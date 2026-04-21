# 다음 작업 - Ministry 계층 완성

## 현재 상태
- ✅ 프론트엔드: ministry 완전 분리 (로컬에서 작동 확인)
- ✅ DB: users UNIQUE 제약 변경 완료 (nickname, group_code, ministry_cd)
- ⏳ RPC: get_stats_tmp() 사용 중 (테스트 단계)

---

## 다음 작업 순서

### 1단계: get_stats() 함수 교체
**파일:** `supabase_migration_get_stats_ministry.sql`

```sql
-- Supabase SQL Editor에서 실행
CREATE OR REPLACE FUNCTION get_stats(p_group_code TEXT, p_ministry_cd TEXT DEFAULT '0')
...
```

**확인:** 
- Supabase에서 함수 생성 완료
- 테스트: `SELECT * FROM get_stats('제1청장년', '0');`

### 2단계: index.html 수정
**파일:** `index.html` 라인 103

```javascript
// 변경 전
sb.rpc('get_stats_tmp', { p_group_code: groupCode, p_ministry_cd: ministryCode })

// 변경 후
sb.rpc('get_stats', { p_group_code: groupCode, p_ministry_cd: ministryCode })
```

### 3단계: plan_set_id 컬럼 삭제
**새 파일:** `supabase_migration_drop_plan_set_id.sql` 생성 후 실행

```sql
-- Supabase SQL Editor에서 실행
DROP INDEX IF EXISTS public.idx_plans_plan_set;
ALTER TABLE public.groups DROP COLUMN plan_set_id;
ALTER TABLE public.plans DROP COLUMN plan_set_id;
```

### 4단계: get_stats_tmp() 함수 삭제
**파일:** `supabase_migration_ministry.sql` 수정

```sql
-- 아래 함수 제거
CREATE OR REPLACE FUNCTION get_stats_tmp(...)
```

---

## 배포 타이밍
- 로컬 테스트: ✅ 완료
- GitHub Pages 배포: 🎯 예정 (서버 배포 전)
- Supabase 마이그레이션: 🎯 예정 (HTML 배포 후)

---

## 체크리스트
- [ ] get_stats() 함수 Supabase 생성
- [ ] index.html get_stats_tmp() → get_stats() 변경
- [ ] 로컬 테스트 재확인
- [ ] GitHub Pages 배포 (git push)
- [ ] plan_set_id 컬럼 삭제
- [ ] get_stats_tmp() 함수 삭제

---

## 참고
- ministry 기본값: '0'
- plan_set_cd 기본값: '1' (문자열)
- 모든 쿼리에서 ministry_cd 필터링 완료
- RLS 정책: 신뢰 그룹 대상이므로 전체 허용 유지
