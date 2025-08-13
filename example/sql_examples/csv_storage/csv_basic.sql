-- Csv Storage Basic SQL
-- Generated from 04_csv_demo

-- CSV Storage 기본 사용법

-- 직원 데이터 조회
SELECT '=== 전체 직원 목록 ===' as info;
SELECT * FROM employees ORDER BY salary DESC;

-- 부서별 직원 현황
SELECT '=== 부서별 직원 현황 ===' as info;
SELECT
    department,
    COUNT(*) as 인원수,
    AVG(salary) as 평균급여,
    MAX(salary) as 최고급여,
    MIN(salary) as 최저급여,
    AVG(age) as 평균나이
FROM employees
GROUP BY department
ORDER BY 평균급여 DESC;

-- 연령대별 분석
SELECT '=== 연령대별 분석 ===' as info;
SELECT
    CASE
        WHEN age < 25 THEN '20대 초반'
        WHEN age < 30 THEN '20대 후반'
        WHEN age < 35 THEN '30대 초반'
        ELSE '30대 후반+'
    END as 연령대,
    COUNT(*) as 인원수,
    AVG(salary) as 평균급여
FROM employees
GROUP BY
    CASE
        WHEN age < 25 THEN '20대 초반'
        WHEN age < 30 THEN '20대 후반'
        WHEN age < 35 THEN '30대 초반'
        ELSE '30대 후반+'
    END
ORDER BY 평균급여 DESC;

-- 입사년도별 통계
SELECT '=== 입사년도별 통계 ===' as info;
SELECT
    SUBSTR(hire_date, 1, 4) as 입사년도,
    COUNT(*) as 신규입사자,
    AVG(salary) as 당시평균급여
FROM employees
GROUP BY SUBSTR(hire_date, 1, 4)
ORDER BY 입사년도;
