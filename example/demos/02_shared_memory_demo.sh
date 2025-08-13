#!/bin/bash

# =============================================================================
# GlueSQL Shared Memory Storage Demo
# 공유 메모리 저장소 - 멀티스레드 환경에서 안전한 메모리 공유
# =============================================================================

echo "🔗 GlueSQL Shared Memory Storage Demo"
echo "======================================"
echo "✨ 특징: 멀티스레드 안전, 공유 메모리, 동시성 지원"
echo ""

# 결과 디렉토리 생성
mkdir -p results/demo_results

echo "📊 1. 기본 공유 메모리 테이블 생성"
echo "----------------------------------------"

cat << 'EOF' | ../bin/gluesql-cli -s memory > results/demo_results/02_shared_memory_basic.txt 2>&1
-- Shared Memory Storage 시뮬레이션 (CLI에서는 Memory Storage로 실행)
-- 실제 Shared Memory는 Rust 코드에서 멀티스레드로 사용됩니다

CREATE TABLE shared_sessions (
    session_id TEXT,
    user_id INTEGER,
    thread_id INTEGER,
    created_at TEXT,
    data TEXT
);

-- 멀티스레드 시뮬레이션 데이터
INSERT INTO shared_sessions VALUES
    ('sess_001', 1, 1, '2024-01-01 10:00:00', 'thread_1_data'),
    ('sess_002', 2, 2, '2024-01-01 10:00:01', 'thread_2_data'),
    ('sess_003', 3, 1, '2024-01-01 10:00:02', 'thread_1_more_data'),
    ('sess_004', 4, 3, '2024-01-01 10:00:03', 'thread_3_data'),
    ('sess_005', 1, 2, '2024-01-01 10:00:04', 'thread_2_user1_data');

SELECT '=== 공유 세션 데이터 ===' as info;
SELECT * FROM shared_sessions ORDER BY created_at;

-- 스레드별 활동 분석
SELECT '=== 스레드별 활동 통계 ===' as info;
SELECT
    thread_id,
    COUNT(*) as session_count,
    COUNT(DISTINCT user_id) as unique_users,
    MIN(created_at) as first_activity,
    MAX(created_at) as last_activity
FROM shared_sessions
GROUP BY thread_id
ORDER BY thread_id;

-- 동시성 시뮬레이션 테스트
CREATE TABLE concurrent_counters (
    counter_name TEXT,
    value INTEGER,
    updated_by_thread INTEGER,
    updated_at TEXT
);

INSERT INTO concurrent_counters VALUES
    ('global_counter', 1, 1, '2024-01-01 10:00:00'),
    ('global_counter', 2, 2, '2024-01-01 10:00:01'),
    ('global_counter', 3, 1, '2024-01-01 10:00:02'),
    ('global_counter', 4, 3, '2024-01-01 10:00:03'),
    ('user_counter', 1, 1, '2024-01-01 10:00:00'),
    ('user_counter', 2, 2, '2024-01-01 10:00:01');

SELECT '=== 동시성 카운터 현황 ===' as info;
SELECT
    counter_name,
    MAX(value) as current_value,
    COUNT(*) as update_count,
    COUNT(DISTINCT updated_by_thread) as thread_count
FROM concurrent_counters
GROUP BY counter_name;
EOF

echo "✅ 기본 공유 메모리 테스트 완료: results/demo_results/02_shared_memory_basic.txt"

echo ""
echo "🔄 2. 동시성 시나리오 시뮬레이션"
echo "----------------------------------------"

cat << 'EOF' | ../bin/gluesql-cli -s memory > results/demo_results/02_shared_memory_concurrency.txt 2>&1
-- 동시성 처리 시나리오 시뮬레이션

-- 동시 읽기/쓰기 테스트를 위한 테이블
CREATE TABLE shared_cache (
    key_name TEXT,
    value_data TEXT,
    version INTEGER,
    locked_by_thread INTEGER,
    lock_time TEXT
);

-- 여러 스레드가 동시에 캐시에 접근하는 시나리오
INSERT INTO shared_cache VALUES
    ('user:1', '{"name": "Alice", "age": 30}', 1, 1, '2024-01-01 10:00:00'),
    ('user:2', '{"name": "Bob", "age": 25}', 1, 2, '2024-01-01 10:00:01'),
    ('user:1', '{"name": "Alice", "age": 31}', 2, 3, '2024-01-01 10:00:02'),
    ('config:app', '{"theme": "dark", "lang": "ko"}', 1, 1, '2024-01-01 10:00:03'),
    ('config:app', '{"theme": "light", "lang": "ko"}', 2, 2, '2024-01-01 10:00:04');

SELECT '=== 공유 캐시 최신 상태 ===' as info;
SELECT
    key_name,
    value_data,
    MAX(version) as latest_version,
    COUNT(*) as update_count
FROM shared_cache
GROUP BY key_name, value_data
HAVING version = MAX(version)
ORDER BY key_name;

-- 락 경합 분석
SELECT '=== 스레드별 락 사용 패턴 ===' as info;
SELECT
    locked_by_thread as thread_id,
    COUNT(*) as lock_acquisitions,
    COUNT(DISTINCT key_name) as unique_keys_locked,
    MIN(lock_time) as first_lock,
    MAX(lock_time) as last_lock
FROM shared_cache
GROUP BY locked_by_thread
ORDER BY lock_acquisitions DESC;

-- 메모리 공유 효율성 테스트
CREATE TABLE memory_usage_stats (
    operation_type TEXT,
    thread_id INTEGER,
    memory_mb FLOAT,
    cpu_percent FLOAT,
    timestamp TEXT
);

INSERT INTO memory_usage_stats VALUES
    ('read', 1, 12.5, 5.2, '2024-01-01 10:00:00'),
    ('write', 2, 15.8, 8.7, '2024-01-01 10:00:01'),
    ('read', 3, 12.3, 4.9, '2024-01-01 10:00:02'),
    ('write', 1, 16.2, 9.1, '2024-01-01 10:00:03'),
    ('read', 2, 12.1, 5.1, '2024-01-01 10:00:04');

SELECT '=== 메모리 사용량 분석 ===' as info;
SELECT
    operation_type,
    COUNT(*) as operation_count,
    AVG(memory_mb) as avg_memory_mb,
    AVG(cpu_percent) as avg_cpu_percent,
    COUNT(DISTINCT thread_id) as threads_used
FROM memory_usage_stats
GROUP BY operation_type
ORDER BY avg_memory_mb DESC;
EOF

echo "✅ 동시성 시뮬레이션 완료: results/demo_results/02_shared_memory_concurrency.txt"

echo ""
echo "📋 3. 실행 결과 요약"
echo "----------------------------------------"
echo "생성된 결과 파일들:"
ls -la results/demo_results/02_shared_memory_*.txt 2>/dev/null || echo "결과 파일이 아직 생성되지 않았습니다."

echo ""
echo "🎯 Shared Memory Storage 특징 요약:"
echo "  ✅ 멀티스레드 환경에서 안전한 메모리 공유"
echo "  ✅ Read-Write Lock으로 동시성 제어"
echo "  ✅ Atomic Reference Count로 메모리 관리"
echo "  ✅ 여러 스레드에서 동일한 데이터 참조"
echo "  ⚠️  메모리 사용량은 높을 수 있음"
echo "  ⚠️  애플리케이션 종료시 데이터 소실"

echo ""
echo "💡 사용 시나리오:"
echo "  - 멀티스레드 웹 서버"
echo "  - 동시성이 중요한 애플리케이션"
echo "  - 스레드 간 데이터 공유"
echo "  - 고성능 캐싱 시스템"
echo "  - 실시간 협업 애플리케이션"

echo ""
echo "🔧 Rust 코드 예제:"
echo "  use gluesql_shared_memory_storage::SharedMemoryStorage;"
echo "  let storage = SharedMemoryStorage::default();"
echo "  let storage_clone = storage.clone(); // 다른 스레드에서 사용 가능"

echo ""
echo "🎉 Shared Memory Storage Demo 완료!"
