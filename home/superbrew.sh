#!/bin/zsh
########################################################################
####                        SuperBrew.sh                            ####
####     Interactive Homebrew Audit & Install Script                ####
####     Checks for outdated formulae/casks, shows results,        ####
####     and asks before making any changes.                        ####
########################################################################
set -euo pipefail

########################################################################
####                        Color Helpers                           ####
########################################################################
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
BOLD='\033[1m'
NC='\033[0m' # No Color

header()  { echo "\n${BOLD}${BLUE}=========================================${NC}"; \
            echo "${BOLD}${BLUE}  $1${NC}"; \
            echo "${BOLD}${BLUE}=========================================${NC}"; }
success() { echo "${GREEN}✔  $1${NC}"; }
warn()    { echo "${YELLOW}⚠  $1${NC}"; }
info()    { echo "${CYAN}ℹ  $1${NC}"; }
ask()     { echo "${YELLOW}${BOLD}▶  $1 [y/n]: ${NC}\c"; }

########################################################################
####                        Confirmation Helper                     ####
########################################################################
confirm() {
    ask "$1"
    read response
    [[ "$response" =~ ^[Yy]$ ]]
}

########################################################################
####                  1. Refresh Homebrew Index                     ####
########################################################################
header "Refreshing Homebrew Formula Index"
brew update
success "Homebrew index refreshed"

########################################################################
####                  2. Check Outdated Formulae                    ####
########################################################################
header "Checking for Outdated Formulae"
OUTDATED_FORMULAE=$(brew outdated --formula --verbose 2>/dev/null)
if [[ -z "$OUTDATED_FORMULAE" ]]; then
    success "All formulae are up to date"
else
    warn "The following formulae have updates available:"
    echo "${YELLOW}${OUTDATED_FORMULAE}${NC}"
    echo ""
    if confirm "Upgrade all outdated formulae?"; then
        brew upgrade --formula
        success "Formulae upgraded"
    else
        info "Skipping formula upgrades"
    fi
fi

########################################################################
####                  3. Check Outdated Casks                       ####
########################################################################
header "Checking for Outdated Casks"
OUTDATED_CASKS=$(brew outdated --cask --verbose 2>/dev/null)
if [[ -z "$OUTDATED_CASKS" ]]; then
    success "All casks are up to date"
else
    warn "The following casks have updates available:"
    echo "${YELLOW}${OUTDATED_CASKS}${NC}"
    echo ""
    if confirm "Upgrade all outdated casks?"; then
        brew upgrade --cask
        success "Casks upgraded"
    else
        info "Skipping cask upgrades"
    fi
fi

########################################################################
####          4. Check for Auto-Updating Casks (Greedy)             ####
########################################################################
header "Checking Auto-Updating Casks (Greedy)"
info "Some casks self-update and are skipped by default."
info "Running greedy check to find any that have newer versions..."
GREEDY_OUTDATED=$(brew outdated --cask --greedy --verbose 2>/dev/null | grep -v "^Already" || true)
if [[ -z "$GREEDY_OUTDATED" ]]; then
    success "All auto-updating casks are current"
else
    warn "The following auto-updating casks may have updates:"
    echo "${YELLOW}${GREEDY_OUTDATED}${NC}"
    echo ""
    if confirm "Upgrade these casks too?"; then
        brew upgrade --cask --greedy
        success "Greedy casks upgraded"
    else
        info "Skipping greedy cask upgrades"
    fi
fi

########################################################################
####              5. Check Brewfile Consistency                      ####
########################################################################
header "Checking Brewfile Consistency"
info "Checking for packages installed but not in your Brewfile..."
UNLISTED=$(brew bundle cleanup --file="$HOME/Brewfile" 2>/dev/null || true)
if [[ -z "$UNLISTED" ]]; then
    success "All installed packages are in your Brewfile"
else
    warn "The following are installed but not in your Brewfile:"
    echo "${YELLOW}${UNLISTED}${NC}"
    echo ""
    info "To add them: edit ~/Brewfile and run 'brew bundle'"
    info "To remove them: run 'brew bundle cleanup --force'"
fi

########################################################################
####              6. Check for Missing Brewfile Packages             ####
########################################################################
header "Checking for Missing Brewfile Packages"
info "Checking for packages in Brewfile that are not installed..."
MISSING=$(brew bundle check --file="$HOME/Brewfile" --verbose 2>&1 | grep "^x " || true)
if [[ -z "$MISSING" ]]; then
    success "All Brewfile packages are installed"
else
    warn "The following Brewfile packages are missing:"
    echo "${YELLOW}${MISSING}${NC}"
    echo ""
    if confirm "Install missing Brewfile packages now?"; then
        brew bundle install --file="$HOME/Brewfile"
        success "Missing packages installed"
    else
        info "Skipping missing package install"
    fi
fi

########################################################################
####                  7. Check Ruby Gems                            ####
########################################################################
header "Checking for Outdated Ruby Gems"
OUTDATED_GEMS=$(/opt/homebrew/opt/ruby/bin/gem outdated 2>/dev/null)
if [[ -z "$OUTDATED_GEMS" ]]; then
    success "All Ruby gems are up to date"
else
    warn "The following gems have updates available:"
    echo "${YELLOW}${OUTDATED_GEMS}${NC}"
    echo ""
    if confirm "Update all Ruby gems?"; then
        /opt/homebrew/opt/ruby/bin/gem update
        success "Ruby gems updated"
    else
        info "Skipping gem updates"
    fi
fi

########################################################################
####                  8. Homebrew Health Check                      ####
########################################################################
header "Running Homebrew Health Check"
DOCTOR=$(brew doctor 2>&1 || true)
if echo "$DOCTOR" | grep -q "Your system is ready to brew"; then
    success "Homebrew is healthy"
else
    warn "Homebrew doctor found some issues:"
    echo "${YELLOW}${DOCTOR}${NC}"
fi

########################################################################
####                  9. Cleanup                                    ####
########################################################################
header "Cleanup Old Versions"
info "The following old versions and cache files can be removed:"
brew cleanup --dry-run 2>/dev/null || true
echo ""
if confirm "Run brew cleanup to remove old versions?"; then
    brew cleanup
    success "Cleanup complete"
else
    info "Skipping cleanup"
fi

########################################################################
####                  10. Summary                                   ####
########################################################################
header "Installed Package Summary"
echo "${BOLD}Formulae:${NC}"
brew list --formula | column
echo ""
echo "${BOLD}Casks:${NC}"
brew list --cask | column
echo ""
success "SuperBrew audit complete!"
