-- Json Storage Analytics SQL
-- Generated from 03_json_demo

-- 스키마 정의 테이블과 스키마리스 테이블 혼합 사용

-- 스키마 정의된 카테고리 테이블
SELECT '=== 카테고리 목록 (스키마 정의) ===' as info;
SELECT * FROM categories;

-- 스키마리스 혼합 이벤트 테이블
SELECT '=== 혼합 이벤트 (스키마리스) ===' as info;
SELECT * FROM mixed_events;

-- 구조화 + 비구조화 데이터 조인
SELECT '=== 카테고리별 사용자 활동 분석 ===' as info;
SELECT
    c.name as 카테고리,
    c.description,
    u.name as 사용자명,
    JSON_EXTRACT(m.data, '$.action') as 액션
FROM categories c
JOIN mixed_events m ON c.id = m.category_id
JOIN users u ON m.user_id = u.id
ORDER BY c.name, u.name;

-- JSON 함수 활용한 복잡한 분석
SELECT '=== JSON 데이터 상세 분석 ===' as info;
SELECT
    u.name,
    c.name as 카테고리,
    JSON_EXTRACT(m.data, '$.action') as 액션,
    CASE
        WHEN JSON_EXTRACT(m.data, '$.action') = 'purchase'
        THEN JSON_EXTRACT(m.data, '$.total')
        ELSE NULL
    END as 구매금액,
    CASE
        WHEN JSON_EXTRACT(m.data, '$.action') IN ('view', 'compare')
        THEN JSON_EXTRACT(m.data, '$.time_spent')
        WHEN JSON_EXTRACT(m.data, '$.action') = 'compare'
        THEN JSON_EXTRACT(m.data, '$.duration')
        ELSE NULL
    END as 소요시간
FROM mixed_events m
JOIN users u ON m.user_id = u.id
JOIN categories c ON m.category_id = c.id
ORDER BY u.name;
