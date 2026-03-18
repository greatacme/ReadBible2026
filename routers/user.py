from fastapi import APIRouter, HTTPException
from pydantic import BaseModel
import database

router = APIRouter()


class UserIn(BaseModel):
    nickname: str


@router.post("/users")
def register_or_get(body: UserIn):
    nickname = body.nickname.strip()
    if not nickname:
        raise HTTPException(400, "별명을 입력하세요")

    with database.get_conn() as conn:
        row = conn.execute(
            "SELECT id, nickname FROM users WHERE nickname = ?", (nickname,)
        ).fetchone()
        if row:
            return {"id": row["id"], "nickname": row["nickname"], "is_new": False}

        cur = conn.execute("INSERT INTO users (nickname) VALUES (?)", (nickname,))
        return {"id": cur.lastrowid, "nickname": nickname, "is_new": True}
