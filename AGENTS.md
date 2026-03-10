# Project Instructions

## Scope
- This workspace is for a research poster on `贸易战2.0背景下中国企业出海的应对策略研究`.
- The editable poster prototype lives in `poster/index.html` and `poster/styles.css`.
- The reusable workflow, rules, and project record live in `docs/` and `poster-agent/`.

## Preferred Workflow
- Treat `docs/` as the project record for workflow decisions, implementation notes, and next steps.
- Treat `poster-agent/` as the source of truth for prompts, rules, templates, and handoff artifacts.
- When the user asks to revise the poster, update the local HTML/CSS prototype first.
- Keep the poster to a single-page academic layout suitable for Figma capture and later manual refinement.
- Use the research copy already distilled in `poster/index.html`; only add new claims after checking the local source materials.
- Treat the Figma MCP server as a bridge, not a general-purpose layout engine.

## Figma Workflow
- For creating a new poster in Figma, prefer `local HTML/CSS -> Figma MCP generate_figma_design -> manual polish in Figma`.
- For revising an existing Figma frame, prefer `get_design_context`, `get_screenshot`, and `get_variable_defs`.
- If the user wants selection-based design context, use the Figma desktop MCP server with the desktop app open in Dev Mode.
- If the user wants to capture the local poster into a new Figma file, use the remote Figma MCP server.

## Poster Guardrails
- Keep language concise and presentation-ready; do not paste long report paragraphs into the poster.
- Preserve the current factual backbone unless the user provides a newer source:
  - Core topic: `贸易战2.0背景下中国企业出海的应对策略研究`
  - Method: `历史比较 + 实证案例`
  - Japanese reference patterns: `雁行模式 / 在地融合 / 跟随模式 / 协作模式 / 战略并购`
  - China sector cases: `家电 / 电车 / 电池 / 光伏 / 电踏车驱动系统`
  - 2024 Chinese EV exports: `200.53 万辆`
  - 2025 Chinese battery global share: `68%+`
  - 2024 Chinese PV module exports: `235.93 GW`
- Use a strong editorial hierarchy: headline, core conclusion, research framework, sector evidence, cross-case strategy, policy implications.

## Preview
- For local preview, run `python -m http.server 4173` from the workspace root and open `http://127.0.0.1:4173/poster/`.
