-- Json Storage Basic SQL
-- Generated from 03_json_demo

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
