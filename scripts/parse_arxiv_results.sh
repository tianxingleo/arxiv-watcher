#!/usr/bin/env bash
# scripts/parse_arxiv_results.sh
# 解析ArXiv API返回的XML结果，进行去重和排序
#
# 用法: ./parse_arxiv_results.sh <results_file> [mode]
#
# 参数:
#   results_file: ArXiv API返回的XML文件
#   mode: 输出模式
#         - concise (默认): 简洁模式
#         - detailed: 详细模式

RESULTS_FILE="$1"
MODE=${2:-concise}

if [[ -z "$RESULTS_FILE" ]]; then
    echo "错误: 缺少结果文件"
    echo "用法: $0 <results_file> [mode]"
    exit 1
fi

if [[ ! -f "$RESULTS_FILE" ]]; then
    echo "错误: 文件不存在: $RESULTS_FILE"
    exit 1
fi

# 临时文件
TEMP_DIR=$(mktemp -d)
TITLES_FILE="$TEMP_DIR/titles.txt"
UNIQUE_FILE="$TEMP_DIR/unique.xml"

# 提取所有标题
grep -oP '(?<=<title>).*?(?=</title>)' "$RESULTS_FILE" | \
    sed 's/^ *//;s/ *$//' > "$TITLES_FILE"

# 去重（基于标题相似度）
# 简单策略：完全相同的标题只保留一个
declare -A SEEN_TITLES

while IFS= read -r line; do
    # 标准化标题（小写，去除多余空格）
    normalized=$(echo "$line" | tr '[:upper:]' '[:lower:]' | sed 's/  */ /g')

    if [[ ! ${SEEN_TITLES[$normalized]+_} ]]; then
        SEEN_TITLES[$normalized]=1
    fi
done < "$TITLES_FILE"

echo "📊 去重统计:"
echo "   原始论文数: $(grep '<entry>' "$RESULTS_FILE" | wc -l)"
echo "   去重后数量: ${#SEEN_TITLES[@]}"
echo ""

# 解析并输出结果
echo "## 检索结果"
echo ""

# 使用Python解析XML（更可靠）
python3 - <<PYTHON
import xml.etree.ElementTree as ET
import sys
import re
from datetime import datetime

try:
    tree = ET.parse('$RESULTS_FILE')
    root = tree.getroot()

    # ArXiv API使用Atom命名空间
    ns = {'atom': 'http://www.w3.org/2005/Atom'}

    entries = root.findall('atom:entry', ns)
    seen_titles = set()

    results = []

    for entry in entries:
        # 提取基本信息
        title = entry.find('atom:title', ns)
        summary = entry.find('atom:summary', ns)
        published = entry.find('atom:published', ns)

        if title is not None:
            title_text = title.text.strip()

            # 去重
            title_normalized = title_text.lower().strip()
            if title_normalized in seen_titles:
                continue
            seen_titles.add(title_normalized)

            # 提取作者
            authors = []
            author_list = entry.findall('atom:author', ns)
            for author in author_list:
                name = author.find('atom:name', ns)
                if name is not None:
                    authors.append(name.text)

            # 提取ArXiv ID
            arxiv_id = "Unknown"
            arxiv_id_elem = entry.find('atom:id', ns)
            if arxiv_id_elem is not None:
                match = re.search(r'abs/(\d+\.\d+)', arxiv_id_elem.text)
                if match:
                    arxiv_id = match.group(1)

            # 提取PDF链接
            pdf_url = ""
            for link in entry.findall('atom:link', ns):
                link_type = link.get('type')
                link_title = link.get('title')
                if link_title == 'pdf' or link_type == 'application/pdf':
                    pdf_url = link.get('href')
                    break

            # 提取发布日期
            date_str = ""
            if published is not None:
                try:
                    dt = datetime.strptime(published.text, '%Y-%m-%dT%H:%M:%SZ')
                    date_str = dt.strftime('%Y')
                except:
                    pass

            # 提取主要类别
            primary_category = ""
            cat_elem = entry.find('atom:primary_category', ns)
            if cat_elem is not None:
                primary_category = cat_elem.get('term', '')

            # 清理摘要
            summary_text = ""
            if summary is not None:
                summary_text = summary.text.strip()

            results.append({
                'title': title_text,
                'authors': authors[:3],  # 只显示前3个作者
                'arxiv_id': arxiv_id,
                'pdf_url': pdf_url,
                'year': date_str,
                'category': primary_category,
                'summary': summary_text
            })

    # 输出结果
    for i, paper in enumerate(results, 1):
        print(f"### {i}. **{paper['title']}**")
        print(f"   - **作者**: {', '.join(paper['authors'])}" + (" et al." if len(paper['authors']) >= 3 else ""))
        print(f"   - **年份**: {paper['year']}")
        print(f"   - **ArXiv**: {paper['arxiv_id']}")
        if paper['category']:
            print(f"   - **类别**: {paper['category']}")
        print(f"   - **摘要**: {paper['summary'][:200]}...")
        print("")

except Exception as e:
    print(f"错误: {e}", file=sys.stderr)
    sys.exit(1)
PYTHON

# 清理临时文件
rm -rf "$TEMP_DIR"
