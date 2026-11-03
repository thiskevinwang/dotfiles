"""Offline installer checks. No packages, downloads, or real home changes."""

from pathlib import Path
import shutil
import subprocess
import tempfile
import unittest


ROOT = Path(__file__).resolve().parents[1]


class LinuxSetupTest(unittest.TestCase):
    def setUp(self):
        self.temporary = tempfile.TemporaryDirectory(prefix="dotfiles test ")
        self.addCleanup(self.temporary.cleanup)
        self.base = Path(self.temporary.name)
        self.home = self.base / "home"
        self.home.mkdir()
        self.bin = self.base / "bin"
        self.bin.mkdir()
        self.env = {
            "HOME": str(self.home),
            "PATH": f"{self.bin}:/usr/bin:/bin",
            "LC_ALL": "C",
        }
        # Exercise Linux branches on any host, without claiming a Linux install.
        self.stub("uname", 'case "$1" in -s) echo Linux;; -m) echo x86_64;; esac')

    def stub(self, name, body="exit 99"):
        path = self.bin / name
        path.write_text(f"#!/bin/sh\n{body}\n")
        path.chmod(0o755)

    def setup(self, *arguments, script="install-linux.sh"):
        return subprocess.run(
            ["/bin/bash", str(ROOT / script), *arguments],
            env=self.env,
            text=True,
            capture_output=True,
            timeout=20,
        )

    def require_success(self, result):
        self.assertEqual(result.returncode, 0, result.stdout + result.stderr)

    def test_configs_backups_and_repeat_run(self):
        (self.home / ".zshrc").write_text("existing shell\n")
        zed = self.home / ".config/zed"
        zed.mkdir(parents=True)
        (zed / "other.json").write_text("keep\n")
        (self.home / ".gitconfig.local").write_text("[user]\nname = Local User\n")
        # A dangling link and an existing directory must also be preserved.
        (self.home / ".vimrc").symlink_to(self.home / "missing")
        (self.home / ".tmux.conf").mkdir()
        (self.home / ".tmux.conf/keep").write_text("keep\n")
        self.require_success(self.setup("--config-only"))
        self.assertEqual((self.home / ".zshrc").resolve(), ROOT / "zshrc.linux")
        self.assertEqual((zed / "other.json").read_text(), "keep\n")
        self.assertIn("Local User", (self.home / ".gitconfig.local").read_text())
        backups = self.home / ".local/state/dotfiles/backups"
        saved = list(backups.iterdir())
        self.assertEqual(len(saved), 1)
        original = saved[0] / str(self.home).lstrip("/")
        self.assertEqual((original / ".zshrc").read_text(), "existing shell\n")
        self.assertTrue((original / ".vimrc").is_symlink())
        self.assertEqual((original / ".tmux.conf/keep").read_text(), "keep\n")
        rules = (self.home / ".codex/AGENTS.md").read_text()
        self.assertIn(f"@{self.home}/.codex/RTK.md", rules)
        self.assertNotIn("/Users/kevin", rules)
        self.require_success(self.setup("--config-only"))
        self.assertEqual(list(backups.iterdir()), saved)

    def test_dry_run_has_no_side_effects(self):
        # If any mutating command escapes the dry-run wrapper, it must fail.
        for command in ("curl", "git", "sudo", "npm", "chsh", "apt-get"):
            self.stub(command)
        self.require_success(self.setup("--dry-run", "--change-shell"))
        self.assertEqual(list(self.home.iterdir()), [])

    def test_failed_package_install_stops_before_config_changes(self):
        self.stub("apt-get", "exit 42")
        self.stub("sudo", 'exec "$@"')
        result = self.setup()
        self.assertEqual(result.returncode, 42, result.stdout + result.stderr)
        self.assertEqual(list(self.home.iterdir()), [])

    def test_failed_download_does_not_execute_partial_script(self):
        self.stub("curl", '''while [ "$#" -gt 0 ]; do
  if [ "$1" = -o ]; then
    shift
    printf 'touch "$HOME/partial-script-executed"\\n' > "$1"
    exit 22
  fi
  shift
done
exit 22''')
        result = self.setup("--skip-packages", "--skip-plugins")
        self.assertEqual(result.returncode, 22, result.stdout + result.stderr)
        self.assertEqual(list(self.home.iterdir()), [])

    def test_xdg_and_zdotdir(self):
        self.env.update({
            "XDG_CONFIG_HOME": str(self.base / "config"),
            "XDG_DATA_HOME": str(self.base / "data"),
            "XDG_STATE_HOME": str(self.base / "state"),
            "ZDOTDIR": str(self.base / "zsh"),
        })
        self.require_success(self.setup("--config-only"))
        self.assertTrue((self.base / "config/nushell/config.nu").is_symlink())
        self.assertTrue((self.base / "config/nvim/init.vim").is_file())
        self.assertTrue((self.base / "zsh/.zshrc").is_symlink())

    def test_main_installer_dispatches_to_linux(self):
        self.require_success(self.setup("--config-only", script="install.sh"))
        self.assertTrue((self.home / ".tmux.conf").is_symlink())

    def test_invalid_option_and_non_linux_do_not_write(self):
        self.assertEqual(self.setup("--invalid").returncode, 2)
        self.stub("uname", "echo Darwin")
        self.assertEqual(self.setup("--config-only").returncode, 1)
        self.assertEqual(list(self.home.iterdir()), [])

    @unittest.skipUnless(shutil.which("zsh"), "Zsh unavailable")
    def test_shell_starts_without_optional_tools(self):
        self.require_success(self.setup("--config-only"))
        result = subprocess.run(
            [shutil.which("zsh"), "-d", "-i", "-c", "print -r -- shell-ready"],
            env=self.env, text=True, capture_output=True, timeout=20,
        )
        self.require_success(result)
        self.assertIn("shell-ready", result.stdout)
        self.assertEqual(result.stderr, "")


if __name__ == "__main__":
    unittest.main()
