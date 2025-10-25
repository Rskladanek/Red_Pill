from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from fastapi.responses import RedirectResponse

from .api import auth, habits, health, users
from .api import progress, daily_tasks, lessons  # <-- MUSI być lessons tutaj

from .deps import engine
from .models.base import Base



# import modeli, żeby create_all stworzyło tabele
from .models import user, habit
from .models import content as content_model
from .models import daily as daily_model

app = FastAPI(title="Red Pill API", version="0.3.0")

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],   # dev pozwala frontowi na 127.0.0.1:random
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

@app.on_event("startup")
async def on_startup():
    async with engine.begin() as conn:
        await conn.run_sync(Base.metadata.create_all)

# kolejność routerów nie musi być identyczna, ważne że wszystkie są dodane:
app.include_router(health.router)
app.include_router(auth.router)
app.include_router(habits.router)
app.include_router(users.router)

app.include_router(progress.router)     # /v1/progress/summary
app.include_router(daily_tasks.router)  # /v1/daily/...
app.include_router(lessons.router)      # /v1/mind/lesson itd.

@app.get("/", include_in_schema=False)
def root_redirect():
    return RedirectResponse(url="/docs")
