from IPython.terminal.prompts import Prompts
from pygments.token import Token

c = get_config()  # noqa: F821

try:
    from IPython.core import ultratb
    ultratb.VerboseTB.tb_highlight = "bg:#8B0000"
except Exception:
    print("Could not override IPython exception colors.")


# https://ipython.readthedocs.io/en/stable/config/details.html#MyPrompts.in_prompt_tokens
# Make the IPython prompt a bit less imposing
class MyPrompt(Prompts):
    def in_prompt_tokens(self, cli=None):
        return [(Token.Prompt, "> ")]

    def continuation_prompt_tokens(self, width=None):
        return [(Token.Prompt, "+ ")]

    # def rewrite_prompt_tokens(self):
    #     pass

    def out_prompt_tokens(self):
        return [(Token.OutPrompt, "")]


c.TerminalInteractiveShell.prompts_class = MyPrompt
