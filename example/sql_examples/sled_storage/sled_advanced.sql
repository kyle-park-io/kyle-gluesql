-- Sled Storage Advanced SQL
-- Generated from 06_sled_demo

-- Sled Storage의 트랜잭션 기능 테스트

-- 급여 인상 트랜잭션 시뮬레이션
BEGIN;

-- IT 부서 직원들의 급여를 10% 인상
UPDATE employees
SET salary = CAST(salary * 1.1 AS INTEGER)
WHERE department = 'IT';

-- 부서 예산도 함께 조정
UPDATE departments
SET budget = budget + 15000
WHERE dept_name = 'IT';

-- 트랜잭션 확인을 위한 조회
SELECT '=== 트랜잭션 중 상태 확인 ===' as info;
SELECT
    e.name,
    e.department,
    e.salary,
    d.budget as dept_budget
FROM employees e
JOIN departments d ON e.department = d.dept_name
WHERE e.department = 'IT'
ORDER BY e.salary DESC;

COMMIT;

SELECT '=== 트랜잭션 커밋 후 최종 상태 ===' as info;
SELECT
    e.name,
    e.department,
    e.salary,
    d.budget as dept_budget
FROM employees e
JOIN departments d ON e.department = d.dept_name
WHERE e.department = 'IT'
ORDER BY e.salary DESC;

-- 제약 조건 테스트 (PRIMARY KEY, UNIQUE)
SELECT '=== 제약 조건 테스트 ===' as info;

-- 성공적인 삽입
INSERT INTO employees VALUES
    (9, '신입사원', 'new@company.com', 'IT', 4000, '2024-01-01', 1);

-- 중복 이메일 삽입 시도 (실패해야 함)
-- INSERT INTO employees VALUES (10, '중복이메일', 'kim@company.com', 'IT', 4000, '2024-01-01', 1);

SELECT '신입사원 추가 성공' as result;

-- 복잡한 집계 쿼리 (인덱스 성능 확인)
SELECT '=== 부서별 상세 통계 ===' as info;
SELECT
    d.dept_name,
    d.budget,
    COUNT(e.id) as employee_count,
    COALESCE(SUM(e.salary), 0) as total_salaries,
    COALESCE(AVG(e.salary), 0) as avg_salary,
    d.budget - COALESCE(SUM(e.salary), 0) as remaining_budget,
    CASE
        WHEN COUNT(e.id) > 0 THEN ROUND((COALESCE(SUM(e.salary), 0) * 100.0 / d.budget), 2)
        ELSE 0
    END as budget_utilization_percent
FROM departments d
LEFT JOIN employees e ON d.dept_name = e.department
GROUP BY d.dept_id, d.dept_name, d.budget
ORDER BY budget_utilization_percent DESC;
