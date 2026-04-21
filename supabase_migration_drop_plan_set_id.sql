-- ============================================================
-- plan_set_id 컬럼 삭제 - plan_set_cd로 완전 전환
-- 실행: get_stats() 함수 생성 후, index.html 배포 완료 후
-- ============================================================

-- 1. groups 테이블 - plan_set_id 컬럼 삭제
ALTER TABLE public.groups DROP COLUMN IF EXISTS plan_set_id;

-- 2. plans 테이블 - plan_set_id 컬럼 삭제 및 인덱스 정리
DROP INDEX IF EXISTS public.idx_plans_plan_set_id;
ALTER TABLE public.plans DROP COLUMN IF EXISTS plan_set_id;

-- ============================================================
-- 확인 쿼리
-- ============================================================
-- SELECT * FROM INFORMATION_SCHEMA.COLUMNS
-- WHERE TABLE_NAME IN ('groups', 'plans') AND COLUMN_NAME LIKE '%plan_set%';
