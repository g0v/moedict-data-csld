from functools import lru_cache
import json


@lru_cache()
def load_terms():
    # You would load the files here and return the terms
    with open('../=同實異名.json', 'r', encoding='utf-8') as file:
        unique_synonyms = json.load(file)

    # Remove the first part of the string, which is the term itself
    for i in range(len(unique_synonyms)):
        unique_synonyms[i] = unique_synonyms[i].split(';')[2]

    with open('../=大陸特有.json', 'r', encoding='utf-8') as file:
        unique_mainland_terms = json.load(file)

    # Combine and deduplicate terms
    all_terms = set(unique_synonyms + unique_mainland_terms)
    return list(all_terms)

# Dependency function to be used with FastAPI
async def get_terms():
    return load_terms()