from fastapi import FastAPI, Response, status

app = FastAPI()


@app.get("/")
async def root(response: Response):
    response.status_code = status.HTTP_200_OK
    return {"message": "Hello World"}
