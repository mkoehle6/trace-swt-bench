# Frozen experiment reports

26 instances from princeton-nlp/SWE-bench_Verified, test split, revision
`c104f840cc67f8b6eec6f759ebc8b2693d585d4a`.

The Easy and Hard selections follow slides 31 and 32 of the supplied
SWT-bench x mini-swe presentation. easy.txt and hard.txt preserve slide order.
manifest.json records report SHA-256 hashes, repository base commits, and groups.
Use this same snapshot for both experimental methods. Historical baseline outcome
labels define these groups; they are not outcomes measured by this project.

Each instance directory contains only the original problem_statement in report.txt
and public source identifiers in source.json. No reference fixes, reference test
patches, hints, evaluator test lists, or evaluator results are included.
The existing Django pilot report was verified against the pinned source and retained.

Source and attribution: https://huggingface.co/datasets/princeton-nlp/SWE-bench_Verified
and https://www.swebench.com/ . These are benchmark issue descriptions from the
upstream projects, not new reports authored by TRACE. Refer to the upstream dataset
card and source repositories for their applicable terms.

This snapshot preserves reports, not runnable repository environments. Record the
matching Docker image digests separately when generation and evaluation are run.
