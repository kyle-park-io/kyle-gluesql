-- Memory Storage Advanced SQL
-- Generated from 01_memory_demo

-- 메모리 저장소 고급 기능 테스트

-- 프로젝트 테이블 생성
CREATE TABLE projects (
    id INTEGER,
    name TEXT,
    department TEXT,
    budget INTEGER,
    status TEXT
);

-- 프로젝트 데이터 삽입
INSERT INTO projects VALUES
    (1, 'ERP 시스템 구축', 'IT', 150000, 'active'),
    (2, '채용 시스템 개선', 'HR', 80000, 'completed'),
    (3, '마케팅 캠페인', 'Marketing', 120000, 'planning'),
    (4, '예산 관리 시스템', 'Finance', 200000, 'active');

-- 복잡한 조인 쿼리
SELECT '=== 부서별 직원 및 프로젝트 현황 ===' as info;
SELECT
    e.department,
    COUNT(DISTINCT e.id) as 직원수,
    COUNT(DISTINCT p.id) as 프로젝트수,
    AVG(e.salary) as 평균급여,
    SUM(p.budget) as 총예산
FROM employees e
LEFT JOIN projects p ON e.department = p.department
GROUP BY e.department
ORDER BY 총예산 DESC;

-- 서브쿼리 사용
SELECT '=== 평균 급여 이상 받는 직원들 ===' as info;
SELECT
    name,
    department,
    salary,
    salary - (SELECT AVG(salary) FROM employees) as 급여차이
FROM employees
WHERE salary > (SELECT AVG(salary) FROM employees)
ORDER BY salary DESC;

-- 윈도우 함수 (순위)
SELECT '=== 부서 내 급여 순위 ===' as info;
SELECT
    name,
    department,
    salary,
    RANK() OVER (PARTITION BY department ORDER BY salary DESC) as 부서내순위
FROM employees
ORDER BY department, 부서내순위;

-- 업데이트 및 삭제 테스트
UPDATE employees SET salary = salary * 1.1 WHERE department = 'IT';
SELECT '=== IT부서 급여 인상 후 ===' as info;
SELECT name, department, salary FROM employees WHERE department = 'IT';

-- 메모리 저장소 정보 확인
SELECT '=== 저장소 정보 ===' as info;
SHOW TABLES;
