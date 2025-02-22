#!/bin/zsh

# =========================
# HELPERS
# =========================
print_message() {
  echo "$1"
}

confirm() {
  while true; do
    read "response?$1 (y/n): "
    case $response in
      [Yy]* ) return 0;;  # User chose yes
      [Nn]* ) return 1;;  # User chose no
      * ) echo "Please answer yes (y) or no (n).";;
    esac
  done
}

# =========================
# SETUP
# =========================
# Check if ZSH is installed
if ! command -v zsh &> /dev/null; then
  print_message "zsh is not installed. Please install zsh and try again."
  exit 1
fi

print_message "Enter your admin password:"
sudo -v

print_message "Enter your git email:"
read git_email
print_message "Enter your git username"
read git_username

# =========================
# HOMEBREW
# =========================
print_message "Installing Homebrew"
NONINTERACTIVE=1 /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

# Add brew to PATH
echo 'eval "$(/opt/homebrew/bin/brew shellenv)"' >> ~/.zprofile

# Reload shell
eval "$(/opt/homebrew/bin/brew shellenv)"


# =========================
# Development
# =========================
# PyEnv
print_message "Installing PyEnv"
brew install -q pyenv
echo '' >> ~/.zshrc
echo '# PyEnv' >> ~/.zshrc
echo 'export PYENV_ROOT="$HOME/.pyenv"' >> ~/.zshrc
echo '[[ -d $PYENV_ROOT/bin ]] && export PATH="$PYENV_ROOT/bin:$PATH"' >> ~/.zshrc
echo 'eval "$(pyenv init -)"' >> ~/.zshrc

# Python
print_message "Installing the latest Python version using pyenv"
latest_python_version=$(pyenv install --list | grep -E '^\s*[0-9]+(\.[0-9]+)*$' | tail -1 | tr -d ' ')
pyenv install -f $latest_python_version
pyenv global $latest_python_version

# Watch
brew install watch

# JQ
brew install jq

# =========================
# MAC CONFIG
# =========================
# Dockutil
brew install dockutil

# Clear Dock
echo "Clearing and configuring Dock"
dockutil --remove com.apple.launchpad.launcher
dockutil --remove com.apple.Maps
dockutil --remove com.apple.Photos
dockutil --remove com.apple.FaceTime
dockutil --remove com.apple.Calendar
dockutil --remove com.apple.AddressBook
dockutil --remove com.apple.reminders
dockutil --remove com.apple.Notes
dockutil --remove com.apple.freeform
dockutil --remove com.apple.TV
dockutil --remove com.apple.news
dockutil --remove com.apple.AppStore
dockutil --remove com.apple.systempreferences
dockutil --remove '~/Downloads'
dockutil --remove spacer-tiles

# Set dock to the left edge
defaults write com.apple.dock "orientation" -string "left" 

# Set dock icons size
defaults write com.apple.dock "tilesize" -int "40"

# Enable dock autohide
defaults write com.apple.dock "autohide" -bool "true"

# Show dock instantly
defaults write com.apple.dock "autohide-delay" -float "0"
defaults write com.apple.dock "autohide-time-modifier" -float "0"

# Disable Spaces automatic rearranging
defaults write com.apple.dock "mru-spaces" -bool "false"

# Restart the dock
killall Dock

# Don't show screenshot preview
defaults write com.apple.screencapture "show-thumbnail" -bool "false"

# Set finder view mode to columns
defaults write com.apple.finder "FXPreferredViewStyle" -string "clmv"

# Delete trash items after 30 days
defaults write com.apple.finder "FXRemoveOldTrashItems" -bool "true"

# Restart Finder
killall Finder

# =========================
# Oh My ZSH
# =========================
# Install plugins
print_message "Configuring Oh My ZSH "
git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions
git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting
git clone https://github.com/ohmyzsh/ohmyzsh/tree/master/plugins/kubectl ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/kubectl
git clone https://github.com/ohmyzsh/ohmyzsh/tree/master/plugins/doctl ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/doctl
git clone https://github.com/ohmyzsh/ohmyzsh/tree/master/plugins/docker ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/docker
git clone https://github.com/ohmyzsh/ohmyzsh/tree/master/plugins/gitignore ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/gitignore

# =========================
# Hush Login
# =========================
touch ~/.hushlogin

# =========================
# VIM
# =========================
print_message "Configuring VIM"
touch ~/.vimrc
echo "set number" >> ~/.vimrc
echo "syntax on" >> ~/.vimrc

# =========================
# Apps
# =========================
# Installing apps from brew.
# Install mas utility
print_message "Installing mas utility"
brew install mas

# Ghostty
print_message "Installing Ghostty"
brew install --cask ghostty

# Visual Studio Code
print_message "Installing Visual Studio Code"
brew install --cask visual-studio-code

# Launch App Store to ensure we can install MAS apps.
open -a /System/Applications/App\ Store.app

# Kill App Store after a brief wait.
sleep 10
killall App\ Store

# Install public Xcode
mas install 497799835
sudo xcodebuild -license accept

# Install Helm for App Store Connect
mas install 6479357934

# Install RevenueCat Dashboard
mas install 1544144499

# Install Slurp
mas install 1287239339

# Install Affinity Photo
mas install 1616822987

# Install Pipifier
mas install 1160374471

# Install Testflight
mas install 899247664

# Install Apple Developer
mas install 640199958

# Install Logic Pro X
mas install 634148309

# Install Final Cut Pro X
mas install 424389933

# =========================
# Git
# =========================
print_message "Configuring Git"
git config --global user.email $git_email
git config --global user.name $git_username

# =========================
# Setup Dock
# =========================
dockutil --add /Applications/Ghostty.app
dockutil --add /Applications/Visual\ Studio\ Code.app
dockutil --add /Applications/Xcode.app

# =========================
# Open URLS
# =========================
declare -a arr=(
  "https://x.com"
  "https://bsky.app"
  "https://medium.com"
  "https://substack.com"
  "https://appstoreconnect.apple.com"
  "https://reddit.com"
  "https://buffer.com"
)

for url in "${arr[@]}"
do
  open $url
done

# Install Oh My ZSH
print_message "Installing Oh My ZSH"
sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"

# =========================
# FINISH
# =========================
print_message "Reloading shell configuration"
source ~/.zshrc

print_message "Job's done. Reload your shell to complete setup."
