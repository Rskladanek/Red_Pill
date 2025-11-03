from sqlalchemy.orm import Session
from app.models.content import Lesson, QuizQuestion, Task
from .data_focus import FOCUS_LESSONS, FOCUS_QUIZ, FOCUS_TASKS
from .data_foundations import FOUNDATIONS_LESSONS, FOUNDATIONS_QUIZ

def _ensure_lesson(db: Session, track: str, module: str, order: int, title: str, content: str):
    if not db.query(Lesson).filter_by(track=track, module=module, order=order).first():
        db.add(Lesson(track=track, module=module, order=order, title=title, content=content))

def _ensure_question(db: Session, track: str, module: str, order: int, question: str, options: list, correct: int):
    if not db.query(QuizQuestion).filter_by(track=track, module=module, order=order).first():
        db.add(QuizQuestion(track=track, module=module, order=order, question=question, options=options, correct_index=correct))

def _ensure_task(db: Session, track: str, module: str, order: int, title: str, body: str, difficulty: str, checklist: list):
    if not db.query(Task).filter_by(track=track, module=module, order=order).first():
        db.add(Task(track=track, module=module, order=order, title=title, body=body, difficulty=difficulty, checklist=checklist))

def run_seed_if_empty(db: Session):
    if db.query(Lesson).first():
        return
    for l in FOCUS_LESSONS:
        _ensure_lesson(db, "mind", "Focus", l["order"], l["title"], l["content"])
    for (o, q, opts, c) in FOCUS_QUIZ:
        _ensure_question(db, "mind", "Focus", o, q, opts, c)
    for t in FOCUS_TASKS:
        _ensure_task(db, "mind", "Focus", t["order"], t["title"], t["body"], t["difficulty"], t["checklist"])
    for l in FOUNDATIONS_LESSONS:
        _ensure_lesson(db, "mind", "Foundations", l["order"], l["title"], l["content"])
    for (o, q, opts, c) in FOUNDATIONS_QUIZ:
        _ensure_question(db, "mind", "Foundations", o, q, opts, c)
    db.commit()
