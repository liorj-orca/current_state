#!/bin/bash

# GitHub repository details
REPO=$1
BRANCH=$2
TITLE=$3
BODY=$4

# Generate a random string for the branch name
RANDOM_BRANCH=$(cat /dev/urandom | tr -dc 'a-zA-Z0-9' | fold -w 10 | head -n 1)

# Create a new branch
git checkout -b $RANDOM_BRANCH

# Make changes to the repository
# For demonstration purposes, echo some content to a file
echo "Changes" >> changes.txt

# Add and commit changes
git add .
git commit -m "Automated changes"

# Push the branch to GitHub
git push origin $RANDOM_BRANCH

# Create a pull request
curl -X POST \
    -H "Authorization: token $GITHUB_TOKEN" \
    -d '{ "title": "'"$TITLE"'", "body": "'"$BODY"'", "head": "'"$RANDOM_BRANCH"'", "base": "'"$BRANCH"'" }' \
    "https://api.github.com/repos/$REPO/pulls"
