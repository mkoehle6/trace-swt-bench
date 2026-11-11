import json
from pathlib import Path
import tempfile
import unittest
from unittest.mock import patch, Mock
import types
import controller as c


class ValidationTests(unittest.TestCase):
    def setUp(self):
        self.report = 'Function f returns 1 but should return 2.'
        self.spec = {k: {'value': None, 'evidence': None} for k in c.FIELDS}
        self.spec['expected_behavior'] = {'value': 'returns 2', 'evidence': 'should return 2'}

    def test_grounding_and_shapes(self):
        self.assertEqual(c.validate(self.spec, self.report), [])
        self.spec['expected_behavior']['evidence'] = 'fabricated'
        self.assertTrue(c.validate(self.spec, self.report))
        self.assertTrue(c.validate([], self.report))
        self.spec['expected_behavior'] = {'value': None, 'evidence': 'quote'}
        self.assertTrue(c.validate(self.spec, self.report))

    def test_semantic_rejection_and_types(self):
        review = dict(valid=True, unsupported_fields=[], contradictions=[], missing_information=[])
        self.assertEqual(c.semantic_errors(review), [])
        review['contradictions'] = ['wrong behavior']
        self.assertTrue(c.semantic_errors(review))
        review['valid'] = 'true'
        self.assertTrue(c.semantic_errors(review))

    def test_revision_then_accept(self):
        review = dict(valid=True, unsupported_fields=[], contradictions=[], missing_information=[])
        with tempfile.TemporaryDirectory() as directory, patch.object(c, 'ask', side_effect=[{}, self.spec, review]):
            spec, count = c.extract(self.report, 'mock', Path(directory))
            self.assertEqual(count, 2)
            self.assertEqual(spec, self.spec)

    def test_bounded_failure(self):
        with tempfile.TemporaryDirectory() as directory, patch.object(c, 'ask', return_value={}):
            spec, count = c.extract(self.report, 'mock', Path(directory))
            self.assertIsNone(spec)
            self.assertEqual(count, 3)
            self.assertFalse((Path(directory) / 'bug_spec.json').exists())

    def test_baseline_prepare_and_no_clobber(self):
        with tempfile.TemporaryDirectory() as directory:
            root = Path(directory)
            report = root / 'report.txt'
            report.write_text(self.report)
            config = Path(__file__).resolve().parent / 'baseline/swt_test.yaml'
            args = ['--report', str(report), '--config', str(config), '--out', str(root / 'run'), '--mode', 'baseline']
            c.main(args)
            self.assertEqual((root / 'run/task.txt').read_text(), self.report)
            manifest = json.loads((root / 'run/manifest.json').read_text())
            self.assertTrue(manifest['baseline_unchanged'])
            with self.assertRaises(FileExistsError):
                c.main(args)

    def test_launcher_preserves_config_and_collects_submission(self):
        config = Path(__file__).resolve().parent / 'baseline/swt_test.yaml'
        original = config.read_bytes()
        env, agent = Mock(), Mock()
        agent.run.return_value = {'exit_status': 'Submitted', 'submission': 'test patch'}
        agent.serialize.return_value = {'messages': []}
        environment_factory = Mock(return_value=env)
        agent_factory = Mock(return_value=agent)
        modules = {
            'minisweagent.agents': types.SimpleNamespace(get_agent=agent_factory),
            'minisweagent.environments': types.SimpleNamespace(get_environment=environment_factory),
            'minisweagent.models': types.SimpleNamespace(get_model=Mock(return_value=Mock()))}
        with tempfile.TemporaryDirectory() as directory, patch.dict('sys.modules', modules), patch.object(c.importlib.metadata, 'version', return_value='2.4.6'):
            c.launch(config, 'image@sha256:example', self.report, Path(directory))
            effective = json.loads((Path(directory) / 'effective_config.json').read_text())
            import yaml
            expected = yaml.safe_load(original)
            expected['environment']['image'] = 'image@sha256:example'
            self.assertEqual(effective, expected)
            self.assertEqual((Path(directory) / 'submission.patch').read_text(), 'test patch')
            self.assertEqual(agent_factory.call_args.kwargs, {'default_type': 'default'})
            env.cleanup.assert_called_once()
        self.assertEqual(config.read_bytes(), original)


if __name__ == '__main__':
    unittest.main()
