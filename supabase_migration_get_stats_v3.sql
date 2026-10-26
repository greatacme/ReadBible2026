-- ============================================================
-- get_stats_v3() 함수 생성 - 전체/구약/신약 탭 지원
-- ============================================================
-- 기존 get_stats_v2() 는 그대로 유지 (운영 영향 없음)
--
-- p_testament 파라미터:
--   'ALL' (기본값) - 전체 (기존 get_stats_v2 와 동일 결과)
--   'OT'           - 구약 (book.testament = 'OT')
--   'NT'           - 신약 (book.testament = 'NT')
--
-- plans.book (한글 책명 TEXT) → book.name_ko 로 조인하여 testament 필터
-- ============================================================

CREATE OR REPLACE FUNCTION public.get_stats_v3(
  p_group_code TEXT,
  p_testament  TEXT DEFAULT 'ALL'
)
RETURNS TABLE(nickname TEXT, completed BIGINT, planned BIGINT, rate NUMERIC)
LANGUAGE sql
SECURITY DEFINER
SET search_path = public
AS $$
  WITH grp AS (
    -- 그룹의 plan_set_cd 조회 (없으면 기본값 '1')
    SELECT COALESCE(
      (SELECT plan_set_cd
       FROM public.groups
       WHERE group_code = p_group_code),
      '1'
    ) AS plan_set_cd
  ),
  planned_cnt AS (
    -- 오늘까지 계획된 장 수 (testament 필터 적용)
    SELECT COUNT(*) AS cnt
    FROM public.plans pl
    JOIN grp g ON pl.plan_set_cd = g.plan_set_cd
    LEFT JOIN public.book b ON b.name_ko = pl.book
    WHERE pl.date <= (CURRENT_TIMESTAMP AT TIME ZONE 'Asia/Seoul')::DATE
      AND (p_testament = 'ALL' OR b.testament = p_testament)
  ),
  user_done AS (
    -- 사용자별 완료 장 수 (testament 필터 적용)
    -- testament 필터는 FILTER(WHERE ...) 안에만 적용하여
    -- 기록이 없는 사용자도 0으로 정상 포함됨
    SELECT u.nickname,
           u.created_at,
           MAX(r.updated_at) FILTER (
             WHERE r.completed = true
               AND (p_testament = 'ALL' OR b.testament = p_testament)
           ) AS first_record_at,
           COUNT(r.id) FILTER (
             WHERE r.completed = true
               AND (p_testament = 'ALL' OR b.testament = p_testament)
           ) AS done
    FROM public.users u
    LEFT JOIN public.records r  ON r.user_id = u.id
    LEFT JOIN public.plans   pl ON pl.id = r.plan_id
    LEFT JOIN public.book    b  ON b.name_ko = pl.book
    WHERE u.group_code = p_group_code
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

GRANT EXECUTE ON FUNCTION public.get_stats_v3(TEXT, TEXT) TO anon;

-- ============================================================
-- 검증 쿼리 (Supabase SQL Editor에서 실행)
-- ============================================================
-- 1. 전체 통계 (get_stats_v2 와 결과 동일해야 함)
--    SELECT * FROM public.get_stats_v3('제1청장년', 'ALL');
--
-- 2. 구약 통계
--    SELECT * FROM public.get_stats_v3('제1청장년', 'OT');
--
-- 3. 신약 통계
--    SELECT * FROM public.get_stats_v3('제1청장년', 'NT');
--
-- 4. 전체 = 구약 + 신약 검증
--    (각 사용자의 OT.completed + NT.completed = ALL.completed 이어야 함)
