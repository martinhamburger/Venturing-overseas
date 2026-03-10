# 实施日志

## 2026-03-10

### 已完成

1. 提取本地课题材料中的核心结构
   - 主题：`贸易战2.0背景下中国光伏产业“出海”策略研究`
   - 主线：出口格局、出海模式、晶科案例、区域风险与对策

2. 创建本地海报原型
   - `poster/index.html`
   - `poster/styles.css`
   - `poster/codex_prompts_cn.md`
   - `poster/README.md`

3. 创建项目级规则文件
   - `AGENTS.md`

4. 配置 Figma 远程 MCP
   - 工作区配置：`.vscode/mcp.json`
   - 全局配置：`C:\Users\Martin\.codex\config.toml`

5. 建立文档化工作流
   - `docs/`
   - `poster-agent/`

6. 根据公开学术海报规范和模板来源，重做海报原型
   - 强化三栏阅读路径
   - 强化核心结论区
   - 降低文字密度
   - 收缩色彩系统

7. 补充外部来源与分享说明
   - `docs/reference-sources.md`
   - `docs/edit-and-share.md`

8. 根据结题报告重新校正海报范围
   - 从“光伏单行业海报”调整为“总课题综合海报”
   - 按结题报告的正式结构重写海报内容
   - 将日本经验、家电、电车、电池、光伏、电踏车与政策建议整合进一版

### 当前可直接使用的内容

- 本地可预览海报原型
- Codex/Figma 工作流说明
- 研究海报的规则、模板、prompt 和 handoff 文件
- 外部参考来源清单
- 查看、编辑和分享说明

### 尚未执行

- 绑定具体 Figma 模板链接
- 完成第一次正式导入 Figma
- 在 Figma 中根据模板进行精修
- 补入最终图表、学校标识、署名和导出设置

### 风险提示

- 如果后续换成不同尺寸或不同模板，优先修改 `poster-agent/templates/`
- 如果后续换数据口径，优先修改 `poster-agent/outputs/poster_content.md`
- 不建议直接把长篇课题文字贴进 Figma 再压缩
