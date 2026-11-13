# Post-evaluation verification

All 26 reports per method are present. Official aggregate resolved/unresolved sets agree with the per-instance reports and cover all 26 assigned IDs. Both original generation exports, frozen report hashes, workflow hashes, and tracked harness code remain unchanged.

The harness prints `completed_instances: 0` on initial grading because that counter increments only for reports that existed before the reporting pass. This is distinct from missing evaluations: 26 reports per method were verified, with zero official error instances. No harness code was changed.

Evaluation time was 3,425.92 seconds baseline and 1,549.86 seconds improved. Improved reused comparison caches; these times do not show a method speedup. Existing generation protocol flags and historical image limitations remain applicable.
