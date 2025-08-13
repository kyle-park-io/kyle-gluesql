# GlueSQL 모든 저장소 예제 모음 🚀

## 📖 개요

이 디렉토리는 GlueSQL이 지원하는 **모든 저장소 타입**에 대한 실제 동작 예제를 포함합니다. 각 저장소별로 실제 SQL 명령어와 그 실행 결과를 확인할 수 있습니다.

## 🎯 지원하는 저장소 (14개)

### 📁 메모리 기반

- **Memory Storage** - 고성능 인메모리 저장소
- **Shared Memory Storage** - 멀티스레드 공유 메모리

### 💾 임베디드 데이터베이스

- **Sled Storage** - 완전한 기능의 키-값 DB
- **Redb Storage** - 단일 파일 트랜잭션 DB

### 📄 파일 기반

- **JSON Storage** - JSON/JSONL 파일
- **CSV Storage** - CSV 파일
- **Parquet Storage** - Parquet 파일
- **File Storage** - 파일시스템 기반

### 🌐 웹 브라우저

- **Web Storage** - localStorage/sessionStorage
- **IndexedDB Storage** - 브라우저 IndexedDB

### 🗄️ 외부 데이터베이스

- **MongoDB Storage** - MongoDB 컬렉션
- **Redis Storage** - Redis 키-값 저장소

### 🔧 특수 저장소

- **Composite Storage** - 여러 저장소 통합
- **Git Storage** - Git 저장소 기반

## 🚀 빠른 시작

### Path 설정

```bash
cd /Users/kyle/code/kyle-gluesql/example
```

### 모든 예제 실행

```bash
# 모든 저장소 예제를 한번에 실행
./run_all_storage_demos.sh
```

### 개별 저장소 테스트

```bash
# 메모리 저장소
./demos/01_memory_demo.sh

# JSON 저장소
./demos/03_json_demo.sh

# 복합 저장소 (여러 저장소 조인)
./demos/13_composite_demo.sh
```

## 📂 디렉토리 구조

```
example/
├── README.md                     # 이 파일
├── run_all_storage_demos.sh      # 전체 데모 실행 스크립트
├── demos/                        # 각 저장소별 데모 스크립트
│   ├── 01_memory_demo.sh         # 메모리 저장소
│   ├── 02_shared_memory_demo.sh  # 공유 메모리
│   ├── 03_json_demo.sh           # JSON 저장소
│   ├── 04_csv_demo.sh            # CSV 저장소
│   ├── 05_parquet_demo.sh        # Parquet 저장소
│   ├── 06_sled_demo.sh           # Sled 저장소
│   ├── 07_redb_demo.sh           # Redb 저장소
│   ├── 08_file_demo.sh           # File 저장소
│   ├── 09_mongo_demo.sh          # MongoDB 저장소
│   ├── 10_redis_demo.sh          # Redis 저장소
│   ├── 11_web_demo.sh            # Web 저장소 (Node.js)
│   ├── 12_idb_demo.sh            # IndexedDB 저장소 (Node.js)
│   ├── 13_composite_demo.sh      # 복합 저장소
│   └── 14_git_demo.sh            # Git 저장소
├── data/                         # 예제 데이터 파일들
├── results/                      # 실행 결과 저장
│   └── demo_results/             # 각 데모별 실행 결과
├── sql_examples/                 # SQL 스크립트들 (저장소별 정리)
└── extract_sql_from_demos.sh     # SQL 자동 추출 스크립트

```

## 🎪 주요 특징 데모

### 1. 멀티 저장소 조인

서로 다른 저장소의 테이블을 조인:

```sql
CREATE TABLE users ENGINE = memory;
CREATE TABLE logs ENGINE = json;
CREATE TABLE cache ENGINE = redis;

SELECT u.name, l.action, c.data
FROM users u
JOIN logs l ON u.id = l.user_id
JOIN cache c ON u.id = c.user_id;
```

### 2. 스키마리스 데이터 처리

```sql
CREATE TABLE events;  -- 스키마 없음
INSERT INTO events VALUES
    ('{"type": "click", "user": "alice", "timestamp": "2024-01-01"}'),
    ('{"type": "view", "user": "bob", "page": "/home"}');

SELECT * FROM events WHERE JSON_EXTRACT(events, '$.type') = 'click';
```

### 3. 실시간 데이터 분석

```sql
-- CSV 파일과 JSON 로그를 실시간 분석
SELECT
    c.category,
    COUNT(*) as event_count,
    AVG(CAST(JSON_EXTRACT(j.data, '$.value') AS FLOAT)) as avg_value
FROM categories.csv c
JOIN events.jsonl j ON c.id = JSON_EXTRACT(j.data, '$.category_id')
WHERE DATE(JSON_EXTRACT(j.data, '$.timestamp')) = CURRENT_DATE
GROUP BY c.category;
```

## 📊 성능 비교

각 저장소별 성능 특성:

| 저장소  | 읽기 속도  | 쓰기 속도  | 메모리 사용량 | 영구 저장 |
| ------- | ---------- | ---------- | ------------- | --------- |
| Memory  | ⭐⭐⭐⭐⭐ | ⭐⭐⭐⭐⭐ | 높음          | ❌        |
| Sled    | ⭐⭐⭐⭐   | ⭐⭐⭐⭐   | 중간          | ✅        |
| JSON    | ⭐⭐⭐     | ⭐⭐       | 낮음          | ✅        |
| CSV     | ⭐⭐⭐     | ⭐⭐       | 낮음          | ✅        |
| MongoDB | ⭐⭐⭐     | ⭐⭐⭐     | 중간          | ✅        |
| Redis   | ⭐⭐⭐⭐   | ⭐⭐⭐⭐   | 높음          | ⚠️        |

## 🛠️ 필요한 환경

### 기본 요구사항

- Rust (최신 stable 버전)
- GlueSQL CLI (바이너리가 `bin/gluesql-cli`에 포함되어 있음)

### 저장소별 추가 요구사항

- **MongoDB**: MongoDB 서버 실행
- **Redis**: Redis 서버 실행
- **Git**: Git 설치
- **웹 저장소**: Node.js (웹 환경 시뮬레이션)

## 🎉 시작해보기

1. **전체 데모 실행**:

   ```bash
   cd /Users/kyle/code/kyle-gluesql/example
   chmod +x run_all_storage_demos.sh
   ./run_all_storage_demos.sh
   ```

2. **결과 확인**:

   ```bash
   ls results/demo_results/
   # 각 저장소별 실행 결과 파일들이 생성됨
   ```

3. **개별 테스트**:

   ```bash
   # 메모리 저장소 테스트
   ./demos/01_memory_demo.sh

   # JSON 저장소 테스트
   ./demos/03_json_demo.sh
   ```

---

**🎯 목표**: 이 예제들을 통해 GlueSQL의 **"모든 데이터를 SQL로"** 철학을 직접 체험해보세요!

---

_마지막 업데이트: 2024년 12월_
_GlueSQL 버전: v0.17.0_
