
# #{buffer:.zshrc}
#
# Why isn't fzf completion, e.g. cd **<tab> working in tmux? It works outside of tmux.

if [[ -n "$TMUX" ]]; then
    export TERM=tmux-256color
else
    export TERM=xterm-256color
fi
# export COLORTERM=truecolor
export HISTSIZE=10000 # Default 1000 lines isn't enough
export EDITOR=nvim
export JUPYTER_PATH=$HOME/Repos/jet

# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# Adjust path
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
path+=("$HOME/.local/bin/")
# path=($HOME/.local/bin/ $path)

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
# fzf key bindings and fuzzy completion
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# CTRL-/ to show preview window which is hidden by default
#
# Homebrew auto completions
FPATH="$(brew --prefix)/share/zsh/site-functions:${FPATH}"

# Set emacs keybindings BEFORE fzf so fzf's Tab completion isn't overridden
bindkey -e

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

# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# Misc env vars
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

# Use Neovim as the pager for man entries
export MANPAGER='nvim +Man!'

# uv install settings (only needed on work machine)
export UV_NATIVE_TLS=true

# GitHub Copilot CLI
export COPILOT_MODEL="claude-sonnet-4.5"

# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# use starship
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
eval "$(starship init zsh)"


# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# Set the terminal background color
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# echo -e "\033]11;#011E3A\007"
echo -e "\033]11;#001426\007"



# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# Aliases and other customisation
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
alias lg="lazygit"
alias vim="nvim"
alias ff="fzf"
alias pip="uv pip"
alias co="git checkout"
alias ga="git add"
alias gc="git commit"
alias gp="git pull"
alias gP="git push"
alias gl="git nl"
alias gs="git status"
alias gd="git diff"
alias g="git"

# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# Keymaps
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
bindkey -s ^f "tmux-sessionizer\n"
bindkey -s '\eu' "tmux-sessionizer -s 0\n"
bindkey -s '\ei' "tmux-sessionizer -s 1\n"
bindkey -s '\eo' "tmux-sessionizer -s 2\n"
bindkey -s '\ep' "tmux-sessionizer -s 3\n"

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

function venv() {
    uv venv "$@" && source ".venv/bin/activate"
}

# Transform a video into a gif with nice settings.
# This is pretty much impossible to remember if you're not intimately familiar
# with ffmpeg.
gif() {
    local input="$1"
    local output="$2"
    local width="${3:-1080}"
    local speed="${4:-1}"    # E.g. 0.5 = half speed
    local fps="${5:-20}"

    if [[ -z "$input" || -z "$output" ]]; then
        echo "Usage: gif <input.mov> <output.gif> [<width>] [<speed>]"
        return 1
    fi

    ffmpeg -i "$input" \
        -vf "setpts=${speed}*PTS, \
        fps=${fps}, \
        scale=${width}:-1:flags=lanczos, \
        split[s0][s1], \
        [s0]palettegen[p]; \
        [s1][p]paletteuse" \
        -loop 1 \
        "$output"
}

scratch() {
    local name="$1"
    local scratch_type="${2:-r}"

    if [[ "$scratch_type" == "r" ]]; then
        local filetype="R"
    else
        local filetype="$scratch_type"
    fi

    local directory="$HOME/${3:-Repos/$scratch_type-scratch}"

    if [[ -z "$name" ]]; then
        local filename="$directory/$(ls -R $directory | fzf --prompt 'Select scratch file> ')"
    else
        local today="$(date +%Y-%m-%d)"
        local filename="$directory/${today}_$name.$filetype"
    fi

    if command -v positron >/dev/null 2>&1; then
        touch $filename
        positron $filename $directory
    else
        nvim $filename
    fi
}

h() {
    local cmd="$1"
    if [[ -z "$cmd" ]]; then
        echo "Usage: h <command>"
        return 1
    fi
    curl "https://cheat.sh/$cmd"
}

mdb-export-all() {
    local db_file="$1"
    local dir="${2:-.}"
    if [[ -z "$db_file" ]]; then
        echo "Usage: mdb-export-all <database.accdb> <output_directory>"
        return 1
    fi

    local tables=$(mdb-tables "$db_file")
    for tb in ${=tables}; do
        echo "Exporting ${tb}.csv"

        mdb-export "$db_file" \
            "$tb" \
            --date-format=%Y-%m-%d \
            --datetime-format=%Y-%m-%d\ %H:%M:%S \
            > "${dir}/${tb}.csv"
    done
}

# Even after I sign on I get a lingering SSO window which I can't close or interact with.
# I can close it with the activity monitor, but this is easier.
sso-kill() {
    ps aux | grep -i  "appssoagent" | grep -v grep | awk '{print $2}' | xargs kill
}

ai() {
    local branch="$1"

    # Check if current directory is a git repository
    if ! git rev-parse --git-dir &>/dev/null; then
        echo "Error: Not in a git repository" >&2
        return 1
    fi

    if [[ -z "$branch" ]]; then
        # No branch provided, open current directory in VS Code
        code .
    else
        # Get current directory name
        local current_dir=$(basename "$PWD")
        local parent_dir=$(dirname "$PWD")
        local new_dir="${parent_dir}/${current_dir}-${branch}"

        # Create new branch and worktree
        git worktree add "$new_dir" -b "$branch"

        # Open new directory in VS Code
        code "$new_dir"
    fi
}

