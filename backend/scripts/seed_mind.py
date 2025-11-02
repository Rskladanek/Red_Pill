from sqlalchemy.orm import Session
from app.models.base import SessionLocal, engine
from app.models.learning import Module, Task, Quiz, Question, Option
from app.models.base import Base

def run():
    Base.metadata.create_all(bind=engine)
    db: Session = SessionLocal()
    if db.query(Module).filter_by(track="mind", title="Narracja i kontrola rozmowy").first():
        print("Mind seed already exists"); return

    m = Module(track="mind", title="Narracja i kontrola rozmowy",
               summary="Kontrola rytmu rozmowy > głośność.",
               content_md="## Teoria\n- Status > bycie lubianym.\n\n## Praktyka\n- Pauza przed odpowiedzią.\n",
               order=1, is_active=True)
    db.add(m); db.flush()

    for i, txt in enumerate([
        "Zrób pauzę przed odpowiedzią (2 rozmowy).",
        "Zastąp 'sorry' zdaniem 'Potrzebuję X'.",
        "Zapisz 3 pytania otwarte na jutro."
    ], start=1):
        db.add(Task(module_id=m.id, text=txt, order=i))

    qz = Quiz(module_id=m.id, title="Quiz: Mind – moduł 1")
    db.add(qz); db.flush()

    def add_q(order, text, correct, opts):
        q = Question(quiz_id=qz.id, text=text, order=order); db.add(q); db.flush()
        for k, t in opts.items():
            db.add(Option(question_id=q.id, key=k, text=t, is_correct=(k==correct)))

    add_q(1, "Kto kontroluje rozmowę?", "B", {"A":"Najgłośniejszy","B":"Ten kto kontroluje rytm","C":"Najmilszy"})
    add_q(2, "Pauza to sygnał:", "C", {"A":"Brak wiedzy","B":"Stres","C":"Kontrola tempa"})
    add_q(3, "Zamiast 'sorry':", "A", {"A":"Formułujesz potrzebę","B":"Mówisz głośniej","C":"Zmieniasz temat"})
    add_q(4, "Najlepsze pytania:", "C", {"A":"Tak/Nie","B":"Retoryczne","C":"Otwarte"})
    add_q(5, "Status podkreślasz:", "B", {"A":"Emotki","B":"Spokój i rytm","C":"Szybkie riposty"})
    add_q(6, "Słuchają lidera, bo:", "A", {"A":"Wyższy status","B":"Dowcip","C":"Długość mowy"})
    add_q(7, "W konflikcie najpierw:", "B", {"A":"Mów szybciej","B":"Zwolnij","C":"Zmieniaj temat"})
    add_q(8, "Cisza + spojrzenie to:", "A", {"A":"Też komunikat","B":"Brak reakcji","C":"Agresja"})
    add_q(9, "Ktoś przerywa – co robisz?", "C", {"A":"Przemów go","B":"Kończysz","C":"Wracasz do wątku"})
    add_q(10,"Cel modułu:", "A", {"A":"Kontrola rytmu","B":"Bycie głośnym","C":"Zero pauz"})
    db.commit(); print("Seed OK")

if __name__ == "__main__":
    run()
