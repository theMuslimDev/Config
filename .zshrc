# If you come from bash you might have to change your $PATH.
# export PATH=$HOME/bin:$HOME/.local/bin:/usr/local/bin:$PATH

# Path to your Oh My Zsh installation.
export ZSH="$HOME/.oh-my-zsh"

# Set name of the theme to load --- if set to "random", it will
# load a random theme each time Oh My Zsh is loaded, in which case,
# to know which specific one was loaded, run: echo $RANDOM_THEME
# See https://github.com/ohmyzsh/ohmyzsh/wiki/Themes
ZSH_THEME="robbyrussell"

# Set list of themes to pick from when loading at random
# Setting this variable when ZSH_THEME=random will cause zsh to load
# a theme from this variable instead of looking in $ZSH/themes/
# If set to an empty array, this variable will have no effect.
# ZSH_THEME_RANDOM_CANDIDATES=( "robbyrussell" "agnoster" )

# Uncomment the following line to use case-sensitive completion.
# CASE_SENSITIVE="true"

# Uncomment the following line to use hyphen-insensitive completion.
# Case-sensitive completion must be off. _ and - will be interchangeable.
# HYPHEN_INSENSITIVE="true"

# Uncomment one of the following lines to change the auto-update behavior
# zstyle ':omz:update' mode disabled  # disable automatic updates
# zstyle ':omz:update' mode auto      # update automatically without asking
# zstyle ':omz:update' mode reminder  # just remind me to update when it's time

# Uncomment the following line to change how often to auto-update (in days).
# zstyle ':omz:update' frequency 13

# Uncomment the following line if pasting URLs and other text is messed up.
# DISABLE_MAGIC_FUNCTIONS="true"

# Uncomment the following line to disable colors in ls.
# DISABLE_LS_COLORS="true"

# Uncomment the following line to disable auto-setting terminal title.
# DISABLE_AUTO_TITLE="true"

# Uncomment the following line to enable command auto-correction.
# ENABLE_CORRECTION="true"

# Uncomment the following line to display red dots whilst waiting for completion.
# You can also set it to another string to have that shown instead of the default red dots.
# e.g. COMPLETION_WAITING_DOTS="%F{yellow}waiting...%f"
# Caution: this setting can cause issues with multiline prompts in zsh < 5.7.1 (see #5765)
# COMPLETION_WAITING_DOTS="true"

# Uncomment the following line if you want to disable marking untracked files
# under VCS as dirty. This makes repository status check for large repositories
# much, much faster.
# DISABLE_UNTRACKED_FILES_DIRTY="true"

# Uncomment the following line if you want to change the command execution time
# stamp shown in the history command output.
# You can set one of the optional three formats:
# "mm/dd/yyyy"|"dd.mm.yyyy"|"yyyy-mm-dd"
# or set a custom format using the strftime function format specifications,
# see 'man strftime' for details.
# HIST_STAMPS="mm/dd/yyyy"

# Would you like to use another custom folder than $ZSH/custom?
# ZSH_CUSTOM=/path/to/new-custom-folder

# Which plugins would you like to load?
# Standard plugins can be found in $ZSH/plugins/
# Custom plugins may be added to $ZSH_CUSTOM/plugins/
# Example format: plugins=(rails git textmate ruby lighthouse)
# Add wisely, as too many plugins slow down shell startup.
plugins=(git)

source $ZSH/oh-my-zsh.sh

# User configuration
eval "$(rbenv init - zsh)"

# Common command aliases
alias ..="cd .."
alias c='clear'
alias hist='history | grep -i'
alias run_fastlane='bundle exec fastlane'
alias szsh='source ~/.zshrc'
alias which_xcode='/usr/bin/xcodebuild -version'

# Git
alias ga='git add '
alias gs='git status'
alias gp='git push'
gcom() { git commit -S -m "$1"; }
gres() { git restore --staged "$1"; }
delete_all_local_branch() { git branch --merged | grep -v \* | xargs git branch -D; }
lgrep() { ls | grep "$1"; }

# Function to rebase the current branch onto origin/develop
# Usage: grebase
function grebase() {
  '
  grebase: Rebase your current Git branch onto another branch.

  Usage:
    grebase [target_branch]

  Arguments:
    target_branch (optional): The branch to rebase onto (e.g., `main`, `feature/xyz`).
                              Defaults to `develop` if not specified.

  Examples:
    - `grebase`         : Rebases current branch onto `origin/develop`.
    - `grebase main`    : Rebases current branch onto `origin/main`.

  Note: Requires confirmation (type `yes`) before proceeding.
  '
  
  # Check if we are inside a Git repository
  if ! git rev-parse --is-inside-work-tree > /dev/null 2>&1; then
    echo "Error: You are not inside a Git repository."
    return 1
  fi

  local current_branch=$(git rev-parse --abbrev-ref HEAD)
  local target_branch="develop" # Default rebase target branch

  # Check for an argument to set the target branch
  if [[ -n "$1" ]]; then
    target_branch="$1"
  fi

  # Prevent rebasing the target branch onto itself
  if [[ "$current_branch" == "$target_branch" ]]; then
    echo "You are currently on the '$current_branch' branch."
    echo "Rebasing '$current_branch' onto itself is usually not what you want."
    echo "Please switch to your feature branch (e.g., 'git switch my-feature-branch') before running this command."
    return 1
  fi

  # Abort if there are uncommitted changes
  if ! git diff-index --quiet HEAD --; then
    echo ""
    echo "❌ Aborting rebase: Your working directory has uncommitted changes."
    echo "Please commit or stash your changes before running this command:"
    echo "  - To commit: git add . && git commit -m 'WIP: Before rebase'"
    echo "  - To stash: git stash push -m 'WIP: Before rebase'"
    echo "Then try 'grd' again."
    return 1
  fi

  echo "--- Git Rebase Helper ---"
  echo "Current branch: $current_branch"
  echo "Target branch for rebase: origin/$target_branch"
  echo ""

  # Confirmation step (more compatible way)
  # Using printf for the prompt and then read for input
  printf "Do you want to rebase '%s' onto 'origin/%s'? (yes/no): " "$current_branch" "$target_branch"
  read confirmation
  case "$confirmation" in
    [yY][eE][sS])
      echo "Proceeding with rebase..."
      ;;
    *)
      echo "Rebase aborted by user."
      return 1
      ;;
  esac

  echo "Fetching the latest '$target_branch' from 'origin'..."

  # Fetch the latest target branch from the 'origin' remote
  if ! git fetch origin "$target_branch"; then
    echo "Error: Failed to fetch 'origin/$target_branch'."
    echo "Please check your network connection or your Git remote setup."
    return 1
  fi

  echo "Attempting to rebase '$current_branch' onto 'origin/$target_branch'..."

  # Perform the rebase
  if git rebase "origin/$target_branch"; then
    echo ""
    echo "✅ Rebase successful! Your branch '$current_branch' is now rebased onto 'origin/$target_branch'."
    echo "You can now push your changes (e.g., 'git push --force-with-lease' if you've rewritten history)."
  else
    echo ""
    echo "❌ Rebase failed. Conflicts detected or another issue occurred."
    echo "Please resolve any conflicts shown above, then run 'git rebase --continue'."
    echo "If you wish to abort the rebase, run 'git rebase --abort'."
    return 1 # Indicate failure
  fi
}

cd ~/Documents

# export MANPATH="/usr/local/man:$MANPATH"

# You may need to manually set your language environment
# export LANG=en_US.UTF-8

# Preferred editor for local and remote sessions
# if [[ -n $SSH_CONNECTION ]]; then
#   export EDITOR='vim'
# else
#   export EDITOR='nvim'
# fi

# Compilation flags
# export ARCHFLAGS="-arch $(uname -m)"

# Set personal aliases, overriding those provided by Oh My Zsh libs,
# plugins, and themes. Aliases can be placed here, though Oh My Zsh
# users are encouraged to define aliases within a top-level file in
# the $ZSH_CUSTOM folder, with .zsh extension. Examples:
# - $ZSH_CUSTOM/aliases.zsh
# - $ZSH_CUSTOM/macos.zsh
# For a full list of active aliases, run `alias`.
#
# Example aliases
# alias zshconfig="mate ~/.zshrc"
# alias ohmyzsh="mate ~/.oh-my-zsh"
