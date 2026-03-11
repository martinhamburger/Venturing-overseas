# Versions

Each generation attempt is recorded under:

```text
versions/<paper_folder>/vNNN/
```

Each version directory is intended to be traceable:

- `manifest.json`
  - machine-readable metadata
- `notes.md`
  - human-readable summary
- `command.txt`
  - exact wrapper command that was attempted
- `poster.yaml.snapshot`
  - style snapshot used for that attempt, when available
- `output/poster.pptx`
  - version-specific poster copy, when generation succeeds
- `artifacts/run.log`
  - captured runner log, when available

Repeated runs automatically create the next version number.

