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
# --greedy also upgrades casks that have built-in auto-update mechanisms,
# ensuring everything gets updated regardless of how it manages itself
brew upgrade --greedy

echo ""
echo "========================================="
echo "  Verifying Brewfile Packages Are Present"
echo "========================================="
# Checks that every package listed in the Brewfile is installed.
# Does NOT install or downgrade anything — purely a presence check.
# If anything is missing (e.g. accidentally removed), it will be reported.
# To install any missing packages manually: brew bundle install
if brew bundle check --verbose; then
    echo "All Brewfile packages are present."
else
    echo ""
    echo "  Some Brewfile packages are missing. Installing them now..."
    brew bundle install
fi

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
# Ruby and its bundled gems are managed by Homebrew via `brew upgrade --greedy`
# above. Running `gem update` separately causes a version conflict where
# rdoc 7.2.0 gets reinstalled alongside Ruby's bundled rdoc 7.0.4, producing
# constant redefinition warnings on every gem invocation. Homebrew is the
# correct update mechanism for this Ruby installation.
echo "Ruby is managed by Homebrew — gems updated via brew upgrade above."

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
echo "  Regenerating Brewfile"
echo "========================================="
# Rebuilds ~/Brewfile from scratch to reflect the current installed state:
# all formulae, casks, App Store apps, and VS Code extensions.
# This ensures the Brewfile stays accurate after upgrades and any manual
# installs/removals since the last run. --force overwrites the existing file.
brew bundle dump --force --file="$HOME/Brewfile"
echo "Brewfile updated at ~/Brewfile"

echo ""
echo "========================================="
echo "  All done! System is up to date."
echo "========================================="
