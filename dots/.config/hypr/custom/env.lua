local home_dir = os.getenv("HOME")

-- Override Qt platform to avoid xcb fallback
hl.env("QT_QPA_PLATFORM", "wayland")

-- Terminal application
hl.env("TERMINAL", "kitty -1")

-- X11 Forwarding
hl.env("XAUTHORITY", home_dir .. "/.Xauthority")
