-- Monitor configuration
-- INTEGRATED
hl.monitor({ output = "eDP-1", mode = "preferred", position = "0x0", scale = "1" })
-- hl.monitor({ output = "eDP-1", disable = true })

-- DORM ROOM
-- hl.monitor({ output = "HDMI-A-2", mode = "preferred", position = "+1920x0", scale = "1" })
hl.monitor({ output = "HDMI-A-2", mode = "preferred", position = "0x-1080", scale = "1" })
-- hl.monitor({ output = "HDMI-A-2", mode = "preferred", position = "0x0", scale = "1" })

-- COMPUTER LAB
-- hl.monitor({ output = "DP-2", mode = "preferred", position = "0x-1440", scale = "1" })
-- hl.monitor({ output = "DP-2", mode = "preferred", position = "0x0", scale = "1" })
-- hl.monitor({ output = "HDMI-A-2", mode = "preferred", position = "0x-1440", scale = "1" })
-- hl.monitor({ output = "HDMI-A-2", mode = "preferred", position = "0x0", scale = "1" })

-- Vertical screen
hl.monitor({ output = "DP-1", mode = "preferred", position = "1920x-840", scale = "1", transform = "1" })

hl.config({
    general = {
        gaps_in = 0,
        gaps_out = 0,
        border_size = 0,
        col = { active_border = "rgba(0DB7D4FF)" },
        resize_on_border = false,
    },
    dwindle = {
        smart_split = true,
    },
    decoration = {
        rounding = 0,
        blur = {
            enabled = false,
            noise = 0.15,
            contrast = 0.2,
            vibrancy = 0.8,
            vibrancy_darkness = 0.8,
        },
        shadow = { enabled = false },
        dim_inactive = false,
        dim_strength = 0.025,
        dim_special = 0.07,
    },
    animations = { enabled = false },
    input = {
        touchpad = {
            natural_scroll = false,
            scroll_factor = 2.0,
        },
        sensitivity = 0.6,
        force_no_accel = false,
    },
    cursor = { zoom_disable_aa = false },
    -- Plugin config (hyprexpo overview)
    plugin = {
        hyprexpo = {
            columns = 3,
            gap_size = 5,
            bg_col = "rgb(000000)",
            workspace_method = "first 1",
        },
    },
})

-- Device-specific input configs
hl.config({ device = { name = "tpps/2-ibm-trackpoint", enabled = true } })
hl.config({ device = { name = "at-translated-set-2-keyboard", enabled = true } })
hl.config({ device = { name = "synaptics-tm3276-022", enabled = true } })
hl.config({ device = { name = "logitech-g305-1", sensitivity = -0.2 } })
