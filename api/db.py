from config import settings
from sqlalchemy.engine import Engine
from sqlalchemy.ext.asyncio import AsyncSession, create_async_engine
from sqlalchemy.orm import sessionmaker
from sqlalchemy.orm.session import Session

ASYNC_ENGINE: Engine = create_async_engine(
    settings.POSTGRES_DSN,
    pool_size=15,
    max_overflow=5,
    pool_pre_ping=True,
    pool_recycle=3600,
)

print("ASYNC_ENGINE", settings.POSTGRES_DSN)

ASYNC_SESSION: Session = sessionmaker(
    class_=AsyncSession, autocommit=False, autoflush=False, bind=ASYNC_ENGINE
)