from fastapi import APIRouter, Depends, HTTPException, Body
from sqlalchemy.ext.asyncio import AsyncSession
from ..deps import get_db, get_current_user
from ..models.user import User
from ..schemas.user import UserOut
from pydantic import BaseModel

router = APIRouter(prefix="/v1/users", tags=["users"])

class HardModeIn(BaseModel):
    active: bool

@router.get("/me", response_model=UserOut)
async def get_user_profile(user: User = Depends(get_current_user)):
    """
    Zwraca profil zalogowanego użytkownika.
    """
    return user

@router.post("/me/hard-mode")
async def set_hard_mode(
    data: HardModeIn,
    db: AsyncSession = Depends(get_db),
    user: User = Depends(get_current_user)
):
    """
    Włącza lub wyłącza "Hard Mode" dla użytkownika.
    """
    user.hard_mode = data.active
    await db.commit()
    return {"message": f"Hard Mode set to {data.active}", "hard_mode": user.hard_mode}

@router.post("/me/timezone")
async def set_timezone(
    timezone: str = Body(..., embed=True),
    db: AsyncSession = Depends(get_db),
    user: User = Depends(get_current_user)
):
    """
    Pozwala klientowi zaktualizować swoją strefę czasową.
    """
    # Prosta walidacja
    import pytz
    try:
        pytz.timezone(timezone)
        user.timezone = timezone
        await db.commit()
        return {"message": "Timezone updated", "timezone": user.timezone}
    except pytz.UnknownTimeZoneError:
        raise HTTPException(400, "Invalid timezone name")
