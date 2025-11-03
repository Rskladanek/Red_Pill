from pydantic import BaseModel
from typing import List
class LessonOut(BaseModel):
    id: int
    track: str
    module: str
    order: int
    title: str
    content: str
    completed: bool = False
class CompleteIn(BaseModel):
    complete: bool
class QuizStartOut(BaseModel):
    question_id: int
    module: str
    question: str
    options: List[str]
class QuizAnswerIn(BaseModel):
    module: str
    question_id: int
    answer_index: int
class TaskOut(BaseModel):
    id: int
    track: str
    module: str
    order: int
    title: str
    body: str
    difficulty: str
    checklist: List[str] = []
