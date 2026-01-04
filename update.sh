#!/bin/zsh

# Configuration
OUTPUT_FILE="artifacts.js"
SOURCE_DIR="./src"

echo "--- Generating $OUTPUT_FILE from $SOURCE_DIR directory contents ---"

# Start writing the artifacts.js file structure
cat > "$OUTPUT_FILE" <<- EOL
// --- START BUILD SCRIPT INJECTION ZONE ---
// This array represents the dynamically generated list of artifacts.
const ARTIFACT_DATA_GENERATED = [
EOL

# Enable Zsh extended globbing for recursive search (**) and case-insensitive matching (#i).
# Also enable nullglob: if no files match the pattern, the list is empty.
setopt extendedglob
setopt nullglob

# Check if the source directory exists
if [ ! -d "$SOURCE_DIR" ]; then
    echo "Error: Source directory '$SOURCE_DIR' not found. Please create it and add image files."
    # Output an empty array structure
    cat >> "$OUTPUT_FILE" <<- EOL
];
// --- END BUILD SCRIPT INJECTION ZONE ---
EOL
    exit 1
fi

# Use Zsh globbing to find all files recursively that match common image extensions.
# The pattern **/*.(#i)(...) handles the filtering internally, replacing 'find | grep'.
for FILE_PATH in "$SOURCE_DIR"/**/*.(#i)(jpg|jpeg|png|gif|svg|webp); do

    # Skip files that might not exist if nullglob wasn't enough (safer check)
    if [[ ! -f "$FILE_PATH" ]]; then
        continue
    fi
    
    # 1. Extract the filename with extension
    FILENAME_WITH_EXT="${FILE_PATH##*/}"
    
    # 2. Extract the clean name (filename without extension)
    CLEAN_NAME="${FILENAME_WITH_EXT%.*}"
    
    # 3. Format the path for JavaScript (e.g., './src/file.jpg')
    JS_PATH="./$FILE_PATH"

    # Escape single quotes just in case file names contain them
    ESCAPED_JS_PATH="${JS_PATH//\'/\\\'}"
    ESCAPED_CLEAN_NAME="${CLEAN_NAME//\'/\\\'}"

    # Construct the JavaScript object entry and append to the output file
    printf "    { url: '%s', name: '%s (Image)' },\n" "$ESCAPED_JS_PATH" "$ESCAPED_CLEAN_NAME" >> "$OUTPUT_FILE"
done

# End the JavaScript file structure
cat >> "$OUTPUT_FILE" <<- EOL
];
// --- END BUILD SCRIPT INJECTION ZONE ---
EOL

echo "--- Generation complete. File written to $OUTPUT_FILE ---"
