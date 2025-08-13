-- File Storage Basic SQL
-- Generated from 08_file_demo

-- File Storage 시뮬레이션 (실제로는 파일시스템에 저장됨)

CREATE TABLE documents (
    id INTEGER,
    title TEXT,
    content TEXT,
    author TEXT,
    created_at TEXT,
    file_size INTEGER
);

INSERT INTO documents VALUES
    (1, 'README.md', 'Project documentation', 'alice', '2024-01-01', 1024),
    (2, 'config.json', 'Configuration file', 'bob', '2024-01-02', 512),
    (3, 'main.rs', 'Main source code', 'charlie', '2024-01-03', 2048);

SELECT '=== File Storage 특징 ===' as info;
SELECT * FROM documents;

SELECT 'File Storage는 각 테이블을 디렉토리로, 각 행을 RON 파일로 저장합니다' as description;
