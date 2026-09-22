"""Complete pyspark DataFrame column names inside method-argument strings.

e.g. `df.select("<TAB>` offers columns of `df` — including through nested calls
like `df.select(F.coalesce("<TAB>`.
"""

import ast
import sys

from IPython.core.completer import (  # ty:ignore[unresolved-import]
    SimpleCompletion,
    context_matcher,
)

_ip = get_ipython()  # noqa: F821  # ty:ignore[unresolved-reference]


def _install_key_completions(_):
    for name in ("pyspark.sql.dataframe", "pyspark.sql.connect.dataframe"):
        if (m := sys.modules.get(name)) is not None:
            m.DataFrame._ipython_key_completions_ = lambda self: list(self.columns)


_ip.events.register("post_run_cell", _install_key_completions)


_COL_METHODS = frozenset(
    {
        "agg",
        "coalesce",
        "drop",
        "filter",
        "groupBy",
        "groupby",
        "isnotnull",
        "isnull",
        "join",
        "orderBy",
        "partitionBy",
        "select",
        "sort",
        "where",
        "withColumn",
        "withColumnRenamed",
        "withColumnsRenamed",
    }
)

# Suffixes to try appending to make an incomplete snippet parseable — closes an
# unterminated string plus up to 3 levels of nested calls.
_CLOSINGS = [q + ")" * n for n in range(4) for q in ('"', "'")]


@context_matcher()
def _df_col_matcher(context):
    # Classic pyspark (e.g. databricks-connect 15.x) exposes DataFrame at
    # pyspark.sql.dataframe; Spark Connect (databricks-connect 16+) returns a
    # separate pyspark.sql.connect.dataframe.DataFrame with no shared base, so
    # check whichever modules are loaded.
    df_classes = tuple(
        m.DataFrame
        for name in ("pyspark.sql.dataframe", "pyspark.sql.connect.dataframe")
        if (m := sys.modules.get(name)) is not None
    )
    if not df_classes:
        return {"completions": []}

    # cursor_position is line-relative. Rebuild the snippet up to the cursor and
    # note the cursor's (lineno, col) in AST coordinates (1-indexed line).
    lines = context.full_text.split("\n")
    current_line = lines[context.cursor_line]
    col = min(context.cursor_position, len(current_line))
    snippet = "\n".join(lines[: context.cursor_line] + [current_line[:col]])
    cursor = (context.cursor_line + 1, col)
    prefix = context.token.lstrip("\"'")

    tree = None
    for closing in _CLOSINGS:
        try:
            tree = ast.parse(snippet + closing)
            break
        except SyntaxError:
            continue
    if tree is None:
        return {"completions": []}

    def contains_cursor(node):
        return (
            (node.lineno, node.col_offset)
            <= cursor
            <= (node.end_lineno, node.end_col_offset)
        )

    # Innermost call first; walk outward until we find a DataFrame method.
    calls = sorted(
        (n for n in ast.walk(tree) if isinstance(n, ast.Call) and contains_cursor(n)),
        key=lambda n: (n.lineno, n.col_offset),
        reverse=True,
    )

    for call in calls:
        func = call.func
        if not isinstance(func, ast.Attribute) or func.attr not in _COL_METHODS:
            continue
        # Walk back through chained .method().method() calls to the root Name.
        # If the root is anything else (e.g. a Call like tbl_compute("x")), we
        # can't resolve it without executing code, so skip.
        root = func.value
        while True:
            if isinstance(root, ast.Attribute):
                root = root.value
            elif isinstance(root, ast.Call) and isinstance(root.func, ast.Attribute):
                root = root.func.value
            else:
                break
        if not isinstance(root, ast.Name):
            continue
        df = _ip.user_ns.get(root.id)
        if not isinstance(df, df_classes):
            continue
        return {
            "completions": [
                SimpleCompletion(text=c, type="value")
                for c in df.columns
                if c.startswith(prefix)
            ],
            "suppress": True,
        }

    return {"completions": []}


_ip.Completer.custom_matchers.append(_df_col_matcher)
