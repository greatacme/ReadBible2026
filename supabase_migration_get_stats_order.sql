-- get_stats RPC: 동률 시 정렬 기준을 가나다순 → 최근 등록순(created_at DESC)으로 변경

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
           u.created_at,
           MIN(r.updated_at) AS first_record_at,
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
