from pydantic import BaseModel, EmailStr
class Token(BaseModel):
    token: str
class UserOut(BaseModel):
    id: int
    email: EmailStr
class TokenWithUser(BaseModel):
    token: str
    user: UserOut
class LoginIn(BaseModel):
    email: EmailStr
    password: str
class RegisterIn(BaseModel):
    email: EmailStr
    password: str
