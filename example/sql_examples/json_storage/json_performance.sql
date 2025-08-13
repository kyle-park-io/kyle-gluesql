-- Json Storage Performance SQL
-- Generated from 03_json_demo

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
