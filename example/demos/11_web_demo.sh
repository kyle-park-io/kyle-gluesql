#!/bin/bash

echo "🌐 GlueSQL Web Storage Demo"
echo "==========================="
echo "✨ 특징: localStorage/sessionStorage를 SQL로 사용"
echo ""

mkdir -p results/demo_results

cat << 'EOF' > results/demo_results/11_web_simulation.txt
=== Web Storage (localStorage/sessionStorage) Demo ===

Web Storage는 브라우저 환경에서 사용됩니다:

JavaScript 예제:
```javascript
import { gluesql } from 'gluesql';

const db = await gluesql();

// localStorage 테이블
await db.query(`
    CREATE TABLE user_settings ENGINE = localStorage;
    INSERT INTO user_settings VALUES 
        ('theme', 'dark'),
        ('language', 'ko');
`);

// sessionStorage 테이블  
await db.query(`
    CREATE TABLE temp_data ENGINE = sessionStorage;
    INSERT INTO temp_data VALUES 
        ('cart_items', '3'),
        ('current_page', '/dashboard');
`);

// 브라우저 저장소 간 조인
const result = await db.query(`
    SELECT s.*, t.*
    FROM user_settings s
    CROSS JOIN temp_data t;
`);
```

특징:
✅ 브라우저 로컬 스토리지를 SQL로 쿼리
✅ localStorage: 영구 저장
✅ sessionStorage: 세션 동안만 저장
✅ 클라이언트 사이드 데이터베이스

사용 시나리오:
- 오프라인 웹 애플리케이션
- 사용자 설정 저장
- 임시 데이터 캐싱
- PWA (Progressive Web App)
EOF

echo "✅ Web Storage 정보 생성 완료: results/demo_results/11_web_simulation.txt"
echo "🎉 Web Storage Demo 완료!"
