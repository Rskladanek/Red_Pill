from pydantic import BaseModel, EmailStr
from .user import UserOut

class RegisterIn(BaseModel):
    email: EmailStr
    password: str

class LoginIn(BaseModel):
    email: EmailStr
    password: str

class TokenOut(BaseModel):
    access: str
    token: str
    jwt: str
    user: UserOut

    class Config:
        from_attributes = True
