---
layout: post
title: !/bin/bash
author: Kenan Sevindik
---

# Loop through all regular files in the current directory
find . -maxdepth 1 -type f | while IFS= read -r file; do
  # Remove the leading ./ for cleaner output
  clean_file="${file#./}"

  # Extract the first line starting with #
  first_line=$(grep -m 1 '^#' "$file")
  if [[ -z "$first_line" ]]; then
    echo "Skipping '$clean_file': No line starting with '#' found."
    continue
  fi

  # Remove the leading # and any extra spaces to form the title
  title=$(echo "$first_line" | sed 's/^# *//')

  # Create the new block with the title
  new_block=$(printf '%s\n' "---" "layout: post" "title: $title" "author: Kenan Sevindik" "---")

  # Use a temporary file for safe replacement
  tmp_file=$(mktemp)

  # Write the new block and the rest of the file content, skipping the first # line
  {
    printf '%s\n' "$new_block"
    awk 'NR == 1 && /^#/ {next} {print}' "$file"
  } > "$tmp_file"

  # Overwrite the original file
  mv "$tmp_file" "$file"

  echo "Processed '$clean_file': Updated with title '$title'."
done
