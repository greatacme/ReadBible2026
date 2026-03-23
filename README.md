# ReadBible2026

2026 연세대학교회 성경통독 진도 관리 웹앱

---

## 서비스 URL

**https://greatacme.github.io/ReadBible2026/**

---

## 개요

성경통독 계획을 저장하고 개인별 읽기 실적을 관리한다.
별명 기반 로그인으로 누구나 간편하게 참여하고, 전체 참여자의 완료율을 한눈에 확인할 수 있다.

---

## 기능 상세

### 성경 읽기 계획
- 2026년 4월 5일 ~ 12월 25일 (216일)
- 창세기 ~ 요한계시록 **총 1,189장**을 일자별 배분 (하루 평균 4~5장)
- 하루 계획은 장(chapter) 단위로 분리되어 **1장씩 개별 체크** 가능

### 읽기 실적 관리
- 장별 체크박스로 완료 여부 표시 → **즉시 자동 저장**
- 완료율 = 오늘까지의 계획 장수 대비 완료 장수 (%)
- 계획보다 앞서 읽으면 **100% 초과** 가능

### 사용자 관리
- **암호 없이 별명으로 로그인** (최초 입력 시 자동 등록)
- 복수 사용자 지원

### 화면 구성

**첫 화면**
- 전체 참여자 완료율 순위 목록
- 완료율 TOP 10 가로 막대 그래프 (Chart.js)
- 하단 별명 입력 → "기록" 버튼으로 개인 기록 화면 이동

**기록 화면**
- 월별 접기/펼치기 구조
- 첫 진입 시 **최초 미완료 장이 속한 달을 자동으로 펼치고 해당 행으로 스크롤**
- 날짜별 그룹 표시 (완료된 날짜는 초록색)
- 장별 체크박스 → 체크 즉시 저장, 헤더에 "저장됨 ✓" 표시
- 완료율 실시간 업데이트

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
  index.html  ─────┐
  record.html ──────┼──── Supabase JS SDK ──── Supabase PostgreSQL
                   │         (REST API)
                   └── Chart.js (TOP10 그래프)
```

별도 백엔드 서버 없이 브라우저에서 Supabase에 직접 접근한다.

---

## DB 구조

```sql
users   (id, nickname, created_at)
plans   (id, date, book, chapter_no, sort_order)
records (id, user_id, plan_id, completed, updated_at)
```

- `plans.sort_order` : 전체 장의 읽기 순서 (창세기 1장 = 1, 요한계시록 22장 = 1189)
- `records` : user_id + plan_id 조합 UNIQUE → upsert로 중복 없이 관리

---

## Supabase 설정

### 테이블 / RLS / RPC 생성
Supabase SQL Editor에서 실행:
```
supabase_setup.sql
```

### 성경 계획 데이터 입력
Supabase SQL Editor에서 실행:
```
seed_plans.sql   (1,189장 INSERT)
```

### seed_plans.sql 재생성
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
