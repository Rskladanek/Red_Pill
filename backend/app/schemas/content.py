from pydantic import BaseModel

# Ten schemat definiuje, co API zwraca na zewnątrz (dla Pydantic)
class LessonOut(BaseModel):
    id: int
    title: str
    content: str
    source: str
    application: str

    # To jest kluczowe (dla Pydantic v2):
    # Pozwala Pydantic czytać dane z atrybutów obiektu (jak w modelu SQLAlchemy)
    # To jest nowa nazwa dla starego 'orm_mode = True'
    class Config:
        from_attributes = True

