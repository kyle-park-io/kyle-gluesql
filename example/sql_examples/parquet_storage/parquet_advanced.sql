-- Parquet Storage Advanced SQL
-- Generated from 05_parquet_demo

-- Parquet 저장소의 분석 쿼리 최적화 시연

-- 윈도우 함수를 활용한 고급 분석 (Parquet의 장점)
SELECT '=== 매출 트렌드 분석 (윈도우 함수) ===' as info;
SELECT
    transaction_date,
    category,
    total_amount,
    SUM(total_amount) OVER (PARTITION BY category ORDER BY transaction_date) as running_total,
    AVG(total_amount) OVER (PARTITION BY category ORDER BY transaction_date ROWS BETWEEN 2 PRECEDING AND CURRENT ROW) as moving_avg_3day,
    ROW_NUMBER() OVER (PARTITION BY category ORDER BY total_amount DESC) as revenue_rank_in_category
FROM sales_data
ORDER BY category, transaction_date;

-- 복잡한 집계 및 서브쿼리 (컬럼형 저장의 이점)
SELECT '=== 카테고리별 상세 통계 ===' as info;
SELECT
    category,
    COUNT(*) as transactions,
    SUM(total_amount) as total_revenue,
    AVG(total_amount) as avg_revenue,
    MIN(total_amount) as min_revenue,
    MAX(total_amount) as max_revenue,
    -- 중앙값 계산
    (SELECT AVG(total_amount)
     FROM (
         SELECT total_amount,
                ROW_NUMBER() OVER (ORDER BY total_amount) as rn,
                COUNT(*) OVER () as cnt
         FROM sales_data s2
         WHERE s2.category = s1.category
     ) ranked
     WHERE rn IN ((cnt + 1) / 2, (cnt + 2) / 2)
    ) as median_revenue,
    -- 표준편차 근사
    SQRT(AVG((total_amount - (SELECT AVG(total_amount) FROM sales_data s3 WHERE s3.category = s1.category)) *
             (total_amount - (SELECT AVG(total_amount) FROM sales_data s4 WHERE s4.category = s1.category)))) as revenue_std_dev
FROM sales_data s1
GROUP BY category
ORDER BY total_revenue DESC;

-- 고객 세분화 분석
SELECT '=== 고객 행동 패턴 분석 ===' as info;
SELECT
    customer_id,
    COUNT(DISTINCT category) as category_diversity,
    COUNT(DISTINCT transaction_date) as shopping_days,
    SUM(total_amount) as total_spent,
    SUM(quantity) as total_items,
    AVG(unit_price) as avg_price_preference,
    CASE
        WHEN SUM(total_amount) > 2000 THEN 'High Value'
        WHEN SUM(total_amount) > 1000 THEN 'Medium Value'
        ELSE 'Low Value'
    END as customer_segment,
    CASE
        WHEN COUNT(DISTINCT category) >= 3 THEN 'Diversified'
        WHEN COUNT(DISTINCT category) = 2 THEN 'Moderate'
        ELSE 'Focused'
    END as shopping_behavior
FROM sales_data
GROUP BY customer_id
ORDER BY total_spent DESC;

-- 제품 성과 분석
SELECT '=== 제품별 판매 성과 ===' as info;
SELECT
    product_id,
    category,
    subcategory,
    COUNT(*) as times_sold,
    SUM(quantity) as total_quantity_sold,
    SUM(total_amount) as total_revenue,
    AVG(unit_price) as avg_selling_price,
    COUNT(DISTINCT customer_id) as unique_customers,
    COUNT(DISTINCT region) as regions_sold_in,
    (SUM(total_amount) / COUNT(*)) as revenue_per_transaction
FROM sales_data
GROUP BY product_id, category, subcategory
ORDER BY total_revenue DESC;
