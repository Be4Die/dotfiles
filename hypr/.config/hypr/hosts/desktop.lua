-- Desktop Host Configuration (cachyos-pc)
local colors = require("frappe")

------------------
---- MONITORS ----
------------------

hl.monitor({
    output   = "HDMI-A-1",
    mode     = "preferred",
    position = "1080x420",
    scale    = 1,
})

hl.monitor({
    output   = "DVI-D-1",
    mode     = "1920x1080@60",
    position = "0x0",
    scale    = 1,
    transform = 1,
})


-------------------------------
---- ENVIRONMENT VARIABLES ----
-------------------------------

hl.env("LIBVA_DRIVER_NAME", "nvidia")
hl.env("GBM_BACKEND", "nvidia-drm")
hl.env("WLR_RENDERER_ALLOW_SOFTWARE", "1")
hl.env("NVD_BACKEND", "direct")
hl.env("BROWSER", "firefox")


-----------------------
---- LOOK AND FEEL ----
-----------------------

hl.config({
    misc = {
        middle_click_paste = false,
    },
    decoration = {
        rounding       = 12,
        rounding_power = 2.0,

        active_opacity   = 1.0,
        inactive_opacity = 1.0,

        shadow = {
            enabled      = true,
            range        = 8,
            render_power = 3,
            color        = "rgba(" .. colors.crustAlpha .. "ee)",
        },

        blur = {
            enabled           = true,
            size              = 8,
            passes            = 3,
            vibrancy          = 0.1696,
            vibrancy_darkness = 0.5,
        },
    },
})

----------------------------
---- DESKTOP AUTOSTART -----
----------------------------

hl.on("hyprland.start", function()
    -- Set 1x standard DPI (96 DPI) for XWayland/X11 apps on desktop monitors
    hl.exec_cmd("echo 'Xft.dpi: 96' | xrdb -merge")
end)
