-- ============================================================
-- Ministry 계층 추가 - get_stats() 함수 수정
-- 임시 함수 get_stats_tmp()로 테스트 후 운영 반영
-- ============================================================

-- 임시 테스트 함수: get_stats_tmp()
-- ministry_cd 파라미터 추가, ministry별 통계 필터링
CREATE OR REPLACE FUNCTION get_stats_tmp(p_group_code TEXT, p_ministry_cd TEXT DEFAULT '0')
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

-- 주석:
-- 1. plan_set_cd 기본값을 '1' 문자열로 설정 (groups 테이블의 plan_set_cd는 INTEGER인데,
--    plans 테이블의 plan_set_cd도 확인 필요)
-- 2. ministry_cd 기본값 '0'으로 기존 호환성 유지
-- 3. users와 groups에서 모두 ministry_cd 필터링
-- 4. 정렬 기준: 완독률 DESC, 최근 완료 시점 ASC (또는 가입일)
