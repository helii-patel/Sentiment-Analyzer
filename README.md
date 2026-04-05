# Sentiment Analyzer Application

## 📌 Project Overview
This project is a Sentiment Analyzer system built using a **Flutter (Dart) frontend**
and a **Python FastAPI backend**. The application analyzes user-entered text and
classifies it into sentiment categories such as Positive or Negative using
a pretrained Natural Language Processing (NLP) model.

---

## 🧱 System Architecture
The system follows a **client–server architecture**:

- **Frontend (Flutter):**
  - Handles UI and user interaction
  - Sends text data to backend using REST API
  - Displays sentiment results

- **Backend (Python FastAPI):**
  - Exposes REST endpoints
  - Performs sentiment analysis using a machine learning model
  - Returns structured JSON responses

The frontend and backend are fully decoupled, allowing independent development
and sc
