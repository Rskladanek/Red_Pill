from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware

from app.core.config import settings
from app.db.init_db import create_all
from app.db.session import SessionLocal
from app.api.auth import router as auth_router
from app.api.content import router as content_router
from app.api.progress import router as progress_router
from app.seeds.loader import run_seed_if_empty


def create_app() -> FastAPI:
    app = FastAPI(
        title=settings.PROJECT_NAME,
    )

    # CORS – DEV: otwarte, żeby front na localhost mógł gadać z backendem.
    # Jak będziesz stawiał produkcję, to tu zawężamy originy.
    app.add_middleware(
        CORSMiddleware,
        allow_origins=["*"],      # na dev po prostu full open
        allow_credentials=True,
        allow_methods=["*"],
        allow_headers=["*"],
    )

    # Routery z prefixem /v1
    app.include_router(auth_router, prefix=settings.API_PREFIX)
    app.include_router(content_router, prefix=settings.API_PREFIX)
    app.include_router(progress_router, prefix=settings.API_PREFIX)

    @app.on_event("startup")
    def startup_event() -> None:
        """Tworzy tabele i odpala seedy przy starcie serwera."""
        create_all()
        db = SessionLocal()
        try:
            run_seed_if_empty(db)
        finally:
            db.close()

    @app.get("/", tags=["health"])
    def health_check():
        return {"status": "ok"}

    return app


app = create_app()
