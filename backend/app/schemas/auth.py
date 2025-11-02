from pydantic import BaseModel, EmailStr


class AuthIn(BaseModel):
    email: EmailStr
    password: str


class UserOut(BaseModel):
    id: int
    email: EmailStr

    class Config:
        from_attributes = True  # zamiast orm_mode


class AuthOut(BaseModel):
    token: str
    user: UserOut
