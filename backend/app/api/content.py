from fastapi import APIRouter, Depends, HTTPException, Query
from sqlalchemy.orm import Session
from typing import List
from app.deps import get_db, get_current_user
from app.models.content import Lesson, UserLesson, QuizQuestion
from app.schemas.content import LessonOut, LessonCompleteIn, ModulesOut, QuizStartOut, QuizAnswerIn

router = APIRouter(prefix="/v1/content", tags=["content"])


@router.get("/{track}/modules", response_model=List[str])
def list_modules(track: str, db: Session = Depends(get_db), user=Depends(get_current_user)):
    rows = (
        db.query(Lesson.module)
        .filter(Lesson.track == track)
        .distinct()
        .order_by(Lesson.module.asc())
        .all()
    )
    mods = [r[0] for r in rows]
    return mods


@router.get("/{track}/lessons", response_model=List[LessonOut])
def list_lessons(
    track: str,
    module: str = Query(...),
    db: Session = Depends(get_db),
    user=Depends(get_current_user),
):
    lessons = (
        db.query(Lesson)
        .filter(Lesson.track == track, Lesson.module == module)
        .order_by(Lesson.id.asc())
        .all()
    )
    out: List[LessonOut] = []
    for les in lessons:
        comp = (
            db.query(UserLesson)
            .filter(UserLesson.user_id == user.id, UserLesson.lesson_id == les.id)
            .first()
        )
        out.append(LessonOut(id=les.id, title=les.title, completed=bool(comp and comp.completed), html=les.html))
    return out


@router.post("/lessons/{lesson_id}/complete")
def complete_lesson(
    lesson_id: int,
    payload: LessonCompleteIn,
    db: Session = Depends(get_db),
    user=Depends(get_current_user),
):
    les = db.query(Lesson).filter(Lesson.id == lesson_id).first()
    if not les:
        raise HTTPException(status_code=404, detail="Lesson not found")

    rec = (
        db.query(UserLesson)
        .filter(UserLesson.user_id == user.id, UserLesson.lesson_id == lesson_id)
        .first()
    )
    if rec:
        rec.completed = payload.completed
    else:
        rec = UserLesson(user_id=user.id, lesson_id=lesson_id, completed=payload.completed)
        db.add(rec)
    db.commit()
    return {"ok": True}


@router.get("/{track}/quiz/start", response_model=QuizStartOut)
def quiz_start(track: str, module: str = Query("Foundations"), db: Session = Depends(get_db), user=Depends(get_current_user)):
    q = (
        db.query(QuizQuestion)
        .filter(QuizQuestion.track == track, QuizQuestion.module == module)
        .order_by(QuizQuestion.id.asc())
        .first()
    )
    if not q:
        # brak pytań — zwróć prosty placeholder żeby front mógł działać
        return QuizStartOut(
            quiz_id=1,
            question_id=1,
            question="Fallback question: pick anything.",
            options=["Option A", "Option B", "Option C"],
        )
    return QuizStartOut(
        quiz_id=q.id,  # prosto
        question_id=q.id,
        question=q.question,
        options=[q.opt_a, q.opt_b, q.opt_c],
    )


@router.get("/{track}/daily", response_model=QuizStartOut)
def daily(track: str, db: Session = Depends(get_db), user=Depends(get_current_user)):
    # daily = pierwsze pytanie dla tracku
    q = (
        db.query(QuizQuestion)
        .filter(QuizQuestion.track == track)
        .order_by(QuizQuestion.id.asc())
        .first()
    )
    if not q:
        return QuizStartOut(
            quiz_id=1,
            question_id=1,
            question="Daily fallback question.",
            options=["Option A", "Option B", "Option C"],
        )
    return QuizStartOut(
        quiz_id=q.id,
        question_id=q.id,
        question=q.question,
        options=[q.opt_a, q.opt_b, q.opt_c],
    )
