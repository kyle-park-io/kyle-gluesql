-- Csv Storage Performance SQL
-- Generated from 04_csv_demo

-- CSV 고급 분석 및 통계

-- 전체 비즈니스 KPI
SELECT '=== 주요 KPI 지표 ===' as info;
SELECT
    '전체 현황' as 구분,
    (SELECT COUNT(*) FROM employees) as 총직원수,
    (SELECT COUNT(*) FROM sales) as 총거래건수,
    (SELECT SUM(price * quantity) FROM sales) as 총매출,
    (SELECT AVG(salary) FROM employees) as 평균급여,
    (SELECT COUNT(DISTINCT product) FROM sales) as 판매상품수;

-- 상위 10% 직원 분석
WITH employee_sales AS (
    SELECT
        e.id,
        e.name,
        e.department,
        e.salary,
        COALESCE(SUM(s.price * s.quantity), 0) as total_sales
    FROM employees e
    LEFT JOIN sales s ON e.id = s.employee_id
    GROUP BY e.id, e.name, e.department, e.salary
),
sales_rank AS (
    SELECT
        *,
        RANK() OVER (ORDER BY total_sales DESC) as sales_rank,
        COUNT(*) OVER () as total_employees
    FROM employee_sales
)
SELECT '=== 상위 성과자 (상위 30%) ===' as info;
SELECT
    name,
    department,
    salary,
    total_sales,
    sales_rank,
    ROUND(sales_rank * 100.0 / total_employees, 1) as 백분위순위
FROM sales_rank
WHERE sales_rank <= CAST(total_employees * 0.3 AS INTEGER)
ORDER BY sales_rank;

-- 부서 효율성 분석
SELECT '=== 부서 효율성 순위 ===' as info;
SELECT
    d.dept_name,
    COUNT(e.id) as 직원수,
    SUM(e.salary) as 부서급여총액,
    COALESCE(SUM(s.price * s.quantity), 0) as 부서매출총액,
    ROUND(COALESCE(SUM(s.price * s.quantity), 0) / COUNT(e.id), 0) as 직원당매출,
    ROUND(COALESCE(SUM(s.price * s.quantity), 0) / SUM(e.salary), 2) as 급여대비매출비율,
    RANK() OVER (ORDER BY COALESCE(SUM(s.price * s.quantity), 0) / COUNT(e.id) DESC) as 효율성순위
FROM departments d
LEFT JOIN employees e ON d.dept_name = e.department
LEFT JOIN sales s ON e.id = s.employee_id
GROUP BY d.dept_name
ORDER BY 효율성순위;

-- 제품 카테고리별 분석 (가정: 첫 글자로 카테고리 구분)
SELECT '=== 제품 카테고리 분석 ===' as info;
SELECT
    CASE
        WHEN product LIKE '노트북%' OR product LIKE '태블릿%' THEN '컴퓨터'
        WHEN product LIKE '마우스%' OR product LIKE '키보드%' THEN '입력장치'
        WHEN product LIKE '모니터%' OR product LIKE '스피커%' THEN '출력장치'
        ELSE '기타'
    END as 제품카테고리,
    COUNT(*) as 거래건수,
    SUM(quantity) as 총판매수량,
    SUM(price * quantity) as 카테고리매출,
    AVG(price) as 평균단가,
    AVG(quantity) as 평균구매수량
FROM sales
GROUP BY
    CASE
        WHEN product LIKE '노트북%' OR product LIKE '태블릿%' THEN '컴퓨터'
        WHEN product LIKE '마우스%' OR product LIKE '키보드%' THEN '입력장치'
        WHEN product LIKE '모니터%' OR product LIKE '스피커%' THEN '출력장치'
        ELSE '기타'
    END
ORDER BY 카테고리매출 DESC;

-- CSV 저장소 성능 테스트 결과
SELECT '=== CSV Storage 분석 완료 ===' as result;
SELECT 'CSV 파일을 실시간 데이터베이스로 활용하여 복잡한 분석 쿼리 실행 완료' as description;
