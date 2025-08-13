#!/bin/bash

# 데모 스크립트에서 SQL 구문을 추출하여 저장소별 폴더에 저장하는 스크립트 (v2)

echo "🔍 데모 스크립트에서 SQL 추출 중 (v2)..."
echo "================================================"

# 현재 디렉토리 확인
if [[ ! -f "extract_sql_from_demos.sh" ]]; then
    echo "❌ 오류: example 디렉토리에서 실행해주세요"
    echo "실행 방법: cd /Users/kyle/code/kyle-gluesql/example && ./extract_sql_from_demos.sh"
    exit 1
fi

# sql_examples 기본 폴더만 생성 (저장소별 폴더는 필요할 때 생성)
mkdir -p sql_examples

# 저장소 번호와 폴더명 매핑 (문자열로 처리)
get_storage_folder() {
    case "$1" in
        "01") echo "memory_storage" ;;
        "02") echo "shared_memory_storage" ;;
        "03") echo "json_storage" ;;
        "04") echo "csv_storage" ;;
        "05") echo "parquet_storage" ;;
        "06") echo "sled_storage" ;;
        "07") echo "redb_storage" ;;
        "08") echo "file_storage" ;;
        "09") echo "mongo_storage" ;;
        "10") echo "redis_storage" ;;
        "11") echo "web_storage" ;;
        "12") echo "idb_storage" ;;
        "13") echo "composite_storage" ;;
        "14") echo "git_storage" ;;
        *) echo "unknown_storage" ;;
    esac
}

# 저장소 이름 추출 (폴더명에서 _storage 제거)
get_storage_name() {
    echo "$1" | sed 's/_storage$//'
}

# 각 데모 파일에서 SQL 구문 추출
for demo_file in demos/*.sh; do
    if [[ -f "$demo_file" ]]; then
        filename=$(basename "$demo_file" .sh)
        demo_number=$(echo "$filename" | cut -d'_' -f1)
        storage_folder=$(get_storage_folder "$demo_number")
        storage_name=$(get_storage_name "$storage_folder")

        echo "📄 처리 중: $filename -> $storage_folder"

        if [[ "$storage_folder" != "unknown_storage" ]]; then
            # 먼저 SQL 블록이 있는지 확인 (두 가지 패턴 모두 체크)
            if grep -q -E "(\.\.\/bin\/gluesql-cli.*<<.*EOF|cat.*<<.*EOF.*\.\.\/bin\/gluesql-cli)" "$demo_file" 2>/dev/null; then
                # SQL이 있을 때만 폴더 생성
                mkdir -p "sql_examples/$storage_folder"

                # SQL 블록 추출
                sql_count=0
                temp_file="/tmp/sql_extract_$$"

                # awk로 SQL 블록들 추출 (두 패턴 모두 처리)
                awk '
                /(\.\.\/bin\/gluesql-cli.*<<.*EOF|cat.*<<.*EOF.*\.\.\/bin\/gluesql-cli)/ {
                    in_sql = 1
                    sql_count++
                    if (sql_count == 1) suffix = "_basic"
                    else if (sql_count == 2) suffix = "_advanced"
                    else if (sql_count == 3) suffix = "_analytics"
                    else if (sql_count == 4) suffix = "_performance"
                    else suffix = "_part" sql_count

                    output_file = "sql_examples/" storage_folder "/" storage_name suffix ".sql"
                    storage_title = toupper(substr(storage_name, 1, 1)) substr(storage_name, 2)
                    suffix_title = toupper(substr(suffix, 2, 1)) substr(suffix, 3)
                    print "-- " storage_title " Storage " suffix_title " SQL" > output_file
                    print "-- Generated from " filename > output_file
                    print "" > output_file
                    next
                }
                in_sql && /^EOF$/ {
                    in_sql = 0
                    next
                }
                in_sql {
                    print $0 > output_file
                }
                ' storage_folder="$storage_folder" storage_name="$storage_name" filename="$filename" "$demo_file"
            else
                echo "  ⚠️  SQL 블록이 없습니다 - 폴더 생성 안함"
            fi
        fi
    fi
done

echo ""
echo "✅ SQL 추출 완료!"
echo ""
echo "📊 생성된 SQL 파일들:"
find sql_examples/ -name "*.sql" | wc -l | xargs echo "총 파일 수:"
echo ""
echo "📋 저장소별 파일 수:"
for dir in sql_examples/*/; do
    storage_name=$(basename "$dir")
    file_count=$(find "$dir" -name "*.sql" 2>/dev/null | wc -l)
    if [[ $file_count -gt 0 ]]; then
        echo "  $storage_name: ${file_count}개"
    fi
done
