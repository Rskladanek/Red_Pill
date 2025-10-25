from pydantic import BaseModel, Field
from datetime import date, datetime # Musimy zaimportować datetime
from ..models.habit import Status, HabitCategory # Dodajemy HabitCategory

class HabitBase(BaseModel):
    title: str = Field(..., max_length=120)
    cadence: str = "daily"
    difficulty: int = Field(3, ge=1, le=5)
    category: HabitCategory = HabitCategory.OTHER # Zostawiamy OTHER, tak jak masz

class HabitIn(HabitBase):
    pass

class HabitOut(HabitBase):
    id: int
    active: bool
    user_id: int
    created_at: datetime # Model bazowy ma 'datetime', a nie 'date'

    class Config:
        from_attributes = True # POPRAWKA: Zmieniamy 'orm_mode' na 'from_attributes'

class CheckIn(BaseModel):
    """
    Kluczowa zmiana: Klient MUSI wysłać datę, której dotyczy check-in.
    Serwer nie może zgadywać strefy czasowej.
    """
    date: date
    status: Status
    note: str = Field("", max_length=380)

class StreakOut(BaseModel):
    current: int
    best: int

