"""성경통독 계획 초기 데이터 생성 (2026.4.1 ~ 2026.12.31)"""
from datetime import date, timedelta
import database

BOOKS = [
    ("창세기", 50), ("출애굽기", 40), ("레위기", 27), ("민수기", 36), ("신명기", 34),
    ("여호수아", 24), ("사사기", 21), ("룻기", 4), ("사무엘상", 31), ("사무엘하", 24),
    ("열왕기상", 22), ("열왕기하", 25), ("역대상", 29), ("역대하", 36),
    ("에스라", 10), ("느헤미야", 13), ("에스더", 10), ("욥기", 42), ("시편", 150),
    ("잠언", 31), ("전도서", 12), ("아가", 8), ("이사야", 66), ("예레미야", 52),
    ("예레미야애가", 5), ("에스겔", 48), ("다니엘", 12), ("호세아", 14), ("요엘", 3),
    ("아모스", 9), ("오바댜", 1), ("요나", 4), ("미가", 7), ("나훔", 3),
    ("하박국", 3), ("스바냐", 3), ("학개", 2), ("스가랴", 14), ("말라기", 4),
    ("마태복음", 28), ("마가복음", 16), ("누가복음", 24), ("요한복음", 21),
    ("사도행전", 28), ("로마서", 16), ("고린도전서", 16), ("고린도후서", 13),
    ("갈라디아서", 6), ("에베소서", 6), ("빌립보서", 4), ("골로새서", 4),
    ("데살로니가전서", 5), ("데살로니가후서", 3), ("디모데전서", 6), ("디모데후서", 4),
    ("디도서", 3), ("빌레몬서", 1), ("히브리서", 13), ("야고보서", 5),
    ("베드로전서", 5), ("베드로후서", 3), ("요한1서", 5), ("요한2서", 1),
    ("요한3서", 1), ("유다서", 1), ("요한계시록", 22),
]  # 총 1,189장


def _build_desc(day_chapters: list) -> str:
    parts = []
    cur_book = None
    ch_start = ch_end = None
    for book, ch in day_chapters:
        if book != cur_book:
            if cur_book:
                suffix = f"{ch_start}장" if ch_start == ch_end else f"{ch_start}-{ch_end}장"
                parts.append(f"{cur_book} {suffix}")
            cur_book, ch_start, ch_end = book, ch, ch
        else:
            ch_end = ch
    if cur_book:
        suffix = f"{ch_start}장" if ch_start == ch_end else f"{ch_start}-{ch_end}장"
        parts.append(f"{cur_book} {suffix}")
    return ", ".join(parts)


def generate_plans() -> list:
    chapters = [(book, ch) for book, n in BOOKS for ch in range(1, n + 1)]
    total = len(chapters)          # 1,189
    start = date(2026, 4, 1)
    total_days = 275               # 4/1 ~ 12/31

    plans, idx = [], 0
    for day_idx in range(total_days):
        n = total // total_days + (1 if day_idx < total % total_days else 0)
        day_chapters = chapters[idx: idx + n]
        idx += n
        d = (start + timedelta(days=day_idx)).strftime("%Y-%m-%d")
        plans.append((d, _build_desc(day_chapters), day_idx + 1))
    return plans


def seed():
    with get_conn() as conn:
        if conn.execute("SELECT COUNT(*) FROM plans").fetchone()[0] > 0:
            return
        plans = generate_plans()
        conn.executemany(
            "INSERT INTO plans (date, description, sort_order) VALUES (?, ?, ?)", plans
        )
        print(f"성경통독 계획 {len(plans)}일치 등록 완료")


def get_conn():
    return database.get_conn()


if __name__ == "__main__":
    database.init_db()
    seed()
    print("완료")
