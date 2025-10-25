from sqlalchemy.orm import Mapped, mapped_column
from sqlalchemy import ForeignKey, Date, Enum, UniqueConstraint, String
from datetime import date
from .base import BaseModel
from .content import Track
import enum

# status zadania dla usera
class TaskStatus(str, enum.Enum):
    pending = "pending"  # jeszcze nie ruszone
    done = "done"        # zrobione
    skip = "skip"        # ominął
    fail = "fail"        # zawalił / przyznał się że nie dał rady

# to jest "zadanie przypisane użytkownikowi na dzisiaj"
class DailyAssignment(BaseModel):
    __tablename__ = "daily_assignments"
    __table_args__ = (
        # user ma tylko jedno zadanie typu 'mind' na dany dzień,
        # jedno 'body' na dany dzień itd.
        UniqueConstraint("user_id", "track", "day", name="uq_user_track_day"),
    )

    id: Mapped[int] = mapped_column(primary_key=True)

    user_id: Mapped[int] = mapped_column(ForeignKey("users.id"))
    task_id: Mapped[int] = mapped_column(ForeignKey("content_tasks.id"))

    # mind / body / soul
    track: Mapped[Track] = mapped_column(Enum(Track))

    # na jaki dzień to przypisane
    day: Mapped[date] = mapped_column()

    # aktualny status (czy wykonałeś czy nie)
    status: Mapped[TaskStatus] = mapped_column(
        Enum(TaskStatus),
        default=TaskStatus.pending,
    )

    # user może dopisać komentarz (np. "nie zrobiłem bo stchórzyłem przy szefie")
    note: Mapped[str] = mapped_column(String(400), default="")
