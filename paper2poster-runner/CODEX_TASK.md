Set up and maintain a local Paper2Poster wrapper inside `paper2poster-runner/`.

Goal:
- turn `Paper2Poster-data/<paper_folder>/paper.pdf` into an editable `poster.pptx`
- prefer wrapper scripts over changing upstream source
- support both Docker and local Python execution
- support per-paper `poster.yaml` styling
- keep every attempt viewable and traceable

Constraints:
- do not redesign the project structure unless necessary
- do not modify the upstream Paper2Poster source unless required
- keep secrets in `.env`, never hardcode API keys
- assume `paper.pdf` is the canonical input filename

Required outputs:
1. reproducible scripts in `scripts/`
2. a short operational README
3. a clear place for per-paper style overrides
4. a final copied PPTX under `outputs/final/` when generation succeeds
5. a version folder for every attempt under `versions/<paper_folder>/vNNN/`

Default workflow:
1. bootstrap upstream repo
2. check `.env`
3. check `paper.pdf`
4. create a new traceable version folder before each attempt
5. run Docker first when available
6. fall back to local Python only when the machine is ready
