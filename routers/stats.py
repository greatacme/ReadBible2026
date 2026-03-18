from fastapi import APIRouter
from datetime import date
import database

router = APIRouter()


def _calc_stats() -> list:
    today = date.today().strftime("%Y-%m-%d")
    with database.get_conn() as conn:
        planned = conn.execute(
            "SELECT COUNT(*) FROM plans WHERE date <= ?", (today,)
        ).fetchone()[0]

        users = conn.execute(
            "SELECT id, nickname FROM users ORDER BY nickname"
        ).fetchall()

        results = []
        for u in users:
            completed = conn.execute(
                "SELECT COUNT(*) FROM records WHERE user_id = ? AND completed = 1",
                (u["id"],),
            ).fetchone()[0]
            rate = round(completed / planned * 100, 1) if planned > 0 else 0.0
            results.append({
                "nickname": u["nickname"],
                "completed": completed,
                "planned": planned,
                "rate": rate,
            })

        results.sort(key=lambda x: -x["rate"])
        return results


@router.get("/stats/all")
def all_stats():
    return _calc_stats()


@router.get("/stats/top10")
def top10():
    return _calc_stats()[:10]
