from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from sqlalchemy.orm import Session
from app.db import Base, engine, SessionLocal

from .api.auth import router as auth_router
from .api.content import router as content_router
from .api.progress import router as progress_router
from .models.content import Lesson, QuizQuestion
from fastapi.middleware.cors import CORSMiddleware
app = FastAPI(title="RedPill API")

app.add_middleware(
    CORSMiddleware,
    allow_origin_regex=r"^https?://(localhost|127\.0\.0\.1)(:\d+)?$",
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

app.include_router(auth_router)
app.include_router(content_router)
app.include_router(progress_router)


def seed(db: Session):
    # moduły/lekcje (MIND)
    if db.query(Lesson).filter(Lesson.track == "mind").count() == 0:
        lessons = [
            # Foundations
            Lesson(track="mind", module="Foundations", title="Foundations — Lesson 1",
                   html="<h2>Attention basics</h2><p>Two-minute focus drill…</p>"),
            Lesson(track="mind", module="Foundations", title="Foundations — Lesson 2",
                   html="<h2>Systems vs Goals</h2><p>Work the system, not the finish line.</p>"),
            # Focus
            Lesson(track="mind", module="Focus", title="Focus — Lesson 1",
                   html="<h2>Deep Work Warmup</h2><p>Breath 4-7-8 + timer 25m.</p>"),
            Lesson(track="mind", module="Focus", title="Focus — Lesson 2",
                   html="<h2>Context switching kills</h2><p>Batch notifications.</p>"),
            # Memory
            Lesson(track="mind", module="Memory", title="Memory — Lesson 1",
                   html="<h2>Spaced repetition</h2><p>SM-2 in 3 bullets.</p>"),
            Lesson(track="mind", module="Memory", title="Memory — Lesson 2",
                   html="<h2>Chunking</h2><p>Group 7±2 → 3–4.</p>"),
            # Logic
            Lesson(track="mind", module="Logic", title="Logic — Lesson 1",
                   html="<h2>Truth tables</h2><p>AND/OR/NOT.</p>"),
            Lesson(track="mind", module="Logic", title="Logic — Lesson 2",
                   html="<h2>Implication</h2><p>P→Q, contrapositive.</p>"),
        ]
        db.add_all(lessons)

    # quizy (MIND)
    if db.query(QuizQuestion).filter(QuizQuestion.track == "mind").count() == 0:
        qs = [
            QuizQuestion(track="mind", module="Foundations",
                         question="Which practice reduces context switching?",
                         opt_a="Batch notifications", opt_b="Random checking", opt_c="Multi-tasking", correct="A"),
            QuizQuestion(track="mind", module="Focus",
                         question="Pomodoro default work interval?",
                         opt_a="15 min", opt_b="25 min", opt_c="45 min", correct="B"),
        ]
        db.add_all(qs)

    db.commit()


@app.on_event("startup")
def on_startup():
    Base.metadata.create_all(bind=engine)
    db = SessionLocal()
    try:
        seed(db)
    finally:
        db.close()


@app.get("/healthz")
def healthz():
    return {"ok": True}
