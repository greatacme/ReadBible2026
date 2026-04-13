"""테스트용 users + records DML 생성"""
from datetime import date, timedelta

NICKNAMES = [
    "김성현", "이지은", "박준혁", "최민지", "정우진",
    "한소희", "윤재호", "강미래", "오세훈", "임수빈",
    "신동훈", "배유리", "황민준", "전혜린", "조성재",
    "류지현", "문태양", "서은아", "남기훈", "권나연",
]

# 사용자별 완료 장수 (순서대로 1장부터 N장까지 완료 처리)
COMPLETED = [
    120,  # 김성현  - 많이 앞서감
    105,  # 이지은
    95,   # 박준혁
    88,   # 최민지
    80,   # 정우진  - 약간 앞서감
    74,   # 한소희  - 딱 맞게
    70,   # 윤재호
    65,   # 강미래
    60,   # 오세훈
    55,   # 임수빈  - 약간 뒤처짐
    48,   # 신동훈
    40,   # 배유리
    32,   # 황민준
    25,   # 전혜린
    18,   # 조성재
    12,   # 류지현
    8,    # 문태양
    4,    # 서은아
    2,    # 남기훈  - 막 시작함
    0,    # 권나연  - 아직 시작 안 함
]

lines = ["-- test_data.sql  (Supabase SQL Editor에서 실행)\n"]

# 1. users INSERT
user_vals = ", ".join(f"('{n}')" for n in NICKNAMES)
lines.append(f"INSERT INTO public.users (nickname) VALUES\n  {user_vals}\nON CONFLICT DO NOTHING;\n")

# 2. records INSERT (plan_id는 sort_order = 1~N 순서로 완료 처리)
#    plan_id를 sort_order로 직접 참조할 수 없으므로, subquery로 가져옴
record_rows = []
for nickname, completed in zip(NICKNAMES, COMPLETED):
    if completed == 0:
        continue
    record_rows.append(
        f"  SELECT u.id, p.id, true, now()\n"
        f"  FROM public.users u, public.plans p\n"
        f"  WHERE u.nickname = '{nickname}' AND p.sort_order <= {completed}"
    )

if record_rows:
    union_sql = "\nUNION ALL\n".join(record_rows)
    lines.append(
        f"INSERT INTO public.records (user_id, plan_id, completed, updated_at)\n"
        f"{union_sql}\n"
        f"ON CONFLICT (user_id, plan_id) DO UPDATE SET completed = EXCLUDED.completed, updated_at = EXCLUDED.updated_at;\n"
    )

with open("test_data.sql", "w", encoding="utf-8") as f:
    f.write("\n".join(lines))

print(f"test_data.sql 생성 완료")
print(f"  사용자: {len(NICKNAMES)}명")
print(f"  records: {sum(COMPLETED)}건")
