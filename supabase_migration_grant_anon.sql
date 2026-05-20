-- ============================================================
-- Data API 접근 권한 명시적 부여 (anon 롤)
-- 배경: Supabase 2026-10-30부터 기존 프로젝트도 명시적 GRANT 필수
-- Supabase > SQL Editor 에서 실행
-- ============================================================

-- COMM_CODE: 공통 코드 조회용 (읽기만)
GRANT SELECT ON public."COMM_CODE" TO anon;

-- groups: 그룹 생성/조회/수정/삭제
GRANT SELECT, INSERT, UPDATE, DELETE ON public.groups TO anon;

-- users: 사용자 등록/조회/수정/삭제
GRANT SELECT, INSERT, UPDATE, DELETE ON public.users TO anon;
GRANT USAGE ON SEQUENCE public.users_id_seq TO anon;

-- plans: 읽기 일정 조회 (앱에서 수정 없음)
GRANT SELECT ON public.plans TO anon;

-- records: 읽기 기록 생성/조회/수정/삭제
GRANT SELECT, INSERT, UPDATE, DELETE ON public.records TO anon;
GRANT USAGE ON SEQUENCE public.records_id_seq TO anon;

-- book: 성경 책 목록 조회 (읽기만)
GRANT SELECT ON public.book TO anon;

-- verse: 성경 절 본문 조회 (읽기만)
GRANT SELECT ON public.verse TO anon;

-- section_heading: 절 제목 조회 (읽기만)
GRANT SELECT ON public.section_heading TO anon;

-- footnote: 각주 조회 (읽기만)
GRANT SELECT ON public.footnote TO anon;
