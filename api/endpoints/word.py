@app.post("/check-text/")
async def check_text(text_input: TextInput):
    # Extract keywords using flashtext
    found_terms = keyword_processor.extract_keywords(text_input.text)
    return {"found_terms": found_terms}