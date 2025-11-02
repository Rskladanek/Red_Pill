from sqlalchemy import Column, Integer, String
from sqlalchemy.orm import relationship
from app.db import Base

class User(Base):
    __tablename__ = "users"

    id = Column(Integer, primary_key=True, index=True)
    email = Column(String, unique=True, index=True, nullable=False)
    password_hash = Column(String, nullable=False)

    # one-to-many – wczyta się po imporcie UserProgress
    progress = relationship(
        "UserProgress",
        back_populates="user",
        cascade="all, delete-orphan",
        passive_deletes=True,
    )
