#!/bin/bash

# Directory to scan files
DIRECTORY=${1:-.}

# Check if the directory exists
if [ ! -d "$DIRECTORY" ]; then
  echo "Directory $DIRECTORY does not exist."
  exit 1
fi

# Iterate over files in the directory
find "$DIRECTORY" -type f | while IFS= read -r file; do
  sed -i '' 's|src="images/|(src="http://kenansevindik.com/assets/images/|g' "$file"
done

echo "Replacement completed in all files under $DIRECTORY."

