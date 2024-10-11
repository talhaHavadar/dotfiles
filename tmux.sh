#!/bin/env bash

query="$(zoxide query -l)"$'\n'"$(tmux list-sessions)"
result=$(echo "$query" | fzf-tmux -p -w 62% -h 38% -m)
if [ "$result" = "" ]; then
    exit 0
else
    zoxide add "$result" &>/dev/null
    session_name=$(echo $result | sed "s/:.*//g" | sed "s/.*\///g")
    if [ "$TMUX" ]; then
        tmux switch-client -t $session_name || (cd $result && tmux new-session -d -s $session_name && cd - && tmux switch-client -t $session_name)
    else
        cd $result
        tmux new -As $session_name
    fi
fi
