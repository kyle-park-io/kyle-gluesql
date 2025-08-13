#!/bin/bash

echo "🔴 GlueSQL Redis Storage Demo"
echo "=============================="
echo "✨ 특징: Redis 키-값 저장소에 SQL 인터페이스 제공"
echo ""

mkdir -p results/demo_results

cat << 'EOF' | ../bin/gluesql-cli -s memory > results/demo_results/10_redis_simulation.txt 2>&1
-- Redis Storage 시뮬레이션 (실제로는 Redis 서버 사용)

CREATE TABLE cache_entries (
    key_name TEXT,
    value_data TEXT,
    expiry_time TEXT,
    hit_count INTEGER
);

INSERT INTO cache_entries VALUES
    ('user:1:profile', '{"name": "Alice", "age": 30}', '2024-01-02', 145),
    ('session:abc123', '{"user_id": 1, "login_time": "2024-01-01"}', '2024-01-01', 5),
    ('config:app', '{"theme": "dark", "language": "en"}', '2024-12-31', 890);

SELECT '=== Redis 캐시 데이터 ===' as info;
SELECT * FROM cache_entries;

SELECT '=== 인기 캐시 키 분석 ===' as info;
SELECT key_name, hit_count, value_data
FROM cache_entries
ORDER BY hit_count DESC;

SELECT 'Redis 키-값 저장소를 SQL로 분석할 수 있습니다!' as feature;
EOF

echo "✅ Redis 시뮬레이션 완료: results/demo_results/10_redis_simulation.txt"
echo "🎉 Redis Storage Demo 완료!"
