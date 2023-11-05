from typing import List, Dict
from pydantic import BaseModel, Field, validator



# Define the request schema
class TextInput(BaseModel):
    text: str = Field(..., example="Example text containing specific terms")

# Define the response schema
class TermPosition(BaseModel):
    pos: int = Field(..., description="The starting index position of the found term in the text")
    word: str = Field(..., description="The term that was found")

class TermsFoundResponse(BaseModel):
    terms: Dict[str, List[int]]

    @validator('terms', pre=True, each_item=True)
    def check_values(cls, v):
        if isinstance(v, list) and all(isinstance(x, int) for x in v):
            return v
        raise ValueError('terms must be a list of integers')
