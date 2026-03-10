# Codex Prompts

## 1. 首次生成到 Figma

```text
请使用 Figma MCP 的 generate_figma_design 工具，把本地页面 http://127.0.0.1:4173/poster/ 捕捉到一个新的 Figma Design 文件中。

要求：
1. 捕捉整页，不要只截首屏。
2. 文件名命名为“中国企业出海策略研究海报-v1”。
3. 保留页面中的层级、标题、行业矩阵和关键数字。
4. 完成后把 Figma 文件链接返回给我。
```

## 2. 捕捉到已有 Figma 文件

```text
请使用 Figma MCP 的 generate_figma_design 工具，把 http://127.0.0.1:4173/poster/ 这个页面捕捉到这个 Figma 文件：
[把你的 Figma 文件链接贴在这里]

要求：
1. 新建一个页面或 frame，命名为“poster-html-import-v2”。
2. 不覆盖已有内容。
3. 完成后告诉我导入到了哪个页面或 frame。
```

## 3. 让 Codex 读取已有 Figma Frame 再继续改 HTML

```text
请读取这个 Figma frame 的设计上下文和截图，然后对比本地项目里的 poster/index.html 和 poster/styles.css，帮我把本地海报改成更接近这个 Figma 版本。

要求：
1. 先用 get_design_context 和 get_screenshot。
2. 保留中文内容，不改研究结论。
3. 只调整版式、颜色、间距和层级。
```

## 4. 让 Codex 只做文字压缩

```text
请根据 poster/index.html 里的现有内容，把每个模块的正文再压缩 20% 到 30%，但保留所有核心数字和地区结论。不要改视觉结构，只改文案长度。
```
