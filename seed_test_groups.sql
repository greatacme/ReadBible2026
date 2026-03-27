-- ============================================================
-- 그룹별 테스트 데이터
-- 그룹: 0, 1, alpha, 제1청장년, B
-- ============================================================

-- 기존 테스트 데이터 초기화 (필요 시 주석 해제)
-- DELETE FROM records;
-- DELETE FROM users;

-- ============================================================
-- 사용자 등록
-- ============================================================
INSERT INTO users (nickname, group_code) VALUES
  -- 그룹 0 (5명)
  ('김말씀',   '0'),
  ('이은혜',   '0'),
  ('박기도',   '0'),
  ('최찬양',   '0'),
  ('정성령',   '0'),

  -- 그룹 1 (5명)
  ('한믿음',   '1'),
  ('오소망',   '1'),
  ('강사랑',   '1'),
  ('윤평화',   '1'),
  ('임충성',   '1'),

  -- 그룹 alpha (4명)
  ('James',    'alpha'),
  ('Sarah',    'alpha'),
  ('Michael',  'alpha'),
  ('Grace',    'alpha'),

  -- 그룹 제1청장년 (5명)
  ('홍길동',   '제1청장년'),
  ('조은별',   '제1청장년'),
  ('신아침',   '제1청장년'),
  ('류하늘',   '제1청장년'),
  ('문진리',   '제1청장년'),

  -- 그룹 B (4명)
  ('이새벽',   'B'),
  ('박통독',   'B'),
  ('김완독',   'B'),
  ('장열심',   'B')
ON CONFLICT (nickname, group_code) DO NOTHING;

-- ============================================================
-- 완료 기록 (plans 테이블 sort_order 기준으로 앞에서 N장 완료)
-- ============================================================

-- 그룹 0
-- 김말씀: 120장 완료 (열심)
INSERT INTO records (user_id, plan_id, completed, updated_at)
SELECT u.id, p.id, true, NOW()
FROM users u
CROSS JOIN (SELECT id FROM plans ORDER BY sort_order LIMIT 120) p
WHERE u.nickname = '김말씀' AND u.group_code = '0'
ON CONFLICT (user_id, plan_id) DO NOTHING;

-- 이은혜: 85장 완료
INSERT INTO records (user_id, plan_id, completed, updated_at)
SELECT u.id, p.id, true, NOW()
FROM users u
CROSS JOIN (SELECT id FROM plans ORDER BY sort_order LIMIT 85) p
WHERE u.nickname = '이은혜' AND u.group_code = '0'
ON CONFLICT (user_id, plan_id) DO NOTHING;

-- 박기도: 60장 완료
INSERT INTO records (user_id, plan_id, completed, updated_at)
SELECT u.id, p.id, true, NOW()
FROM users u
CROSS JOIN (SELECT id FROM plans ORDER BY sort_order LIMIT 60) p
WHERE u.nickname = '박기도' AND u.group_code = '0'
ON CONFLICT (user_id, plan_id) DO NOTHING;

-- 최찬양: 40장 완료
INSERT INTO records (user_id, plan_id, completed, updated_at)
SELECT u.id, p.id, true, NOW()
FROM users u
CROSS JOIN (SELECT id FROM plans ORDER BY sort_order LIMIT 40) p
WHERE u.nickname = '최찬양' AND u.group_code = '0'
ON CONFLICT (user_id, plan_id) DO NOTHING;

-- 정성령: 15장 완료 (방금 시작)
INSERT INTO records (user_id, plan_id, completed, updated_at)
SELECT u.id, p.id, true, NOW()
FROM users u
CROSS JOIN (SELECT id FROM plans ORDER BY sort_order LIMIT 15) p
WHERE u.nickname = '정성령' AND u.group_code = '0'
ON CONFLICT (user_id, plan_id) DO NOTHING;


-- 그룹 1
-- 한믿음: 100장 완료
INSERT INTO records (user_id, plan_id, completed, updated_at)
SELECT u.id, p.id, true, NOW()
FROM users u
CROSS JOIN (SELECT id FROM plans ORDER BY sort_order LIMIT 100) p
WHERE u.nickname = '한믿음' AND u.group_code = '1'
ON CONFLICT (user_id, plan_id) DO NOTHING;

-- 오소망: 75장 완료
INSERT INTO records (user_id, plan_id, completed, updated_at)
SELECT u.id, p.id, true, NOW()
FROM users u
CROSS JOIN (SELECT id FROM plans ORDER BY sort_order LIMIT 75) p
WHERE u.nickname = '오소망' AND u.group_code = '1'
ON CONFLICT (user_id, plan_id) DO NOTHING;

-- 강사랑: 55장 완료
INSERT INTO records (user_id, plan_id, completed, updated_at)
SELECT u.id, p.id, true, NOW()
FROM users u
CROSS JOIN (SELECT id FROM plans ORDER BY sort_order LIMIT 55) p
WHERE u.nickname = '강사랑' AND u.group_code = '1'
ON CONFLICT (user_id, plan_id) DO NOTHING;

-- 윤평화: 30장 완료
INSERT INTO records (user_id, plan_id, completed, updated_at)
SELECT u.id, p.id, true, NOW()
FROM users u
CROSS JOIN (SELECT id FROM plans ORDER BY sort_order LIMIT 30) p
WHERE u.nickname = '윤평화' AND u.group_code = '1'
ON CONFLICT (user_id, plan_id) DO NOTHING;

-- 임충성: 10장 완료
INSERT INTO records (user_id, plan_id, completed, updated_at)
SELECT u.id, p.id, true, NOW()
FROM users u
CROSS JOIN (SELECT id FROM plans ORDER BY sort_order LIMIT 10) p
WHERE u.nickname = '임충성' AND u.group_code = '1'
ON CONFLICT (user_id, plan_id) DO NOTHING;


-- 그룹 alpha
-- James: 110장 완료
INSERT INTO records (user_id, plan_id, completed, updated_at)
SELECT u.id, p.id, true, NOW()
FROM users u
CROSS JOIN (SELECT id FROM plans ORDER BY sort_order LIMIT 110) p
WHERE u.nickname = 'James' AND u.group_code = 'alpha'
ON CONFLICT (user_id, plan_id) DO NOTHING;

-- Sarah: 90장 완료
INSERT INTO records (user_id, plan_id, completed, updated_at)
SELECT u.id, p.id, true, NOW()
FROM users u
CROSS JOIN (SELECT id FROM plans ORDER BY sort_order LIMIT 90) p
WHERE u.nickname = 'Sarah' AND u.group_code = 'alpha'
ON CONFLICT (user_id, plan_id) DO NOTHING;

-- Michael: 45장 완료
INSERT INTO records (user_id, plan_id, completed, updated_at)
SELECT u.id, p.id, true, NOW()
FROM users u
CROSS JOIN (SELECT id FROM plans ORDER BY sort_order LIMIT 45) p
WHERE u.nickname = 'Michael' AND u.group_code = 'alpha'
ON CONFLICT (user_id, plan_id) DO NOTHING;

-- Grace: 20장 완료
INSERT INTO records (user_id, plan_id, completed, updated_at)
SELECT u.id, p.id, true, NOW()
FROM users u
CROSS JOIN (SELECT id FROM plans ORDER BY sort_order LIMIT 20) p
WHERE u.nickname = 'Grace' AND u.group_code = 'alpha'
ON CONFLICT (user_id, plan_id) DO NOTHING;


-- 그룹 제1청장년
-- 홍길동: 130장 완료
INSERT INTO records (user_id, plan_id, completed, updated_at)
SELECT u.id, p.id, true, NOW()
FROM users u
CROSS JOIN (SELECT id FROM plans ORDER BY sort_order LIMIT 130) p
WHERE u.nickname = '홍길동' AND u.group_code = '제1청장년'
ON CONFLICT (user_id, plan_id) DO NOTHING;

-- 조은별: 95장 완료
INSERT INTO records (user_id, plan_id, completed, updated_at)
SELECT u.id, p.id, true, NOW()
FROM users u
CROSS JOIN (SELECT id FROM plans ORDER BY sort_order LIMIT 95) p
WHERE u.nickname = '조은별' AND u.group_code = '제1청장년'
ON CONFLICT (user_id, plan_id) DO NOTHING;

-- 신아침: 70장 완료
INSERT INTO records (user_id, plan_id, completed, updated_at)
SELECT u.id, p.id, true, NOW()
FROM users u
CROSS JOIN (SELECT id FROM plans ORDER BY sort_order LIMIT 70) p
WHERE u.nickname = '신아침' AND u.group_code = '제1청장년'
ON CONFLICT (user_id, plan_id) DO NOTHING;

-- 류하늘: 50장 완료
INSERT INTO records (user_id, plan_id, completed, updated_at)
SELECT u.id, p.id, true, NOW()
FROM users u
CROSS JOIN (SELECT id FROM plans ORDER BY sort_order LIMIT 50) p
WHERE u.nickname = '류하늘' AND u.group_code = '제1청장년'
ON CONFLICT (user_id, plan_id) DO NOTHING;

-- 문진리: 5장 완료 (시작 단계)
INSERT INTO records (user_id, plan_id, completed, updated_at)
SELECT u.id, p.id, true, NOW()
FROM users u
CROSS JOIN (SELECT id FROM plans ORDER BY sort_order LIMIT 5) p
WHERE u.nickname = '문진리' AND u.group_code = '제1청장년'
ON CONFLICT (user_id, plan_id) DO NOTHING;


-- 그룹 B
-- 이새벽: 115장 완료
INSERT INTO records (user_id, plan_id, completed, updated_at)
SELECT u.id, p.id, true, NOW()
FROM users u
CROSS JOIN (SELECT id FROM plans ORDER BY sort_order LIMIT 115) p
WHERE u.nickname = '이새벽' AND u.group_code = 'B'
ON CONFLICT (user_id, plan_id) DO NOTHING;

-- 박통독: 80장 완료
INSERT INTO records (user_id, plan_id, completed, updated_at)
SELECT u.id, p.id, true, NOW()
FROM users u
CROSS JOIN (SELECT id FROM plans ORDER BY sort_order LIMIT 80) p
WHERE u.nickname = '박통독' AND u.group_code = 'B'
ON CONFLICT (user_id, plan_id) DO NOTHING;

-- 김완독: 35장 완료
INSERT INTO records (user_id, plan_id, completed, updated_at)
SELECT u.id, p.id, true, NOW()
FROM users u
CROSS JOIN (SELECT id FROM plans ORDER BY sort_order LIMIT 35) p
WHERE u.nickname = '김완독' AND u.group_code = 'B'
ON CONFLICT (user_id, plan_id) DO NOTHING;

-- 장열심: 25장 완료
INSERT INTO records (user_id, plan_id, completed, updated_at)
SELECT u.id, p.id, true, NOW()
FROM users u
CROSS JOIN (SELECT id FROM plans ORDER BY sort_order LIMIT 25) p
WHERE u.nickname = '장열심' AND u.group_code = 'B'
ON CONFLICT (user_id, plan_id) DO NOTHING;
