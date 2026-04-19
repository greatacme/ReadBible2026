# ReadBible2026 변경 이력

버전 체계: `ver.major.minor.yyyy.mmdd`
- major: 사용자 요청 시만 변경
- minor: 기능 추가/개선 배포마다 +1 (오류 수정은 유지)
- yyyy.mmdd: 배포 당일 날짜

---

## ver.3.4.2026.0419
- fix: 문자 인코딩 문제 예방 (한글 깨짐 현상 방지)
  - 모든 입력 폼에 accept-charset="UTF-8" 추가
  - 입력값 정규화 함수 추가 (한글, 영문, 숫자, 공백, 기호만 허용)

## ver.3.4.2026.0414
- feat: plan_set_id=3 읽기 일정 추가 (2026-02-09 ~ 2026-11-26, 1,189장)
- feat: RNKSV(새번역) 성경 버전 지원 추가
  - Supabase verse 테이블에서 로드
  - 마이그레이션: supabase_migration_version_id.sql (SAENEW → RNKSV)
- refactor: 성경 버전 분기 로직 개선
  - KLB: YouVersion API (현대인의 성경)
  - KJV: helloao.org API (개역한글)
  - 그 외: Supabase verse 테이블

## ver.3.3.2026.0413
- chore: 성경 버전 기본값을 개역한글(KJV)로 변경
- chore: groups 테이블 version_id 사용 제거 (groups.version_id 컬럼 삭제 가능)
- fix: 그룹 편집 화면에서 성경 버전 편집 기능 제거

## ver.3.2.2026.0413
- feat: 사용자별 성경 버전 설정 기능 추가
  - edit.html: 프로필 편집 페이지에 성경 버전 선택 필드 추가 (KLB/KJV)
  - users.bible_ver_cd 컬럼 참조 (groups.version_id 대신)
  - KLB: YouVersion API (현대인의 성경)
  - KJV: helloao.org API (개역한글)
  - 신규 사용자 기본값: KLB

## ver.3.1.2026.0413
- feat: YouVersion Platform API를 통한 KLB(Korean Living Bible) 지원 추가
  - bible.html: version_id = 'KLB' 설정 시 YouVersion API에서 KLB 본문 로드
  - youversion-proxy: Supabase Edge Functions로 CORS 프록시 구현
  - 로컬 개발: 로컬 Node.js 프록시 서버 지원
  - 절 단위 파싱: HTML format 활용으로 1회 API 요청만 사용 (빠른 로드)

## ver.2.9.2026.0408
- bible.html: 헤더 플랜 날짜를 맨 우측 끝으로 이동

## ver.2.8.2026.0408
- bible.html: 헤더 우측에 플랜 날짜(월/일(요일)) 표시 추가

## ver.2.7.2026.0406
- group-edit.html: 그룹 삭제 버튼 추가 (사용자 있을 시 삭제 차단)

## ver.2.6.2026.0406
- edit.html: 그룹 변경 입력을 콤보박스 선택으로 변경
- get_stats RPC: 날짜 기준 UTC → KST(Asia/Seoul) 자정 기준으로 변경
- get_stats RPC: 동률 정렬 기준 → 최초 완료 시점(MAX updated_at WHERE completed) ASC

## ver.2.5.2026.0406
- index.html: TOP 콤보박스 폰트를 완독률 헤더와 동일하게 조정

## ver.2.4.2026.0406
- index.html: 완독률 차트 TOP 인원 선택 콤보박스 추가 (3/5/10명, 기본 5명)

## ver.2.3.2026.0406
- home.html: 타이틀에 연세대학교회 추가

## ver.2.2.2026.0406
- 버전 체계 변경: yyyy.mmdd.일련번호 → major.minor.yyyy.mmdd
- home.html: 버전 정보 우측 하단 표시 추가

## ver.2.1.2026.0406 (구 ver.2026.0426.1)
- home.html: 신규 그룹 생성 버튼을 헤더 우측으로 이동
- index.html: 그룹/플랜 표시 형식 변경 (`그룹명 group`)
- index.html: 그룹편집·공유 버튼 헤더 우측 정렬
- index.html: 공유 버튼 클릭 시 URL 복사 + "복사됨!" 2초 표시
- group-edit.html: 저장 후 링크 자동 복사 + 확인 팝업 표시
- index.html: 존재하지 않는 그룹 접근 시 home.html 리디렉션

## ver.2.0.2026.0406
- home.html: 그룹 목록 화면 신규 추가 (그룹 버튼 목록 + 신규 생성 모달)
- group-edit.html: 그룹 편집 화면 신규 추가 (그룹명 변경)
- edit.html: 프로필 편집 화면 추가 (닉네임/그룹 변경, 기록 이전, 계정 삭제)
- record.html: 헤더에 편집 버튼 추가
- index.html: 신규 사용자 등록 확인 절차 추가

---

## 이전 버전 (버전 관리 이전)

- bible.html: 성경 본문 소스 분기 (version_id 기반 DB/API 선택)
- bible.html: 전각 역슬래시(＼) 개행 처리, verse 주석 영문자 제거
- index.html: 그룹/플랜 텍스트 영어로 변경, 글자 크기 확대
- index.html: 그룹별 플랜(plan_set_id) 분리 지원
- index.html: 완독률 TOP 10 차트 추가
- bible.html: 스크롤 끝까지 내리면 읽기 완료 자동 처리
- bible.html: 이전/다음 장 이동 버튼 추가
- 초기 출시: 리더보드, 닉네임 로그인, 개인 진도 화면, 성경 읽기 화면
