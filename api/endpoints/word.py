from fastapi import FastAPI
from pydantic import BaseModel
import re
from deps import get_terms
import schemas
from fastapi import APIRouter, Depends, HTTPException, status

router = APIRouter()

# # Assuming the unique_synonyms and unique_mainland_terms are already defined as Python lists
# unique_synonyms = [...] #TODO: Fill this with the content from =同實異名.json
# unique_mainland_terms = [...] #TODO: Fill this with the content from =大陸特有.json

# # Combine both lists for checking
# all_terms = set(unique_synonyms + unique_mainland_terms)  # Use a set for faster lookup

@router.post(
    "/check-text/",
    status_code=status.HTTP_200_OK,
    response_model=schemas.TermsFoundResponse,
    name="word:check_text",
)
async def check_text(text_input: schemas.TextInput, terms: set = Depends(get_terms)):
    print(terms)
    # Find keywords along with their positions
    found_terms_with_pos = []
    # for term in terms:
    #     for match in re.finditer(r'\b{}\b'.format(re.escape(term)), text_input.text):
    #         start_pos = match.start()
    #         found_terms_with_pos.append({"pos": start_pos, "word": term})
    # # Sort the results by position
    # found_terms_with_pos.sort(key=lambda x: x["pos"])
    return found_terms_with_pos