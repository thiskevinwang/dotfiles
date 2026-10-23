import importlib.util
import json
import os
from pathlib import Path
import subprocess
import tempfile
import unittest
from unittest.mock import patch


spec = importlib.util.spec_from_file_location(
    "bootstrap", Path(__file__).resolve().parents[1] / "scripts/bootstrap.py")
bootstrap = importlib.util.module_from_spec(spec)
spec.loader.exec_module(bootstrap)


class AdoptionTests(unittest.TestCase):
    def setUp(self):
        self.temporary = tempfile.TemporaryDirectory()
        self.addCleanup(self.temporary.cleanup)
        self.root = Path(self.temporary.name)
        self.home = self.root / "home"
        self.repo = self.home / "repos/dotfiles"
        self.repo.mkdir(parents=True)
        self.source = self.repo / "gitconfig"
        self.source.write_text("new config\n")
        self.bridge = self.home / ".local/share/dotfiles/repo"
        self.manifest = {
            "homeDirectory": str(self.home), "repoLink": str(self.bridge),
            "files": [{"target": ".gitconfig", "source": str(self.source)}],
        }

    def adopt(self):
        return bootstrap.adopt(self.manifest, self.home, self.repo)

    def test_regular_file_backup_and_restore(self):
        target = self.home / ".gitconfig"
        target.write_text("local config\n")
        directory = self.adopt()
        self.assertFalse(target.exists())
        self.assertEqual((directory / "files/.gitconfig").read_text(), "local config\n")
        target.symlink_to(self.source)
        bootstrap.restore(directory, self.home)
        self.assertEqual(target.read_text(), "local config\n")
        self.assertFalse(target.is_symlink())
        self.assertFalse(self.bridge.exists())

    def test_checkout_link_is_backed_up_without_changing_its_source(self):
        old = self.repo / "old-config"
        old.write_text("old\n")
        target = self.home / ".gitconfig"
        target.symlink_to(old)
        directory = self.adopt()
        self.assertTrue((directory / "files/.gitconfig").is_symlink())
        self.assertEqual(old.read_text(), "old\n")
        bootstrap.restore(directory, self.home)
        self.assertEqual(os.readlink(target), str(old))

    def test_repeat_run_keeps_matching_links_and_creates_no_backup(self):
        target = self.home / ".gitconfig"
        target.symlink_to(self.source)
        self.bridge.parent.mkdir(parents=True)
        self.bridge.symlink_to(self.repo)
        self.assertIsNone(self.adopt())
        self.assertFalse((self.home / ".local/state/dotfiles/backups").exists())

    def test_checks_all_targets_before_any_move(self):
        target = self.home / ".gitconfig"
        target.write_text("keep\n")
        unrelated = self.root / "unrelated"
        unrelated.write_text("other manager\n")
        (self.home / ".vimrc").symlink_to(unrelated)
        self.manifest["files"].append({"target": ".vimrc", "source": str(self.source)})
        with self.assertRaisesRegex(ValueError, "outside this checkout"):
            self.adopt()
        self.assertEqual(target.read_text(), "keep\n")
        self.assertFalse((self.home / ".local/state").exists())

    def test_symlink_parent_cannot_redirect_a_write(self):
        outside = self.root / "outside"
        outside.mkdir()
        (self.home / ".config").symlink_to(outside)
        self.manifest["files"][0]["target"] = ".config/git/config"
        with self.assertRaisesRegex(ValueError, "symlink parent"):
            self.adopt()
        self.assertEqual(list(outside.iterdir()), [])

    def test_parent_traversal_and_home_root_are_rejected(self):
        for name in ["../outside", str(self.root / "outside"), str(self.home), "."]:
            with self.subTest(name=name):
                self.manifest["files"][0]["target"] = name
                with self.assertRaises(ValueError):
                    self.adopt()

    def test_overlapping_targets_are_rejected(self):
        self.manifest["files"] = [
            {"target": ".config", "source": str(self.repo)},
            {"target": ".config/file", "source": str(self.source)},
        ]
        with self.assertRaisesRegex(ValueError, "Overlapping"):
            self.adopt()

    def test_move_failure_restores_previous_moves(self):
        first = self.home / ".gitconfig"
        first.write_text("first\n")
        second = self.home / ".vimrc"
        second.write_text("second\n")
        self.manifest["files"].append({"target": ".vimrc", "source": str(self.source)})
        replace = os.replace

        def fail_second(source, target):
            if Path(source) == second:
                raise OSError("test move failure")
            return replace(source, target)

        with patch.object(bootstrap.os, "replace", side_effect=fail_second):
            with self.assertRaisesRegex(OSError, "test move failure"):
                self.adopt()
        self.assertEqual(first.read_text(), "first\n")
        self.assertEqual(second.read_text(), "second\n")

    def test_restore_keeps_an_unexpected_new_file(self):
        target = self.home / ".gitconfig"
        target.write_text("original\n")
        directory = self.adopt()
        target.write_text("new user change\n")
        with self.assertRaisesRegex(ValueError, "block backup restoration"):
            bootstrap.restore(directory, self.home)
        self.assertEqual(target.read_text(), "new user change\n")
        self.assertEqual((directory / "files/.gitconfig").read_text(), "original\n")

    def test_unexpected_directory_is_not_moved(self):
        target = self.home / ".gitconfig"
        target.mkdir()
        (target / "important").write_text("keep")
        with self.assertRaisesRegex(ValueError, "Unexpected directory"):
            self.adopt()
        self.assertEqual((target / "important").read_text(), "keep")

    def test_existing_gpg_settings_and_installed_extensions_are_kept(self):
        gnupg = self.home / ".gnupg"
        gnupg.mkdir()
        agent = gnupg / "gpg-agent.conf"
        agent.write_text("existing machine settings\n")
        vscode = self.repo / ".vscode"
        vscode.mkdir()
        (vscode / "extensions.txt").write_text("golang.go\nGitHub.copilot\n")
        with patch.object(bootstrap, "executable", return_value="/tool/bin/code"), \
             patch.object(bootstrap, "run", return_value="golang.go\ngithub.copilot\n") as run:
            bootstrap.finish_setup(self.repo, self.home)
        self.assertEqual(agent.read_text(), "existing machine settings\n")
        run.assert_called_once_with(["/tool/bin/code", "--list-extensions"], capture=True)

    def test_only_missing_extensions_are_installed(self):
        vscode = self.repo / ".vscode"
        vscode.mkdir()
        (vscode / "extensions.txt").write_text("golang.go\ngithub.copilot\n")
        with patch.object(bootstrap, "executable", return_value="/tool/bin/code"), \
             patch.object(bootstrap, "run", return_value="golang.go\n") as run:
            bootstrap.finish_setup(self.repo, self.home)
        self.assertEqual(run.call_count, 2)
        self.assertEqual(run.call_args.args[0], ["/tool/bin/code", "--install-extension", "github.copilot"])


class BootstrapTests(unittest.TestCase):
    def setUp(self):
        self.temporary = tempfile.TemporaryDirectory()
        self.addCleanup(self.temporary.cleanup)
        self.system = Path(self.temporary.name) / "system"
        (self.system / "sw/bin").mkdir(parents=True)
        (self.system / "sw/bin/darwin-rebuild").write_text("built")
        for name, value in [("system", "Darwin"), ("machine", "arm64")]:
            context = patch.object(bootstrap.platform, name, return_value=value)
            context.start()
            self.addCleanup(context.stop)
        for context in [patch.object(bootstrap.os, "geteuid", return_value=501),
                        patch.object(bootstrap.getpass, "getuser", return_value="kevin"),
                        patch.object(bootstrap.Path, "home", return_value=Path("/Users/kevin"))]:
            context.start()
            self.addCleanup(context.stop)

    def command(self, argv, capture=False):
        if "build" in argv:
            return str(self.system) + "\n"
        if "eval" in argv:
            return json.dumps({"username": "kevin"})
        if "switch" in argv:
            raise subprocess.CalledProcessError(1, argv)
        return "/Library/Developer/CommandLineTools\n"

    def test_build_only_never_adopts_or_activates(self):
        with patch.object(bootstrap, "prerequisites", return_value="/nix/bin/nix") as prerequisites, \
             patch.object(bootstrap, "run", side_effect=self.command) as run, \
             patch.object(bootstrap, "adopt") as adopt, \
             patch.object(bootstrap, "finish_setup") as finish:
            bootstrap.main(["--build-only"])
        prerequisites.assert_called_once_with(True)
        adopt.assert_not_called()
        finish.assert_not_called()
        commands = [call.args[0] for call in run.call_args_list]
        self.assertFalse(any("sudo" in command or "eval" in command for command in commands))
        build = next(command for command in commands if "build" in command)
        self.assertIn("--no-update-lock-file", build)

    def test_activation_failure_restores_backups_and_stops(self):
        directory = Path(self.temporary.name) / "backup"
        with patch.object(bootstrap, "prerequisites", return_value="/nix/bin/nix"), \
             patch.object(bootstrap, "run", side_effect=self.command), \
             patch.object(bootstrap, "adopt", return_value=directory), \
             patch.object(bootstrap, "restore") as restore, \
             patch.object(bootstrap, "finish_setup") as finish:
            with self.assertRaises(subprocess.CalledProcessError):
                bootstrap.main([])
        restore.assert_called_once_with(directory, Path("/Users/kevin"))
        finish.assert_not_called()

    def test_wrong_architecture_stops_before_prerequisites(self):
        with patch.object(bootstrap, "prerequisites") as prerequisites:
            with self.assertRaisesRegex(ValueError, "architecture"):
                bootstrap.main(["--host", "kevin-intel"])
        prerequisites.assert_not_called()

    def test_build_only_cannot_be_combined_with_restore(self):
        with patch.object(bootstrap, "restore") as restore:
            with self.assertRaises(SystemExit) as error:
                bootstrap.main(["--build-only", "--restore", "/unused"])
        self.assertEqual(error.exception.code, 2)
        restore.assert_not_called()

    def test_administrator_denial_cannot_move_home_files(self):
        def deny(command, capture=False):
            if command == ["sudo", "-v"]:
                raise subprocess.CalledProcessError(1, command)
            return self.command(command, capture)

        with patch.object(bootstrap, "prerequisites", return_value="/nix/bin/nix"), \
             patch.object(bootstrap, "run", side_effect=deny), \
             patch.object(bootstrap, "adopt") as adopt:
            with self.assertRaises(subprocess.CalledProcessError):
                bootstrap.main([])
        adopt.assert_not_called()

    def test_existing_nix_is_not_reinstalled_for_build_only(self):
        with patch.object(bootstrap, "executable", return_value="/nix/bin/nix"), \
             patch.object(bootstrap, "install_script") as install, \
             patch.dict(bootstrap.os.environ, {"PATH": "/usr/bin:/bin"}):
            self.assertEqual(bootstrap.prerequisites(True), "/nix/bin/nix")
        install.assert_not_called()

    def test_download_failure_cannot_execute_installer(self):
        with patch.object(bootstrap, "run", side_effect=subprocess.CalledProcessError(22, "curl")) as run:
            with self.assertRaises(subprocess.CalledProcessError):
                bootstrap.install_script("https://example.invalid/install", ["/bin/sh"])
        self.assertEqual(run.call_count, 1)


if __name__ == "__main__":
    unittest.main()
