from fastapi import APIRouter, Depends, HTTPException, Query
from sqlalchemy.orm import Session
from sqlalchemy import func

from ..deps import get_db, get_current_user
from ..models.user import User
from ..models.progress import UserProgress
from ..models.content import Lesson, UserLesson, Quiz, QuizQuestion, UserQuizProgress
from ..schemas.content import ModuleOut, LessonWithState, QuizQuestionOut, QuizResultOut

router = APIRouter(prefix="/v1/lessons", tags=["lessons"])


@router.get("/modules", response_model=list[ModuleOut])
def get_modules(track: str = Query(..., pattern="^(mind|body|soul)$"),
                db: Session = Depends(get_db),
                user: User = Depends(get_current_user)):
    # Moduły = grupowanie po module
    rows = (db.query(Lesson.module, func.count(Lesson.id))
              .filter(Lesson.track == track)
              .group_by(Lesson.module)
              .order_by(Lesson.module)
              .all())
    out: list[ModuleOut] = []
    for module, count_lessons in rows:
        # postęp: ile lekcji oznaczonych "done"
        done_count = (db.query(func.count(UserLesson.id))
                        .join(Lesson, UserLesson.lesson_id == Lesson.id)
                        .filter(UserLesson.user_id == user.id,
                                Lesson.track == track,
                                Lesson.module == module,
                                UserLesson.done == 1)
                        .scalar() or 0)

        quiz = db.query(Quiz).filter(Quiz.track == track, Quiz.module == module).first()
        out.append(ModuleOut(
            module=module,
            title=f"Moduł {module}",
            lesson_count=count_lessons,
            quiz_id=quiz.id if quiz else 0,
            progress=(done_count / max(1, count_lessons))
        ))
    return out


@router.get("/by_module", response_model=list[LessonWithState])
def get_lessons_by_module(track: str,
                          module: int,
                          db: Session = Depends(get_db),
                          user: User = Depends(get_current_user)):
    lessons = (db.query(Lesson)
                 .filter(Lesson.track == track, Lesson.module == module)
                 .order_by(Lesson.id)
                 .all())
    out: list[LessonWithState] = []
    for l in lessons:
        ul = (db.query(UserLesson)
                .filter(UserLesson.user_id == user.id, UserLesson.lesson_id == l.id)
                .first())
        out.append(LessonWithState(id=l.id, title=l.title, done=bool(ul and ul.done), html=l.html))
    return out


@router.post("/mark_done")
def mark_lesson_done(lesson_id: int,
                     done: bool,
                     db: Session = Depends(get_db),
                     user: User = Depends(get_current_user)):
    lesson = db.query(Lesson).filter(Lesson.id == lesson_id).first()
    if not lesson:
        raise HTTPException(404, "Lesson not found")
    rec = (db.query(UserLesson)
             .filter(UserLesson.user_id == user.id, UserLesson.lesson_id == lesson_id)
             .first())
    if not rec:
        rec = UserLesson(user_id=user.id, lesson_id=lesson_id, done=1 if done else 0)
        db.add(rec)
    else:
        rec.done = 1 if done else 0
    db.commit()
    return {"ok": True}


# ===== QUIZ =====

def _question_to_out(q: QuizQuestion, quiz_id: int) -> QuizQuestionOut:
    return QuizQuestionOut(
        quiz_id=quiz_id,
        question_id=q.id,
        order=q.order,
        question=q.question,
        options=[q.option_a, q.option_b, q.option_c]
    )


@router.post("/quiz/start", response_model=QuizQuestionOut)
def start_quiz(track: str, module: int,
               db: Session = Depends(get_db),
               user: User = Depends(get_current_user)):
    quiz = db.query(Quiz).filter(Quiz.track == track, Quiz.module == module).first()
    if not quiz:
        raise HTTPException(404, "Quiz not found")

    # zresetuj postęp jeśli był
    up = db.query(UserQuizProgress).filter(
        UserQuizProgress.user_id == user.id,
        UserQuizProgress.quiz_id == quiz.id
    ).first()
    if up:
        up.current_order = 0
        up.correct_count = 0
        up.finished = 0
    else:
        up = UserQuizProgress(user_id=user.id, quiz_id=quiz.id)
        db.add(up)
    db.commit()

    q = (db.query(QuizQuestion)
           .filter(QuizQuestion.quiz_id == quiz.id)
           .order_by(QuizQuestion.order).first())
    if not q:
        raise HTTPException(404, "Quiz has no questions")
    return _question_to_out(q, quiz.id)


@router.post("/quiz/answer", response_model=QuizResultOut)
def answer_quiz(quiz_id: int, question_id: int, answer: int,
                db: Session = Depends(get_db),
                user: User = Depends(get_current_user)):
    up = db.query(UserQuizProgress).filter(
        UserQuizProgress.user_id == user.id,
        UserQuizProgress.quiz_id == quiz_id
    ).first()
    if not up or up.finished:
        raise HTTPException(400, "Quiz not started or already finished")

    q = db.query(QuizQuestion).filter(QuizQuestion.id == question_id,
                                      QuizQuestion.quiz_id == quiz_id).first()
    if not q:
        raise HTTPException(404, "Question not found")

    correct_now = int(answer == q.correct)
    if q.order == up.current_order:
        up.correct_count += correct_now
        up.current_order += 1

    # kolejny
    next_q = (db.query(QuizQuestion)
                .filter(QuizQuestion.quiz_id == quiz_id, QuizQuestion.order == up.current_order)
                .first())

    xp_awarded = 0
    finished = False
    next_payload = None
    if not next_q:
        finished = True
        up.finished = 1

        # nagroda: 10 XP za moduł + 2 za każdą poprawną
        xp_awarded = 10 + 2 * up.correct_count

        # wpis do UserProgress
        prog = db.query(UserProgress).filter(UserProgress.user_id == user.id).first()
        if not prog:
            prog = UserProgress(user_id=user.id)
            db.add(prog)
        prog.xp_mind += xp_awarded
        prog.experience += xp_awarded
    else:
        next_payload = _question_to_out(next_q, quiz_id)

    db.commit()
    return QuizResultOut(correct=bool(correct_now), finished=finished, xp_awarded=xp_awarded, next=next_payload)
