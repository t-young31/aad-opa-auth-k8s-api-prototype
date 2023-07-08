from fastapi import FastAPI, Response, Request, status

app = FastAPI()


@app.get("/")
async def root(request: Request, response: Response):
    response.status_code = status.HTTP_200_OK
    email = request.headers["x-email"]
    return {"message": f"Hello {email}"}
