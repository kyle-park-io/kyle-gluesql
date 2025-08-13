#!/bin/bash

# =============================================================================
# GlueSQL Parquet Storage Demo
# Parquet 저장소 - 컬럼형 저장으로 빅데이터 분석 최적화
# =============================================================================

echo "🗂️ GlueSQL Parquet Storage Demo"
echo "================================="
echo "✨ 특징: 컬럼형 저장, 압축 효율성, 대용량 데이터 분석 최적화"
echo ""

# 결과 디렉토리 생성
mkdir -p results/demo_results data/parquet_demo

echo "📊 1. Parquet 데이터 파일 준비"
echo "----------------------------------------"

# Parquet는 바이너리 형식이므로 시뮬레이션 데이터 설명만 제공
cat > data/parquet_demo/parquet_info.txt << 'EOF'
Parquet Storage 정보:

Parquet는 컬럼형 저장 형식으로 다음과 같은 장점이 있습니다:
1. 높은 압축률 - 동일한 타입의 데이터가 연속으로 저장됨
2. 빠른 분석 쿼리 - 필요한 컬럼만 읽어서 I/O 최소화
3. 스키마 진화 지원 - 시간에 따른 스키마 변경 지원
4. 다양한 압축 알고리즘 지원 (SNAPPY, GZIP, LZ4 등)

실제 Parquet 파일은 다음과 같은 구조를 가집니다:
- Header: 파일 메타데이터
- Row Groups: 데이터 청크 단위
- Column Chunks: 컬럼별 데이터 저장
- Footer: 스키마 및 메타데이터
EOF

echo "✅ Parquet 정보 파일 생성 완료"

echo ""
echo "🔍 2. Parquet 저장소 시뮬레이션 (Memory Storage 사용)"
echo "----------------------------------------"

cat << 'EOF' | ../bin/gluesql-cli -s memory > results/demo_results/05_parquet_simulation.txt 2>&1
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
EOF

echo "✅ Parquet 시뮬레이션 완료: results/demo_results/05_parquet_simulation.txt"

echo ""
echo "📈 3. 컬럼형 저장소의 분석 성능 최적화"
echo "----------------------------------------"

cat << 'EOF' | ../bin/gluesql-cli -s memory > results/demo_results/05_parquet_analytics.txt 2>&1
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
EOF

echo "✅ 고급 분석 쿼리 완료: results/demo_results/05_parquet_analytics.txt"

echo ""
echo "📋 4. 실행 결과 요약"
echo "----------------------------------------"
echo "생성된 정보 파일들:"
ls -la data/parquet_demo/

echo ""
echo "생성된 결과 파일들:"
ls -la results/demo_results/05_parquet_*.txt 2>/dev/null || echo "결과 파일이 아직 생성되지 않았습니다."

echo ""
echo "🎯 Parquet Storage 특징 요약:"
echo "  ✅ 컬럼형 저장으로 압축률 극대화"
echo "  ✅ 분석 쿼리 성능 최적화 (필요한 컬럼만 읽기)"
echo "  ✅ 스키마 진화 지원"
echo "  ✅ 다양한 압축 알고리즘 지원"
echo "  ✅ 빅데이터 생태계 표준 형식"
echo "  ⚠️  행 단위 업데이트에는 비효율적"
echo "  ⚠️  소규모 데이터에는 오버헤드"

echo ""
echo "💡 사용 시나리오:"
echo "  - 데이터 웨어하우스 및 데이터 레이크"
echo "  - 빅데이터 분석 (수백만~수십억 행)"
echo "  - ETL 파이프라인의 중간 저장소"
echo "  - 시계열 데이터 분석"
echo "  - 비즈니스 인텔리전스 (BI) 플랫폼"
echo "  - 머신러닝 피처 저장소"

echo ""
echo "📊 성능 특성:"
echo "  - 읽기 최적화: ⭐⭐⭐⭐⭐"
echo "  - 압축률: ⭐⭐⭐⭐⭐"
echo "  - 분석 쿼리: ⭐⭐⭐⭐⭐"
echo "  - 쓰기 성능: ⭐⭐"
echo "  - 업데이트: ⭐"

echo ""
echo "🎉 Parquet Storage Demo 완료!"
echo "컬럼형 저장소의 분석 성능 우위를 확인하세요! 📊"
