#!/bin/zsh
########################################################################
####                   Custom Zsh Shell Functions                   ####
########################################################################
# Functions are grouped by category. Each function includes a usage
# comment above it. This file is sourced automatically by ~/.zshrc
# via the Dotfiles glob loader.

########################################################################
####                    Apple App Integration                       ####
########################################################################

# note: Add a note to Notes.app
# Usage: note 'title' 'body'   or   echo 'body' | note
# Title is optional when piping input
function note() {
        local title
        local body
        if [ -t 0 ]; then
                title="$1"
                body="$2"
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
# Usage: remind 'foo'   or   echo 'foo' | remind
function remind() {
        local text
        if [ -t 0 ]; then
                text="$1" # argument
        else
                text=$(cat) # pipe
        fi
        osascript >/dev/null <<EOF
tell application "Reminders"
        tell the default list
                make new reminder with properties {name:"$text"}
        end tell
end tell
EOF
}

########################################################################
####                      Shell Utilities                           ####
########################################################################

# lman: Open the man page for the previously run command
# Usage: lman   (run after any command to pull up its man page)
function lman () {
    set -- $(fc -nl -1); while [ "$#" -gt 0 -a '(' "sudo" = "$1" -o "-" = "${1:0:1}" ')' ]; do shift; done; man "$1" || help "$1";
}


########################################################################
####                     Finder Integration                         ####
########################################################################

# show: Reveal one or more files or directories in the Finder
# Usage: show <path> [path ...]   or   show   (defaults to current directory)
function show {
        # Default to the current directory.
        [ $# -eq 0 ] && set -- .;

        # Build the array of paths for AppleScript.
        local path paths=();
        for path; do
                # Make sure each path exists.
                if ! [ -e "$path" ]; then
                        echo "show: $path: No such file or directory";
                        continue;
                fi;

                # Crappily re-implement "readlink -f" ("realpath") for Darwin.
                # (The "cd ... > /dev/null" hides CDPATH noise.)
                [ -d "$path" ] \
                        && path="$(cd "$path" > /dev/null && pwd)" \
                        || path="$(cd "$(dirname "$path")" > /dev/null && \
                         echo "$PWD/$(basename "$path")")";

                # Use the "POSIX file" AppleScript syntax.
                paths+=("POSIX file \"${path//\"/\"}\"");
        done;
        [ "${#paths[@]}" -eq 0 ] && return;

        # Group all output to pipe through osacript.
        {
                echo 'tell application "Finder"';
                echo -n 'select {'; # "reveal" would select only the last file.

                for ((i = 0; i < ${#paths[@]}; i++)); do
                        echo -n "${paths[$i]}";
                        [ $i -lt $(($# - 1)) ] && echo -n ', '; # Ugly array.join()...
                done;

                echo '}';
                echo 'activate';
                echo 'end tell';
        } | osascript;
}


########################################################################
####                    Encoding Utilities                          ####
########################################################################

# b64: Base64 encode or decode a string
# Named b64 to avoid shadowing /usr/bin/base64
# Usage: b64 encode <string>   |   b64 decode <string>
function b64 {
    if [ $# -eq 0 ]; then
        echo 'Usage: b64 [encode|decode] <string>';
        return;
    elif [ "$1" = 'decode' ]; then
        action='decode';
        shift;
    elif [ "$1" = 'encode' ]; then
        action='encode';
        shift;
    else
        action='decode';
    fi;
    echo "$@" | php -r "echo base64_$action(file_get_contents('php://stdin'));";
    echo;
}


########################################################################
####               Directory & Archive Utilities                    ####
########################################################################

# deletefiles: Delete all files matching a pattern from the current directory tree
# Usage: deletefiles <pattern>   e.g. deletefiles '*.log'
# Defaults to '*.DS_Store' if no pattern is given
function deletefiles() {
    local q="${1:-*.DS_Store}"
    find . -type f -name "$q" -ls -delete
}

# cdf: cd into the directory currently open in the frontmost Finder window
# Usage: cdf
function cdf() {
        cd "$(osascript -e 'tell app "Finder" to POSIX path of (insertion location as alias)')"
}

# extract: Extract most known archive formats with a single command
# Usage: extract <file>   supports tar.gz, zip, bz2, rar, 7z, and more
  extract () {
      if [ -f $1 ] ; then
        case $1 in
          *.tar.bz2)   tar xjf $1     ;;
          *.tar.gz)    tar xzf $1     ;;
          *.bz2)       bunzip2 $1     ;;
          *.rar)       unrar e $1     ;;
          *.gz)        gunzip $1      ;;
          *.tar)       tar xf $1      ;;
          *.tbz2)      tar xjf $1     ;;
          *.tgz)       tar xzf $1     ;;
          *.zip)       unzip $1       ;;
          *.Z)         uncompress $1  ;;
          *.7z)        7z x $1        ;;
          *)     echo "'$1' cannot be extracted via extract()" ;;
           esac
       else
           echo "'$1' is not a valid file"
       fi
     }


# mkd: Create a new directory (including parents) and cd into it
# Usage: mkd <directory>
function mkd() {
        mkdir -p "$@" && cd "$@"
}

# targz: Create a .tar.gz archive using the best available compressor
# Prefers zopfli (best compression) → pigz (parallel) → gzip (fallback)
# Usage: targz <file-or-directory>
function targz() {
        local tmpFile="${@%/}.tar"
        tar -cvf "${tmpFile}" --exclude=".DS_Store" "${@}" || return 1

        size=$(
                stat -f"%z" "${tmpFile}" 2> /dev/null; # OS X `stat`
                stat -c"%s" "${tmpFile}" 2> /dev/null # GNU `stat`
        )

        local cmd=""
        if (( size < 52428800 )) && hash zopfli 2> /dev/null; then
                # the .tar file is smaller than 50 MB and Zopfli is available; use it
                cmd="zopfli"
        else
                if hash pigz 2> /dev/null; then
                        cmd="pigz"
                else
                        cmd="gzip"
                fi
        fi

        echo "Compressing .tar using \`${cmd}\`…"
        "${cmd}" -v "${tmpFile}" || return 1
        [ -f "${tmpFile}" ] && rm "${tmpFile}"
        echo "${tmpFile}.gz created successfully."
}

########################################################################
####                      Disk Utilities                            ####
########################################################################

# fs: Show the size of a file or total size of a directory
# Usage: fs <path> [path ...]   or   fs   (sizes everything in current dir)
function fs() {
        if du -b /dev/null > /dev/null 2>&1; then
                local arg=-sbh
        else
                local arg=-sh
        fi
        if [[ -n "$@" ]]; then
                du $arg -- "$@"
        else
                du $arg .[^.]* *
        fi
}

# diff: Use git’s colored word-diff when available, falling back to system diff
# Usage: diff <file1> <file2>
hash git &>/dev/null
if [ $? -eq 0 ]; then
        function diff() {
                git diff --no-index --color-words "$@"
        }
fi

# duh: Sort du output by size and display in human-readable units (KiB/MiB/GiB etc.)
# Usage: duh [path ...]   or   duh   (sizes current directory contents)
function duh {
        du -sk "$@" | sort -n | while read size fname; do
                for unit in KiB MiB GiB TiB PiB EiB ZiB YiB; do
                        if [ "$size" -lt 1024 ]; then
                                echo -e "${size} ${unit}\t${fname}";
                                break;
                        fi;
                        size=$((size/1024));
                done;
        done;
}

########################################################################
####                     Search Utilities                           ####
########################################################################

# spotlight: Search for a file by display name using macOS Spotlight metadata
# Usage: spotlight <filename>
  spotlight () { mdfind "kMDItemDisplayName == '$@'wc"; }

########################################################################
####              Process Management & System Info                  ####
########################################################################

# findPid: Find the PID of a running process by name or regex
# Command name can be a regex — e.g. findPid '/d$/' finds all daemons
# Without sudo, only shows processes owned by the current user
# Usage: findPid <name-or-regex>
  findPid () { lsof -t -c "$@" ; }

# memHogsTop, memHogsPs, cpu_hogs, topForever, ttop:
# Defined in aliases.zsh — not duplicated here.

# my_ps: List all processes owned by the current user
# Usage: my_ps
  my_ps() { ps $@ -u $USER -o pid,%cpu,%mem,start,time,bsdtime,command ; }

# ii: Display a summary of useful host and network information
# Usage: ii
  ii() {
      echo -e "\nYou are logged on ${RED}$HOST"
      echo -e "\nAdditionnal information:$NC " ; uname -a
      echo -e "\n${RED}Users logged on:$NC " ; w -h
      echo -e "\n${RED}Current date :$NC " ; date
      echo -e "\n${RED}Machine stats :$NC " ; uptime
      echo -e "\n${RED}Current network location :$NC " ; scselect
      echo -e "\n${RED}Public facing IP Address :$NC " ;myip
      echo -e "\n${RED}DNS Configuration:$NC " ; scutil --dns
      echo
    }



########################################################################
####                   File & Directory Utilities                   ####
########################################################################

# ff: Find files by partial name in the current directory tree
# Usage: ff <partial-name>
function ff() {
    find -L "." -type f -name "*$1*"
}

# cf: Count files in a directory (defaults to current directory)
# Usage: cf [directory]
function cf() {
    if [[ -n "$1" ]]; then
        find -L "$1" -type f | wc -l
    else
        find -L "." -type f | wc -l
    fi
}

########################################################################
####                     Security Utilities                         ####
########################################################################

# passgen: Generate a random password of a specified length
# Usage: passgen <length>   e.g. passgen 24
function passgen() {
    echo ""
    LC_ALL=C awk '{gsub("[^A-Za-z0-9!@#$%^&*=+]", ""); printf "%s", $0}' < /dev/random | head -c "$1" && echo ""
    echo ""
}

# checksum: Print the SHA-256 checksum of a file
# Usage: checksum <file>
function checksum() {
    shasum -a 256 "$1"
}

# sslCheck: Check the SSL certificate expiration date for a domain
# Usage: sslCheck <domain>   e.g. sslCheck github.com
function sslCheck() {
    local domain="$1"
    local expiration_date
    expiration_date=$(openssl s_client -servername "$domain" -connect "$domain":443 </dev/null 2>/dev/null \
        | openssl x509 -noout -enddate | cut -d= -f2)
    echo "SSL certificate for $domain expires on $expiration_date"
}

# jwtd: Decode and pretty-print a JWT token (header + payload)
# Usage: jwtd <token>
function jwtd() {
    local jwt="$1"
    if [[ -z "$jwt" ]]; then
        echo "Usage: jwtd <jwt-token>"
        return 1
    fi
    echo "Header:"
    echo "$jwt" | cut -d "." -f 1 | base64 --decode 2>/dev/null | python3 -m json.tool
    echo "\nPayload:"
    echo "$jwt" | cut -d "." -f 2 | base64 --decode 2>/dev/null | python3 -m json.tool
}

########################################################################
####                     Network Utilities                          ####
########################################################################

# netscan: Display current Wi-Fi connection info and scan nearby networks
# Usage: netscan
function netscan() {
    local airport="/System/Library/PrivateFrameworks/Apple80211.framework/Versions/Current/Resources/airport"
    local iface
    iface=$(networksetup -listallhardwareports | awk '/Wi-Fi|AirPort/{getline; print $NF}')
    echo "\n--- Current Connection ---"
    "$airport" -I | column -t
    echo "\n--- Available Networks ---"
    "$airport" -s
    echo ""
}

# weather: Get a weather report via wttr.in
# Usage: weather <location> <unit>   unit: f = Fahrenheit, m = Metric
# Example: weather Nashville f
function weather() {
    echo ""
    if [[ "$2" == "m" ]]; then
        curl "wttr.in/$1?mF"
    elif [[ "$2" == "f" ]]; then
        curl "wttr.in/$1?uF"
    else
        echo "Usage: weather <location> <f|m>"
        echo "  f = Fahrenheit (US), m = Metric"
    fi
    echo ""
}

########################################################################
####                      Git Utilities                             ####
########################################################################

# gcr: Clone a remote repository after verifying it exists
# Usage: gcr <repository-url>
function gcr() {
    if [[ -z "$1" ]]; then
        echo "Usage: gcr <repository-url>"
        return 1
    fi
    if git ls-remote --exit-code "$1" &>/dev/null; then
        git clone "$1"
    else
        echo "Repository does not exist or is not accessible: $1"
        return 1
    fi
}

# cbr: Print the name of the current git branch
# Usage: cbr
function cbr() {
    git rev-parse --abbrev-ref HEAD
}

# gbd: Delete a local git branch with a confirmation prompt
# Usage: gbd <branch-name>
function gbd() {
    local branch_name="$1"
    if [[ -z "$branch_name" ]]; then
        echo "Usage: gbd <branch-name>"
        return 1
    fi
    if git show-ref --quiet --verify "refs/heads/$branch_name"; then
        print -n "Are you sure you want to delete branch '$branch_name'? [y/N]: "
        read response
        if [[ "$response" =~ ^[Yy]$ ]]; then
            git branch -D "$branch_name"
        else
            echo "Branch deletion cancelled."
        fi
    else
        echo "Error: Branch '$branch_name' does not exist."
        return 1
    fi
}

# gbrb: Rebase only the commits unique to the current branch onto another branch
# Usage: gbrb <base-branch>   e.g. gbrb main
function gbrb() {
    if [[ -z "$1" ]]; then
        echo "Usage: gbrb <base-branch>"
        return 1
    fi
    local divergence_point
    divergence_point=$(git merge-base HEAD "$1")
    git rebase --onto "$1" "$divergence_point" HEAD
}

# gclog: Write a formatted git changelog to changelog.md in the current directory
# Usage: gclog   (must be run inside a git repository)
function gclog() {
    if ! git rev-parse --is-inside-work-tree &>/dev/null; then
        echo "Not inside a Git repository."
        return 1
    fi
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

# cloneRepos: Clone a list of repository URLs from a text file (one URL per line)
# Skips repos that already exist locally.
# Usage: cloneRepos <file>   e.g. cloneRepos ~/repos.txt
function cloneRepos() {
    if [[ -z "$1" || ! -f "$1" ]]; then
        echo "Usage: cloneRepos <file-with-repo-urls>"
        return 1
    fi
    while IFS= read -r repo; do
        local repo_name="${${repo##*/}%.git}"
        if [[ ! -d "$repo_name" ]]; then
            git clone "$repo"
        else
            echo "Already exists, skipping: $repo_name"
        fi
    done < "$1"
}

# grf: Display the contents of a file or directory in a remote GitHub repository
# Usage: grf <owner> <repo> <branch> <path>
# Example: grf anthropics claude-code main src/
function grf() {
    if [[ "$1" == "-h" || "$1" == "--help" || "$#" -ne 4 ]]; then
        echo "Usage: grf <owner> <repo> <branch> <path>"
        echo "Example: grf anthropics claude-code main README.md"
        return 0
    fi
    local owner="$1" repo="$2" branch="$3" file_path="${4%/}"
    local url="https://api.github.com/repos/$owner/$repo/contents/$file_path?ref=$branch"
    local response
    response=$(curl -s -H "Accept: application/vnd.github.v3.raw" "$url")
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
    if [[ -z "$entries" ]]; then
        echo "$response"
    else
        echo "Contents of '$file_path' on $branch:"
        while IFS= read -r entry; do
            local type="${entry%% *}" name="${entry#* }"
            [[ "$type" == "file" ]] && echo "  File: $name" || echo "  Dir:  $name"
        done <<< "$entries"
    fi
}

## custom functions
# gpr() {
#   if [ $? -eq 0 ]; then
#     github_url=`git remote -v | awk '/fetch/{print $2}' | sed -Ee 's#(git@|git://)#http://#' -e 's@com:@com/@' -e 's%\.git$%%'`;
#     branch_name=`git symbolic-ref HEAD 2>/dev/null | cut -d"/" -f 3`;
#     pr_url=$github_url"/compare/master..."$branch_name
#     open $pr_url;
#   else
#     echo 'failed to open a pull request.';
#   fi
# }

# commands() {
#   awk '{a[$2]++}END{for(i in a){print a[i] " " i}}'
# }
########################################################################
####                  Terminal File Manager                         ####
########################################################################

# y: Launch yazi file manager and cd into the directory you exit from
# Yazi writes its final directory to a temp file; we read it and cd there
# Usage: y [path]
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
####                  Navigation Utilities                          ####
########################################################################

# mkcd: Create a directory (including parents) and cd into it immediately
# Usage: mkcd <directory>
function mkcd() { mkdir -p "$@" && cd "$_"; }

# fcd: Interactively pick a directory using fzf and cd into it
# Usage: fcd [starting-path]   (defaults to current directory)
function fcd() {
  local dir
  dir=$(find "${1:-.}" -type d 2>/dev/null | fzf +m --preview 'eza -lAh {}') && cd "$dir"
}

########################################################################
####                     Server Utilities                           ####
########################################################################

# serve: Spin up a quick Python HTTP server in the current directory
# Usage: serve [port]   (defaults to port 8000)
function serve() { python3 -m http.server "${1:-8000}"; }

########################################################################
####                      JSON Utilities                            ####
########################################################################

# json: Pretty-print JSON from a file, pipe, or stdin
# Usage: json <file>   or   cat file.json | json   or   json   (reads stdin)
function json() { python3 -m json.tool "${@:--}"; }

########################################################################
####                    Archive Utilities                           ####
########################################################################

# unzip-safe: Extract a zip into a named subdirectory to avoid zip bombs
# Usage: unzip-safe <file.zip>
function unzip-safe() { unzip "$1" -d "${1%.zip}"; }
