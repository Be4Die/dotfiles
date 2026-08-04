-- MacBook Pro Mid 2015 Host Configuration (Retina A1398)
local colors = require("frappe")

------------------
---- MONITORS ----
------------------

-- Retina 15" (2880x1800@60 with 1.75 scale for comfortable UI size)
hl.monitor({
    output   = "eDP-1",
    mode     = "2880x1800@60",
    position = "0x0",
    scale    = 1.75,
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

-- Intel Iris Pro iGPU Binding
hl.env("AQ_DRM_DEVICES", "/dev/dri/card0")


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

-- 3-Finger Touchpad Workspace Swipe Gesture (Hyprland 0.51+ syntax)
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
        inactive_opacity = 0.98,

        shadow = {
            enabled = false,
        },

        blur = {
            enabled = false,
        },
    },
})
