-- MacBook Pro Mid 2015 Host Configuration (Retina A1398)
local colors = require("frappe")

------------------
---- MONITORS ----
------------------

-- Retina 15" (2880x1800@60 with native 2.0 integer Retina scale)
hl.monitor({
    output   = "eDP-1",
    mode     = "2880x1800@60",
    position = "0x0",
    scale    = 2,
})

hl.monitor({
    output   = "",
    mode     = "preferred",
    position = "auto",
    scale    = 1,
})


-------------------------------
---- ENVIRONMENT VARIABLES ----
-------------------------------

-- Hardware video acceleration & Wayland optimizations
hl.env("MOZ_ENABLE_WAYLAND", "1")
hl.env("LIBVA_DRIVER_NAME", "radeonsi")
hl.env("VDPAU_DRIVER", "radeonsi")
hl.env("mesa_glthread", "true")

-- Fix blurry text in XWayland apps (ONLYOFFICE, Steam, etc.) on Retina display with fractional scaling
hl.config({
    xwayland = {
        force_zero_scaling = true,
    },
})


---------------------------------
---- TOUCHPAD & GESTURES ----
---------------------------------

hl.config({
    input = {
        touchpad = {
            natural_scroll = true,
        },
    },
})

-- 3-Finger Touchpad Workspace Swipe Gesture
hl.gesture({ fingers = 3, direction = "horizontal", action = "workspace" })


--------------------------------------------
---- BATTERY & RESOURCE EFFICIENCY ----
--------------------------------------------

-- Disable heavy blur & drop shadows for battery efficiency
hl.config({
    decoration = {
        rounding       = 8,
        rounding_power = 2.0,

        active_opacity   = 1.0,
        inactive_opacity = 1.0,

        shadow = {
            enabled = false,
        },

        blur = {
            enabled = false,
        },
    },
})

-------------------------
---- LAPTOP HOTKEYS -----
-------------------------

hl.bind("SUPER + P", hl.dsp.exec_cmd("~/dotfiles/scripts/toggle-mirror.sh"))
