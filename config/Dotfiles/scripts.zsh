#!/bin/zsh
########################################################################
####      Custom Zsh Shell Functions — Unified/OS-aware             ####
########################################################################
# Functions using macOS-only tech (osascript/AppleScript, Finder, Spotlight,
# airport) print a clear message and return instead of a bare
# "command not found" when called on Linux. Functions with no OS-specific
# dependency are left exactly as they were — most of this file already was
# portable POSIX/GNU-ish shell.

_ucd_macos_only() {
  echo "$1: macOS-only (uses $2) — not available on this box ($UCD_OS)." >&2
  return 1
}

########################################################################
####            Apple App Integration (macOS-only)                  ####
########################################################################

# note: Add a note to Notes.app
function note() {
  if [[ "$UCD_OS" != "macos" ]]; then
    _ucd_macos_only "note" "Notes.app/osascript"; return 1
  fi
  local title body
  if [ -t 0 ]; then
    title="$1"; body="$2"
  else
    title=$(cat)
  fi
  osascript >/dev/null <<EOF
tell application "Notes"
        tell account "iCloud"
                tell folder "Notes"
                        make new note with properties {name:"$title", body:"$title" & "<br><br>" & "$body"}
                end tell
        end tell
end tell
EOF
}

# remind: Add a reminder to Reminders.app
function remind() {
  if [[ "$UCD_OS" != "macos" ]]; then
    _ucd_macos_only "remind" "Reminders.app/osascript"; return 1
  fi
  local text
  if [ -t 0 ]; then text="$1"; else text=$(cat); fi
  osascript >/dev/null <<EOF
tell application "Reminders"
        tell the default list
                make new reminder with properties {name:"$text"}
        end tell
end tell
EOF
}

########################################################################
####                Shell Utilities (portable)                      ####
########################################################################

# lman: Open the man page for the previously run command
function lman () {
    set -- $(fc -nl -1); while [ "$#" -gt 0 -a '(' "sudo" = "$1" -o "-" = "${1:0:1}" ')' ]; do shift; done; man "$1" || help "$1";
}

########################################################################
####                 Finder Integration (macOS-only)                ####
########################################################################

# show: Reveal one or more files/directories in the Finder
function show {
  if [[ "$UCD_OS" != "macos" ]]; then
    _ucd_macos_only "show" "Finder/osascript"; return 1
  fi
        [ $# -eq 0 ] && set -- .;
        local path paths=();
        for path; do
                if ! [ -e "$path" ]; then
                        echo "show: $path: No such file or directory";
                        continue;
                fi;
                [ -d "$path" ] \
                        && path="$(cd "$path" > /dev/null && pwd)" \
                        || path="$(cd "$(dirname "$path")" > /dev/null && \
                         echo "$PWD/$(basename "$path")")";
                paths+=("POSIX file \"${path//\"/\"}\"");
        done;
        [ "${#paths[@]}" -eq 0 ] && return;
        {
                echo 'tell application "Finder"';
                echo -n 'select {';
                for ((i = 0; i < ${#paths[@]}; i++)); do
                        echo -n "${paths[$i]}";
                        [ $i -lt $(($# - 1)) ] && echo -n ', ';
                done;
                echo '}';
                echo 'activate';
                echo 'end tell';
        } | osascript;
}

# cdf: cd into the directory open in the frontmost Finder window
function cdf() {
  if [[ "$UCD_OS" != "macos" ]]; then
    _ucd_macos_only "cdf" "Finder/osascript"; return 1
  fi
  cd "$(osascript -e 'tell app "Finder" to POSIX path of (insertion location as alias)')"
}

########################################################################
####                Encoding Utilities (portable)                   ####
########################################################################

# b64: Base64 encode or decode a string. Prefers the standard `base64`
# command (present on both macOS and Linux) — falls back to php only if
# base64 itself is somehow missing.
function b64 {
    if [ $# -eq 0 ]; then
        echo 'Usage: b64 [encode|decode] <string>'; return
    elif [ "$1" = 'decode' ]; then action='decode'; shift
    elif [ "$1" = 'encode' ]; then action='encode'; shift
    else action='decode'
    fi
    if command -v base64 &>/dev/null; then
        if [[ "$action" == "encode" ]]; then
            echo -n "$@" | base64
        else
            echo -n "$@" | base64 --decode 2>/dev/null || echo -n "$@" | base64 -D
        fi
    elif command -v php &>/dev/null; then
        echo "$@" | php -r "echo base64_$action(file_get_contents('php://stdin'));"
    else
        echo "b64: neither base64 nor php available" >&2; return 1
    fi
    echo
}

########################################################################
####          Directory & Archive Utilities (portable)              ####
########################################################################

function deletefiles() {
    local q="${1:-*.DS_Store}"
    find . -type f -name "$q" -ls -delete
}

function extract () {
    if [ -f "$1" ] ; then
      case "$1" in
        *.tar.bz2)   tar xjf "$1"     ;;
        *.tar.gz)    tar xzf "$1"     ;;
        *.bz2)       bunzip2 "$1"     ;;
        *.rar)       unrar e "$1"     ;;
        *.gz)        gunzip "$1"      ;;
        *.tar)       tar xf "$1"      ;;
        *.tbz2)      tar xjf "$1"     ;;
        *.tgz)       tar xzf "$1"     ;;
        *.zip)       unzip "$1"       ;;
        *.Z)         uncompress "$1"  ;;
        *.7z)        7z x "$1"        ;;
        *)     echo "'$1' cannot be extracted via extract()" ;;
      esac
    else
        echo "'$1' is not a valid file"
    fi
}

function mkd() { mkdir -p "$@" && cd "$@"; }
function mkcd() { mkdir -p "$@" && cd "$_"; }

# targz: already portable — tries BSD `stat -f` (macOS) then GNU `stat -c`
# (Linux) in sequence, no changes needed.
function targz() {
        local tmpFile="${@%/}.tar"
        tar -cvf "${tmpFile}" --exclude=".DS_Store" "${@}" || return 1
        size=$(
                stat -f"%z" "${tmpFile}" 2> /dev/null
                stat -c"%s" "${tmpFile}" 2> /dev/null
        )
        local cmd=""
        if (( size < 52428800 )) && hash zopfli 2> /dev/null; then
                cmd="zopfli"
        else
                if hash pigz 2> /dev/null; then cmd="pigz"; else cmd="gzip"; fi
        fi
        echo "Compressing .tar using \`${cmd}\`…"
        "${cmd}" -v "${tmpFile}" || return 1
        [ -f "${tmpFile}" ] && rm "${tmpFile}"
        echo "${tmpFile}.gz created successfully."
}

########################################################################
####                  Disk Utilities (portable)                     ####
########################################################################

function fs() {
        if du -b /dev/null > /dev/null 2>&1; then local arg=-sbh; else local arg=-sh; fi
        if [[ -n "$@" ]]; then du $arg -- "$@"; else du $arg .[^.]* *; fi
}

hash git &>/dev/null
if [ $? -eq 0 ]; then
        function diff() { git diff --no-index --color-words "$@"; }
fi

function duh {
        du -sk "$@" | sort -n | while read size fname; do
                for unit in KiB MiB GiB TiB PiB EiB ZiB YiB; do
                        if [ "$size" -lt 1024 ]; then echo -e "${size} ${unit}\t${fname}"; break; fi;
                        size=$((size/1024));
                done;
        done;
}

########################################################################
####              Search Utilities (macOS-only: Spotlight)          ####
########################################################################

spotlight () {
  if [[ "$UCD_OS" != "macos" ]]; then
    echo "spotlight: macOS-only (mdfind). Try: find / -iname '*\$1*' 2>/dev/null" >&2; return 1
  fi
  mdfind "kMDItemDisplayName == '$@'wc"
}

########################################################################
####          Process Management & System Info (portable)           ####
########################################################################

findPid () { lsof -t -c "$@" ; }
my_ps() { ps $@ -u $USER -o pid,%cpu,%mem,start,time,bsdtime,command ; }

########################################################################
####            File & Directory Utilities (portable)               ####
########################################################################

function ff() { find -L "." -type f -name "*$1*"; }
function cf() {
    if [[ -n "$1" ]]; then find -L "$1" -type f | wc -l
    else find -L "." -type f | wc -l
    fi
}

########################################################################
####                Security Utilities (portable)                   ####
########################################################################

function passgen() {
    echo ""
    LC_ALL=C awk '{gsub("[^A-Za-z0-9!@#$%^&*=+]", ""); printf "%s", $0}' < /dev/random | head -c "$1" && echo ""
    echo ""
}
function checksum() { shasum -a 256 "$1"; }
function sslCheck() {
    local domain="$1" expiration_date
    expiration_date=$(openssl s_client -servername "$domain" -connect "$domain":443 </dev/null 2>/dev/null \
        | openssl x509 -noout -enddate | cut -d= -f2)
    echo "SSL certificate for $domain expires on $expiration_date"
}
function jwtd() {
    local jwt="$1"
    if [[ -z "$jwt" ]]; then echo "Usage: jwtd <jwt-token>"; return 1; fi
    echo "Header:"
    echo "$jwt" | cut -d "." -f 1 | base64 --decode 2>/dev/null | python3 -m json.tool
    echo "\nPayload:"
    echo "$jwt" | cut -d "." -f 2 | base64 --decode 2>/dev/null | python3 -m json.tool
}

########################################################################
####          Network Utilities (mixed — see per-function)          ####
########################################################################

# netscan: macOS-only (uses the private `airport` binary)
function netscan() {
  if [[ "$UCD_OS" != "macos" ]]; then
    echo "netscan: macOS-only (airport binary). Try: nmcli device wifi list  (Linux, NetworkManager)" >&2
    return 1
  fi
  local airport="/System/Library/PrivateFrameworks/Apple80211.framework/Versions/Current/Resources/airport"
  local iface
  iface=$(networksetup -listallhardwareports | awk '/Wi-Fi|AirPort/{getline; print $NF}')
  echo "\n--- Current Connection ---"
  "$airport" -I | column -t
  echo "\n--- Available Networks ---"
  "$airport" -s
  echo ""
}

# weather: portable (just curl)
function weather() {
    echo ""
    if [[ "$2" == "m" ]]; then curl "wttr.in/$1?mF"
    elif [[ "$2" == "f" ]]; then curl "wttr.in/$1?uF"
    else echo "Usage: weather <location> <f|m>"; echo "  f = Fahrenheit (US), m = Metric"
    fi
    echo ""
}

########################################################################
####                  Git Utilities (all portable)                  ####
########################################################################

function gcr() {
    if [[ -z "$1" ]]; then echo "Usage: gcr <repository-url>"; return 1; fi
    if git ls-remote --exit-code "$1" &>/dev/null; then git clone "$1"
    else echo "Repository does not exist or is not accessible: $1"; return 1
    fi
}
function cbr() { git rev-parse --abbrev-ref HEAD; }
function gbd() {
    local branch_name="$1"
    if [[ -z "$branch_name" ]]; then echo "Usage: gbd <branch-name>"; return 1; fi
    if git show-ref --quiet --verify "refs/heads/$branch_name"; then
        print -n "Are you sure you want to delete branch '$branch_name'? [y/N]: "
        read response
        if [[ "$response" =~ ^[Yy]$ ]]; then git branch -D "$branch_name"
        else echo "Branch deletion cancelled."
        fi
    else echo "Error: Branch '$branch_name' does not exist."; return 1
    fi
}
function gbrb() {
    if [[ -z "$1" ]]; then echo "Usage: gbrb <base-branch>"; return 1; fi
    local divergence_point; divergence_point=$(git merge-base HEAD "$1")
    git rebase --onto "$1" "$divergence_point" HEAD
}
function gclog() {
    if ! git rev-parse --is-inside-work-tree &>/dev/null; then echo "Not inside a Git repository."; return 1; fi
    echo -n "" > changelog.md
    local REPO_URL
    REPO_URL="https://github.com/$(git config --get remote.origin.url \
        | sed 's/^git@github.com://' | sed 's/\.git$//' | tr -d '\n')"
    git log --pretty=format:"**Commit:** [%h]($REPO_URL/commit/%H)
    &emsp;&emsp;**Author:** %an <%ae>
    &emsp;&emsp;**When:** %ad
    &emsp;&emsp;**Summary:** %f
    " --date=format-local:"<br>
    &emsp;&emsp;&emsp;&emsp;**Date**: %m/%d/%y<br>
    &emsp;&emsp;&emsp;&emsp;**Time**: %H:%M" >> changelog.md
    echo "changelog.md written."
}
function cloneRepos() {
    if [[ -z "$1" || ! -f "$1" ]]; then echo "Usage: cloneRepos <file-with-repo-urls>"; return 1; fi
    while IFS= read -r repo; do
        local repo_name="${${repo##*/}%.git}"
        if [[ ! -d "$repo_name" ]]; then git clone "$repo"
        else echo "Already exists, skipping: $repo_name"
        fi
    done < "$1"
}
function grf() {
    if [[ "$1" == "-h" || "$1" == "--help" || "$#" -ne 4 ]]; then
        echo "Usage: grf <owner> <repo> <branch> <path>"
        echo "Example: grf anthropics claude-code main README.md"
        return 0
    fi
    local owner="$1" repo="$2" branch="$3" file_path="${4%/}"
    local url="https://api.github.com/repos/$owner/$repo/contents/$file_path?ref=$branch"
    local response; response=$(curl -s -H "Accept: application/vnd.github.v3.raw" "$url")
    local entries
    entries=$(echo "$response" | python3 -c "
import sys, json
try:
    data = json.load(sys.stdin)
    if isinstance(data, list):
        for e in data:
            print(e['type'], e['name'])
    else:
        print(data.get('message', 'Not a directory listing'))
except: print(sys.stdin.read())
" 2>/dev/null)
    if [[ -z "$entries" ]]; then echo "$response"
    else
        echo "Contents of '$file_path' on $branch:"
        while IFS= read -r entry; do
            local type="${entry%% *}" name="${entry#* }"
            [[ "$type" == "file" ]] && echo "  File: $name" || echo "  Dir:  $name"
        done <<< "$entries"
    fi
}

########################################################################
####          Terminal File Manager (portable, needs yazi)          ####
########################################################################

function y() {
  local tmp cwd
  tmp="$(mktemp -t "yazi-cwd.XXXXXX")"
  yazi "$@" --cwd-file="$tmp"
  if cwd="$(command cat -- "$tmp")" && [ -n "$cwd" ] && [ "$cwd" != "$PWD" ]; then
    builtin cd -- "$cwd"
  fi
  rm -f -- "$tmp"
}

########################################################################
####             Navigation Utilities (portable, needs fzf)         ####
########################################################################

function fcd() {
  local dir
  dir=$(find "${1:-.}" -type d 2>/dev/null | fzf +m --preview 'eza -lAh {} 2>/dev/null || ls -lAh {}') && cd "$dir"
}

########################################################################
####                 Server Utilities (portable)                    ####
########################################################################

function serve() { python3 -m http.server "${1:-8000}"; }

########################################################################
####                  JSON Utilities (portable)                     ####
########################################################################

function json() { python3 -m json.tool "${@:--}"; }

########################################################################
####                 Archive Utilities (portable)                   ####
########################################################################

function unzip-safe() { unzip "$1" -d "${1%.zip}"; }
