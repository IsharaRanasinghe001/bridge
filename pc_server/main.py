from fastapi import FastAPI
import os

app = FastAPI()

@app.get("/files")
def list_files():
    path = "~/Documents"
    return {"files": os.listdir}