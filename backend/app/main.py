from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from fastapi.responses import RedirectResponse

# USUWAMY content z tego importu:
from .api import auth, habits, health, users
from .deps import engine
from .models.base import Base

# To zostaje, bo chcemy żeby tabele powstały przy starcie
from .models import user, habit
from .models import content as content_model  # ContentTask, Track
from .models import daily as daily_model      # DailyAssignment

app = FastAPI(title="Red Pill API", version="0.2.0")

# CORS – to zostaje jak było
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

@app.on_event("startup")
async def on_startup():
    async with engine.begin() as conn:
        await conn.run_sync(Base.metadata.create_all)

# podpinamy tylko te routery, które są poprawne
app.include_router(health.router)
app.include_router(auth.router)
app.include_router(habits.router)
app.include_router(users.router)

# NIE podpinamy content.router bo jest stary i rozwala start

@app.get("/", include_in_schema=False)
def root_redirect():
    return RedirectResponse(url="/docs")
