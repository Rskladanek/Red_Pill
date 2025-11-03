from fastapi import APIRouter, Depends
from sqlalchemy.orm import Session
from app.api.deps import get_db, get_current_user
from app.services.progress import build_summary

router = APIRouter(prefix="/progress", tags=["progress"])

@router.get("/summary")
def summary(db: Session = Depends(get_db), user=Depends(get_current_user)):
    return build_summary(db, user.id)
