#!/bin/bash

echo "Checking out branch '$1' and pulling..."
git checkout $1
if [[ ! $? -eq 0 ]]; then
  echo
  echo "Unable to checkout branch, aborting."
  exit
fi
git pull
echo "Pruning dead remote branch pointers..."
git fetch --prune

# get list of remote branch names, find all local branch names which aren't in the list of remote names (inverse grep)
DEAD_BRANCHES=$(git branch --remotes | awk '{print $1}' | egrep --invert-match --file=/dev/fd/0 <(git branch -vv) | awk '{print $1}')
#convert newline string to bash array
IFS=$'\n' read -r -a DEAD_BRANCHES_ARRAY <<< "$DEAD_BRANCHES"

DEAD_BRANCH_COUNT=${#DEAD_BRANCHES_ARRAY[@]}
if [[ "$DEAD_BRANCH_COUNT" -lt 1 ]]; then
  echo
  echo "No branches to clean, exiting"
  exit
fi

echo
echo "Found $DEAD_BRANCH_COUNT local branches to delete:"
for branch in ${DEAD_BRANCHES_ARRAY[@]}; do
  echo "  $branch"
done
echo
read -p "Are you sure? [y/n] " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
  for branch in ${DEAD_BRANCHES_ARRAY[@]}; do
    git branch -D $branch
  done
else
  echo Aborting
fi

