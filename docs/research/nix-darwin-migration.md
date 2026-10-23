# nix-darwin migration

The migration is now implemented on this branch. See [setup instructions](../../README.md). The bootstrap, flake, and plugin sources replace the old installer. Nix owns supported CLI tools; Homebrew retains app casks and four exceptions. The installed Nix version remains under its current owner.

## Historical spike

The research below records the earlier proposal and its temporary proof build. Its statements about missing implementation describe that earlier state.

Research date: 2026-10-21. Repo baseline: `056fbfaad3f92a0d46be02f9ed194f7c1e6bf530`.

Scope: the current Apple Silicon Mac. Linux migration remains separate.

### Result

Use nix-darwin for the Mac configuration and Homebrew. Use its Home Manager module for user files. Keep existing config files and Homebrew package ownership during the first migration. Move CLI tools to Nix in later changes, one tool at a time.

This remains a proposed migration. After Nix installation, the example below passed a flake check and a full system build on arm64 macOS 26.7.1. No activation was run. The repo still has no `flake.nix`, `flake.lock`, or `bootstrap.sh`.

### Validation after Nix installation

Verified Nix 2.35.3 and its daemon. The tool shell did not have Nix on PATH; this profile script made it available:

```sh
source /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh
```

The Markdown example and its three source files were copied to a temporary folder. A lockfile was generated there. These checks passed:

- `nix flake check --no-build`.
- `nix build --no-link --print-out-paths --no-update-lock-file .#darwinConfigurations.kevin-mac.system`.
- The built output contains an executable `sw/bin/darwin-rebuild` and activation scripts.
- The generated Brewfile contains the repo Brewfile unchanged: 35 formulae, 17 casks, and 3 taps.

The successful build used these locked revisions:

| Input | Revision |
| --- | --- |
| nixpkgs | [36fd15bbb657815e2028e31d715c2e43a1230c91](https://github.com/NixOS/nixpkgs/commit/36fd15bbb657815e2028e31d715c2e43a1230c91) |
| nix-darwin | [4459544d8296fa2cca7168de1e54a6691ec48a17](https://github.com/nix-darwin/nix-darwin/commit/4459544d8296fa2cca7168de1e54a6691ec48a17) |
| Home Manager | [24f8f8e786f87d6a818e1746cb2389bf922afdab](https://github.com/nix-community/home-manager/commit/24f8f8e786f87d6a818e1746cb2389bf922afdab) |

Build output: `/nix/store/7xlprwpc8dp6hr1m0gxaxhxqabzqfsqg-darwin-system-26.05.4459544`.

The proposed configuration selects Nix 2.34.9+1; the installed version is 2.35.3. Review Nix version and installation ownership before the first activation.

This proves that the small example builds. Homebrew installation, file adoption, plugin behavior, fresh-machine setup, and activation remain untested. No Homebrew command or activation script was run during validation.

### One-command setup target

One command must set up a supported Mac, including Nix and Homebrew prerequisites. Proposed entry point after checkout:

```sh
bash ./bootstrap.sh --host kevin-mac
```

`bootstrap.sh` is proposed; this spike does not add it. The published entry point must also work before the repo is cloned: a small launcher downloads a fixed repo revision and runs the same script. A new Mac must not require a separate Nix, Homebrew, or plugin installation command.

The script must:

1. Check macOS, architecture, user, and required Apple command-line tools. Report required OS steps and resume safely when rerun.
2. Install missing Nix and Homebrew prerequisites, then load their paths in the same run.
3. Select the host configuration and use its committed lockfile. Ordinary setup must not update the lockfile.
4. Back up configured target files, check ownership, and build before activation. Stop on unexpected file conflicts.
5. Apply packages, file mappings, and declared plugins through nix-darwin and Home Manager.
6. Run smoke checks and print any remaining account sign-ins or machine-specific key setup.

Administrator prompts and app sign-ins remain interactive. A second run must use the same entry point without duplicate installs, lost files, or unintended package upgrades. Test both a clean Mac and an existing dotfiles installation before calling one-command setup complete.

### Current scope

The [installer](https://github.com/thiskevinwang/dotfiles/blob/056fbfaad3f92a0d46be02f9ed194f7c1e6bf530/install.sh) combines package installation, network downloads, file deletion, symlinks, plugin setup, and local Git/GPG edits. Its root glob also links non-config entries such as `Brewfile` and `docs`. New root `nix/` or `home/` directories would become `~/.nix` or `~/.home`. Replace or guard that glob before adding modules.

The [Brewfile](https://github.com/thiskevinwang/dotfiles/blob/056fbfaad3f92a0d46be02f9ed194f7c1e6bf530/Brewfile) declares 35 formulae, 17 casks, and 3 taps. The checked Mac has 150 formulae and 21 casks. Thus, the Brewfile does not describe the full installed environment. These counts do not establish package equivalence or alias resolution.

Existing shell, Git, Vim, tmux, Ghostty, Zed, and agent instructions use checkout symlinks. File edits take effect directly. Store-backed Home Manager files instead require a rebuild and activation. Keep this change visible in the new README.

The open draft [PR #3](https://github.com/thiskevinwang/dotfiles/pull/3) contains an older migration at `4a57b3dd7fb90cc86338092b67e5b3c451b69d6e`. It uses 24.11 plus unstable inputs, lacks `flake.lock`, and leaves GUI casks manual. Its shell/tmux conversion omits current behavior. Reuse its file-mapping idea only. Its reported container check was not repeated for this spike.

### Ownership

| Component | First migration | Later work |
| --- | --- | --- |
| nix-darwin | Nix settings, host architecture, primary user, Homebrew activation | Explicit macOS preferences and services |
| Home Manager | Explicit leaf-file links from existing sources | Native program modules where behavior matches |
| Homebrew | Existing 35 formulae, 17 casks, 3 taps | Keep GUI apps; transfer selected CLI tools to Nix |
| Local writable files | Credentials, runtime state, machine-specific Git settings | Keep outside the Nix store |
| Bootstrap | Install missing Nix/Homebrew prerequisites and adopt files explicitly | One command for a new or existing Mac |

Home Manager supports nix-darwin integration, activates each configured user during system activation, and can share the system package set. Use `home-manager.useGlobalPkgs = true` and `home-manager.useUserPackages = true`. [Home Manager integration](https://nix-community.github.io/home-manager/installation/nix-darwin.html)

Keep one owner per executable and config path. For example, retain Homebrew `gh` and GPG while `gitconfig` names their Homebrew paths. Do not also install Nix copies. Keep raw `.zshrc` ownership separate from `programs.zsh` configuration generation.

#### File manifest

Use explicit `home.file` targets, relative to `/Users/kevin`. Do not link entire `.codex`, `.claude`, `.config`, or application-support directories.

| Source | Target |
| --- | --- |
| `zshrc` | `~/.zshrc` |
| `gitconfig` | `~/.gitconfig` |
| `gitignore` | `~/.gitignore` |
| `vimrc` | `~/.vimrc` |
| `tmux.conf` | `~/.tmux.conf` |
| `AGENTS.md` | `~/.codex/AGENTS.md`, `~/.claude/CLAUDE.md`, `~/.config/zed/AGENTS.md` |
| `zed/settings.json` | `~/.config/zed/settings.json` |
| `ghostty/config` | `~/.config/ghostty/config` |
| `nushell/config.nu` | `~/Library/Application Support/nushell/config.nu` |
| `tmux-powerline/config.sh` | `~/.config/tmux-powerline/config.sh` |
| `tmux-powerline/theme.sh` | `~/.config/tmux-powerline/themes/theme.sh` |
| Generated Neovim file | `~/.config/nvim/init.vim`, sourcing `~/.vimrc` |

These mappings come from the [installer](https://github.com/thiskevinwang/dotfiles/blob/056fbfaad3f92a0d46be02f9ed194f7c1e6bf530/install.sh). Preserve source bytes first. The installer creates the Neovim target, but that path was absent on the checked Mac; validate it during adoption.

### Minimal proposed flake

This example shows the proposed integration with tmux and agent instruction files. It is not the complete migration. Place `flake.nix` at the repo root only after the old installer glob is guarded.

```nix
{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-26.05-darwin";
    nix-darwin.url = "github:nix-darwin/nix-darwin/nix-darwin-26.05";
    nix-darwin.inputs.nixpkgs.follows = "nixpkgs";
    home-manager.url = "github:nix-community/home-manager/release-26.05";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = { nix-darwin, home-manager, ... }: {
    darwinConfigurations.kevin-mac = nix-darwin.lib.darwinSystem {
      modules = [
        home-manager.darwinModules.home-manager
        {
          nixpkgs.hostPlatform = "aarch64-darwin";
          system.primaryUser = "kevin";
          users.users.kevin.home = "/Users/kevin";
          system.stateVersion = 7;
          nix.settings.experimental-features = [ "nix-command" "flakes" ];

          homebrew = {
            enable = true;
            extraConfig = builtins.readFile ./Brewfile;
            onActivation = {
              cleanup = "none";
              autoUpdate = false;
              upgrade = false;
            };
          };

          home-manager.useGlobalPkgs = true;
          home-manager.useUserPackages = true;
          home-manager.users.kevin = {
            home.username = "kevin";
            home.homeDirectory = "/Users/kevin";
            home.stateVersion = "26.05";
            home.file = {
              ".tmux.conf".source = ./tmux.conf;
              ".codex/AGENTS.md".source = ./AGENTS.md;
              ".claude/CLAUDE.md".source = ./AGENTS.md;
              ".config/zed/AGENTS.md".source = ./AGENTS.md;
            };
          };
        }
      ];
    };
  };
}
```

The release input names match the [nix-darwin release flake](https://github.com/nix-darwin/nix-darwin/blob/nix-darwin-26.05/flake.nix) and [Home Manager release branch](https://github.com/nix-community/home-manager/tree/release-26.05). Module wiring follows the [Home Manager Darwin template](https://github.com/nix-community/home-manager/blob/release-26.05/templates/nix-darwin/flake.nix). Generate and commit `flake.lock`; branch names alone do not freeze revisions. The revisions used for the successful build are recorded above.

`system.stateVersion = 7` selects nix-darwin compatibility defaults for a new 26.05 installation. `home.stateVersion = "26.05"` separately selects Home Manager compatibility defaults. Neither value pins packages. Keep both values fixed across ordinary updates; review migration notes before a change. [nix-darwin version option](https://github.com/nix-darwin/nix-darwin/blob/nix-darwin-26.05/modules/system/version.nix), [Home Manager version option](https://github.com/nix-community/home-manager/blob/release-26.05/modules/misc/version.nix)

`homebrew.extraConfig` appends the current Brewfile without a package-name rewrite. The module requires an existing Homebrew installation. `cleanup = "none"` keeps undeclared packages. `autoUpdate = false` and `upgrade = false` suppress activation updates/upgrades; they do not pin Homebrew package versions or stop separate manual/app updates. Review custom-tap trust with the installed Homebrew version before the first switch. [Homebrew module](https://github.com/nix-darwin/nix-darwin/blob/nix-darwin-26.05/modules/homebrew.nix)

### Adoption and mutable state

1. Record the explicit target manifest, each existing link target, and regular-file contents in a dated backup outside the repo.
2. Remove only verified checkout symlinks for targets being adopted. Stop on unexpected files or links. Do not use a root glob or blanket `force = true`.
3. Activate the small proof, compare content, then adopt the remaining targets in groups.
4. Keep backups until shell, editor, Git/GPG, and repeat-activation checks pass.

Home Manager checks collisions before file writes. Equal-content files can pass; different existing checkout symlinks fail. `backupFileExtension` handles regular files, not these symlinks. Therefore, use the explicit adoption step even when some current links have equal contents. [Collision checks](https://github.com/nix-community/home-manager/blob/release-26.05/modules/files/check-link-targets.sh)

Normal `home.file.source` paths become store-backed files. Keep editable local files, token files, keys, Codex state, plugin download directories, and application state outside these sources. If editable checkout links are required, `mkOutOfStoreSymlink` can link to an absolute checkout path; old generations then read current checkout contents, so file-content rollback is lost. [Home Manager file implementation](https://github.com/nix-community/home-manager/blob/release-26.05/modules/files.nix)

For settings edited through an app, such as Zed, choose the file ownership first. Test a settings save before adoption. Retain a writable checkout link when app edits are required.

Keep `~/.gitconfig.local` writable and preserve its include. Direct machine-specific edits to `git config --file ~/.gitconfig.local ...`; `git config --global` cannot be assumed to work with a read-only managed `.gitconfig`. Preserve local GPG agent configuration until its merge/ownership policy is explicit.

Never import plaintext secrets through `source`, `readFile`, or Nix option values. Store contents are readable by local users. Reference secret paths as runtime strings, or add encrypted secret management later. [Nix secrets guidance](https://nix.dev/manual/nix/2.34/store/secrets)

When `.zshrc` remains a raw file, add the Home Manager session-variable hook at the appropriate point: `. "/etc/profiles/per-user/$USER/etc/profile.d/hm-session-vars.sh"` for `useUserPackages = true`. Verify PATH order in a new login shell. [Session-variable hook](https://nix-community.github.io/home-manager/installation/nix-darwin.html)

### Work order

| Step | Files / work | Required result |
| --- | --- | --- |
| 1 | Guard `install.sh` root glob; define `bootstrap.sh` host selection and backup/adoption procedure | New module folders cannot become home links |
| 2 | Add `flake.nix`, `flake.lock`; extract modules to `nix/darwin.nix` and `nix/home.nix` | Evaluate and build the proposed proof on this Mac |
| 3 | Adopt tmux/agent leaves; retain Brewfile packages | Correct links; no package removals |
| 4 | Add remaining file manifest and shell session hook | Existing shell/editor/Git behavior retained |
| 5 | Add `bootstrap.sh`; replace network/plugin setup with declared packages or pinned sources | One command sets up a clean Mac and can run again safely |
| 6 | Add selected macOS preferences; move individual CLI tools | One owner per executable; checked reset/rollback behavior |

Step 5 must cover Oh My Zsh, zsh plugins, Vim plug/plugins, TPM, tmux-powerline, optional fonts, Neovim glue, and VS Code extensions. Do not retire the installer before this work or a documented replacement exists. The bootstrap script must install missing Nix and Homebrew prerequisites. The direct validation commands below assume those prerequisites are installed. The [nix-darwin README](https://github.com/nix-darwin/nix-darwin#prerequisites) currently recommends the Lix installer for its uninstaller; nix-darwin manages the Nix implementation by default.

Resolve current machine dependencies separately: `tmux`, `rtk`, `git-lfs`, Terraform, gcloud, Bun, and Codex are available but not fully declared by the Brewfile. The shell also assumes Nomad, rbenv/Ruby, OpenJDK, Android SDK, and local scripts; these assumptions do not prove working installs. Preserve PostgreSQL data/services before selecting versions: installed names include `postgresql@14` and `postgresql@18`; the Brewfile says `postgresql`. [Current shell](https://github.com/thiskevinwang/dotfiles/blob/056fbfaad3f92a0d46be02f9ed194f7c1e6bf530/zshrc)

Preserve tmux Ctrl-Space, theme hooks, `set-titles-string '#T'`, and tmux-powerline paths. Resolve the font mismatch: Ghostty/Zed select IBM Plex Mono; Brewfile declares Fira Code Nerd Font. [tmux config](https://github.com/thiskevinwang/dotfiles/blob/056fbfaad3f92a0d46be02f9ed194f7c1e6bf530/tmux.conf), [Ghostty config](https://github.com/thiskevinwang/dotfiles/blob/056fbfaad3f92a0d46be02f9ed194f7c1e6bf530/ghostty/config), [Zed config](https://github.com/thiskevinwang/dotfiles/blob/056fbfaad3f92a0d46be02f9ed194f7c1e6bf530/zed/settings.json)

### Validation and commands

Proposed commands only. Run after Nix installation and after the actual configuration files exist. `kevin-mac` is an explicit flake output name, not a claim about the current hostname.

```sh
rtk git add flake.nix
rtk proxy nix --extra-experimental-features 'nix-command flakes' flake lock
rtk git add flake.lock
rtk proxy nix --extra-experimental-features 'nix-command flakes' flake check --no-build
rtk proxy nix --extra-experimental-features 'nix-command flakes' build .#darwinConfigurations.kevin-mac.system
```

The feature flags work before the first activation; the flake's `nix.settings` takes effect only after activation. Also stage extracted modules before evaluation; local Git flakes include added files and omit untracked files. A flake check alone does not establish Darwin activation or Homebrew availability. [Nix flake rules](https://nix.dev/manual/nix/2.33/command-ref/new-cli/nix3-flake.html)

Review the generated activation scripts and the generated Homebrew list. Then run the first activation through the built output:

```sh
rtk proxy sudo ./result/sw/bin/darwin-rebuild switch --flake .#kevin-mac
rtk proxy sudo darwin-rebuild switch --flake .#kevin-mac
```

`build` does not activate the system and can run as the user. `switch`, `check`, and rollback require root in the checked release. `check` runs activation checks; it is not a substitute for a build-only stage. [darwin-rebuild source](https://github.com/nix-darwin/nix-darwin/blob/nix-darwin-26.05/pkgs/nix-tools/darwin-rebuild.sh)

Acceptance checks:

- A clean worktree clone evaluates and builds from the committed lockfile on the target Mac.
- The generated package list matches the declared Brewfile; installed extra packages remain installed.
- All adopted links point to the expected generation; file contents match their repo sources.
- A new login shell loads with correct PATH and tool versions. Git authentication/signing and Vim/Neovim plugins work.
- Ghostty, Zed, Nushell, tmux bindings/theme/title, and agent instruction paths retain current behavior.
- A second switch causes no unwanted file, package, or preference changes.
- One setup command completes bootstrap on a disposable Mac/VM before the old installer is removed; the same command can run again safely.

### Rollback limits

List or activate an earlier system generation after at least two successful generations exist:

```sh
rtk proxy darwin-rebuild --list-generations
rtk proxy sudo darwin-rebuild switch --rollback
```

Rollback selects an older system profile and runs its activation. It is not a full disk rollback. Homebrew versions, deleted application data, runtime state, out-of-store file contents, and pre-adoption files require separate backups. The first Nix generation cannot restore the former unmanaged setup by itself. [Rollback implementation](https://github.com/nix-darwin/nix-darwin/blob/nix-darwin-26.05/pkgs/nix-tools/darwin-rebuild.sh)

macOS preferences need explicit reset rules. nix-darwin writes configured non-null defaults; removing an option does not issue `defaults delete`. An older generation therefore does not necessarily reset a preference introduced later. Capture the old value before the first preference change. [Defaults implementation](https://github.com/nix-darwin/nix-darwin/blob/nix-darwin-26.05/modules/system/defaults-write.nix)

Before the first switch, retain the target manifest and original links. If that activation fails, inspect partial changes and restore only adopted targets from the backup. Nix installation removal is a separate installer-specific operation.
