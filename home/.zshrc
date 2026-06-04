########################################################################
####              My Custom .zshrc for Mac OS X                      ####
####                    Last Updated: 2026                           ####
########################################################################
# This .zshrc initializes Oh My Zsh and Powerlevel10k, and sources
# modular config files (path, aliases, scripts) from ~/.config/Dotfiles/
#
# Source file layout:
#   ~/.config/Dotfiles/path.zsh      — PATH declarations
#   ~/.config/Dotfiles/aliases.zsh   — Shell aliases
#   ~/.config/Dotfiles/scripts.zsh   — Shell functions
#
# Key tools in use:
#   eza       — modern ls replacement (replaces exa)
#   bat       — modern cat replacement
#   fzf       — fuzzy finder (Ctrl+R, Ctrl+T, Alt+C)
#   zoxide    — smarter cd with frecency tracking (`cd` is remapped)
#   yazi      — terminal file manager (function: y)
#   atuin     — shell history sync & search
#   fastfetch — system info on shell start
#   code      — Visual Studio Code editor
#   zed       — Zed editor (alias: ze)

########################################################################
####              Amazon Q Pre-Block                                ####
####         (Must remain at the very top of this file)            ####
########################################################################
[[ -f "${HOME}/Library/Application Support/amazon-q/shell/zshrc.pre.zsh" ]] && \
  builtin source "${HOME}/Library/Application Support/amazon-q/shell/zshrc.pre.zsh"

########################################################################
####                   Powerlevel10k Instant Prompt                 ####
####    Must stay near the top — before any output or interaction   ####
########################################################################
# Set to 'off' because fastfetch intentionally prints to console at startup.
# 'quiet' still triggers the warning; 'off' disables instant prompt cleanly.
# Tradeoff: zsh starts ~100-200ms slower, but fastfetch displays without errors.
# If you ever remove fastfetch, change this back to 'quiet' for faster startup.
typeset -g POWERLEVEL9K_INSTANT_PROMPT=off

if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

########################################################################
####                        Oh My Zsh Setup                         ####
########################################################################
export ZSH="$HOME/.oh-my-zsh"

# ZSH_THEME is intentionally blank — Powerlevel10k is loaded manually
# below via its Homebrew path, which is the correct method for p10k.
ZSH_THEME=""

# Auto-update weekly without prompting
zstyle ':omz:update' mode auto
zstyle ':omz:update' frequency 7

# UX options
ENABLE_CORRECTION="true"             # Try to correct spelling of commands
COMPLETION_WAITING_DOTS="true"       # Show dots while waiting for completion
DISABLE_UNTRACKED_FILES_DIRTY="true" # Faster git status in large repos
ZSH_DISABLE_COMPFIX="true"           # Suppress compfix warnings (safe for personal machines)

########################################################################
####                    History Configuration                       ####
########################################################################
HISTFILE="$HOME/.zsh_history"        # History save file location
HISTSIZE=50000                       # In-session history size
SAVEHIST=50000                       # Persisted history size
HIST_STAMPS="yyyy-mm-dd"             # Timestamp format shown in history output

setopt EXTENDED_HISTORY              # Save timestamps with each history entry
setopt SHARE_HISTORY                 # Share history instantly across all sessions
setopt APPEND_HISTORY                # Append to history file rather than overwrite
setopt INC_APPEND_HISTORY            # Write to history file immediately after each command
setopt HIST_IGNORE_ALL_DUPS          # Don't store duplicate commands at all
setopt HIST_FIND_NO_DUPS             # No duplicates when searching history
setopt HIST_IGNORE_DUPS              # Don't store consecutive duplicate commands
setopt HIST_IGNORE_SPACE             # Don't store commands beginning with a space
setopt HIST_REDUCE_BLANKS            # Strip extra blanks from history entries
setopt HIST_VERIFY                   # Preview history expansions before executing
setopt HIST_EXPIRE_DUPS_FIRST        # Expire duplicates first when trimming history

########################################################################
####                         Zsh Options                            ####
########################################################################
setopt AUTO_CD                       # Type a directory name to cd into it
setopt INTERACTIVE_COMMENTS          # Allow # comments in interactive shell
setopt NO_BEEP                       # Silence all terminal bells
setopt NO_BG_NICE                    # Don't throttle background tasks
setopt HUP                           # Send HUP signal to jobs when shell exits
setopt LOCAL_OPTIONS                 # Allow functions to have local options
setopt LOCAL_TRAPS                   # Allow functions to have local traps
setopt PROMPT_SUBST                  # Enable parameter expansion in prompts
setopt CORRECT                       # Try to correct spelling of commands
setopt COMPLETE_IN_WORD              # Complete from both ends of a word

########################################################################
####        Homebrew: Completions FPATH                             ####
####   Must be set BEFORE oh-my-zsh.sh is sourced so that omz      ####
####   picks up the Homebrew completions when it runs compinit.     ####
########################################################################
if type brew &>/dev/null; then
  FPATH="$(brew --prefix)/share/zsh-completions:$(brew --prefix)/share/zsh/site-functions:$FPATH"
fi

########################################################################
####                       Oh My Zsh Plugins                        ####
########################################################################
# Standard plugins live in $ZSH/plugins/
# Custom plugins go in $ZSH_CUSTOM/plugins/
# Note: zsh-lux is loaded separately below with a guard, so it is NOT
# listed here — listing a missing plugin aborts compinit.

plugins=(
  # --- Navigation & Files ---
  copyfile           # `copyfile <path>` copies file contents to clipboard
  copypath           # `copypath` copies current directory path to clipboard
  dirhistory         # Alt+Left/Right to navigate directory history
  extract            # `extract <archive>` handles zip/tar/gz/7z/rar/etc.

  # --- Aliases & Commands ---
  aliases            # `als` to search aliases
  alias-finder       # Suggests aliases for commands you type in full
  common-aliases     # Useful common aliases (G, L, etc.)
  sudo               # Press Esc+Esc to prefix last/current command with sudo
  gnu-utils          # Use GNU coreutils versions where available

  # --- Display & Color ---
  colored-man-pages  # Colorized man pages

  # --- History ---
  history            # `h` = history, `hs <term>` = grep history

  # --- Shell Integration ---
  iterm2             # iTerm2 integration (tab titles, badges, etc.)
  dotenv             # Auto-source .env files when entering a directory
  macos              # macOS-specific aliases and utilities

  # --- Web & Search ---
  web-search         # `google <term>`, `ddg <term>`, etc.

  # --- Security & Auth ---
  1password          # 1Password CLI completions
  gpg-agent          # GPG agent management
  keychain           # SSH/GPG keychain integration

  # --- Git ---
  git                # Extensive git aliases (gst, gco, etc.)
  git-extras         # Extra git commands
  github             # GitHub helpers
  gitignore          # `gi <lang>` to generate .gitignore files

  # --- Languages & Runtimes ---
  pip                # pip completions
  python             # Python helpers
  ruby               # Ruby helpers
  jruby              # JRuby helpers
  rails              # Rails helpers
  node               # Node.js helpers

  # --- Tools ---
  aws                # AWS CLI completions
  docker             # Docker completions and aliases
  nmap               # nmap completions
  rust               # Rust/cargo completions
  xcode              # Xcode helpers
)

########################################################################
####                       Source Oh My Zsh                         ####
####   (Oh My Zsh runs compinit internally — do not run it again)  ####
########################################################################
source "$ZSH/oh-my-zsh.sh"

########################################################################
####        Homebrew: Syntax Highlighting & Autosuggestions         ####
####              (Must be sourced AFTER oh-my-zsh.sh)              ####
########################################################################
[[ -f /opt/homebrew/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh ]] && \
  source /opt/homebrew/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh

[[ -f /opt/homebrew/share/zsh-autosuggestions/zsh-autosuggestions.zsh ]] && \
  source /opt/homebrew/share/zsh-autosuggestions/zsh-autosuggestions.zsh

########################################################################
####   zsh-lux — Guarded Load (safe if plugin is not installed)    ####
########################################################################
# zsh-lux is loaded here rather than in the plugins array so that a
# missing install does not abort compinit and break the whole shell.
# To install: clone into $ZSH_CUSTOM/plugins/zsh-lux
_ZSH_LUX="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/zsh-lux/zsh-lux.plugin.zsh"
[[ -f "$_ZSH_LUX" ]] && source "$_ZSH_LUX"
# To install zsh-lux:
# git clone https://github.com/pndurette/zsh-lux ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-lux
unset _ZSH_LUX

########################################################################
####                          PATH Setup                            ####
########################################################################
# Core Homebrew and local bin paths — set early for availability.
# Full PATH is extended in ~/.config/Dotfiles/path.zsh
export PATH="/opt/homebrew/bin:/opt/homebrew/sbin:$HOME/.local/bin:$PATH"

########################################################################
####      Source Modular Config Files from ~/.config/Dotfiles/      ####
########################################################################
# Auto-sources path.zsh, aliases.zsh, and scripts.zsh.
# Any new .zsh file added to the Dotfiles directory is auto-loaded.
# Note: zoxide remaps `cd` below — the cd() override in aliases.zsh is
# intentionally superseded by zoxide. That is expected behaviour.

for FILE in "$HOME/.config/Dotfiles/"*.zsh; do
  [[ -r "$FILE" ]] && source "$FILE"
done
unset FILE

########################################################################
####                  Programming Configurations                    ####
########################################################################

# --- Python ---
# Homebrew installs python3/pip3 but not the unversioned python/pip by default.
# This adds the libexec/bin path which contains the unversioned symlinks.
export PATH="/opt/homebrew/opt/python@3.14/libexec/bin:$PATH"

# --- ImageMagick Full ---
# keg-only: not symlinked into /opt/homebrew — PATH must be set explicitly
export PATH="/opt/homebrew/opt/imagemagick-full/bin:$PATH"

# --- Ruby / OpenSSL / icu4c / ImageMagick Full ---
# All combined so no single set overrides another at compile time.
export PATH="/opt/homebrew/opt/ruby/bin:/opt/homebrew/lib/ruby/gems/4.0.0/bin:$PATH"
export LDFLAGS="-L/opt/homebrew/opt/ruby/lib -L/opt/homebrew/opt/openssl@3/lib -L/opt/homebrew/opt/icu4c@76/lib -L/opt/homebrew/opt/imagemagick-full/lib"
export CPPFLAGS="-I/opt/homebrew/opt/ruby/include -I/opt/homebrew/opt/openssl@3/include -I/opt/homebrew/opt/icu4c@76/include -I/opt/homebrew/opt/imagemagick-full/include"
export PKG_CONFIG_PATH="/opt/homebrew/opt/ruby/lib/pkgconfig:/opt/homebrew/opt/openssl@3/lib/pkgconfig:/opt/homebrew/opt/icu4c@76/lib/pkgconfig:/opt/homebrew/opt/imagemagick-full/lib/pkgconfig"

# --- Java (uncomment if needed) ---
# export PATH="/opt/homebrew/opt/openjdk/bin:$PATH"

########################################################################
####                    Environment Variables                       ####
########################################################################
export MANPATH="/usr/local/man:$MANPATH"     # Man page search path
export LANG="en_US.UTF-8"                    # Language environment
export LC_ALL="en_US.UTF-8"                  # Locale — all categories

# Preferred editor: nano over SSH, VS Code locally
if [[ -n $SSH_CONNECTION ]]; then
  export EDITOR='nano'
  export VISUAL='nano'
else
  export EDITOR='code'
  export VISUAL='code'
fi

########################################################################
####                    Colorization                                ####
####   bat handles syntax highlighting — colorize plugin removed.  ####
####   Use `bat <file>` in place of cat, ccat, or cless.           ####
########################################################################

########################################################################
####                  fzf — Fuzzy Finder Integration                ####
########################################################################
# Ctrl+R = fuzzy history | Ctrl+T = fuzzy file insert | Alt+C = fuzzy cd

if command -v fzf &>/dev/null; then
  source <(fzf --zsh)
elif [[ -f ~/.fzf.zsh ]]; then
  source ~/.fzf.zsh
elif test -d /opt/homebrew/opt/fzf/shell; then
  source /opt/homebrew/opt/fzf/shell/key-bindings.zsh
else
  bindkey '^R' history-incremental-search-backward
fi

# fzf appearance — Catppuccin Mocha color scheme
export FZF_DEFAULT_OPTS="
  --height=50%
  --layout=reverse
  --border=rounded
  --preview-window=wrap
  --color=bg+:#313244,bg:#1e1e2e,spinner:#f5e0dc,hl:#f38ba8
  --color=fg:#cdd6f4,header:#f38ba8,info:#cba6f7,pointer:#f5e0dc
  --color=marker:#b4befe,fg+:#cdd6f4,prompt:#cba6f7,hl+:#f38ba8
"
export FZF_CTRL_T_OPTS="--preview 'bat --color=always {}' --preview-window=right:60%"
export FZF_ALT_C_OPTS="--preview 'eza -lAh {}'"

########################################################################
####               zoxide — Smarter cd with Frecency                ####
########################################################################
# `cd <partial>` jumps to the highest-frecency match
# `cdi` launches an interactive picker
eval "$(zoxide init zsh --cmd cd)"

########################################################################
####                   1Password Shell Completion                   ####
########################################################################
# Wrapped in a guard so compdef doesn't error if compinit didn't finish
if command -v op &>/dev/null; then
  eval "$(op completion zsh)" 2>/dev/null
  if (( $+functions[compdef] )); then
    compdef _op op
  fi
fi

########################################################################
####                  iTerm2 Shell Integration                      ####
########################################################################
test -e "${HOME}/.iterm2_shell_integration.zsh" && \
  source "${HOME}/.iterm2_shell_integration.zsh"

########################################################################
####                  Atuin — Shell History Sync                    ####
########################################################################
if command -v atuin &>/dev/null; then
  eval "$(atuin init zsh)"
fi

########################################################################
####             Fastfetch — System Info at Shell Start             ####
########################################################################
if command -v fastfetch &>/dev/null; then
  fastfetch
fi

########################################################################
####                     Powerlevel10k Theme                        ####
########################################################################
# Sourced from Homebrew install path — correct for Apple Silicon Macs.
source /opt/homebrew/share/powerlevel10k/powerlevel10k.zsh-theme
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh

########################################################################
####                Amazon Q Post-Block                             ####
####          (Must remain at the very bottom of this file)         ####
########################################################################
[[ -f "${HOME}/Library/Application Support/amazon-q/shell/zshrc.post.zsh" ]] && \
  builtin source "${HOME}/Library/Application Support/amazon-q/shell/zshrc.post.zsh"
