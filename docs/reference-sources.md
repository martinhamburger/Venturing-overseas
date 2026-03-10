# 参考来源

更新时间：2026-03-10

本文件记录这次海报原型与工作流中实际参考过的外部来源，用于说明版式和流程选择的依据。

## 零、本地内容依据

### 结题报告

本地文件：

- `结题报告.pdf`
- `最终PPT/结题报告PPT.pptx`

使用原因：

- 它们是当前海报文字内容的核心来源
- 本项目的主题、结构、案例与策略建议均以结题报告为准

## 一、学术海报设计原则

### American Psychological Association

链接：

- https://convention.apa.org/presenters/posters

使用原因：

- 官方会议级海报建议
- 明确强调清晰、简洁、战略性设计
- 明确推荐 Better Poster 改造版以突出核心信息

本项目吸收的规则：

- 优先突出核心结论
- 保持信息顺序清晰
- 非必要内容放到口头讲解或补充说明中

### Association of Research Libraries

链接：

- https://www.arl.org/accessibility-guidelines-for-posters/

使用原因：

- 提供可访问性底线
- 给出最小字体和高可读性要求

本项目吸收的规则：

- 正文不低于 24pt 等效可读尺寸
- 高对比度正文
- 图像和颜色不能只依赖单一色彩传达信息

### Widener University Research Poster Guide

链接：

- https://widener.libguides.com/Poster/BestPractices
- https://widener.libguides.com/Poster/PosterParts

使用原因：

- 对海报的结构、字体层级和结果区比重给出了很明确的建议

本项目吸收的规则：

- 标题尽量控制在两行内
- 结果区尽量以视觉内容为主、减少文字
- 字体数量尽量控制在两套以内
- 颜色尽量控制在 2 到 3 个主色

### Davenport University Poster Guide

链接：

- https://davenport.libguides.com/posters/design

使用原因：

- 提供“至少约 1/3 留白”和“2 到 3 个颜色”的明确建议

本项目吸收的规则：

- 当前海报色彩收缩为墨色、赭红、金色三主色
- 版式中主动保留留白，不做满版堆叠

### Erau Poster Presentation Design Guide

链接：

- https://erau.libguides.com/poster-presentations/design

使用原因：

- 提供实操性很强的设计底线

本项目吸收的规则：

- 使用项目符号控制文本密度
- 使用浅底深字
- 不让 LOGO、背景和花哨装饰抢主信息

## 二、公开模板与仓库

### osvalB / figma_science_poster_templates

链接：

- https://github.com/osvalB/figma_science_poster_templates

使用原因：

- 提供直接可导入 Figma 的科研海报模板
- 说明了 Figma 文件导入与编辑流程

本项目吸收的规则：

- 留白优先
- 颜色控制在 3 到 4 个以内
- 图文对齐严格处理

### MIT-BECL / Poster_Resources

链接：

- https://github.com/MIT-BECL/Poster_Resources

使用原因：

- 提供多个方向和尺寸的科学海报模板
- 带有最佳实践标注示例

本项目吸收的规则：

- 模板优先于从零排版
- 用结构约束内容，而不是让内容无限膨胀

### njwfish / stanford-poster-templates

链接：

- https://github.com/njwfish/stanford-poster-templates

使用原因：

- 对“海报不是论文全文”的解释很直接
- 对“更多视觉、少量文字、清晰对齐”给出了可执行建议

本项目吸收的规则：

- 除摘要外不保留长段文字
- 更强调视觉引导和结果呈现
- 用统一对齐和呼吸感控制版面质量

## 三、Figma 工作流

### Figma MCP 文档

链接：

- https://developers.figma.com/docs/mcp/
- https://developers.figma.com/docs/mcp/tools-and-prompts/
- https://developers.figma.com/docs/mcp/remote-server-installation/
- https://developers.figma.com/docs/mcp/desktop-server-installation/

使用原因：

- 确认当前官方能力边界
- 确认本项目应优先采用 `generate_figma_design` 做桥接

本项目吸收的规则：

- Figma MCP 作为桥接层
- 本地 HTML/CSS 原型作为导入源
- 终稿仍需要人工微调
