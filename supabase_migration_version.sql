-- ============================================================
-- groups 테이블에 version_id 컬럼 추가
-- Supabase > SQL Editor 에서 실행
-- ============================================================

ALTER TABLE public.groups ADD COLUMN version_id TEXT;
