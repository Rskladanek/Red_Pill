from typing import List
from pydantic import AnyHttpUrl
from pydantic_settings import BaseSettings, SettingsConfigDict


class Settings(BaseSettings):
    # Meta
    project_name: str = "RedPill API"
    api_prefix: str = "/v1"

    # Konfiguracja z .env – to masz już w pliku .env
    db_url: str = "sqlite+aiosqlite:///./redpill.db"
    jwt_secret: str = "CHANGE_ME_NOW"
    access_min: int = 30          # ile minut ważny access token
    refresh_days: int = 14        # ile dni ważny refresh token (jak go dorobisz)
    default_tz: str = "Europe/Warsaw"

    backend_cors_origins: List[AnyHttpUrl] = []

    # Pydantic-settings v2
    model_config = SettingsConfigDict(
        env_file=".env",
        env_file_encoding="utf-8",
        extra="ignore",  # jak wrzucisz kiedyś coś więcej do .env, nie wywali błędu
    )

    # Alias dla starego kodu, który używał UPPER_CASE
    @property
    def PROJECT_NAME(self) -> str:
        return self.project_name

    @property
    def API_PREFIX(self) -> str:
        return self.api_prefix

    @property
    def SECRET_KEY(self) -> str:
        # stary kod w security.py używa SECRET_KEY → mapujemy na jwt_secret
        return self.jwt_secret

    @property
    def ACCESS_TOKEN_EXPIRE_MINUTES(self) -> int:
        # stary kod używa ACCESS_TOKEN_EXPIRE_MINUTES → mapujemy na access_min
        return self.access_min

    @property
    def BACKEND_CORS_ORIGINS(self) -> List[AnyHttpUrl]:
        return self.backend_cors_origins


settings = Settings()
