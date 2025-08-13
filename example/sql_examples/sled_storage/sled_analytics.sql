-- Sled Storage Analytics SQL
-- Generated from 06_sled_demo

-- Sled Storage 고급 기능 테스트

-- 프로젝트 관리 테이블 추가
CREATE TABLE projects (
    project_id INTEGER PRIMARY KEY,
    project_name TEXT NOT NULL,
    department TEXT,
    start_date TEXT,
    end_date TEXT,
    budget INTEGER,
    status TEXT
);

-- 프로젝트 참여자 테이블 (다대다 관계)
CREATE TABLE project_assignments (
    assignment_id INTEGER PRIMARY KEY,
    project_id INTEGER,
    employee_id INTEGER,
    role TEXT,
    allocation_percent INTEGER,
    assigned_date TEXT
);

-- 인덱스 생성
CREATE INDEX idx_project_department ON projects (department);
CREATE INDEX idx_assignment_project ON project_assignments (project_id);
CREATE INDEX idx_assignment_employee ON project_assignments (employee_id);

-- 프로젝트 데이터 삽입
INSERT INTO projects VALUES
    (1, 'ERP 시스템 구축', 'IT', '2024-01-01', '2024-06-30', 200000, 'active'),
    (2, '채용 시스템 개선', 'HR', '2024-02-01', '2024-04-30', 80000, 'active'),
    (3, '마케팅 캠페인', 'Marketing', '2024-01-15', '2024-03-15', 120000, 'completed'),
    (4, '예산 관리 시스템', 'Finance', '2024-03-01', '2024-08-31', 150000, 'planning');

-- 프로젝트 할당 데이터
INSERT INTO project_assignments VALUES
    (1, 1, 1, 'Project Manager', 100, '2024-01-01'),
    (2, 1, 3, 'Senior Developer', 80, '2024-01-01'),
    (3, 1, 6, 'Junior Developer', 90, '2024-01-05'),
    (4, 2, 2, 'Project Manager', 100, '2024-02-01'),
    (5, 2, 7, 'HR Specialist', 70, '2024-02-01'),
    (6, 3, 4, 'Marketing Manager', 100, '2024-01-15'),
    (7, 3, 8, 'Marketing Coordinator', 60, '2024-01-15'),
    (8, 4, 5, 'Finance Manager', 80, '2024-03-01');

-- 복잡한 조인 쿼리 (3개 테이블)
SELECT '=== 프로젝트별 팀 구성 현황 ===' as info;
SELECT
    p.project_name,
    p.department,
    p.status,
    p.budget,
    COUNT(pa.employee_id) as team_size,
    GROUP_CONCAT(e.name || '(' || pa.role || ')') as team_members,
    SUM(pa.allocation_percent) as total_allocation,
    AVG(e.salary) as avg_team_salary
FROM projects p
LEFT JOIN project_assignments pa ON p.project_id = pa.project_id
LEFT JOIN employees e ON pa.employee_id = e.id
GROUP BY p.project_id, p.project_name, p.department, p.status, p.budget
ORDER BY p.status, p.budget DESC;

-- 직원별 프로젝트 참여 현황
SELECT '=== 직원별 프로젝트 참여 현황 ===' as info;
SELECT
    e.name,
    e.department,
    e.salary,
    COUNT(pa.project_id) as project_count,
    GROUP_CONCAT(p.project_name) as projects,
    SUM(pa.allocation_percent) as total_allocation,
    CASE
        WHEN SUM(pa.allocation_percent) > 100 THEN 'Overallocated'
        WHEN SUM(pa.allocation_percent) = 100 THEN 'Fully Allocated'
        WHEN SUM(pa.allocation_percent) > 0 THEN 'Partially Allocated'
        ELSE 'Not Allocated'
    END as allocation_status
FROM employees e
LEFT JOIN project_assignments pa ON e.id = pa.employee_id
LEFT JOIN projects p ON pa.project_id = p.project_id AND p.status = 'active'
GROUP BY e.id, e.name, e.department, e.salary
ORDER BY total_allocation DESC;

-- 윈도우 함수를 활용한 분석
SELECT '=== 부서별 급여 순위 및 분석 ===' as info;
SELECT
    name,
    department,
    salary,
    RANK() OVER (PARTITION BY department ORDER BY salary DESC) as dept_rank,
    DENSE_RANK() OVER (ORDER BY salary DESC) as company_rank,
    salary - AVG(salary) OVER (PARTITION BY department) as dept_salary_diff,
    ROUND((salary * 100.0 / SUM(salary) OVER (PARTITION BY department)), 2) as dept_salary_percent
FROM employees
ORDER BY department, dept_rank;

-- 데이터 무결성 확인
SELECT '=== 데이터 무결성 검사 ===' as info;

-- 모든 매니저가 실제 직원인지 확인
SELECT
    'Manager Integrity Check' as check_type,
    COUNT(*) as violations
FROM employees e1
WHERE e1.manager_id IS NOT NULL
AND NOT EXISTS (
    SELECT 1 FROM employees e2 WHERE e2.id = e1.manager_id
);

-- 모든 프로젝트 할당이 유효한 직원인지 확인
SELECT
    'Project Assignment Integrity Check' as check_type,
    COUNT(*) as violations
FROM project_assignments pa
WHERE NOT EXISTS (
    SELECT 1 FROM employees e WHERE e.id = pa.employee_id
);

SELECT '=== Sled Storage 고급 기능 테스트 완료 ===' as result;
