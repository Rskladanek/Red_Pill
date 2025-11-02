from fastapi import APIRouter, Depends
from sqlalchemy.orm import Session
from app.deps import get_db, get_current_user
from app.models.content import UserLesson, Lesson
from app.schemas.content import SummaryOut

router = APIRouter(prefix="/v1/progress", tags=["progress"])

@router.get("/summary", response_model=SummaryOut)
def summary(db: Session = Depends(get_db), user=Depends(get_current_user)):
    # XP = 10 za ukończoną lekcję — osobno per track
    q = (
        db.query(Lesson.track, UserLesson.completed)
        .join(Lesson, Lesson.id == UserLesson.lesson_id)
        .filter(UserLesson.user_id == user.id, UserLesson.completed == True)  # noqa
        .all()
    )
    xp_mind = sum(10 for t, _ in q if t == "mind")
    xp_body = sum(10 for t, _ in q if t == "body")
    xp_soul = sum(10 for t, _ in q if t == "soul")
    total = xp_mind + xp_body + xp_soul
    # streak – na razie 0; jak chcesz, dołożymy logikę później
    return SummaryOut(xp_mind=xp_mind, xp_body=xp_body, xp_soul=xp_soul, experience=total, streak_days=0)
