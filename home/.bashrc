########################################################################
####     Unified CommandLineInterface Dotfiles — bash fallback      ####
####  Deliberately minimal. zsh (.zshrc) is the primary, fully-     ####
####  featured shell everywhere it's installed. This exists for the ####
####  moments bash is what's actually running: a fresh box before   ####
####  `chsh -s $(which zsh)`, a root/rescue shell, or a script that  ####
####  explicitly invokes bash.                                      ####
########################################################################

# --- SystemChecks — same detection module .zshrc uses ---
[[ -f "$HOME/.config/Dotfiles/system_checks.sh" ]] && \
  source "$HOME/.config/Dotfiles/system_checks.sh"

# --- History (same intent as the zsh HIST_* options, bash equivalents) ---
export HISTFILE="$HOME/.bash_history"
export HISTSIZE=50000
export HISTFILESIZE=50000
shopt -s histappend
export HISTCONTROL=ignoredups:erasedups
export HISTTIMEFORMAT="%F %T "

# --- Sane bash options ---
shopt -s autocd 2>/dev/null       # bash 4+: type a dir name to cd into it
shopt -s cdspell 2>/dev/null      # minor cd typo correction
shopt -s checkwinsize             # update LINES/COLUMNS after resize

# --- Editor: nano everywhere bash is the fallback shell ---
export EDITOR='nano'
export VISUAL='nano'

# --- Minimal, informative prompt (host, cwd, git branch if in a repo) ---
# Not Powerlevel10k — that's zsh-only. This just avoids a bare "$" with zero
# context, which is the actual problem, not full prompt parity.
__ucd_git_branch() {
  git branch --show-current 2>/dev/null | sed 's/^/ (/;s/$/)/'
}
if [[ "$UCD_IS_SSH" == "1" ]]; then
  PS1='\[\e[33m\]\u@\h\[\e[0m\]:\[\e[36m\]\w\[\e[32m\]$(__ucd_git_branch)\[\e[0m\]\$ '
else
  PS1='\[\e[36m\]\w\[\e[32m\]$(__ucd_git_branch)\[\e[0m\]\$ '
fi

# --- Same modular-config pattern .zshrc uses, minus anything zsh-only ---
# aliases.zsh entries that are plain POSIX/bash-compatible get sourced here
# too. Anything using zsh-only syntax (e.g. `setopt`, `zstyle`) will error in
# bash — keep genuinely shared aliases POSIX-safe, or split a bash-safe subset
# into its own file if that becomes necessary.
for _ucd_file in "$HOME/.config/Dotfiles/"*.sh; do
  [[ -r "$_ucd_file" ]] && source "$_ucd_file"
done
unset _ucd_file

# --- Common aliases (kept here directly rather than relying on aliases.zsh,
# since that file is likely to contain zsh-specific syntax over time) ---
alias ll='ls -lah'
alias ..='cd ..'
alias ...='cd ../..'
if [[ "$UCD_HAS_EZA" == "1" ]]; then
  alias ls='eza'
  alias ll='eza -lah'
fi
if [[ "$UCD_HAS_BAT" == "1" ]]; then
  alias cat='bat'
fi

echo "[bash fallback shell — zsh not active. Run 'zsh' or fix chsh if this is unexpected.]"
