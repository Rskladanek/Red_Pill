# app/core/config.py
import os

DB_URL = os.getenv("DATABASE_URL", "sqlite:///./redpill.db")
SECRET_KEY = os.getenv("SECRET_KEY", "DEV_SECRET_CHANGE_ME")
ACCESS_TOKEN_EXPIRE_MINUTES = 60 * 24 * 30  # 30 dni
ALLOWED_ORIGINS = os.getenv("ALLOWED_ORIGINS", "*").split(",")
