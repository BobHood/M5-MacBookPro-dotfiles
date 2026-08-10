#!/bin/zsh
########################################################################
####       .zsh Shell Alias Definitions — Unified/OS-aware          ####
########################################################################
# Requires system_checks.sh to have run first (UCD_OS, UCD_PKG, UCD_HAS_*).
# Structure: portable aliases first, then a macOS-only block, then a
# Linux-only block for the equivalents. To see all active aliases: alias

########################################################################
####                 Change Directory Aliases (portable)            ####
########################################################################
alias cd..='cd ../'
alias ..='cd ../'
alias ...='cd ../../'
alias .3='cd ../../../'
alias .4='cd ../../../../'
alias .5='cd ../../../../../'
alias .6='cd ../../../../../../'
if [[ "$UCD_HAS_EZA" == "1" ]]; then
  cd() { builtin cd "$@"; eza -lh; }
else
  cd() { builtin cd "$@"; ls -lh; }
fi

########################################################################
####       Directory Listing (eza if present, plain ls fallback)    ####
########################################################################
if [[ "$UCD_HAS_EZA" == "1" ]]; then
  alias ls="eza"
  alias ll="eza -lh"
  alias la="eza -lah"
  alias tree="eza --tree"
  alias lt="eza -lAGht"
else
  alias ll="ls -lh"
  alias la="ls -lah"
  # tree: leave as the real `tree` command if installed; don't alias over it
  # with something broken when eza is absent.
fi
alias lr='ls -R | grep ":$" | sed -e '\''s/:$//'\'' -e '\''s/[^-][^\/]*\//--/g'\'' -e '\''s/^/   /'\'' -e '\''s/-/|/'\'' | less'

########################################################################
####            Direct Directory Navigation (portable)              ####
########################################################################
alias ~="cd ~"
alias dload="cd ~/Downloads"
alias dt="cd ~/Desktop"
alias sshdir="cd ~/.ssh"

########################################################################
####                Command Shortcuts (portable)                    ####
########################################################################
if [[ "$UCD_HAS_BAT" == "1" ]]; then
  alias cat='bat'
  alias ccat='bat'
  alias cless='bat --paging=always'
fi
alias cp='cp -iv'
alias mv='mv -iv'
alias mkdir='mkdir -pv'
alias md="mkdir"
alias less='less -FSRXc'
alias which='type -a'
alias path='echo -e ${PATH//:/\\n}'
alias fix_stty='stty sane'
alias cls=clear
alias h="history"
alias j="jobs"
alias grep='grep --color=auto'
alias egrep='egrep --color=auto'
alias fgrep='fgrep --color=auto'
alias dirs='dirs -v | head -10'
alias usage='du -h -d1'
alias runp="lsof -i"
alias sudo='sudo '   # allow aliases to work after sudo
command -v grunt > /dev/null && alias grunt="grunt --stack"
mcd()  { mkdir -p "$1" && cd "$1"; }

########################################################################
####  Same-name, cross-platform functions (identical behavior on     ####
####  either OS, different implementation under the hood — this is   ####
####  the pattern to extend when adding more unified aliases)        ####
########################################################################

# trash: move file(s) to the OS trash instead of permanently deleting
trash() {
  if [[ "$UCD_OS" == "macos" ]]; then
    command mv "$@" ~/.Trash
  elif command -v gio &>/dev/null; then
    gio trash "$@"
  else
    # Freedesktop trash spec fallback — no gio available (minimal/headless box)
    local trash_dir="$HOME/.local/share/Trash/files"
    mkdir -p "$trash_dir"
    command mv "$@" "$trash_dir"
    echo "Moved to $trash_dir (no gio/trash-cli found — install trash-cli for full freedesktop trash support)"
  fi
}

# ips: list all local IP addresses
ips() {
  if [[ "$UCD_OS" == "macos" ]]; then
    ifconfig -a | grep -o 'inet6\? \(\([0-9]\+\.[0-9]\+\.[0-9]\+\.[0-9]\+\)\|[a-fA-F0-9:]\+\)' | sed -e 's/inet6* //'
  else
    ip -4 -o addr show scope global | awk '{print $4}'
    ip -6 -o addr show scope global | awk '{print $4}'
  fi
}

# openPorts: list listening ports
openPorts() {
  if [[ "$UCD_OS" == "macos" ]]; then
    sudo lsof -i | grep LISTEN
  else
    sudo ss -tulnp
  fi
}

# lsockU / lsockT: open UDP / TCP sockets only
lsockU() {
  if [[ "$UCD_OS" == "macos" ]]; then sudo /usr/sbin/lsof -nP | grep UDP
  else sudo ss -u -a -n -p
  fi
}
lsockT() {
  if [[ "$UCD_OS" == "macos" ]]; then sudo /usr/sbin/lsof -nP | grep TCP
  else sudo ss -t -a -n -p
  fi
}

# lumos / nox: switch to light / dark mode
lumos() {
  if [[ "$UCD_OS" == "macos" ]] && command -v lux &>/dev/null; then
    lux all light
  elif command -v gsettings &>/dev/null; then
    gsettings set org.gnome.desktop.interface color-scheme 'prefer-light'
  else
    echo "lumos: no supported light/dark switcher found (lux on macOS, gsettings/GNOME on Linux)" >&2; return 1
  fi
}
nox() {
  if [[ "$UCD_OS" == "macos" ]] && command -v lux &>/dev/null; then
    lux all dark
  elif command -v gsettings &>/dev/null; then
    gsettings set org.gnome.desktop.interface color-scheme 'prefer-dark'
  else
    echo "nox: no supported light/dark switcher found (lux on macOS, gsettings/GNOME on Linux)" >&2; return 1
  fi
}

# showBlocked: show firewall-blocked rules
showBlocked() {
  if [[ "$UCD_OS" == "macos" ]]; then
    sudo ipfw list 2>/dev/null || echo "showBlocked: ipfw not available on this macOS version (removed in modern macOS — check pfctl instead)" >&2
  elif command -v ufw &>/dev/null; then
    sudo ufw status verbose
  else
    sudo iptables -L -n
  fi
}

# mount: -t column only useful with plain `mount` output format; portable
alias mount='mount | column -t'

########################################################################
####          Config Editing Aliases (editor-presence-aware)        ####
########################################################################
if command -v code &>/dev/null; then
  alias zshrc='code ~/.zshrc'
  alias zshconf='code ~/.zshrc'
  alias ohmyzsh='code ~/.oh-my-zsh'
  alias dotfiles='code ~/.config/Dotfiles'
  alias c="code ."
else
  alias zshrc="${EDITOR:-nano} ~/.zshrc"
  alias zshconf="${EDITOR:-nano} ~/.zshrc"
  alias ohmyzsh="${EDITOR:-nano} ~/.oh-my-zsh"
  alias dotfiles="${EDITOR:-nano} ~/.config/Dotfiles"
fi
command -v zed &>/dev/null && alias ze="zed ."

########################################################################
####                Session Management (portable)                   ####
########################################################################
alias update="source ~/.zshrc"
alias reload="source ~/.zshrc && echo 'Shell reloaded.'"
alias topten="history | awk '{a[\$2]++}END{for(i in a){print a[i] \" \" i}}' | sort -rn | head"

########################################################################
####                    Networking (portable core)                  ####
########################################################################
alias myip='curl http://ipecho.net/plain; echo'
alias pubip="curl -s https://ipinfo.io/ip"
alias netCons='lsof -i'
alias whois="whois -h whois-servers.net"

########################################################################
####               Fallback Utility Aliases (portable)              ####
########################################################################
# macOS doesn't ship md5sum/sha1sum/hd — these guards only fire where the
# native GNU tool is actually missing, so they're already safe on Linux
# (where md5sum/sha1sum/hd exist natively and these become silent no-ops).
command -v md5sum  > /dev/null || alias md5sum="md5"
command -v sha1sum > /dev/null || alias sha1sum="shasum"
command -v hd > /dev/null || alias hd="hexdump -C"

########################################################################
####                    Git Aliases (portable)                      ####
########################################################################
function gc { git commit -m "$@"; }
alias gchm="git checkout master"
alias gs="git status"
alias gpull="git pull"
alias gf="git fetch"
alias gfa="git fetch --all"
alias gfo="git fetch origin"
alias gpush="git push"
alias gd="git diff"
alias ga="git add ."
alias gb="git branch"
alias gbr="git branch remote"
alias gru="git remote update"
alias gbn="git checkout -B"
alias grf="git reflog"
alias grh="git reset HEAD~"
alias gac="git add . && git commit -a -m"
alias gsu="git push --set-upstream origin"
alias glog="git log --color --graph --pretty=format:'%Cred%h%Creset -%C(yellow)%d%Creset %s %Cgreen(%cr) %C(bold blue)<%an>%Creset' --abbrev-commit --branches"

########################################################################
####              Process Management (mostly portable)              ####
########################################################################
# `top`'s flags differ meaningfully between BSD (macOS) and Linux `top` —
# not worth reconciling, since `top` is interactive and rarely scripted.
if [[ "$UCD_OS" == "macos" ]]; then
  alias memHogsTop='top -l 1 -o rsize | head -20'
  alias topForever='top -l 9999999 -s 10 -o cpu'
  alias ttop="top -R -F -s 10 -o rsize"
else
  alias memHogsTop='top -b -n 1 -o %MEM | head -20'
  alias topForever='top -b -d 10'
  alias ttop="top"
fi
alias memHogsPs='ps wwaxm -o pid,stat,vsize,rss,time,command | head -10'
alias cpu_hogs='ps wwaxr -o pid,stat,%cpu,time,command | head -10'

########################################################################
####                  Python Aliases (portable)                     ####
########################################################################
alias python="python3"
alias pip="pip3"
alias venv="python3 -m venv .venv && source .venv/bin/activate"
alias activate="source .venv/bin/activate"

########################################################################
####                  Docker Aliases (portable)                     ####
########################################################################
if command -v docker &>/dev/null; then
  alias dps='docker ps --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}"'
  alias dpa='docker ps -a --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}"'
  alias dclean="docker system prune -f"
  alias dlogs="docker logs -f"
fi

########################################################################
####                  Date/Time Utilities (portable)                ####
########################################################################
alias week="date +%V"
alias timestamp="date -u +%Y-%m-%dT%H:%M:%SZ"

########################################################################
########################################################################
####                      macOS-ONLY BLOCK                          ####
########################################################################
########################################################################
if [[ "$UCD_OS" == "macos" ]]; then

  alias drop="cd ~/Dropbox"
  alias gdrive="cd ~/Google\ Drive"
  alias f='open -a Finder ./'
  ql()   { qlmanage -p "$*" >& /dev/null; }
  alias DT='tee ~/Desktop/terminalOut.txt'
  alias -s {txt,md,yaml,yml}="code"
  alias pg="echo 'Pinging Google' && ping www.google.com"

  # --- Clipboard (macOS Pasteboard) ---
  alias -g 2clip='| pbcopy'
  alias -g clip2='pbpaste |'

  # --- Networking (macOS-specific tools) ---
  # ips, openPorts, lsockU, lsockT, lumos, nox, showBlocked, trash are now
  # unified functions defined in the portable section above — not redefined
  # here, so the same name works identically on either OS.
  alias localip="ipconfig getifaddr en0"
  alias lsock='sudo /usr/sbin/lsof -i -P'
  alias ipInfo0='ipconfig getpacket en0'
  alias ipInfo1='ipconfig getpacket en1'
  alias ip="ipconfig getifaddr en0"

  # --- DNS ---
  alias flushdns="sudo dscacheutil -flushcache; sudo killall -HUP mDNSResponder"
  alias flushDNS='dscacheutil -flushcache'
  alias flush="dscacheutil -flushcache && killall -HUP mDNSResponder"

  # --- Finder / Spotlight / System defaults ---
  alias showFiles='defaults write com.apple.finder AppleShowAllFiles YES; killall Finder'
  alias hideFiles='defaults write com.apple.finder AppleShowAllFiles NO; killall Finder'
  alias showhidden="defaults write com.apple.finder AppleShowAllFiles -bool true && killall Finder"
  alias hidehidden="defaults write com.apple.finder AppleShowAllFiles -bool false && killall Finder"
  alias hidedesktop="defaults write com.apple.finder CreateDesktop -bool false && killall Finder"
  alias showdesktop="defaults write com.apple.finder CreateDesktop -bool true && killall Finder"
  alias deleteDSFiles="find . -name '.DS_Store' -type f -delete"
  alias cleanup="find . -type f -name '*.DS_Store' -ls -delete"
  alias cleanupLS="/System/Library/Frameworks/CoreServices.framework/Frameworks/LaunchServices.framework/Support/lsregister -kill -r -domain local -domain system -domain user && killall Finder"
  alias lscleanup="/System/Library/Frameworks/CoreServices.framework/Frameworks/LaunchServices.framework/Support/lsregister -kill -r -domain local -domain system -domain user && killall Finder"
  alias emptytrash="sudo rm -rfv /Volumes/*/.Trashes; sudo rm -rfv ~/.Trash; sudo rm -rfv /private/var/log/asl/*.asl"
  alias ScreensaverDesktop='/System/Library/Frameworks/ScreenSaver.framework/Resources/ScreenSaverEngine.app/Contents/MacOS/ScreenSaverEngine -background'
  alias mergepdf='/System/Library/Automator/Combine\ PDF\ Pages.action/Contents/Resources/join.py'
  alias afk="/System/Library/CoreServices/Menu\ Extras/User.menu/Contents/Resources/CGSession -suspend"
  alias spotoff="sudo mdutil -a -i off"
  alias spoton="sudo mdutil -a -i on"
  alias sleepnow="pmset sleepnow"

  # lumos/nox are unified functions (portable section above) — not redefined here.

  # --- Homebrew ---
  alias -g BrewMe="brew update && brew upgrade"
  alias -g BrewGreedy="brew update && brew upgrade --greedy --verbose"
  alias brewup="brew update && brew upgrade && brew cleanup -q"
  alias brewinfo="brew leaves | xargs brew desc --eval-all"
  alias osupdate='sudo softwareupdate -i -a; brew update; brew upgrade; brew cleanup; sudo gem update'

fi

########################################################################
########################################################################
####                      LINUX-ONLY BLOCK                          ####
########################################################################
########################################################################
if [[ "$UCD_OS" == "linux" ]]; then

  # --- Clipboard: xclip/xsel if present, else a clear error instead of a
  # silent failure (headless boxes like macpro-llm have no clipboard at all,
  # which is expected — this just makes that obvious if invoked). ---
  if command -v xclip &>/dev/null; then
    alias -g 2clip='| xclip -selection clipboard'
    alias -g clip2='xclip -selection clipboard -o |'
  elif command -v xsel &>/dev/null; then
    alias -g 2clip='| xsel --clipboard --input'
    alias -g clip2='xsel --clipboard --output |'
  else
    alias -g 2clip='| { echo "No clipboard tool installed (xclip/xsel). On headless boxes this is expected." >&2; cat; }'
  fi

  # --- Networking ---
  alias localip="hostname -I | awk '{print \$1}'"
  alias ip_addr="hostname -I"   # named ip_addr, not ip — `ip` is the real Linux networking command
  command -v ss &>/dev/null && alias lsock="sudo ss -tulnp" || alias lsock="sudo lsof -i -P"

  # --- DNS flush (systemd-resolved, the common case on Ubuntu 26.04) ---
  if command -v resolvectl &>/dev/null; then
    alias flushdns="sudo resolvectl flush-caches"
    alias flush="sudo resolvectl flush-caches"
  elif command -v systemd-resolve &>/dev/null; then
    alias flushdns="sudo systemd-resolve --flush-caches"
    alias flush="sudo systemd-resolve --flush-caches"
  fi

  # --- Power ---
  command -v systemctl &>/dev/null && alias sleepnow="systemctl suspend"

  # --- Package manager (apt) ---
  if [[ "$UCD_PKG" == "apt" ]]; then
    alias -g AptMe="sudo apt update && sudo apt upgrade"
    alias -g AptGreedy="sudo apt update && sudo apt full-upgrade -y && sudo apt autoremove -y"
    alias aptup="sudo apt update && sudo apt upgrade -y && sudo apt autoremove -y"
    alias aptinfo="apt list --installed"
  fi

fi
