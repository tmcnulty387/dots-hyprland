-- former `exec` (re-run on reload) goes outside; `exec-once` goes inside hyprland.start
hl.exec_cmd("cloudcli")

hl.on("hyprland.start", function()
    hl.exec_cmd("hyprpm reload")
end)
