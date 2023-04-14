FROM python:3.6-alpine

WORKDIR /app
COPY . /app

RUN pip install -r /app/requirements.txt

ENV MONGO crawler_db
ENV MONGO_PORT 27017

WORKDIR /app/ui

ENTRYPOINT FLASK_APP=ui.py gunicorn ui:app -b 0.0.0.0
