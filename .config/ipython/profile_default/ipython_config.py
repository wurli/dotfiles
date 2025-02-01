from IPython.terminal.prompts import Prompts
from pygments.token import Token

c = get_config()  # noqa: F821

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

