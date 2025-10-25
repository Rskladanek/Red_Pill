# app/schemas/user.py
from pydantic import BaseModel
from datetime import datetime

class UserOut(BaseModel):
    id: int
    email: str
    rank: str
    experience: int
    hard_mode: bool
    timezone: str
    created_at: datetime

    class Config:
        from_attributes = True
