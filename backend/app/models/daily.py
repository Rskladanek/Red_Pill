from sqlalchemy.orm import Mapped, mapped_column
from sqlalchemy import ForeignKey, Date, Enum, UniqueConstraint, String
from datetime import date
from .base import BaseModel
from .content import Track
import enum

# status wykonania zadania
class TaskStatus(str, enum.Enum):
    pending = "pending"
    done = "done"
    skip = "skip"
    fail = "fail"

# Zadanie przypisane konkretnemu userowi na konkretny dzień
class DailyAssignment(BaseModel):
    __tablename__ = "daily_assignments"
    __table_args__ = (
        # Jeden user nie dostaje dwóch różnych zadań z tego samego tracka tego samego dnia
        UniqueConstraint("user_id", "track", "day", name="uq_user_track_day"),
    )

    id: Mapped[int] = mapped_column(primary_key=True)

    user_id: Mapped[int] = mapped_column(ForeignKey("users.id"))
    task_id: Mapped[int] = mapped_column(ForeignKey("content_tasks.id"))

    track: Mapped[Track] = mapped_column(Enum(Track))   # mind/body/soul
    day: Mapped[date] = mapped_column()                 # np. 2025-10-25

    status: Mapped[TaskStatus] = mapped_column(
        Enum(TaskStatus),
        default=TaskStatus.pending,
    )

    note: Mapped[str] = mapped_column(String(400), default="")
