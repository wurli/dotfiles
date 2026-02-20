#!/bin/bash

INPUT=$(cat)

FILE_PATH=$(echo "$INPUT" | jq -r '.tool_input.file_path // empty')

# Ruff (Python)
if [[ "$FILE_PATH" =~ \.py$ ]]; then
	if command -v ruff &> /dev/null; then
	  ruff format "$FILE_PATH" 2>/dev/null
	  exit 0
	else
	  echo "ruff is not installed. Skipping formatting." >&2
	  exit 0
	fi
fi

# Air (R)
if [[ "$FILE_PATH" =~ \.[rR]$ ]]; then
	if command -v air &> /dev/null; then
	  air format "$FILE_PATH" 2>/dev/null
	  exit 0
	else
	  echo "air is not installed. Skipping formatting." >&2
	  exit 0
	fi
fi
