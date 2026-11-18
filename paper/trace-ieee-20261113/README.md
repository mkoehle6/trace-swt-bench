# TRACE IEEE conference paper

Open [trace_experiment.pdf](trace_experiment.pdf) for the latest compiled paper. Refreshed November 17, 2026: 9 pages. `TRACE_paper_20261117.pdf` is an identical dated copy.

## Current contents

- `main.tex`: title, three authors and DePaul affiliation, abstract, packages, document assembly.
- `body.tex`: six main sections, workflow explanations, results, limitations, and conclusions.
- `appendix.tex`: six case studies with P1-P4 test-quality assessments; Appendix B outcomes; reproducibility, hardware/course details, billing and AI disclosure.
- `outcomes-table.tex`: all 26 paired results. Appendix B uses a dedicated full-width page so the heading and table stay together.
- `references.tex`: bibliography; updated immutable artifact link remains a TODO.
- `IEEEtran.cls`: unchanged document class; copyright and license retained.
- `evidence.json`: original experiment evidence index, metrics and provenance; preserved unchanged.
- `trace_experiment.pdf`, `TRACE_paper_20261117.pdf`: identical current PDFs.
- `trace_experiment.txt`: text extracted from the current PDF.
- `preview-page-1.png` through `preview-page-9.png`: current page previews.
- `word-count.json`: current approximate body-text count; not a formal texcount result.
- `draft-validation.json`: current source/PDF hashes and checks, with diagnostic limitations.
- `current-build.txt`: latest compile/export status.
- `historical-build-20261113/`: preserved original compiler logs and auxiliary files; these are not current diagnostics.
- `trace_ieee_draft.zip`: refreshed source-and-output package, excluding itself.

## Build

The current PDF was compiled and downloaded from the desktop LaTeX editor. Open `main.tex` as the project main document. Alternatively, use Overleaf or run twice with a local TeX installation:

```sh
pdflatex -interaction=nonstopmode -halt-on-error -jobname=trace_experiment main.tex
pdflatex -interaction=nonstopmode -halt-on-error -jobname=trace_experiment main.tex
```

No BibTeX pass is needed. Detailed logs from the latest editor compilation were not exported; historical logs must not be used to certify this build.

## Results and scope

Official outcomes remain baseline 16/26 and TRACE 17/26; applicability is 26/26 for both. The same shared native-test adaptation was used for both methods. No predictions, benchmark data, or outcomes were changed during the manuscript refresh.

The provider exports report $0.959975793 in charges across their period; this is not a separate per-method generation total. Hardware and course details are recorded in Appendix C. Contributions are a team effort; DeepSeek, mini-SWE-agent, Codex, ChatGPT GPT-6.1, and Claude are disclosed in Appendix D.

## Remaining information

Submission date and commit-pinned artifact links are finalized. Docker/WSL resource allocations and some historical tool/model versions were not recorded. See the manuscript for these limitations. This folder refresh does not itself commit or push changes to GitHub.

November 17 proofreading: clarified the measured research question, named fallback and identical-patch instances, reported McNemar exact p=1.0, identified history flags by arm, explained zero coverage delta, standardized outcome labels, and added complete appendix/table pointers. Course information is now a title-page footnote. The earlier dated PDF is retained in `historical-build-20261116/`.

Second November 17 wording pass: parallel P1-P4 definitions, clearer evaluator criteria and unit of analysis, consistent issue-specification and input/output-token terminology, explicit rounded billing value, and qualified fallback spending. Sources and PDFs remain synchronized.

Second November 17 terminology pass: parallel P1-P4 definitions, clearer evaluator criteria and unit of analysis, consistent issue-specification and input/output-token terminology, explicit rounded billing value, and qualified fallback spending. Sources and PDFs remain synchronized.

Final November 17 clarity review: simplified abstract and evaluation criteria, clarified units and costs, shortened ambiguous implications, and replaced hard-coded section numbers with cross-references. Submission date and Claude Sonnet 5.5 disclosure included. Sources and PDFs remain synchronized.

Final snapshot citation update (November 17, 2026): sources and exported PDF reference commit `a5344b0abf54dcb9674f70261ad1a66d938f8a3f`. Current PDFs and source archive are synchronized; experiment results are unchanged.

Final snapshot citation update (November 17, 2026): sources and exported PDF reference commit `a5344b0abf54dcb9674f70261ad1a66d938f8a3f`. Current PDFs and source archive are synchronized; experiment results are unchanged.
