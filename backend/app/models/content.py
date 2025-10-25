from sqlalchemy.orm import Mapped, mapped_column
from sqlalchemy import String, Integer, Enum, Text, Boolean
from .base import BaseModel
import enum

# W której ścieżce jest zadanie / lekcja / cokolwiek
class Track(str, enum.Enum):
    mind = "mind"
    body = "body"
    soul = "soul"

# Zadanie praktyczne do zrobienia w realu (dzienne wyzwania)
class ContentTask(BaseModel):
    __tablename__ = "content_tasks"

    id: Mapped[int] = mapped_column(primary_key=True)

    # "mind" / "body" / "soul"
    track: Mapped[Track] = mapped_column(Enum(Track))

    # nagłówek
    title: Mapped[str] = mapped_column(String(120))

    # opis co dokładnie zrobić / jak się zachować
    description: Mapped[str] = mapped_column(Text)

    difficulty: Mapped[int] = mapped_column(Integer, default=1)

    active: Mapped[bool] = mapped_column(Boolean, default=True, server_default="true")


# Lekcje do MIND/BODY/SOUL
# - theory = teoria (zasady, mindset)
# - practice = instrukcja zachowania/postawy/stylu
# - check = quiz / test samooceny
class LessonType(str, enum.Enum):
    theory = "theory"
    practice = "practice"
    check = "check"

class Lesson(BaseModel):
    __tablename__ = "lessons"

    id: Mapped[int] = mapped_column(primary_key=True)

    track: Mapped[Track] = mapped_column(Enum(Track))          # mind/body/soul
    kind: Mapped[LessonType] = mapped_column(Enum(LessonType)) # theory/practice/check

    title: Mapped[str] = mapped_column(String(200))
    content: Mapped[str] = mapped_column(Text)  # tekst do przeczytania albo polecenie

    # quiz / sprawdzenie wiedzy (opcjonalne pola)
    quiz_a: Mapped[str] = mapped_column(String(200), default="")
    quiz_b: Mapped[str] = mapped_column(String(200), default="")
    quiz_c: Mapped[str] = mapped_column(String(200), default="")
    correct: Mapped[str] = mapped_column(String(1), default="")  # "A"/"B"/"C"

    active: Mapped[bool] = mapped_column(Boolean, default=True, server_default="true")


# Cytaty motywacyjne do "Cytat dnia"
class Quote(BaseModel):
    __tablename__ = "quotes"

    id: Mapped[int] = mapped_column(primary_key=True)

    text: Mapped[str] = mapped_column(Text)
    author: Mapped[str] = mapped_column(String(120))

    active: Mapped[bool] = mapped_column(Boolean, default=True, server_default="true")
