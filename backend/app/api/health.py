from fastapi import APIRouter

router = APIRouter(prefix="/v1/health", tags=["health"])

@router.get("/ping")
def ping():
    return {"pong": True}
