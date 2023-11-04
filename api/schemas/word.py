from typing import List
from pydantic import BaseModel, Field


# Define the request schema
class TextInput(BaseModel):
    text: str = Field(..., example="Example text containing specific terms")

# Define the response schema
class TermPosition(BaseModel):
    pos: int = Field(..., description="The starting index position of the found term in the text")
    word: str = Field(..., description="The term that was found")

class TermsFoundResponse(BaseModel):
    result: List[TermPosition]
