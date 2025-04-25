#!/bin/bash

# Prometheus server URL
PROMETHEUS_URL="http://localhost:9090/api/v1/query"

# File containing the list of images (registry and name, no version)
IMAGE_FILE="addons/images.txt"

# Check if the image file exists
if [[ ! -f "$IMAGE_FILE" ]]; then
  echo "Error: Image file '$IMAGE_FILE' not found."
  exit 1
fi

# Initialize variables
OUTDATED_ADDONS=()
UP_TO_DATE_ADDONS=()

# Loop through each image in the file
while IFS= read -r IMAGE; do
  # Query Prometheus for the latest version of the image
  QUERY="version_checker_is_latest_version{image=\"$IMAGE\"}"
  RESPONSE=$(curl -s --get --data-urlencode "query=$QUERY" "$PROMETHEUS_URL")

  # Check if the Prometheus query was successful
  if [[ $? -ne 0 ]]; then
    echo "Error: Failed to query Prometheus for image '$IMAGE'."
    exit 1
  fi

  # Parse the response to check if the image is outdated
  IS_LATEST=$(echo "$RESPONSE" | jq -r '.data.result[0].value[1]')
  CURRENT_VERSION=$(echo "$RESPONSE" | jq -r '.data.result[0].metric.current_version')

  # If the image is not using the latest version, add it to the list of outdated add-ons
  if [[ "$IS_LATEST" == 0 ]]; then
    OUTDATED_ADDONS+=("$IMAGE (current version: $CURRENT_VERSION)")
  else
    UP_TO_DATE_ADDONS+=("$IMAGE (current version: $CURRENT_VERSION)")
  fi
done < "$IMAGE_FILE"

# Output results
if [[ ${#OUTDATED_ADDONS[@]} -gt 0 ]]; then
  echo "Outdated add-ons detected:"
  for ADDON in "${OUTDATED_ADDONS[@]}"; do
    echo "- $ADDON"
  done
  echo "Error: ${#OUTDATED_ADDONS[@]} outdated add-ons detected."
  exit 1
else
  echo "All add-ons are up-to-date:"
  for ADDON in "${UP_TO_DATE_ADDONS[@]}"; do
    echo "- $ADDON"
  done
  echo "All add-ons are up-to-date. Proceeding with deployment."
  exit 0
fi