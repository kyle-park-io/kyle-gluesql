#!/bin/bash

echo "💾 GlueSQL IndexedDB Storage Demo"
echo "=================================="
echo "✨ 특징: 브라우저 고급 로컬 데이터베이스를 SQL로 사용"
echo ""

mkdir -p results/demo_results

cat << 'EOF' > results/demo_results/12_idb_simulation.txt
=== IndexedDB Storage Demo ===

IndexedDB는 브라우저의 고급 로컬 데이터베이스입니다:

JavaScript 예제:
```javascript
import { gluesql } from 'gluesql';

const db = await gluesql();
await db.loadIndexedDB();

// IndexedDB 테이블 생성
await db.query(`
    CREATE TABLE offline_posts ENGINE = indexedDB;
    INSERT INTO offline_posts VALUES 
        (1, 'First Post', 'This is my first post', '2024-01-01'),
        (2, 'Second Post', 'Another great post', '2024-01-02');
        
    CREATE TABLE user_data ENGINE = indexedDB;
    INSERT INTO user_data VALUES
        ('preferences', '{"theme": "dark", "notifications": true}'),
        ('cache', '{"last_sync": "2024-01-01T10:00:00Z"}');
`);

// 복잡한 오프라인 쿼리
const posts = await db.query(`
    SELECT * FROM offline_posts 
    WHERE title LIKE '%Post%'
    ORDER BY id DESC;
`);
```

특징:
✅ 대용량 로컬 데이터 저장
✅ 트랜잭션 지원
✅ 인덱스 지원으로 빠른 검색
✅ 브라우저 간 호환성
✅ 오프라인 애플리케이션 지원

사용 시나리오:
- 오프라인 우선 웹 앱
- 대용량 클라이언트 데이터
- 동기화 대기 데이터
- 브라우저 기반 IDE/편집기

성능:
- 저장 용량: 브라우저 설정에 따라 GB 단위
- 쿼리 성능: 인덱스 활용으로 빠른 검색
- 동시성: 웹 워커에서 안전하게 사용 가능
EOF

echo "✅ IndexedDB 정보 생성 완료: results/demo_results/12_idb_simulation.txt"
echo "🎉 IndexedDB Storage Demo 완료!"
