# CLAUDE.md — ReadBible2026

## 프로젝트 개요

2026년 성경통독 진도 관리 웹앱. GitHub Pages 정적 사이트 + Supabase(PostgreSQL) 조합.
별도 백엔드 없이 브라우저에서 Supabase REST API에 직접 접근한다.

---

## 파일 구조

```
index.html            # 첫 화면: 리더보드 + 닉네임 로그인
record.html           # 개인 진도 화면: 월별 장별 체크박스
bible.html            # 성경 본문 읽기 화면 (helloao.org API)
supabase_setup.sql    # 최초 DB 세팅 (테이블 / RLS / RPC 생성)
supabase_migration.sql# 그룹 기능 마이그레이션 (group_code 컬럼 추가)
seed_plans.sql        # plans 테이블 1,189장 데이터
seed_test_groups.sql  # 그룹별 테스트 사용자 및 완료 기록
generate_seed.py      # seed_plans.sql 재생성 스크립트
```

---

## DB 스키마

```sql
groups  (group_code TEXT PK, plan_set_id INT DEFAULT 1, created_at)
users   (id SERIAL PK, nickname TEXT, group_code TEXT, created_at)
plans   (id SERIAL PK, plan_set_id INT DEFAULT 1, date DATE, book TEXT, chapter_no INT, sort_order INT)
records (id SERIAL PK, user_id INT → users.id, plan_id INT → plans.id,
         completed BOOLEAN, updated_at TIMESTAMPTZ)
```

- `groups` — group_code 를 plan_set_id 에 매핑. 최초 사용자 등록 시 upsert (이미 있으면 plan_set_id 유지)
- `users.nickname` + `users.group_code` 복합 UNIQUE → 그룹 내 닉네임 중복 불가
- `plans.plan_set_id` — 읽기 플랜 구분. 1 = 기본 플랜, 2 = 두 번째 플랜(plans2 데이터)
- `plans.sort_order` — plan_set_id 내에서만 고유하면 됨 (인접 장 탐색에 사용)
- `records` 는 users.id 를 통해 그룹 격리됨
- RLS 정책: 전체 허용 (신뢰 그룹 대상 서비스)

### RPC

```sql
get_stats(p_group_code TEXT)
  → (nickname, completed, planned, rate)
  -- groups 테이블에서 plan_set_id 조회 (없으면 1), 해당 plan_set 기준으로 완독률 계산
```

---

## 그룹 시스템

- URL 파라미터 `?group=그룹코드` 필수
- 없으면 index.html에서 안내 메시지 표시 + 입력 비활성화
- record.html / bible.html은 그룹 없으면 index.html 리디렉션
- 그룹은 사전 등록 불필요 — 첫 사용자 등록 시 groups 테이블에 upsert (plan_set_id 결정)
- `?plan=N` — 그룹 최초 생성 시만 유효. 이미 존재하는 그룹은 기존 plan_set_id 유지
- plan 파라미터 생략 시 plan_set_id = 1 (기본 플랜)

```
index.html?group=제1청장년           ← plan_set_id=1 (기본)
index.html?group=루체채플&plan=2     ← plan_set_id=2 (첫 진입 시에만 적용)
record.html?nickname=홍길동&group=제1청장년
bible.html?nickname=홍길동&plan_id=1&book=창세기&chapter_no=1&sort_order=1&group=제1청장년
```

---

## JS 패턴 (3개 HTML 공통)

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

- 테이블명은 항상 `'users'` / `'plans'` / `'records'` 고정 (T 객체 없음)
- 모든 페이지 이동 시 `groupParam` 을 URL에 append

---

## Supabase 설정 순서

1. `supabase_setup.sql` 실행 (최초 1회)
2. `seed_plans.sql` 실행 (1,189장 데이터, plan_set_id=1)
3. `supabase_migration.sql` 실행 (group_code 컬럼 추가)
4. `supabase_setup2.sql` 실행 (plans2 테이블 생성)
5. `seed_plans2.sql` 실행 (plan_set_id=2 용 데이터)
6. `supabase_migration_plan_set.sql` 실행 (groups 테이블, plans.plan_set_id, plans2→plans 이관, RPC 수정)
7. (선택) `seed_test_groups.sql` 실행 (테스트 데이터)

---

## 배포

GitHub Pages (main 브랜치 root). push 시 자동 배포.
서비스 URL: https://greatacme.github.io/ReadBible2026/

---

## 주의사항

- Supabase anon key 가 HTML에 하드코딩되어 있음 — RLS 정책으로 접근 제어
- 닉네임 기반 로그인이므로 타인 닉네임 입력 시 해당 사용자로 접근 가능 (신뢰 그룹 전제)
- plans 테이블은 그룹 공용이므로 그룹별로 다른 읽기 일정이 필요하다면 스키마 변경 필요
