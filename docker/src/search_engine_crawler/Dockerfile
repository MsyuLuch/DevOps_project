FROM python:3.6-alpine

WORKDIR /app
COPY . /app

RUN pip install -r /app/requirements.txt

ENV MONGO crawler_db
ENV MONGO_PORT 27017
ENV RMQ_HOST rabbitmq
ENV RMQ_QUEUE queue
ENV RMQ_USERNAME guest
ENV RMQ_PASSWORD guest
ENV CHECK_INTERVAL 5
ENV EXCLUDE_URLS '.*github.com'

CMD python -u ./crawler/crawler.py https://vitkhab.github.io/search_engine_test_site/
