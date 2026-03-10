# Codex + Figma 海报工作流

更新时间：2026-03-10

## 1. 目标

让 Codex 在本地围绕一个固定海报模板和明确的版式规则工作，先产出可控的研究海报内容与布局规划，再接入 Figma 完成导入和人工微调。

当前海报对应的总课题为：

`贸易战2.0背景下中国企业出海的应对策略研究`

## 2. 当前默认路线

当前项目采用 `路线 A` 作为默认主干：

1. 本地整理内容与版式规则
2. 让 Codex 基于规则生成 `poster_content`、`layout_plan`、`handoff`
3. 先在本地 HTML/CSS 原型中验证信息层级
4. 再通过 Figma MCP 导入或读取设计上下文
5. 最后在 Figma 中手工微调

不采用“从零直接让 agent 自由生成整张海报”的原因很简单：

- 研究海报高度依赖信息层级控制
- 课题内容已有较强结构，不需要无约束发散
- 当前官方 Figma MCP 更适合做“桥接”和“上下文读取”，而不是完全替代设计师

## 3. 当前工作流分层

### 3.1 内容层

目录：`poster-agent/outputs/`

作用：

- 固化标题、核心结论、分区文案、数据数字
- 先把文案压缩成海报尺度
- 让后续换模板时不必重写内容

### 3.2 规则层

目录：`poster-agent/rules/`

作用：

- 规定海报的字数、主次层级、叙事顺序
- 约束 Figma 中哪些部分适合自动化，哪些必须人工检查

### 3.3 模板层

目录：`poster-agent/templates/`

作用：

- 规定海报结构、区块顺序、版式预设
- 为将来的 Figma 母版提供稳定映射

### 3.4 原型层

目录：`poster/`

作用：

- 用本地 HTML/CSS 快速验证视觉层级和信息密度
- 作为 `generate_figma_design` 的导入来源

### 3.5 Figma 接入层

当前已配置：

- 工作区 MCP：`.vscode/mcp.json`
- 全局 Codex MCP：`C:\Users\Martin\.codex\config.toml`

当前默认服务名：

- `figmaRemoteMcp`

## 4. 官方能力边界

截至 2026-03-10，当前项目采用以下理解作为事实边界：

- Figma 官方提供远程 MCP 服务器，可通过 `https://mcp.figma.com/mcp` 连接
- Figma 也提供桌面 MCP，本地地址为 `http://127.0.0.1:3845/mcp`
- 对“把本地海报转进 Figma”最合适的官方工具是 `generate_figma_design`
- 对“读取已有设计上下文”最合适的官方工具是 `get_design_context`、`get_screenshot`、`get_variable_defs`

这意味着：

- 当前工作流不把“任意创建 frame / text / auto layout”视为默认可靠能力
- 自动导入海报时，优先走 `HTML/CSS -> generate_figma_design -> Figma 微调`
- 对已有 Figma 模板的迭代，优先走“读取上下文 -> 本地改内容/样式 -> 再次导入或人工覆盖”

## 5. 当前项目的标准执行顺序

### 步骤 1：维护内容源

先编辑：

- `poster-agent/outputs/poster_content.md`
- `poster-agent/outputs/poster_layout_plan.md`
- `poster-agent/outputs/poster_handoff.md`

而不是先改 Figma。

### 步骤 2：维护规则与模板

如需调整结构，先改：

- `poster-agent/rules/*.md`
- `poster-agent/templates/*.json`

### 步骤 3：更新本地视觉原型

再同步改：

- `poster/index.html`
- `poster/styles.css`

### 步骤 4：导入 Figma

两种模式：

- 新建设计稿：
  - 本地启动页面
  - 用远程 MCP 的 `generate_figma_design` 把页面导入 Figma
- 对已有 Figma 模板做对照修改：
  - 用桌面 MCP 读取选中 frame 的上下文和截图
  - 回到本地继续改规则、文案或 HTML/CSS

### 步骤 5：人工终稿

必须人工检查：

- 字间距
- 视觉平衡
- 图像裁切
- 表格或图表对齐
- 中文字体表现
- 导出尺寸与边距

## 6. 当前目录分工

### `docs/`

记录工作流、决策、日志和后续动作。

### `poster-agent/`

给 Codex 用的“任务说明 + 规则 + 模板 + 输出”。

### `poster/`

给人看、给 MCP 捕捉、给 Figma 导入的视觉原型。

## 7. 当前推荐的实际操作

如果今天要继续做这张海报，建议按这个顺序：

1. 先确认一个 Figma 科研海报母版
2. 如母版结构有变化，先改 `poster-agent/templates/poster_sections.json`
3. 如文案重心有变化，先改 `poster-agent/outputs/poster_content.md`
4. 如视觉层级要调整，再改 `poster/index.html` 与 `poster/styles.css`
5. 最后做一次 Figma 导入并开始微调

## 8. 官方参考

- Figma MCP 总览：
  - https://developers.figma.com/docs/mcp/
- Figma Remote MCP 安装：
  - https://developers.figma.com/docs/mcp/remote-server-installation/
- Figma Desktop MCP 安装：
  - https://developers.figma.com/docs/mcp/desktop-server-installation/
- Figma MCP 工具列表：
  - https://developers.figma.com/docs/mcp/tools-and-prompts/
- Figma MCP 客户端说明：
  - https://developers.figma.com/docs/mcp/clients/
