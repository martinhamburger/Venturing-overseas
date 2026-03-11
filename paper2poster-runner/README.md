# Paper2Poster Runner

这个目录是我们给 `Paper2Poster` 做的本地运行器，目标很明确：

1. 不依赖 `git clone` 作为唯一入口
2. 每次尝试都自动编号并留痕
3. 先拿到可编辑的 `poster.pptx`
4. 后面再决定是否继续进 Figma 精修

## 当前状态

已经完成：
- 版本化运行入口已经就位
- Docker 路线已经补强
- upstream 支持三种接入方式：原生下载、Docker 下载、已有本地目录导入
- `run_docker.ps1` 现在会先把输入复制到 ASCII 临时目录，再挂载给 Docker，尽量绕开 Windows 中文路径 bind mount 的不稳定问题
- 每次 PowerShell 运行都会写入 `versions/<paper_folder>/vNNN/`

当前仍缺：
- `paper2poster-runner/Paper2Poster/` 还没有落盘
- `paper2poster-runner/.env` 还没有创建
- `paper2poster-runner/Paper2Poster-data/my_paper/paper.pdf` 还没有放入

## 你应该先看哪里

- 运行说明：`paper2poster-runner/README.md`
- 一键体检：`paper2poster-runner/scripts/check_runner_ready.ps1`
- 上游下载：`paper2poster-runner/scripts/bootstrap_upstream.ps1`
- Docker 运行：`paper2poster-runner/scripts/run_docker.ps1`
- 版本记录：`paper2poster-runner/versions/`

## 推荐顺序

### 1. 看当前缺什么

```powershell
./paper2poster-runner/scripts/check_runner_ready.ps1
```

### 2. 拉取 upstream

优先尝试自动 bootstrap：

```powershell
./paper2poster-runner/scripts/bootstrap_upstream.ps1 -Method Docker
```

如果你已经在别处拿到了完整的 `Paper2Poster` 源码目录，也可以直接导入：

```powershell
./paper2poster-runner/scripts/install_upstream_from_path.ps1 -SourcePath "D:\path\to\Paper2Poster"
```

### 3. 补运行前置条件

- 复制 `paper2poster-runner/.env.example` 为 `paper2poster-runner/.env`
- 填入 `OPENAI_API_KEY`
- 把论文放到 `paper2poster-runner/Paper2Poster-data/my_paper/paper.pdf`

### 4. 运行 Docker 版

```powershell
./paper2poster-runner/scripts/run_docker.ps1 -PaperFolder my_paper
```

## 输出在哪里看

主要看这三个地方：

- 原始输出：`paper2poster-runner/outputs/`
- 最终归档：`paper2poster-runner/outputs/final/`
- 版本快照：`paper2poster-runner/versions/my_paper/vNNN/`

每个版本目录里至少会有：
- `manifest.json`
- `notes.md`
- `command.txt`
- `artifacts/run.log`
- `output/poster.pptx`（生成成功时）

## 现有历史

目前已经有两次失败尝试被记录：
- `v001`：早期 Docker 不可用时的失败
- `v002`：upstream 尚未落盘时的失败

这些历史不会被覆盖，后面新的尝试会继续生成 `v003`、`v004`。

## 备注

- `.docker-config/` 现在会落在 runner 目录下，避免当前环境去读取用户主目录的 Docker 配置时报权限错误。
- 如果 `bootstrap_upstream.ps1 -Method Docker` 仍然失败，下一条最稳的路就是用 `install_upstream_from_path.ps1` 从已有本地源码目录导入。
