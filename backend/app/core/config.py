from pydantic_settings import BaseSettings
from typing import Literal

class Settings(BaseSettings):
    DB_URL: str = "sqlite+aiosqlite:///./redpill.db"
    JWT_SECRET: str = "change_me"
    ACCESS_MIN: int = 30
    REFRESH_DAYS: int = 14
    DEFAULT_TZ: str = "Europe/Warsaw"

    class Config:
        env_file = ".env"

settings = Settings()
