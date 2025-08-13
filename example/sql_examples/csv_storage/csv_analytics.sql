-- Csv Storage Analytics SQL
-- Generated from 04_csv_demo

-- CSV를 활용한 시계열 분석

-- 일별 매출 추이
SELECT '=== 일별 매출 추이 ===' as info;
SELECT
    sale_date,
    COUNT(*) as 거래건수,
    SUM(price * quantity) as 일매출,
    AVG(price * quantity) as 평균거래액,
    COUNT(DISTINCT employee_id) as 활동직원수
FROM sales
GROUP BY sale_date
ORDER BY sale_date;

-- 고객 유형별 매출 분석
SELECT '=== 고객 유형별 매출 분석 ===' as info;
SELECT
    customer_type,
    COUNT(*) as 거래건수,
    SUM(price * quantity) as 총매출,
    AVG(price * quantity) as 평균거래액,
    MIN(price * quantity) as 최소거래액,
    MAX(price * quantity) as 최대거래액
FROM sales
GROUP BY customer_type
ORDER BY 총매출 DESC;

-- 제품별 판매 현황
SELECT '=== 제품별 판매 현황 ===' as info;
SELECT
    product,
    COUNT(*) as 판매횟수,
    SUM(quantity) as 총판매수량,
    SUM(price * quantity) as 총매출,
    AVG(price) as 평균단가,
    COUNT(DISTINCT employee_id) as 판매직원수
FROM sales
GROUP BY product
ORDER BY 총매출 DESC;

-- 월별 트렌드 분석 (가상의 월별 데이터)
SELECT '=== 일별 성장률 분석 ===' as info;
SELECT
    sale_date,
    SUM(price * quantity) as 일매출,
    LAG(SUM(price * quantity)) OVER (ORDER BY sale_date) as 전일매출,
    CASE
        WHEN LAG(SUM(price * quantity)) OVER (ORDER BY sale_date) > 0
        THEN ROUND(
            (SUM(price * quantity) - LAG(SUM(price * quantity)) OVER (ORDER BY sale_date)) * 100.0 /
            LAG(SUM(price * quantity)) OVER (ORDER BY sale_date), 2
        )
        ELSE NULL
    END as 전일대비성장률
FROM sales
GROUP BY sale_date
ORDER BY sale_date;
