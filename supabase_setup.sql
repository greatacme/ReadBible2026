-- ============================================================
-- ReadBible2026 Supabase 초기 설정
-- Supabase > SQL Editor 에서 실행
-- ============================================================

-- 1. 테이블 생성
CREATE TABLE public.users (
  id         SERIAL PRIMARY KEY,
  nickname   TEXT UNIQUE NOT NULL,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE TABLE public.plans (
  id         SERIAL PRIMARY KEY,
  date       DATE NOT NULL,
  book       TEXT NOT NULL,
  chapter_no INTEGER NOT NULL,
  sort_order INTEGER NOT NULL
);

CREATE TABLE public.records (
  id         SERIAL PRIMARY KEY,
  user_id    INTEGER NOT NULL REFERENCES public.users(id),
  plan_id    INTEGER NOT NULL REFERENCES public.plans(id),
  completed  BOOLEAN DEFAULT FALSE,
  updated_at TIMESTAMPTZ DEFAULT NOW(),
  UNIQUE(user_id, plan_id)
);

-- 2. 인덱스
CREATE INDEX idx_plans_date   ON public.plans(date);
CREATE INDEX idx_plans_sort   ON public.plans(sort_order);
CREATE INDEX idx_records_user ON public.records(user_id);
CREATE INDEX idx_records_plan ON public.records(plan_id);

-- 3. RLS 활성화
ALTER TABLE public.users   ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.plans   ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.records ENABLE ROW LEVEL SECURITY;

-- 4. 정책 (10명 소규모 신뢰 그룹 → 전체 공개)
CREATE POLICY "allow_all" ON public.users   FOR ALL USING (true) WITH CHECK (true);
CREATE POLICY "allow_all" ON public.plans   FOR ALL USING (true);
CREATE POLICY "allow_all" ON public.records FOR ALL USING (true) WITH CHECK (true);

-- 5. 완료율 통계 RPC
CREATE OR REPLACE FUNCTION get_stats()
RETURNS TABLE(nickname TEXT, completed BIGINT, planned BIGINT, rate NUMERIC)
LANGUAGE sql SECURITY DEFINER
AS $$
  WITH planned_cnt AS (
    SELECT COUNT(*) AS cnt FROM public.plans WHERE date <= CURRENT_DATE
  ),
  user_done AS (
    SELECT u.nickname,
           COUNT(r.id) FILTER (WHERE r.completed = true) AS done
    FROM public.users u
    LEFT JOIN public.records r ON r.user_id = u.id
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
