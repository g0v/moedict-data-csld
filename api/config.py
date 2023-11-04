import json
from pydantic import BaseModel, PostgresDsn, ValidationError
import yaml

class AppConfig(BaseModel):
    title: str = "fastapi template"
    description: str = "A simple template for fastapi and complete workflow"
    version: str = "0.1.0"
    openapi_url: str = "/openapi.json"
    prefix: str = "/api"

class HttpServerConfig(BaseModel):
    hostname: str = "localhost"
    port: str = "8000"

class GrpcServerConfig(BaseModel):
    hostname: str = "localhost"
    port: str = "50051"

class DatabaseConfig(BaseModel):
    host: str = "localhost"
    port: str = "5432"
    user: str = "user"
    password: str = "password"
    dbname: str = "dbname"
    dsn: PostgresDsn = None  # This will be computed, so no default is set here

class MongoConfig(BaseModel):
    mongo_uri: str = "mongodb://localhost:27017"
    db: str = "mydb"
    response_collection: str = "responses"

class SecretConfig(BaseModel):
    access_secret: str = "mysecretkey"
    access_token_expire_minutes: int = 60 * 24 * 8  # 8 days
    access_token_algorithm: str = "HS256"

class Configuration(BaseModel):
    app: AppConfig = AppConfig()
    http_server: HttpServerConfig = HttpServerConfig()
    grpc_server: GrpcServerConfig = GrpcServerConfig()
    user_grpc: GrpcServerConfig = GrpcServerConfig()
    db: DatabaseConfig = DatabaseConfig()
    mongo: MongoConfig = MongoConfig()
    core: SecretConfig = SecretConfig()

def load_config_from_yaml(yaml_path: str = "config.yaml") -> Configuration:
    with open(yaml_path, 'r') as file:
        yaml_content = yaml.safe_load(file)
        try:
            config = Configuration(**yaml_content)
            # print(json.dumps(config.model_dump(),
            #     sort_keys=True,
            #     indent=4
            # ))
            return config
        except ValidationError as e:
            print(f"Error loading configuration: {e}")
            raise

# # Example usage: Load settings from a YAML file
settings = load_config_from_yaml('../config.yaml')
