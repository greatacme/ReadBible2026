-- ============================================================
-- ReadBible2026 두 번째 그룹용 테이블 (users2, plans2, records2)
-- Supabase > SQL Editor 에서 실행
-- ============================================================

-- 1. 테이블 생성
CREATE TABLE public.users2 (
  id         SERIAL PRIMARY KEY,
  nickname   TEXT UNIQUE NOT NULL,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE TABLE public.plans2 (
  id         SERIAL PRIMARY KEY,
  date       DATE NOT NULL,
  book       TEXT NOT NULL,
  chapter_no INTEGER NOT NULL,
  sort_order INTEGER NOT NULL
);

CREATE TABLE public.records2 (
  id         SERIAL PRIMARY KEY,
  user_id    INTEGER NOT NULL REFERENCES public.users2(id),
  plan_id    INTEGER NOT NULL REFERENCES public.plans2(id),
  completed  BOOLEAN DEFAULT FALSE,
  updated_at TIMESTAMPTZ DEFAULT NOW(),
  UNIQUE(user_id, plan_id)
);

-- 2. 인덱스
CREATE INDEX idx_plans2_date   ON public.plans2(date);
CREATE INDEX idx_plans2_sort   ON public.plans2(sort_order);
CREATE INDEX idx_records2_user ON public.records2(user_id);
CREATE INDEX idx_records2_plan ON public.records2(plan_id);

-- 3. RLS 활성화
ALTER TABLE public.users2   ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.plans2   ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.records2 ENABLE ROW LEVEL SECURITY;

-- 4. 정책
CREATE POLICY "allow_all" ON public.users2   FOR ALL USING (true) WITH CHECK (true);
CREATE POLICY "allow_all" ON public.plans2   FOR ALL USING (true);
CREATE POLICY "allow_all" ON public.records2 FOR ALL USING (true) WITH CHECK (true);

-- 5. 완료율 통계 RPC
CREATE OR REPLACE FUNCTION get_stats2()
RETURNS TABLE(nickname TEXT, completed BIGINT, planned BIGINT, rate NUMERIC)
LANGUAGE sql SECURITY DEFINER
AS $$
  WITH planned_cnt AS (
    SELECT COUNT(*) AS cnt FROM public.plans2 WHERE date <= CURRENT_DATE
  ),
  user_done AS (
    SELECT u.nickname,
           COUNT(r.id) FILTER (WHERE r.completed = true) AS done
    FROM public.users2 u
    LEFT JOIN public.records2 r ON r.user_id = u.id
    GROUP BY u.id, u.nickname
  )
  SELECT ud.nickname,
         ud.done,
         pc.cnt,
         CASE WHEN pc.cnt > 0
              THEN ROUND(ud.done::NUMERIC / pc.cnt * 100, 1)
              ELSE 0
         END AS rate
  FROM user_done ud, planned_cnt pc
  ORDER BY rate DESC, ud.nickname;
$$;
