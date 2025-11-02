from datetime import datetime
from sqlalchemy import (Column, Integer, String, Boolean, ForeignKey,
                        DateTime, Text, UniqueConstraint)
from sqlalchemy.orm import relationship
from .base import Base

class Module(Base):
    __tablename__ = "modules"
    id = Column(Integer, primary_key=True)
    track = Column(String(16), index=True, default="mind")  # mind/body/soul
    title = Column(String(120), nullable=False)
    summary = Column(String(280), default="")
    content_md = Column(Text, default="")
    order = Column(Integer, default=0)
    is_active = Column(Boolean, default=True)

    tasks = relationship("Task", order_by="Task.order", back_populates="module")
    quiz = relationship("Quiz", uselist=False, back_populates="module")

class Task(Base):
    __tablename__ = "tasks"
    id = Column(Integer, primary_key=True)
    module_id = Column(Integer, ForeignKey("modules.id"), nullable=False, index=True)
    text = Column(String(240), nullable=False)
    order = Column(Integer, default=0)
    module = relationship("Module", back_populates="tasks")

class Quiz(Base):
    __tablename__ = "quizzes"
    id = Column(Integer, primary_key=True)
    module_id = Column(Integer, ForeignKey("modules.id"), nullable=False, unique=True)
    title = Column(String(120), default="Quiz")
    module = relationship("Module", back_populates="quiz")
    questions = relationship("Question", order_by="Question.order", back_populates="quiz")

class Question(Base):
    __tablename__ = "questions"
    id = Column(Integer, primary_key=True)
    quiz_id = Column(Integer, ForeignKey("quizzes.id"), nullable=False, index=True)
    text = Column(String(400), nullable=False)
    order = Column(Integer, default=0)
    quiz = relationship("Quiz", back_populates="questions")
    options = relationship("Option", order_by="Option.key", back_populates="question")

class Option(Base):
    __tablename__ = "options"
    id = Column(Integer, primary_key=True)
    question_id = Column(Integer, ForeignKey("questions.id"), nullable=False, index=True)
    key = Column(String(1), nullable=False)   # 'A'/'B'/'C'/'D'
    text = Column(String(240), nullable=False)
    is_correct = Column(Boolean, default=False)
    __table_args__ = (UniqueConstraint('question_id', 'key', name='uq_q_key'),)
    question = relationship("Question", back_populates="options")

class TaskProgress(Base):
    __tablename__ = "task_progress"
    id = Column(Integer, primary_key=True)
    user_id = Column(Integer, index=True, nullable=False)
    task_id = Column(Integer, ForeignKey("tasks.id"), index=True, nullable=False)
    done = Column(Boolean, default=False)
    updated_at = Column(DateTime, default=datetime.utcnow)
    __table_args__ = (UniqueConstraint('user_id', 'task_id', name='uq_user_task'),)

class QuizAttempt(Base):
    __tablename__ = "quiz_attempts"
    id = Column(Integer, primary_key=True)
    user_id = Column(Integer, index=True, nullable=False)
    quiz_id = Column(Integer, ForeignKey("quizzes.id"), index=True, nullable=False)
    created_at = Column(DateTime, default=datetime.utcnow)
    score = Column(Integer, default=0)
    max_score = Column(Integer, default=0)
