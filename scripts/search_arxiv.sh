#!/usr/bin/env bash
# scripts/search_arxiv.sh
# 基础ArXiv检索工具
#
# 用法: ./search_arxiv.sh "<query>" [count]
#
# 参数:
#   query: 搜索关键词
#   count: 返回结果数量（默认5，最大100）

QUERY="$1"
COUNT=${2:-5}

# 验证参数
if [[ -z "$QUERY" ]]; then
    echo "错误: 缺少查询参数"
    echo "用法: $0 \"<query>\" [count]"
    exit 1
fi

# 限制结果数量
if [[ $COUNT -gt 100 ]]; then
    COUNT=100
    echo "警告: 结果数量限制为100"
fi

echo "🔍 正在搜索 ArXiv: $QUERY"
echo "📊 检索数量: $COUNT"
echo ""

# 使用curl查询ArXiv API
# 按提交时间降序排序（最新优先）
curl -sL "https://export.arxiv.org/api/query?search_query=all:$QUERY&start=0&max_results=$COUNT&sortBy=submittedDate&sortOrder=descending"
