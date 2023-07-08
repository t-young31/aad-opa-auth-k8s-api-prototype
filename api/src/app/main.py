import os
import json
import logging
import requests

from fastapi import FastAPI, Response, Request, status

OPA_URL = f"{os.environ['OPA_URL']}/v1/data/example"
app = FastAPI()

logging.basicConfig(
    level=logging.DEBUG if os.environ.get("DEBUG", "True") else logging.WARNING
)


@app.get("/")
async def root(request: Request, response: Response):
    response.status_code = status.HTTP_200_OK
    email = request.headers.get("x-email", default=None)

    if email is None:
        return {"message": "Hello unknown"}

    logging.debug(f"Getting authorization from {OPA_URL}")
    response = requests.post(OPA_URL, json={"input": {"email": email}})

    if response.status_code >= 300:
        logging.warning(f"Error checking auth, got status {response.status_code}")

    data = response.json()
    logging.info(f"Auth response: \n{json.dumps(data, indent=2)}")

    prefix = "" if data["result"].get("allow", False) else "un"
    return {"message": f"Hello {email} you are {prefix}authorized"}


@app.get("/health")
async def health(response: Response):
    response.status_code = status.HTTP_200_OK
    return "OK"
