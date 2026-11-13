# TRACE IEEE conference paper draft

Start with [trace_experiment.pdf](trace_experiment.pdf). The manuscript uses `\documentclass[conference]{IEEEtran}` and the official IEEE conference template's structure. The unmodified IEEEtran class is included for portability; its license and copyright notices remain in `IEEEtran.cls`.

The main paper contains the six requested sections. The appendix supplies six distinct case analyses, generated-test excerpts, all 26 paired outcomes, reproducibility notes, contributions placeholders, and AI disclosure. This draft reports the completed official evaluation, superseding the evaluation-pending statements in the older preliminary report without editing that historical file.

## Files

- `main.tex`: title, author placeholders, abstract, packages, and document assembly.
- `body.tex`: six main sections, result and paired-comparison tables.
- `appendix.tex`: six detailed cases and outstanding information.
- `outcomes-table.tex`: complete official outcomes.
- `references.tex`: IEEE-style numbered references.
- `evidence.json`: computed metrics, case-selection rule, source paths, and source hashes.
- `word-count.json`: reproducible approximate count of main prose; abstract/tables/references/appendices excluded.
- `GUIDELINE_REVIEW.md`: requirement-to-manuscript mapping and known gaps.
- `SOURCE_PROVENANCE.md`: guideline and IEEE template sources.
- `trace_experiment.pdf`: compiled draft. Build logs are preserved.

## Compile

Upload the `.tex` files and `IEEEtran.cls` to Overleaf and choose `main.tex` as the main document, or run locally:

```sh
pdflatex -interaction=nonstopmode -halt-on-error -jobname=trace_experiment main.tex
pdflatex -interaction=nonstopmode -halt-on-error -jobname=trace_experiment main.tex
```

No BibTeX pass is needed because the draft uses `thebibliography`. Standard LaTeX packages include `booktabs`, `listings`, `hyperref`, and `xcolor`. The compiled document preserves IEEE margins and columns. It does not use manual font/geometry changes to shrink the paper.

## Remaining placeholders

- Authors, affiliation, and contact details: intentionally omitted at the user's request.
- Complete generation spending: reconcile provider billing/rates, cache pricing, preprocessing, and historical attempts. Known agent-only costs and saved preprocessing token totals are reported separately.
- Host CPU/RAM/Docker allocation and budget for repeats.
- Team/course identifier, submission date, and immutable final artifact release/commit.
- Member contributions and the precise list of AI outputs independently reviewed or modified by the team.

The project owner clarified that the guideline's “DeepFlash” baseline refers to DeepSeek. The paper retains the actual recorded generation and preprocessing model identifiers, and does not invent an immutable provider version.

## Interpretation

Official outcomes are baseline 16/26 and TRACE 17/26, with paired counts 15/1/2/8 (both/baseline-only/TRACE-only/neither). All predictions apply; all 52 reports exist. The paper reports parser-attribution discrepancies separately from raw pre/post behavior, and discloses protocol and historical-image limitations. Neither a success flag nor a coverage score certifies all agent actions complied with the experimental rules.

This is an AI-assisted draft requiring team review. No experiment was rerun or changed to write it. Evaluation/reference artifacts were read only for analysis, never supplied for generation or repair. No GitHub push was performed while preparing this paper.
