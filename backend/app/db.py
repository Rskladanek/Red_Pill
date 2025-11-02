import os
from sqlalchemy import create_engine
from sqlalchemy.orm import sessionmaker, declarative_base

# SQLite lokalnie; możesz nadpisać zmienną środowiskową na Postgresa itp.
DATABASE_URL = os.getenv("DATABASE_URL", "sqlite:///./redpill.db")

# dla SQLite trzeba wyłączyć check_same_thread
connect_args = {"check_same_thread": False} if DATABASE_URL.startswith("sqlite") else {}

engine = create_engine(
    DATABASE_URL,
    echo=False,        # ustaw True, jeśli chcesz logi SQL
    future=True,
    connect_args=connect_args
)

SessionLocal = sessionmaker(bind=engine, autoflush=False, autocommit=False, future=True)
Base = declarative_base()
