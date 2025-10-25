# app/core/security.py
from datetime import datetime, timedelta, timezone
from jose import jwt, JWTError
from passlib.context import CryptContext
from .config import settings
import hashlib

ALGO = "HS256"
pwd = CryptContext(schemes=["bcrypt"], deprecated="auto")

def _norm_pw(p: str) -> str:
    """
    Hashujemy najpierw sha256 -> hex (64 znaki),
    żeby bcrypt zawsze dostał stałą długość i nie ucinał.
    """
    return hashlib.sha256(p.encode("utf-8")).hexdigest()

def hash_pw(p: str) -> str:
    return pwd.hash(_norm_pw(p))

def verify_pw(plain: str, pw_hash: str) -> bool:
    return pwd.verify(_norm_pw(plain), pw_hash)

def make_token(sub: str, minutes: int) -> str:
    now = datetime.now(timezone.utc)
    payload = {
        "sub": sub,
        "iat": int(now.timestamp()),
        "exp": int((now + timedelta(minutes=minutes)).timestamp()),
    }
    return jwt.encode(payload, settings.JWT_SECRET, algorithm=ALGO)

def decode_token(token: str) -> dict | None:
    try:
        return jwt.decode(token, settings.JWT_SECRET, algorithms=[ALGO])
    except JWTError:
        return None
