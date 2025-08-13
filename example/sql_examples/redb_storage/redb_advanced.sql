-- Redb Storage Advanced SQL
-- Generated from 07_redb_demo

-- Redb의 트랜잭션 기능 테스트

-- 사용자 설정 테이블 추가
CREATE TABLE user_preferences (
    user_id INTEGER,
    preference_key TEXT,
    preference_value TEXT,
    updated_at TEXT
);

-- 트랜잭션을 통한 일관성 있는 데이터 업데이트
BEGIN;

-- 새 사용자 추가
INSERT INTO users VALUES
    (6, 'frank', 'frank@example.com', '2024-01-12 10:00:00', true);

-- 해당 사용자의 기본 설정 추가
INSERT INTO user_preferences VALUES
    (6, 'theme', 'dark', '2024-01-12 10:00:00'),
    (6, 'language', 'ko', '2024-01-12 10:00:00'),
    (6, 'notifications', 'true', '2024-01-12 10:00:00');

-- 첫 로그인 세션 생성
INSERT INTO user_sessions VALUES
    ('sess_009', 6, '2024-01-12 10:05:00', '192.168.1.105', 'Chrome/91.0');

COMMIT;

SELECT '=== 트랜잭션 후 새 사용자 확인 ===' as info;
SELECT
    u.username,
    u.email,
    u.created_at,
    COUNT(p.preference_key) as preference_count,
    COUNT(s.session_id) as session_count
FROM users u
LEFT JOIN user_preferences p ON u.id = p.user_id
LEFT JOIN user_sessions s ON u.id = s.user_id
WHERE u.id = 6
GROUP BY u.id, u.username, u.email, u.created_at;

-- 사용자별 설정 조회
SELECT '=== 사용자 설정 현황 ===' as info;
SELECT
    u.username,
    p.preference_key,
    p.preference_value,
    p.updated_at
FROM users u
JOIN user_preferences p ON u.id = p.user_id
ORDER BY u.username, p.preference_key;

-- 일일 활동 통계
SELECT '=== 일일 로그인 통계 ===' as info;
SELECT
    DATE(s.login_time) as login_date,
    COUNT(DISTINCT s.user_id) as unique_users,
    COUNT(s.session_id) as total_sessions,
    COUNT(DISTINCT s.ip_address) as unique_ips
FROM user_sessions s
GROUP BY DATE(s.login_time)
ORDER BY login_date;

-- 브라우저 사용 통계
SELECT '=== 브라우저 사용 현황 ===' as info;
SELECT
    CASE
        WHEN user_agent LIKE '%Chrome%' THEN 'Chrome'
        WHEN user_agent LIKE '%Firefox%' THEN 'Firefox'
        WHEN user_agent LIKE '%Safari%' THEN 'Safari'
        WHEN user_agent LIKE '%Edge%' THEN 'Edge'
        WHEN user_agent LIKE '%Mozilla%' THEN 'Mozilla'
        ELSE 'Other'
    END as browser,
    COUNT(*) as session_count,
    COUNT(DISTINCT user_id) as unique_users
FROM user_sessions
GROUP BY
    CASE
        WHEN user_agent LIKE '%Chrome%' THEN 'Chrome'
        WHEN user_agent LIKE '%Firefox%' THEN 'Firefox'
        WHEN user_agent LIKE '%Safari%' THEN 'Safari'
        WHEN user_agent LIKE '%Edge%' THEN 'Edge'
        WHEN user_agent LIKE '%Mozilla%' THEN 'Mozilla'
        ELSE 'Other'
    END
ORDER BY session_count DESC;
