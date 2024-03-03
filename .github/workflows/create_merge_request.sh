#!/bin/bash

# GitLab API details
GITLAB_API_URL="https://gitlab.example.com/api/v4"
PROJECT_ID="your_project_id"
SOURCE_BRANCH="feature-branch"
TARGET_BRANCH="main"
API_TOKEN="your_api_token"

# Create Merge Request
create_mr_response=$(curl --request POST --header "PRIVATE-TOKEN: $API_TOKEN" \
  --data "source_branch=$SOURCE_BRANCH" \
  --data "target_branch=$TARGET_BRANCH" \
  "$GITLAB_API_URL/projects/$PROJECT_ID/merge_requests")

# Extract Merge Request ID from the response
MR_ID=$(echo "$create_mr_response" | jq -r '.id')

echo "Merge Request created successfully. ID: $MR_ID"

# Modify existing file and add test secret
file_content=$(curl --header "PRIVATE-TOKEN: $API_TOKEN" \
  "$GITLAB_API_URL/projects/$PROJECT_ID/repository/files/test.py?ref=$SOURCE_BRANCH" | jq -r '.content')

# Add the test secret to the file content
new_content="$file_content\n# Added by CI/CD\nTEST_SECRET = 'your_test_secret'\n"

# Update the file with the new content
update_file_response=$(curl --request PUT --header "PRIVATE-TOKEN: $API_TOKEN" \
  --data-urlencode "branch=$SOURCE_BRANCH" \
  --data-urlencode "content=$new_content" \
  --data "commit_message=Add test secret" \
  "$GITLAB_API_URL/projects/$PROJECT_ID/repository/files/test.py")

echo "File updated with test secret."

# Wait for pipeline to succeed or timeout
timeout_seconds=60
end_time=$((SECONDS + timeout_seconds))

while [ $SECONDS -lt $end_time ]; do
  pipeline_status=$(curl --header "PRIVATE-TOKEN: $API_TOKEN" \
    "$GITLAB_API_URL/projects/$PROJECT_ID/pipelines?ref=$SOURCE_BRANCH" | jq -r '.[0].status')

  if [ "$pipeline_status" == "success" ]; then
    echo "111111"  # Pipeline succeeded!
    exit 0
  elif [ "$pipeline_status" == "failed" ] || [ "$pipeline_status" == "canceled" ]; then
    echo "222222"  # Pipeline failed or was canceled.
    exit 1
  else
    echo "Pipeline status: $pipeline_status. Waiting for success..."
    sleep 5  # Adjust the sleep interval as needed
  fi
done

echo "222222"  # Timeout reached.
exit 1
