#!/usr/bin/env python3
"""
Tworzy tabele lessons/quiz_questions/user_lessons/user_answers,
dodaje kolumny xp_* do users (jeśli brak),
i seeduje przykładowy moduł Mind z 10 pytaniami.
"""
from sqlalchemy import text
from app.models.base import engine, SessionLocal, Base
from app.models.content import Lesson, QuizQuestion
from app.models.user import User  # upewnia się, że tabela users jest zarejestrowana


def add_user_columns_if_missing():
    with engine.connect() as conn:
        # SQLite nie ma IF NOT EXISTS dla kolumn — więc próbujemy i ignorujemy błędy
        for stmt in [
            "ALTER TABLE users ADD COLUMN xp_mind INTEGER DEFAULT 0",
            "ALTER TABLE users ADD COLUMN xp_body INTEGER DEFAULT 0",
            "ALTER TABLE users ADD COLUMN xp_soul INTEGER DEFAULT 0",
            "ALTER TABLE users ADD COLUMN streak_days INTEGER DEFAULT 0",
            "ALTER TABLE users ADD COLUMN experience INTEGER DEFAULT 0",
        ]:
            try:
                conn.execute(text(stmt))
            except Exception:
                pass
        conn.commit()


def create_tables():
    Base.metadata.create_all(bind=engine)


def seed_mind_if_empty():
    db = SessionLocal()
    try:
        exists = db.query(Lesson).filter(Lesson.track == "mind").first()
        if exists:
            return

        l1 = Lesson(
            track="mind",
            slug="focus-101",
            title="Focus 101: Podstawy uwagi",
            summary="Krótki moduł o skupieniu, trybach pracy i eliminacji szumu.",
            body_md="# Focus 101\n\n- Tryb głęboki vs płytki\n- Reguła 50/10\n- Eliminacja notyfikacji\n",
            order_index=1,
            is_active=True,
        )
        db.add(l1)
        db.flush()

        questions = [
            ("Tryb pracy sprzyjający długim blokom bez przerw to:", "Tryb głęboki", "Tryb płytki", "Multitasking", "Tryb zadaniowy", "A"),
            ("Optymalny blok pracy wg popularnej reguły to:", "25/5", "50/10", "15/5", "90/30", "B"),
            ("Co najbardziej zabija skupienie?", "Notyfikacje", "Kawa", "Zimna woda", "Krótkie przerwy", "A"),
            ("Najlepsze miejsce na telefon w czasie pracy:", "Na biurku", "W ręce", "W innym pokoju", "Na ładowarce obok", "C"),
            ("Kiedy planować blok głębokiej pracy?", "Gdy jesteś najbardziej świeży", "Tuż po obiedzie", "Wieczorem po 22", "Kiedykolwiek", "A"),
            ("Co z listą zadań w bloku deep work?", "Mieć 1 cel", "Mieć 10 celów", "Otworzyć Slacka", "Sprawdzać social media", "A"),
            ("Jaki hałas jest najgorszy dla koncentracji?", "Rozmowy ludzkie", "Szum ulicy", "Muzyka klasyczna", "Biały szum", "A"),
            ("Ile zadań równolegle w deep work?", "2-3", "1", "5", "Nie ma znaczenia", "B"),
            ("Co zazwyczaj poprawia wejście w rytm?", "Rytuał startowy", "Losowe zaczynanie", "Nowe narzędzia", "Zmiana pokoju", "A"),
            ("Co z przerwami w 50/10?", "Patrzenie w telefon", "Pisanie na czacie", "Krótki spacer/oddech", "Nowe zadanie", "C"),
        ]
        for text_q, a, b, c, d, corr in questions:
            db.add(QuizQuestion(
                lesson_id=l1.id,
                text=text_q, a=a, b=b, c=c, d=d,
                correct=corr,
                explanation=None
            ))

        db.commit()
        print("[seed] Mind: dodano Focus 101 z 10 pytaniami")
    finally:
        db.close()


if __name__ == "__main__":
    add_user_columns_if_missing()
    create_tables()
    seed_mind_if_empty()
    print("[migrate_002] OK")
