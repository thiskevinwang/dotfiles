"""Check the packaged editor and tmux config without home-file adoption."""

import argparse
import json
import os
from pathlib import Path
import platform
import shutil
import subprocess
import tempfile


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--host", default="kevin-mac" if platform.machine() == "arm64" else "kevin-intel")
    args = parser.parse_args()
    repo = Path(__file__).resolve().parents[1]
    nix = shutil.which("nix") or "/nix/var/nix/profiles/default/bin/nix"
    base = [nix, "--extra-experimental-features", "nix-command flakes", "eval",
            "--no-update-lock-file"]
    manifest = json.loads(subprocess.check_output(base + ["--json", str(repo) + "#lib.bootstrap." + args.host], text=True))
    profile = Path(subprocess.check_output(base + ["--raw", str(repo) + "#darwinConfigurations." + args.host +
        ".config.home-manager.users." + manifest["username"] + ".home.path"], text=True).strip())
    files = {entry["target"]: Path(entry["source"]) for entry in manifest["files"]}
    required = [files[".vimrc"], files[".tmux.conf"]] + [
        source for target, source in files.items() if "/pack/dotfiles/start/" in target]
    if not (profile / "bin/nvim").exists() or any(not source.exists() for source in required):
        raise RuntimeError("Run bootstrap.sh --build-only first")

    with tempfile.TemporaryDirectory(prefix="dotfiles-runtime-") as temporary:
        temporary = Path(temporary)
        environment = dict(os.environ)
        for name in ["CONFIG", "DATA", "STATE", "CACHE"]:
            path = temporary / name.lower()
            path.mkdir()
            environment["XDG_" + name + "_HOME"] = str(path)
        environment["PATH"] = str(profile / "bin") + os.pathsep + environment["PATH"]
        environment.pop("TMUX", None)

        packages = temporary / "runtime/pack/dotfiles/start"
        packages.mkdir(parents=True)
        for target, source in files.items():
            if "/pack/dotfiles/start/" in target:
                (packages / Path(target).name).symlink_to(source)
        check = (
            "lua local ok, err = pcall(function() "
            "for _, name in ipairs({'telescope', 'nvim-tree', 'plenary', 'toggleterm'}) do "
            "assert(require(name)) end; "
            "assert(vim.fn.maparg(' ff', 'n'):find('Telescope find_files', 1, true)); "
            "local tree = require('nvim-tree.api').tree; tree.open(); "
            "assert(tree.is_visible()); tree.close() end); "
            "if not ok then print(err); vim.cmd('cquit 1') end"
        )
        subprocess.run([str(profile / "bin/nvim"), "--headless", "-i", "NONE",
            "--cmd", "set packpath=" + str(temporary / "runtime"),
            "-u", str(files[".vimrc"]), "-c", check, "-c", "qa!"],
            env=environment, cwd=temporary, check=True, timeout=45)

        # Check bindings, title, and theme-hook syntax without starting plugins.
        config = temporary / "tmux.conf"
        config.write_text("set -s exit-empty off\n" + "\n".join(
            line for line in files[".tmux.conf"].read_text().splitlines()
            if not line.startswith("run ")) + "\n")
        tmux = [str(profile / "bin/tmux"), "-S", str(temporary / "tmux.sock")]
        try:
            subprocess.run(tmux + ["-f", str(config), "start-server"],
                           env=environment, check=True, timeout=15)
            for option, expected in [("prefix", "C-Space"), ("set-titles-string", "#T")]:
                actual = subprocess.check_output(tmux + ["show-options", "-gv", option],
                    env=environment, text=True, timeout=15).strip()
                if actual != expected:
                    raise AssertionError(option + ": " + actual)
        finally:
            subprocess.run(tmux + ["kill-server"], env=environment, check=False,
                           stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL, timeout=15)
    print("Packaged Neovim startup and tmux configuration passed")


if __name__ == "__main__":
    main()
