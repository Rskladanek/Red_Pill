from datetime import datetime
from typing import List, Optional

from fastapi import APIRouter, Depends, HTTPException, Query
from sqlalchemy.orm import Session

from ..deps import get_db, get_current_user
from ..models.user import User
from ..models.content import Lesson, QuizQuestion, UserLesson, UserAnswer
from ..schemas.content import (
    ModuleListItem, LessonOut, QuestionOut,
    QuizAnswerIn, QuizAnswerOut
)

router = APIRouter(prefix="/v1/mind", tags=["mind"])

XP_CORRECT = 5
XP_WRONG = 0  # jak chcesz „pocieszenie”, zmień na 1


def _award_xp_mind(db: Session, user: User, delta: int) -> None:
    # Pola mogą nazywać się różnie – ustaw tylko istniejące
    if hasattr(user, "xp_mind"):
        user.xp_mind = (user.xp_mind or 0) + delta
    if hasattr(user, "experience"):
        user.experience = (user.experience or 0) + delta
    db.add(user)


def _stats_tuple(user: User) -> tuple[int, int, int, int]:
    xm = getattr(user, "xp_mind", 0) or 0
    xb = getattr(user, "xp_body", 0) or 0
    xs = getattr(user, "xp_soul", 0) or 0
    exp = getattr(user, "experience", xm + xb + xs) or (xm + xb + xs)
    return xm, xb, xs, exp


@router.get("/modules", response_model=list[ModuleListItem])
def list_modules(db: Session = Depends(get_db), current: User = Depends(get_current_user)):
    lessons = (
        db.query(Lesson)
        .filter(Lesson.track == "mind", Lesson.is_active == True)
        .order_by(Lesson.order_index.asc(), Lesson.id.asc())
        .all()
    )

    # stan ukończenia
    done_map = {
        (ul.lesson_id): ul.completed
        for ul in db.query(UserLesson).filter(UserLesson.user_id == current.id).all()
    }

    out: list[ModuleListItem] = []
    for l in lessons:
        out.append(
            ModuleListItem(
                id=l.id, title=l.title, summary=l.summary or "",
                order_index=l.order_index, completed=bool(done_map.get(l.id, False))
            )
        )
    return out


@router.get("/modules/{lesson_id}", response_model=LessonOut)
def get_module(lesson_id: int, db: Session = Depends(get_db), current: User = Depends(get_current_user)):
    lesson: Optional[Lesson] = db.query(Lesson).filter(Lesson.id == lesson_id, Lesson.track == "mind").first()
    if not lesson:
        raise HTTPException(status_code=404, detail="Lesson not found")

    # nie podawaj 'correct' do frontu
    questions = (
        db.query(QuizQuestion)
        .filter(QuizQuestion.lesson_id == lesson_id)
        .order_by(QuizQuestion.id.asc())
        .all()
    )
    q_out = [QuestionOut.model_validate(q) for q in questions]

    return LessonOut(
        id=lesson.id,
        track=lesson.track,
        slug=lesson.slug,
        title=lesson.title,
        summary=lesson.summary,
        body_md=lesson.body_md,
        order_index=lesson.order_index,
        is_active=lesson.is_active,
        questions=q_out
    )


@router.post("/answer", response_model=QuizAnswerOut)
def answer(payload: QuizAnswerIn, db: Session = Depends(get_db), current: User = Depends(get_current_user)):
    # aliasy już ogarnia Pydantic (quiz_id->lesson_id, selected->answer)
    if payload.question_id is None:
        raise HTTPException(status_code=422, detail="question_id is required")

    q: Optional[QuizQuestion] = db.query(QuizQuestion).filter(
        QuizQuestion.id == payload.question_id,
        QuizQuestion.lesson_id == payload.lesson_id
    ).first()
    if not q:
        raise HTTPException(status_code=404, detail="Question not found")

    is_correct = (payload.answer == q.correct)

    # Upsert user_answer
    ua: Optional[UserAnswer] = db.query(UserAnswer).filter(
        UserAnswer.user_id == current.id,
        UserAnswer.question_id == q.id
    ).first()

    first_time_correct = False
    if ua is None:
        ua = UserAnswer(
            user_id=current.id,
            question_id=q.id,
            selected=payload.answer,
            is_correct=is_correct,
            answered_at=datetime.utcnow()
        )
        db.add(ua)
        first_time_correct = is_correct
    else:
        # jeśli wcześniej było źle, a teraz dobrze — nagrodź
        if is_correct and (not ua.is_correct):
            first_time_correct = True
        ua.selected = payload.answer
        ua.is_correct = is_correct
        ua.answered_at = datetime.utcnow()
        db.add(ua)

    awarded = 0
    if first_time_correct:
        awarded = XP_CORRECT
        _award_xp_mind(db, current, awarded)
    elif not ua.is_correct and XP_WRONG:
        awarded = XP_WRONG
        _award_xp_mind(db, current, awarded)

    # czy moduł kompletny? -> wszystkie pytania mają user_answer
    total_q = db.query(QuizQuestion).filter(QuizQuestion.lesson_id == q.lesson_id).count()
    answered_q = db.query(UserAnswer).filter(
        UserAnswer.user_id == current.id,
        UserAnswer.question_id.in_(
            db.query(QuizQuestion.id).filter(QuizQuestion.lesson_id == q.lesson_id).subquery()
        )
    ).count()

    lesson_completed = (answered_q >= total_q and total_q > 0)

    ul: Optional[UserLesson] = db.query(UserLesson).filter(
        UserLesson.user_id == current.id,
        UserLesson.lesson_id == q.lesson_id
    ).first()
    if ul is None:
        ul = UserLesson(
            user_id=current.id,
            lesson_id=q.lesson_id,
            completed=lesson_completed,
            completed_at=datetime.utcnow() if lesson_completed else None
        )
    else:
        ul.completed = lesson_completed
        ul.completed_at = datetime.utcnow() if lesson_completed else None
    db.add(ul)

    db.commit()
    db.refresh(current)

    xp_mind, xp_body, xp_soul, experience = _stats_tuple(current)
    return QuizAnswerOut(
        correct=is_correct,
        awarded=awarded,
        xp_mind=xp_mind,
        xp_body=xp_body,
        xp_soul=xp_soul,
        experience=experience,
        lesson_completed=lesson_completed
    )
