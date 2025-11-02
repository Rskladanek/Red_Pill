import os
from datetime import datetime, timedelta
from typing import Any, Dict
from jose import jwt, JWTError
from passlib.context import CryptContext

JWT_SECRET = os.getenv("JWT_SECRET", "devsecret")
JWT_ALG = "HS256"
_pwd = CryptContext(schemes=["bcrypt"], deprecated="auto")

def get_password_hash(password: str) -> str:
    return _pwd.hash(password)

def verify_password(password: str, password_hash: str) -> bool:
    return _pwd.verify(password, password_hash)

def create_access_token(user_id: int, email: str, expires: timedelta | None = None) -> str:
    if expires is None:
        expires = timedelta(days=30)
    payload = {
        "sub": str(user_id),
        "email": email,
        "exp": datetime.utcnow() + expires,
    }
    return jwt.encode(payload, JWT_SECRET, algorithm=JWT_ALG)

def decode_token(token: str) -> Dict[str, Any]:
    try:
        return jwt.decode(token, JWT_SECRET, algorithms=[JWT_ALG])
    except JWTError as e:
        # log do konsoli, żeby było jasne czemu 401
        print(f"[JWT] decode error: {e}")
        return {}
