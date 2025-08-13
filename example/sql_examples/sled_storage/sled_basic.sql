-- Sled Storage Basic SQL
-- Generated from 06_sled_demo

-- Sled Storage는 GlueSQL에서 가장 완전한 기능을 제공하는 저장소입니다

-- 기본 테이블 생성
CREATE TABLE employees (
    id INTEGER PRIMARY KEY,
    name TEXT NOT NULL,
    email TEXT UNIQUE,
    department TEXT,
    salary INTEGER,
    hire_date TEXT,
    manager_id INTEGER
);

-- 인덱스 생성 (Sled Storage만 지원)
CREATE INDEX idx_employee_department ON employees (department);
CREATE INDEX idx_employee_salary ON employees (salary);

-- 부서 테이블
CREATE TABLE departments (
    dept_id INTEGER PRIMARY KEY,
    dept_name TEXT UNIQUE NOT NULL,
    budget INTEGER,
    manager_id INTEGER
);

-- 기본 데이터 삽입
INSERT INTO employees VALUES
    (1, '김철수', 'kim@company.com', 'IT', 5500, '2020-01-15', NULL),
    (2, '이영희', 'lee@company.com', 'HR', 4800, '2019-03-22', NULL),
    (3, '박민수', 'park@company.com', 'IT', 6200, '2021-06-10', 1),
    (4, '최지연', 'choi@company.com', 'Marketing', 4900, '2020-09-05', NULL),
    (5, '정현우', 'jung@company.com', 'Finance', 5800, '2018-12-03', NULL),
    (6, '김영수', 'kim2@company.com', 'IT', 4500, '2022-02-14', 1),
    (7, '이미영', 'lee2@company.com', 'HR', 5200, '2021-11-28', 2),
    (8, '박준호', 'park2@company.com', 'Marketing', 5100, '2020-04-17', 4);

INSERT INTO departments VALUES
    (1, 'IT', 150000, 1),
    (2, 'HR', 80000, 2),
    (3, 'Marketing', 120000, 4),
    (4, 'Finance', 100000, 5);

SELECT '=== 기본 데이터 확인 ===' as info;
SELECT * FROM employees ORDER BY id;

SELECT '=== 인덱스 활용 쿼리 (부서별) ===' as info;
SELECT department, COUNT(*) as employee_count, AVG(salary) as avg_salary
FROM employees
GROUP BY department
ORDER BY avg_salary DESC;

SELECT '=== 외래키 관계 (매니저-직원) ===' as info;
SELECT
    e.name as employee,
    e.department,
    e.salary,
    m.name as manager
FROM employees e
LEFT JOIN employees m ON e.manager_id = m.id
ORDER BY e.department, e.name;
