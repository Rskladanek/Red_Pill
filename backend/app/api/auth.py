# app/api/auth.py
from fastapi import APIRouter, Depends, HTTPException, status
from pydantic import BaseModel, EmailStr
from sqlalchemy.orm import Session

from ..deps import get_db
from ..core.security import get_password_hash, verify_password, create_access_token
from ..models.user import User

router = APIRouter(prefix="/v1/auth", tags=["auth"])

class AuthIn(BaseModel):
    email: EmailStr
    password: str

@router.post("/register")
def register(data: AuthIn, db: Session = Depends(get_db)):
    existing = db.query(User).filter(User.email == data.email).first()
    if existing:
        # Masz już takiego usera
        raise HTTPException(status_code=status.HTTP_409_CONFLICT, detail="User already exists")

    u = User(email=data.email, password_hash=get_password_hash(data.password))
    db.add(u)
    db.commit()
    db.refresh(u)

    token = create_access_token(u.id, u.email)  # <<< WŁAŚCIWE WYWOŁANIE
    return {"token": token, "user": {"id": u.id, "email": u.email}}

@router.post("/login")
def login(data: AuthIn, db: Session = Depends(get_db)):
    user = db.query(User).filter(User.email == data.email).first()
    if not user or not verify_password(data.password, user.password_hash):
        raise HTTPException(status_code=status.HTTP_401_UNAUTHORIZED, detail="Invalid credentials")

    token = create_access_token(user.id, user.email)  # <<< WŁAŚCIWE WYWOŁANIE
    return {"token": token, "user": {"id": user.id, "email": user.email}}
