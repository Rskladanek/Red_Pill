# app/seeds/loader.py

from __future__ import annotations

from sqlalchemy.orm import Session

from app.models.content import Lesson
from app.seeds.focus_mind import seed_focus_module
# w przyszłości:
# from app.seeds.mind_foundations import seed_foundations_module
# from app.seeds.body_strength import seed_body_strength
# itd.


def run_seed_if_empty(db: Session) -> None:
    """
    Odpala seedy tylko wtedy, gdy w bazie NIE ma jeszcze żadnych lekcji.
    Dzięki temu:
    - przy pierwszym starcie dostajesz MIND / Focus,
    - przy kolejnych restartach nie duplikujesz danych.
    """
    has_lessons = db.query(Lesson).first()
    if has_lessons:
        return

    seed_focus_module(db)
    # w przyszłości:
    # seed_foundations_module(db)
    # ...
