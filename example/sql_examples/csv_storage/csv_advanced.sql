-- Csv Storage Advanced SQL
-- Generated from 04_csv_demo

-- CSV 파일 간 조인 쿼리

-- 직원과 판매 실적 조인
SELECT '=== 직원별 판매 실적 ===' as info;
SELECT
    e.name,
    e.department,
    COUNT(s.id) as 판매건수,
    SUM(s.price * s.quantity) as 총매출,
    AVG(s.price * s.quantity) as 평균거래액
FROM employees e
LEFT JOIN sales s ON e.id = s.employee_id
GROUP BY e.id, e.name, e.department
ORDER BY 총매출 DESC;

-- 부서별 성과 분석
SELECT '=== 부서별 성과 분석 ===' as info;
SELECT
    d.dept_name,
    d.budget,
    d.manager,
    d.location,
    COUNT(e.id) as 직원수,
    SUM(e.salary) as 총급여비용,
    COALESCE(SUM(s.price * s.quantity), 0) as 총매출,
    d.budget - SUM(e.salary) as 급여후예산여유,
    CASE
        WHEN SUM(s.price * s.quantity) > 0
        THEN ROUND(SUM(s.price * s.quantity) / SUM(e.salary), 2)
        ELSE 0
    END as 매출대급여비율
FROM departments d
LEFT JOIN employees e ON d.dept_name = e.department
LEFT JOIN sales s ON e.id = s.employee_id
GROUP BY d.dept_name, d.budget, d.manager, d.location
ORDER BY 매출대급여비율 DESC;

-- 고성과자 분석 (매출 상위 직원)
SELECT '=== 고성과자 분석 ===' as info;
SELECT
    e.name,
    e.department,
    e.salary,
    SUM(s.price * s.quantity) as 개인매출,
    COUNT(s.id) as 거래건수,
    AVG(s.price * s.quantity) as 평균거래액,
    ROUND(SUM(s.price * s.quantity) / e.salary, 2) as 매출대급여비율
FROM employees e
JOIN sales s ON e.id = s.employee_id
GROUP BY e.id, e.name, e.department, e.salary
HAVING SUM(s.price * s.quantity) > 100000
ORDER BY 개인매출 DESC;
