#!/bin/sh
# system_checks.sh — Unified CommandLineInterface Dotfiles (SystemChecks built in)
#
# POSIX-compatible detection module. Sourced first by BOTH .zshrc and .bashrc,
# before anything else, so every later block can branch on these flags instead
# of re-detecting OS/shell/tool-availability itself with scattered ad hoc
# `if type brew` / `[[ -f ... ]]` checks.
#
# Written in plain POSIX sh syntax (no [[ ]], no zsh-only constructs) so it's
# safe to `source`/`.` from either a zsh or a bash startup file without error.
#
# Exports (all UCD_ prefixed — "Unified CommandLineInterface Dotfiles"):
#   UCD_OS          "macos" | "linux" | "unknown"
#   UCD_PKG         "brew"  | "apt"   | "unknown"   (primary package manager)
#   UCD_SHELL       "zsh"   | "bash"  | "other"     (currently running shell)
#   UCD_IS_SSH      "1" if this is an SSH session, "0" otherwise
#   UCD_HOSTNAME    short hostname, for prompt/host-aware logic
#   UCD_HAS_*        "1"/"0" for each optional tool this dotfiles setup uses

# --- OS detection ---
case "$(uname -s)" in
  Darwin) UCD_OS="macos" ;;
  Linux)  UCD_OS="linux" ;;
  *)      UCD_OS="unknown" ;;
esac
export UCD_OS

# --- Package manager detection ---
if command -v brew >/dev/null 2>&1; then
  UCD_PKG="brew"
elif command -v apt >/dev/null 2>&1 || command -v apt-get >/dev/null 2>&1; then
  UCD_PKG="apt"
else
  UCD_PKG="unknown"
fi
export UCD_PKG

# --- Shell detection ---
# $ZSH_VERSION / $BASH_VERSION are set by the shell itself, not the OS —
# reliable even if invoked via `sh -c` from the other shell.
if [ -n "$ZSH_VERSION" ]; then
  UCD_SHELL="zsh"
elif [ -n "$BASH_VERSION" ]; then
  UCD_SHELL="bash"
else
  UCD_SHELL="other"
fi
export UCD_SHELL

# --- SSH detection ---
if [ -n "$SSH_CONNECTION" ] || [ -n "$SSH_TTY" ] || [ -n "$SSH_CLIENT" ]; then
  UCD_IS_SSH="1"
else
  UCD_IS_SSH="0"
fi
export UCD_IS_SSH

# --- Hostname (short form, no domain) ---
UCD_HOSTNAME="$(hostname -s 2>/dev/null || hostname 2>/dev/null || echo unknown)"
export UCD_HOSTNAME

# --- Optional tool availability ---
# Add new tools here as the dotfiles grow to depend on more of them —
# one place to check, instead of re-testing `command -v X` in every module.
for _ucd_tool in brew fzf zoxide eza bat yazi atuin fastfetch tmux nvim vim nano op gh git tesseract python3; do
  _ucd_var="UCD_HAS_$(echo "$_ucd_tool" | tr '[:lower:]' '[:upper:]' | tr '-' '_')"
  if command -v "$_ucd_tool" >/dev/null 2>&1; then
    eval "export $_ucd_var=1"
  else
    eval "export $_ucd_var=0"
  fi
done
unset _ucd_tool _ucd_var

# --- Homebrew prefix (Apple Silicon vs Intel vs none) ---
if [ "$UCD_PKG" = "brew" ]; then
  UCD_BREW_PREFIX="$(brew --prefix 2>/dev/null)"
else
  UCD_BREW_PREFIX=""
fi
export UCD_BREW_PREFIX

# --- oh-my-zsh custom dir (works whether ZSH_CUSTOM is already set or not) ---
UCD_ZSH_CUSTOM="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}"
export UCD_ZSH_CUSTOM

# Uncomment to debug what this detected on a given box:
# echo "UCD_OS=$UCD_OS UCD_PKG=$UCD_PKG UCD_SHELL=$UCD_SHELL UCD_IS_SSH=$UCD_IS_SSH UCD_HOSTNAME=$UCD_HOSTNAME"
