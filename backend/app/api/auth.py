from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.orm import Session
from app.schemas.auth import RegisterIn, LoginIn, TokenWithUser, UserOut
from app.core.security import get_password_hash, verify_password, create_access_token
from app.api.deps import get_db
from app.models.user import User
from app.models.progress import UserProgress

router = APIRouter(prefix="/auth", tags=["auth"])

@router.post("/register", response_model=TokenWithUser)
def register(data: RegisterIn, db: Session = Depends(get_db)):
    existing = db.query(User).filter(User.email == data.email).first()
    if existing:
        raise HTTPException(status_code=status.HTTP_409_CONFLICT, detail="Email exists")
    u = User(email=data.email, password_hash=get_password_hash(data.password))
    db.add(u); db.flush()
    db.add(UserProgress(user_id=u.id))
    db.commit(); db.refresh(u)
    token = create_access_token(sub=str(u.id), email=u.email)
    return {"token": token, "user": UserOut(id=u.id, email=u.email)}

@router.post("/login", response_model=TokenWithUser)
def login(data: LoginIn, db: Session = Depends(get_db)):
    user = db.query(User).filter(User.email == data.email).first()
    if not user or not verify_password(data.password, user.password_hash):
        raise HTTPException(status_code=status.HTTP_401_UNAUTHORIZED, detail="Bad credentials")
    token = create_access_token(sub=str(user.id), email=user.email)
    return {"token": token, "user": UserOut(id=user.id, email=user.email)}
