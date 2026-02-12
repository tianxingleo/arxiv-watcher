#!/usr/bin/env bash
# scripts/extract_pdf.sh
# 提取ArXiv PDF内容
#
# 用法: ./extract_pdf.sh <pdf_url>
#
# 参数:
#   pdf_url: ArXiv PDF的URL

PDF_URL="$1"

if [[ -z "$PDF_URL" ]]; then
    echo "错误: 缺少PDF URL"
    echo "用法: $0 <pdf_url>"
    exit 1
fi

echo "📄 正在提取PDF内容"
echo "🔗 URL: $PDF_URL"
echo ""

# 临时文件
TEMP_DIR=$(mktemp -d)
PDF_FILE="$TEMP_DIR/paper.pdf"

# 下载PDF
echo "⬇️  下载PDF..."
if ! curl -sL "$PDF_URL" -o "$PDF_FILE"; then
    echo "❌ 下载失败"
    rm -rf "$TEMP_DIR"
    exit 1
fi

echo "✅ 下载完成"
echo "📁 文件: $PDF_FILE"
echo ""

# 检查是否安装了pdftotext
if command -v pdftotext &> /dev/null; then
    echo "📝 使用pdftotext提取文本..."
    pdftotext "$PDF_FILE" "$TEMP_DIR/text.txt"
    echo ""
    echo "--- 文本内容 (前5000字符) ---"
    head -c 5000 "$TEMP_DIR/text.txt"
    echo ""
    echo "..."
    echo ""
    echo "📁 完整文本: $TEMP_DIR/text.txt"
else
    echo "⚠️  未安装pdftotext"
    echo "💡 安装方法: sudo apt-get install poppler-utils"
    echo ""
    echo "📁 PDF文件: $PDF_FILE"
    echo "💡 可以使用其他工具（如python pdfplumber）提取"
fi

# 清理提示
echo ""
echo "💡 提示: 临时文件保存在 $TEMP_DIR，处理完成后手动清理"
