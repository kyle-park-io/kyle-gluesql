-- Redb Storage Basic SQL
-- Generated from 07_redb_demo

-- Redb Storage는 단일 파일에 모든 데이터를 저장하는 임베디드 데이터베이스입니다

-- 사용자 테이블 생성
CREATE TABLE users (
    id INTEGER,
    username TEXT,
    email TEXT,
    created_at TEXT,
    is_active BOOLEAN
);

-- 세션 테이블 생성
CREATE TABLE user_sessions (
    session_id TEXT,
    user_id INTEGER,
    login_time TEXT,
    ip_address TEXT,
    user_agent TEXT
);

-- 기본 데이터 삽입
INSERT INTO users VALUES
    (1, 'alice', 'alice@example.com', '2024-01-01 10:00:00', true),
    (2, 'bob', 'bob@example.com', '2024-01-02 11:30:00', true),
    (3, 'charlie', 'charlie@example.com', '2024-01-03 09:15:00', false),
    (4, 'diana', 'diana@example.com', '2024-01-04 14:20:00', true),
    (5, 'eve', 'eve@example.com', '2024-01-05 16:45:00', true);

INSERT INTO user_sessions VALUES
    ('sess_001', 1, '2024-01-10 09:00:00', '192.168.1.100', 'Mozilla/5.0'),
    ('sess_002', 2, '2024-01-10 09:15:00', '192.168.1.101', 'Chrome/91.0'),
    ('sess_003', 1, '2024-01-10 14:30:00', '192.168.1.100', 'Mozilla/5.0'),
    ('sess_004', 4, '2024-01-10 10:45:00', '192.168.1.102', 'Safari/14.0'),
    ('sess_005', 2, '2024-01-11 08:20:00', '192.168.1.101', 'Chrome/91.0'),
    ('sess_006', 5, '2024-01-11 11:10:00', '192.168.1.103', 'Firefox/89.0'),
    ('sess_007', 1, '2024-01-11 15:30:00', '192.168.1.104', 'Edge/91.0'),
    ('sess_008', 4, '2024-01-11 13:45:00', '192.168.1.102', 'Safari/14.0');

SELECT '=== 사용자 목록 ===' as info;
SELECT * FROM users ORDER BY id;

SELECT '=== 활성 사용자 세션 분석 ===' as info;
SELECT
    u.username,
    u.email,
    COUNT(s.session_id) as session_count,
    MIN(s.login_time) as first_login,
    MAX(s.login_time) as last_login
FROM users u
LEFT JOIN user_sessions s ON u.id = s.user_id
WHERE u.is_active = true
GROUP BY u.id, u.username, u.email
ORDER BY session_count DESC;

-- 단일 파일 저장소의 장점: 간단한 백업 및 이동
SELECT '=== 데이터베이스 메타 정보 ===' as info;
SELECT
    '단일 파일 저장소' as storage_type,
    'database.redb' as file_name,
    COUNT(DISTINCT table_name) as table_count
FROM (
    SELECT 'users' as table_name
    UNION ALL
    SELECT 'user_sessions' as table_name
) tables;
