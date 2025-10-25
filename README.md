# RED PILL — Backend MVP (FastAPI)

Minimalny backend pod aplikację „Red Pill” — rejestracja/logowanie, rytuały (habits), check-in bez backdatingu, streak.

## Szybki start (bez Dockera)
```bash
cd backend
python -m venv .venv && source .venv/bin/activate
pip install -r requirements.txt
cp .env.example .env
# Domyślnie SQLite w pliku ./redpill.db — można zmienić DB_URL na Postgresa
uvicorn app.main:app --reload
```
Otwórz: http://127.0.0.1:8000/docs

## Szybki start (Docker + Postgres)
```bash
docker compose up --build
```
API: http://127.0.0.1:8000/docs

## Zmienne środowiskowe (.env)
- `DB_URL` — np. `sqlite+aiosqlite:///./redpill.db` (domyślnie) lub `postgresql+asyncpg://redpill:redpill@db/redpill`
- `JWT_SECRET` — ustaw silny sekret
- `ACCESS_MIN` — ważność tokenu access (minuty)

## Endpoints (MVP)
- `POST /v1/auth/register` — email, password
- `POST /v1/auth/login` — email, password → access token
- `POST /v1/habits` — utworzenie rytuału
- `GET /v1/habits` — lista Twoich rytuałów
- `POST /v1/habits/{id}/checkin` — {status: done|skip|fail, note}
- `GET /v1/habits/{id}/streak` — bieżący/best streak
- `GET /v1/health/ping` — ping

## Notatki
- Brak backdatingu: check-in możliwy wyłącznie dla dzisiejszej daty (wg strefy użytkownika, domyślnie Europe/Warsaw).
- Streak: liczy tylko dni ze statusem `done` bez przerw.
- Baza: modele proste (User, Habit, HabitLog); łatwo dodać Virtue/Value/HardMode.
# Red_Pill
