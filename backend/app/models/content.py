from sqlalchemy import Integer, String, Text, JSON
from sqlalchemy.orm import relationship, Mapped, mapped_column
from app.db.base import Base

class Lesson(Base):
    __tablename__ = "lessons"
    id: Mapped[int] = mapped_column(Integer, primary_key=True)
    track: Mapped[str] = mapped_column(String, index=True)
    module: Mapped[str] = mapped_column(String, index=True)
    order: Mapped[int] = mapped_column(Integer, index=True)
    title: Mapped[str] = mapped_column(String, nullable=False)
    content: Mapped[str] = mapped_column(Text, nullable=False)
    users = relationship("UserLesson", back_populates="lesson", cascade="all, delete")

class QuizQuestion(Base):
    __tablename__ = "quiz_questions"
    id: Mapped[int] = mapped_column(Integer, primary_key=True)
    track: Mapped[str] = mapped_column(String, index=True)
    module: Mapped[str] = mapped_column(String, index=True)
    order: Mapped[int] = mapped_column(Integer, index=True)
    question: Mapped[str] = mapped_column(Text, nullable=False)
    options: Mapped[list] = mapped_column(JSON, nullable=False)
    correct_index: Mapped[int] = mapped_column(Integer, nullable=False)
    explanation: Mapped[str] = mapped_column(Text, nullable=True)

    answers = relationship("UserQuizAnswer", back_populates="question", cascade="all, delete")

    def as_public(self):
        return {
            "question_id": self.id,
            "module": self.module,
            "question": self.question,
            "options": self.options,
        }

class Task(Base):
    __tablename__ = "tasks"
    id: Mapped[int] = mapped_column(Integer, primary_key=True)
    track: Mapped[str] = mapped_column(String, index=True)
    module: Mapped[str] = mapped_column(String, index=True)
    order: Mapped[int] = mapped_column(Integer, index=True)
    title: Mapped[str] = mapped_column(String, nullable=False)
    body: Mapped[str] = mapped_column(Text, nullable=False)
    difficulty: Mapped[str] = mapped_column(String, default="easy")
    checklist: Mapped[list] = mapped_column(JSON, default=list)

    attempts = relationship("UserTaskAttempt", back_populates="task", cascade="all, delete")
