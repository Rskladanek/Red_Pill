from fastapi import APIRouter, Depends
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy import select
from sqlalchemy.sql.expression import func
from ..deps import get_db, get_current_user
from ..models.user import User
from ..models.content import Lesson
from ..schemas.content import LessonOut  # Upewnij się, że app/schemas/content.py istnieje

# Ta linia definiuje 'router', którego brakowało w błędzie
router = APIRouter(prefix="/v1/content", tags=["content"])


@router.get("/lesson", response_model=LessonOut)
async def get_daily_lesson(db: AsyncSession = Depends(get_db), user: User = Depends(get_current_user)):
    """
    Zwraca losową lekcję (zasadę) dla użytkownika.
    W przyszłości można to oprzeć o logikę (np. codziennie nowa, śledzenie postępów).
    Na razie: losowa.
    """
    res = await db.execute(select(Lesson).order_by(func.random()).limit(1))
    lesson = res.scalar_one_or_none()

    if not lesson:
        # Fallback, gdyby baza danych była pusta
        return Lesson(
            id=0,
            title="Zasada Zero",
            content="Dyscyplina to wolność. Zacznij działać.",
            source="Internal",
            application="Wykonaj dzisiaj swój najważniejszy nawyk bez wymówek."
        )

    # Pydantic (z 'from_attributes=True' w LessonOut) automatycznie
    # zmapuje ten obiekt modelu SQLAlchemy 'Lesson' na schemat 'LessonOut'
    return lesson

