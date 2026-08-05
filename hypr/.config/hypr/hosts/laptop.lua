-- MacBook Pro Mid 2015 Host Configuration (Retina A1398)
local colors = require("frappe")

------------------
---- MONITORS ----
------------------

-- Retina 15" (2880x1800@60 with 1.7 scale)
hl.monitor({
    output   = "eDP-1",
    mode     = "2880x1800@60",
    position = "0x0",
    scale    = 1.6,
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

-- Вывод через разъем AMD, но рендеринг на холодном и экономичном Intel
hl.env("AQ_DRM_DEVICES", "/dev/dri/card1:/dev/dri/card0")

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
    gestures = {
        workspace_swipe = true,
        workspace_swipe_fingers = 3,
    },
})


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
