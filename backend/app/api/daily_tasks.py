from fastapi import APIRouter
from pydantic import BaseModel

router = APIRouter(
    prefix="/v1/daily",
    tags=["daily"],
)

# ----------------------
# MODELE REQUEST / RESPONSE
# ----------------------

class DailyTaskOut(BaseModel):
    assignment_id: int
    track: str
    title: str
    description: str
    status: str

class DailyTodayResponse(BaseModel):
    tasks: list[DailyTaskOut]

class CheckIn(BaseModel):
    status: str  # "done", "skip", "fail"
    note: str | None = None

class CheckOut(BaseModel):
    ok: bool

# ----------------------
# ENDPOINTY
# ----------------------

@router.get("/today", response_model=DailyTodayResponse)
async def get_today_tasks():
    # TODO: w przyszłości losuj/przypisuj z ContentTask i DailyAssignment z DB
    # Teraz zwracamy mock, ale to już jest format docelowy.
    return DailyTodayResponse(
        tasks=[
            DailyTaskOut(
                assignment_id=44,
                track="mind",
                title="Kontakt wzrokowy",
                description="Nie uciekaj wzrokiem pierwszy. Patrz spokojnie i stabilnie.",
                status="pending",
            ),
            DailyTaskOut(
                assignment_id=45,
                track="body",
                title="Postawa barki w dół",
                description="3 razy dzisiaj popraw barki: dół + lekko tył. Zero garba.",
                status="pending",
            ),
            DailyTaskOut(
                assignment_id=46,
                track="soul",
                title="Twoje 'dlaczego'",
                description="Napisz jedno zdanie: dlaczego nie możesz być miękki. Bez ściemy.",
                status="pending",
            ),
        ]
    )

@router.post("/{assignment_id}/check", response_model=CheckOut)
async def check_task(assignment_id: int, body: CheckIn):
    # TODO: w przyszłości zapisz status w DB (DailyAssignment.status)
    # Teraz tylko udajemy sukces.
    print(f"[CHECK] assignment={assignment_id} -> {body.status} note={body.note}")
    return CheckOut(ok=True)
