# Path to your Oh My Zsh installation.
export ZSH="$HOME/.oh-my-zsh"

# NOTE: ZSH_THEME is intentionally left empty because the Pure Prompt is used instead.
# Oh My Zsh's theme system is bypassed when a custom prompt like Pure is loaded directly.
ZSH_THEME=""

# Which plugins would you like to load?
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

# Git Reset Aliases for convenience after rebase or similar operations
alias grs='git reset --soft "HEAD@{2}"'
alias grh='git reset --hard "HEAD@{2}"'

which_alias() {
  echo "--- Your Aliases from ~/.zshrc ---"
  grep '^alias ' ~/.zshrc

  echo ""
  echo "--- Your Functions from ~/.zshrc ---"
  typeset -f gcom
  typeset -f gres
  typeset -f delete_all_local_branch
  typeset -f lgrep
  typeset -f grebase # Added to display grebase function definition
}

# Function to rebase the current branch onto origin/develop
# Usage: grebase [target_branch]
function grebase() {
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

# Pure Prompt Configuration
# NOTE: To use the Pure Prompt, you need to download and install it separately.
# Pure is a popular Zsh prompt that offers a clean and minimalist look.
autoload -U promptinit; promptinit
# Load the nearcolor module for hexadecimal color support
zmodload zsh/nearcolor

# Set the Git branch color
zstyle :prompt:pure:git:branch color '#F9ECB6'
zstyle :prompt:pure:git:branch:cached color '#F9ECB6'
prompt pure
cd ~/Documents
