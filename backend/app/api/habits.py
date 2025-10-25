from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy import select, func
from sqlalchemy.ext.asyncio import AsyncSession
# Zmieniamy zależność na get_current_user
from ..deps import get_db, get_current_user
from ..models.user import User
from ..models.habit import Habit, HabitLog, Status
from ..schemas.habit import HabitIn, HabitOut, CheckIn, StreakOut
from datetime import date, timedelta, datetime
import pytz  # Do obsługi stref czasowych

router = APIRouter(prefix="/v1/habits", tags=["habits"])


# --- Funkcja pomocnicza do logiki rang ---
# (Docelowo można ją wynieść do app/core/gamification.py)
def update_rank(user: User):
    exp = user.experience
    if exp < 1000:
        user.rank = "Adept"
    elif exp < 5000:
        user.rank = "Wojownik"
    elif exp < 15000:
        user.rank = "Strateg"
    else:
        user.rank = "Mistrz"
    # (Można to zrobić bardziej elegancko, np. słownikiem progów)


@router.post("", response_model=HabitOut)
async def create_habit(data: HabitIn, db: AsyncSession = Depends(get_db), user: User = Depends(get_current_user)):
    h = Habit(
        user_id=user.id,
        title=data.title,
        cadence=data.cadence,
        difficulty=data.difficulty,
        category=data.category  # Dodajemy nowe pole
    )
    db.add(h)
    await db.commit()
    await db.refresh(h)
    return h


@router.get("", response_model=list[HabitOut])
async def list_habits(db: AsyncSession = Depends(get_db), user: User = Depends(get_current_user)):
    res = await db.execute(
        select(Habit).where(Habit.user_id == user.id, Habit.active == True).order_by(Habit.id.desc()))
    return res.scalars().all()


@router.post("/{habit_id}/checkin")
async def checkin(habit_id: int, data: CheckIn, db: AsyncSession = Depends(get_db),
                  user: User = Depends(get_current_user)):
    h = await db.get(Habit, habit_id)
    if not h or h.user_id != user.id:
        raise HTTPException(404, "Habit not found")

    # 1. Walidacja Strefy Czasowej (KRYTYCZNE)
    try:
        user_tz = pytz.timezone(user.timezone)
    except pytz.UnknownTimeZoneError:
        user_tz = pytz.timezone(settings.DEFAULT_TZ)

    user_today = datetime.now(user_tz).date()

    if data.date > user_today:
        raise HTTPException(400, "Nie można logować dla przyszłych dat.")
    # Pozwalamy na logowanie do 2 dni wstecz
    if data.date < user_today - timedelta(days=2):
        raise HTTPException(400, "Data jest zbyt odległa w przeszłości.")

    # 2. Walidacja "Hard Mode"
    if user.hard_mode and data.status == Status.skip:
        raise HTTPException(403, "Tryb 'Hard Mode' jest aktywny: nie można pomijać nawyków.")

    # 3. Logika Upsert (znajdź lub stwórz log)
    existing = await db.execute(select(HabitLog).where(HabitLog.habit_id == h.id, HabitLog.date == data.date))
    log = existing.scalar_one_or_none()

    xp_gain = 0
    xp_base = h.difficulty * 10  # Bazowy zysk XP zależy od trudności

    if log is None:
        # Tworzenie nowego logu
        log = HabitLog(habit_id=h.id, date=data.date, status=data.status, note=data.note[:380])
        db.add(log)
        if data.status == Status.done:
            xp_gain = xp_base
    else:
        # Aktualizacja istniejącego logu
        old_status = log.status
        if old_status != Status.done and data.status == Status.done:
            xp_gain = xp_base  # Przyznaj XP przy zmianie na 'done'
        elif old_status == Status.done and data.status != Status.done:
            xp_gain = -xp_base  # Odbierz XP, jeśli ktoś cofa 'done'

        log.status = data.status
        log.note = data.note[:380]

    # 4. Zastosuj XP i sprawdź awans
    if xp_gain != 0:
        user.experience = (user.experience or 0) + xp_gain
        if user.experience < 0:
            user.experience = 0  # XP nie może być ujemne

        old_rank = user.rank
        update_rank(user)  # Sprawdź, czy użytkownik awansował
        new_rank = user.rank

    await db.commit()

    return {
        "ok": True,
        "xp_gained": xp_gain,
        "new_experience": user.experience,
        "rank_changed": old_rank != new_rank if 'old_rank' in locals() else False,
        "new_rank": user.rank
    }


@router.get("/{habit_id}/streak", response_model=StreakOut)
async def get_streak(habit_id: int, db: AsyncSession = Depends(get_db), user: User = Depends(get_current_user)):
    h = await db.get(Habit, habit_id)
    if not h or h.user_id != user.id:
        raise HTTPException(404, "Habit not found")

    # Logika streaka (pozostaje bez zmian, była poprawna)
    res = await db.execute(select(HabitLog).where(HabitLog.habit_id == habit_id).order_by(HabitLog.date.desc()))
    logs = res.scalars().all()
    best = cur = 0
    prev = None

    # Musimy znać dzisiejszą datę użytkownika
    try:
        user_tz = pytz.timezone(user.timezone)
    except pytz.UnknownTimeZoneError:
        user_tz = pytz.timezone(settings.DEFAULT_TZ)
    user_today = datetime.now(user_tz).date()

    # Sprawdzamy, czy ostatni log był dzisiaj lub wczoraj
    if logs and (logs[0].date == user_today or logs[0].date == user_today - timedelta(days=1)):
        # Logika liczenia streaka
        for l in logs:
            if l.status != Status.done:
                if prev is None:  # Jeśli pierwszy log to fail/skip, cur=0
                    break
                # Jeśli był fail/skip, ale nie na początku, kończymy liczyć obecny streak
                prev = None
                cur = 0
                continue

            if prev is None or l.date == prev - timedelta(days=1):
                cur += 1
            else:
                # Przerwa w serii
                cur = 1

            best = max(best, cur)
            prev = l.date

        # Po pętli musimy jeszcze raz zaktualizować 'best'
        best = max(best, cur)

        # Jeśli ostatni log nie był 'done', obecny streak to 0
        if logs[0].status != Status.done:
            cur = 0

    # Przeliczamy 'best' jeszcze raz, iterując po wszystkich
    # Poprzednia logika była trochę błędna, uprośćmy:
    best_streak = 0
    current_streak = 0

    # Przeliczanie 'best'
    temp_best = 0
    prev_date = None
    for l in logs:  # Pamiętaj, że są posortowane MALEJĄCO
        if l.status == Status.done:
            if prev_date is None or l.date == prev_date + timedelta(days=1):
                temp_best += 1
            else:
                temp_best = 1
            best_streak = max(best_streak, temp_best)
            prev_date = l.date
        else:
            temp_best = 0
            prev_date = None

    # Przeliczanie 'current'
    prev_date = None
    if logs and logs[0].date == user_today and logs[0].status == Status.done:
        prev_date = user_today
        current_streak = 1
    elif logs and logs[0].date == user_today - timedelta(days=1) and logs[0].status == Status.done:
        prev_date = user_today - timedelta(days=1)
        current_streak = 1

    if current_streak > 0:
        for l in logs[1:]:
            if l.status == Status.done and l.date == prev_date - timedelta(days=1):
                current_streak += 1
                prev_date = l.date
            else:
                break  # Koniec obecnego streaka

    return StreakOut(current=current_streak, best=best_streak)
