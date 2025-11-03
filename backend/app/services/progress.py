from sqlalchemy.orm import Session
from app.models.progress import UserProgress
def build_summary(db: Session, user_id: int):
    p = db.query(UserProgress).filter_by(user_id=user_id).first()
    if not p:
        p = UserProgress(user_id=user_id); db.add(p); db.commit(); db.refresh(p)
    return {"xp_mind": p.xp_mind, "xp_body": p.xp_body, "xp_soul": p.xp_soul, "exp": p.exp_total, "streak": p.streak}
