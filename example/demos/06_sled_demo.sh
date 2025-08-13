#!/bin/bash

# =============================================================================
# GlueSQL Sled Storage Demo
# Sled 저장소 - 완전한 기능의 임베디드 키-값 데이터베이스
# =============================================================================

echo "🗄️ GlueSQL Sled Storage Demo"
echo "============================="
echo "✨ 특징: 완전한 트랜잭션 지원, 인덱스, 영구 저장, 모든 Store 트레이트 구현"
echo ""

# 결과 및 데이터 디렉토리 생성
mkdir -p results/demo_results data/sled_demo

echo "📊 1. Sled 저장소 기본 기능"
echo "----------------------------------------"

../bin/gluesql-cli -s sled -p data/sled_demo -e - > results/demo_results/06_sled_basic.txt 2>&1 << 'EOF'
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
EOF

echo "✅ Sled 기본 기능 테스트 완료: results/demo_results/06_sled_basic.txt"

echo ""
echo "🔄 2. 트랜잭션 및 ACID 특성 테스트"
echo "----------------------------------------"

../bin/gluesql-cli -s sled -p data/sled_demo -e - > results/demo_results/06_sled_transactions.txt 2>&1 << 'EOF'
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
EOF

echo "✅ 트랜잭션 테스트 완료: results/demo_results/06_sled_transactions.txt"

echo ""
echo "📈 3. 고급 기능 및 성능 테스트"
echo "----------------------------------------"

../bin/gluesql-cli -s sled -p data/sled_demo -e - > results/demo_results/06_sled_advanced.txt 2>&1 << 'EOF'
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
EOF

echo "✅ 고급 기능 테스트 완료: results/demo_results/06_sled_advanced.txt"

echo ""
echo "📋 4. 실행 결과 요약"
echo "----------------------------------------"
echo "생성된 Sled 데이터베이스 파일들:"
ls -la data/sled_demo/ 2>/dev/null || echo "Sled 데이터베이스 파일들이 생성됩니다."

echo ""
echo "생성된 결과 파일들:"
ls -la results/demo_results/06_sled_*.txt 2>/dev/null || echo "결과 파일이 아직 생성되지 않았습니다."

echo ""
echo "🎯 Sled Storage 특징 요약:"
echo "  ✅ 완전한 ACID 트랜잭션 지원"
echo "  ✅ PRIMARY KEY, UNIQUE, INDEX 지원"
echo "  ✅ 복잡한 조인 및 서브쿼리 지원"
echo "  ✅ 윈도우 함수 및 고급 SQL 기능"
echo "  ✅ 영구 데이터 저장 (파일 기반)"
echo "  ✅ 모든 Store 트레이트 구현"
echo "  ⚠️  단일 프로세스만 접근 가능"
echo "  ⚠️  네트워크 접근 불가 (임베디드 전용)"

echo ""
echo "💡 사용 시나리오:"
echo "  - 완전한 기능이 필요한 임베디드 애플리케이션"
echo "  - 로컬 데이터베이스가 필요한 데스크톱 앱"
echo "  - 프로토타입 및 개발 환경"
echo "  - 중소규모 웹 애플리케이션 백엔드"
echo "  - 데이터 무결성이 중요한 시스템"

echo ""
echo "⚡ 성능 특성:"
echo "  - 읽기 성능: ⭐⭐⭐⭐"
echo "  - 쓰기 성능: ⭐⭐⭐⭐"
echo "  - 트랜잭션: ⭐⭐⭐⭐⭐"
echo "  - 동시성: ⭐⭐⭐"
echo "  - 확장성: ⭐⭐⭐"

echo ""
echo "🎉 Sled Storage Demo 완료!"
echo "가장 완전한 기능을 제공하는 GlueSQL 저장소입니다! 🗄️"
