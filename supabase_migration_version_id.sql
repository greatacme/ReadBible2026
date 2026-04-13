-- 마이그레이션: version_id를 SAENEW에서 RNKSV로 변경
-- SELECT-INSERT 방식으로 안전하게 데이터 이전

-- 1. version 테이블 마이그레이션
INSERT INTO version (version_id, name)
SELECT 'RNKSV', name FROM version WHERE version_id = 'SAENEW'
ON CONFLICT (version_id) DO NOTHING;

-- 2. section_heading 테이블 마이그레이션
INSERT INTO section_heading (version_id, book_id, chapter, heading_title)
SELECT 'RNKSV', book_id, chapter, heading_title
FROM section_heading
WHERE version_id = 'SAENEW';

-- 3. verse 테이블 마이그레이션 (데이터량 많음)
INSERT INTO verse (version_id, book_id, chapter, verse, text)
SELECT 'RNKSV', book_id, chapter, verse, text
FROM verse
WHERE version_id = 'SAENEW';

-- 4. footnote 테이블 마이그레이션
INSERT INTO footnote (version_id, book_id, chapter, verse, footnote_text)
SELECT 'RNKSV', book_id, chapter, verse, footnote_text
FROM footnote
WHERE version_id = 'SAENEW';

-- 5. 기존 SAENEW 데이터 삭제
DELETE FROM footnote WHERE version_id = 'SAENEW';
DELETE FROM verse WHERE version_id = 'SAENEW';
DELETE FROM section_heading WHERE version_id = 'SAENEW';
DELETE FROM version WHERE version_id = 'SAENEW';
