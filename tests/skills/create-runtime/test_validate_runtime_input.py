import json
import subprocess
import sys
import tempfile
import unittest
from pathlib import Path


REPO_ROOT = Path(__file__).resolve().parents[3]
VALIDATOR = REPO_ROOT / ".agents/skills/create-runtime/scripts/validate-runtime-input.py"


class ValidateRuntimeInputTests(unittest.TestCase):
    def run_validator(self, repo_root: Path, runtime_type: str, name: str, version: str):
        return subprocess.run(
            [
                sys.executable,
                str(VALIDATOR),
                "--repo-root",
                str(repo_root),
                "--type",
                runtime_type,
                "--name",
                name,
                "--version",
                version,
            ],
            capture_output=True,
            text=True,
            check=False,
        )

    def test_normalizes_language_and_returns_runtime_paths(self):
        with tempfile.TemporaryDirectory() as temporary_directory:
            result = self.run_validator(
                Path(temporary_directory), "language", "python", "3.13"
            )

        self.assertEqual(result.returncode, 0, result.stderr)
        payload = json.loads(result.stdout)
        self.assertEqual(payload["kind"], "languages")
        self.assertEqual(
            payload["runtime_path"], "runtime-images/languages/python/3.13"
        )
        self.assertEqual(
            payload["smoke_test_path"],
            "tests/runtime-smoke/languages/python/3.13/smoke.sh",
        )

    def test_rejects_path_traversal_components(self):
        with tempfile.TemporaryDirectory() as temporary_directory:
            result = self.run_validator(
                Path(temporary_directory), "language", "../python", "3.13"
            )

        self.assertNotEqual(result.returncode, 0)
        self.assertIn("path component", result.stderr)

    def test_rejects_unknown_type(self):
        with tempfile.TemporaryDirectory() as temporary_directory:
            result = self.run_validator(
                Path(temporary_directory), "database", "postgres", "16"
            )

        self.assertNotEqual(result.returncode, 0)
        self.assertIn("type", result.stderr)

    def test_rejects_existing_smoke_test_target(self):
        with tempfile.TemporaryDirectory() as temporary_directory:
            repo_root = Path(temporary_directory)
            smoke_test = (
                repo_root
                / "tests"
                / "runtime-smoke"
                / "languages"
                / "python"
                / "3.13"
                / "smoke.sh"
            )
            smoke_test.parent.mkdir(parents=True)
            smoke_test.write_text("#!/bin/bash\n", encoding="utf-8")

            result = self.run_validator(repo_root, "language", "python", "3.13")

        self.assertNotEqual(result.returncode, 0)
        self.assertIn("smoke test target already exists", result.stderr)

    def test_rejects_existing_runtime_target(self):
        with tempfile.TemporaryDirectory() as temporary_directory:
            repo_root = Path(temporary_directory)
            target = repo_root / "runtime-images" / "frameworks" / "nest.js" / "v12"
            target.mkdir(parents=True)
            (target / "Dockerfile").write_text("FROM scratch\n", encoding="utf-8")

            result = self.run_validator(repo_root, "framework", "nest.js", "v12")

        self.assertNotEqual(result.returncode, 0)
        self.assertIn("already exists", result.stderr)


if __name__ == "__main__":
    unittest.main()
