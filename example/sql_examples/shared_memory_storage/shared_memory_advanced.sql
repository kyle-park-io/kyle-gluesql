-- Shared_memory Storage Advanced SQL
-- Generated from 02_shared_memory_demo

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
