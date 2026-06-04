# 🍎 M5 MacBook Pro Dotfiles

> **A fully documented, modular shell configuration for macOS — built for the Apple M5 MacBook Pro.**

```
 ██████╗  ██████╗ ████████╗███████╗██╗██╗     ███████╗███████╗
 ██╔══██╗██╔═══██╗╚══██╔══╝██╔════╝██║██║     ██╔════╝██╔════╝
 ██║  ██║██║   ██║   ██║   █████╗  ██║██║     █████╗  ███████╗
 ██║  ██║██║   ██║   ██║   ██╔══╝  ██║██║     ██╔══╝  ╚════██║
 ██████╔╝╚██████╔╝   ██║   ██║     ██║███████╗███████╗███████║
 ╚═════╝  ╚═════╝    ╚═╝   ╚═╝     ╚═╝╚══════╝╚══════╝╚══════╝
```

![macOS](https://img.shields.io/badge/macOS-Sequoia-black?style=for-the-badge&logo=apple&logoColor=white)
![Shell](https://img.shields.io/badge/Shell-Zsh-blue?style=for-the-badge&logo=gnu-bash&logoColor=white)
![Homebrew](https://img.shields.io/badge/Homebrew-Package_Manager-orange?style=for-the-badge&logo=homebrew&logoColor=white)
![Oh My Zsh](https://img.shields.io/badge/Oh_My_Zsh-Framework-purple?style=for-the-badge)
![Powerlevel10k](https://img.shields.io/badge/Powerlevel10k-Theme-yellow?style=for-the-badge)

---

## 📁 Repository Structure

The repo mirrors the exact folder structure on the Mac so you always know where each file lives and where to put it back.

```
M5-MacBookPro-dotfiles/         Mac location
│
├── 📁 home/                    → ~/
│   ├── 📄 .zshrc               → ~/.zshrc
│   ├── 📄 Brewfile             → ~/Brewfile
│   ├── 📄 Updater.sh           → ~/Updater.sh
│   └── 📄 superbrew.sh         → ~/superbrew.sh
│
└── 📁 config/                  → ~/.config/
    └── 📁 Dotfiles/            → ~/.config/Dotfiles/
        ├── 📄 aliases.zsh      → ~/.config/Dotfiles/aliases.zsh
        ├── 📄 path.zsh         → ~/.config/Dotfiles/path.zsh
        ├── 📄 scripts.zsh      → ~/.config/Dotfiles/scripts.zsh
        ├── 📄 .tmux.conf       → ~/.config/Dotfiles/.tmux.conf
        ├── 📄 .vimrc           → ~/.config/Dotfiles/.vimrc
        │
        └── 📁 OSX-Git/         → ~/.config/Dotfiles/OSX-Git/
            ├── 📄 .gitconfig   → ~/.gitconfig
            ├── 📄 .gitignore   → ~/.gitignore
            ├── 📄 .gitattributes → ~/.gitattributes
            └── 📄 git-bootstrap.sh
```

---

## 🔧 Key Tools & Technologies

| Tool | Purpose |
|------|---------|
| 🐚 **Zsh + Oh My Zsh** | Shell framework with plugins and themes |
| ⚡ **Powerlevel10k** | Fast, customizable prompt theme |
| 🍺 **Homebrew** | macOS package manager |
| 📦 **Brewfile** | Declarative package list for reproducible installs |
| 🔍 **fzf** | Fuzzy finder — Ctrl+R history, Ctrl+T file search |
| 📂 **eza** | Modern `ls` replacement with icons and git integration |
| 🦇 **bat** | Syntax-highlighted `cat` replacement |
| 🚀 **zoxide** | Smart `cd` with frecency tracking |
| 🗂 **yazi** | Terminal file manager with image preview |
| 🔄 **atuin** | Shell history sync and search |
| ℹ️ **fastfetch** | System info display at shell startup |
| 📖 **tealdeer** | Fast Rust-based tldr pages client |
| 🏪 **mas** | Mac App Store CLI for automated installs |
| 🔐 **1Password** | Password manager with CLI and shell integration |

---

## 📄 File Descriptions

### 🐚 `.zshrc`
**Location:** `~/.zshrc`

The main entry point for the shell. Loads everything in the correct order:

- **Amazon Q pre/post blocks** — AI coding assistant hooks (must stay at top/bottom)
- **Powerlevel10k** — prompt theme initialization
- **Oh My Zsh** — framework, plugins, and completions
- **Homebrew completions** — loaded before Oh My Zsh for correct compinit
- **Modular config files** — auto-sources all `.zsh` files from `~/.config/Dotfiles/`
- **Programming environments** — Python, Ruby, OpenSSL, icu4c, ImageMagick paths
- **fzf integration** — fuzzy finder key bindings with Catppuccin Mocha color scheme
- **zoxide** — smart cd (initialized last to correctly override all cd definitions)
- **1Password completion** — CLI shell integration
- **iTerm2 integration** — tab titles, badges, and shell marks
- **atuin** — shell history sync
- **fastfetch** — system info on startup

---

### 🔗 `aliases.zsh`
**Location:** `~/.config/Dotfiles/aliases.zsh`

All shell aliases organized into sections:

| Section | Examples |
|---------|---------|
| 📁 **Directory Navigation** | `..` `...` `.3` `.4` — traverse up directories |
| 📋 **Directory Listing** | `ls` `ll` `la` `tree` — powered by eza |
| 🔖 **Direct Navigation** | `dt` `drop` `dload` `gdrive` — jump to common folders |
| ⚡ **Command Shortcuts** | `cat→bat` `cp` `mv` `mkdir` — enhanced defaults |
| ✏️ **Config Editing** | `zshrc` `dotfiles` `ohmyzsh` — open configs in VS Code |
| 🔄 **Session Management** | `reload` `osupdate` `topten` |
| 🌐 **Networking** | `myip` `localip` `flushdns` `netCons` `openPorts` |
| 🍎 **macOS Utilities** | `showFiles` `hideFiles` `emptytrash` `spotoff` `afk` |
| 📋 **Clipboard** | `2clip` `clip2` — pipe to/from macOS clipboard |
| 🌙 **Light/Dark Mode** | `lumos` `nox` — switch all apps via zsh-lux |
| 🍺 **Homebrew** | `BrewMe` `BrewGreedy` — update and upgrade |
| 🔀 **Git** | `gs` `gd` `ga` `gpull` `gpush` `glog` — common git operations |
| 📊 **Process Management** | `memHogsTop` `cpu_hogs` `ttop` |
| 🐳 **Docker** | `dps` `dpa` `dclean` `dlogs` |
| 🐍 **Python** | `python→python3` `pip→pip3` `venv` `activate` |
| ✏️ **Editors** | `c` opens VS Code, `ze` opens Zed |

---

### 🛤 `path.zsh`
**Location:** `~/.config/Dotfiles/path.zsh`

Manages the `$PATH` environment variable with deduplication via `typeset -U`. Adds:

- `~/Applications` and `~/.local/bin`
- `/usr/local/bin` and `/usr/local/sbin`
- `~/.cargo/bin` — Rust binaries
- `/opt/homebrew/bin` — Homebrew core
- OpenSSL 3, Ruby, GNU libtool, and icu4c paths

---

### 📜 `scripts.zsh`
**Location:** `~/.config/Dotfiles/scripts.zsh`

Custom shell functions organized by category:

| Category | Functions |
|----------|----------|
| 🍎 **Apple Integration** | `note` — add to Notes.app; `remind` — add to Reminders.app |
| 🐚 **Shell Utilities** | `lman` — open man page for previous command |
| 📂 **Finder Integration** | `show` — reveal files in Finder; `cdf` — cd to Finder window |
| 🔐 **Encoding** | `b64` — base64 encode/decode |
| 🗂 **Directory & Archives** | `deletefiles` `extract` `mkd` `targz` |
| 💾 **Disk Utilities** | `fs` — file/dir size; `duh` — human-readable du |
| 🔍 **Search** | `spotlight` — Spotlight metadata search |
| ⚙️ **Process Management** | `findPid` `my_ps` `ii` — system info dashboard |
| 📁 **File Utilities** | `ff` — find by name; `cf` — count files |
| 🔒 **Security** | `passgen` `checksum` `sslCheck` `jwtd` |
| 🌐 **Network** | `netscan` — Wi-Fi info; `weather` — wttr.in report |
| 🔀 **Git Utilities** | `gcr` `cbr` `gbd` `gbrb` `gclog` `cloneRepos` `grf` |
| 🗂 **File Manager** | `y` — launch yazi and cd to exit directory |
| 🧭 **Navigation** | `mkcd` `fcd` — fzf directory picker |
| 🖥 **Server** | `serve` — Python HTTP server |
| 📋 **JSON** | `json` — pretty-print JSON |
| 📦 **Archive** | `unzip-safe` — safe zip extraction |

---

### 🍺 `Brewfile`
**Location:** `~/Brewfile`

Declarative list of all Homebrew formulae, casks, Mac App Store apps, and VS Code extensions. Used by `brew bundle` to keep the system in sync.

Includes:
- **CLI Tools** — git, vim, neovim, wget, fzf, bat, eza, yazi, zoxide, tealdeer, and more
- **Languages** — Python 3.14, Ruby 4.0, Rust
- **macOS Apps** — VS Code, iTerm2, Docker, 1Password, Blender, Obsidian, and more
- **MAS Apps** — Xcode, GarageBand, iMovie, Keynote, Pages, Numbers, and more
- **VS Code Extensions** — Claude Code, Prettier, shell formatting, icons, and more

---

### 🔄 `Updater.sh`
**Location:** `~/Updater.sh`

A fully automated system update script that runs everything in the correct order:

```
1. 🍎  macOS software updates        (softwareupdate)
2. 🐚  Oh My Zsh update              (upgrade.sh)
3. 🍺  Homebrew index refresh        (brew update)
4. ⬆️  Upgrade formulae & casks      (brew upgrade)
5. 📦  Reconcile Brewfile            (brew bundle)
6. 🔍  Check unlisted packages       (brew bundle cleanup)
7. 📖  Update tealdeer cache         (tldr --update)
8. 🏪  Mac App Store updates         (mas upgrade)
9. 💎  Ruby Gems update              (gem update)
10. 🧹 Homebrew cleanup              (brew cleanup)
11. 🏥 Brew Doctor health check      (brew doctor)
```

---

### 🍺 `superbrew.sh`
**Location:** `~/superbrew.sh`

An interactive Homebrew audit script that shows you everything before making any changes. Run it anytime to get a full health check of your system:

```sh
~/superbrew.sh
```

Checks performed — each one shows results and asks `[y/n]` before acting:

| Step | Check |
|------|-------|
| 1 | Refresh Homebrew formula index |
| 2 | Outdated formulae |
| 3 | Outdated casks |
| 4 | Auto-updating casks (greedy check) |
| 5 | Packages installed but missing from Brewfile |
| 6 | Packages in Brewfile but not installed |
| 7 | Outdated Ruby gems |
| 8 | Homebrew health check (`brew doctor`) |
| 9 | Cleanup old versions |
| 10 | Full summary of all installed formulae and casks |

---

### 🖥 `.tmux.conf`
**Location:** `~/.config/Dotfiles/.tmux.conf` → symlink to `~/.tmux.conf`

Tmux terminal multiplexer configuration with the Dracula theme. Enables persistent sessions, powerline status bar, and custom key bindings.

---

### 📝 `.vimrc`
**Location:** `~/.config/Dotfiles/.vimrc` → symlink to `~/.vimrc`

Vim editor configuration including syntax highlighting, smart indentation, search settings, and plugin mappings for NERDTree, Ack, and NERD Commenter.

---

### 🔀 `OSX-Git/`
**Location:** `~/.config/Dotfiles/OSX-Git/`

| File | Purpose |
|------|---------|
| `.gitconfig` | Global git settings — aliases, colors, diff tools, pretty log format |
| `.gitignore` | Global ignore rules — macOS, Vim, Windows, and common dev files |
| `.gitattributes` | Enforces LF line endings across all text files |
| `git-bootstrap.sh` | Sets up a fresh git environment on a new machine |

---

## 🚀 Deploying to a New Mac

### 1. Install Homebrew
```bash
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
```

### 2. Install Oh My Zsh
```bash
sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
```

### 3. Clone this repo
```bash
mkdir -p ~/GitHub && git clone https://github.com/BobHood/M5-MacBookPro-dotfiles.git ~/GitHub/M5-MacBookPro-dotfiles
```

### 4. Copy dotfiles into place
```bash
cd ~/GitHub/M5-MacBookPro-dotfiles

# Home directory files (~/)
cp home/.zshrc ~/.zshrc
cp home/Brewfile ~/Brewfile
cp home/Updater.sh ~/Updater.sh && chmod +x ~/Updater.sh
cp home/superbrew.sh ~/superbrew.sh && chmod +x ~/superbrew.sh

# Modular zsh config files (~/.config/Dotfiles/)
mkdir -p ~/.config/Dotfiles
cp config/Dotfiles/aliases.zsh ~/.config/Dotfiles/
cp config/Dotfiles/path.zsh ~/.config/Dotfiles/
cp config/Dotfiles/scripts.zsh ~/.config/Dotfiles/
cp config/Dotfiles/.tmux.conf ~/.config/Dotfiles/
cp config/Dotfiles/.vimrc ~/.config/Dotfiles/

# Git configuration (~/  )
cp config/Dotfiles/OSX-Git/.gitconfig ~/.gitconfig
cp config/Dotfiles/OSX-Git/.gitignore ~/.gitignore
cp config/Dotfiles/OSX-Git/.gitattributes ~/.gitattributes
```

### 5. Install all Homebrew packages
```bash
brew bundle install --file ~/Brewfile
```

### 6. Install Powerlevel10k
```bash
brew install powerlevel10k
```

### 7. Reload the shell
```bash
source ~/.zshrc
```

---

## 🎨 Shell Theme & Colors

The prompt uses **Powerlevel10k** with a custom configuration stored in `~/.p10k.zsh`.

fzf uses the **Catppuccin Mocha** color scheme:

![Catppuccin Mocha](https://img.shields.io/badge/Theme-Catppuccin_Mocha-cba6f7?style=for-the-badge&labelColor=1e1e2e)

---

## 📋 Notes

- **Apple Silicon** — All paths use `/opt/homebrew` (Apple Silicon Homebrew location)
- **Ruby** — Homebrew Ruby 4.0 is used instead of the macOS system Ruby 2.6
- **Python** — Homebrew Python 3.14 with unversioned `python`/`pip` symlinks enabled
- **zoxide** — initialized last in `.zshrc` so it correctly overrides all `cd` definitions
- **Amazon Q** — pre and post blocks must remain at the very top and bottom of `.zshrc`

---

## 📄 License

MIT — feel free to use, fork, and adapt for your own setup.

---

*Built and maintained by [BobHood](https://github.com/BobHood)*
