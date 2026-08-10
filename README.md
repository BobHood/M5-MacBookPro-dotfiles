# 🖥 Unified CommandLineInterface Dotfiles (SystemChecks built in)

> **One set of dotfiles, both machines.** A modular shell configuration that
> auto-detects OS, package manager, shell, and SSH context, and adapts —
> instead of maintaining separate Mac and Linux dotfile trees.

```
 ██████╗  ██████╗ ████████╗███████╗██╗██╗     ███████╗███████╗
 ██╔══██╗██╔═══██╗╚══██╔══╝██╔════╝██║██║     ██╔════╝██╔════╝
 ██║  ██║██║   ██║   ██║   █████╗  ██║██║     █████╗  ███████╗
 ██║  ██║██║   ██║   ██║   ██╔══╝  ██║██║     ██╔══╝  ╚════██║
 ██████╔╝╚██████╔╝   ██║   ██║     ██║███████╗███████╗███████║
 ╚═════╝  ╚═════╝    ╚═╝   ╚═╝     ╚═╝╚══════╝╚══════╝╚══════╝
```

![macOS](https://img.shields.io/badge/macOS-Sequoia_%2F_Tahoe-black?style=for-the-badge&logo=apple&logoColor=white)
![Linux](https://img.shields.io/badge/Linux-Ubuntu_Server-e95420?style=for-the-badge&logo=ubuntu&logoColor=white)
![Shell](https://img.shields.io/badge/Shell-Zsh_%2B_Bash-blue?style=for-the-badge&logo=gnu-bash&logoColor=white)
![Homebrew](https://img.shields.io/badge/Homebrew-Package_Manager-orange?style=for-the-badge&logo=homebrew&logoColor=white)
![Oh My Zsh](https://img.shields.io/badge/Oh_My_Zsh-Framework-purple?style=for-the-badge)
![Powerlevel10k](https://img.shields.io/badge/Powerlevel10k-Theme-yellow?style=for-the-badge)

---

## Currently deployed on

| Machine | OS | Package manager | Shell |
|---|---|---|---|
| **BlackMagic-M5** (MacBook Pro, Apple M5) | macOS Tahoe | Homebrew | zsh (Powerlevel10k) |
| **macpro-llm** (2010 Mac Pro flashed to 5,1, local LLM homelab server) | Ubuntu Server 26.04 | apt | zsh (Powerlevel10k) |

This repo was originally Mac-only (`M5-MacBookPro-dotfiles`). It was renamed and
reworked in place (2026-08-09) after copying `.zshrc` onto `macpro-llm` hit
hard-coded Homebrew-only paths that broke on Linux — see
`Second Brain/Coding/Dotfiles/Dotfiles - Project Context & Handoff.md` for the
full story. Rather than maintaining a separate Linux config tree (the
now-superseded `Operating-System-Dotfiles` repo's approach), this repo detects
its environment and adapts.

---

## SystemChecks — the part that makes "unified" actually work

`config/Dotfiles/system_checks.sh` is a plain **POSIX `sh`** module (not
zsh-only syntax) sourced first — before anything else — by both `.zshrc` and
`.bashrc`. It runs detection once and exports flags every later file branches
on, instead of every file separately re-testing `command -v`/`[[ -f ]]`:

| Flag | Values | What it's for |
|---|---|---|
| `UCD_OS` | `macos` / `linux` | Which OS-specific block to run |
| `UCD_PKG` | `brew` / `apt` | Which package manager's update commands apply |
| `UCD_SHELL` | `zsh` / `bash` / `other` | Which shell is actually running right now |
| `UCD_IS_SSH` | `0` / `1` | Local session vs. SSH'd in (affects editor choice, prompt style) |
| `UCD_HOSTNAME` | short hostname | Host-aware logic / prompt |
| `UCD_BREW_PREFIX` | e.g. `/opt/homebrew` | Homebrew paths without hard-coding Apple Silicon vs Intel vs "no Homebrew at all" |
| `UCD_ZSH_CUSTOM` | oh-my-zsh custom dir | Where Powerlevel10k/plugins actually live on this box |
| `UCD_HAS_<TOOL>` | `0` / `1` per tool | fzf, zoxide, eza, bat, atuin, fastfetch, tmux, nvim, vim, nano, op, gh, git, tesseract, python3, brew |

**Why both `.zshrc` and `.bashrc` source it:** zsh is the primary, fully-featured
shell everywhere it's installed — but a fresh box (before `chsh`), a root/rescue
shell, or a script that explicitly invokes bash still needs *something* sane.
`.bashrc` is deliberately minimal (not full zsh/Powerlevel10k parity) — it just
means bash-as-fallback isn't a bare, context-free `$` prompt.

---

## 📁 Repository Structure

The repo mirrors the exact folder structure on each machine, so a file's path
in the repo tells you exactly where it lives.

```
unified-cli-dotfiles/            Machine location
│
├── 📁 home/                                           → ~/
│   ├── 📄 .zshrc                                      → ~/.zshrc                    (both OSes)
│   ├── 📄 .bashrc                                     → ~/.bashrc                   (both OSes — fallback shell)
│   ├── 📄 .p10k.zsh                                   → ~/.p10k.zsh                 (macOS; Linux boxes run p10k's first-run wizard once instead)
│   ├── 📄 .gitconfig                                  → ~/.gitconfig                (macOS)
│   ├── 📄 Brewfile                                    → ~/Brewfile                  (macOS only — Homebrew package list)
│   ├── 📄 Updater.sh                                  → ~/Updater.sh                (macOS only)
│   ├── 📄 superbrew.sh                                → ~/superbrew.sh              (macOS only)
│   │
│   ├── 📁 .ssh/                                       → ~/.ssh/
│   │   └── 📄 config                                  → ~/.ssh/config
│   │
│   ├── 📁 .claude/                                    → ~/.claude/
│   │   └── 📄 settings.local.json                     → ~/.claude/settings.local.json
│   │
│   ├── 📁 .config/                                    → ~/.config/
│   │   ├── 📁 bpytop/                                 → ~/.config/bpytop/           (macOS)
│   │   └── 📁 zed/                                    → ~/.config/zed/              (macOS)
│   │
│   └── 📁 Library/                                    → ~/Library/                  (macOS only — VS Code, iTerm2)
│
└── 📁 config/                                         → ~/.config/
    └── 📁 Dotfiles/                                   → ~/.config/Dotfiles/
        ├── 📄 system_checks.sh                        → OS/shell/SSH detection — sourced first by both .zshrc and .bashrc
        ├── 📄 aliases.zsh                             → portable + macOS-only + Linux-only sections
        ├── 📄 path.zsh                                → portable + Homebrew-gated section
        ├── 📄 scripts.zsh                              → functions; macOS-only ones (AppleScript-based) print a clear message on Linux instead of erroring
        ├── 📄 .tmux.conf                              → (macOS)
        ├── 📄 .vimrc                                  → (macOS)
        │
        └── 📁 OSX-Git/                               → ~/.config/Dotfiles/OSX-Git/  (macOS)
```

---

## 🔧 Key Tools & Technologies

| Tool | Purpose | Availability |
|------|---------|---|
| 🐚 **Zsh + Oh My Zsh** | Shell framework with plugins and themes | Both |
| ⚡ **Powerlevel10k** | Fast, customizable prompt theme | Both (Homebrew path or oh-my-zsh custom-themes path, auto-detected) |
| 🍺 **Homebrew** | macOS package manager | macOS |
| 📦 **apt** | Debian/Ubuntu package manager | Linux |
| 📦 **Brewfile** | Declarative package list for reproducible installs | macOS |
| 🔍 **fzf** | Fuzzy finder — Ctrl+R history, Ctrl+T file search | Both, if installed (`UCD_HAS_FZF`) |
| 📂 **eza** | Modern `ls` replacement with icons and git integration | Both, if installed (`ll`/`la`/`tree` fall back to plain `ls` if not) |
| 🦇 **bat** | Syntax-highlighted `cat` replacement | Both, if installed |
| 🚀 **zoxide** | Smart `cd` with frecency tracking | Both, if installed (guarded — `cd` stays the plain builtin otherwise) |
| 🗂 **yazi** | Terminal file manager with image preview | Both, if installed |
| 🔄 **atuin** | Shell history sync and search | Both, if installed |
| ℹ️ **fastfetch** | System info display at shell startup | Both, if installed |
| 🔐 **1Password** | Password manager with CLI and shell integration | macOS |
| 🖥 **xclip / xsel** | Clipboard access | Linux equivalent of macOS `pbcopy`/`pbpaste` — used by the unified `2clip`/`clip2` aliases |

---

## 📄 File Descriptions

### 🐚 `.zshrc`
**Location:** `~/.zshrc` (both OSes)

Loads in this order (see `Dotfiles - Standards & Conventions.md` for the full
authoritative list):

1. Amazon Q pre-block
2. **SystemChecks** (`system_checks.sh`) — must run before anything below branches on `UCD_*`
3. Powerlevel10k instant prompt
4. Homebrew completions (macOS, if present)
5. Oh My Zsh
6. Syntax highlighting / autosuggestions (Homebrew path → apt path → oh-my-zsh custom-plugin path, first one found wins)
7. Modular `.zsh` files from `~/.config/Dotfiles/` (glob uses zsh's `(N)` null-glob qualifier so an empty directory doesn't abort shell startup)
8. Programming environment paths
9. fzf key bindings
10. 1Password CLI completion (macOS)
11. iTerm2 integration (macOS)
12. atuin, fastfetch (if installed)
13. Powerlevel10k theme (Homebrew path → oh-my-zsh custom-themes path)
14. zoxide (guarded — skipped entirely if not installed)
15. Amazon Q post-block

### 🐚 `.bashrc`
**Location:** `~/.bashrc` (both OSes)

Deliberately minimal fallback — not full zsh/Powerlevel10k parity. Sources
`system_checks.sh`, sets bash-equivalent history options, a plain
informative prompt (host/cwd/git-branch), and a small set of tool-aware
aliases. Exists for: a fresh box before `chsh -s $(which zsh)`, a root/rescue
shell, or a script that explicitly invokes bash.

### 🔗 `aliases.zsh`
**Location:** `~/.config/Dotfiles/aliases.zsh`

Three sections:
- **Portable** — git, docker, python, disk usage, session management, editor
  selection (checks `command -v code`), etc. Work identically on either OS.
- **macOS-only block** (`if [[ "$UCD_OS" == "macos" ]]`) — Finder/Spotlight/
  `defaults write`, `pmset`, Homebrew commands. No meaningful Linux
  equivalent for most of these, so they're simply not defined there.
- **Linux-only block** (`if [[ "$UCD_OS" == "linux" ]]`) — apt equivalents,
  `xclip`/`xsel` clipboard, `systemd-resolved` DNS flush.

Several aliases that used to be macOS-only are now **unified same-name
functions** in the portable section, branching internally on `$UCD_OS` so
the identical command works correctly on either machine: `trash`, `ips`,
`openPorts`, `lsockU`, `lsockT`, `lumos`/`nox` (light/dark mode — `lux` on
macOS, `gsettings` on Linux/GNOME), `showBlocked` (`ipfw`/`ufw`/`iptables`).

### 🛤 `path.zsh`
**Location:** `~/.config/Dotfiles/path.zsh`

Portable core (`~/Applications`, `~/.cargo/bin`, `~/.local/bin`) plus a
Homebrew block gated on `$UCD_OS == macos && $UCD_BREW_PREFIX` — uses
`$UCD_BREW_PREFIX` rather than a hard-coded `/opt/homebrew`, so it's correct
on both Apple Silicon and Intel Macs without editing.

### 📜 `scripts.zsh`
**Location:** `~/.config/Dotfiles/scripts.zsh`

Functions that depend on AppleScript/osascript (`note`, `remind`, `show`,
`cdf`) or macOS-only tools (`spotlight`/Spotlight, `netscan`/the private
`airport` binary) print a clear "macOS-only, not available on $UCD_OS"
message on Linux instead of a bare "command not found." Everything else
(git helpers, `extract`, `targz`, `fs`, `duh`, `y`, `fcd`, `passgen`,
`checksum`, `sslCheck`, `jwtd`, `weather`, `serve`, `json`, `unzip-safe`,
etc.) was already portable POSIX/GNU-ish shell and is unchanged. `b64` now
prefers the standard `base64` command over `php` (works on both OSes
without needing php installed).

### 🍺 `Brewfile`, `Updater.sh`, `superbrew.sh`
**macOS only.** Declarative Homebrew package list, full automated system
updater, and interactive Homebrew audit script respectively — unchanged
from the original Mac-only repo. No Linux equivalent is planned; `apt`
package management on Linux boxes is handled ad hoc (see `aptup`/`aptinfo`
aliases in `aliases.zsh`'s Linux block) rather than via a declarative
manifest, since the Linux machines in this setup (currently just
`macpro-llm`) are single-purpose servers, not general-use workstations.

### 🖥 `.tmux.conf`, 📝 `.vimrc`, 🔀 `OSX-Git/`, VS Code / iTerm2 / Zed / bpytop configs
**macOS only**, unchanged from the original repo.

---

## 🚀 Deploying to a New Machine

### macOS

```bash
# 1. Homebrew
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

# 2. Oh My Zsh
sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"

# 3. Clone
mkdir -p ~/GitHub && git clone https://github.com/BobHood/unified-cli-dotfiles.git ~/GitHub/unified-cli-dotfiles
cd ~/GitHub/unified-cli-dotfiles

# 4. Copy into place
cp home/.zshrc ~/.zshrc
cp home/.bashrc ~/.bashrc
cp home/.p10k.zsh ~/.p10k.zsh
cp home/.gitconfig ~/.gitconfig
cp home/Brewfile ~/Brewfile
cp home/Updater.sh ~/Updater.sh && chmod +x ~/Updater.sh
cp home/superbrew.sh ~/superbrew.sh && chmod +x ~/superbrew.sh
mkdir -p ~/.ssh && cp home/.ssh/config ~/.ssh/config && chmod 600 ~/.ssh/config
mkdir -p ~/.claude && cp home/.claude/settings.local.json ~/.claude/settings.local.json
mkdir -p ~/.config/bpytop && cp home/.config/bpytop/bpytop.conf ~/.config/bpytop/bpytop.conf
mkdir -p ~/.config/zed && cp home/.config/zed/settings.json ~/.config/zed/settings.json
mkdir -p ~/Library/Application\ Support/Code/User
cp home/Library/Application\ Support/Code/User/settings.json ~/Library/Application\ Support/Code/User/settings.json
cp home/Library/Application\ Support/Code/User/keybindings.json ~/Library/Application\ Support/Code/User/keybindings.json
mkdir -p ~/Library/Application\ Support/iTerm2/DynamicProfiles
cp "home/Library/Application Support/iTerm2/DynamicProfiles/vscode-synced.json" ~/Library/Application\ Support/iTerm2/DynamicProfiles/vscode-synced.json

mkdir -p ~/.config/Dotfiles
cp config/Dotfiles/system_checks.sh ~/.config/Dotfiles/
cp config/Dotfiles/aliases.zsh ~/.config/Dotfiles/
cp config/Dotfiles/path.zsh ~/.config/Dotfiles/
cp config/Dotfiles/scripts.zsh ~/.config/Dotfiles/
cp config/Dotfiles/.tmux.conf ~/.config/Dotfiles/
cp config/Dotfiles/.vimrc ~/.config/Dotfiles/
cp config/Dotfiles/OSX-Git/.gitignore ~/.gitignore
cp config/Dotfiles/OSX-Git/.gitattributes ~/.gitattributes

# 5. Packages, theme, reload
brew bundle install --file ~/Brewfile
brew install powerlevel10k
source ~/.zshrc
```

### Linux (Ubuntu/Debian — tested on Ubuntu Server 26.04)

```bash
# 1. zsh + git
sudo apt install -y zsh git

# 2. Oh My Zsh
sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
# ^ This backs up any existing .zshrc to .zshrc.pre-oh-my-zsh — restore/merge
#   as needed rather than losing it: mv ~/.zshrc.pre-oh-my-zsh ~/.zshrc

# 3. Powerlevel10k (cloned into oh-my-zsh's custom themes dir — system_checks.sh
#    detects this path automatically via $UCD_ZSH_CUSTOM)
git clone --depth=1 https://github.com/romkatv/powerlevel10k.git ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k

# 4. Clone this repo and copy the cross-platform pieces into place
#    (skip the macOS-only home/ files above — Brewfile, .p10k.zsh, VS Code/
#    iTerm2/Zed configs, etc. don't apply)
mkdir -p ~/GitHub && git clone https://github.com/BobHood/unified-cli-dotfiles.git ~/GitHub/unified-cli-dotfiles
cd ~/GitHub/unified-cli-dotfiles
cp home/.zshrc ~/.zshrc
cp home/.bashrc ~/.bashrc
mkdir -p ~/.config/Dotfiles
cp config/Dotfiles/system_checks.sh ~/.config/Dotfiles/
cp config/Dotfiles/aliases.zsh ~/.config/Dotfiles/
cp config/Dotfiles/path.zsh ~/.config/Dotfiles/
cp config/Dotfiles/scripts.zsh ~/.config/Dotfiles/

# 5. Make zsh the default shell, then start it (Powerlevel10k runs its
#    first-run config wizard automatically since there's no ~/.p10k.zsh yet)
chsh -s $(which zsh)
zsh
```

Optional Linux tool parity (not required — everything degrades gracefully
without these, per `UCD_HAS_*` guards):
```bash
sudo apt install -y zsh-syntax-highlighting zsh-autosuggestions nano
pip install eza-like-alternative-if-desired --break-system-packages   # or build eza from source; not in default apt repos on all releases
```

---

## 🎨 Shell Theme & Colors

**Powerlevel10k** on both machines. macOS uses `~/.p10k.zsh` copied from this
repo; Linux boxes generate their own via the first-run wizard on first `zsh`
launch (terminal font/glyph rendering can differ enough between machines that
sharing one `.p10k.zsh` isn't reliable — worth revisiting if that changes).

fzf uses the **Catppuccin Mocha** color scheme where fzf is installed:

![Catppuccin Mocha](https://img.shields.io/badge/Theme-Catppuccin_Mocha-cba6f7?style=for-the-badge&labelColor=1e1e2e)

---

## 📋 Notes

- **SystemChecks must load first** — everything else in `.zshrc`/`.bashrc` assumes `UCD_*` flags already exist.
- **Homebrew paths** use `$UCD_BREW_PREFIX` (detected via `brew --prefix`), not a hard-coded `/opt/homebrew` — correct on both Apple Silicon and Intel.
- **zoxide** is guarded — `cd` stays the plain shell builtin on any box without zoxide installed (e.g. macpro-llm, currently), rather than erroring on startup.
- **The `~/.config/Dotfiles/*.zsh` glob loader** uses zsh's `(N)` null-glob qualifier — safe even when the directory is empty or missing files, which zsh would otherwise treat as a fatal "no matches found" and abort shell startup entirely.
- **Amazon Q** pre and post blocks must remain at the very top and bottom of `.zshrc`.
- **Ruby/Python Homebrew versions** (macOS-only paths in `path.zsh`) — Homebrew Ruby 4.0 instead of system Ruby, Homebrew Python 3.14 with unversioned `python`/`pip` symlinks.

---

## 📄 License

MIT — feel free to use, fork, and adapt for your own setup.

---

*Built and maintained by [BobHood](https://github.com/BobHood)*
