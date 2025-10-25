from sqlalchemy.orm import Mapped, mapped_column
from sqlalchemy import String, Integer, Boolean
from .base import BaseModel
import enum


class UserRank(str, enum.Enum):
    ADEPT = "Adept"
    WARRIOR = "Wojownik"
    STRATEGIST = "Strateg"
    MASTER = "Mistrz"


class User(BaseModel):
    __tablename__ = "users"
    id: Mapped[int] = mapped_column(primary_key=True)
    email: Mapped[str] = mapped_column(String(255), unique=True, index=True)
    pw_hash: Mapped[str] = mapped_column(String(255))
    timezone: Mapped[str] = mapped_column(String(64), default="Europe/Warsaw")

    # --- NOWE POLA ---
    # Pola do gamifikacji i statusu
    rank: Mapped[UserRank] = mapped_column(String(50), default=UserRank.ADEPT)
    experience: Mapped[int] = mapped_column(Integer, default=0)

    # Pole do "Hard Mode"
    hard_mode: Mapped[bool] = mapped_column(Boolean, default=False)
