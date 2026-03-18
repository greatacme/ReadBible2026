from fastapi import APIRouter, HTTPException
from pydantic import BaseModel
import database

router = APIRouter()


class RecordUpdate(BaseModel):
    completed: bool


@router.get("/records/{nickname}")
def get_records(nickname: str):
    with database.get_conn() as conn:
        user = conn.execute(
            "SELECT id FROM users WHERE nickname = ?", (nickname,)
        ).fetchone()
        if not user:
            raise HTTPException(404, "사용자를 찾을 수 없습니다")

        rows = conn.execute(
            """
            SELECT p.id AS plan_id, p.date, p.description,
                   COALESCE(r.completed, 0) AS completed
            FROM plans p
            LEFT JOIN records r ON r.plan_id = p.id AND r.user_id = ?
            ORDER BY p.sort_order
            """,
            (user["id"],),
        ).fetchall()

        return [dict(r) for r in rows]


@router.patch("/records/{nickname}/{plan_id}")
def update_record(nickname: str, plan_id: int, body: RecordUpdate):
    with database.get_conn() as conn:
        user = conn.execute(
            "SELECT id FROM users WHERE nickname = ?", (nickname,)
        ).fetchone()
        if not user:
            raise HTTPException(404, "사용자를 찾을 수 없습니다")

        conn.execute(
            """
            INSERT INTO records (user_id, plan_id, completed, updated_at)
            VALUES (?, ?, ?, CURRENT_TIMESTAMP)
            ON CONFLICT(user_id, plan_id) DO UPDATE SET
                completed  = excluded.completed,
                updated_at = CURRENT_TIMESTAMP
            """,
            (user["id"], plan_id, 1 if body.completed else 0),
        )
        return {"ok": True}
