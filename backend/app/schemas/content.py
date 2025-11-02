from pydantic import BaseModel, Field
from typing import List, Optional


class LessonOut(BaseModel):
    id: int
    title: str
    completed: bool = False
    html: Optional[str] = None

    class Config:
        from_attributes = True


class LessonCompleteIn(BaseModel):
    completed: bool = True


class ModulesOut(BaseModel):
    modules: List[str]


class QuizStartOut(BaseModel):
    quiz_id: int
    question_id: int
    question: str
    options: List[str]


class QuizAnswerIn(BaseModel):
    track: str
    quiz_id: Optional[int] = None
    question_id: Optional[int] = None
    answer: str


class SummaryOut(BaseModel):
    xp_mind: int = 0
    xp_body: int = 0
    xp_soul: int = 0
    streak_days: int = 0
    experience: int = 0
