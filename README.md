# ReadBible2026

2026 성경통독 진도 관리 웹앱

---

## 서비스 URL

**https://greatacme.github.io/ReadBible2026/**

그룹 링크 형식:
```
https://greatacme.github.io/ReadBible2026/index.html?group=그룹코드
```

---

## 개요

성경통독 계획을 저장하고 개인별 읽기 실적을 그룹 단위로 관리한다.
별명 기반 로그인으로 누구나 간편하게 참여하고, 같은 그룹 내 참여자의 완료율을 한눈에 확인할 수 있다.

---

## 기능

### 그룹 시스템
- 홈 화면(`home.html`)에서 그룹 목록 확인 및 신규 그룹 생성
- URL의 `?group=그룹코드` 파라미터로 그룹 구분
- 그룹 간 데이터 완전 격리 (리더보드, 진도 모두 그룹 내에서만 공유)
- 그룹별 읽기 플랜 분리 (`plan_set_id` 1/2/3)

### 성경 읽기 계획
- 2026년 1,189장 (창세기 ~ 요한계시록) 일자별 배분
- 그룹별로 다른 플랜 적용 가능 (하루 평균 4~5장)
- 장별 개별 체크 가능

### 읽기 실적 관리
- 장별 체크박스 완료 표시 → 즉시 자동 저장
- 완료율 = 오늘까지의 계획 장수 대비 완료 장수 (%)
- 계획보다 앞서 읽으면 100% 초과 가능

### 사용자 관리
- 암호 없이 별명으로 로그인 (최초 입력 시 자동 등록)
- 같은 별명이어도 그룹이 다르면 별개 계정
- 프로필 편집: 닉네임 변경, 그룹 이동 (기록 이전 포함), 계정 삭제

### 화면 구성

**홈 화면** (`home.html`)
- 전체 그룹 목록 (자연 정렬)
- 신규 그룹 생성 (그룹명 + 플랜 선택)

**그룹 메인** (`index.html?group=...`)
- 참여자 완독률 순위 목록
- 완독률 TOP N 가로 막대 그래프 (N: 3/5/10 선택)
- 별명 입력 → 기록 버튼으로 개인 기록 화면 이동

**기록 화면** (`record.html?nickname=...&group=...`)
- 월별 접기/펼치기 구조
- 첫 진입 시 최초 미완료 장 자동 스크롤
- 날짜별 장 목록, 완료 날짜는 초록색 표시
- 장별 체크박스 → 체크 즉시 저장

**성경 읽기 화면** (`bible.html?...&group=...`)
- 장 본문 표시 (helloao.org API 또는 Supabase verse 테이블)
- 헤더에 플랜 날짜(월/일(요일)) 표시
- 끝까지 스크롤 시 자동 완료 체크
- 이전/다음 장 이동

**프로필 편집** (`edit.html?nickname=...&group=...`)
- 닉네임 변경
- 그룹 이동 (플랜이 다를 경우 기록 이전/삭제 선택)
- 계정 삭제

**그룹 편집** (`group-edit.html?group=...`)
- 그룹명 변경 (저장 시 링크 자동 복사)
- 그룹 삭제 (사용자 있을 시 차단)

---

## 기술 스택

| 역할 | 기술 |
|------|------|
| 프론트엔드 | HTML / Vanilla JS |
| 스타일 | Tailwind CSS (CDN) |
| 차트 | Chart.js (CDN) |
| 데이터베이스 | Supabase (PostgreSQL) |
| 호스팅 | GitHub Pages |

---

## 아키텍처

```
브라우저 (GitHub Pages)
  home.html       ──┐
  index.html      ──┤
  record.html     ──┼── Supabase JS SDK (REST API) ── Supabase PostgreSQL
  bible.html      ──┤
  edit.html       ──┤
  group-edit.html ──┘
```

별도 백엔드 서버 없이 브라우저에서 Supabase에 직접 접근.

---

## DB 구조

```sql
groups  (group_code TEXT PK, plan_set_id INT, version_id INT, created_at)
users   (id, nickname, group_code, created_at)
plans   (id, plan_set_id, date, book, chapter_no, sort_order)
records (id, user_id, plan_id, completed, updated_at)
book    (book_id, name_ko, ...)
verse   (version_id, book_id, chapter, verse, text)
```

- `groups.plan_set_id` — 그룹별 읽기 플랜 구분 (1/2/3)
- `groups.version_id` — NULL이면 외부 API, 값이 있으면 내부 DB에서 본문 로드
- `users.nickname` + `users.group_code` 복합 UNIQUE
- `records`는 `users.id`를 통해 그룹별 격리
- RPC `get_stats(p_group_code)` — 그룹 필터링된 완독률, KST 기준 날짜, 완료 시점순 정렬

---

## Supabase 설정

Supabase SQL Editor에서 순서대로 실행:

```
1. supabase_setup.sql                    테이블 / RLS / RPC 생성
2. seed_plans.sql                        1,189장 계획 (plan_set_id=1)
3. supabase_migration.sql                group_code 컬럼 추가
4. supabase_migration_plan_set.sql       groups 테이블, plan_set_id, RPC 수정
5. seed_plans2.sql                       1,189장 계획 (plan_set_id=2)
6. seed_plans3.sql                       1,189장 계획 (plan_set_id=3)
7. supabase_migration_get_stats_order.sql KST 날짜 + 완료 시점 정렬 적용
```

테스트 데이터:
```
seed_test_groups.sql    그룹별 샘플 사용자 및 완료 기록
```

---

## GitHub Pages 배포

1. 저장소 **Settings → Pages**
2. Source: `Deploy from a branch` / Branch: `main` / Folder: `/ (root)`
3. push 시 자동 배포

---

## 변경 이력

[CHANGELOG.md](CHANGELOG.md) 참조

---

## Supabase 무료 티어 제한

| 항목 | 제한 | 영향 |
|------|------|------|
| DB 용량 | 500MB | 문제 없음 (수 MB 수준) |
| 비활성 정지 | 7일 무접속 시 | 매일 사용하므로 해당 없음 |
| 동시 접속 | 제한 없음 | 문제 없음 |
