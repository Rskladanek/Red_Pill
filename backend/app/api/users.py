# app/api/users.py
from fastapi import APIRouter, Depends
from ..deps import get_current_user
from ..models.user import User

router = APIRouter()

def _get(obj, name, default=None):
    return getattr(obj, name, default)

@router.get("/me")
def read_me(user: User = Depends(get_current_user)):
    # zwracamy “bezpieczne” pole usera do frontu
    return {
        "id": _get(user, "id"),
        "email": _get(user, "email"),
        "username": _get(user, "username"),
        "experience": _get(user, "experience", 0),
        "xp_mind": _get(user, "xp_mind", 0),
        "xp_body": _get(user, "xp_body", 0),
        "xp_soul": _get(user, "xp_soul", 0),
        "streak_days": _get(user, "streak_days", 0),
        "last_active": _get(user, "last_active").isoformat() if _get(user, "last_active") else None,
    }
