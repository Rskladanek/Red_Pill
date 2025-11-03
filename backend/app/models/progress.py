from __future__ import annotations

from datetime import date, datetime

from sqlalchemy import Integer, ForeignKey, Date, DateTime, func
from sqlalchemy.orm import Mapped, mapped_column, relationship

from app.db.base import Base


class UserProgress(Base):
    """
    Sumaryczne statystyki usera:
    - XP na filary (mind / body / soul)
    - łączny EXP (exp_total)
    - streak + ostatni dzień aktywności
    """

    __tablename__ = "user_progress"

    user_id: Mapped[int] = mapped_column(
        ForeignKey("users.id"),
        primary_key=True,
        index=True,
    )

    xp_mind: Mapped[int] = mapped_column(Integer, default=0)
    xp_body: Mapped[int] = mapped_column(Integer, default=0)
    xp_soul: Mapped[int] = mapped_column(Integer, default=0)
    exp_total: Mapped[int] = mapped_column(Integer, default=0)

    streak: Mapped[int] = mapped_column(Integer, default=0)
    last_active: Mapped[date | None] = mapped_column(Date, nullable=True)

    created_at: Mapped[datetime] = mapped_column(
        DateTime(timezone=True),
        server_default=func.now(),
    )

    user = relationship("User", back_populates="progress")
