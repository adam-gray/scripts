#!/bin/bash

# get list of branch names, omitting the one you're currently on with *
LOCAL_BRANCHES=$(git branch | grep -iv -e 'staging/' -e 'release/' -e '*')

# convert newline string to bash array
IFS=$'\n' read -r -d '' -a LOCAL_BRANCHES_ARRAY <<< "$LOCAL_BRANCHES"
BRANCH_COUNT=${#LOCAL_BRANCHES_ARRAY[@]}


# if there are no other branches, exit
if [[ $BRANCH_COUNT -eq 0 ]]; then
  echo "No other branches to delete"
  exit
fi


cmd=(dialog --stdout --no-items \
        --separate-output \
        --ok-label "Delete" \
        --checklist "Select local branches to delete:" 0 0 0)
TO_DELETE=$("${cmd[@]}" $(printf '%s\n' "${LOCAL_BRANCHES[@]}" | awk '{print $1, "off"}'))

for branch in ${TO_DELETE[@]}; do
    git branch -d $branch
done

