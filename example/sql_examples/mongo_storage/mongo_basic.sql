-- Mongo Storage Basic SQL
-- Generated from 09_mongo_demo

-- MongoDB Storage 시뮬레이션 (실제로는 MongoDB 컬렉션 사용)

CREATE TABLE products (
    _id TEXT,
    name TEXT,
    category TEXT,
    price FLOAT,
    in_stock BOOLEAN,
    tags TEXT
);

INSERT INTO products VALUES
    ('prod_001', 'Laptop', 'Electronics', 999.99, true, '["computers", "portable"]'),
    ('prod_002', 'Coffee Mug', 'Home', 12.99, true, '["kitchen", "ceramic"]'),
    ('prod_003', 'Smartphone', 'Electronics', 699.99, false, '["mobile", "tech"]');

SELECT '=== MongoDB 스타일 문서 데이터 ===' as info;
SELECT * FROM products;

SELECT '=== 카테고리별 집계 (NoSQL → SQL) ===' as info;
SELECT category, COUNT(*) as product_count, AVG(price) as avg_price
FROM products
GROUP BY category;

SELECT 'MongoDB 컬렉션을 SQL로 쿼리할 수 있습니다!' as feature;
