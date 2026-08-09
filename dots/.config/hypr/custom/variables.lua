-- Override default terminal to prefer kitty
terminal = "kitty -1"

-- Override code editor: match v2 order (no windsurf/antigravity)
codeEditor = "~/.config/hypr/hyprland/scripts/launch_first_available.sh 'code' 'codium' 'cursor' 'zed' 'zedit' 'zeditor' 'kate' 'gnome-text-editor' 'emacs' 'command -v nvim && kitty -1 nvim' 'command -v micro && kitty -1 micro'"
