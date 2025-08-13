# kyle-gluesql 🚀

> **GlueSQL 다중 저장소 통합 데모 프로젝트**

이 프로젝트는 **GlueSQL**의 강력한 다중 저장소 통합 기능을 실제로 체험할 수 있는 포괄적인 데모 모음입니다.

## 🎯 프로젝트 개요

**GlueSQL**은 하나의 SQL 인터페이스로 **14가지 다양한 저장소**를 통합하여 사용할 수 있는 혁신적인 데이터베이스 솔루션입니다. 이 프로젝트는 메모리, 파일, 임베디드 DB, 클라우드 저장소까지 모든 타입의 저장소를 **단일 SQL**로 조작하는 방법을 보여줍니다.

### ✨ 핵심 특징

- 🔗 **다중 저장소 조인**: 서로 다른 저장소의 테이블을 하나의 SQL로 조인
- 📊 **스키마 자유도**: JSON, CSV 등 스키마리스 데이터도 SQL로 분석
- ⚡ **성능 최적화**: 각 저장소의 특성에 맞는 최적화된 쿼리 실행
- 🌐 **플랫폼 독립**: CLI, 웹 브라우저, 임베디드 환경 모두 지원

## 📁 지원 저장소 (14개)

### 💾 메모리 기반

- **Memory Storage** - 초고속 인메모리 처리
- **Shared Memory Storage** - 멀티스레드 안전 공유 메모리

### 🗃️ 임베디드 데이터베이스

- **Sled Storage** - 고성능 키-값 임베디드 DB
- **Redb Storage** - 단일 파일 트랜잭션 DB

### 📄 파일 기반

- **JSON Storage** - JSON/JSONL 파일 직접 쿼리
- **CSV Storage** - 스프레드시트 호환 테이블 데이터
- **Parquet Storage** - 컬럼형 빅데이터 포맷
- **File Storage** - 일반 파일시스템 기반

### 🌐 웹 브라우저

- **Web Storage** - localStorage/sessionStorage
- **IndexedDB Storage** - 브라우저 고급 로컬 DB

### 🏢 외부 데이터베이스

- **MongoDB Storage** - NoSQL 도큐먼트 DB
- **Redis Storage** - 인메모리 키-값 저장소

### 🔧 특수 저장소

- **Composite Storage** - 여러 저장소 동시 통합 사용
- **Git Storage** - Git 저장소를 데이터베이스로 활용

## 🚀 빠른 시작

### 1. 전체 데모 실행

```bash
cd example
./run_all_storage_demos.sh
```

### 2. 개별 저장소 테스트

```bash
# 메모리 저장소 - 초고속 처리
./demos/01_memory_demo.sh

# JSON 저장소 - 로그 분석
./demos/03_json_demo.sh

# 복합 저장소 - 다중 저장소 조인
./demos/13_composite_demo.sh
```

### 3. 실제 비즈니스 시나리오

```sql
-- 서로 다른 저장소의 데이터를 하나의 SQL로!
CREATE TABLE users ENGINE = json;      -- JSON 파일
CREATE TABLE sessions ENGINE = memory; -- 메모리 캐시
CREATE TABLE orders ENGINE = csv;      -- CSV 스프레드시트

SELECT u.name, s.login_time, o.total_amount
FROM users u
JOIN sessions s ON u.id = s.user_id
JOIN orders o ON u.id = o.customer_id
WHERE o.date >= '2024-01-01';
```

## 📊 실제 사용 사례

### 🏢 기업 데이터 통합

- **문제**: ERP는 CSV, 로그는 JSON, 캐시는 Redis에 분산 저장
- **해결**: GlueSQL로 모든 데이터를 하나의 SQL로 통합 분석

### 📈 실시간 대시보드

- **문제**: 실시간 데이터는 메모리, 과거 데이터는 파일에 저장
- **해결**: Composite Storage로 실시간+과거 데이터 통합 쿼리

### 🔄 데이터 마이그레이션

- **문제**: 레거시 시스템에서 신규 시스템으로 점진적 이전
- **해결**: 기존 데이터 구조 변경 없이 GlueSQL로 통합

## 📚 프로젝트 구조

```
kyle-gluesql/
├── example/                    # 메인 데모 디렉토리
│   ├── demos/                  # 14개 저장소별 실행 스크립트
│   ├── data/                   # 샘플 데이터 (JSON, CSV, Parquet 등)
│   ├── sql_examples/           # 28개 SQL 쿼리 예제 모음
│   ├── results/                # 실행 결과 및 성능 비교
│   └── run_all_storage_demos.sh # 전체 데모 일괄 실행
├── bin/
│   └── gluesql-cli            # GlueSQL CLI 바이너리
└── README.md                  # 이 파일
```

## 🎪 주요 데모 하이라이트

### 1. 💥 성능 비교 테스트

각 저장소별 성능 특성을 실제 데이터로 비교:

- Memory: 초당 100만 레코드 처리
- JSON: 로그 분석에 최적화
- CSV: 스프레드시트 호환성
- Sled: 영구 저장 + 트랜잭션

### 2. 🔗 크로스 스토리지 조인

```sql
-- 메모리의 실시간 세션 + JSON의 사용자 정보 + CSV의 주문 데이터
SELECT u.name, s.device, o.product, o.amount
FROM memory.sessions s
JOIN json.users u ON s.user_id = u.id
JOIN csv.orders o ON u.id = o.customer_id;
```

### 3. 📊 실시간 분석 대시보드

```sql
-- 시간대별 매출 분석 (다중 저장소)
SELECT
    HOUR(s.login_time) as hour,
    COUNT(DISTINCT s.user_id) as active_users,
    SUM(o.amount) as hourly_revenue
FROM memory.sessions s
JOIN csv.orders o ON s.user_id = o.customer_id
WHERE DATE(o.created_at) = CURRENT_DATE
GROUP BY HOUR(s.login_time);
```

## 🛠️ 개발 환경

### 필수 요구사항

- **GlueSQL CLI**: 프로젝트에 포함된 바이너리 사용
- **Rust**: 소스코드 빌드시에만 필요 (선택사항)

### 저장소별 추가 요구사항

- **MongoDB/Redis**: 해당 서버 실행 필요
- **웹 저장소**: Node.js (브라우저 환경 시뮬레이션)

## 🎉 시작해보기

1. **저장소 클론 및 이동**

   ```bash
   git clone <repository-url>
   cd kyle-gluesql
   ```

2. **전체 데모 실행**

   ```bash
   cd example
   chmod +x run_all_storage_demos.sh
   ./run_all_storage_demos.sh
   ```

3. **결과 확인**

   ```bash
   ls results/demo_results/
   # 각 저장소별 실행 결과 확인
   ```

4. **개별 저장소 테스트**
   ```bash
   # 관심 있는 저장소만 선택 실행
   ./demos/01_memory_demo.sh      # 메모리 저장소
   ./demos/03_json_demo.sh        # JSON 저장소
   ./demos/13_composite_demo.sh   # 복합 저장소
   ```

## 🌟 GlueSQL의 비전

> **"모든 데이터를 SQL로, 어떤 저장소든 하나의 인터페이스로"**

이 프로젝트는 GlueSQL이 추구하는 **데이터베이스 민주화**를 직접 체험할 수 있도록 설계되었습니다. 데이터가 어디에 저장되어 있든, 어떤 형태든 상관없이 친숙한 SQL로 모든 데이터를 다룰 수 있는 미래를 보여줍니다.

---

📖 **더 자세한 정보**: [GlueSQL 공식 문서](https://gluesql.org)  
🔧 **개발 가이드**: `example/README.md` 참조  
📊 **SQL 예제**: `example/sql_examples/README.md` 참조
