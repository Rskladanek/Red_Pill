from .session import engine
from .base import Base
from app.models import user, content, progress  # noqa

def create_all():
    Base.metadata.create_all(bind=engine)
