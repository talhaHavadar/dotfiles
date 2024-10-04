export DOTFILES_BASH_SOURCED="true"
export GPG_TTY=$(tty)
export PATH="$PATH:~/.local/bin"

. "$HOME/.cargo/env"
eval "$(zoxide init --cmd cd bash)"
eval "$(starship init bash)"

tmux_find_or_create_prompt() {
    result=$(zoxide query -l | fzf-tmux -p -w 62% -h 38% -m)
    if [ "$result" = "" ]; then
        echo ""
    else
        zoxide add "$result" &>/dev/null
        session_name=$(echo $result | sed "s/.*\///g")
        if [ "$TMUX" ]; then
            echo "in tmux session"
            
            tmux switch-client -t $session_name || (cd $result && tmux new-session -d -s $session_name && cd - && tmux switch-client -t $session_name)
        else
            echo "not in tmux session"
            cd $result
            tmux new -As $session_name
        fi
    fi
}

alias tn='tmux new -As $(pwd | sed "s/.*\///g")'
alias t='tmux new -As '
alias tl='tmux list-sessions'
alias tk='tmux kill-session -t'
#alias tf='tmux new -As $(zoxide query -l | fzf-tmux | sed "s/.*\///g")'
alias tf=tmux_find_or_create_prompt
alias tp="tmux list-panes -a -F '#D #T #{pane_tty} #{pane_current_command} #{pane_current_path}'"
