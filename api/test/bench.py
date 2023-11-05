import re

def find_all_occurrences_regex(terms_list, text):
    term_occurrences = {}
    for term in terms_list:
        # Compile a regular expression pattern for the term
        pattern = re.compile(re.escape(term))
        # Find all matches of the pattern in the text
        matches = [match.start() for match in pattern.finditer(text)]
        if matches:
            term_occurrences[term] = matches
        else:
            term_occurrences[term] = "Not found in the text"
    return term_occurrences

def find_all_term_occurrences(terms_list, text):
    term_occurrences = {}
    for term in terms_list:
        # Finding all start indices of the term in the text
        start_indices = [i for i in range(len(text)) if text.startswith(term, i)]
        if start_indices:
            term_occurrences[term] = start_indices
        else:
            term_occurrences[term] = "Not found in the text"
    return term_occurrences