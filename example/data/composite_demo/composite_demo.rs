use gluesql::{
    gluesql_composite_storage::CompositeStorage,
    gluesql_memory_storage::MemoryStorage,
    gluesql_json_storage::JsonStorage,
    gluesql_csv_storage::CsvStorage,
    prelude::Glue,
};
use std::path::Path;

#[tokio::main]
async fn main() -> Result<(), Box<dyn std::error::Error>> {
    println!("🔗 Composite Storage 멀티 저장소 조인 데모");

    // 1. 각 저장소 생성
    let memory_storage = MemoryStorage::default();
    let json_storage = JsonStorage::new("data/composite_demo")?;
    let csv_storage = CsvStorage::new("data/composite_demo")?;

    // 2. Composite Storage 생성 및 저장소 등록
    let mut composite = CompositeStorage::new();
    composite.push("memory", memory_storage);
    composite.push("json", json_storage);
    composite.push("csv", csv_storage);

    let mut glue = Glue::new(composite);

    // 3. Memory에 세션 데이터 생성
    glue.execute("
        CREATE TABLE sessions (
            user_id INTEGER,
            login_time TEXT,
            device TEXT
        ) ENGINE = memory;

        INSERT INTO sessions VALUES
            (1, '2024-01-01 09:00:00', 'laptop'),
            (2, '2024-01-01 09:15:00', 'mobile'),
            (3, '2024-01-01 09:30:00', 'desktop'),
            (4, '2024-01-01 09:45:00', 'tablet');
    ").await?;

    // 4. 멀티 저장소 조인 쿼리
    println!("\n=== 멀티 저장소 조인 결과 ===");

    let result = glue.execute("
        SELECT
            u.name,
            u.department,
            s.login_time,
            s.device,
            sal.base_salary + sal.bonus as total_salary
        FROM users u                    -- JSON Storage
        JOIN sessions s ON u.id = s.user_id      -- Memory Storage
        JOIN salaries sal ON u.id = sal.employee_id  -- CSV Storage
        WHERE sal.year = 2024
        ORDER BY total_salary DESC
    ").await?;

    println!("{:#?}", result);

    // 5. 저장소별 통계
    let stats = glue.execute("
        SELECT
            u.department,
            COUNT(DISTINCT s.user_id) as active_users,
            AVG(sal.base_salary) as avg_salary,
            COUNT(s.login_time) as total_sessions
        FROM users u
        LEFT JOIN sessions s ON u.id = s.user_id
        LEFT JOIN salaries sal ON u.id = sal.employee_id AND sal.year = 2024
        GROUP BY u.department
        ORDER BY avg_salary DESC
    ").await?;

    println!("\n=== 부서별 통계 ===");
    println!("{:#?}", stats);

    Ok(())
}
