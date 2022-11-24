FROM python:3.11.0-slim-buster

RUN addgroup --system app && adduser --system --group app

COPY ./ /app
WORKDIR /app

RUN pip install --no-cache-dir --upgrade -r /app/requirements.txt

USER app

CMD ["uvicorn", "main:app", "--proxy-headers", "--host", "0.0.0.0", "--port", "80"]
