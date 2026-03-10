# 查看、修改与分享

## 1. 我生成的东西在哪里看

### 视觉海报

打开：

- `poster/index.html`

推荐方式：

1. 在项目根目录运行 `python -m http.server 4173`
2. 打开 `http://127.0.0.1:4173/poster/`

### 内容与版式规划

打开：

- `poster-agent/outputs/poster_content.md`
- `poster-agent/outputs/poster_layout_plan.md`
- `poster-agent/outputs/poster_handoff.md`

### 工作流与依据

打开：

- `docs/codex-figma-poster-workflow.md`
- `docs/final-report-distillation.md`
- `docs/reference-sources.md`

## 2. 你可以修改它吗

可以，而且推荐这样改：

- 改内容逻辑：先改 `poster-agent/outputs/`
- 改规则：改 `poster-agent/rules/`
- 改视觉：改 `poster/index.html` 和 `poster/styles.css`

## 3. 你可以分享它吗

可以。

### 本地分享

- 直接把项目文件夹打包给别人
- 对方打开 `poster/index.html` 即可查看

### 文档分享

- 浏览器中将页面导出为 PDF
- 或打印为 PDF 后发送

### Figma 分享

- 将本地页面导入 Figma
- 直接分享 Figma 文件链接

## 4. 最适合当前项目的分享方式

如果你要给老师或组员快速看：

- 先发 PDF

如果你要和别人协同微调：

- 导入 Figma 后发 Figma 链接

如果你要保留可编辑源码：

- 直接分享整个项目目录
