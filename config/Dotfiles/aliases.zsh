#!/bin/zsh
########################################################################
####                 .zsh Shell Alias Definitions                   ####
########################################################################
# Set personal aliases, overriding those provided by oh-my-zsh libs,
# plugins, and themes.
#
# Alias types in use:
#   Simple aliases   — replace long commands with short names
#   Suffix aliases   — open specific file types with a designated app
#   Global aliases   — usable anywhere in a command line (e.g. in pipes)
#   Function aliases — inline functions that accept parameters
#
# This file lives at ~/.config/Dotfiles/aliases.zsh and is sourced
# automatically by ~/.zshrc via the Dotfiles glob loader.
#
# To see all currently active aliases, run: alias

########################################################################
####                 Change Directory Aliases                       ####
########################################################################
alias cd..='cd ../'                         # Go back 1 directory level (typo-safe)
alias ..='cd ../'                           # Go back 1 directory level
alias ...='cd ../../'                       # Go back 2 directory levels
alias .3='cd ../../../'                     # Go back 3 directory levels
alias .4='cd ../../../../'                  # Go back 4 directory levels
alias .5='cd ../../../../../'               # Go back 5 directory levels
alias .6='cd ../../../../../../'            # Go back 6 directory levels
cd() { builtin cd "$@"; eza -lh; }          # Always list directory contents upon 'cd'

########################################################################
####            Directory Listing Commands (ls => eza)             ####
########################################################################
# eza is the actively maintained fork of the abandoned exa project.
# It is a drop-in replacement with identical flags and behavior.
alias ls="eza"                              # Replace ls with eza
alias ll="eza -lh"                          # Long list with header
alias la="eza -lah"                         # Long list, all files (incl. hidden), with header
alias tree="eza --tree"                     # Tree view (also accepts -T)
alias lr='ls -R | grep ":$" | sed -e '\''s/:$//'\'' -e '\''s/[^-][^\/]*\//--/g'\'' -e '\''s/^/   /'\'' -e '\''s/-/|/'\'' | less'
                                            # lr: Full recursive directory listing

########################################################################
####                Direct Directory Navigation                     ####
########################################################################
alias ~="cd ~"                              # Go to home directory
alias drop="cd ~/Dropbox"                   # Jump to Dropbox directory
alias dload="cd ~/Downloads"                # Jump to Downloads directory
alias dt="cd ~/Desktop"                     # Jump to Desktop
alias gdrive="cd ~/Google\ Drive"          # Jump to Google Drive (fixed space escaping)
alias sshdir="cd ~/.ssh"                    # Jump to .ssh directory

########################################################################
####                     Command Shortcuts                          ####
########################################################################
alias cat='bat'                             # Replace cat with bat for syntax highlighting
alias ccat='bat'                            # Drop-in replacement for colorize's ccat
alias cless='bat --paging=always'           # Drop-in replacement for colorize's cless
alias cp='cp -iv'                           # Interactive + verbose cp
alias mv='mv -iv'                           # Interactive + verbose mv
alias mkdir='mkdir -pv'                     # Create parent dirs as needed, verbose
alias md="mkdir"                            # Short form of mkdir
alias less='less -FSRXc'                    # Preferred less implementation
alias f='open -a Finder ./'                 # Open current directory in Finder
alias which='type -a'                       # Show all locations of an executable
alias path='echo -e ${PATH//:/\\n}'         # Print each PATH entry on its own line
alias fix_stty='stty sane'                  # Restore terminal settings if scrambled
alias show_options='shopt'                  # Display all shell option settings
alias cic='set completion-ignore-case On'   # Make tab-completion case-insensitive
mcd()  { mkdir -p "$1" && cd "$1"; }        # Make a directory and cd into it
trash() { command mv "$@" ~/.Trash; }       # Move file(s) to macOS Trash
ql()   { qlmanage -p "$*" >& /dev/null; }  # Open file(s) in macOS Quick Look
alias DT='tee ~/Desktop/terminalOut.txt'    # Tee terminal output to Desktop file
alias cls=clear                             # Familiar clear alias
alias h="history"                           # Short history command
alias j="jobs"                              # Short jobs command
alias grep='grep --color=auto'              # Colorized grep
alias egrep='egrep --color=auto'            # Colorized egrep
alias fgrep='fgrep --color=auto'            # Colorized fgrep
alias -s {txt,md,yaml,yml}="code"          # Auto-open text/config files in VS Code
alias pg="echo 'Pinging Google' && ping www.google.com"
                                            # Quick connectivity check
alias dirs='dirs -v | head -10'             # Show last 10 visited directories
alias usage='du -h -d1'                     # Disk usage, one level deep
alias runp="lsof -i"                        # Show processes using network ports
alias mount='mount | column -t'            # Human-readable mount output
alias sudo='sudo '                          # Allow aliases to work with sudo

########################################################################
####                    Config Editing Aliases                      ####
########################################################################
alias zshrc='code ~/.zshrc'                 # Edit .zshrc in VS Code
alias zshconf='code ~/.zshrc'               # Alternate alias for .zshrc editing
alias ohmyzsh='code ~/.oh-my-zsh'           # Edit oh-my-zsh directory in VS Code
alias dotfiles='code ~/.config/Dotfiles'    # Open Dotfiles directory in VS Code

########################################################################
####                     Session Management                         ####
########################################################################
alias update="source ~/.zshrc"              # Re-source .zshrc to apply changes
                                            # (For macOS software updates, see 'osupdate' below)
alias osupdate='sudo softwareupdate -i -a; brew update; brew upgrade; brew cleanup; sudo gem update'
                                            # Full system update: macOS + Homebrew + gems
alias topten="history | awk '{a[\$2]++}END{for(i in a){print a[i] \" \" i}}' | sort -rn | head"
                                            # Top 10 most-used commands in history

########################################################################
####                       Networking                               ####
########################################################################
alias myip='curl http://ipecho.net/plain; echo'
                                            # Public-facing IP address (single definition)
alias localip="ipconfig getifaddr en0"      # Local IP on primary interface (en0 for Wi-Fi)
alias ips="ifconfig -a | grep -o 'inet6\? \(\([0-9]\+\.[0-9]\+\.[0-9]\+\.[0-9]\+\)\|[a-fA-F0-9:]\+\)' | sed -e 's/inet6* //'"
                                            # All local IP addresses
alias netCons='lsof -i'                     # Show all open TCP/IP sockets
alias lsock='sudo /usr/sbin/lsof -i -P'    # Display open sockets
alias lsockU='sudo /usr/sbin/lsof -nP | grep UDP'  # Open UDP sockets only
alias lsockT='sudo /usr/sbin/lsof -nP | grep TCP'  # Open TCP sockets only
alias ipInfo0='ipconfig getpacket en0'      # Connection info for en0
alias ipInfo1='ipconfig getpacket en1'      # Connection info for en1
alias openPorts='sudo lsof -i | grep LISTEN'        # All listening ports
alias showBlocked='sudo ipfw list'          # Show ipfw rules including blocked IPs
alias whois="whois -h whois-servers.net"    # Enhanced WHOIS lookups

# DNS — three aliases, each with a distinct purpose:
alias flushdns="sudo dscacheutil -flushcache; sudo killall -HUP mDNSResponder"
                                            # Full DNS flush (cache + resolver restart)
alias flushDNS='dscacheutil -flushcache'    # Flush DNS cache only (no resolver restart)
alias flush="dscacheutil -flushcache && killall -HUP mDNSResponder"
                                            # Alias flush (same as flushdns, without sudo)

########################################################################
####                  Mac OS X Specific Commands                    ####
########################################################################
alias showFiles='defaults write com.apple.finder AppleShowAllFiles YES; killall Finder'
                                            # Show hidden files in Finder
alias hideFiles='defaults write com.apple.finder AppleShowAllFiles NO; killall Finder'
                                            # Hide hidden files in Finder
alias showhidden="defaults write com.apple.finder AppleShowAllFiles -bool true && killall Finder"
                                            # Show hidden files (bool form — same as showFiles)
alias hidehidden="defaults write com.apple.finder AppleShowAllFiles -bool false && killall Finder"
                                            # Hide hidden files (bool form — same as hideFiles)
alias hidedesktop="defaults write com.apple.finder CreateDesktop -bool false && killall Finder"
                                            # Hide all icons from the Desktop
alias showdesktop="defaults write com.apple.finder CreateDesktop -bool true && killall Finder"
                                            # Show all icons on the Desktop
alias deleteDSFiles="find . -name '.DS_Store' -type f -delete"
                                            # Delete all .DS_Store files recursively from current directory
alias cleanup="find . -type f -name '*.DS_Store' -ls -delete"
                                            # List and delete all .DS_Store files (verbose form)
alias cleanupLS="/System/Library/Frameworks/CoreServices.framework/Frameworks/LaunchServices.framework/Support/lsregister -kill -r -domain local -domain system -domain user && killall Finder"
                                            # Remove duplicates from "Open With" menu
alias lscleanup="/System/Library/Frameworks/CoreServices.framework/Frameworks/LaunchServices.framework/Support/lsregister -kill -r -domain local -domain system -domain user && killall Finder"
                                            # Alternate name for cleanupLS — same operation
alias emptytrash="sudo rm -rfv /Volumes/*/.Trashes; sudo rm -rfv ~/.Trash; sudo rm -rfv /private/var/log/asl/*.asl"
                                            # Empty Trash, external volumes, and old system logs
alias ScreensaverDesktop='/System/Library/Frameworks/ScreenSaver.framework/Resources/ScreenSaverEngine.app/Contents/MacOS/ScreenSaverEngine -background'
                                            # Run the screensaver as a desktop background
alias mergepdf='/System/Library/Automator/Combine\ PDF\ Pages.action/Contents/Resources/join.py'
                                            # Merge multiple PDFs using the built-in Automator action
alias afk="/System/Library/CoreServices/Menu\ Extras/User.menu/Contents/Resources/CGSession -suspend"
                                            # Lock screen when going AFK
alias spotoff="sudo mdutil -a -i off"       # Disable Spotlight indexing
alias spoton="sudo mdutil -a -i on"         # Enable Spotlight indexing

########################################################################
####                  Clipboard (macOS Pasteboard)                  ####
########################################################################
alias -g 2clip='| pbcopy'                   # Pipe output to clipboard
alias -g clip2='pbpaste |'                  # Paste clipboard into a pipeline

########################################################################
####                  Light / Dark Mode (lux)                       ####
########################################################################
alias lumos='lux all light'                 # Switch all to light mode
alias nox='lux all dark'                    # Switch all to dark mode

########################################################################
####                  Fallback Utility Aliases                      ####
########################################################################
# macOS doesn't ship md5sum or sha1sum — use native equivalents
command -v md5sum  > /dev/null || alias md5sum="md5"
command -v sha1sum > /dev/null || alias sha1sum="shasum"
# macOS doesn't ship hd (hex dump) — fall back to hexdump
command -v hd > /dev/null || alias hd="hexdump -C"
# Use Grunt with stack traces if installed
command -v grunt > /dev/null && alias grunt="grunt --stack"

########################################################################
####                       Homebrew Commands                        ####
########################################################################
alias -g BrewMe="brew update && brew upgrade"
                                            # Standard Homebrew update + upgrade
alias -g BrewGreedy="brew update && brew upgrade --greedy --verbose"
                                            # Force-upgrade all casks (incl. auto-updating ones)

########################################################################
####                         Git Aliases                            ####
########################################################################
function gc { git commit -m "$@"; }         # Commit with message
alias gchm="git checkout master"            # Checkout master branch
alias gs="git status"                       # Git status
alias gpull="git pull"                      # Git pull
alias gf="git fetch"                        # Fetch from default remote
alias gfa="git fetch --all"                 # Fetch from all remotes
alias gfo="git fetch origin"                # Fetch from origin specifically
alias gpush="git push"                      # Git push
alias gd="git diff"                         # Git diff
alias ga="git add ."                        # Stage all changes
alias gb="git branch"                       # List branches
alias gbr="git branch remote"               # List remote branches
alias gru="git remote update"               # Update all remotes
alias gbn="git checkout -B"                 # Create and switch to new branch
alias grf="git reflog"                      # Show reflog
alias grh="git reset HEAD~"                 # Undo last commit (keep changes staged)
alias gac="git add . && git commit -a -m"   # Stage all and commit
alias gsu="git push --set-upstream origin"  # Push and set upstream (fixed: was 'git gpush')
alias glog="git log --color --graph --pretty=format:'%Cred%h%Creset -%C(yellow)%d%Creset %s %Cgreen(%cr) %C(bold blue)<%an>%Creset' --abbrev-commit --branches"
                                            # Pretty git log graph

########################################################################
####                  Process Management                            ####
########################################################################
alias memHogsTop='top -l 1 -o rsize | head -20'        # Top memory consumers (top)
alias memHogsPs='ps wwaxm -o pid,stat,vsize,rss,time,command | head -10'  # Top memory (ps)
alias cpu_hogs='ps wwaxr -o pid,stat,%cpu,time,command | head -10'        # Top CPU consumers
alias topForever='top -l 9999999 -s 10 -o cpu'          # Continuous top (every 10s)
alias ttop="top -R -F -s 10 -o rsize"                   # Resource-efficient top invocation

########################################################################
####                       Docker Aliases                           ####
####          (Uncomment if Docker Compose is in active use)        ####
########################################################################
# alias dockerstop='docker-compose stop'
# alias dockerrestart='docker-compose restart'
# alias dockerup='docker-compose up -d'
# alias dockerrm='docker-compose rm --all'

########################################################################
####                        NPM Aliases                             ####
####              (Uncomment if npm workflow is active)             ####
########################################################################
# alias npm-update="npx npm-check -u"
# alias ni="npm install"
# alias nrs="npm run start -s --"
# alias nrb="npm run build -s --"
# alias nrd="npm run dev -s --"
# alias nrt="npm run test -s --"
# alias nrtw="npm run test:watch -s --"
# alias nrv="npm run validate -s --"
# alias rmn="rm -rf node_modules"
# alias flush-npm="rm -rf node_modules && npm i && echo NPM is done"

########################################################################
####                         Yarn Aliases                           ####
####              (Uncomment if Yarn workflow is active)            ####
########################################################################
# alias yar="yarn run"
# alias yab="yarn build"
# alias yal="yarn lint:fix"
# alias yac="yarn commit"
# alias yas="yarn start"
# alias yasb="yarn storybook:start"
# alias yat="yarn test"
# alias yatw="yarn test:watch"

########################################################################
####                        Other Aliases                           ####
########################################################################

########################################################################
####                     Listing Extras (eza)                       ####
########################################################################
alias lt="eza -lAGht"                  # Long list sorted by time, newest first

########################################################################
####                         Editor Aliases                         ####
########################################################################
alias c="code ."                       # Open current directory in VS Code
alias ze="zed ."                       # Open current directory in Zed

########################################################################
####                        Python Aliases                          ####
########################################################################
alias python="python3"                 # Always use Python 3
alias pip="pip3"                       # Always use pip for Python 3
alias venv="python3 -m venv .venv && source .venv/bin/activate"
                                       # Create a virtual environment and activate it
alias activate="source .venv/bin/activate"
                                       # Activate an existing virtual environment

########################################################################
####                        Docker Aliases                          ####
########################################################################
alias dps='docker ps --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}"'
                                       # List running containers in a clean table
alias dpa='docker ps -a --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}"'
                                       # List all containers (including stopped)
alias dclean="docker system prune -f"  # Remove all unused Docker resources
alias dlogs="docker logs -f"           # Follow logs for a container

########################################################################
####                     macOS Utility Aliases                      ####
########################################################################
alias brewup="brew update && brew upgrade && brew cleanup -q"
                                       # Quick Homebrew update, upgrade, and cleanup
alias brewinfo="brew leaves | xargs brew desc --eval-all"
                                       # Show descriptions for all top-level installed formulae
alias ip="ipconfig getifaddr en0"      # Local IP address on primary Wi-Fi interface
alias pubip="curl -s https://ipinfo.io/ip"
                                       # Public-facing IP address
alias sleepnow="pmset sleepnow"        # Put the Mac to sleep immediately
alias week="date +%V"                  # Print the current ISO week number
alias timestamp="date -u +%Y-%m-%dT%H:%M:%SZ"
                                       # Print current UTC timestamp in ISO 8601 format

########################################################################
####                       Session Aliases                          ####
########################################################################
alias reload="source ~/.zshrc && echo 'Shell reloaded.'"
                                       # Re-source .zshrc to pick up any changes
