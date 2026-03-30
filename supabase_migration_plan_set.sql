-- ============================================================
-- plan_set_id 마이그레이션
-- 실행 전제: supabase_setup.sql, supabase_setup2.sql(plans2), seed_plans2.sql 완료
-- Supabase > SQL Editor 에서 실행
-- ============================================================

-- 1. groups 테이블 생성
CREATE TABLE public.groups (
  group_code  TEXT PRIMARY KEY,
  plan_set_id INTEGER NOT NULL DEFAULT 1,
  created_at  TIMESTAMPTZ DEFAULT NOW()
);

ALTER TABLE public.groups ENABLE ROW LEVEL SECURITY;
CREATE POLICY "allow_all" ON public.groups FOR ALL USING (true) WITH CHECK (true);

-- 2. plans 테이블에 plan_set_id 컬럼 추가 (기존 데이터 = 1)
ALTER TABLE public.plans ADD COLUMN plan_set_id INTEGER NOT NULL DEFAULT 1;
CREATE INDEX idx_plans_plan_set ON public.plans(plan_set_id);

-- 3. plans2 데이터를 plans 테이블에 plan_set_id=2 로 삽입
--    (plans2의 sort_order는 plan_set_id 내에서만 고유하면 됨)
INSERT INTO public.plans (date, book, chapter_no, sort_order, plan_set_id)
SELECT date, book, chapter_no, sort_order, 2
FROM public.plans2;

-- 4. get_stats RPC 수정: groups 테이블에서 plan_set_id 조회, 없으면 1 기본값
CREATE OR REPLACE FUNCTION get_stats(p_group_code TEXT)
RETURNS TABLE(nickname TEXT, completed BIGINT, planned BIGINT, rate NUMERIC)
LANGUAGE sql SECURITY DEFINER
AS $$
  WITH grp AS (
    SELECT COALESCE(
      (SELECT plan_set_id FROM public.groups WHERE group_code = p_group_code),
      1
    ) AS plan_set_id
  ),
  planned_cnt AS (
    SELECT COUNT(*) AS cnt
    FROM public.plans, grp
    WHERE public.plans.plan_set_id = grp.plan_set_id
      AND public.plans.date <= CURRENT_DATE
  ),
  user_done AS (
    SELECT u.nickname,
           COUNT(r.id) FILTER (WHERE r.completed = true) AS done
    FROM public.users u
    LEFT JOIN public.records r ON r.user_id = u.id
    WHERE u.group_code = p_group_code
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
