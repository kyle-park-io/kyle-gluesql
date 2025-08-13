const { gluesql } = require('../../pkg/javascript/gluesql.node.js');

async function runCompositeDemo() {
  console.log('🌐 JavaScript Composite Storage Demo');

  // GlueSQL 인스턴스 생성 (자동으로 Composite Storage 사용)
  const db = gluesql();

  // 1. 각 저장소별 테이블 생성
  await db.query(`
        -- Memory Storage: 임시 세션 데이터
        CREATE TABLE temp_sessions (
            user_id INTEGER,
            session_id TEXT,
            created_at TEXT
        ) ENGINE = memory;

        -- LocalStorage: 사용자 설정 (브라우저 환경에서)
        CREATE TABLE user_preferences (
            user_id INTEGER,
            theme TEXT,
            language TEXT
        ) ENGINE = localStorage;
    `);

  // 2. 데이터 삽입
  await db.query(`
        INSERT INTO temp_sessions VALUES
            (1, 'sess_001', '2024-01-01 09:00:00'),
            (2, 'sess_002', '2024-01-01 09:15:00'),
            (3, 'sess_003', '2024-01-01 09:30:00');

        INSERT INTO user_preferences VALUES
            (1, 'dark', 'ko'),
            (2, 'light', 'en'),
            (3, 'auto', 'ko');
    `);

  // 3. 멀티 저장소 조인
  const result = await db.query(`
        SELECT
            s.user_id,
            s.session_id,
            p.theme,
            p.language
        FROM temp_sessions s
        JOIN user_preferences p ON s.user_id = p.user_id
        ORDER BY s.created_at
    `);

  console.log('멀티 저장소 조인 결과:');
  console.table(result[0].rows);

  console.log('✅ JavaScript Composite Demo 완료');
}

// Node.js 환경에서만 실행
if (typeof require !== 'undefined' && require.main === module) {
  runCompositeDemo().catch(console.error);
}

module.exports = { runCompositeDemo };
