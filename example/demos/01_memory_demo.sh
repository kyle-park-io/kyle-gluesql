#!/bin/bash

# =============================================================================
# GlueSQL Memory Storage Demo
# 메모리 저장소 - 고성능 인메모리 데이터베이스
# =============================================================================

echo "🧠 GlueSQL Memory Storage Demo"
echo "================================="
echo "✨ 특징: 초고속 처리, 애플리케이션 종료시 데이터 소실"
echo ""

# 결과 디렉토리 생성
mkdir -p results/demo_results

echo "📊 1. 기본 테이블 생성 및 데이터 삽입"
echo "----------------------------------------"

# Memory Storage로 기본 CRUD 작업
cat << 'EOF' | ../bin/gluesql-cli -s memory > results/demo_results/01_memory_basic.txt 2>&1
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
EOF

echo "✅ 기본 CRUD 작업 완료: results/demo_results/01_memory_basic.txt"

echo ""
echo "🔄 2. 복잡한 쿼리 및 트랜잭션 테스트"
echo "----------------------------------------"

cat << 'EOF' | ../bin/gluesql-cli -s memory > results/demo_results/01_memory_advanced.txt 2>&1
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
EOF

echo "✅ 고급 쿼리 테스트 완료: results/demo_results/01_memory_advanced.txt"

echo ""
echo "⚡ 3. 성능 테스트 - 대량 데이터 처리"
echo "----------------------------------------"

cat << 'EOF' | ../bin/gluesql-cli -s memory > results/demo_results/01_memory_performance.txt 2>&1
-- 메모리 저장소 성능 테스트

-- 대량 데이터를 위한 테이블 생성
CREATE TABLE performance_test (
    id INTEGER,
    category TEXT,
    value FLOAT,
    created_at TEXT
);

-- 대량 데이터 삽입 (시뮬레이션)
INSERT INTO performance_test VALUES
    (1, 'A', 10.5, '2024-01-01'),
    (2, 'B', 20.3, '2024-01-01'),
    (3, 'A', 15.7, '2024-01-02'),
    (4, 'C', 30.1, '2024-01-02'),
    (5, 'B', 25.9, '2024-01-03'),
    (6, 'A', 12.3, '2024-01-03'),
    (7, 'C', 35.6, '2024-01-04'),
    (8, 'B', 22.8, '2024-01-04'),
    (9, 'A', 18.4, '2024-01-05'),
    (10, 'C', 28.7, '2024-01-05');

-- 집계 성능 테스트
SELECT '=== 카테고리별 통계 (메모리 저장소) ===' as info;
SELECT
    category,
    COUNT(*) as 데이터수,
    AVG(value) as 평균값,
    SUM(value) as 합계,
    MIN(value) as 최솟값,
    MAX(value) as 최댓값,
    MAX(value) - MIN(value) as 범위
FROM performance_test
GROUP BY category
ORDER BY 평균값 DESC;

-- 복잡한 윈도우 함수
SELECT '=== 이동 평균 계산 ===' as info;
SELECT
    id,
    category,
    value,
    AVG(value) OVER (PARTITION BY category ORDER BY id ROWS BETWEEN 1 PRECEDING AND 1 FOLLOWING) as 이동평균
FROM performance_test
ORDER BY category, id;

SELECT '=== 메모리 저장소 성능 테스트 완료 ===' as result;
SELECT '메모리 저장소는 모든 데이터가 RAM에 저장되어 최고 성능을 제공합니다' as description;
EOF

echo "✅ 성능 테스트 완료: results/demo_results/01_memory_performance.txt"

echo ""
echo "📋 4. 실행 결과 요약"
echo "----------------------------------------"
echo "생성된 결과 파일들:"
ls -la results/demo_results/01_memory_*.txt 2>/dev/null || echo "결과 파일이 아직 생성되지 않았습니다."

echo ""
echo "🎯 Memory Storage 특징 요약:"
echo "  ✅ 초고속 처리 (모든 데이터가 메모리에)"
echo "  ✅ 복잡한 조인, 집계, 윈도우 함수 지원"
echo "  ✅ 완전한 SQL 기능 지원"
echo "  ⚠️  애플리케이션 종료시 데이터 소실"
echo "  ⚠️  메모리 사용량 높음"
echo ""
echo "💡 사용 시나리오:"
echo "  - 임시 데이터 처리"
echo "  - 캐싱"
echo "  - 테스트 환경"
echo "  - 고성능 인메모리 분석"

echo ""
echo "🎉 Memory Storage Demo 완료!"
