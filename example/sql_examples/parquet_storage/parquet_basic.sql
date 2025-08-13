-- Parquet Storage Basic SQL
-- Generated from 05_parquet_demo

-- Parquet Storage 시뮬레이션
-- 실제로는 .parquet 파일을 직접 읽을 수 있습니다

-- 대용량 데이터 분석을 위한 테이블 (Parquet의 주요 사용 사례)
CREATE TABLE sales_data (
    transaction_id INTEGER,
    customer_id INTEGER,
    product_id INTEGER,
    category TEXT,
    subcategory TEXT,
    quantity INTEGER,
    unit_price FLOAT,
    total_amount FLOAT,
    transaction_date TEXT,
    region TEXT,
    salesperson_id INTEGER
);

-- 빅데이터 시뮬레이션 (실제로는 수백만~수십억 행)
INSERT INTO sales_data VALUES
    (1, 1001, 2001, 'Electronics', 'Smartphones', 2, 599.99, 1199.98, '2024-01-01', 'North', 501),
    (2, 1002, 2002, 'Electronics', 'Laptops', 1, 1299.99, 1299.99, '2024-01-01', 'South', 502),
    (3, 1003, 2003, 'Clothing', 'Shirts', 3, 29.99, 89.97, '2024-01-01', 'East', 503),
    (4, 1004, 2001, 'Electronics', 'Smartphones', 1, 599.99, 599.99, '2024-01-02', 'West', 501),
    (5, 1005, 2004, 'Home', 'Furniture', 1, 899.99, 899.99, '2024-01-02', 'North', 504),
    (6, 1001, 2005, 'Clothing', 'Pants', 2, 49.99, 99.98, '2024-01-02', 'South', 503),
    (7, 1006, 2002, 'Electronics', 'Laptops', 1, 1299.99, 1299.99, '2024-01-03', 'East', 502),
    (8, 1007, 2006, 'Home', 'Appliances', 1, 399.99, 399.99, '2024-01-03', 'West', 505),
    (9, 1002, 2003, 'Clothing', 'Shirts', 5, 29.99, 149.95, '2024-01-03', 'North', 503),
    (10, 1008, 2001, 'Electronics', 'Smartphones', 1, 599.99, 599.99, '2024-01-04', 'South', 501);

SELECT '=== Parquet 스타일 컬럼형 분석 ===' as info;

-- 1. 카테고리별 매출 집계 (Parquet의 컬럼형 압축 효과가 큰 쿼리)
SELECT
    category,
    COUNT(*) as transaction_count,
    SUM(total_amount) as total_revenue,
    AVG(total_amount) as avg_transaction_value,
    SUM(quantity) as total_quantity
FROM sales_data
GROUP BY category
ORDER BY total_revenue DESC;

-- 2. 시계열 분석 (파티셔닝된 Parquet 파일의 강점)
SELECT '=== 일별 매출 추이 분석 ===' as info;
SELECT
    transaction_date,
    COUNT(*) as daily_transactions,
    SUM(total_amount) as daily_revenue,
    COUNT(DISTINCT customer_id) as unique_customers,
    COUNT(DISTINCT product_id) as unique_products,
    AVG(total_amount) as avg_transaction_value
FROM sales_data
GROUP BY transaction_date
ORDER BY transaction_date;

-- 3. 지역별 성과 분석 (컬럼 선택적 읽기의 이점)
SELECT '=== 지역별 매출 성과 ===' as info;
SELECT
    region,
    category,
    COUNT(*) as transaction_count,
    SUM(total_amount) as region_category_revenue,
    AVG(unit_price) as avg_unit_price,
    SUM(quantity) as total_items_sold
FROM sales_data
GROUP BY region, category
ORDER BY region, region_category_revenue DESC;

-- 4. 고가치 고객 분석 (필터링된 집계)
SELECT '=== 고가치 고객 TOP 5 ===' as info;
SELECT
    customer_id,
    COUNT(*) as purchase_count,
    SUM(total_amount) as total_spent,
    AVG(total_amount) as avg_purchase_value,
    COUNT(DISTINCT category) as categories_purchased,
    MIN(transaction_date) as first_purchase,
    MAX(transaction_date) as last_purchase
FROM sales_data
GROUP BY customer_id
ORDER BY total_spent DESC
LIMIT 5;
