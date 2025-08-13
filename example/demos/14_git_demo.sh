#!/bin/bash

echo "🔀 GlueSQL Git Storage Demo"
echo "==========================="
echo "✨ 특징: Git 저장소와 연동된 버전 관리 데이터베이스"
echo ""

mkdir -p results/demo_results

cat << 'EOF' | ../bin/gluesql-cli -s memory > results/demo_results/14_git_simulation.txt 2>&1
-- Git Storage 시뮬레이션 (실제로는 Git 저장소와 연동)

CREATE TABLE code_reviews (
    review_id INTEGER,
    pull_request INTEGER,
    reviewer TEXT,
    status TEXT,
    comments TEXT,
    created_at TEXT
);

INSERT INTO code_reviews VALUES
    (1, 123, 'alice', 'approved', 'LGTM! Great work', '2024-01-01'),
    (2, 123, 'bob', 'changes_requested', 'Please add tests', '2024-01-01'),
    (3, 124, 'charlie', 'approved', 'Code looks good', '2024-01-02'),
    (4, 125, 'alice', 'pending', 'Still reviewing', '2024-01-03');

SELECT '=== Git 연동 코드 리뷰 데이터 ===' as info;
SELECT * FROM code_reviews ORDER BY created_at;

SELECT '=== 리뷰 상태별 통계 ===' as info;
SELECT status, COUNT(*) as count
FROM code_reviews
GROUP BY status;

SELECT '=== 리뷰어별 활동 ===' as info;
SELECT reviewer, COUNT(*) as reviews_done
FROM code_reviews
GROUP BY reviewer
ORDER BY reviews_done DESC;

SELECT 'Git Storage는 데이터 변경을 자동으로 commit합니다!' as feature;
EOF

echo "✅ Git Storage 시뮬레이션 완료: results/demo_results/14_git_simulation.txt"
echo "🎉 Git Storage Demo 완료!"
