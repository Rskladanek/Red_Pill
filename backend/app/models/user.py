from datetime import datetime
from sqlalchemy import Integer, String, DateTime, func, ForeignKey, Boolean
from sqlalchemy.orm import relationship, Mapped, mapped_column
from app.db.base import Base

class User(Base):
    __tablename__ = "users"
    id: Mapped[int] = mapped_column(Integer, primary_key=True, index=True)
    email: Mapped[str] = mapped_column(String, unique=True, index=True, nullable=False)
    password_hash: Mapped[str] = mapped_column(String, nullable=False)
    created_at: Mapped[datetime] = mapped_column(
        DateTime(timezone=True),
        server_default=func.now(),
    )

    progress = relationship("UserProgress", back_populates="user", uselist=False, cascade="all, delete")
    lessons = relationship("UserLesson", back_populates="user", cascade="all, delete")
    quiz_answers = relationship("UserQuizAnswer", back_populates="user", cascade="all, delete")
    task_attempts = relationship("UserTaskAttempt", back_populates="user", cascade="all, delete")

class UserLesson(Base):
    __tablename__ = "user_lessons"
    id: Mapped[int] = mapped_column(Integer, primary_key=True)
    user_id: Mapped[int] = mapped_column(ForeignKey("users.id"), index=True)
    lesson_id: Mapped[int] = mapped_column(ForeignKey("lessons.id"), index=True)
    completed: Mapped[bool] = mapped_column(Boolean, default=False)

    user = relationship("User", back_populates="lessons")
    lesson = relationship("Lesson", back_populates="users")

class UserQuizAnswer(Base):
    __tablename__ = "user_quiz_answers"
    id: Mapped[int] = mapped_column(Integer, primary_key=True)
    user_id: Mapped[int] = mapped_column(ForeignKey("users.id"))
    question_id: Mapped[int] = mapped_column(ForeignKey("quiz_questions.id"))
    picked_index: Mapped[int] = mapped_column(Integer, nullable=False)
    correct: Mapped[bool] = mapped_column(Boolean, default=False)
    created_at: Mapped[datetime] = mapped_column(
        DateTime(timezone=True),
        server_default=func.now(),
    )

    user = relationship("User", back_populates="quiz_answers")
    question = relationship("QuizQuestion", back_populates="answers")

class UserTaskAttempt(Base):
    __tablename__ = "user_task_attempts"
    id: Mapped[int] = mapped_column(Integer, primary_key=True)
    user_id: Mapped[int] = mapped_column(ForeignKey("users.id"))
    task_id: Mapped[int] = mapped_column(ForeignKey("tasks.id"))
    payload: Mapped[str] = mapped_column(String, nullable=True)
    success: Mapped[bool] = mapped_column(Boolean, default=False)
    created_at: Mapped[datetime] = mapped_column(
        DateTime(timezone=True),
        server_default=func.now(),
    )

    user = relationship("User", back_populates="task_attempts")
    task = relationship("Task", back_populates="attempts")
