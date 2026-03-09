#!/bin/bash

# Hook to discourage pip usage
# Warns if 'pip' is used as a direct command (not as a subcommand of uv)

cmd="$CLAUDE_TOOL_INPUT_command"

# Skip if empty or if it's 'uv pip'
[[ -z "$cmd" ]] && exit 0
[[ "$cmd" =~ uv[[:space:]]+pip ]] && exit 0

# Check for pip/pip3 as a command (word boundary check)
if echo "$cmd" | grep -qE '(^|[[:space:]]|&&|\||;)pip3?([[:space:]]|$)' || \
   echo "$cmd" | grep -qE 'python3?[[:space:]]+-m[[:space:]]+pip'; then
  echo "Use of pip is highly discouraged. Please use uv instead if possible." >&2
fi
