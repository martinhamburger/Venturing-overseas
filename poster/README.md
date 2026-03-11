# Research Poster Prototype

This folder contains the current editable poster prototype for `贸易战2.0背景下中国企业出海的应对策略研究`.

## What To Open

- Main preview file: `poster/index.html`
- Visual system: `poster/styles.css`
- Figma prompt snippets: `poster/codex_prompts_cn.md`

## How To View It

From the workspace root:

```powershell
python -m http.server 4173
```

Then open:

`http://127.0.0.1:4173/poster/`

## How To Edit It

- Edit text and structure in `poster/index.html`
- Edit color, spacing, typography, and layout in `poster/styles.css`
- If you want to revise the underlying content logic first, update:
  - `poster-agent/outputs/poster_content.md`
  - `poster-agent/outputs/poster_layout_plan.md`

## How To Share It

You can share this poster in three practical ways:

1. Share the local project folder with someone who can open `poster/index.html`
2. Export the page to PDF from the browser
3. Import the page into Figma and share the Figma file link

## Current Design Basis

This version follows recurring advice from reliable research-poster guides:

- emphasize the main takeaway early
- use a 3-column reading structure
- reduce paragraph density
- keep colors restrained
- preserve enough white space

Source notes are tracked in `docs/reference-sources.md`.

## Submission Constraints

According to the local poster template:

- the poster must be `A1` portrait (`594mm x 841mm`)
- resolution must be at least `150dpi`
- final export must be `png`, `jpeg`, or `jpg`
- final file size must stay under `20M`
- required content should at least include title, student team, advisor, abstract, content/process/method, concrete conclusions, and reflections

## Codex + Figma

The current default bridge is:

`local HTML/CSS -> Figma MCP generate_figma_design -> manual polish in Figma`

That route is more reliable than assuming full free-form Figma object editing.

### Current Figma Handoff Path

1. Run `python -m http.server 4173` from the workspace root.
2. Open `http://127.0.0.1:4173/poster/`.
3. Use the remote MCP server `figmaRemoteMcp`.
4. Import the page with `generate_figma_design`.
5. In Figma, use page `Poster` and main frame `PV-Poster-A1-v1`.
6. Manually check Chinese font fallback, number/unit alignment, chart spacing, and final A1 export settings.
