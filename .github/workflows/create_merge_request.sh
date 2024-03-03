#!/bin/bash

# GitLab repository details
REPO=$1
BRANCH=$2
TITLE=$3
BODY=$4

# Clone the repository
git clone "https://gitlab.com/$REPO" temp_repo
cd temp_repo

# Make changes to the repository
# For demonstration purposes, let's edit an existing file
echo "Changes" >> existing_file.txt

# Add and commit changes
git add existing_file.txt
git commit -m "Automated changes"

# Generate a random string for the branch name
RANDOM_BRANCH=$(cat /dev/urandom | tr -dc 'a-zA-Z0-9' | fold -w 10 | head -n 1)

# Create a new branch
git checkout -b $RANDOM_BRANCH

# Push the branch to GitLab
git push origin $RANDOM_BRANCH

# Create a merge request
curl --request POST \
     --header "PRIVATE-TOKEN: $GITLAB_TOKEN" \
     --header "Content-Type: application/json" \
     --data '{
         "source_branch": "'"$RANDOM_BRANCH"'",
         "target_branch": "'"$BRANCH"'",
         "title": "'"$TITLE"'",
         "description": "'"$BODY"'"
     }' \
     "https://gitlab.com/api/v4/projects/$REPO/merge_requests"

# Cleanup: Remove temporary cloned repository
cd ..
rm -rf temp_repo
