from contextlib import asynccontextmanager
from fastapi import FastAPI
from fastapi.staticfiles import StaticFiles
from fastapi.responses import FileResponse

import database
import seed_plan
from routers import user, stats, record


@asynccontextmanager
async def lifespan(app: FastAPI):
    database.init_db()
    seed_plan.seed()
    yield


app = FastAPI(title="ReadBible2026", lifespan=lifespan)

app.include_router(user.router, prefix="/api")
app.include_router(stats.router, prefix="/api")
app.include_router(record.router, prefix="/api")

app.mount("/static", StaticFiles(directory="static"), name="static")


@app.get("/")
def index():
    return FileResponse("static/index.html")


@app.get("/record")
def record_page():
    return FileResponse("static/record.html")
