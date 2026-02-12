#!/usr/bin/env bash
# scripts/analyze_paper.sh
# 分析ArXiv论文的详细信息
#
# 用法: ./analyze_paper.sh <arxiv_id>
#
# 参数:
#   arxiv_id: ArXiv论文ID（如: 2003.08934）

ARXIV_ID="$1"

if [[ -z "$ARXIV_ID" ]]; then
    echo "错误: 缺少ArXiv ID"
    echo "用法: $0 <arxiv_id>"
    exit 1
fi

echo "📄 正在分析论文"
echo "🆔 ArXiv ID: $ARXIV_ID"
echo ""

# 构建URL
ABS_URL="https://arxiv.org/abs/$ARXIV_ID"
PDF_URL="https://arxiv.org/pdf/$ARXIV_ID.pdf"

echo "🔗 论文链接: $ABS_URL"
echo "📥 PDF链接: $PDF_URL"
echo ""

# 检索论文元数据
echo "📊 检索论文信息..."
METADATA=$(curl -sL "https://export.arxiv.org/api/query?id_list=$ARXIV_ID")

# 提取标题
TITLE=$(echo "$METADATA" | grep -oP '(?<=<title>).*?(?=</title>)' | sed '2d' | sed 's/^ *//;s/ *$//')

# 提取作者
AUTHORS=$(echo "$METADATA" | grep -oP '(?<=<name>).*?(?=</name>)' | head -5 | tr '\n' ',' | sed 's/,$//')

# 提取摘要
SUMMARY=$(echo "$METADATA" | grep -oP '(?<=<summary>).*?(?=</summary>)' | sed 's/^ *//;s/ *$//')

# 提取发布日期
PUBLISHED=$(echo "$METADATA" | grep -oP '(?<=<published>).*?(?=</published>)' | sed 's/T.*//')

# 提取类别
CATEGORY=$(echo "$METADATA" | grep -oP '(?<=<primary_category term=")[^"]*' | head -1)

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "📌 **$TITLE**"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "**作者**: $AUTHORS"
echo "**发布**: $PUBLISHED"
echo "**类别**: $CATEGORY"
echo "**ArXiv**: $ARXIV_ID"
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "📝 摘要"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "$SUMMARY"
echo ""

# 提供PDF提取选项
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "🔧 操作选项"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "1. 提取PDF完整内容:"
echo "   ./scripts/extract_pdf.sh \"$PDF_URL\""
echo ""
echo "2. 查看论文页面:"
echo "   打开浏览器访问: $ABS_URL"
echo ""
echo "3. 保存到研究日志:"
echo "   ./scripts/save_to_log.sh \"$ARXIV_ID\" \"$TITLE\""
echo ""

# 尝试使用web_fetch提取更多内容（如果在OpenClaw环境中运行）
if command -v web_fetch &> /dev/null || type web_fetch &> /dev/null; then
    echo "💡 检测到OpenClaw环境，可以使用web_fetch提取更多详情"
fi
