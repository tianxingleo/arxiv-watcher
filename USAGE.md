# arxiv-watcher Skill 使用指南

## 快速开始

### 1. 基础检索
```bash
# 检索NeRF相关论文
scripts/search_arxiv.sh "neural radiance fields" 5
```

### 2. 批量检索（推荐）
```bash
# 检索多个相关关键词
scripts/batch_search.sh "neural radiance fields|neural rendering|implicit neural" 10

# 解析并展示结果（自动去重）
scripts/parse_arxiv_results.sh <results.xml>
```

### 3. 论文详细分析
```bash
# 分析特定论文
scripts/analyze_paper.sh 2003.08934

# 提取PDF内容
scripts/extract_pdf.sh "https://arxiv.org/pdf/2003.08934.pdf"
```

### 4. 保存到研究日志
```bash
# 保存论文到日志
scripts/save_to_log.sh 2003.08934
```

## 使用场景示例

### 场景1: Idea验证 - "用NeRF做动态场景重建"

**步骤1**: 检索相关论文
```bash
scripts/batch_search.sh "neural radiance fields dynamic|neRF animation|time-varying NeRF" 15 > /tmp/results.xml
```

**步骤2**: 解析并展示结果
```bash
scripts/parse_arxiv_results.sh /tmp/results.xml
```

**步骤3**: 深度分析重点论文
```bash
scripts/analyze_paper.sh 2101.05278  # Dynamic Scene Representation with Neural Radiance Fields
```

**步骤4**: 保存到日志
```bash
scripts/save_to_log.sh 2101.05278 "Dynamic Scene Representation with Neural Radiance Fields"
```

### 场景2: 领域进展追踪 - "城市场景重建"

**步骤1**: 批量检索
```bash
scripts/batch_search.sh "urban scene reconstruction|large scale 3D reconstruction|city level 3D" 20 > /tmp/urban.xml
```

**步骤2**: 解析结果
```bash
scripts/parse_arxiv_results.sh /tmp/urban.xml
```

**步骤3**: 查看趋势（按年份排序）
结果会自动按时间排序，可以看到技术演进路径

## 输出格式说明

### 简洁模式（默认）
```
### 1. **NeRF: Representing Scenes as Neural Radiance Fields**
   - **作者**: Mildenhall et al.
   - **年份**: 2020
   - **ArXiv**: 2003.08934
   - **摘要**: 首次提出神经辐射场概念，使用神经网络隐式表示3D场景...
```

### 详细模式
使用 `analyze_paper.sh` 获取完整信息：
- 标题、作者、发布日期
- 完整摘要
- 论文类别
- PDF链接
- 操作建议

## 脚本功能详解

### search_arxiv.sh
- **功能**: 基础ArXiv检索
- **参数**: `<query> [count]`
- **输出**: XML格式结果（原始ArXiv API返回）

### batch_search.sh
- **功能**: 多关键词批量检索
- **参数**: `<query1|query2|query3> [count]`
- **输出**: 合并的XML结果
- **特点**: 自动合并多个查询结果

### parse_arxiv_results.sh
- **功能**: 解析XML并去重
- **参数**: `<results_file> [mode]`
- **输出**: 格式化的论文列表
- **特点**:
  - 自动去重（基于标题）
  - 中文友好输出
  - 支持简洁/详细两种模式

### analyze_paper.sh
- **功能**: 详细分析论文
- **参数**: `<arxiv_id>`
- **输出**: 论文元数据 + 摘要 + 操作选项
- **特点**:
  - 自动检索完整信息
  - 提供PDF提取建议
  - 支持保存到日志

### extract_pdf.sh
- **功能**: 提取PDF内容
- **参数**: `<pdf_url>`
- **输出**: 文本内容
- **依赖**: 需要安装 pdftotext (poppler-utils)

### save_to_log.sh
- **功能**: 保存到研究日志
- **参数**: `<arxiv_id> [title]`
- **输出**: 保存到 `memory/RESEARCH_LOG.md`
- **特点**: 自动生成日志条目

## 集成到OpenClaw

在OpenClaw中，你可以通过对话直接使用这个skill：

**用户**: "帮我查一下NeRF做动态场景重建的相关论文"

**系统**: 自动调用脚本，展示结果

**用户**: "深入分析第一篇论文"

**系统**: 调用 `analyze_paper.sh` 和 `extract_pdf.sh`

**用户**: "把这些论文保存到我的研究日志"

**系统**: 自动调用 `save_to_log.sh` 批量保存

## 常见问题

### Q: 如何获取最新的研究进展？
A: 使用批量检索，设置较大的数量（20-30），然后解析结果查看最新发布日期。

### Q: 如何避免重复检索？
A: `parse_arxiv_results.sh` 会自动去重。也可以检查研究日志避免重复保存。

### Q: PDF提取失败怎么办？
A: 安装 `poppler-utils`:
```bash
sudo apt-get install poppler-utils
```

### Q: 如何追踪特定领域的新论文？
A: 定期运行批量检索，对比上次结果。可以结合cron任务自动化。

## 进阶使用

### 自定义查询
```bash
# 按作者检索
scripts/search_arxiv.sh "author:Mildenhall" 10

# 按类别检索
scripts/search_arxiv.sh "cat:cs.CV AND (neural rendering)" 10

# 组合查询
scripts/search_arxiv.sh "ti:dynamic AND (neural radiance fields)" 10
```

### 批量操作
```bash
# 检索并保存一批论文
scripts/batch_search.sh "topic1|topic2|topic3" 20 > /tmp/results.xml
scripts/parse_arxiv_results.sh /tmp/results.xml | grep "ArXiv:" | awk '{print $2}' | while read id; do
    scripts/save_to_log.sh "$id"
done
```

## 与其他Skill配合

- **academic-deep-research**: 深度研究某个主题
- **second-brain**: 保存知识点到知识库
- **todoist**: 创建论文阅读任务

## 更新日志

### v1.1 (2026-02-12) - 增强版
- ✨ 新增Idea验证功能
- ✨ 新增领域追踪功能
- ✨ 新增批量检索和去重
- ✨ 新增PDF提取能力
- ✨ 新增中文支持
- ✨ 新增自动归档功能
- 🔧 优化输出格式
- 📝 完善文档

### v1.0 - 原始版本
- 基础ArXiv检索
- 简单结果展示
