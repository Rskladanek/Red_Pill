from sqlalchemy.orm import Mapped, mapped_column
from sqlalchemy import String, Integer, Enum, Text, Boolean
from .base import BaseModel
import enum

# to określa do której ścieżki należy zadanie
class Track(str, enum.Enum):
    mind = "mind"
    body = "body"
    soul = "soul"

# pojedyncze "zadanie dnia" typu:
# - MIND: "Trzymaj kontakt wzrokowy"
# - BODY: "Wyprostuj barki 3x dziennie"
# - SOUL: "Zapisz swoje 'dlaczego'"
class ContentTask(BaseModel):
    __tablename__ = "content_tasks"

    id: Mapped[int] = mapped_column(primary_key=True)

    # mind / body / soul
    track: Mapped[Track] = mapped_column(Enum(Track))

    # krótki nagłówek
    title: Mapped[str] = mapped_column(String(120))

    # opis działania, jak wykonać
    description: Mapped[str] = mapped_column(Text)

    # trudność (na przyszłość, np. do progresji)
    difficulty: Mapped[int] = mapped_column(Integer, default=1)

    # czy aktywne, żeby można było wyłączyć słabe zadania
    active: Mapped[bool] = mapped_column(Boolean, default=True, server_default="true")
