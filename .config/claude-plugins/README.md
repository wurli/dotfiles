This directory functions as a private
['marketplace'](https://code.claude.com/docs/en/plugin-marketplaces)
for Claude Code plugins.

It seems that certain config, e.g. LSP integration, can't be done any other
way.

This marketplace needs to be recorded in `~/.claude/plugins/`:

```
/plugin marketplace add ~/.config/claude-plugins
```

Or alternatively, you can just tell use the `--plugin-dir` arg to Claude Code
(which I normally do)

