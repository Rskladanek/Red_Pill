from pydantic import BaseModel
from typing import List, Optional

class TaskOut(BaseModel):
    id: int
    text: str
    order: int
    done: bool = False
    class Config: orm_mode = True

class OptionOut(BaseModel):
    key: str
    text: str
    class Config: orm_mode = True

class QuestionOut(BaseModel):
    id: int
    text: str
    order: int
    options: List[OptionOut]
    class Config: orm_mode = True

class QuizPreview(BaseModel):
    quiz_id: int
    title: str
    questions_count: int

class ModuleListItem(BaseModel):
    id: int
    title: str
    summary: str
    progress_pct: int
    quiz: Optional[QuizPreview]
    class Config: orm_mode = True

class ModuleDetail(BaseModel):
    id: int
    title: str
    summary: str
    content_md: str
    tasks: List[TaskOut]
    quiz: QuizPreview

class StartQuizOut(BaseModel):
    attempt_id: int
    quiz_id: int
    questions: List[QuestionOut]

class SubmitAnswerIn(BaseModel):
    attempt_id: int
    answers: List[dict]  # {"question_id":int, "selected":str}

class SubmitResult(BaseModel):
    score: int
    max_score: int
    xp_awarded: int
