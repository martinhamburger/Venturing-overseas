# Paper2Poster 替代工作流
更新时间：2026-03-11

## 1. 为什么保留这条路线

`Codex + Figma` 适合已经有相对稳定的版式框架，再去做内容填充和设计微调。

`Paper2Poster` 适合另一种目标：
- 输入 `paper.pdf`
- 快速得到可编辑的 `poster.pptx`
- 先拿到第一版
- 再决定是否进入 Figma 做视觉精修

所以它不是替代 Figma，而是给我们多一条“先出稿、再精修”的路线。

## 2. 昨天到今天完成了什么

已经落地：
- `paper2poster-runner/` 独立运行器目录
- Docker、本地 Python、复制最终输出、版本归档等 wrapper 脚本
- 自动版本号机制，PowerShell 每次运行会生成 `versions/<paper_folder>/vNNN/`
- `manifest.json`、`notes.md`、`command.txt`、`run.log` 的留痕机制
- `install_upstream_from_path.ps1`，支持从已有本地源码目录直接导入 upstream
- `check_runner_ready.ps1`，用于一次性检查 Docker、upstream、`.env`、`paper.pdf` 是否到位

今天补强：
- `bootstrap_upstream.ps1` 现在支持重试，并优先使用 `curl.exe` 的断点续传能力
- Docker bootstrap 现在改成“容器内下载 + docker cp 取回”，不再依赖中文路径 bind mount
- `run_docker.ps1` 现在会先把输入复制到 ASCII 临时目录，再交给 Docker 挂载，尽量规避 Windows 中文路径问题
- runner 内增加本地 `.docker-config/`，避免当前环境访问用户主目录 Docker 配置时报权限问题

## 3. 当前真实状态

当前已经确认：
- `docker --version` 可用
- 版本追踪机制可用
- upstream 仍未完整落盘
- `.env` 仍未创建
- `paper.pdf` 仍未放入 `Paper2Poster-data/my_paper/`

所以当前不是“脚本没写完”，而是“运行前置条件还没全部就位”。

## 4. 现在最合理的执行顺序

1. 先跑：
   ```powershell
   ./paper2poster-runner/scripts/check_runner_ready.ps1
   ```

2. 然后拿 upstream：
   ```powershell
   ./paper2poster-runner/scripts/bootstrap_upstream.ps1 -Method Docker
   ```

3. 如果 upstream 仍然拿不下来，就改走：
   ```powershell
   ./paper2poster-runner/scripts/install_upstream_from_path.ps1 -SourcePath "D:\path\to\Paper2Poster"
   ```

4. 补 `.env` 和 `paper.pdf`

5. 再跑：
   ```powershell
   ./paper2poster-runner/scripts/run_docker.ps1 -PaperFolder my_paper
   ```

## 5. 你能在哪里看结果

优先看：
- `paper2poster-runner/outputs/`
- `paper2poster-runner/outputs/final/`
- `paper2poster-runner/versions/my_paper/`

每个版本目录都能回答这几个问题：
- 当时跑的是哪条命令
- 用了什么参数
- 成功还是失败
- 失败原因是什么
- 最终输出有没有生成

## 6. 后续还可以怎么改进

如果这条路线后面要长期使用，我建议按这个顺序继续升级：

1. 给 `bootstrap_upstream.ps1` 再补一层更详细的失败日志
2. 给 Docker 运行入口增加对多个 `paper_folder` 的批量处理能力
3. 把 `poster.yaml` 调参过程也纳入版本记录
4. 成功生成 `poster.pptx` 后，再决定要不要导入 Figma 继续精修
5. 如果后面需要自动多轮试验，再把“版本标签”和“本轮改动说明”写得更结构化
