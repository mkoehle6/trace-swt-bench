"""Read official reports; retain every assignment and distinguish missing reports."""
import json,hashlib,datetime,statistics
from pathlib import Path
root=Path(__file__).resolve().parent
p=json.loads((root/'provenance.json').read_text())
assert (root/'execution-complete.json').exists(), 'Wait for both harness commands'
summary={'prepared_utc':datetime.datetime.now(datetime.timezone.utc).isoformat(),'assigned_instances':26,'methods':{},'instances':{i:{} for i in p['instance_ids']},'evaluation_only':True}
for mode in ('baseline','improved'):
 assert hashlib.sha256((root/mode/'prediction.jsonl').read_bytes()).hexdigest()==p['prediction_sha256'][mode]
 run_id=root.name+'-'+mode
 reports=root/'run_instance_swt_logs'/run_id/('trace-'+mode+'-unit-test')
 records={}
 for i in p['instance_ids']:
  path=reports/i/'report.json'
  if path.exists():
   value=json.loads(path.read_text())[i]
   record={k:value.get(k) for k in ('patch_exists','patch_successfully_applied','resolved','added_f2p','coverage_pred','coverage_delta_pred')}
   record.update(status='reported',report=str(path.relative_to(root)))
  else:record={'status':'missing_official_report','resolved':None,'patch_successfully_applied':None,'coverage_pred':None,'coverage_delta_pred':None}
  records[i]=record;summary['instances'][i][mode]=record
 vals=list(records.values());cov=[v['coverage_delta_pred'] for v in vals if isinstance(v.get('coverage_delta_pred'),(float,int))]
 successcov=[v['coverage_delta_pred'] for v in vals if v.get('resolved') is True and isinstance(v.get('coverage_delta_pred'),(float,int))]
 summary['methods'][mode]={'assigned':26,'reported':sum(v['status']=='reported' for v in vals),'missing_reports':sum(v['status']!='reported' for v in vals),'applicable':sum(v.get('patch_successfully_applied') is True for v in vals),'resolved':sum(v.get('resolved') is True for v in vals),'unresolved_reported':sum(v.get('resolved') is False for v in vals),'coverage_delta_pred_available':len(cov),'coverage_delta_pred_mean_available':statistics.mean(cov) if cov else None,'coverage_delta_pred_mean_resolved':statistics.mean(successcov) if successcov else None,'resolved_coverage_available':len(successcov),'timing':json.loads((root/mode/'timing.json').read_text())}
summary['disagreements']=[i for i,v in summary['instances'].items() if all(v[m]['status']=='reported' for m in ('baseline','improved')) and v['baseline']['resolved']!=v['improved']['resolved']]
with (root/'summary.json').open('x') as f:json.dump(summary,f,indent=2)
text='# Official TRACE evaluation: 26 assigned instances\n\nEvaluation-only evidence. Predictions were copied unchanged; generation workflows were not modified. Missing reports are infrastructure/reporting gaps, not confirmed unsuccessful reproductions. All rates retain the 26-instance assignment denominator.\n\n'
text+='| Method | Reports | Applicable | Resolved | Missing reports | Coverage delta mean (available count) | Time |\n| --- | ---: | ---: | ---: | ---: | --- | ---: |\n'
for mode,v in summary['methods'].items():
 cov='N/A' if v['coverage_delta_pred_mean_available'] is None else f"{v['coverage_delta_pred_mean_available']:.6f}"
 text+=f"| {mode} | {v['reported']}/26 | {v['applicable']}/26 | {v['resolved']}/26 | {v['missing_reports']} | {cov} ({v['coverage_delta_pred_available']}) | {v['timing']['seconds']:.2f}s |\n"
text+='\ncoverage_delta_pred is the harness fraction of executable reference-fix changed lines whose execution counts increase relative to base. It is not whole-repository coverage, and unavailable values are not zero. Coverage above averages available reports, independently of reproduction success. Full fields and success-conditioned coverage are in summary.json. Improved runs after baseline and can reuse comparison caches; timing differences are not experimental speedups.\n\n'
text+='| Instance | Baseline | Improved | Coverage delta B / I |\n| --- | --- | --- | --- |\n'
for i,v in summary['instances'].items():
 def label(x):return 'Missing report' if x['status']!='reported' else ('Resolved' if x['resolved'] else ('Unresolved' if x['patch_successfully_applied'] else 'Patch not applicable'))
 def cov(x):return 'N/A' if x['coverage_delta_pred'] is None else f"{x['coverage_delta_pred']:.6f}"
 text+=f"| {i} | {label(v['baseline'])} | {label(v['improved'])} | {cov(v['baseline'])} / {cov(v['improved'])} |\n"
text+='\nMethod disagreements: '+(', '.join(summary['disagreements']) or 'none among cases with both official reports')+'.\n\n[Machine-readable summary](summary.json) · [Input provenance and checksums](provenance.json) · [Workflow/prediction post-checks](execution-complete.json)\n\nGeneration-stage history-inspection flags and diagnostic deviations remain applicable; evaluation scores do not certify protocol compliance. No evaluation result was fed back to a generator or used to repair a prediction.\n'
with (root/'RESULTS.md').open('x') as f:f.write(text)
with (root/'artifact-checksums.json').open('x') as f:json.dump({str(q.relative_to(root)):hashlib.sha256(q.read_bytes()).hexdigest() for q in root.rglob('*') if q.is_file() and q.name!='artifact-checksums.json' and 'locks' not in q.parts},f,indent=2)
print(json.dumps({'results':str(root/'RESULTS.md'),'methods':summary['methods'],'disagreements':summary['disagreements']}))
