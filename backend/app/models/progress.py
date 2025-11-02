from sqlalchemy import Column, Integer, String, ForeignKey, UniqueConstraint
from sqlalchemy.orm import relationship
from app.db import Base

class UserProgress(Base):
    __tablename__ = "user_progress"

    id = Column(Integer, primary_key=True)
    user_id = Column(Integer, ForeignKey("users.id", ondelete="CASCADE"), nullable=False)
    track = Column(String, nullable=False)        # "mind" | "body" | "soul"
    xp = Column(Integer, default=0, nullable=False)
    streak_days = Column(Integer, default=0, nullable=False)

    user = relationship("User", back_populates="progress")

    __table_args__ = (
        UniqueConstraint("user_id", "track", name="uq_user_track"),
    )
