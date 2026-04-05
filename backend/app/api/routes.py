from fastapi import APIRouter
from app.models.schemas import TextsRequest, SentimentResponse
from app.services.sentiment_service import analyze_texts

router = APIRouter()

@router.post("/predict", response_model=SentimentResponse)
def predict_sentiment(data: TextsRequest):
    # Force reload test
    return analyze_texts(data.texts)
