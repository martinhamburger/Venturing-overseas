---
name: research-poster-figma-workflow
description: Build, revise, and hand off academic or research posters through a local HTML/CSS plus optional Figma MCP workflow. Use when a user asks to make or update a poster, 学术海报, 科研海报, 课程海报, 思政海报, compress source material into poster copy, add charts, fit an official template, or upload a poster to Figma.
---

# Research Poster Figma Workflow

## Goal

Turn source material, layout constraints, and optional Figma/template context into a single-page poster that is concise, presentation-ready, and easy to hand off.

## Start Here

- Inspect the workspace before asking questions.
- If the repo already separates records, rules, templates, and prototype files, reuse that structure.
- Ask only for missing high-impact info. Keep questions short.
- Default to doing the work, not merely planning it.

## Requirement Pass

When key inputs are missing and cannot be inferred, ask for:

- source materials or their paths
- poster size/orientation plus submission rules
- mandatory sections, names, logos, advisor info, or reflections
- whether there is an official template, screenshot, or existing Figma frame
- whether the user wants local prototype only, Figma upload, or both
- whether charts are required and where the data comes from

If the workspace already answers these, do not ask again.

## Workflow

### 1. Read the source first

- Prefer local PDFs, DOCX, PPTX, notes, and existing poster drafts.
- Extract one main claim, supporting evidence, required numbers, named regions, and unavoidable labels.
- Do not add new claims unless they are verified from local material or the user explicitly asks for new research.

### 2. Read poster constraints

- Capture paper size, orientation, export format, DPI, file size, mandatory sections, institutional branding, and any font restrictions.
- If the user gives an official template, treat it as a constraint, not inspiration.
- If no template is fixed, choose a restrained academic structure that can survive Figma import.

### 3. Plan the poster before editing

- Lock the reading path: headline -> core takeaway -> framework/method -> evidence/cases -> cross-case synthesis -> strategy/implications -> low-priority references/contact.
- Compress paragraphs into poster-scale blocks.
- Move repeat points out of body text and into bullets, cards, or figure notes.
- Keep one dominant narrative; do not flatten the poster into equal-weight sections.

### 4. Add or revise charts deliberately

- Add a chart only when it makes comparison or trend faster to see.
- Every chart needs a title, unit, source basis, and 2-3 short interpretation bullets.
- Prefer simple SVG/HTML charts that survive local preview and Figma capture better than screenshots.
- If data is incomplete, say what is missing instead of fabricating a graphic.

### 5. Build locally first

- Prefer local HTML/CSS as the drafting surface.
- Let HTML own content structure and section order.
- Let CSS own typography, spacing, color, page size, and print/export behavior.
- Keep the poster to a single page unless the user explicitly asks otherwise.
- If the repo already has `poster/`, update it before touching Figma.

### 6. Make the page feel full, not crowded

- Run a balance pass after major edits.
- Fix dead space by rebalancing sections, charts, cards, gaps, or column widths, not by stuffing filler prose.
- Fix crowding by compressing copy, moving repeated points into figure notes, or redistributing section weight.
- The goal is a page that reads as complete and intentionally filled while still keeping visible breathing room.

### 7. Treat Figma as a bridge

- If there is no stable Figma master, prefer `local HTML/CSS -> generate_figma_design -> manual polish`.
- If there is an existing Figma frame or template, use `get_design_context`, `get_screenshot`, and `get_variable_defs` first, then map the findings back to local files.
- Do not assume free-form Figma object editing is the primary workflow.
- Keep versioned page/frame names when importing; do not overwrite earlier poster variants unless the user asks.

### 8. Finish with a typography and export pass

- Follow explicit font, size, spacing, and alignment requirements literally.
- If no exact typography is provided, use stable Chinese-friendly families and keep body text at poster-readable size.
- Check line breaks, unit alignment, chart labels, Chinese font fallback, edge margins, and print/export specs.
- Separate “must fix before import” from “can polish inside Figma”.

## Default Guardrails

- Keep headline and takeaway visually dominant.
- Keep copy concise and presentation-ready; do not paste long report paragraphs into the poster.
- Prefer 2 font families or fewer.
- Prefer 2-3 main colors with strong contrast.
- Keep body text at a readable poster scale; treat roughly 24pt equivalent as the floor.
- Favor 3-column or 4-column academic reading paths.
- Use figures, comparison blocks, and key-number cards before tables.
- If a table is unavoidable, keep only the essential fields.

## Workspace Pattern

When the workspace looks like this project, read [workspace-pattern.md](references/workspace-pattern.md).
Use that file for the proven split between `docs/`, `poster-agent/`, and `poster/`.

When you need a reusable review or handoff checklist, read [poster-checklist.md](references/poster-checklist.md).

## Suggested Deliverables

When the user wants a full working poster workflow, aim to leave behind:

- updated source-backed poster copy or section outline
- updated local prototype files
- short notes on chart logic and missing inputs
- Figma handoff/import status if the user asked for Figma
- a concise list of manual checks still needed

## Good Triggers

- “帮我把论文/结题报告做成 A1 海报”
- “根据学校模板重排这张科研海报”
- “压缩海报文字并补两张图表”
- “把本地 HTML 海报传到 Figma”
- “读取已有 Figma frame，再把本地海报改得更接近它”
