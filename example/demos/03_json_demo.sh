#!/bin/bash

# =============================================================================
# GlueSQL JSON Storage Demo
# JSON 저장소 - JSON/JSONL 파일을 데이터베이스로 활용
# =============================================================================

echo "📄 GlueSQL JSON Storage Demo"
echo "=============================="
echo "✨ 특징: JSON/JSONL 파일에 SQL 쿼리, 스키마 선택적, 로그 분석 최적화"
echo ""

# 결과 및 데이터 디렉토리 생성
mkdir -p ../results data/json_demo

echo "📊 1. JSON 저장소 기본 설정"
echo "----------------------------------------"

# 샘플 JSON 데이터 생성
cat > data/json_demo/users.jsonl << 'EOF'
{"id": 1, "name": "김철수", "email": "kim@example.com", "age": 30, "department": "IT"}
{"id": 2, "name": "이영희", "email": "lee@example.com", "age": 28, "department": "HR"}
{"id": 3, "name": "박민수", "email": "park@example.com", "age": 32, "department": "IT"}
{"id": 4, "name": "최지연", "email": "choi@example.com", "age": 26, "department": "Marketing"}
{"id": 5, "name": "정현우", "email": "jung@example.com", "age": 35, "department": "Finance"}
EOF

# 이벤트 로그 JSON 생성 (스키마리스)
cat > data/json_demo/events.jsonl << 'EOF'
{"timestamp": "2024-01-01T10:00:00", "user_id": 1, "event": "login", "ip": "192.168.1.100"}
{"timestamp": "2024-01-01T10:05:00", "user_id": 1, "event": "page_view", "page": "/dashboard", "duration": 30}
{"timestamp": "2024-01-01T10:10:00", "user_id": 2, "event": "login", "ip": "192.168.1.101"}
{"timestamp": "2024-01-01T10:15:00", "user_id": 1, "event": "click", "element": "button", "page": "/profile"}
{"timestamp": "2024-01-01T10:20:00", "user_id": 3, "event": "login", "ip": "192.168.1.102"}
{"timestamp": "2024-01-01T10:25:00", "user_id": 2, "event": "purchase", "product": "laptop", "amount": 1200}
{"timestamp": "2024-01-01T10:30:00", "user_id": 1, "event": "logout"}
EOF

# 판매 데이터 JSON 생성
cat > data/json_demo/sales.json << 'EOF'
[
  {"id": 1, "user_id": 2, "product": "laptop", "price": 1200, "quantity": 1, "date": "2024-01-01"},
  {"id": 2, "user_id": 1, "product": "mouse", "price": 25, "quantity": 2, "date": "2024-01-01"},
  {"id": 3, "user_id": 3, "product": "keyboard", "price": 80, "quantity": 1, "date": "2024-01-02"},
  {"id": 4, "user_id": 4, "product": "monitor", "price": 300, "quantity": 1, "date": "2024-01-02"},
  {"id": 5, "user_id": 5, "product": "headset", "price": 150, "quantity": 2, "date": "2024-01-03"}
]
EOF

echo "✅ 샘플 JSON 데이터 생성 완료"

echo ""
echo "🔍 2. JSON 파일 직접 쿼리 (스키마리스)"
echo "----------------------------------------"

../bin/gluesql-cli -s json -p data/json_demo -e - > results/demo_results/03_json_basic.txt 2>&1 << 'EOF'
-- JSON Storage 기본 사용법 (스키마 없이)

-- JSONL 파일 직접 쿼리 (테이블 이름 = 파일명)
SELECT '=== 사용자 목록 (users.jsonl) ===' as info;
SELECT * FROM users ORDER BY age;

-- JSON 배열 파일 쿼리
SELECT '=== 판매 목록 (sales.json) ===' as info;
SELECT * FROM sales ORDER BY price DESC;

-- 이벤트 로그 분석
SELECT '=== 이벤트 로그 분석 ===' as info;
SELECT
    event,
    COUNT(*) as 발생횟수
FROM events
GROUP BY event
ORDER BY 발생횟수 DESC;

-- 특정 이벤트 필터링
SELECT '=== 로그인 이벤트만 ===' as info;
SELECT user_id, timestamp, ip
FROM events
WHERE event = 'login'
ORDER BY timestamp;
EOF

echo "✅ 기본 JSON 쿼리 완료: results/03_json_basic.txt"

echo ""
echo "🔗 3. JSON 파일 간 조인 쿼리"
echo "----------------------------------------"

../bin/gluesql-cli -s json -p data/json_demo -e - > results/demo_results/03_json_joins.txt 2>&1 << 'EOF'
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
EOF

echo "✅ JSON 조인 쿼리 완료: results/03_json_joins.txt"

echo ""
echo "📈 4. 스키마 정의 테이블과 스키마리스 혼합"
echo "----------------------------------------"

# 스키마 파일 생성
cat > data/json_demo/categories.sql << 'EOF'
CREATE TABLE categories (
    id INTEGER,
    name TEXT,
    description TEXT
);
EOF

# 카테고리 데이터 생성
cat > data/json_demo/categories.jsonl << 'EOF'
{"id": 1, "name": "Electronics", "description": "전자제품"}
{"id": 2, "name": "Accessories", "description": "액세서리"}
{"id": 3, "name": "Software", "description": "소프트웨어"}
EOF

# 혼합된 이벤트 데이터 (구조화 + 비구조화)
cat > data/json_demo/mixed_events.jsonl << 'EOF'
{"user_id": 1, "category_id": 1, "data": {"action": "view", "product": "laptop", "time_spent": 120}}
{"user_id": 2, "category_id": 2, "data": {"action": "purchase", "items": ["mouse", "pad"], "total": 45}}
{"user_id": 3, "category_id": 1, "data": {"action": "compare", "products": ["laptop1", "laptop2"], "duration": 300}}
{"user_id": 4, "category_id": 3, "data": {"action": "download", "software": "antivirus", "size_mb": 150}}
EOF

../bin/gluesql-cli -s json -p data/json_demo -e - > results/demo_results/03_json_mixed.txt 2>&1 << 'EOF'
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
EOF

echo "✅ 혼합 스키마 테스트 완료: results/03_json_mixed.txt"

echo ""
echo "⚡ 5. 로그 분석 및 집계 (JSON의 강점)"
echo "----------------------------------------"

# 더 많은 로그 데이터 생성
cat > data/json_demo/access_logs.jsonl << 'EOF'
{"timestamp": "2024-01-01T08:00:00", "ip": "192.168.1.100", "method": "GET", "path": "/", "status": 200, "size": 1024}
{"timestamp": "2024-01-01T08:01:00", "ip": "192.168.1.101", "method": "GET", "path": "/login", "status": 200, "size": 512}
{"timestamp": "2024-01-01T08:02:00", "ip": "192.168.1.100", "method": "POST", "path": "/login", "status": 302, "size": 256}
{"timestamp": "2024-01-01T08:03:00", "ip": "192.168.1.102", "method": "GET", "path": "/dashboard", "status": 200, "size": 2048}
{"timestamp": "2024-01-01T08:04:00", "ip": "192.168.1.103", "method": "GET", "path": "/api/data", "status": 404, "size": 128}
{"timestamp": "2024-01-01T08:05:00", "ip": "192.168.1.100", "method": "GET", "path": "/profile", "status": 200, "size": 1536}
{"timestamp": "2024-01-01T08:06:00", "ip": "192.168.1.104", "method": "POST", "path": "/api/submit", "status": 500, "size": 64}
{"timestamp": "2024-01-01T08:07:00", "ip": "192.168.1.101", "method": "GET", "path": "/logout", "status": 200, "size": 256}
EOF

../bin/gluesql-cli -s json -p data/json_demo -e - > results/demo_results/03_json_analytics.txt 2>&1 << 'EOF'
-- JSON 로그 분석 (웹 서버 액세스 로그)

-- 상태 코드별 통계
SELECT '=== HTTP 상태 코드 분석 ===' as info;
SELECT
    status,
    COUNT(*) as 요청수,
    AVG(size) as 평균크기,
    SUM(size) as 총크기
FROM access_logs
GROUP BY status
ORDER BY 요청수 DESC;

-- IP별 접근 패턴
SELECT '=== IP별 접근 통계 ===' as info;
SELECT
    ip,
    COUNT(*) as 접근횟수,
    COUNT(DISTINCT path) as 방문페이지수,
    SUM(size) as 총전송량,
    MIN(timestamp) as 첫접근,
    MAX(timestamp) as 마지막접근
FROM access_logs
GROUP BY ip
ORDER BY 접근횟수 DESC;

-- 시간대별 트래픽 분석
SELECT '=== 시간대별 트래픽 ===' as info;
SELECT
    SUBSTR(timestamp, 12, 2) as 시간,
    COUNT(*) as 요청수,
    SUM(size) as 총크기,
    AVG(size) as 평균크기
FROM access_logs
GROUP BY SUBSTR(timestamp, 12, 2)
ORDER BY 시간;

-- 에러 요청 상세 분석
SELECT '=== 에러 요청 분석 ===' as info;
SELECT
    timestamp,
    ip,
    method,
    path,
    status,
    size
FROM access_logs
WHERE status >= 400
ORDER BY timestamp;

-- 페이지별 인기도
SELECT '=== 페이지 인기도 ===' as info;
SELECT
    path,
    COUNT(*) as 접근횟수,
    COUNT(DISTINCT ip) as 순방문자수,
    AVG(size) as 평균응답크기
FROM access_logs
WHERE status = 200
GROUP BY path
ORDER BY 접근횟수 DESC;
EOF

echo "✅ 로그 분석 완료: results/03_json_analytics.txt"

echo ""
echo "📋 6. 실행 결과 요약"
echo "----------------------------------------"
echo "생성된 데이터 파일들:"
ls -la data/json_demo/

echo ""
echo "생성된 결과 파일들:"
ls -la results/demo_results/03_json_*.txt

echo ""
echo "🎯 JSON Storage 특징 요약:"
echo "  ✅ JSON/JSONL 파일을 직접 쿼리"
echo "  ✅ 스키마 선택적 (있어도 되고 없어도 됨)"
echo "  ✅ 로그 분석에 최적화"
echo "  ✅ 중첩된 JSON 데이터 처리 가능"
echo "  ✅ 파일 기반 영구 저장"
echo "  ⚠️  대용량 데이터시 성능 제한"

echo ""
echo "💡 사용 시나리오:"
echo "  - 로그 파일 분석"
echo "  - API 응답 데이터 분석"
echo "  - 설정 파일 관리"
echo "  - 비정형 데이터 처리"
echo "  - ETL 프로세스 중간 저장소"

echo ""
echo "🎉 JSON Storage Demo 완료!"
