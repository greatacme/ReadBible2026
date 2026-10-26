-- groups.group_code를 전역 고유 그룹 식별자로 사용하기 위한 사전 마이그레이션
BEGIN;

DO $$
BEGIN
  IF EXISTS (
    SELECT 1
    FROM public.groups
    GROUP BY group_code
    HAVING COUNT(*) > 1
  ) THEN
    RAISE EXCEPTION 'groups.group_code에 중복 값이 있어 UNIQUE 제약을 추가할 수 없습니다.';
  END IF;

  IF NOT EXISTS (
    SELECT 1
    FROM pg_constraint
    WHERE conrelid = 'public.groups'::regclass
      AND contype = 'u'
      AND conname = 'groups_group_code_unique'
  ) THEN
    ALTER TABLE public.groups
      ADD CONSTRAINT groups_group_code_unique UNIQUE (group_code);
  END IF;
END
$$;

COMMIT;

-- 확인: UNIQUE (group_code)가 표시되어야 함
SELECT conname, pg_get_constraintdef(oid) AS definition
FROM pg_constraint
WHERE conrelid = 'public.groups'::regclass
  AND conname = 'groups_group_code_unique';
