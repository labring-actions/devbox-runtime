import unittest
from pathlib import Path


REPO_ROOT = Path(__file__).resolve().parents[2]
RUNTIME_ROOT = REPO_ROOT / "runtime-images/languages/java/openjdk25"


class JavaOpenJDK25RuntimeTests(unittest.TestCase):
    def test_conformance_runner_registers_runtime(self):
        runner = REPO_ROOT / "tests/runtime-conformance/run.sh"
        content = runner.read_text(encoding="utf-8")

        self.assertIn("languages/java/openjdk25)", content)
        self.assertIn("check_java_openjdk25_runtime", content)

    def test_required_runtime_files_exist(self):
        required_files = [
            RUNTIME_ROOT / "Dockerfile",
            RUNTIME_ROOT / "build.sh",
            RUNTIME_ROOT / "project-template/HelloWorld.java",
            RUNTIME_ROOT / "project-template/entrypoint.sh",
            RUNTIME_ROOT / "project-template/README.en_US.md",
            RUNTIME_ROOT / "project-template/README.zh_CN.md",
            REPO_ROOT / "base-images/languages/java/openjdk25/Dockerfile",
            REPO_ROOT / "base-images/languages/java/openjdk25/build.sh",
            REPO_ROOT / "tests/runtime-smoke/languages/java/openjdk25/smoke.sh",
        ]

        for path in required_files:
            with self.subTest(path=path):
                self.assertTrue(path.is_file(), f"missing file: {path}")


if __name__ == "__main__":
    unittest.main()
