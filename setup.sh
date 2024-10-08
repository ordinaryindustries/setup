#!/bin/zsh

# Function to print messages
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

echo "Enter your git email:"
read git_email
echo "Enter your git username"
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
brew insall jq

# TODO: Poetry?

# Virtual environments
pip install virtualenvwrapper
echo "" >> ~/.zshrc
echo "# Virtualenvs" >> ~/.zshrc
echo "export WORKON_HOME=$HOME/.virtualenvs" >> ~/.zshrc
echo "export PROJECT_HOME=$HOME/Devel" >> ~/.zshrc
python_path=$(which python)
echo "export VIRTUALENVWRAPPER_PYTHON=$python_path" >> ~/.zshrc
echo "source ~/.pyenv/versions/$latest_python_version/bin/virtualenvwrapper.sh" >> ~/.zshrc


# =========================
# MAC CONFIG
# =========================
# Set dock to the left edge
defaults write com.apple.dock "orientation" -string "left" 

# Set dock icons size
defaults write com.apple.dock "tilesize" -int "24"

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

# iTerm2
echo "Installing iTerm2"
brew install --cask iterm2

# Visual Studio Code
echo "Installing Visual Studio Code"
brew install --cask visual-studio-code

if confirm "Ensure you have logged into the App Store at least once and then press any key to continue"; then
  print_message "Installing apps from Mac App Store"
else
  echo "Installation canceled"
  exit 1
fi

# Xcode
mas install 497799835
sudo xcodebuild -license accept

# =========================
# Git
# =========================
print_message "Configuring Git"
git config --global user.email $git_email
git config --global user.name $git_username

# =========================
# GPG
# =========================
print_message "Configuring GPG"
brew install gnupg
gpg --full-generate-key

# =========================
# FINISH
# =========================
print_message "Reloading shell configuration"
source ~/.zshrc

print_message "Job's done"
