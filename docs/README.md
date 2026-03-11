# 文档索引

这个目录用来记录海报项目的工作流、决策、实施记录和下一步动作。

## 建议阅读顺序

- `codex-figma-poster-workflow.md`
  - Figma 路线的正式工作流说明
- `reference-sources.md`
  - 海报设计与学术表达参考来源
- `final-report-distillation.md`
  - 结题报告如何被提炼成海报逻辑
- `decision-log.md`
  - 关键决策及原因
- `implementation-log.md`
  - 已经做过的实现与未完成事项
- `next-steps.md`
  - 之后待执行动作
- `edit-and-share.md`
  - 在哪里查看、修改和分享海报
- `paper2poster-alternative-workflow.md`
  - Paper2Poster 替代路线的计划、现状、阻塞项和后续升级方向

## 相关目录

- `poster/`
  - 本地 HTML/CSS 海报原型
- `poster-agent/`
  - 给 Codex 使用的规则、模板、prompt 和中间产物
- `paper2poster-runner/`
  - Paper2Poster 本地运行器
  - 适合先从 `paper.pdf` 生成可编辑 `poster.pptx`
- `.vscode/mcp.json`
  - 当前工作区的 Figma MCP 配置

## 当前状态

- 已有本地海报原型：`poster/index.html`
- 已有 Figma MCP 配置：`.vscode/mcp.json`
- 已有项目级工作流骨架：`poster-agent/`
- 已有 Paper2Poster 运行器：`paper2poster-runner/`
- 当前优先路线：`local HTML/CSS -> Figma MCP -> manual polish`
- Paper2Poster 路线已完成大部分接入验证，但由于 Docker 依赖重、构建链路复杂，当前更适合作为参考工作流而非主交付路径
