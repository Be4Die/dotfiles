local colors = require("frappe")

---------------------------------
---- HOST-SPECIFIC CONFIG (LUA) ----
---------------------------------

local handle = io.popen("hostname 2>/dev/null || cat /etc/hostname 2>/dev/null")
local hostname = handle and handle:read("*a"):gsub("%s+", "") or ""
if handle then handle:close() end

if hostname == "cachyos-pc" then
    pcall(require, "hosts.desktop")
else
    local host_ok, host = pcall(require, "host")
    if not host_ok then
        pcall(require, "hosts.laptop")
    end
end


---------------------
---- MY PROGRAMS ----
---------------------

local terminal    = "alacritty"
local fileManager = "thunar"
local menu        = "wofi --conf ~/.config/wofi/program-menu/config --style ~/.config/wofi/program-menu/catppuccin_frappe/style.css --show drun"


-------------------
---- AUTOSTART ----
-------------------

hl.on("hyprland.start", function()
    hl.exec_cmd("systemctl --user start hyprpolkitagent")
    hl.exec_cmd("dunst")
    hl.exec_cmd("wallpaper-toggle init")
    hl.exec_cmd("waybar")
    hl.exec_cmd("nm-applet --indicator")
    hl.exec_cmd("hyprctl setcursor macOS 24")
    hl.exec_cmd("gsettings set org.gnome.desktop.interface cursor-theme macOS")
    hl.exec_cmd("gsettings set org.gnome.desktop.interface cursor-size 24")
end)


-------------------------------------
---- COMMON ENVIRONMENT VARIABLES ----
-------------------------------------

hl.env("XCURSOR_SIZE", "24")
hl.env("XCURSOR_THEME", "macOS")
hl.env("HYPRCURSOR_SIZE", "24")
hl.env("HYPRCURSOR_THEME", "macOS")
hl.env("XDG_SESSION_TYPE", "wayland")
hl.env("QT_QPA_PLATFORMTHEME", "qt6ct")
hl.env("QT_STYLE_OVERRIDE", "kvantum")


-----------------------
---- LOOK AND FEEL ----
-----------------------

hl.config({
    general = {
        gaps_in  = 6,
        gaps_out = 12,

        border_size = 2,

        col = {
            active_border   = { colors = { "rgba(" .. colors.mauveAlpha .. "ee)", "rgba(" .. colors.blueAlpha .. "ee)" }, angle = 45 },
            inactive_border = "rgba(" .. colors.surface0Alpha .. "aa)",
        },

        resize_on_border = true,
        allow_tearing    = false,
        layout           = "dwindle",
    },

    animations = {
        enabled = true,
    },

    dwindle = {
        preserve_split       = true,
        special_scale_factor = 0.8,
    },

    master = {
        new_status = "slave",
    },

    misc = {
        force_default_wallpaper  = 0,
        disable_hyprland_logo    = true,
        disable_splash_rendering = true,
        mouse_move_enables_dpms  = true,
        key_press_enables_dpms   = true,
        focus_on_activate       = true,
    },

    input = {
        kb_layout  = "us, ru",
        kb_variant = "",
        kb_model   = "",
        kb_options = "grp:win_space_toggle",
        kb_rules   = "",

        follow_mouse = 1,
        sensitivity  = 0,

        touchpad = {
            natural_scroll = false,
        },
    },
})


--------------------
---- ANIMATIONS ----
--------------------

hl.curve("md3_decel",   { type = "bezier", points = { {0.05, 0.7}, {0.1, 1.0} } })
hl.curve("easeOutExpo", { type = "bezier", points = { {0.16, 1.0}, {0.3, 1.0} } })
hl.curve("smoothOut",   { type = "bezier", points = { {0.36, 0.0}, {0.66, 1.0} } })
hl.curve("gentle",      { type = "bezier", points = { {0.25, 0.8}, {0.25, 1.0} } })

hl.animation({ leaf = "windows",       enabled = true, speed = 4,  bezier = "md3_decel",   style = "slide" })
hl.animation({ leaf = "windowsIn",     enabled = true, speed = 4,  bezier = "md3_decel",   style = "slide 20%" })
hl.animation({ leaf = "windowsOut",    enabled = true, speed = 3,  bezier = "smoothOut",   style = "slide 20%" })
hl.animation({ leaf = "windowsMove",   enabled = true, speed = 4,  bezier = "easeOutExpo", style = "slide" })

hl.animation({ leaf = "border",        enabled = true, speed = 5,  bezier = "gentle" })

hl.animation({ leaf = "fade",          enabled = true, speed = 4,  bezier = "smoothOut" })
hl.animation({ leaf = "fadeIn",        enabled = true, speed = 3,  bezier = "smoothOut" })
hl.animation({ leaf = "fadeOut",       enabled = true, speed = 3,  bezier = "smoothOut" })

hl.animation({ leaf = "layers",        enabled = true, speed = 4,  bezier = "md3_decel",   style = "fade" })
hl.animation({ leaf = "layersIn",      enabled = true, speed = 3,  bezier = "md3_decel",   style = "slide" })
hl.animation({ leaf = "layersOut",     enabled = true, speed = 3,  bezier = "smoothOut",   style = "fade" })

hl.animation({ leaf = "workspaces",    enabled = true, speed = 4,  bezier = "easeOutExpo", style = "slidefade 15%" })
hl.animation({ leaf = "workspacesIn",  enabled = true, speed = 4,  bezier = "easeOutExpo", style = "slidefade 15%" })
hl.animation({ leaf = "workspacesOut", enabled = true, speed = 4,  bezier = "smoothOut",   style = "slidefade 15%" })


-- NOTE: Gestures are defined per-host in hosts/laptop.lua and hosts/desktop.lua

------------------
---- DEVICES -----
------------------

hl.device({
    name        = "epic-mouse-v1",
    sensitivity = -0.5,
})


---------------------
---- KEYBINDINGS ----
---------------------

local mainMod = "SUPER"

hl.bind(mainMod .. " + Q", hl.dsp.exec_cmd(terminal))
hl.bind(mainMod .. " + C", hl.dsp.window.close())
hl.bind(mainMod .. " + E", hl.dsp.exec_cmd(fileManager))
hl.bind(mainMod .. " + V", hl.dsp.window.float({ action = "toggle"}))
hl.bind(mainMod .. " + R", hl.dsp.exec_cmd(menu))
hl.bind(mainMod .. " + Escape", hl.dsp.exec_cmd("~/.config/hypr/powermenu.sh"))

-- Move focus
hl.bind(mainMod .. " + left",  hl.dsp.focus({ direction = "l" }))
hl.bind(mainMod .. " + right", hl.dsp.focus({ direction = "r" }))
hl.bind(mainMod .. " + up",    hl.dsp.focus({ direction = "u" }))
hl.bind(mainMod .. " + down",  hl.dsp.focus({ direction = "d" }))

-- Switch workspaces 1..9
for i = 1, 9 do
    hl.bind(mainMod .. " + " .. i,         hl.dsp.focus({ workspace = tostring(i) }))
    hl.bind(mainMod .. " + SHIFT + " .. i, hl.dsp.window.move({ workspace = tostring(i) }))
end
-- Workspace 10
hl.bind(mainMod .. " + 0",         hl.dsp.focus({ workspace = "10" }))
hl.bind(mainMod .. " + SHIFT + 0", hl.dsp.window.move({ workspace = "10" }))

-- Custom Application Shortcuts
hl.bind(mainMod .. " + SHIFT + T", hl.dsp.exec_cmd("Telegram"))
hl.bind(mainMod .. " + SHIFT + F", hl.dsp.exec_cmd("firefox"))
hl.bind(mainMod .. " + SHIFT + H", hl.dsp.exec_cmd("alacritty -e herdr"))
hl.bind(mainMod .. " + SHIFT + Z", hl.dsp.exec_cmd("zed"))
hl.bind(mainMod .. " + SHIFT + W", hl.dsp.exec_cmd("wallpaper-toggle"))

-- Scroll through existing workspaces with mainMod + scroll
hl.bind(mainMod .. " + mouse_down", hl.dsp.focus({ workspace = "e+1" }))
hl.bind(mainMod .. " + mouse_up",   hl.dsp.focus({ workspace = "e-1" }))

-- Move/resize windows with mainMod + LMB/RMB and dragging
hl.bind(mainMod .. " + mouse:272", hl.dsp.window.drag(),   { mouse = true })
hl.bind(mainMod .. " + mouse:273", hl.dsp.window.resize(), { mouse = true })

-- Screenshots (Hyprshot)
hl.bind("PRINT",                   hl.dsp.exec_cmd("hyprshot -m region --clipboard-only"))
hl.bind(mainMod .. " + PRINT",         hl.dsp.exec_cmd("hyprshot -m window"))
hl.bind(mainMod .. " + SHIFT + PRINT", hl.dsp.exec_cmd("hyprshot -m output"))
hl.bind("CTRL + PRINT",            hl.dsp.exec_cmd("hyprshot -m region --clipboard-only"))

-- macOS-style screenshot bindings (ALT + SHIFT + 3/4/5 to avoid conflict with moving windows to workspaces)
hl.bind("ALT + SHIFT + 3", hl.dsp.exec_cmd("hyprshot -m output"))
hl.bind("ALT + SHIFT + 4", hl.dsp.exec_cmd("hyprshot -m region --clipboard-only"))
hl.bind("ALT + SHIFT + 5", hl.dsp.exec_cmd("hyprshot -m window"))

-- Media & Hardware Keys (Volume, Brightness, Keyboard Backlight, Player)
hl.bind("XF86AudioRaiseVolume",  hl.dsp.exec_cmd("wpctl set-volume -l 1.5 @DEFAULT_AUDIO_SINK@ 5%+"))
hl.bind("XF86AudioLowerVolume",  hl.dsp.exec_cmd("wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-"))
hl.bind("XF86AudioMute",         hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"))

-- Screen Brightness (amdgpu_bl1)
hl.bind("XF86MonBrightnessUp",   hl.dsp.exec_cmd("/usr/local/bin/change-brightness + 5%"))
hl.bind("XF86MonBrightnessDown", hl.dsp.exec_cmd("/usr/local/bin/change-brightness - 5%"))
hl.bind("F2",                    hl.dsp.exec_cmd("/usr/local/bin/change-brightness + 5%"))
hl.bind("F1",                    hl.dsp.exec_cmd("/usr/local/bin/change-brightness - 5%"))
hl.bind("code:233",              hl.dsp.exec_cmd("/usr/local/bin/change-brightness + 5%"))
hl.bind("code:232",              hl.dsp.exec_cmd("/usr/local/bin/change-brightness - 5%"))

-- Apple Keyboard F3 (Mission Control) -> Round-robin Window Cycle (Tiled -> Maximized -> Floating)
hl.bind("XF86LaunchA",           hl.dsp.exec_cmd("~/dotfiles/scripts/window-cycle.sh"))
hl.bind("XF86Explorer",          hl.dsp.exec_cmd("~/dotfiles/scripts/window-cycle.sh"))

-- Apple Keyboard F4 (Launchpad) -> Wofi App Launcher
hl.bind("XF86LaunchB",           hl.dsp.exec_cmd(menu))
hl.bind("XF86Search",            hl.dsp.exec_cmd(menu))

hl.bind("XF86KbdBrightnessUp",   hl.dsp.exec_cmd("brightnessctl --device='*kbd*' set 5%+"))
hl.bind("XF86KbdBrightnessDown", hl.dsp.exec_cmd("brightnessctl --device='*kbd*' set 5%-"))

hl.bind("XF86AudioPlay",         hl.dsp.exec_cmd("playerctl play-pause"))
hl.bind("XF86AudioNext",         hl.dsp.exec_cmd("playerctl next"))
hl.bind("XF86AudioPrev",         hl.dsp.exec_cmd("playerctl previous"))


----------------------------------
---- WINDOWS AND WORKSPACES ------
----------------------------------

hl.window_rule({
    name           = "suppress-maximize-events",
    match          = { class = ".*" },
    suppress_event = "maximize",
})

hl.window_rule({
    name  = "move-hyprland-run",
    match = { class = "hyprland-run" },
    move  = "20 monitor_h-120",
    float = true,
})
