-- Composite Storage Basic SQL
-- Generated from 13_composite_demo

-- Memory Storage: 세션 데이터
CREATE TABLE sessions (
    user_id INTEGER,
    login_time TEXT,
    ip_address TEXT,
    device TEXT
);

INSERT INTO sessions VALUES
    (1, '2024-01-01 09:00:00', '192.168.1.100', 'laptop'),
    (2, '2024-01-01 09:15:00', '192.168.1.101', 'mobile'),
    (3, '2024-01-01 09:30:00', '192.168.1.102', 'desktop'),
    (4, '2024-01-01 09:45:00', '192.168.1.103', 'tablet'),
    (1, '2024-01-01 14:00:00', '192.168.1.100', 'laptop');

SELECT '=== Memory: 세션 데이터 ===' as info;
SELECT * FROM sessions ORDER BY login_time;
