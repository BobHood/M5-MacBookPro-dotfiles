#!/bin/zsh
########################################################################
####                   Shell PATH Configuration                     ####
########################################################################
# typeset -U ensures PATH contains no duplicate entries.
# The shell keeps only the left-most occurrence, so prepending a path
# moves it to the front without leaving a stale copy further back.
# Run `typeset +U` to list all variables with uniqueness enforced.

typeset -U PATH path                                                    # Deduplicate PATH entries automatically

export PATH="$PATH:$HOME:$HOME/Applications"                           # Home dir and ~/Applications
export PATH="$PATH:/usr/local/bin:/usr/local/sbin"                     # Standard system tool locations
export PATH="$PATH:$HOME/.cargo/bin"                                   # Rust / Cargo binaries
export PATH="$PATH:/opt/homebrew/bin:/opt/homebrew/etc:/opt/homebrew/opt"  # Homebrew core paths
export PATH="$PATH:/opt/homebrew/opt/openssl@3/bin"                    # OpenSSL 3 (keg-only, not auto-linked)
export PATH="$PATH:/opt/homebrew/opt/ruby/bin"                         # Homebrew Ruby (overrides macOS system Ruby)
export PATH="$PATH:/opt/homebrew/opt/libtool/libexec/gnubin"           # GNU libtool binaries
export PATH="/opt/homebrew/opt/icu4c@76/sbin:$PATH"                    # ICU 4.76 system binaries (prepended for priority)
export PATH="/opt/homebrew/opt/icu4c@76/bin:$PATH"                     # ICU 4.76 user binaries (prepended for priority)
