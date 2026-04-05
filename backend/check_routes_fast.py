import sys
from unittest.mock import MagicMock

# Mock the heavy dependencies before importing the app
sys.modules['app.services.sentiment_service'] = MagicMock()
sys.modules['transformers'] = MagicMock()

from app.main import app

print("--- Registered Routes ---")
for route in app.routes:
    methods = getattr(route, "methods", None)
    path = getattr(route, "path", None)
    name = getattr(route, "name", None)
    print(f"Path: {path}, Name: {name}, Methods: {methods}")
print("-------------------------")
