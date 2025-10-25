from sqlalchemy.orm import Mapped, mapped_column
from sqlalchemy import String, Integer, Boolean, ForeignKey, Enum, Date, UniqueConstraint
from .base import BaseModel
from datetime import date
import enum


class Status(str, enum.Enum):
    done = "done"
    skip = "skip"
    fail = "fail"

class HabitCategory(str, enum.Enum):
    PRESENCE = "Prezencja"     # Wygląd, postura, higiena
    MIND = "Umysł"             # Nauka (Greene itp.), medytacja
    BODY = "Ciało"             # Trening, dieta
    CONTROL = "Kontrola"       # Kontrola dopaminy, zimne prysznice
    OTHER = "Inne"

class Habit(BaseModel):
    __tablename__ = "habits"

    id: Mapped[int] = mapped_column(primary_key=True)
    user_id: Mapped[int] = mapped_column(ForeignKey("users.id"))
    title: Mapped[str] = mapped_column(String(120))
    cadence: Mapped[str] = mapped_column(String(20), default="daily")
    difficulty: Mapped[int] = mapped_column(Integer, default=3)
    active: Mapped[bool] = mapped_column(Boolean, default=True)

    # --- NOWE POLE ---
    # Kategoria rytuału
    category: Mapped[HabitCategory] = mapped_column(String(50), default=HabitCategory.OTHER)


class HabitLog(BaseModel):
    __tablename__ = "habit_logs"
    __table_args__ = (UniqueConstraint("habit_id", "date", name="uq_habit_day"),)

    id: Mapped[int] = mapped_column(primary_key=True)
    habit_id: Mapped[int] = mapped_column(ForeignKey("habits.id", ondelete="CASCADE")) # Lepsze usuwanie
    date: Mapped[date] = mapped_column(Date)
    status: Mapped[Status] = mapped_column(Enum(Status))
    note: Mapped[str] = mapped_column(String(400), default="")
