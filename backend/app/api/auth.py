from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy import select
from sqlalchemy.ext.asyncio import AsyncSession

from ..deps import get_db, get_current_user
from ..models.user import User
from ..schemas.auth import RegisterIn, LoginIn, TokenOut
from ..schemas.user import UserOut
from ..core.security import hash_pw, verify_pw, make_token
from ..core.config import settings

router = APIRouter(prefix="/v1/auth", tags=["auth"])

def _build_auth_response(u: User) -> TokenOut:
    """
    Zwracamy token w paru polach naraz, żeby frontend nie miał focha,
    plus pełny obiekt usera.
    """
    t = make_token(str(u.id), settings.ACCESS_MIN)
    user_data = UserOut.model_validate(u)
    return TokenOut(
        access=t,
        token=t,
        jwt=t,
        user=user_data,
    )

@router.post("/register", response_model=TokenOut)
async def register(data: RegisterIn, db: AsyncSession = Depends(get_db)):
    # sprawdź czy email już istnieje
    q = await db.execute(select(User).where(User.email == data.email))
    if q.scalar_one_or_none():
        raise HTTPException(status_code=400, detail="Email exists")

    # utwórz usera
    u = User(
        email=data.email,
        pw_hash=hash_pw(data.password),
    )
    db.add(u)
    await db.commit()
    await db.refresh(u)

    # zwróć token + user
    return _build_auth_response(u)

@router.post("/login", response_model=TokenOut)
async def login(data: LoginIn, db: AsyncSession = Depends(get_db)):
    q = await db.execute(select(User).where(User.email == data.email))
    u = q.scalar_one_or_none()
    if not u or not verify_pw(data.password, u.pw_hash):
        raise HTTPException(status_code=401, detail="Invalid credentials")

    return _build_auth_response(u)

@router.get("/check", response_model=UserOut)
async def check(user: User = Depends(get_current_user)):
    return user
