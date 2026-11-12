import importlib.util
import json
import os
from pathlib import Path
import tempfile
import unittest

script = Path(os.environ.get("APPEARANCE_SCRIPT", Path(__file__).parent.parent / "scripts/apply-appearance.py"))
spec = importlib.util.spec_from_file_location("appearance", script)
appearance = importlib.util.module_from_spec(spec)
spec.loader.exec_module(appearance)


class AppearanceTests(unittest.TestCase):
    def test_preserves_unmanaged_and_nested_settings(self):
        with tempfile.TemporaryDirectory() as directory:
            path = Path(directory) / "settings.json"
            path.write_text('// user preferences\n{"terminal": {"shell": "zsh",}, "vim_mode": true,}')
            appearance.update_json(path, {"terminal": {"font_family": "Mono"}})
            self.assertEqual(json.loads(path.read_text()), {
                "terminal": {"shell": "zsh", "font_family": "Mono"}, "vim_mode": True,
            })
            timestamp = path.stat().st_mtime_ns
            appearance.update_json(path, {"terminal": {"font_family": "Mono"}})
            self.assertEqual(path.stat().st_mtime_ns, timestamp)

    def test_invalid_settings_are_not_overwritten(self):
        with tempfile.TemporaryDirectory() as directory:
            path = Path(directory) / "settings.json"
            original = '{"unfinished":'
            path.write_text(original)
            with self.assertRaises(ValueError):
                appearance.update_json(path, {"font": "Mono"})
            self.assertEqual(path.read_text(), original)

    def test_symlink_target_is_not_modified(self):
        with tempfile.TemporaryDirectory() as directory:
            target = Path(directory) / "target.json"
            target.write_text('{}')
            path = Path(directory) / "settings.json"
            path.symlink_to(target)
            with self.assertRaises(ValueError):
                appearance.update_json(path, {"font": "Mono"})
            self.assertEqual(target.read_text(), '{}')


if __name__ == "__main__":
    unittest.main()
