#!/bin/zsh

LOCAL_DIR="$HOME/.local/bin"
TMUX_SESSIONIZER_FILE="$LOCAL_DIR/tmux-sessionizer"

curl --output \
    $TMUX_SESSIONIZER_FILE \
    "https://raw.githubusercontent.com/ThePrimeagen/tmux-sessionizer/refs/heads/master/tmux-sessionizer"

chmod +x $TMUX_SESSIONIZER_FILE



