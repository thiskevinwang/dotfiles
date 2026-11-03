#!/usr/bin/env python3
"""Build and apply the locked Mac configuration; retain file backups."""

import argparse
import datetime
import getpass
import json
import os
from pathlib import Path
import platform
import shlex
import shutil
import subprocess
import sys
import tempfile
import uuid


REPO = Path(__file__).resolve().parents[1]
NIX_FLAGS = ["--extra-experimental-features", "nix-command flakes"]


def run(command, capture=False):
    command = [str(part) for part in command]
    print("+ " + shlex.join(command), file=sys.stderr)
    return subprocess.run(command, check=True, text=True,
                          stdout=subprocess.PIPE if capture else None).stdout


def executable(name, candidates=()):
    return shutil.which(name) or next(
        (str(path) for path in candidates if os.access(path, os.X_OK)), None)


def target_path(home, target):
    path = Path(target)
    if ".." in path.parts:
        raise ValueError("Parent traversal in file manifest: " + target)
    if not path.is_absolute():
        path = home / path
    try:
        relative = path.relative_to(home)
    except ValueError:
        raise ValueError("Target is outside the home directory: " + str(path))
    if not relative.parts:
        raise ValueError("The home directory cannot be a file target")
    return path


def check_parents(home, path):
    """Do not follow a config-directory link into another tree."""
    for parent in path.parents:
        if parent == home:
            return
        if parent.is_symlink():
            raise ValueError("Refusing a symlink parent: " + str(parent))
        if parent.exists() and not parent.is_dir():
            raise ValueError("Parent is not a directory: " + str(parent))
    raise ValueError("Target is outside the home directory: " + str(path))


def managed_link(path):
    if not path.is_symlink():
        return False
    link = os.readlink(path)
    return link.startswith("/nix/store/") and "-home-manager-files/" in link


def same_link(path, source):
    return path.is_symlink() and path.resolve() == Path(source).resolve()


def write_journal(directory, journal):
    temporary = directory / "manifest.tmp"
    temporary.write_text(json.dumps(journal, indent=2) + "\n")
    os.replace(temporary, directory / "manifest.json")


def restore(directory, home):
    directory = Path(directory)
    backup_root = home / ".local/state/dotfiles/backups"
    if not directory.resolve().is_relative_to(backup_root.resolve()):
        raise ValueError("Backup is outside the dotfiles backup directory")
    journal = json.loads((directory / "manifest.json").read_text())
    if journal["home"] != str(home):
        raise ValueError("Backup belongs to another home directory")
    errors = []
    for entry in reversed(journal["files"]):
        target = target_path(home, entry["target"])
        check_parents(home, target)
        backup = directory / "files" / target.relative_to(home)
        original_present = os.path.lexists(backup)
        if not entry["started"]:
            continue
        if os.path.lexists(target):
            if managed_link(target) or same_link(target, entry["source"]):
                target.unlink()
            elif original_present:
                errors.append(str(target))
                continue
            else:
                continue
        if original_present:
            target.parent.mkdir(parents=True, exist_ok=True)
            os.replace(backup, target)
    if errors:
        raise ValueError("New files block backup restoration: " + ", ".join(errors))
    print("File backups restored from " + str(directory), file=sys.stderr)


def plan_adoption(manifest, home, repo):
    """Check every target before any file can move."""
    repo = repo.resolve()
    if Path(manifest["homeDirectory"]) != home:
        raise ValueError("Host homeDirectory does not match the current user")
    files = list(manifest["files"]) + [{
        "target": manifest["repoLink"], "source": str(repo), "repoLink": True,
    }]
    targets = [target_path(home, entry["target"]) for entry in files]
    if len(set(targets)) != len(targets):
        raise ValueError("Duplicate file target")
    for target in targets:
        check_parents(home, target)
        if any(parent in targets for parent in target.parents):
            raise ValueError("Overlapping file targets: " + str(target))

    planned = []
    for entry, target in zip(files, targets):
        source = Path(entry["source"])
        if not os.path.lexists(source):
            raise ValueError("Built source is missing: " + str(source))
        if same_link(target, source) or (not entry.get("repoLink") and managed_link(target)):
            continue
        if target.is_symlink() and not target.resolve().is_relative_to(repo):
            raise ValueError("Target is linked outside this checkout: " + str(target))
        if target.is_dir() and (entry.get("repoLink") or not source.is_dir()):
            raise ValueError("Unexpected directory at file target: " + str(target))
        planned.append({"target": str(target), "source": str(source),
                        "repoLink": entry.get("repoLink", False), "started": False})
    return planned


def adopt(manifest, home, repo):
    """Move only preflighted targets into a recoverable journal."""
    repo = repo.resolve()
    planned = plan_adoption(manifest, home, repo)
    if not planned:
        return None

    root = home / ".local/state/dotfiles/backups"
    check_parents(home, root / "new-backup")
    stamp = datetime.datetime.now(datetime.timezone.utc).strftime("%Y%m%dT%H%M%SZ")
    directory = root / (stamp + "-" + uuid.uuid4().hex[:8])
    directory.mkdir(parents=True, mode=0o700)
    journal = {"home": str(home), "files": planned}
    write_journal(directory, journal)
    try:
        for entry in planned:
            target = Path(entry["target"])
            entry["started"] = True
            write_journal(directory, journal)
            if os.path.lexists(target):
                backup = directory / "files" / target.relative_to(home)
                backup.parent.mkdir(parents=True, exist_ok=True)
                os.replace(target, backup)
            if entry["repoLink"]:
                target.parent.mkdir(parents=True, exist_ok=True)
                target.symlink_to(repo, target_is_directory=True)
    except BaseException:
        restore(directory, home)
        raise
    print("File backups: " + str(directory), file=sys.stderr)
    return directory


def install_script(url, command):
    with tempfile.TemporaryDirectory(prefix="dotfiles-installer-") as temporary:
        installer = Path(temporary) / "install.sh"
        run(["/usr/bin/curl", "--fail", "--location", "--proto", "=https",
             "--tlsv1.2", "--output", installer, url])
        run(command + [installer])


def prerequisites(build_only):
    nix = executable("nix", [Path("/nix/var/nix/profiles/default/bin/nix")])
    if not nix:
        if build_only:
            raise ValueError("Nix is required for --build-only")
        install_script("https://nixos.org/nix/install", ["/bin/sh"])
        nix = executable("nix", [Path("/nix/var/nix/profiles/default/bin/nix")])
        if not nix:
            raise ValueError("Nix installation did not provide a nix command")
    os.environ["PATH"] = str(Path(nix).parent) + os.pathsep + os.environ["PATH"]
    certificate = Path("/nix/var/nix/profiles/default/etc/ssl/certs/ca-bundle.crt")
    if certificate.is_file():
        os.environ.setdefault("NIX_SSL_CERT_FILE", str(certificate))
    if build_only:
        return nix
    brew = executable("brew", [Path("/opt/homebrew/bin/brew"), Path("/usr/local/bin/brew")])
    if not brew:
        install_script("https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh", ["/bin/bash"])
        brew = executable("brew", [Path("/opt/homebrew/bin/brew"), Path("/usr/local/bin/brew")])
        if not brew:
            raise ValueError("Homebrew installation did not provide a brew command")
    os.environ["PATH"] += os.pathsep + str(Path(brew).parent)
    return nix


def finish_setup(repo, home):
    gnupg = home / ".gnupg"
    check_parents(home, gnupg / "gpg-agent.conf")
    gnupg.mkdir(mode=0o700, exist_ok=True)
    agent_config = gnupg / "gpg-agent.conf"
    if not os.path.lexists(agent_config):
        pinentry = executable("pinentry-mac")
        if not pinentry:
            raise ValueError("pinentry-mac is missing after activation")
        with agent_config.open("x") as stream:
            stream.write("default-cache-ttl 46000\nmax-cache-ttl 46000\n")
            stream.write("pinentry-program " + pinentry + "\n")
    code = executable("code", [Path("/Applications/Visual Studio Code.app/Contents/Resources/app/bin/code")])
    if not code:
        raise ValueError("VS Code CLI is missing after activation")
    installed = set(run([code, "--list-extensions"], capture=True).lower().splitlines())
    for extension in (repo / ".vscode/extensions.txt").read_text().splitlines():
        extension = extension.strip()
        if extension and extension.lower() not in installed:
            run([code, "--install-extension", extension])
    for tool in ["git", "gh", "gpg", "go", "node", "nvim", "tmux", "rtk", "watchman"]:
        if not executable(tool):
            raise ValueError("Missing command after activation: " + tool)


def main(argv=None):
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--host", choices=["kevin-mac", "kevin-intel"])
    mode = parser.add_mutually_exclusive_group()
    mode.add_argument("--build-only", action="store_true", help="build without installs, backups, or activation")
    mode.add_argument("--restore", type=Path, metavar="BACKUP", help="restore the named file backup")
    args = parser.parse_args(argv)
    home = Path.home()
    if args.restore:
        restore(args.restore, home)
        return
    if platform.system() != "Darwin":
        raise ValueError("This bootstrap requires macOS")
    if os.geteuid() == 0:
        raise ValueError("Run bootstrap as the login user; it requests sudo when needed")
    architecture = platform.machine()
    default_host = {"arm64": "kevin-mac", "x86_64": "kevin-intel"}.get(architecture)
    if not default_host:
        raise ValueError("Unsupported Mac architecture: " + architecture)
    host = args.host or default_host
    if host != default_host:
        raise ValueError("Host architecture does not match this Mac")
    if not (REPO / "flake.lock").is_file():
        raise ValueError("Missing committed flake.lock")
    run(["/usr/bin/xcode-select", "--print-path"], capture=True)
    nix = prerequisites(args.build_only)
    flake = str(REPO) + "#"
    system = Path(run([nix] + NIX_FLAGS + ["build", "--no-link", "--print-out-paths",
        "--no-update-lock-file", flake + "darwinConfigurations." + host + ".system"], capture=True).strip())
    if not (system / "sw/bin/darwin-rebuild").is_file():
        raise ValueError("Build did not produce darwin-rebuild")
    if args.build_only:
        print(system)
        return
    manifest = json.loads(run([nix] + NIX_FLAGS + ["eval", "--json", "--no-update-lock-file",
        flake + "lib.bootstrap." + host], capture=True))
    if manifest["username"] != getpass.getuser():
        raise ValueError("Host username does not match this user")
    # Obtain administrator access before any home file is moved.
    run(["sudo", "-v"])
    backup = adopt(manifest, home, REPO)
    try:
        root_path = str(Path(nix).parent) + ":/usr/bin:/bin:/usr/sbin:/sbin"
        run(["sudo", "/usr/bin/env", "PATH=" + root_path, str(system / "sw/bin/darwin-rebuild"), "switch", "--flake",
             str(REPO) + "#" + host, "--no-update-lock-file"])
    except BaseException:
        if backup:
            restore(backup, home)
        print("Activation failed. System changes can be partial; file backups are retained.", file=sys.stderr)
        raise
    os.environ["PATH"] = "/etc/profiles/per-user/" + getpass.getuser() + "/bin" + os.pathsep + str(home / ".local/bin") + os.pathsep + os.environ["PATH"]
    finish_setup(REPO, home)
    print("Setup complete. Open a new terminal. App sign-ins and signing-key setup remain manual.")


if __name__ == "__main__":
    try:
        main()
    except (ValueError, OSError, subprocess.CalledProcessError) as error:
        print("Setup failed: " + str(error), file=sys.stderr)
        sys.exit(1)
