-- users.ministry_cd에 의존하지 않는 통계 함수
CREATE OR REPLACE FUNCTION public.get_stats_v2(p_group_code TEXT)
RETURNS TABLE(nickname TEXT, completed BIGINT, planned BIGINT, rate NUMERIC)
LANGUAGE sql
SECURITY DEFINER
SET search_path = public
AS $$
  WITH grp AS (
    SELECT COALESCE(
      (SELECT plan_set_cd
       FROM public.groups
       WHERE group_code = p_group_code),
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

GRANT EXECUTE ON FUNCTION public.get_stats_v2(TEXT) TO anon;

-- 확인 예시
-- SELECT * FROM public.get_stats_v2('G0001');
