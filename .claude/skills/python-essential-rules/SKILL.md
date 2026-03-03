---
name: python-essential-rules
description: Rules you should ALWAYS follow when working with Python
---

## Code style rules

*   Never use `__all__` in `__init__.py`.

## Tooling

Use Astral's suite of python development tools (`uv`, `ty`, and `ruff`) instead
of `pip`, `pyright` and `black` (or similar tools).

### `uv`

Use `uv` for project management:

*   `uv init` starts a new project
*   `uv add <library>` includes a new dependency
*   `uv run <shell command>` runs commands using the project's Python environment

See the [uv docs](https://docs.astral.sh/uv/) for more information.

### `ty`/`ruff`

Astral's type checker/language server `ty`, and their linter/formatter `ruff`
should be configured as hooks, so you don't need to worry about these.

Run type checker:
``` sh
ty check <dir>
```

Run linter
``` 
ruff check .
```

