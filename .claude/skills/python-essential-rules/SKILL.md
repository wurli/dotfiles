---
name: python-essential-rules
description: Rules you should ALWAYS follow when working with Python
---

I prefer to use Astral's suite of python development tools when possible:

## `uv`

Use `uv` for project management:

*   `uv init` starts a new project
*   `uv add <library>` includes a new dependency
*   `uv run <shell command>` runs commands using the project's Python environment

See the [uv docs](https://docs.astral.sh/uv/) for more information.

## `ty`/`ruff`

Astral's type checker/language server `ty`, and their linter/formatter `ruff`
should be configured as hooks, so you don't need to worry about these.
