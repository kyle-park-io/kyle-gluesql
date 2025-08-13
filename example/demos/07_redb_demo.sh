#!/bin/bash

# =============================================================================
# GlueSQL Redb Storage Demo
# Redb 저장소 - 단일 파일 임베디드 데이터베이스
# =============================================================================

echo "📁 GlueSQL Redb Storage Demo"
echo "============================="
echo "✨ 특징: 단일 파일 저장, 트랜잭션 지원, 간단한 임베디드 DB"
echo ""

# 결과 및 데이터 디렉토리 생성
mkdir -p results/demo_results data/redb_demo

echo "📊 1. Redb 저장소 기본 사용법"
echo "----------------------------------------"

../bin/gluesql-cli -s redb -p data/redb_demo/database.redb -e - > results/demo_results/07_redb_basic.txt 2>&1 << 'EOF'
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
EOF

echo "✅ Redb 기본 사용법 완료: results/demo_results/07_redb_basic.txt"

echo ""
echo "🔄 2. 트랜잭션 및 일관성 테스트"
echo "----------------------------------------"

../bin/gluesql-cli -s redb -p data/redb_demo/database.redb -e - > results/demo_results/07_redb_transactions.txt 2>&1 << 'EOF'
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
EOF

echo "✅ 트랜잭션 테스트 완료: results/demo_results/07_redb_transactions.txt"

echo ""
echo "📊 3. 단일 파일 저장소의 장점 활용"
echo "----------------------------------------"

../bin/gluesql-cli -s redb -p data/redb_demo/database.redb -e - > results/demo_results/07_redb_advantages.txt 2>&1 << 'EOF'
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
EOF

echo "✅ 단일 파일 저장소 장점 테스트 완료: results/demo_results/07_redb_advantages.txt"

echo ""
echo "📋 4. 실행 결과 요약"
echo "----------------------------------------"
echo "생성된 Redb 데이터베이스 파일:"
ls -la data/redb_demo/ 2>/dev/null || echo "Redb 데이터베이스 파일이 생성됩니다."

echo ""
echo "생성된 결과 파일들:"
ls -la results/demo_results/07_redb_*.txt 2>/dev/null || echo "결과 파일이 아직 생성되지 않았습니다."

echo ""
echo "🎯 Redb Storage 특징 요약:"
echo "  ✅ 단일 파일에 모든 데이터 저장"
echo "  ✅ 트랜잭션 지원 (ACID 특성)"
echo "  ✅ 간단한 백업 및 이동 (파일 복사만)"
echo "  ✅ 버전 관리 시스템과 호환성"
echo "  ✅ 설치 및 배포 간편함"
echo "  ⚠️  단일 프로세스 접근만 지원"
echo "  ⚠️  대용량 데이터에는 제한적"

echo ""
echo "💡 사용 시나리오:"
echo "  - 소규모 웹 애플리케이션"
echo "  - 데스크톱 애플리케이션 로컬 DB"
echo "  - 프로토타입 및 MVP 개발"
echo "  - 설정 및 캐시 저장소"
echo "  - 포터블 애플리케이션"
echo "  - Git과 함께 버전 관리되는 데이터"

echo ""
echo "📁 단일 파일의 장점:"
echo "  - 배포: 파일 하나만 복사"
echo "  - 백업: 파일 하나만 백업"
echo "  - 이동: 플랫폼 간 쉬운 이동"
echo "  - 버전 관리: Git에서 바이너리 파일로 관리"
echo "  - 격리: 다른 데이터베이스와 충돌 없음"

echo ""
echo "⚡ 성능 특성:"
echo "  - 읽기 성능: ⭐⭐⭐⭐"
echo "  - 쓰기 성능: ⭐⭐⭐"
echo "  - 트랜잭션: ⭐⭐⭐⭐"
echo "  - 확장성: ⭐⭐⭐"
echo "  - 단순성: ⭐⭐⭐⭐⭐"

echo ""
echo "🎉 Redb Storage Demo 완료!"
echo "단일 파일로 완전한 데이터베이스 기능을 제공합니다! 📁"
