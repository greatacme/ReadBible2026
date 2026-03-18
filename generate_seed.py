"""seed_plans.sql 생성 스크립트 — Supabase SQL Editor에서 실행할 INSERT 생성"""
from datetime import date, timedelta

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
]

def generate(start=date(2026, 4, 1), total_days=275):
    chapters = [(b, ch) for b, n in BOOKS for ch in range(1, n + 1)]
    total = len(chapters)
    rows, idx, order = [], 0, 1
    for day in range(total_days):
        n = total // total_days + (1 if day < total % total_days else 0)
        d = (start + timedelta(days=day)).strftime("%Y-%m-%d")
        for book, ch in chapters[idx: idx + n]:
            rows.append(f"('{d}','{book}',{ch},{order})")
            order += 1
        idx += n
    return rows

rows = generate()
chunk = 500
lines = ["-- seed_plans.sql  (Supabase SQL Editor에서 실행)\n"]
for i in range(0, len(rows), chunk):
    vals = ",\n  ".join(rows[i:i+chunk])
    lines.append(
        f"INSERT INTO public.plans (date, book, chapter_no, sort_order) VALUES\n  {vals}\nON CONFLICT DO NOTHING;\n"
    )

with open("seed_plans.sql", "w", encoding="utf-8") as f:
    f.write("\n".join(lines))

print(f"seed_plans.sql 생성 완료 ({len(rows)}행)")
