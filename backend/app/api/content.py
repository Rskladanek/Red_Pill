from __future__ import annotations

from typing import List, Dict, Any

from fastapi import APIRouter, Depends, Query, HTTPException
from sqlalchemy import select
from sqlalchemy.orm import Session

from app.api.deps import get_db, get_current_user
from app.schemas.content import (
    LessonOut,
    CompleteIn,
    QuizStartOut,
    QuizAnswerIn,
    TaskOut,
)
from app.models.content import Lesson, QuizQuestion, Task
from app.models.user import User, UserLesson
from app.core.xp import grant_xp

router = APIRouter(prefix="/content", tags=["content"])


# ---------- MODULES ----------


@router.get("/{track}/modules", response_model=List[str])
def list_modules(
    track: str,
    db: Session = Depends(get_db),
    user: User = Depends(get_current_user),
) -> List[str]:
    """
    Zwraca listę nazw modułów dla danego tracka (mind/body/soul).
    """
    rows = (
        db.execute(
            select(Lesson.module)
            .where(Lesson.track == track)
            .group_by(Lesson.module)
            .order_by(Lesson.module)
        )
        .scalars()
        .all()
    )
    return list(rows)


# ---------- LESSONS ----------


@router.get("/{track}/lessons", response_model=List[LessonOut])
def list_lessons(
    track: str,
    module: str = Query(...),
    db: Session = Depends(get_db),
    user: User = Depends(get_current_user),
) -> List[LessonOut]:
    """
    Zwraca listę lekcji w module + flaga completed dla usera.
    """
    lessons = (
        db.query(Lesson)
        .filter_by(track=track, module=module)
        .order_by(Lesson.order)
        .all()
    )

    user_lesson_ids = {
        ul.lesson_id
        for ul in db.query(UserLesson)
        .filter_by(user_id=user.id)
        .all()
    }

    result: List[LessonOut] = []
    for l in lessons:
        result.append(
            LessonOut(
                id=l.id,
                track=l.track,
                module=l.module,
                order=l.order,
                title=l.title,
                content=l.content,
                completed=l.id in user_lesson_ids,
            )
        )
    return result


# ---------- COMPLETE LESSON + XP ----------


@router.post("/lessons/{lesson_id}/complete")
def complete_lesson(
    lesson_id: int,
    data: CompleteIn,
    db: Session = Depends(get_db),
    user: User = Depends(get_current_user),
) -> Dict[str, Any]:
    """
    Oznacza lekcję jako ukończoną / nieukończoną.

    Front wysyła JSON: { "complete": true/false }

    Reguły XP:
    - jeśli complete == true i user nie miał jeszcze tej lekcji -> +10 XP w danym tracku
    - jeśli complete == false -> usuwamy flagę ukończenia, XP NIE cofamy
      (XP to historia, nie checkbox).
    """
    lesson = db.get(Lesson, lesson_id)
    if not lesson:
        raise HTTPException(status_code=404, detail="Lesson not found")

    track = lesson.track  # "mind" / "body" / "soul"

    existing = (
        db.query(UserLesson)
        .filter_by(user_id=user.id, lesson_id=lesson_id)
        .first()
    )

    if data.complete:
        if existing is None:
            ul = UserLesson(user_id=user.id, lesson_id=lesson_id)
            db.add(ul)
            # pierwszy raz skończona lekcja -> XP
            grant_xp(db, user.id, track=track, amount=10)
    else:
        # odznaczanie lekcji: kasujemy UserLesson,
        # ale nie cofamy XP (XP to "przerobione kiedyś")
        if existing is not None:
            db.delete(existing)

    db.commit()
    return {"status": "ok"}


# ---------- QUIZ START ----------


@router.get("/{track}/quiz/start", response_model=QuizStartOut)
def quiz_start(
    track: str,
    module: str = Query(...),
    db: Session = Depends(get_db),
    user: User = Depends(get_current_user),
) -> QuizStartOut:
    """
    Zwraca pierwsze pytanie quizu dla modułu.
    """
    q = (
        db.query(QuizQuestion)
        .filter_by(track=track, module=module)
        .order_by(QuizQuestion.order)
        .first()
    )
    if not q:
        raise HTTPException(status_code=404, detail="No quiz questions")

    # QuizQuestion ma metodę as_public() zwracającą:
    # { "question_id", "module", "question", "options" }
    data = q.as_public()
    return QuizStartOut.model_validate(data)


# ---------- QUIZ ANSWER + XP ----------


@router.post("/{track}/quiz/answer")
def quiz_answer(
    track: str,
    payload: QuizAnswerIn,
    db: Session = Depends(get_db),
    user: User = Depends(get_current_user),
) -> Dict[str, Any]:
    """
    Sprawdza odpowiedź, przyznaje XP, zwraca kolejne pytanie albo {}.

    Reguły XP:
    - poprawna odpowiedź -> +5 XP w danym tracku
    - niepoprawna -> 0 XP, ale dalej aktualizujemy streak,
      bo ważne jest samo podejście (ogarnia grant_xp).
    """
    q = (
        db.query(QuizQuestion)
        .filter_by(
            id=payload.question_id,
            track=track,
            module=payload.module,
        )
        .first()
    )
    if not q:
        raise HTTPException(status_code=404, detail="Question not found")

    options = q.options or []
    if payload.answer_index < 0 or payload.answer_index >= len(options):
        raise HTTPException(status_code=400, detail="Invalid answer index")

    correct = payload.answer_index == q.correct_index

    if correct:
        grant_xp(db, user.id, track=track, amount=5)
    else:
        # jeśli chcesz, żeby sam fakt podejścia do quizu też ruszał streak:
        # grant_xp(db, user.id, track=track, amount=0)
        pass

    # kolejne pytanie w module
    nxt = (
        db.query(QuizQuestion)
        .filter_by(track=track, module=q.module)
        .filter(QuizQuestion.order > q.order)
        .order_by(QuizQuestion.order)
        .first()
    )

    db.commit()

    if not nxt:
        # koniec quizu
        return {}

    return nxt.as_public()


# ---------- TASKS ----------


@router.get("/{track}/tasks", response_model=List[TaskOut])
def list_tasks(
    track: str,
    module: str = Query(...),
    db: Session = Depends(get_db),
    user: User = Depends(get_current_user),
) -> List[TaskOut]:
    """
    Zwraca taski dla modułu (Body/Soul w przyszłości też to wykorzystają).
    """
    tasks = (
        db.query(Task)
        .filter_by(track=track, module=module)
        .order_by(Task.order)
        .all()
    )
    return [
        TaskOut(
            id=t.id,
            track=t.track,
            module=t.module,
            order=t.order,
            title=t.title,
            body=t.body,
            difficulty=t.difficulty,
            checklist=list(t.checklist or []),
        )
        for t in tasks
    ]
