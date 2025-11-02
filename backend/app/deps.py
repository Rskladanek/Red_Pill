from fastapi import Depends, HTTPException, Request
from sqlalchemy.orm import Session
from .db import SessionLocal
from .core.security import decode_token
from .models.user import User

def get_db():
    db = SessionLocal()
    try:
        yield db
    finally:
        db.close()

def get_current_user(request: Request, db: Session = Depends(get_db)) -> User:
    auth = request.headers.get("Authorization")
    if not auth:
        raise HTTPException(status_code=401, detail="Missing Authorization header")
    parts = auth.split()
    if len(parts) != 2 or parts[0].lower() != "bearer":
        raise HTTPException(status_code=401, detail="Invalid Authorization header")
    data = decode_token(parts[1])
    uid = data.get("sub")
    if not uid:
        raise HTTPException(status_code=401, detail="Invalid or expired token")
    user = db.get(User, int(uid))
    if not user:
        raise HTTPException(status_code=401, detail="User not found")
    return user
