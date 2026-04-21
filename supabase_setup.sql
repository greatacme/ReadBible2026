-- ============================================================
-- ReadBible2026 Supabase 초기 설정 (최신화)
-- Supabase > SQL Editor 에서 실행
-- ============================================================

-- 1. COMM_CODE 테이블 (공통 코드)
CREATE TABLE IF NOT EXISTS public."COMM_CODE" (
  code_group text NOT NULL,
  code_cd text NOT NULL,
  code_nm text,
  description text,
  created_at timestamp with time zone NOT NULL DEFAULT now(),
  PRIMARY KEY (code_group, code_cd)
);

-- 2. groups 테이블 (그룹 관리)
CREATE TABLE IF NOT EXISTS public.groups (
  group_code text NOT NULL,
  ministry_cd text NOT NULL DEFAULT '0',
  plan_set_cd text,
  plan_set_id integer DEFAULT 1,
  created_at timestamp with time zone DEFAULT now(),
  PRIMARY KEY (group_code, ministry_cd)
);

-- 3. users 테이블 (사용자)
CREATE TABLE IF NOT EXISTS public.users (
  id serial PRIMARY KEY,
  nickname text NOT NULL,
  group_code text NOT NULL DEFAULT '0',
  ministry_cd text NOT NULL DEFAULT '0',
  bible_ver_cd text,
  created_at timestamp with time zone DEFAULT now(),
  CONSTRAINT users_nickname_group_ministry_unique UNIQUE (nickname, group_code, ministry_cd)
);

-- 4. plans 테이블 (성경 읽기 일정)
CREATE TABLE IF NOT EXISTS public.plans (
  id serial PRIMARY KEY,
  date date NOT NULL,
  book text NOT NULL,
  chapter_no integer NOT NULL,
  sort_order integer NOT NULL,
  plan_set_cd text,
  plan_set_id integer DEFAULT 1
);

-- 5. records 테이블 (읽기 기록)
CREATE TABLE IF NOT EXISTS public.records (
  id serial PRIMARY KEY,
  user_id integer NOT NULL REFERENCES public.users(id) ON DELETE CASCADE,
  plan_id integer NOT NULL REFERENCES public.plans(id),
  completed boolean DEFAULT false,
  updated_at timestamp with time zone DEFAULT now(),
  UNIQUE(user_id, plan_id)
);

-- 6. book 테이블 (성경 책 목록 - 버전별 본문 참조용)
CREATE TABLE IF NOT EXISTS public.book (
  book_id integer PRIMARY KEY,
  name_ko text,
  name_en text
);

-- 7. verse 테이블 (성경 절 - Supabase 저장용)
CREATE TABLE IF NOT EXISTS public.verse (
  id bigserial PRIMARY KEY,
  version_id text,
  book_id integer,
  chapter integer,
  verse integer,
  text text,
  UNIQUE(version_id, book_id, chapter, verse)
);

-- 8. section_heading 테이블 (절 제목)
CREATE TABLE IF NOT EXISTS public.section_heading (
  id bigserial PRIMARY KEY,
  version_id text,
  book_id integer,
  chapter integer,
  heading text
);

-- 9. footnote 테이블 (각주)
CREATE TABLE IF NOT EXISTS public.footnote (
  id bigserial PRIMARY KEY,
  version_id text,
  book_id integer,
  chapter integer,
  verse integer,
  note text
);

-- 10. 인덱스 생성
CREATE INDEX IF NOT EXISTS idx_plans_date ON public.plans(date);
CREATE INDEX IF NOT EXISTS idx_plans_sort_order ON public.plans(sort_order);
CREATE INDEX IF NOT EXISTS idx_plans_plan_set_cd ON public.plans(plan_set_cd);
CREATE INDEX IF NOT EXISTS idx_plans_plan_set_id ON public.plans(plan_set_id);
CREATE INDEX IF NOT EXISTS idx_records_user_id ON public.records(user_id);
CREATE INDEX IF NOT EXISTS idx_records_plan_id ON public.records(plan_id);
CREATE INDEX IF NOT EXISTS idx_users_group_ministry ON public.users(group_code, ministry_cd);
CREATE INDEX IF NOT EXISTS idx_verse_version_book_chapter ON public.verse(version_id, book_id, chapter);

-- 11. RLS 정책 (신뢰 그룹 대상 - 전체 허용)
ALTER TABLE public.groups ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.users ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.plans ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.records ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.book ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.verse ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.section_heading ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.footnote ENABLE ROW LEVEL SECURITY;

CREATE POLICY IF NOT EXISTS "allow_all_groups" ON public.groups FOR ALL USING (true) WITH CHECK (true);
CREATE POLICY IF NOT EXISTS "allow_all_users" ON public.users FOR ALL USING (true) WITH CHECK (true);
CREATE POLICY IF NOT EXISTS "allow_all_plans" ON public.plans FOR ALL USING (true);
CREATE POLICY IF NOT EXISTS "allow_all_records" ON public.records FOR ALL USING (true) WITH CHECK (true);
CREATE POLICY IF NOT EXISTS "allow_all_book" ON public.book FOR ALL USING (true);
CREATE POLICY IF NOT EXISTS "allow_all_verse" ON public.verse FOR ALL USING (true);
CREATE POLICY IF NOT EXISTS "allow_all_section_heading" ON public.section_heading FOR ALL USING (true);
CREATE POLICY IF NOT EXISTS "allow_all_footnote" ON public.footnote FOR ALL USING (true);
