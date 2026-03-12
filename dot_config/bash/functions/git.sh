#!/bin/bash
# Git Utility Functions

## Delete old git branches
function delete_old_branches() {
  local branch last_commit
  local months_ago=${1:-3} # Default to 3 months if no argument is provided.

  git for-each-ref --sort=-committerdate refs/heads/ --format='%(refname:short) %(committerdate:iso8601)' | while read branch last_commit; do
    if [[ $(date -d "$last_commit" +%s) -lt $(date -d "$months_ago months ago" +%s) ]]; then
      echo "Deleting old branch $branch last committed on $last_commit"
      git branch -D "$branch"
    fi
  done
}

## Function to perform an interactive rebase
function irebase() {
  if [ -z "$1" ]; then
    echo "Error: No branch name provided."
    echo "Usage: irebase <branch-name>"
    return 1
  fi

  local branch_name=$1
  git rebase -i $(git merge-base "$branch_name" HEAD)
}

# Function to show commit timestamp
function git-time() {
  git show -s --format=%ci "$1" 2>/dev/null || echo "Invalid commit hash or not in a git repo"
}

gw() {
  local branch="$1"
  if [ -z "$branch" ]; then
    echo "Usage: gw <branch-name>"
    return 1
  fi

  local repo_name=$(basename "$PWD")
  local source_dir="$PWD"
  local target_dir="../${repo_name}-${branch}"

  git worktree add "$target_dir" -b "$branch" || return

  # Copy .env* files
  for f in "$source_dir"/.env*; do
    [ -f "$f" ] && cp "$f" "$target_dir/"
  done

  # Copy additional files listed in .worktree-files (one glob pattern per line)
  if [ -f "$source_dir/.worktree-files" ]; then
    while IFS= read -r pattern || [ -n "$pattern" ]; do
      [[ "$pattern" =~ ^#|^$ ]] && continue
      for f in $source_dir/$pattern; do
        [ -e "$f" ] || continue
        local rel="${f#$source_dir/}"
        mkdir -p "$target_dir/$(dirname "$rel")"
        cp -r "$f" "$target_dir/$rel"
      done
    done < "$source_dir/.worktree-files"
  fi

  cd "$target_dir" || return
}
