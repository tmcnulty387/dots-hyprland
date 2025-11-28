# fish-specific customization
function fish_prompt -d "Write out the prompt"
    printf '%s@%s %s%s%s > ' $USER $hostname \
        (set_color $fish_color_cwd) (prompt_pwd) (set_color normal)
end

if status is-interactive
    # Commands to run in interactive sessions can go here
    set fish_greeting

end

starship init fish | source
if test -f ~/.local/state/quickshell/user/generated/terminal/sequences.txt
    cat ~/.local/state/quickshell/user/generated/terminal/sequences.txt
end

# env variables
set -x PATH $HOME/bin:$HOME/.local/bin:/usr/local/bin:$HOME/.local/share/JetBrains/Toolbox/scripts:$HOME/.npm-global/bin:$HOME/.cargo/bin:$PATH
set -x EDITOR vim
set -x XDG_CONFIG_HOME $HOME/.config
set -x USERLOG $HOME/log
set -x DOTFILES $HOME/config/dotfiles
#set -x GEMINI_API_KEY AIzaSyD5BMoKcrHt-8rhuXNpQuVn32pxW8lBhXs
set -x GEMINI_API_KEY AIzaSyArRZDcZYFv_NmeMn0MaH_Mmk7IE1VM_-4
#set -x GEMINI_MODEL "gemini-2.5-flash"
set -x CHROME_EXECUTABLE /usr/bin/chromium
set -x LAN_MOUSE_LOG_LEVEL debug

alias ls 'eza --icons'
alias clear "printf '\033[2J\033[3J\033[1;1H'"
    
exec zsh
