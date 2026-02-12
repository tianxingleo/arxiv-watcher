#!/usr/bin/env bash
# scripts/batch_search.sh
# 批量检索ArXiv论文，支持多关键词和去重
#
# 用法: ./batch_search.sh "<query1|query2|query3>" [count]
#
# 参数:
#   queries: 多个查询，用|分隔
#   count: 每个查询返回的数量（默认5）

IFS='|' read -ra QUERIES <<< "$1"
COUNT=${2:-5}

if [[ -z "$1" ]]; then
    echo "错误: 缺少查询参数"
    echo "用法: $0 \"<query1|query2|query3>\" [count]"
    exit 1
fi

echo "🔍 批量检索 ArXiv"
echo "📋 查询数: ${#QUERIES[@]}"
echo "📊 每个查询: $COUNT 篇"
echo ""

# 临时文件存储结果
TEMP_DIR=$(mktemp -d)
RESULTS_FILE="$TEMP_DIR/results.xml"

# 合并所有查询的结果
FIRST=true
for QUERY in "${QUERIES[@]}"; do
    echo "→ 检索: $QUERY"
    curl -sL "https://export.arxiv.org/api/query?search_query=all:$QUERY&start=0&max_results=$COUNT&sortBy=submittedDate&sortOrder=descending" >> "$RESULTS_FILE"
done

echo ""
echo "✅ 检索完成"
echo "📁 结果保存到: $RESULTS_FILE"
echo ""
echo "提示: 可以用脚本 parse_results.sh 解析和去重"

# 输出文件路径（供后续脚本使用）
echo "$RESULTS_FILE"
