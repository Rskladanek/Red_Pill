# app/schemas/user.py
from pydantic import BaseModel, EmailStr
from typing import Optional

class UserOut(BaseModel):
    id: int
    email: EmailStr
    username: Optional[str] = None

    class Config:
        from_attributes = True
