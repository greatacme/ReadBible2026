-- ============================================================
-- ReadBible2026 그룹 기능 마이그레이션
-- 기존 users/plans/records 단일 테이블 세트에
-- group_code 컬럼 추가로 N개 그룹 지원
-- ============================================================

-- 1. users 테이블에 group_code 컬럼 추가
--    (기존 row는 '0'으로 채워짐)
ALTER TABLE public.users
  ADD COLUMN IF NOT EXISTS group_code TEXT NOT NULL DEFAULT '0';

-- 2. nickname 단독 UNIQUE 제거
ALTER TABLE public.users
  DROP CONSTRAINT IF EXISTS users_nickname_key;

-- 3. (nickname, group_code) 복합 UNIQUE 추가
--    → 같은 그룹 내에서만 닉네임 중복 불가
ALTER TABLE public.users
  ADD CONSTRAINT users_nickname_group_unique UNIQUE (nickname, group_code);

-- 4. 기존 단일 RPC 함수 삭제
DROP FUNCTION IF EXISTS get_stats();
DROP FUNCTION IF EXISTS get_stats2();

-- 5. 그룹 코드를 파라미터로 받는 새 RPC 함수 생성
CREATE OR REPLACE FUNCTION get_stats(p_group_code TEXT)
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
