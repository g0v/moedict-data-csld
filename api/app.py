from contextlib import asynccontextmanager
from config import settings
from endpoints import auth, health, user
from fastapi import APIRouter, Depends, FastAPI
from fastapi.middleware.cors import CORSMiddleware
from fastapi.requests import Request
from fastapi.responses import Response
from loguru import logger

APP = FastAPI(
    version=settings.APP_VERSION,
    title=settings.APP_TITLE,
    description=settings.APP_DESCRIPTION,
    openapi_url=settings.APP_OPENAPI_URL,
)

ROUTER = APIRouter()
ROUTER.include_router(health.router, prefix="/health", tags=["health"])
ROUTER.include_router(user.router, prefix="/user", tags=["user"])
ROUTER.include_router(auth.router, prefix="/auth", tags=["auth"])


# Lifespan events
@asynccontextmanager
async def lifespan(app: FastAPI):
    logger.info("Processing startup initialization")
    yield
    logger.info("Processing shutdown initialization")

# Logs incoming request information
async def log_request(request: Request):
    logger.info(
        f"[{request.client.host}:{request.client.host}] {request.method} {request.url}"
    )
    logger.info(f"header: {request.headers}")


# Enable CORS middleware
APP.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# Log response status code and body
@APP.middleware("http")
async def log_response(request: Request, call_next):
    response = await call_next(request)
    body = b""
    async for chunk in response.body_iterator:
        body += chunk

    logger.info(f"{response.status_code} {body}")

    return Response(
        content=body,
        status_code=response.status_code,
        headers=response.headers,
        media_type=response.media_type,
    )


APP.include_router(
    ROUTER, prefix=settings.APP_PREFIX, dependencies=[Depends(log_request)]
)