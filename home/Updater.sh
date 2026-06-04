#!/bin/zsh
########################################################################
####                        Updater.sh                              ####
####       Full system update: macOS + Homebrew + Brewfile          ####
########################################################################
set -euo pipefail   # Exit on error, undefined vars, pipe failures

echo ""
echo "========================================="
echo "  Updating Apple Software"
echo "========================================="
# Installs all available macOS and Apple software updates silently
sudo softwareupdate -i -a --verbose

echo ""
echo "========================================="
echo "  Updating Oh My Zsh"
echo "========================================="
# Calls the Oh My Zsh upgrade script directly — omz is a shell function
# and isn't available in non-interactive scripts
zsh "${ZSH}/tools/upgrade.sh"

echo ""
echo "========================================="
echo "  Refreshing Homebrew Formula Index"
echo "========================================="
# Fetches the latest formula definitions from Homebrew's remote repos
brew update

echo ""
echo "========================================="
echo "  Upgrading Installed Formulae & Casks"
echo "========================================="
# Upgrades all installed formulae and casks to their latest versions
brew upgrade

echo ""
echo "========================================="
echo "  Reconciling Brewfile (bundle)"
echo "========================================="
# Installs anything listed in the Brewfile that isn't already installed,
# keeping this machine in sync with the Brewfile as the source of truth
# brew bundle -v            #verbose mode
brew bundle

echo ""
echo "========================================="
echo "  Checking for Unlisted Installed Packages"
echo "========================================="
# Lists packages installed on this machine but not in the Brewfile.
# Nothing is removed — this is informational only.
# To actually remove them, run manually: brew bundle cleanup --force
brew bundle cleanup || true

echo ""
echo "========================================="
echo "  Updating Tealdeer Page Cache"
echo "========================================="
# tealdeer is a Rust-based tldr client — this refreshes its local page cache
tldr --update

echo ""
echo "========================================="
echo "  Updating Mac App Store Apps"
echo "========================================="
# Upgrades all apps installed via the Mac App Store using the mas CLI tool
mas upgrade

echo ""
echo "========================================="
echo "  Updating Ruby Gems"
echo "========================================="
# Uses the Homebrew Ruby gem binary directly to avoid falling back to
# the write-protected macOS system Ruby at /Library/Ruby/Gems/2.6.0
/opt/homebrew/opt/ruby/bin/gem update

echo ""
echo "========================================="
echo "  Cleaning Up Brew's Mess"
echo "========================================="
# Removes old versions of installed formulae and clears the download cache
brew cleanup

echo ""
echo "========================================="
echo "  Running Brew Doctor (Health Check)"
echo "========================================="
# Checks for common Homebrew issues and suggests fixes
# brew doctor -v            #verbose mode
brew doctor

echo ""
echo "========================================="
echo "  All done! System is up to date."
echo "========================================="
