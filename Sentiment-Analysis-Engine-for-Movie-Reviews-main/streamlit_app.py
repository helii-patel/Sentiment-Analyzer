import streamlit as st
import torch
from transformers import AutoTokenizer, AutoModelForSequenceClassification


model_path = r'C:\vscode\CVprojects\NLP\sentimentModel\distilbert_imdb_model'
tokenizer = AutoTokenizer.from_pretrained(model_path)
model = AutoModelForSequenceClassification.from_pretrained(model_path)
model.eval()

st.title("IMDB Sentiment Analyzer")

text = st.text_area("Enter movie review")

if st.button("Analyze"):
    inputs = tokenizer(text, return_tensors="pt", truncation=True, padding=True)
    outputs = model(**inputs)
    probs = torch.softmax(outputs.logits, dim=1)
    pred = torch.argmax(probs).item()

    st.write("Prediction:", "POSITIVE 😊" if pred == 1 else "NEGATIVE 😠")
    st.write("Confidence:", float(probs[0][pred]))

   