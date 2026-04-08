# CLAUDE.md — ReadBible2026

## 프로젝트 개요

2026년 성경통독 진도 관리 웹앱. GitHub Pages 정적 사이트 + Supabase(PostgreSQL) 조합.
별도 백엔드 없이 브라우저에서 Supabase REST API에 직접 접근한다.

---

## 파일 구조

```
home.html             # 그룹 선택/생성 화면 (진입점)
index.html            # 그룹 메인: 리더보드 + 닉네임 로그인
record.html           # 개인 진도 화면: 월별 장별 체크박스
bible.html            # 성경 본문 읽기 화면
edit.html             # 프로필 편집 화면 (닉네임/그룹 변경, 계정 삭제)
group-edit.html       # 그룹 편집 화면 (그룹명 변경, 그룹 삭제)
CHANGELOG.md          # 버전별 변경 이력
supabase_setup.sql    # 최초 DB 세팅 (테이블 / RLS / RPC 생성)
supabase_migration.sql# 그룹 기능 마이그레이션 (group_code 컬럼 추가)
seed_plans.sql        # plans 테이블 1,189장 데이터 (plan_set_id=1)
seed_plans2.sql       # plans 테이블 1,189장 데이터 (plan_set_id=2)
seed_plans3.sql       # plans 테이블 1,189장 데이터 (plan_set_id=3)
seed_test_groups.sql  # 그룹별 테스트 사용자 및 완료 기록
generate_seed.py      # seed_plans.sql 재생성 스크립트
```

---

## DB 스키마

```sql
groups  (group_code TEXT PK, plan_set_id INT DEFAULT 1, version_id INT, created_at)
users   (id SERIAL PK, nickname TEXT, group_code TEXT, created_at)
plans   (id SERIAL PK, plan_set_id INT DEFAULT 1, date DATE, book TEXT, chapter_no INT, sort_order INT)
records (id SERIAL PK, user_id INT → users.id, plan_id INT → plans.id,
         completed BOOLEAN, updated_at TIMESTAMPTZ)
book    (book_id, name_ko, ...)
verse   (version_id, book_id, chapter, verse, text)
```

- `groups` — group_code 를 plan_set_id / version_id 에 매핑. home.html에서 사전 생성 가능
- `groups.version_id` — NULL이면 helloao.org API 사용, 값이 있으면 Supabase verse 테이블 사용
- `users.nickname` + `users.group_code` 복합 UNIQUE → 그룹 내 닉네임 중복 불가
- `plans.plan_set_id` — 읽기 플랜 구분. 1/2/3 = 각 그룹용 플랜
- `plans.sort_order` — plan_set_id 내에서만 고유하면 됨 (인접 장 탐색에 사용)
- `records` 는 users.id 를 통해 그룹 격리됨
- RLS 정책: 전체 허용 (신뢰 그룹 대상 서비스)

### RPC

```sql
get_stats(p_group_code TEXT)
  → (nickname, completed, planned, rate)
  -- groups 테이블에서 plan_set_id 조회 (없으면 1), 해당 plan_set 기준으로 완독률 계산
  -- 날짜 기준: KST(Asia/Seoul) 자정
  -- 정렬: rate DESC, 동률 시 최초 완료 시점 ASC
```

---

## 그룹 시스템

- 진입점: `home.html` — 그룹 목록 표시, 신규 그룹 생성
- URL 파라미터 `?group=그룹코드` 필수
- 없으면 home.html로 리디렉션
- record.html / bible.html은 그룹 없으면 index.html 리디렉션
- `?plan=N` — 그룹 최초 생성 시만 유효. 이미 존재하는 그룹은 기존 plan_set_id 유지
- plan 파라미터 생략 시 plan_set_id = 1 (기본 플랜)

```
home.html                                ← 그룹 선택/생성
index.html?group=제1청장년               ← 그룹 메인 (plan_set_id=1)
index.html?group=루체채플&plan=2         ← 첫 진입 시에만 plan 적용
record.html?nickname=홍길동&group=제1청장년
bible.html?nickname=홍길동&plan_id=1&book=창세기&chapter_no=1&sort_order=1&group=제1청장년
group-edit.html?group=제1청장년          ← 그룹 편집
edit.html?nickname=홍길동&group=제1청장년← 프로필 편집
```

---

## JS 패턴 (공통)

```javascript
// 그룹 코드 추출
const groupCode = new URLSearchParams(location.search).get('group')
const groupParam = groupCode ? `&group=${encodeURIComponent(groupCode)}` : ''

// users 조회 — 반드시 group_code 필터 포함
sb.from('users').select('id').eq('nickname', nickname).eq('group_code', groupCode)

// users 생성 — group_code 포함
sb.from('users').insert({ nickname, group_code: groupCode })

// stats RPC 호출
sb.rpc('get_stats', { p_group_code: groupCode })
```

- 테이블명은 항상 `'users'` / `'plans'` / `'records'` 고정
- 모든 페이지 이동 시 `groupParam` 을 URL에 append

---

## 성경 본문 소스 분기

bible.html은 그룹의 `version_id`에 따라 본문 소스를 분기한다:

- `version_id = null` → helloao.org API (`/api/kor_old/{BOOK_CODE}/{chapter}.json`)
- `version_id = N` → Supabase `verse` 테이블 (book_id + chapter + version_id 필터)

---

## 버전 관리

- 체계: `ver.major.minor.yyyy.mmdd` (예: ver.2.9.2026.0408)
- major: 사용자 명시 요청 시만 변경
- minor: 기능 추가/개선 배포마다 +1 (오류 수정 fix는 유지)
- yyyy.mmdd: 배포 당일 날짜
- 버전 표기 위치: `home.html` footer 우측 하단
- 변경 이력: `CHANGELOG.md`

---

## Supabase 설정 순서

1. `supabase_setup.sql` 실행 (최초 1회)
2. `seed_plans.sql` 실행 (1,189장 데이터, plan_set_id=1)
3. `supabase_migration.sql` 실행 (group_code 컬럼 추가)
4. `supabase_migration_plan_set.sql` 실행 (groups 테이블, plan_set_id, RPC 수정)
5. `seed_plans2.sql` 실행 (plan_set_id=2 용 데이터)
6. `seed_plans3.sql` 실행 (plan_set_id=3 용 데이터)
7. `supabase_migration_get_stats_order.sql` 실행 (KST 날짜 + 완료 시점 정렬)
8. (선택) `seed_test_groups.sql` 실행 (테스트 데이터)

---

## 배포

GitHub Pages (main 브랜치 root). push 시 자동 배포.
서비스 URL: https://greatacme.github.io/ReadBible2026/

---

## 주의사항

- Supabase anon key 가 HTML에 하드코딩되어 있음 — RLS 정책으로 접근 제어
- 닉네임 기반 로그인이므로 타인 닉네임 입력 시 해당 사용자로 접근 가능 (신뢰 그룹 전제)
- plans 테이블은 그룹 공용이므로 그룹별로 다른 읽기 일정이 필요하다면 plan_set_id 분리
