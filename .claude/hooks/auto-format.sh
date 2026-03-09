#!/bin/bash

FILE_PATH="$CLAUDE_TOOL_INPUT_file_path"

# Ruff (Python)
if [[ "$FILE_PATH" =~ \.py$ ]]; then
	if command -v ruff &> /dev/null; then
	  ruff check --fix --unsafe-fixes "$FILE_PATH" 2>/dev/null
	  ruff format "$FILE_PATH" 2>/dev/null
	  exit 0
	else
	  echo "ruff command not found. Skipping formatting." >&2
	  exit 0
	fi
fi

# Air (R)
if [[ "$FILE_PATH" =~ \.[rR]$ ]]; then
	if command -v air &> /dev/null; then
	  air format "$FILE_PATH" 2>/dev/null
	  exit 0
	else
	  echo "air command not found. Skipping formatting." >&2
	  exit 0
	fi
fi

# Stylua (Lua)
if [[ "$FILE_PATH" =~ \.lua$ ]]; then
	if command -v stylua &> /dev/null; then
	  stylua "$FILE_PATH" 2>/dev/null
	  exit 0
	else
	  echo "stylua command not found. Skipping formatting." >&2
	  exit 0
	fi
fi
