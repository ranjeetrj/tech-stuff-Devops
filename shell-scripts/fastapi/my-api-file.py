import argparse
import uvicorn
from fastapi import FastAPI

app = FastAPI()

parser = argparse.ArgumentParser()
parser.add_argument("--name", type=str, required=True, help="Name of the user")

@app.get("/")
async def index(name: str):
    return {"message": f"Hello, {name}"}

if __name__ == "__main__":
    args = parser.parse_args()
    name = args.name
    uvicorn.run(app, port=8000)
