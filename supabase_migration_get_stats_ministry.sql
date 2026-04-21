-- ============================================================
-- get_stats() 함수 수정 - ministry 계층 지원
-- Supabase에서 정상 작동하는 함수 정의로 확정
-- ============================================================

DROP FUNCTION IF EXISTS public.get_stats(TEXT, TEXT);

CREATE OR REPLACE FUNCTION public.get_stats(p_group_code TEXT, p_ministry_cd TEXT DEFAULT '0')
RETURNS TABLE(nickname TEXT, completed BIGINT, planned BIGINT, rate NUMERIC)
LANGUAGE sql SECURITY DEFINER
AS $$
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
$$;

-- ============================================================
-- 실행 후 정리 작업
-- ============================================================
-- 1. plan_set_id 컬럼 삭제: supabase_migration_drop_plan_set_id.sql 실행
-- 2. get_stats_tmp() 함수 삭제:
--    DROP FUNCTION IF EXISTS public.get_stats_tmp(TEXT, TEXT);
