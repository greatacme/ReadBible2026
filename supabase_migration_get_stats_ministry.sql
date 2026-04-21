-- ============================================================
-- get_stats() 함수 수정 - ministry 계층 지원
-- WITH 절 제거하고 서브쿼리로 변경
-- ============================================================

DROP FUNCTION IF EXISTS public.get_stats(text, text) CASCADE;

CREATE OR REPLACE FUNCTION public.get_stats(
  p_group_code text,
  p_ministry_cd text DEFAULT '0'
)
RETURNS TABLE(nickname text, completed bigint, planned bigint, rate numeric)
LANGUAGE plpgsql
AS $$
DECLARE
  v_plan_set_cd text;
  v_planned_cnt bigint;
BEGIN
  -- 1. plan_set_cd 조회
  SELECT COALESCE(plan_set_cd, '1') INTO v_plan_set_cd
  FROM public.groups
  WHERE group_code = p_group_code AND ministry_cd = p_ministry_cd
  LIMIT 1;

  -- 2. plan_set_cd 기본값 처리
  IF v_plan_set_cd IS NULL THEN
    v_plan_set_cd := '1';
  END IF;

  -- 3. planned_cnt 계산
  SELECT COUNT(*) INTO v_planned_cnt
  FROM public.plans
  WHERE plan_set_cd = v_plan_set_cd
    AND date <= (CURRENT_TIMESTAMP AT TIME ZONE 'Asia/Seoul')::DATE;

  -- 4. 결과 반환
  RETURN QUERY
  SELECT
    u.nickname,
    COUNT(r.id) FILTER (WHERE r.completed = true)::bigint,
    v_planned_cnt::bigint,
    CASE WHEN v_planned_cnt > 0
         THEN ROUND(COUNT(r.id) FILTER (WHERE r.completed = true)::numeric / v_planned_cnt::numeric * 100, 1)
         ELSE 0
    END
  FROM public.users u
  LEFT JOIN public.records r ON r.user_id = u.id
  WHERE u.group_code = p_group_code AND u.ministry_cd = p_ministry_cd
  GROUP BY u.id, u.nickname, u.created_at
  ORDER BY 4 DESC, MAX(r.updated_at) FILTER (WHERE r.completed = true) ASC;
END
$$;

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
