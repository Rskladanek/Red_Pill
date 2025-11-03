# app/schemas/progress.py
from pydantic import BaseModel


class ProgressSummary(BaseModel):
    xp_mind: int
    xp_body: int
    xp_soul: int
    exp: int
    streak: int
