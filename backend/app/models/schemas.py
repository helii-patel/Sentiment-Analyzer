from pydantic import BaseModel
from typing import List

class TextsRequest(BaseModel):
    texts: List[str]

class SentimentResponse(BaseModel):
    positive_count: int
    negative_count: int
    neutral_count: int
    results: List[dict]
