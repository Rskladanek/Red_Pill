from typing import List
from fastapi import APIRouter, Depends, Query, HTTPException
from sqlalchemy import select, func
from sqlalchemy.orm import Session
from app.api.deps import get_db, get_current_user
from app.schemas.content import LessonOut, CompleteIn, QuizStartOut, QuizAnswerIn, TaskOut
from app.models.content import Lesson, QuizQuestion, Task
from app.models.user import User, UserLesson, UserQuizAnswer

router = APIRouter(prefix="/content", tags=["content"])

@router.get("/{track}/modules", response_model=List[str])
def list_modules(track: str, db: Session = Depends(get_db), user: User = Depends(get_current_user)):
    rows = (db.execute(select(Lesson.module)
            .where(Lesson.track == track)
            .group_by(Lesson.module)
            .order_by(func.min(Lesson.order))).scalars().all())
    return rows

@router.get("/{track}/lessons", response_model=List[LessonOut])
def list_lessons(track: str, module: str = Query(...), db: Session = Depends(get_db), user: User = Depends(get_current_user)):
    lessons = (db.execute(select(Lesson)
               .where(Lesson.track == track, Lesson.module == module)
               .order_by(Lesson.order)).scalars().all())
    completed_ids = {ul.lesson_id for ul in user.lessons if ul.completed}
    return [LessonOut(id=l.id, track=l.track, module=l.module, order=l.order, title=l.title, content=l.content, completed=(l.id in completed_ids)) for l in lessons]

@router.post("/lessons/{lesson_id}/complete")
def set_lesson_complete(lesson_id: int, body: CompleteIn, db: Session = Depends(get_db), user: User = Depends(get_current_user)):
    ul = db.query(UserLesson).filter_by(user_id=user.id, lesson_id=lesson_id).first()
    if not ul:
        ul = UserLesson(user_id=user.id, lesson_id=lesson_id, completed=False)
        db.add(ul)
    ul.completed = bool(body.complete)
    prog = user.progress
    if body.complete:
        prog.xp_mind += 5; prog.exp_total += 5
    db.commit()
    return {"ok": True}

@router.get("/{track}/quiz/start", response_model=QuizStartOut)
def quiz_start(track: str, module: str = Query(...), db: Session = Depends(get_db), user: User = Depends(get_current_user)):
    q = (db.query(QuizQuestion)
         .filter_by(track=track, module=module)
         .order_by(QuizQuestion.order.asc()).first())
    if not q:
        raise HTTPException(404, "No questions")
    return q.as_public()

@router.post("/{track}/quiz/answer")
def quiz_answer(track: str, data: QuizAnswerIn, db: Session = Depends(get_db), user: User = Depends(get_current_user)):
    q = db.get(QuizQuestion, data.question_id)
    if not q or q.track != track or q.module != data.module:
        raise HTTPException(404, "Question not found")
    correct = (q.correct_index == data.answer_index)
    db.add(UserQuizAnswer(user_id=user.id, question_id=q.id, picked_index=data.answer_index, correct=correct))
    prog = user.progress
    if correct:
        if track == "mind": prog.xp_mind += 10
        elif track == "body": prog.xp_body += 10
        else: prog.xp_soul += 10
        prog.exp_total += 10
    nxt = (db.query(QuizQuestion).filter_by(track=track, module=q.module)
           .filter(QuizQuestion.order > q.order).order_by(QuizQuestion.order.asc()).first())
    db.commit()
    return {} if not nxt else nxt.as_public()

@router.get("/{track}/tasks", response_model=List[TaskOut])
def list_tasks(track: str, module: str = Query(...), db: Session = Depends(get_db), user: User = Depends(get_current_user)):
    tasks = db.query(Task).filter_by(track=track, module=module).order_by(Task.order).all()
    return [TaskOut.model_validate(t.__dict__) for t in tasks]
