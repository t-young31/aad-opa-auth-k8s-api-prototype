FROM python:3.10

WORKDIR /app

COPY src/requirements.txt requirements.txt
RUN pip install --no-cache-dir --upgrade -r requirements.txt

COPY entrypoint.sh .

COPY src/app .
ENTRYPOINT ["./entrypoint.sh"]
