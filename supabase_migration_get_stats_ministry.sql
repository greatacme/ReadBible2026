-- ============================================================
-- get_stats() 함수 수정 - ministry 계층 지원
-- get_stats_tmp()와 동일한 로직, 함수명만 변경
-- ============================================================

DROP FUNCTION IF EXISTS public.get_stats(text, text) CASCADE;

CREATE OR REPLACE FUNCTION public.get_stats(p_group_code text, p_ministry_cd text DEFAULT '0')
RETURNS TABLE(nickname text, completed bigint, planned bigint, rate numeric) AS
$$
  WITH grp AS (
    SELECT COALESCE(
      (SELECT plan_set_cd FROM public.groups
       WHERE group_code = p_group_code AND ministry_cd = p_ministry_cd),
      '1'
    ) AS plan_set_cd
  ),
  planned_cnt AS (
    SELECT COUNT(*) AS cnt
    FROM public.plans, grp
    WHERE public.plans.plan_set_cd = grp.plan_set_cd
      AND public.plans.date <= (CURRENT_TIMESTAMP AT TIME ZONE 'Asia/Seoul')::DATE
  ),
  user_done AS (
    SELECT u.nickname,
           u.created_at,
           MAX(r.updated_at) FILTER (WHERE r.completed = true) AS first_record_at,
           COUNT(r.id) FILTER (WHERE r.completed = true) AS done
    FROM public.users u
    LEFT JOIN public.records r ON r.user_id = u.id
    WHERE u.group_code = p_group_code AND u.ministry_cd = p_ministry_cd
    GROUP BY u.id, u.nickname, u.created_at
  )
  SELECT ud.nickname,
         ud.done,
         pc.cnt,
         CASE WHEN pc.cnt > 0
              THEN ROUND(ud.done::NUMERIC / pc.cnt * 100, 1)
              ELSE 0
         END AS rate
  FROM user_done ud, planned_cnt pc
  ORDER BY rate DESC, COALESCE(ud.first_record_at, ud.created_at) ASC;
$$
LANGUAGE SQL;

-- 실행 후 정리 작업:
-- 1. supabase_migration_drop_plan_set_id.sql 생성 후 실행
--    - groups 테이블에서 plan_set_id INTEGER 컬럼 삭제
--    - plans 테이블에서 plan_set_id INTEGER 컬럼 삭제
--    - idx_plans_plan_set 인덱스 삭제
--
-- 2. index.html 수정: get_stats_tmp() → get_stats()로 변경
--
-- 3. supabase_migration_ministry.sql에서 get_stats_tmp() 함수 삭제
--    CREATE OR REPLACE FUNCTION get_stats_tmp() ... 제거
