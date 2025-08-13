-- Memory Storage Analytics SQL
-- Generated from 01_memory_demo

-- 메모리 저장소 성능 테스트

-- 대량 데이터를 위한 테이블 생성
CREATE TABLE performance_test (
    id INTEGER,
    category TEXT,
    value FLOAT,
    created_at TEXT
);

-- 대량 데이터 삽입 (시뮬레이션)
INSERT INTO performance_test VALUES
    (1, 'A', 10.5, '2024-01-01'),
    (2, 'B', 20.3, '2024-01-01'),
    (3, 'A', 15.7, '2024-01-02'),
    (4, 'C', 30.1, '2024-01-02'),
    (5, 'B', 25.9, '2024-01-03'),
    (6, 'A', 12.3, '2024-01-03'),
    (7, 'C', 35.6, '2024-01-04'),
    (8, 'B', 22.8, '2024-01-04'),
    (9, 'A', 18.4, '2024-01-05'),
    (10, 'C', 28.7, '2024-01-05');

-- 집계 성능 테스트
SELECT '=== 카테고리별 통계 (메모리 저장소) ===' as info;
SELECT
    category,
    COUNT(*) as 데이터수,
    AVG(value) as 평균값,
    SUM(value) as 합계,
    MIN(value) as 최솟값,
    MAX(value) as 최댓값,
    MAX(value) - MIN(value) as 범위
FROM performance_test
GROUP BY category
ORDER BY 평균값 DESC;

-- 복잡한 윈도우 함수
SELECT '=== 이동 평균 계산 ===' as info;
SELECT
    id,
    category,
    value,
    AVG(value) OVER (PARTITION BY category ORDER BY id ROWS BETWEEN 1 PRECEDING AND 1 FOLLOWING) as 이동평균
FROM performance_test
ORDER BY category, id;

SELECT '=== 메모리 저장소 성능 테스트 완료 ===' as result;
SELECT '메모리 저장소는 모든 데이터가 RAM에 저장되어 최고 성능을 제공합니다' as description;
