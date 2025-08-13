-- Composite Storage Analytics SQL
-- Generated from 13_composite_demo

-- CSV Storage: 급여 정보
SELECT '=== CSV: 급여 정보 ===' as info;
SELECT * FROM salaries ORDER BY employee_id, year;

SELECT '=== CSV: 2024년 급여 통계 ===' as info;
SELECT
    employee_id,
    base_salary + bonus as total_salary
FROM salaries
WHERE year = 2024
ORDER BY total_salary DESC;
