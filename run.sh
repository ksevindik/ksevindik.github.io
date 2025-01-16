#!/bin/bash

# Directory containing the files (update if needed)
directory="."

# Iterate through files matching the pattern
for file in "$directory"/*.md; do
  # Skip if no files match
  [[ -e "$file" ]] || continue

  # Extract the base filename
  filename=$(basename "$file")

  # Match the yyyyMMdd_title.md pattern
  if [[ "$filename" =~ ^([0-9]{4})([0-9]{2})([0-9]{2})_(.+)\.md$ ]]; then
    # Extract parts of the filename
    year="${BASH_REMATCH[1]}"
    month="${BASH_REMATCH[2]}"
    day="${BASH_REMATCH[3]}"
    title="${BASH_REMATCH[4]}"

    # Create the new filename
    new_filename="${year}-${month}-${day}-${title}.md"

    # Rename the file
    mv "$file" "$directory/$new_filename"
    echo "Renamed: $filename -> $new_filename"
  else
    echo "Skipped: $filename (does not match the pattern)"
  fi
done

echo "Renaming complete."

