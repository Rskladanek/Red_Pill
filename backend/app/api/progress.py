from fastapi import APIRouter

router = APIRouter(
    prefix="/v1/progress",
    tags=["progress"],
)

@router.get("/summary")
async def get_progress_summary():
    # UWAGA: to jest mock. Docelowo będzie personalizowane pod usera, po tokenie.
    return {
        "user": {
            "email": "placeholder@user.com",
            "rank": "Adept",
            "xp": 27,
            "next_rank": "Warrior",
            "next_rank_xp": 50,
            "streak_days": 5
        },
        "tracks": {
            "mind": {"percent": 0.40, "done_total": 18},
            "body": {"percent": 0.20, "done_total": 7},
            "soul": {"percent": 0.55, "done_total": 12}
        },
        "tasks": {
            "done_today": 2,
            "assigned_today": 3,
            "total_done_all_time": 37
        },
        "quote": {
            "text": "Kto walczy z potworami, niech uważa, by samemu nie stać się potworem.",
            "author": "Nietzsche"
        }
    }
