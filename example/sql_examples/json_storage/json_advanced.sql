-- Json Storage Advanced SQL
-- Generated from 03_json_demo

-- JSON 파일 간 복잡한 조인

-- 사용자와 판매 데이터 조인
SELECT '=== 사용자별 구매 내역 ===' as info;
SELECT
    u.name,
    u.department,
    s.product,
    s.price,
    s.quantity,
    s.price * s.quantity as 총액
FROM users u
JOIN sales s ON u.id = s.user_id
ORDER BY 총액 DESC;

-- 사용자, 이벤트, 판매 3-way 조인
SELECT '=== 사용자별 활동 및 구매 분석 ===' as info;
SELECT
    u.name,
    u.department,
    COUNT(DISTINCT e.event) as 이벤트종류수,
    COUNT(e.timestamp) as 총이벤트수,
    COALESCE(SUM(s.price * s.quantity), 0) as 총구매액
FROM users u
LEFT JOIN events e ON u.id = e.user_id
LEFT JOIN sales s ON u.id = s.user_id
GROUP BY u.id, u.name, u.department
ORDER BY 총구매액 DESC;

-- 부서별 집계
SELECT '=== 부서별 활동 요약 ===' as info;
SELECT
    u.department,
    COUNT(DISTINCT u.id) as 직원수,
    COUNT(e.timestamp) as 총이벤트수,
    SUM(COALESCE(s.price * s.quantity, 0)) as 총구매액,
    AVG(COALESCE(s.price * s.quantity, 0)) as 평균구매액
FROM users u
LEFT JOIN events e ON u.id = e.user_id
LEFT JOIN sales s ON u.id = s.user_id
GROUP BY u.department
ORDER BY 총구매액 DESC;
