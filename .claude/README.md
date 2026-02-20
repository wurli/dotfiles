# Claude Code Config

Annoyingly, Claude Code
[currently](https://github.com/anthropics/claude-code/issues/1455) does not
respect the XDG Base Directory specification, so it doesn't make sense to put
this stuff in `.config`. Instead it lives here and needs to be symlinked
separately.

Also, Claude Code puts app data (e.g. session history, todos etc) in the
`~/.claude` folder as config like skills and hooks. This makes versioning the
whole folder in my dotfiles quite dangerous.

Weird that Anthropic hasn't gotten this right yet.

Anyway, create the symlinks like this:

``` sh
DOTFILES_CLAUDE_DIR="$HOME/Repos/dotfiles/.claude"
CLAUDE_HOME="$HOME/.claude"

mkdir -p "$CLAUDE_HOME"

for item in "$DOTFILES_CLAUDE_DIR"/*; do
  [ -e "$item" ] || continue
  filename=$(basename "$item")
  [ "$filename" = "README.md" ] && continue

  target_link="$CLAUDE_HOME/$filename"

  ln -sfF "$item" "$target_link"
  echo "Linked: $filename"
done
```
