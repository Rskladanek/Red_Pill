from sqlalchemy import (
    Column,
    Integer,
    String,
    Text,
    Boolean,
    ForeignKey,
    UniqueConstraint,
    Index,
)
from sqlalchemy.orm import relationship
from app.db import Base


class Lesson(Base):
    __tablename__ = "lessons"

    id = Column(Integer, primary_key=True)
    track = Column(String, nullable=False, index=True)      # "mind" | "body" | "soul"
    module = Column(String, nullable=False, index=True)     # np. "Foundations", "Focus"
    title = Column(String, nullable=False)
    html = Column(Text, nullable=False, default="")

    __table_args__ = (
        UniqueConstraint("track", "module", "title", name="uq_lesson_unique"),
        Index("ix_lesson_track_module", "track", "module"),
    )


class UserLesson(Base):
    __tablename__ = "user_lessons"

    id = Column(Integer, primary_key=True)
    user_id = Column(Integer, ForeignKey("users.id", ondelete="CASCADE"), nullable=False, index=True)
    lesson_id = Column(Integer, ForeignKey("lessons.id", ondelete="CASCADE"), nullable=False, index=True)
    completed = Column(Boolean, nullable=False, default=False)

    # relacje – nie musimy dopinać back_populates w User, żeby uniknąć kolejnego import hell
    user = relationship("User")
    lesson = relationship("Lesson")

    __table_args__ = (
        UniqueConstraint("user_id", "lesson_id", name="uq_user_lesson"),
    )


class QuizQuestion(Base):
    __tablename__ = "quiz_questions"

    id = Column(Integer, primary_key=True)
    track = Column(String, nullable=False, index=True)      # "mind" | "body" | "soul"
    module = Column(String, nullable=False, index=True)     # np. "Foundations"
    question = Column(Text, nullable=False)
    opt_a = Column(String, nullable=False)
    opt_b = Column(String, nullable=False)
    opt_c = Column(String, nullable=False)
    # 0 -> A, 1 -> B, 2 -> C
    correct = Column(Integer, nullable=False, default=0)

    __table_args__ = (
        Index("ix_quiz_track_module", "track", "module"),
    )
