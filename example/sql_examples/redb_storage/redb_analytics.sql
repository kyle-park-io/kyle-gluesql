-- Redb Storage Analytics SQL
-- Generated from 07_redb_demo

-- Redb 단일 파일 저장소의 장점을 활용한 시나리오

-- 애플리케이션 로그 테이블
CREATE TABLE app_logs (
    log_id INTEGER,
    user_id INTEGER,
    action TEXT,
    details TEXT,
    timestamp TEXT,
    severity TEXT
);

-- 로그 데이터 삽입
INSERT INTO app_logs VALUES
    (1, 1, 'login', 'User logged in successfully', '2024-01-10 09:00:00', 'INFO'),
    (2, 1, 'view_page', 'Accessed dashboard', '2024-01-10 09:01:00', 'INFO'),
    (3, 2, 'login', 'User logged in successfully', '2024-01-10 09:15:00', 'INFO'),
    (4, 1, 'update_profile', 'Changed email address', '2024-01-10 09:30:00', 'INFO'),
    (5, 3, 'login_failed', 'Invalid password attempt', '2024-01-10 10:00:00', 'WARNING'),
    (6, 2, 'create_post', 'Created new blog post', '2024-01-10 10:30:00', 'INFO'),
    (7, 4, 'login', 'User logged in successfully', '2024-01-10 10:45:00', 'INFO'),
    (8, 1, 'logout', 'User logged out', '2024-01-10 14:30:00', 'INFO'),
    (9, 5, 'error', 'Database connection failed', '2024-01-11 08:15:00', 'ERROR'),
    (10, 2, 'delete_post', 'Deleted blog post', '2024-01-11 11:20:00', 'INFO');

-- 종합 활동 리포트 (모든 테이블 조인)
SELECT '=== 종합 사용자 활동 리포트 ===' as info;
SELECT
    u.username,
    u.email,
    u.is_active,
    COUNT(DISTINCT s.session_id) as session_count,
    COUNT(DISTINCT l.log_id) as activity_count,
    COUNT(DISTINCT p.preference_key) as preferences_set,
    MIN(s.login_time) as first_session,
    MAX(l.timestamp) as last_activity
FROM users u
LEFT JOIN user_sessions s ON u.id = s.user_id
LEFT JOIN app_logs l ON u.id = l.user_id
LEFT JOIN user_preferences p ON u.id = p.user_id
GROUP BY u.id, u.username, u.email, u.is_active
ORDER BY activity_count DESC;

-- 보안 관련 이벤트 분석
SELECT '=== 보안 이벤트 분석 ===' as info;
SELECT
    u.username,
    l.action,
    l.details,
    l.timestamp,
    l.severity,
    s.ip_address
FROM app_logs l
JOIN users u ON l.user_id = u.id
LEFT JOIN user_sessions s ON l.user_id = s.user_id
    AND DATE(l.timestamp) = DATE(s.login_time)
WHERE l.severity IN ('WARNING', 'ERROR')
   OR l.action LIKE '%login%'
ORDER BY l.timestamp;

-- 시간대별 활동 패턴
SELECT '=== 시간대별 활동 패턴 ===' as info;
SELECT
    SUBSTR(l.timestamp, 12, 2) as hour,
    COUNT(*) as activity_count,
    COUNT(DISTINCT l.user_id) as active_users,
    GROUP_CONCAT(DISTINCT l.action) as actions
FROM app_logs l
GROUP BY SUBSTR(l.timestamp, 12, 2)
ORDER BY hour;

-- 단일 파일의 이점: 전체 데이터베이스 통계
SELECT '=== 데이터베이스 전체 통계 ===' as info;
SELECT
    'Redb Single File Database' as database_type,
    (SELECT COUNT(*) FROM users) as total_users,
    (SELECT COUNT(*) FROM user_sessions) as total_sessions,
    (SELECT COUNT(*) FROM user_preferences) as total_preferences,
    (SELECT COUNT(*) FROM app_logs) as total_logs,
    'All data in single .redb file' as storage_info;

-- 데이터 무결성 체크
SELECT '=== 데이터 무결성 확인 ===' as info;
SELECT
    'Orphaned Sessions' as check_type,
    COUNT(*) as count
FROM user_sessions s
WHERE NOT EXISTS (SELECT 1 FROM users u WHERE u.id = s.user_id)
UNION ALL
SELECT
    'Orphaned Logs' as check_type,
    COUNT(*) as count
FROM app_logs l
WHERE NOT EXISTS (SELECT 1 FROM users u WHERE u.id = l.user_id)
UNION ALL
SELECT
    'Orphaned Preferences' as check_type,
    COUNT(*) as count
FROM user_preferences p
WHERE NOT EXISTS (SELECT 1 FROM users u WHERE u.id = p.user_id);
