-- test_data.sql  (Supabase SQL Editor에서 실행)

INSERT INTO public.users (nickname) VALUES
  ('김성현'), ('이지은'), ('박준혁'), ('최민지'), ('정우진'), ('한소희'), ('윤재호'), ('강미래'), ('오세훈'), ('임수빈'), ('신동훈'), ('배유리'), ('황민준'), ('전혜린'), ('조성재'), ('류지현'), ('문태양'), ('서은아'), ('남기훈'), ('권나연')
ON CONFLICT DO NOTHING;

INSERT INTO public.records (user_id, plan_id, completed, updated_at)
  SELECT u.id, p.id, true, now()
  FROM public.users u, public.plans p
  WHERE u.nickname = '김성현' AND p.sort_order <= 120
UNION ALL
  SELECT u.id, p.id, true, now()
  FROM public.users u, public.plans p
  WHERE u.nickname = '이지은' AND p.sort_order <= 105
UNION ALL
  SELECT u.id, p.id, true, now()
  FROM public.users u, public.plans p
  WHERE u.nickname = '박준혁' AND p.sort_order <= 95
UNION ALL
  SELECT u.id, p.id, true, now()
  FROM public.users u, public.plans p
  WHERE u.nickname = '최민지' AND p.sort_order <= 88
UNION ALL
  SELECT u.id, p.id, true, now()
  FROM public.users u, public.plans p
  WHERE u.nickname = '정우진' AND p.sort_order <= 80
UNION ALL
  SELECT u.id, p.id, true, now()
  FROM public.users u, public.plans p
  WHERE u.nickname = '한소희' AND p.sort_order <= 74
UNION ALL
  SELECT u.id, p.id, true, now()
  FROM public.users u, public.plans p
  WHERE u.nickname = '윤재호' AND p.sort_order <= 70
UNION ALL
  SELECT u.id, p.id, true, now()
  FROM public.users u, public.plans p
  WHERE u.nickname = '강미래' AND p.sort_order <= 65
UNION ALL
  SELECT u.id, p.id, true, now()
  FROM public.users u, public.plans p
  WHERE u.nickname = '오세훈' AND p.sort_order <= 60
UNION ALL
  SELECT u.id, p.id, true, now()
  FROM public.users u, public.plans p
  WHERE u.nickname = '임수빈' AND p.sort_order <= 55
UNION ALL
  SELECT u.id, p.id, true, now()
  FROM public.users u, public.plans p
  WHERE u.nickname = '신동훈' AND p.sort_order <= 48
UNION ALL
  SELECT u.id, p.id, true, now()
  FROM public.users u, public.plans p
  WHERE u.nickname = '배유리' AND p.sort_order <= 40
UNION ALL
  SELECT u.id, p.id, true, now()
  FROM public.users u, public.plans p
  WHERE u.nickname = '황민준' AND p.sort_order <= 32
UNION ALL
  SELECT u.id, p.id, true, now()
  FROM public.users u, public.plans p
  WHERE u.nickname = '전혜린' AND p.sort_order <= 25
UNION ALL
  SELECT u.id, p.id, true, now()
  FROM public.users u, public.plans p
  WHERE u.nickname = '조성재' AND p.sort_order <= 18
UNION ALL
  SELECT u.id, p.id, true, now()
  FROM public.users u, public.plans p
  WHERE u.nickname = '류지현' AND p.sort_order <= 12
UNION ALL
  SELECT u.id, p.id, true, now()
  FROM public.users u, public.plans p
  WHERE u.nickname = '문태양' AND p.sort_order <= 8
UNION ALL
  SELECT u.id, p.id, true, now()
  FROM public.users u, public.plans p
  WHERE u.nickname = '서은아' AND p.sort_order <= 4
UNION ALL
  SELECT u.id, p.id, true, now()
  FROM public.users u, public.plans p
  WHERE u.nickname = '남기훈' AND p.sort_order <= 2
ON CONFLICT (user_id, plan_id) DO UPDATE SET completed = EXCLUDED.completed, updated_at = EXCLUDED.updated_at;
