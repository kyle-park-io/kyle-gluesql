-- Shared_memory Storage Basic SQL
-- Generated from 02_shared_memory_demo

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
