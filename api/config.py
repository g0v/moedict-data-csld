import sys
from typing import Any, Dict, Optional

from dotenv import find_dotenv
from pydantic import BaseSettings, PostgresDsn, validator


class Settings(BaseSettings):
    class Config:
        env_file = find_dotenv(usecwd=True)
        env_file_encoding = "utf-8"

    """Application configuration"""
    APP_TITLE: str = "fastapi template"
    APP_DESCRIPTION: str = "A simple template for fastapi and complete workflow"
    APP_VERSION: str = "0.1.0"
    APP_OPENAPI_URL: str = "/openapi.json"
    APP_PREFIX: str = "/api"

    """Database configuration"""
    POSTGRES_DB: str = "fastapi-template"
    POSTGRES_HOST: str = "postgres"
    POSTGRES_PORT: str = "5432"
    POSTGRES_USER: str = "postgres"
    POSTGRES_PASSWORD: str = "m3ow87"
    POSTGRES_TEST_PORT: str = "5433"
    POSTGRES_DSN: Optional[PostgresDsn] = None

    @validator("POSTGRES_DSN", pre=True)
    def assemble_db_connection(
        cls, v: Optional[str], values: Dict[str, Any]
    ) -> Optional[PostgresDsn]:
        # if exists value and not empty
        if isinstance(v, str) and v != "":
            return v

        # choose which port should be used
        port = values.get("POSTGRES_PORT")
        if any("pytest" in arg for arg in sys.argv):
            port = values.get("POSTGRES_TEST_PORT")

        # choose which schema should be used, alembic use sync driver
        schema = "postgresql+asyncpg"
        if any("alembic" in arg for arg in sys.argv):
            schema = "postgresql"

        # build postgres dsn
        return PostgresDsn.build(
            scheme=schema,
            user=values.get("POSTGRES_USER"),
            password=values.get("POSTGRES_PASSWORD"),
            host=values.get("POSTGRES_HOST"),
            port=port,
            path=f"/{values.get('POSTGRES_DB')}",
        )

    """ Core configuration """
    SALT: str = "fu3k3n"
    ACCESS_TOKEN_SECRET_KEY: str = "m3ow87"
    REFRESH_TOKEN_SECRET_KEY: str = "m3ow87m3ow87??"
    ACCESS_TOKEN_EXPIRE_MINUTES: int = 60 * 24 * 8
    REFRESH_TOKEN_EXPIRE_MINUTES: int = 60 * 24 * 30
    ACCESS_TOKEN_ALGORITHM: str = "HS256"


settings = Settings()