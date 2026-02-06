#!/bin/bash
# Build script for daily-eth-knowledge
# Converts markdown lessons to HTML and updates index

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(dirname "$SCRIPT_DIR")"
LESSONS_DIR="$ROOT_DIR/lessons"
TEMPLATE="$ROOT_DIR/templates/lesson.html"

# Create lessons directory if needed
mkdir -p "$LESSONS_DIR"

# Build index.json from markdown files
echo "Building lesson index..."
INDEX="[]"

for md in "$LESSONS_DIR"/*.md; do
    [ -f "$md" ] || continue
    
    filename=$(basename "$md" .md)
    
    # Extract metadata from frontmatter
    title=$(grep -m1 "^title:" "$md" | sed 's/title: *//' | tr -d '"')
    date=$(grep -m1 "^date:" "$md" | sed 's/date: *//' | tr -d '"')
    lesson_num=$(grep -m1 "^lesson:" "$md" | sed 's/lesson: *//' | tr -d '"')
    
    # Add to index
    INDEX=$(echo "$INDEX" | jq --arg file "${filename}.html" \
        --arg title "$title" \
        --arg date "$date" \
        --arg num "$lesson_num" \
        '. + [{"file": $file, "title": $title, "date": $date, "number": ($num | tonumber)}]')
done

# Sort by lesson number descending (newest first)
echo "$INDEX" | jq 'sort_by(.number) | reverse' > "$LESSONS_DIR/index.json"

echo "Index updated with $(echo "$INDEX" | jq length) lessons"
