#!/bin/bash

# =============================================================================
# GlueSQL CSV Storage Demo
# CSV 저장소 - CSV 파일을 데이터베이스로 활용
# =============================================================================

echo "📊 GlueSQL CSV Storage Demo"
echo "==========================="
echo "✨ 특징: CSV 파일에 직접 SQL 쿼리, 스프레드시트 데이터 분석 최적화"
echo ""

# 결과 및 데이터 디렉토리 생성
mkdir -p ../results data/csv_demo

echo "📈 1. CSV 데이터 파일 생성"
echo "----------------------------------------"

# 직원 데이터 CSV
cat > data/csv_demo/employees.csv << 'EOF'
id,name,department,salary,hire_date,age
1,김철수,IT,5500,2020-01-15,30
2,이영희,HR,4800,2019-03-22,28
3,박민수,IT,6200,2021-06-10,32
4,최지연,Marketing,4900,2020-09-05,26
5,정현우,Finance,5800,2018-12-03,35
6,김영수,IT,4500,2022-02-14,24
7,이미영,HR,5200,2021-11-28,29
8,박준호,Marketing,5100,2020-04-17,31
EOF

# 판매 데이터 CSV
cat > data/csv_demo/sales.csv << 'EOF'
id,employee_id,product,price,quantity,sale_date,customer_type
1,1,노트북,1200000,1,2024-01-01,기업
2,3,마우스,25000,5,2024-01-01,개인
3,4,키보드,80000,2,2024-01-02,개인
4,2,모니터,300000,1,2024-01-02,기업
5,5,헤드셋,150000,3,2024-01-03,개인
6,1,태블릿,800000,1,2024-01-03,개인
7,6,스피커,120000,2,2024-01-04,기업
8,7,웹캠,60000,4,2024-01-04,개인
9,3,키보드,80000,1,2024-01-05,개인
10,8,마우스,25000,10,2024-01-05,기업
EOF

# 부서 예산 CSV
cat > data/csv_demo/departments.csv << 'EOF'
dept_name,budget,manager,location,established
IT,150000000,김철수,서울,2010
HR,80000000,이영희,서울,2008
Marketing,120000000,최지연,부산,2012
Finance,100000000,정현우,서울,2005
EOF

# 고객 정보 CSV
cat > data/csv_demo/customers.csv << 'EOF'
id,name,email,phone,city,registration_date
1,ABC기업,abc@company.com,02-1234-5678,서울,2020-01-01
2,홍길동,hong@email.com,010-1111-2222,부산,2021-05-15
3,XYZ코퍼레이션,xyz@corp.com,02-9999-8888,서울,2019-12-20
4,김개인,kim@personal.com,010-3333-4444,대구,2022-03-10
5,DEF엔터프라이즈,def@enterprise.com,051-7777-6666,부산,2021-08-25
EOF

echo "✅ CSV 데이터 파일 생성 완료"

echo ""
echo "🔍 2. CSV 파일 기본 쿼리"
echo "----------------------------------------"

../bin/gluesql-cli -s csv -p data/csv_demo -e - > results/demo_results/04_csv_basic.txt 2>&1 << 'EOF'
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
EOF

echo "✅ CSV 기본 쿼리 완료: results/04_csv_basic.txt"

echo ""
echo "🔗 3. CSV 파일 간 조인 분석"
echo "----------------------------------------"

../bin/gluesql-cli -s csv -p data/csv_demo -e - > results/demo_results/04_csv_joins.txt 2>&1 << 'EOF'
-- CSV 파일 간 조인 쿼리

-- 직원과 판매 실적 조인
SELECT '=== 직원별 판매 실적 ===' as info;
SELECT
    e.name,
    e.department,
    COUNT(s.id) as 판매건수,
    SUM(s.price * s.quantity) as 총매출,
    AVG(s.price * s.quantity) as 평균거래액
FROM employees e
LEFT JOIN sales s ON e.id = s.employee_id
GROUP BY e.id, e.name, e.department
ORDER BY 총매출 DESC;

-- 부서별 성과 분석
SELECT '=== 부서별 성과 분석 ===' as info;
SELECT
    d.dept_name,
    d.budget,
    d.manager,
    d.location,
    COUNT(e.id) as 직원수,
    SUM(e.salary) as 총급여비용,
    COALESCE(SUM(s.price * s.quantity), 0) as 총매출,
    d.budget - SUM(e.salary) as 급여후예산여유,
    CASE
        WHEN SUM(s.price * s.quantity) > 0
        THEN ROUND(SUM(s.price * s.quantity) / SUM(e.salary), 2)
        ELSE 0
    END as 매출대급여비율
FROM departments d
LEFT JOIN employees e ON d.dept_name = e.department
LEFT JOIN sales s ON e.id = s.employee_id
GROUP BY d.dept_name, d.budget, d.manager, d.location
ORDER BY 매출대급여비율 DESC;

-- 고성과자 분석 (매출 상위 직원)
SELECT '=== 고성과자 분석 ===' as info;
SELECT
    e.name,
    e.department,
    e.salary,
    SUM(s.price * s.quantity) as 개인매출,
    COUNT(s.id) as 거래건수,
    AVG(s.price * s.quantity) as 평균거래액,
    ROUND(SUM(s.price * s.quantity) / e.salary, 2) as 매출대급여비율
FROM employees e
JOIN sales s ON e.id = s.employee_id
GROUP BY e.id, e.name, e.department, e.salary
HAVING SUM(s.price * s.quantity) > 100000
ORDER BY 개인매출 DESC;
EOF

echo "✅ CSV 조인 분석 완료: results/04_csv_joins.txt"

echo ""
echo "📊 4. 시계열 데이터 분석"
echo "----------------------------------------"

../bin/gluesql-cli -s csv -p data/csv_demo -e - > results/demo_results/04_csv_timeseries.txt 2>&1 << 'EOF'
-- CSV를 활용한 시계열 분석

-- 일별 매출 추이
SELECT '=== 일별 매출 추이 ===' as info;
SELECT
    sale_date,
    COUNT(*) as 거래건수,
    SUM(price * quantity) as 일매출,
    AVG(price * quantity) as 평균거래액,
    COUNT(DISTINCT employee_id) as 활동직원수
FROM sales
GROUP BY sale_date
ORDER BY sale_date;

-- 고객 유형별 매출 분석
SELECT '=== 고객 유형별 매출 분석 ===' as info;
SELECT
    customer_type,
    COUNT(*) as 거래건수,
    SUM(price * quantity) as 총매출,
    AVG(price * quantity) as 평균거래액,
    MIN(price * quantity) as 최소거래액,
    MAX(price * quantity) as 최대거래액
FROM sales
GROUP BY customer_type
ORDER BY 총매출 DESC;

-- 제품별 판매 현황
SELECT '=== 제품별 판매 현황 ===' as info;
SELECT
    product,
    COUNT(*) as 판매횟수,
    SUM(quantity) as 총판매수량,
    SUM(price * quantity) as 총매출,
    AVG(price) as 평균단가,
    COUNT(DISTINCT employee_id) as 판매직원수
FROM sales
GROUP BY product
ORDER BY 총매출 DESC;

-- 월별 트렌드 분석 (가상의 월별 데이터)
SELECT '=== 일별 성장률 분석 ===' as info;
SELECT
    sale_date,
    SUM(price * quantity) as 일매출,
    LAG(SUM(price * quantity)) OVER (ORDER BY sale_date) as 전일매출,
    CASE
        WHEN LAG(SUM(price * quantity)) OVER (ORDER BY sale_date) > 0
        THEN ROUND(
            (SUM(price * quantity) - LAG(SUM(price * quantity)) OVER (ORDER BY sale_date)) * 100.0 /
            LAG(SUM(price * quantity)) OVER (ORDER BY sale_date), 2
        )
        ELSE NULL
    END as 전일대비성장률
FROM sales
GROUP BY sale_date
ORDER BY sale_date;
EOF

echo "✅ 시계열 분석 완료: results/04_csv_timeseries.txt"

echo ""
echo "⚡ 5. CSV 데이터 집계 및 통계"
echo "----------------------------------------"

../bin/gluesql-cli -s csv -p data/csv_demo -e - > results/demo_results/04_csv_analytics.txt 2>&1 << 'EOF'
-- CSV 고급 분석 및 통계

-- 전체 비즈니스 KPI
SELECT '=== 주요 KPI 지표 ===' as info;
SELECT
    '전체 현황' as 구분,
    (SELECT COUNT(*) FROM employees) as 총직원수,
    (SELECT COUNT(*) FROM sales) as 총거래건수,
    (SELECT SUM(price * quantity) FROM sales) as 총매출,
    (SELECT AVG(salary) FROM employees) as 평균급여,
    (SELECT COUNT(DISTINCT product) FROM sales) as 판매상품수;

-- 상위 10% 직원 분석
WITH employee_sales AS (
    SELECT
        e.id,
        e.name,
        e.department,
        e.salary,
        COALESCE(SUM(s.price * s.quantity), 0) as total_sales
    FROM employees e
    LEFT JOIN sales s ON e.id = s.employee_id
    GROUP BY e.id, e.name, e.department, e.salary
),
sales_rank AS (
    SELECT
        *,
        RANK() OVER (ORDER BY total_sales DESC) as sales_rank,
        COUNT(*) OVER () as total_employees
    FROM employee_sales
)
SELECT '=== 상위 성과자 (상위 30%) ===' as info;
SELECT
    name,
    department,
    salary,
    total_sales,
    sales_rank,
    ROUND(sales_rank * 100.0 / total_employees, 1) as 백분위순위
FROM sales_rank
WHERE sales_rank <= CAST(total_employees * 0.3 AS INTEGER)
ORDER BY sales_rank;

-- 부서 효율성 분석
SELECT '=== 부서 효율성 순위 ===' as info;
SELECT
    d.dept_name,
    COUNT(e.id) as 직원수,
    SUM(e.salary) as 부서급여총액,
    COALESCE(SUM(s.price * s.quantity), 0) as 부서매출총액,
    ROUND(COALESCE(SUM(s.price * s.quantity), 0) / COUNT(e.id), 0) as 직원당매출,
    ROUND(COALESCE(SUM(s.price * s.quantity), 0) / SUM(e.salary), 2) as 급여대비매출비율,
    RANK() OVER (ORDER BY COALESCE(SUM(s.price * s.quantity), 0) / COUNT(e.id) DESC) as 효율성순위
FROM departments d
LEFT JOIN employees e ON d.dept_name = e.department
LEFT JOIN sales s ON e.id = s.employee_id
GROUP BY d.dept_name
ORDER BY 효율성순위;

-- 제품 카테고리별 분석 (가정: 첫 글자로 카테고리 구분)
SELECT '=== 제품 카테고리 분석 ===' as info;
SELECT
    CASE
        WHEN product LIKE '노트북%' OR product LIKE '태블릿%' THEN '컴퓨터'
        WHEN product LIKE '마우스%' OR product LIKE '키보드%' THEN '입력장치'
        WHEN product LIKE '모니터%' OR product LIKE '스피커%' THEN '출력장치'
        ELSE '기타'
    END as 제품카테고리,
    COUNT(*) as 거래건수,
    SUM(quantity) as 총판매수량,
    SUM(price * quantity) as 카테고리매출,
    AVG(price) as 평균단가,
    AVG(quantity) as 평균구매수량
FROM sales
GROUP BY
    CASE
        WHEN product LIKE '노트북%' OR product LIKE '태블릿%' THEN '컴퓨터'
        WHEN product LIKE '마우스%' OR product LIKE '키보드%' THEN '입력장치'
        WHEN product LIKE '모니터%' OR product LIKE '스피커%' THEN '출력장치'
        ELSE '기타'
    END
ORDER BY 카테고리매출 DESC;

-- CSV 저장소 성능 테스트 결과
SELECT '=== CSV Storage 분석 완료 ===' as result;
SELECT 'CSV 파일을 실시간 데이터베이스로 활용하여 복잡한 분석 쿼리 실행 완료' as description;
EOF

echo "✅ CSV 고급 분석 완료: results/04_csv_analytics.txt"

echo ""
echo "📋 6. 실행 결과 요약"
echo "----------------------------------------"

echo "생성된 CSV 데이터 파일들:"
ls -la data/csv_demo/

echo ""
echo "각 CSV 파일의 구조:"
echo "📄 employees.csv - 직원 정보 (8명)"
head -3 data/csv_demo/employees.csv

echo ""
echo "📄 sales.csv - 판매 데이터 (10건)"
head -3 data/csv_demo/sales.csv

echo ""
echo "📄 departments.csv - 부서 정보 (4개 부서)"
head -3 data/csv_demo/departments.csv

echo ""
echo "생성된 결과 파일들:"
ls -la results/demo_results/04_csv_*.txt

echo ""
echo "🎯 CSV Storage 특징 요약:"
echo "  ✅ CSV 파일을 직접 SQL로 쿼리"
echo "  ✅ 복잡한 집계 및 조인 연산 지원"
echo "  ✅ 엑셀/스프레드시트 데이터 분석에 최적화"
echo "  ✅ 윈도우 함수, 서브쿼리 등 고급 SQL 기능"
echo "  ✅ 파일 기반 영구 저장"
echo "  ⚠️  스키마가 첫 번째 행으로 고정"
echo "  ⚠️  데이터 타입 자동 추론 의존"

echo ""
echo "💡 사용 시나리오:"
echo "  - 엑셀/구글 시트 데이터 분석"
echo "  - 비즈니스 인텔리전스 (BI)"
echo "  - 데이터 마이그레이션 중간 단계"
echo "  - 레거시 시스템 데이터 분석"
echo "  - 재무 및 판매 데이터 리포팅"

echo ""
echo "📈 분석된 내용:"
echo "  - 부서별 성과 및 효율성"
echo "  - 직원별 판매 실적"
echo "  - 시계열 매출 추이"
echo "  - 제품별/고객별 세분화 분석"
echo "  - KPI 및 통계 지표"

echo ""
echo "🎉 CSV Storage Demo 완료!"
