#!/usr/bin/env bash
# scripts/save_to_log.sh
# 将论文保存到研究日志
#
# 用法: ./save_to_log.sh <arxiv_id> [title]
#
# 参数:
#   arxiv_id: ArXiv论文ID
#   title: 论文标题（可选，不提供则自动检索）

ARXIV_ID="$1"
TITLE="$2"

if [[ -z "$ARXIV_ID" ]]; then
    echo "错误: 缺少ArXiv ID"
    echo "用法: $0 <arxiv_id> [title]"
    exit 1
fi

# 日志文件路径
WORKSPACE="${OPENCLAW_WORKSPACE:-/home/ltx/.openclaw/workspace}"
LOG_FILE="$WORKSPACE/memory/RESEARCH_LOG.md"
DATE=$(date +%Y-%m-%d)

# 确保memory目录存在
mkdir -p "$(dirname "$LOG_FILE")"

# 如果没有提供标题，自动检索
if [[ -z "$TITLE" ]]; then
    METADATA=$(curl -sL "https://export.arxiv.org/api/query?id_list=$ARXIV_ID")
    TITLE=$(echo "$METADATA" | grep -oP '(?<=<title>).*?(?=</title>)' | sed '2d' | sed 's/^ *//;s/ *$//')
fi

if [[ -z "$TITLE" ]]; then
    echo "❌ 无法检索到论文信息"
    exit 1
fi

# 构建日志条目
ENTRY="
### [$DATE] $TITLE
- **ArXiv**: https://arxiv.org/abs/$ARXIV_ID
- **PDF**: https://arxiv.org/pdf/$ARXIV_ID.pdf
- **保存时间**: $(date '+%Y-%m-%d %H:%M:%S')
"

# 如果日志文件不存在，创建它
if [[ ! -f "$LOG_FILE" ]]; then
    cat > "$LOG_FILE" <<'EOF'
# 研究日志

这个文件记录所有研究和阅读的论文。

---

EOF
fi

# 追加到日志文件
echo "$ENTRY" >> "$LOG_FILE"

echo "✅ 已保存到研究日志"
echo "📁 文件: $LOG_FILE"
echo "📌 论文: $TITLE"
echo "🆔 ArXiv: $ARXIV_ID"
echo ""
echo "💡 可以添加更多笔记:"
echo "   echo '- **我的笔记**: ...' >> \"$LOG_FILE\""
