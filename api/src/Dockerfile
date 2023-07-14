FROM python:3.10

WORKDIR /src
COPY . .

RUN pip install --no-cache-dir --upgrade -r requirements.txt
ENTRYPOINT ["./entrypoint.sh"]
