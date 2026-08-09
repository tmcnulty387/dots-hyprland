local hyprScripts = "$HOME/.config/hypr/hyprland/scripts"
local qsIpcCall = "qs -c $qsConfig ipc call"
local qsIsAlive = qsIpcCall .. " TEST_ALIVE"

--##! User
hl.bind("CTRL + SUPER + Slash", hl.dsp.exec_cmd("xdg-open $HOME/.config/illogical-impulse/config.json"), { description = "User: Edit shell config" })
hl.bind("CTRL + SUPER + ALT + Slash", hl.dsp.exec_cmd("xdg-open $HOME/.config/hypr/custom/keybinds.lua"), { description = "User: Edit keybinds" })

hl.bind("SUPER + Z", hl.dsp.layout("togglesplit"), { description = "Window: Toggle split" })
hl.bind("SUPER + SHIFT + U", hl.dsp.exec_cmd("$HOME/bin/reset-mouse"))
hl.bind("SUPER + Y", hl.dsp.exec_cmd("hyprctl keyword monitor \"eDP-1,disable\""))
hl.bind("SUPER + SHIFT + Y", hl.dsp.exec_cmd("hyprctl keyword monitor \"eDP-1,preferred,0x0,1\""))

-- Float + pin (override upstream's pin-only)
hl.unbind("SUPER + P")
hl.bind("SUPER + P", hl.dsp.exec_cmd("hyprctl dispatch togglefloating active; hyprctl dispatch pin active"), { description = "Window: Float and pin" })

--##! Upstream Overrides

-- Super+Tab: cycle active workspaces instead of overview toggle
hl.unbind("SUPER + Tab")
hl.bind("SUPER + Tab", hl.dsp.exec_cmd(hyprScripts .. "/cycle_active_workspaces.sh"), { description = "Shell: Cycle active workspaces" })

-- Bar toggle moved from J to U (J freed for movefocus down)
hl.unbind("SUPER + J")
hl.bind("SUPER + U", hl.dsp.global("quickshell:barToggle"), { description = "Shell: Toggle bar" })

-- Remove on-screen keyboard toggle (K freed for movefocus up)
hl.unbind("SUPER + K")

-- Panel cycle moved from Ctrl+Super+P to Super+Alt+W
hl.unbind("CTRL + SUPER + P")
hl.bind("SUPER + ALT + W", hl.dsp.global("quickshell:panelFamilyCycle"), { description = "Shell: Cycle panel family" })

-- Widget restart: also reload hyprland and kill legacy ags
hl.unbind("CTRL + SUPER + R")
hl.bind("CTRL + SUPER + R", hl.dsp.exec_cmd("hyprctl reload; killall ags agsv1 gjs ydotool qs quickshell; qs -c $qsConfig &"), { description = "Shell: Restart widgets" })

-- OCR: use regionOcr instead of screenTranslate on Super+Shift+T
hl.unbind("SUPER + SHIFT + T")
hl.bind("SUPER + SHIFT + T", hl.dsp.global("quickshell:regionOcr"))
hl.bind("SUPER + SHIFT + T", hl.dsp.exec_cmd(
    qsIsAlive .. " || pidof slurp || grim -g \"$(slurp $SLURP_ARGS)\" \"/tmp/ocr_image.png\"" ..
    " && tesseract \"/tmp/ocr_image.png\" stdout -l $(tesseract --list-langs | awk 'NR>1{print $1}' | tr '\\n' '+' | sed 's/\\+$/\\n/')" ..
    " | wl-copy && rm \"/tmp/ocr_image.png\""
))

-- Screenshot: full screen instead of active-monitor-only
hl.unbind("Print")
hl.unbind("CTRL + Print")
hl.bind("Print", hl.dsp.exec_cmd("grim - | wl-copy"), { locked = true, description = "Utilities: Screenshot >> clipboard" })
hl.bind("CTRL + Print", hl.dsp.exec_cmd(
    "mkdir -p $(xdg-user-dir PICTURES)/Screenshots && grim $(xdg-user-dir PICTURES)/Screenshots/Screenshot_\"$(date '+%Y-%m-%d_%H.%M.%S')\".png"
), { locked = true, non_consuming = true, description = "Utilities: Screenshot >> file" })
hl.bind("CTRL + Print", hl.dsp.exec_cmd("grim - | wl-copy"), { locked = true, non_consuming = true })

-- Window focus: hjkl instead of BracketLeft/Right (L freed from lock → moved to O below)
hl.unbind("SUPER + BracketLeft")
hl.unbind("SUPER + BracketRight")
hl.unbind("SUPER + L")
hl.bind("SUPER + h", hl.dsp.focus({ direction = "l" }))
hl.bind("SUPER + j", hl.dsp.focus({ direction = "d" }))
hl.bind("SUPER + k", hl.dsp.focus({ direction = "u" }))
hl.bind("SUPER + l", hl.dsp.focus({ direction = "r" }))

-- Lock/sleep: O instead of L; lid switch enabled
hl.unbind("SUPER + O")
hl.unbind("SUPER + SHIFT + L")
hl.bind("SUPER + O", hl.dsp.exec_cmd("loginctl lock-session"), { description = "Session: Lock" })
hl.bind("SUPER + SHIFT + O", hl.dsp.exec_cmd("systemctl suspend || loginctl suspend"), { locked = true, description = "Session: Sleep" })
hl.bind("switch:on:Lid Switch", hl.dsp.exec_cmd("systemctl suspend || loginctl suspend"), { locked = true })

-- Send to workspace: Super+Shift instead of Super+Alt
-- Unbind upstream Super+Alt number binds
for i = 0, 9 do
    hl.unbind("SUPER + ALT + " .. i)
end
local numberkey = { 10, 11, 12, 13, 14, 15, 16, 17, 18, 19 }
for i = 1, 10 do
    hl.unbind("SUPER + ALT + code:" .. numberkey[i])
end
local numpadkey = { 87, 88, 89, 83, 84, 85, 79, 80, 81, 90 }
for i = 1, 10 do
    hl.unbind("SUPER + ALT + code:" .. numpadkey[i])
end
-- Remove Super+Alt scroll/page workspace send binds
hl.unbind("SUPER + ALT + mouse_down")
hl.unbind("SUPER + ALT + mouse_up")
hl.unbind("SUPER + ALT + Page_Down")
hl.unbind("SUPER + ALT + Page_Up")

-- Add Super+Shift workspace send binds
for i = 1, 10 do
    hl.bind("SUPER + SHIFT + code:" .. numberkey[i], hl.dsp.exec_cmd(hyprScripts .. "/workspace_action.sh movetoworkspacesilent " .. i))
end
for i = 1, 10 do
    hl.bind("SUPER + SHIFT + code:" .. numpadkey[i], hl.dsp.exec_cmd(hyprScripts .. "/workspace_action.sh movetoworkspacesilent " .. i))
end
