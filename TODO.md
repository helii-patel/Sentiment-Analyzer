# Sentiment Analyzer App Enhancement TODO

## Backend Tasks
- [x] Copy custom DistilBERT model files from `Sentiment-Analysis-Engine-for-Movie-Reviews-main/sentimentModel/distilbert_imdb_model/` to `sentiment-analyzer/backend/models/`
- [x] Update `sentiment-analyzer/backend/app/services/sentiment_service.py` to load custom model and implement batch analysis with neutral classification
- [x] Update `sentiment-analyzer/backend/app/models/schemas.py` to change TextRequest to TextsRequest and update SentimentResponse for counts and results list
- [x] Update `sentiment-analyzer/backend/app/api/routes.py` to handle batch texts endpoint
- [x] Add CORS middleware to `sentiment-analyzer/backend/app/main.py`
- [x] Verify and update `sentiment-analyzer/backend/requirements.txt` for necessary dependencies

## Frontend Tasks
- [x] Update `sentiment-analyzer/frontend/pubspec.yaml` to add dependencies: shared_preferences, provider, fl_chart
- [x] Update `sentiment-analyzer/frontend/lib/main.dart` for Material Design 3 theme and bottom navigation
- [x] Update `sentiment-analyzer/frontend/lib/screens/home_screen.dart` for multiline input, clear button, and batch handling
- [x] Update `sentiment-analyzer/frontend/lib/screens/result_screen.dart` for counts display, pie chart, and expandable results list
- [x] Update `sentiment-analyzer/frontend/lib/services/api_service.dart` to send list of texts and handle new response
- [x] Update `sentiment-analyzer/frontend/lib/models/sentiment_result.dart` to include counts and results list
- [x] Create `sentiment-analyzer/frontend/lib/screens/history_screen.dart` for displaying past analyses
- [x] Create `sentiment-analyzer/frontend/lib/providers/history_provider.dart` for state management of history

## Testing and Followup
- [x] Install backend dependencies and run server
- [x] Run Flutter pub get and test app on emulator/device
- [x] Test batch analysis, results display, and history feature
