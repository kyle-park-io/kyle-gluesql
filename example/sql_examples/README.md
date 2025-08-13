# GlueSQL SQL 예제 모음

이 폴더는 GlueSQL의 다양한 저장소 타입별 SQL 쿼리 예제들을 체계적으로 정리한 컬렉션입니다.

**📊 현재 상태: 총 28개 SQL 파일, 12개 저장소 타입 커버**

## 📁 폴더 구조

```
sql_examples/
├── memory_storage/          # 메모리 저장소
├── shared_memory_storage/   # 공유 메모리 저장소
├── json_storage/           # JSON 저장소
├── csv_storage/            # CSV 저장소
├── parquet_storage/        # Parquet 저장소
├── sled_storage/           # Sled 임베디드 DB
├── redb_storage/           # Redb 임베디드 DB
├── file_storage/           # 파일 저장소
├── git_storage/            # Git 저장소
├── mongo_storage/          # MongoDB 저장소
├── redis_storage/          # Redis 저장소
└── composite_storage/      # 복합 저장소 (다중 저장소 조인)
```

### 📝 SQL 파일이 있는 저장소 (12개):

실제 SQL 예제 파일이 생성된 저장소들입니다.

### 📝 각 폴더별 SQL 파일 종류:

- `*_basic.sql` - 기본 CRUD 작업
- `*_advanced.sql` - 고급 쿼리 (윈도우 함수, 서브쿼리, 복잡한 조인)
- `*_analytics.sql` - 분석 쿼리 (집계, 통계, 로그 분석)
- `*_performance.sql` - 성능 테스트 및 최적화 예제

## 🚀 사용법

### 0. Path 설정

```bash
cd /Users/kyle/code/kyle-gluesql/example
```

### 1. Memory Storage 예제 실행

```bash
../../bin/gluesql-cli --storage memory --execute sql_examples/memory_storage/memory_basic.sql
```

### 2. JSON Storage 예제 실행

```bash
# 먼저 JSON 데이터 생성 (데모 스크립트 실행)
./demos/03_json_demo.sh

# JSON SQL 예제 실행
../../bin/gluesql-cli --storage json --path data/json_demo --execute sql_examples/json_storage/json_basic.sql
```

### 3. CSV Storage 예제 실행

```bash
# 먼저 CSV 데이터 생성
./demos/04_csv_demo.sh

# CSV SQL 예제 실행
../../bin/gluesql-cli --storage csv --path data/csv_demo --execute sql_examples/csv_storage/csv_basic.sql
```

### 4. Sled Storage 예제 실행

```bash
../../bin/gluesql-cli --storage sled --path ./sled_db --execute sql_examples/sled_storage/sled_basic.sql
```

### 5. Composite Storage 예제 실행 (다중 저장소 조인)

```bash
# 복합 저장소로 메모리와 JSON을 동시 사용
../../bin/gluesql-cli --storage composite --execute sql_examples/composite_storage/composite_basic.sql
```

## 📚 학습 가이드

### 🔰 초급 (Basic)

1. `memory_storage/memory_basic.sql` - SQL 기본 문법 학습
2. `json_storage/json_basic.sql` - 스키마리스 데이터 다루기
3. `csv_storage/csv_basic.sql` - 파일 기반 데이터 쿼리

### 🔶 중급 (Advanced)

1. `memory_storage/memory_advanced.sql` - 윈도우 함수, 서브쿼리
2. `json_storage/json_advanced.sql` - 복합 조인 쿼리
3. `sled_storage/sled_advanced.sql` - 인덱스, 트랜잭션

### 🔥 고급 (Analytics)

1. `json_storage/json_analytics.sql` - 로그 분석
2. `csv_storage/csv_analytics.sql` - 비즈니스 인텔리전스
3. `composite_storage/composite_analytics.sql` - 다중 저장소 분석

## 🎯 저장소별 특징 및 사용 사례

### 💾 Memory Storage

- **특징**: 초고속 성능, 프로세스 종료시 데이터 소실
- **사용 사례**: 캐시, 임시 계산, 프로토타이핑
- **예제**: 기본 CRUD, 윈도우 함수, 복잡한 집계

### 🤝 Shared Memory Storage

- **특징**: 멀티스레드 환경에서 안전한 메모리 공유
- **사용 사례**: 동시성이 중요한 애플리케이션
- **예제**: 동시성 테스트, 멀티스레드 데이터 공유

### 📄 JSON Storage

- **특징**: 스키마리스, JSON/JSONL 파일 직접 쿼리
- **사용 사례**: 로그 분석, API 데이터 처리, NoSQL 스타일 데이터
- **예제**: 비정형 데이터 쿼리, 로그 분석, 복잡한 JSON 조작

### 📊 CSV Storage

- **특징**: 엑셀/스프레드시트 호환, 구조화된 테이블 데이터
- **사용 사례**: 데이터 분석, BI, 레거시 데이터 마이그레이션
- **예제**: 비즈니스 분석, 시계열 데이터, 통계 리포팅

### 🗃️ Sled Storage

- **특징**: 영구 저장, 트랜잭션 지원, 고성능 임베디드 DB
- **사용 사례**: 프로덕션 애플리케이션, 데이터 무결성 중요
- **예제**: 트랜잭션 처리, 인덱스 활용, 복잡한 관계형 쿼리

### 🔄 Composite Storage

- **특징**: 여러 저장소를 조합하여 크로스 스토리지 JOIN
- **사용 사례**: 하이브리드 데이터 아키텍처, 데이터 마이그레이션
- **예제**: 메모리+JSON 조인, 실시간+과거 데이터 분석

## 🌐 브라우저 전용 저장소

아래 저장소들은 브라우저 환경에서만 동작하므로 CLI로는 SQL 예제를 생성할 수 없습니다:

### 🌐 Web Storage

- **특징**: localStorage/sessionStorage를 SQL로 사용
- **환경**: 브라우저 전용 (JavaScript/WASM)

### 🌐 IndexedDB Storage

- **특징**: 브라우저의 고급 로컬 데이터베이스
- **환경**: 브라우저 전용 (JavaScript/WASM)

## 💡 팁 및 권장사항

### 🚀 성능 최적화

- Memory Storage: 대용량 데이터 처리시 메모리 사용량 주의
- JSON Storage: 큰 파일은 JSONL 형식 사용 권장
- CSV Storage: 첫 행을 헤더로 활용
- Sled Storage: 인덱스 생성으로 쿼리 성능 향상

### 🔧 개발 팁

- 초기 개발: Memory Storage로 빠른 프로토타이핑
- 로그 분석: JSON Storage로 유연한 스키마 활용
- 데이터 분석: CSV Storage로 기존 엑셀 데이터 활용
- 프로덕션: Sled Storage로 안정적인 영구 저장

### 🔍 디버깅

- SQL 실행 전 각 저장소의 데이터 구조 확인
- 에러 발생시 데이터 타입과 스키마 불일치 점검
- 복합 쿼리는 단계별로 나누어 테스트

## 🔧 자동 SQL 추출

새로운 데모 스크립트 추가시 SQL을 자동으로 추출하려면:

```bash
./extract_sql_from_demos.sh
```

이 스크립트는 `demos/*.sh` 파일들을 분석하여 SQL 구문을 자동으로 해당 저장소 폴더에 저장합니다.

## 📈 현재 커버리지

- **CLI 실행 가능**: 12개 저장소 (Memory, Shared Memory, JSON, CSV, Parquet, Sled, Redb, File, Git, Mongo, Redis, Composite)
- **브라우저 전용**: 2개 저장소 (Web Storage, IndexedDB) - 시뮬레이션만 제공
- **총 커버리지**: **14개 GlueSQL 저장소 100% 완성** ✅

---

📖 더 많은 예제와 자세한 설명은 [GlueSQL 공식 문서](https://gluesql.org/docs/)를 참고하세요.
