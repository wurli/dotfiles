export TERM=xterm-256color
export COLORTERM=truecolor
export HISTSIZE=10000 # Default 1000 lines isn't enough

# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# Shell autocompletions
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
autoload -U compinit && compinit
zstyle ':completion:*' menu select                            # Enable completions
zstyle ':completion:*' list-rows-first true                   # Rowwise menu
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Za-z}'        # Case-insensitive
zstyle ':completion:*' sort true                              # Sort completeion
export LS_COLORS="di=34:fi=0:ln=36:pi=33:so=35:bd=94:cd=93:or=31:mi=41:ex=32"
zstyle ':completion:*:default' list-colors ${(s.:.)LS_COLORS} # Colours

# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# Misc env vars
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

# Use Neovim as the pager for man entries
export MANPAGER='nvim +Man!'

# uv install settings (only needed on work machine)
export UV_NATIVE_TLS=true

# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# fzf key bindings and fuzzy completion
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# CTRL-/ to show preview window which is hidden by default

export FZF_DEFAULT_OPTS='
  --preview-window "right:60%:hidden:wrap"
  --bind "ctrl-/:toggle-preview,ctrl-h:preview-up,ctrl-l:preview-down"
  --preview "bat --color=always --style=plain,numbers --line-range=:500 {}"
  '

# Preview file content using bat (https://github.com/sharkdp/bat)
export FZF_CTRL_T_OPTS='
  --walker-skip .git,node_modules,target
  --preview "bat --color=always --style=plain,numbers --line-range=:500 {}"
  --bind "ctrl-/:change-preview-window(down|hidden|)"
  '
source <(fzf --zsh)

# Homebrew auto completions
FPATH="$(brew --prefix)/share/zsh/site-functions:${FPATH}"

# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# use starship
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
eval "$(starship init zsh)"

# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# use zoxide
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
eval "$(zoxide init --cmd cd zsh)"

# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# use eza
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# Unfortunately seems very slow
# alias ls="eza"

# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# Aliases and other customisation
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
alias lg="lazygit"
alias vim="nvim"
alias ff="fzf"
alias co="git checkout"
alias ga="git add"
alias gc="git commit"
alias gp="git pull"
alias gP="git push"
alias gl="git nl"
alias gs="git status"
alias gd="git diff"

function fg() {
    RG_PREFIX="rg --column --line-number --no-heading --color=always --smart-case "
    INITIAL_QUERY="${*:-}"

    fzf --ansi --disabled --query "$INITIAL_QUERY" \
    --bind "start:reload:$RG_PREFIX {q}" \
    --bind "change:reload:sleep 0.1; $RG_PREFIX {q} || true" \
    --delimiter : \
    --preview 'bat --color=always {1} --highlight-line {2} --style=plain,numbers ' \
    --preview-window 'right,50%,border-none,+{2}+3/3,~3' \
    --bind 'enter:become(nvim {1} +{2})'
}


# Transform a video into a gif with nice settings.
# This is pretty much impossible to remember if you're not intimately familiar
# with ffmpeg.
gif() {
    local input="$1"
    local output="$2"
    local width="${3:-1080}"
    local speed="${4:-1}"

    if [[ -z "$input" || -z "$output" ]]; then
        echo "Usage: gif <input.mov> <output.gif> [<width>] [<speed>]"
        return 1
    fi

    ffmpeg -i "$input" \
        -vf "setpts=${speed}*PTS, \
        fps=20, \
        scale=${width}:-1:flags=lanczos, \
        split[s0][s1], \
        [s0]palettegen[p]; \
        [s1][p]paletteuse" \
        -loop 1 \
        "$output"
}

scratch() {
    local name="$1"
    if [[ -z "$name" ]]; then
        echo "Usage: scratch <name> [<type>] [<directory>]"
        return 1
    fi

    local scratch_type="${2:-r}"
    if [[ "$scratch_type" == "r" ]]; then
        local filetype="R"
    else
        local filetype="$scratch_type"
    fi

    local directory="$HOME/${3:-Repos/$scratch_type-scratch}"
    local today="$(date +%Y-%m-%d)"
    local filename="$directory/${today}_$1.$filetype"

    if command -v positron >/dev/null 2>&1; then
        local cmd=positron
    else
        local cmd=vim
    fi

    touch $filename
    $cmd $filename
}

# ffmpeg -i input.mov -vf "fps=20,scale=1280:-1:flags=lanczos,split[s0][s1],[s0]palettegen[p];[s1][p]paletteuse” -loop 1 output.gif

# BEGIN opam configuration
# This is useful if you're using opam as it adds:
#   - the correct directories to the PATH
#   - auto-completion for the opam binary
# This section can be safely removed at any time if needed.
[[ ! -r '/Users/jacobscott/.opam/opam-init/init.zsh' ]] || source '/Users/jacobscott/.opam/opam-init/init.zsh' > /dev/null 2> /dev/null
# END opam configuration

. "$HOME/.local/bin/env"

bindkey -s '^[3' \#

