# Figma 映射规则

## 1. 当前默认工作模式

### 模式 A：本地原型导入 Figma

适用场景：

- 还没有固定的 Figma 母版
- 想先快速得到一版可编辑设计稿

做法：

1. 在本地更新 `poster/index.html` 与 `poster/styles.css`
2. 启动本地预览页面
3. 使用远程 MCP 的 `generate_figma_design`
4. 在 Figma 中继续人工微调

### 模式 B：读取已有 Figma 模板

适用场景：

- 已选定科研海报模板
- 想保留母版结构，只替换内容和局部样式

做法：

1. 用桌面 MCP 读取选中 frame 的设计上下文和截图
2. 将结构映射回 `templates/` 和 `outputs/`
3. 先在本地改文案与规则
4. 再决定是重新导入还是手工贴回模板

## 2. Figma 页面与 Frame 命名建议

- 页面名：`Poster`
- 主 frame：`PV-Poster-A1-v1`
- 导入测试页：`Poster-Import-Test`
- 不同方案用版本号区分，不要覆盖老版本

## 3. 自动化与人工分工

### 适合自动化

- 文案压缩
- 区块顺序规划
- 数字卡内容生成
- 模块优先级建议
- 初步视觉原型导入

### 必须人工检查

- 中文字体是否替换正确
- 断行是否自然
- 数字与单位是否对齐
- 图表是否清晰
- LOGO、校名、署名是否准确

## 4. 图层命名建议

- `title/main`
- `title/sub`
- `meta/authors`
- `meta/affiliation`
- `takeaway/main`
- `stats/export`
- `stats/share`
- `stats/europe`
- `stats/jinko`
- `section/modes`
- `section/case`
- `section/regions`
- `section/recommendations`

## 5. 当前项目提示

- 当前工作区远程 MCP 服务名为 `figmaRemoteMcp`
- 若后续启用桌面 MCP，再补充本地服务配置
