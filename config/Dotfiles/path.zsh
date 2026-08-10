#!/bin/zsh
########################################################################
####            Shell PATH Configuration — Unified/OS-aware         ####
########################################################################
# typeset -U ensures PATH contains no duplicate entries.
# Requires system_checks.sh to have run first (sets UCD_OS, UCD_PKG,
# UCD_BREW_PREFIX) — .zshrc sources it before this file.

typeset -U PATH path

# --- Portable, both OSes ---
export PATH="$PATH:$HOME:$HOME/Applications"
export PATH="$PATH:/usr/local/bin:/usr/local/sbin"
export PATH="$PATH:$HOME/.cargo/bin"      # Rust / Cargo binaries
export PATH="$PATH:$HOME/.local/bin"      # pip --user / pipx installs (both OSes)

# --- macOS / Homebrew only ---
if [[ "$UCD_OS" == "macos" && -n "$UCD_BREW_PREFIX" ]]; then
  export PATH="$PATH:$UCD_BREW_PREFIX/bin:$UCD_BREW_PREFIX/etc:$UCD_BREW_PREFIX/opt"
  export PATH="$PATH:$UCD_BREW_PREFIX/opt/openssl@3/bin"            # OpenSSL 3 (keg-only)
  export PATH="$PATH:$UCD_BREW_PREFIX/opt/ruby/bin"                 # Homebrew Ruby
  export PATH="$PATH:$UCD_BREW_PREFIX/opt/libtool/libexec/gnubin"   # GNU libtool binaries
  export PATH="$UCD_BREW_PREFIX/opt/icu4c@76/sbin:$PATH"
  export PATH="$UCD_BREW_PREFIX/opt/icu4c@76/bin:$PATH"
fi

# --- Linux / apt only ---
# apt-installed packages already land on the default system PATH, so there's
# no equivalent block of keg-only paths needed here — this section exists so
# future Linux-specific PATH additions (e.g. a locally-built tool under
# /opt/<something>) have an obvious home instead of getting bolted onto the
# "portable" section above.
if [[ "$UCD_OS" == "linux" ]]; then
  export PATH="$PATH:/snap/bin"   # harmless no-op if snap isn't in use
fi
