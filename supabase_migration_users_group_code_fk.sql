-- users.group_code가 유효한 groups.group_code만 참조하도록 보장
BEGIN;

DO $$
BEGIN
  IF EXISTS (
    SELECT 1
    FROM public.users u
    LEFT JOIN public.groups g ON g.group_code = u.group_code
    WHERE g.group_code IS NULL
  ) THEN
    RAISE EXCEPTION 'groups에 존재하지 않는 group_code를 가진 사용자가 있습니다.';
  END IF;

  IF NOT EXISTS (
    SELECT 1
    FROM pg_constraint
    WHERE conrelid = 'public.users'::regclass
      AND contype = 'f'
      AND conname = 'users_group_code_fkey'
  ) THEN
    ALTER TABLE public.users
      ADD CONSTRAINT users_group_code_fkey
      FOREIGN KEY (group_code)
      REFERENCES public.groups(group_code)
      ON UPDATE CASCADE
      ON DELETE RESTRICT;
  END IF;
END
$$;

COMMIT;

-- 확인: FOREIGN KEY (group_code)가 표시되어야 함
SELECT conname, pg_get_constraintdef(oid) AS definition
FROM pg_constraint
WHERE conrelid = 'public.users'::regclass
  AND conname = 'users_group_code_fkey';
