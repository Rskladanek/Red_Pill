from fastapi import APIRouter, Depends, HTTPException
from pydantic import BaseModel
from typing import Literal, Dict, Any
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy import select
from ..deps import get_db, get_current_user
from ..models.user import User

router = APIRouter(
    prefix="/v1",
    tags=["lessons"],
)

# ---- DEFINICJE LEKCJI / QUIZÓW ----
# Każdy tor ma:
# - theory
# - practice
# - quiz: { id, question, answers, correct }
# Uwaga: correct NIE leci do frontendu.

TRACKS: Dict[str, Dict[str, Any]] = {
    "mind": {
        "theory": {
            "id": 101,
            "title": "Status > bycie lubianym",
            "content": (
                "Nie grasz, żeby cię lubili. Grasz, żeby cię respektowali.\n"
                "Różnica jest prosta: lubią klauna, słuchają lidera.\n"
                "Przestań kupować uwagę żartami i samodeprecjacją. Cisza + spojrzenie to też komunikat."
            ),
        },
        "practice": {
            "id": 102,
            "title": "Nie przepraszaj odruchowo",
            "content": (
                "Dziś eliminujesz automatyczne 'sorry' za rzeczy, które nie są twoją winą.\n"
                "Zamiast 'sorki że zawracam głowę' mów 'Potrzebuję X' / 'Potrzebuję odpowiedzi'."
            ),
        },
        "quiz": {
            "id": 103,
            "question": "Kto realnie kontroluje sytuację w rozmowie?",
            "answers": {
                "A": "Ten kto mówi najwięcej, najgłośniej, nonstop.",
                "B": "Ten kto kontroluje rytm rozmowy i nie reaguje emocjonalnie.",
                "C": "Ten kto jest najbardziej miły i zgadza się ze wszystkimi.",
            },
            "correct": "B",
        },
    },
    "body": {
        "theory": {
            "id": 201,
            "title": "Twoja postura to twoja reklama",
            "content": (
                "Pierwsze co ludzie widzą to barki, szyja i głowa.\n"
                "Garbisz się = zmęczony, zdominowany, przegrany.\n"
                "Prosto = obecny, groźny, nie do zignorowania."
            ),
        },
        "practice": {
            "id": 202,
            "title": "Barki w dół i lekko do tyłu",
            "content": (
                "Wejście do pokoju = barki nie przy uszach, broda neutralnie, krok spokojny.\n"
                "Nie szuraj jak dziecko, nie napinaj się jak kulturysta. Spokój to luksus."
            ),
        },
        "quiz": {
            "id": 203,
            "question": "Perfumy nakładasz:",
            "answers": {
                "A": "Na szyję / nadgarstki / klatkę (ciepło skóry rozprasza zapach).",
                "B": "Na ubranie, żeby waliło na 5 metrów.",
                "C": "Na włosy i w usta.",
            },
            "correct": "A",
        },
    },
    "soul": {
        "theory": {
            "id": 301,
            "title": "Twój kręgosłup > ich komfort",
            "content": (
                "Jeżeli ugłaskujesz innych po to, żeby było 'spokojnie', uczysz ludzi że mogą tobą sterować.\n"
                "To nie jest dobroć. To jest tresura psa.\n"
                "Facet bez granic to nie jest 'miły'. To jest bezużyteczny."
            ),
        },
        "practice": {
            "id": 302,
            "title": "Twoje DLACZEGO",
            "content": (
                "Zapisz jedno zdanie: 'Nie mogę być miękki, bo ___'. "
                "Ma boleć. Ma być prawdziwe. Bez insta-motywacyjnych pierdół."
            ),
        },
        "quiz": {
            "id": 303,
            "question": "Czy dzisiaj zgodziłeś się na coś, czego nie chciałeś, tylko żeby uniknąć konfliktu?",
            "answers": {
                "A": "Tak.",
                "B": "Nie.",
                "C": "Nie, ale prawie się złamałem.",
            },
            "correct": "B",
        },
    },
}


def _require_track(track: str) -> Dict[str, Any]:
    if track not in TRACKS:
        raise HTTPException(status_code=404, detail="Track not found")
    return TRACKS[track]


def _public_quiz_block(q: Dict[str, Any]) -> Dict[str, Any]:
    # Nie wysyłamy pola "correct".
    return {
        "id": q["id"],
        "question": q["question"],
        "answers": q["answers"],
    }


@router.get("/{track}/lesson")
async def get_lesson(
    track: str,
    current_user: User = Depends(get_current_user),
):
    data = _require_track(track)
    return {
        "theory": data["theory"],
        "practice": data["practice"],
        "check": _public_quiz_block(data["quiz"]),
    }


# ----- XP / RANK LOGIKA -----

RANKS = [
    ("Adept", 0),
    ("Warrior", 50),
    ("Knight", 150),
    ("Warlord", 400),
]


def _rank_for_xp(xp: int) -> str:
    # bierzemy najwyższą rangę, do której xp >= próg
    best = RANKS[0][0]
    for name, req in RANKS:
        if xp >= req:
            best = name
    return best


async def _award_xp(
    db: AsyncSession,
    user_id: int,
    gain: int,
) -> Dict[str, Any]:
    # pobierz usera
    res = await db.execute(select(User).where(User.id == user_id))
    user = res.scalar_one_or_none()
    if not user:
        raise HTTPException(status_code=404, detail="User not found")

    # dodaj XP
    user.experience += gain

    # sprawdź rangę
    before_rank = user.rank
    after_rank = _rank_for_xp(user.experience)
    rank_up = False
    if after_rank != before_rank:
        user.rank = after_rank
        rank_up = True

    await db.commit()
    await db.refresh(user)

    return {
        "xp_gain": gain,
        "new_xp": user.experience,
        "rank_up": rank_up,
        "new_rank": user.rank,
    }


# ----- QUIZ ODPOWIEDŹ -----

class QuizAnswerIn(BaseModel):
    question_id: int
    answer: str  # "A" | "B" | "C"


@router.post("/{track}/answer")
async def submit_quiz_answer(
    track: str,
    body: QuizAnswerIn,
    db: AsyncSession = Depends(get_db),
    current_user: User = Depends(get_current_user),
):
    data = _require_track(track)
    quiz = data["quiz"]

    # sprawdź że odpowiada na właściwe pytanie
    if body.question_id != quiz["id"]:
        raise HTTPException(status_code=400, detail="Bad question id")

    # normalizujemy odpowiedź
    picked = body.answer.strip().upper()
    correct = quiz["correct"].strip().upper()

    # jeśli źle -> brak XP
    if picked != correct:
        # odśwież usera żeby mieć aktualne XP/rank bez zmian
        res = await db.execute(select(User).where(User.id == current_user.id))
        user_now = res.scalar_one_or_none()
        if not user_now:
            raise HTTPException(status_code=404, detail="User not found")

        return {
            "correct": False,
            "xp_gain": 0,
            "new_xp": user_now.experience,
            "rank_up": False,
            "new_rank": user_now.rank,
        }

    # jeśli dobrze -> XP + ewentualny awans
    reward = 5
    result = await _award_xp(db, current_user.id, reward)
    result["correct"] = True
    return result
