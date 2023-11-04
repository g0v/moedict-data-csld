from pydantic import BaseModel, PostgresDsn, ValidationError
import yaml

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
    # Set defaults for other secret related configurations if needed

class Configuration(BaseModel):
    http_server: HttpServerConfig = HttpServerConfig()
    grpc_server: GrpcServerConfig = GrpcServerConfig()
    user_grpc: GrpcServerConfig = GrpcServerConfig()
    survey_grpc: GrpcServerConfig = GrpcServerConfig()
    database: DatabaseConfig = DatabaseConfig()
    mongo: MongoConfig = MongoConfig()
    secret: SecretConfig = SecretConfig()

# Example usage: the defaults are used unless you provide an override
settings = Configuration()

def load_config_from_yaml(yaml_path: str = "config.yaml") -> Configuration:
    with open(yaml_path, 'r') as file:
        yaml_content = yaml.safe_load(file)
        print(yaml_content)
        try:
            config = Configuration(**yaml_content)
            return config
        except ValidationError as e:
            print(f"Error loading configuration: {e}")
            raise

# Example usage: Load settings from a YAML file
settings = load_config_from_yaml('config.yaml')

# Accessing a configuration value
print(settings)