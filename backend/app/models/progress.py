from sqlalchemy.orm import Mapped, mapped_column, relationship
from sqlalchemy import Integer, ForeignKey
from app.db.base import Base

class UserProgress(Base):
    __tablename__ = "user_progress"
    user_id: Mapped[int] = mapped_column(ForeignKey("users.id"), primary_key=True)
    xp_mind: Mapped[int] = mapped_column(Integer, default=0)
    xp_body: Mapped[int] = mapped_column(Integer, default=0)
    xp_soul: Mapped[int] = mapped_column(Integer, default=0)
    exp_total: Mapped[int] = mapped_column(Integer, default=0)
    streak: Mapped[int] = mapped_column(Integer, default=0)
    user = relationship("User", back_populates="progress")
