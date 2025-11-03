from __future__ import annotations

from datetime import date
from typing import Literal

from sqlalchemy.orm import Session

from app.models.progress import UserProgress

Track = Literal["mind", "body", "soul"]

_TRACK_FIELD = {
    "mind": "xp_mind",
    "body": "xp_body",
    "soul": "xp_soul",
}


def get_or_create_progress(db: Session, user_id: int) -> UserProgress:
    prog = db.query(UserProgress).filter_by(user_id=user_id).first()
    if not prog:
        prog = UserProgress(user_id=user_id)
        db.add(prog)
        db.flush()
    return prog


def grant_xp(
    db: Session,
    user_id: int,
    *,
    track: Track,
    amount: int,
) -> UserProgress:
    """
    Dodaje XP i ogarnia streak wg zasad:
    - pierwsza aktywność ever -> streak = 1
    - nowy dzień po poprzednim -> +1
    - luka > 1 dzień -> streak = 1
    - kilka akcji w tym samym dniu -> streak się nie zmienia
    """
    if amount <= 0:
        return get_or_create_progress(db, user_id)

    prog = get_or_create_progress(db, user_id)

    field = _TRACK_FIELD.get(track)
    if field is None:
        raise ValueError(f"Unknown track '{track}'")

    # XP w filarze
    setattr(prog, field, getattr(prog, field) + amount)
    # XP globalne
    prog.exp_total += amount

    # streak dzienny
    today = date.today()
    if prog.last_active is None:
        prog.streak = 1
    else:
        delta = (today - prog.last_active).days
        if delta == 0:
            # ta sama data -> zostaw streak jak był
            pass
        elif delta == 1:
            prog.streak += 1
        else:
            prog.streak = 1

    prog.last_active = today
    return prog
