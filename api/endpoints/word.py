from concurrent.futures import ThreadPoolExecutor
from fastapi import FastAPI
from pydantic import BaseModel
import re
from deps import get_terms
import schemas
from fastapi import APIRouter, Depends, HTTPException, status

router = APIRouter()

def find_all_occurrences_regex(terms_list, text):
    term_occurrences = {}
    for term in terms_list:
        # Compile a regular expression pattern for the term
        pattern = re.compile(re.escape(term))
        # Find all matches of the pattern in the text
        matches = [match.start() for match in pattern.finditer(text)]
        if matches:
            term_occurrences[term] = matches
        # else:
        #     term_occurrences[term] = "Not found in the text"
    return term_occurrences

## faster search
@router.post(
    "/check-text/",
    status_code=status.HTTP_200_OK,
    response_model=schemas.TermsFoundResponse,
    name="word:check_text",
)
def check_text(text_input: schemas.TextInput, terms: list = Depends(get_terms)):
    all_terms_occurrences_regex = find_all_occurrences_regex(terms, text_input.text)
    found_terms_with_all_occurrences_regex = {term: positions for term, positions in all_terms_occurrences_regex.items() if positions != "Not found in the text"}
    return schemas.TermsFoundResponse(terms=found_terms_with_all_occurrences_regex)