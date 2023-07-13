import os
import json
import logging
import requests

from fastapi import FastAPI, Response, Request, status

OPA_RBAC_URL = f"{os.environ['OPA_URL']}/v1/data/rbac"
app = FastAPI()

logging.basicConfig(
    level=logging.DEBUG if os.environ.get("DEBUG", "true") else logging.WARNING
)


@app.get("/")
async def root(request: Request, response: Response):
    response.status_code = status.HTTP_200_OK
    email = request.headers["x-email"]

    return {"message": f"Hello {email} you are authorized"}


@app.get("/authorize")
async def authorize(request: Request, response: Response):
    response.status_code = status.HTTP_401_UNAUTHORIZED

    auth_request = {
        "email": request.headers.get("x-email", default=None),
        "path": request.headers.get("x-request_uri", default=None),
        "method": request.headers.get("x-request_method", default=None),
    }
    logging.debug(
        f"Getting authorization from {OPA_RBAC_URL} for \n"
        f"{json.dumps(auth_request, indent=2)}"
    )
    opa_response = requests.post(url=OPA_RBAC_URL, json={"input": auth_request})

    if opa_response.status_code >= 300:
        logging.warning(f"Error checking auth. Status: {response.status_code}")
        return

    data = opa_response.json()
    logging.info(f"Auth response: \n{json.dumps(data, indent=2)}")

    if data["result"].get("allow", False):
        response.status_code = status.HTTP_202_ACCEPTED

    logging.debug(f"Status code {response.status_code}")


@app.get("/health")
async def health(response: Response):
    response.status_code = status.HTTP_200_OK
    return "OK"
