---
name: arxiv-watcher
description: ArXiv论文智能检索工具，支持Idea验证、领域追踪、批量检索。用于快速查找相似论文、了解领域进展、跟踪前沿研究。
---

# ArXiv Watcher 智能检索工具

与ArXiv API交互，智能检索、分析和总结最新研究论文。

## 核心功能

- **Idea验证**: 输入你的idea，智能检索相似论文并提供可参考建议
- **领域追踪**: 监控特定方向（如CV/CG、城市场景重建）的最新进展
- **批量检索**: 一次检索多个关键词，自动去重和排序
- **深度分析**: 按需提取PDF内容，进行详细分析
- **结构化输出**: 列表形式，清晰易读
- **自动归档**: 保存到 `memory/RESEARCH_LOG.md` 长期跟踪

## 使用场景

### 场景1: Idea验证
输入你的idea描述，系统将：
1. 拆解idea为核心关键词（中英文）
2. 执行多轮检索，扩展查询范围
3. 返回相似论文列表
4. 提供可参考论文建议
5. 分析差异化空间

示例：
- "我的想法是用NeRF结合大模型实现语义3D重建，有没有相关研究？"
- "想用transformer改进点云处理的效率，类似研究有哪些？"

### 场景2: 领域进展追踪
输入研究领域关键词，系统将：
1. 检索该方向最新论文
2. 识别经典基础论文
3. 分析技术演进趋势
4. 按时间/相关性排序展示

示例：
- "城市场景重建方向的最新进展"
- "CV领域的扩散模型研究现状"

## 工作流程

### Step 1: 智能查询构建
- 将用户输入拆解为核心概念
- 生成中英文查询词
- 自动扩展同义词和相关术语

### Step 2: 多轮检索
```bash
# 基础检索（主关键词）
scripts/search_arxiv.sh "neural radiance fields" 10

# 扩展检索（相关概念）
scripts/search_arxiv.sh "neural rendering 3d" 10

# 批量检索（多个关键词）
scripts/batch_search.sh "neural fields|implicit neural|volumetric rendering" 20
```

### Step 3: 结果处理
- 去重（基于标题相似度）
- 排序（按相关性 + 时间）
- 过滤（时间范围、类别等）
- 中文总结（摘要翻译和要点提炼）

### Step 4: 输出呈现
```
## 检索结果：NeRF相关论文

### 高度相关 ⭐⭐⭐
1. **NeRF: Representing Scenes as Neural Radiance Fields**
   - 作者: Mildenhall et al.
   - 时间: 2020
   - ArXiv: 2003.08934
   - 要点: 首次提出NeRF概念，使用神经网络隐式表示3D场景...

### 相关 ⭐⭐
2. **Neural Radiance Fields for Unconstrained Photo Collections**
   - ...

### 部分相关 ⭐
3. **...
```

### Step 5: 按需深度分析
```bash
# 提取PDF详细内容
scripts/extract_pdf.sh "https://arxiv.org/pdf/2003.08934.pdf"

# 分析论文方法、实验、贡献
scripts/analyze_paper.sh "2003.08934"
```

### Step 6: 自动归档
```markdown
### [2026-02-12] NeRF: Representing Scenes as Neural Radiance Fields
- **作者**: Mildenhall et al.
- **链接**: https://arxiv.org/abs/2003.08934
- **标签**: #NeRF #neural-rendering #3d-reconstruction
- **总结**: 首次提出神经辐射场概念...
- **我的笔记**: [可选：你的见解]
```

## 命令工具

### 基础检索
```bash
scripts/search_arxiv.sh "<query>" [count]
```

### 批量检索
```bash
scripts/batch_search.sh "<query1|query2|query3>" [count]
```

### PDF提取
```bash
scripts/extract_pdf.sh "<pdf_url>"
```

### 论文分析
```bash
scripts/analyze_paper.sh "<arxiv_id>"
```

### 领域追踪
```bash
scripts/track_field.sh "<field_name>" "<keywords>"
```

## 输出格式

### 简洁模式（默认）
- 标题
- 作者
- 年份
- ArXiv ID
- 1-2句要点总结

### 详细模式（用户指定）
- 标题
- 作者
- 年份
- ArXiv ID
- 摘要翻译
- 核心贡献
- 方法概述
- 实验结果
- 相关工作
- 我的分析

## 示例对话

**用户**: "我想研究用NeRF做动态场景重建，有没有相关论文？"

**系统**:
```
🔍 正在检索: NeRF 动态场景重建...

## 检索结果（共12篇相关论文）

### ⭐⭐⭐ 高度相关

1. **NeRF in the Wild: Neural Radiance Fields for Unconstrained Photo Collections**
   - 作者: Martin-Brualla et al.
   - 时间: 2021
   - ArXiv: 2008.02268
   - 要点: 处理真实照片集合中的场景，包含光照变化和相机不稳定问题...

2. **Dynamic Scene Representation with Neural Radiance Fields**
   - 作者: Pumarola et al.
   - 时间: 2021
   - ArXiv: 2101.05278
   - 要点: 首次将NeRF扩展到动态场景，使用变形网络处理物体运动...

[更多结果...]

💡 可参考方向:
- 结合光流估计和NeRF
- 使用时空注意力机制
- 多视角视频处理技巧

需要我深入分析某篇论文吗？
```

## 技术实现

- ArXiv API: https://export.arxiv.org/api/query
- PDF提取: 使用web_fetch下载并解析
- 去重算法: 基于标题相似度（Jaccard相似性）
- 翻译: 使用模型生成中文总结
- 记忆存储: `memory/RESEARCH_LOG.md`

## 资源文件

- `scripts/search_arxiv.sh`: 基础ArXiv API检索
- `scripts/batch_search.sh`: 批量检索和去重
- `scripts/extract_pdf.sh`: PDF内容提取
- `scripts/analyze_paper.sh`: 论文详细分析
- `scripts/track_field.sh`: 领域定期追踪

## 与其他Skill的关系

- **academic-deep-research**: 深度学术研究，多源数据，长篇报告
- **arxiv-watcher**: ArXiv快速检索，论文列表和摘要

两者互补：用arxiv-watcher快速筛选论文，用academic-deep-research进行深度研究。
