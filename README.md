# ReadBible2026

2026 성경통독 진도 관리 웹앱

---

## 서비스 URL

**https://greatacme.github.io/ReadBible2026/**

접속 시 반드시 그룹 코드 포함:
```
https://greatacme.github.io/ReadBible2026/?group=그룹코드
```

---

## 개요

성경통독 계획을 저장하고 개인별 읽기 실적을 그룹 단위로 관리한다.
별명 기반 로그인으로 누구나 간편하게 참여하고, 같은 그룹 내 참여자의 완료율을 한눈에 확인할 수 있다.

---

## 기능

### 그룹 시스템
- URL의 `?group=그룹코드` 파라미터로 그룹 구분
- 그룹 사전 등록 불필요 — 새 그룹 코드로 접속하면 자동 생성
- 그룹 간 데이터 완전 격리 (리더보드, 진도 모두 그룹 내에서만 공유)

### 성경 읽기 계획
- 2026년 4월 5일 ~ 12월 25일 (216일)
- 창세기 ~ 요한계시록 **총 1,189장**을 일자별 배분 (하루 평균 4~5장)
- 1장씩 개별 체크 가능

### 읽기 실적 관리
- 장별 체크박스 완료 표시 → **즉시 자동 저장**
- 완료율 = 오늘까지의 계획 장수 대비 완료 장수 (%)
- 계획보다 앞서 읽으면 **100% 초과** 가능

### 사용자 관리
- **암호 없이 별명으로 로그인** (최초 입력 시 자동 등록)
- 같은 별명이어도 그룹이 다르면 별개 계정

### 화면 구성

**첫 화면** (`index.html?group=...`)
- 해당 그룹 참여자 완료율 순위 목록
- 완료율 TOP 10 가로 막대 그래프 (Chart.js)
- 별명 입력 → "기록" 버튼으로 개인 기록 화면 이동

**기록 화면** (`record.html?nickname=...&group=...`)
- 월별 접기/펼치기 구조
- 첫 진입 시 최초 미완료 장이 속한 달 자동 펼침 + 해당 행 스크롤
- 날짜별 그룹 표시 (완료된 날짜는 초록색)
- 장별 체크박스 → 체크 즉시 저장

**성경 읽기 화면** (`bible.html?...&group=...`)
- 장 본문 표시 (helloao.org API)
- 끝까지 스크롤 시 자동 완료 체크
- 이전 / 다음 장 이동

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
  index.html  ──┐
  record.html ──┼── Supabase JS SDK (REST API) ── Supabase PostgreSQL
  bible.html  ──┘
```

별도 백엔드 서버 없이 브라우저에서 Supabase에 직접 접근.

---

## DB 구조

```sql
users   (id, nickname, group_code, created_at)
plans   (id, date, book, chapter_no, sort_order)
records (id, user_id, plan_id, completed, updated_at)
```

- `users.nickname` + `users.group_code` 복합 UNIQUE → 그룹 내 닉네임 중복 불가
- `plans` 는 모든 그룹 공용
- `records` 는 `users.id` 를 통해 그룹별 격리
- RPC `get_stats(p_group_code)` : 그룹 필터링된 완독률 반환

---

## Supabase 설정

Supabase SQL Editor에서 순서대로 실행:

```
1. supabase_setup.sql       테이블 / RLS / RPC 생성
2. seed_plans.sql           1,189장 계획 데이터 입력
3. supabase_migration.sql   그룹 기능 적용 (group_code 컬럼 추가)
```

테스트 데이터가 필요한 경우:
```
4. seed_test_groups.sql     그룹별 샘플 사용자 및 완료 기록
```

seed_plans.sql 재생성:
```bash
python3 generate_seed.py
```

---

## GitHub Pages 배포

1. 저장소 **Settings → Pages**
2. Source: `Deploy from a branch` / Branch: `main` / Folder: `/ (root)`
3. push 시 자동 배포

---

## Supabase 무료 티어 제한

| 항목 | 제한 | 영향 |
|------|------|------|
| DB 용량 | 500MB | 문제 없음 (수 MB 수준) |
| 비활성 정지 | 7일 무접속 시 | 매일 사용하므로 해당 없음 |
| 동시 접속 | 제한 없음 | 문제 없음 |
