-- Memory Storage Basic SQL
-- Generated from 01_memory_demo

-- Memory Storage 기본 사용법
CREATE TABLE employees (
    id INTEGER,
    name TEXT,
    department TEXT,
    salary INTEGER,
    hire_date TEXT
);

-- 샘플 데이터 삽입
INSERT INTO employees VALUES
    (1, '김철수', 'IT', 5500, '2020-01-15'),
    (2, '이영희', 'HR', 4800, '2019-03-22'),
    (3, '박민수', 'IT', 6200, '2021-06-10'),
    (4, '최지연', 'Marketing', 4900, '2020-09-05'),
    (5, '정현우', 'Finance', 5800, '2018-12-03');

-- 기본 조회
SELECT '=== 전체 직원 목록 ===' as info;
SELECT * FROM employees ORDER BY salary DESC;

-- 조건 조회
SELECT '=== IT 부서 직원 ===' as info;
SELECT name, salary FROM employees WHERE department = 'IT';

-- 집계 쿼리
SELECT '=== 부서별 통계 ===' as info;
SELECT
    department,
    COUNT(*) as 직원수,
    AVG(salary) as 평균급여,
    MAX(salary) as 최고급여,
    MIN(salary) as 최저급여
FROM employees
GROUP BY department
ORDER BY 평균급여 DESC;
