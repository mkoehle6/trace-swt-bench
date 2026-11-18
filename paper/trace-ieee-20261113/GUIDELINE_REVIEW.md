# Guideline review and draft completion status

Reviewed the [project guidelines](https://github.com/DePaul-SE-Team/SE443-333-final-project-guideline), especially Sections 6 and 8, on November 13, 2026. The cited guideline calls the baseline DeepFlash; the user confirmed this means DeepSeek.

| Requirement | Where addressed | Status |
| --- | --- | --- |
| Section 6: official success and applicability over all assignments | Results, Table I | Complete: 16/26 vs 17/26 successes; 26/26 applicability |
| Coverage field, units, aggregation, available count, success-only distinction | Results: Coverage, Cost, and Runtime | Complete: `coverage_delta_pred`; 25 available per arm; separate successful subsets |
| Missing coverage explanation | Results | Sphinx 8721 has no executable changed-line denominator in harness coverage inputs; N/A |
| Paired counts and uncertainty | Table II and Results | 15 shared successes, 1 baseline-only, 2 TRACE-only, 8 neither; single-run limitation |
| Generation time and evaluation time | Table I and Results | Complete for selected runs; cache/order limits disclosed |
| Complete generation cost | Results and outstanding-information appendix | Provider-period billing reconciled to $0.959975793; selected-run agent costs and analysis usage reported separately. Per-method complete costs remain unavailable. |
| Infrastructure failures and denominator | Experimental Design and Results | Original failures preserved; no unresolved evaluation infrastructure cases |
| Section 8: six distinct cases | Appendix A, with synthesis in Test Quality Analysis | Two shared successes, two shared failures, two disagreements |
| Systematic selection | Main Test Quality Analysis and evidence.json | Lexicographic full IDs within categories; no duplication or shortfall |
| Issue, test, before, after, meaning, implication | Each Appendix A case | Complete; raw/parser discrepancies explicitly distinguished |
| Threats and future improvement | Main Sections V and VI | Complete; includes protocol deviations and sampling limitations |
| Section 11: IEEE template and main-text length | PDF and source | IEEEtran conference; approximately 2,975 main prose words under the documented current counting rule; final course word-limit compliance requires team review |
| Contributions and Section 12 AI disclosure | Last appendix | Team effort recorded; all AI tools confirmed disclosed by the team; exact historical versions remain limited where unrecorded |

The original configuration was preserved but adapted to native unit-test output in both arms. The draft explicitly discloses this deviation from a strict “unchanged baseline” reading; it does not claim instructor approval that has not been established. No experiments or assertions were changed to make results fit the guidelines.

The draft follows the required six-section report structure. Detailed case analysis is in an appendix, with the principal findings retained in the main paper. Author names, DePaul affiliation, and emails are included. Appendix C records SE 433: Software Testing and Quality Assurance, current host specifications, and the limits of historical resource records.

Updated November 16, 2026 against the revised manuscript. Original guideline review date remains November 13; the online guidelines were not re-reviewed during this refresh. Remaining submission-date and artifact-link TODOs are listed in draft-validation.json.

November 17 check: the linked guideline repository really is named `SE443-333-final-project-guideline`; the manuscript retains that URL and distinguishes it from the user-confirmed SE 433 course. Guideline reference [4] is cited before artifact reference [5]. Appendix B rows retain assignment order and use Success/Unsuccessful.
