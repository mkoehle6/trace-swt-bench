# django__django-13513 preparation

Environment and immutable buggy image verified. Generation has not started. Both commands below use the existing unchanged workflows and the same image and shared unit-test profile. They make paid model calls and require provider credentials; improved mode also requires DEEPSEEK_API_KEY. Execute from the project root. Output directories must be new.

```bash
/home/mlkoe/.venvs/se433-swt/bin/python controller.py --report data/django__django-13513/report.txt --instance django__django-13513 --mode baseline --test-format unit_test --out runs/django-13513-unit-baseline-20261112-205739 --image sha256:677635982b65db91a2592d980a197d34dae09dd634d11f58bb35be956f3c4f2c --launch
/home/mlkoe/.venvs/se433-swt/bin/python controller.py --report data/django__django-13513/report.txt --instance django__django-13513 --mode improved --test-format unit_test --out runs/django-13513-unit-improved-20261112-205739 --image sha256:677635982b65db91a2592d980a197d34dae09dd634d11f58bb35be956f3c4f2c --launch
```

Keep evaluation outputs and reference fixes separate from generation inputs. Preserve all run artifacts and export unchanged submissions with export_prediction.py after generation. No GitHub push is part of this preparation.
