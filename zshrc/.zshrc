# Disable RVM auto-loading to prevent PATH conflicts
export rvm_ignore_rvmrc=1

if [[ "$(uname)" == "Darwin" ]]; then
  # Oh My Zsh
  export ZSH="$HOME/.oh-my-zsh"
  ZSH_THEME=""
  plugins=(git)
  source $ZSH/oh-my-zsh.sh

  # Mac aliases
  alias run_fastlane='bundle exec fastlane'
  alias which_xcode='/usr/bin/xcodebuild -version'

  # Mac paths
  path=(/opt/homebrew/bin $path)
  path=($HOME/Documents/scripts $path)
  export PATH="$(brew --prefix)/opt/make/libexec/gnubin:$PATH"

  # Mamba / Conda
  export MAMBA_EXE="$HOME/miniforge3/bin/mamba"
  export MAMBA_ROOT_PREFIX="$HOME/miniforge3"
  __mamba_setup="$("$MAMBA_EXE" shell hook --shell zsh --root-prefix "$MAMBA_ROOT_PREFIX" 2> /dev/null)"
  if [ $? -eq 0 ]; then
    eval "$__mamba_setup"
  else
    alias mamba="$MAMBA_EXE"
  fi
  unset __mamba_setup

  __conda_setup="$("$HOME/miniforge3/bin/conda" 'shell.zsh' 'hook' 2> /dev/null)"
  if [ $? -eq 0 ]; then
    eval "$__conda_setup"
  else
    if [ -f "$HOME/miniforge3/etc/profile.d/conda.sh" ]; then
      . "$HOME/miniforge3/etc/profile.d/conda.sh"
    else
      export PATH="$HOME/miniforge3/bin:$PATH"
    fi
  fi
  unset __conda_setup

  # Pure prompt (Mac — with nearcolor for hex support)
  autoload -U promptinit; promptinit
  zmodload zsh/nearcolor
  zstyle :prompt:pure:git:branch color '#F9ECB6'
  zstyle :prompt:pure:git:branch:cached color '#F9ECB6'
  prompt pure

  cd ~/Documents

elif [[ "$(uname)" == "Linux" ]]; then
  export PATH="$HOME/.local/bin:$PATH"

  # Pure prompt (Linux)
  autoload -U promptinit; promptinit
  prompt pure

  cd ~/projects
fi

# ── Common aliases (Mac + Linux) ─────────────────────────────────────────────

alias ..="cd .."
alias c='clear'
alias hist='history | grep -i'
alias szsh='source ~/.zshrc'

# Git
alias ga='git add '
alias gs='git status'
alias gp='git push'
alias grs='git reset --soft "HEAD@{2}"'
alias grh='git reset --hard "HEAD@{2}"'

gcom() { git commit -S -m "$1"; }
gres() { git restore --staged "$1"; }
delete_all_local_branch() { git branch --merged | grep -v \* | xargs git branch -D; }
lgrep() { ls | grep "$1"; }

which_alias() {
  echo "--- Aliases from ~/.zshrc ---"
  grep '^alias ' ~/.zshrc
  echo ""
  echo "--- Functions from ~/.zshrc ---"
  typeset -f gcom
  typeset -f gres
  typeset -f delete_all_local_branch
  typeset -f lgrep
}

function grebase() {
  if ! git rev-parse --is-inside-work-tree > /dev/null 2>&1; then
    echo "Error: You are not inside a Git repository."
    return 1
  fi

  local current_branch=$(git rev-parse --abbrev-ref HEAD)
  local target_branch="develop"

  if [[ -n "$1" ]]; then
    target_branch="$1"
  fi

  if [[ "$current_branch" == "$target_branch" ]]; then
    echo "You are on '$current_branch'. Switch to a feature branch first."
    return 1
  fi

  if ! git diff-index --quiet HEAD --; then
    echo "❌ Uncommitted changes. Commit or stash before rebasing."
    return 1
  fi

  printf "Rebase '%s' onto 'origin/%s'? (yes/no): " "$current_branch" "$target_branch"
  read confirmation
  case "$confirmation" in
    [yY][eE][sS]) echo "Proceeding..." ;;
    *) echo "Aborted."; return 1 ;;
  esac

  git fetch origin "$target_branch" || { echo "Fetch failed."; return 1; }

  if git rebase "origin/$target_branch"; then
    echo "✅ Rebase successful."
  else
    echo "❌ Conflicts detected. Resolve then run 'git rebase --continue'."
    return 1
  fi
}

export GPG_TTY=$(tty)

[ -f "$HOME/.local/bin/env" ] && . "$HOME/.local/bin/env"
