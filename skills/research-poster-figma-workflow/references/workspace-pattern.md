# Workspace Pattern

This workspace uses a layered poster workflow that is worth reusing when a repo already has similar folders.

## Directory Roles

- `docs/`
  - project record for workflow decisions, source distillation, implementation notes, and next steps
- `poster-agent/`
  - Codex-facing layer for rules, prompts, templates, outputs, and handoff notes
- `poster/`
  - editable local single-page prototype used for preview, capture, and Figma import

## Standard Working Order

1. Update or extract poster copy into `poster-agent/outputs/`
2. Update structural rules in `poster-agent/rules/` and section maps in `poster-agent/templates/`
3. Sync the actual poster in `poster/index.html` and `poster/styles.css`
4. Preview locally
5. Import to Figma or compare against an existing Figma frame
6. Perform manual typography and export checks

Do not start by pushing text directly into Figma.

## Files That Matter Most In This Repo

- `docs/codex-figma-poster-workflow.md`
  - formal statement of the local HTML/CSS plus Figma bridge
- `docs/final-report-distillation.md`
  - why the report was reorganized into poster sections instead of chapter order
- `docs/reference-sources.md`
  - external poster-design and Figma references that informed the rules
- `poster-agent/outputs/poster_content.md`
  - poster-scale copy and chart notes
- `poster-agent/outputs/poster_layout_plan.md`
  - reading path, priority, and chart placement
- `poster-agent/outputs/poster_handoff.md`
  - Figma import sequence and manual polish notes
- `poster-agent/rules/poster_design_rules.md`
  - narrative, density, typography, and whitespace rules
- `poster-agent/rules/figma_mapping_rules.md`
  - when to use HTML capture vs existing Figma-template workflows
- `poster-agent/templates/poster_sections.json`
  - section IDs, priority, and word limits
- `poster/index.html`
  - structure, content blocks, and inline SVG charts
- `poster/styles.css`
  - page size, typography, spacing, color system, and print behavior

## Proven Defaults From This Repo

- single-page academic poster
- A1 portrait layout
- local preview served from `http://127.0.0.1:4173/poster/`
- concise hierarchy:
  - headline
  - core takeaway
  - framework and key numbers
  - evidence panels and charts
  - conclusions, strategies, and reflections
- inline SVG charts plus short interpretation bullets instead of heavy screenshots
- stable Chinese font stacks:
  - `"Noto Sans SC", "Source Han Sans SC", "Microsoft YaHei", sans-serif`
  - `"Noto Serif SC", "Source Han Serif SC", "Songti SC", serif`
- restrained palette controlled with CSS custom properties

## Figma Pattern In This Repo

- preferred bridge for a new poster:
  - `local HTML/CSS -> generate_figma_design -> manual polish`
- preferred tools for revising an existing frame:
  - `get_design_context`
  - `get_screenshot`
  - `get_variable_defs`
- remote MCP service name in `.vscode/mcp.json`:
  - `figmaRemoteMcp`

Treat Figma as the finishing surface, not the first drafting surface.

## Guardrails Worth Carrying Forward

- keep language concise and presentation-ready
- preserve the factual backbone unless a newer local source is confirmed
- keep one dominant narrative
- make conclusion and key numbers visible first
- keep body text readable at poster distance
- fill the page intentionally, but never with filler prose
