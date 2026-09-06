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
local menu        = "fuzzel"


-------------------
---- AUTOSTART ----
-------------------

hl.on("hyprland.start", function()
    hl.exec_cmd("systemctl --user start hyprpolkitagent")

    if hostname == "cachyos-pc" then
        hl.exec_cmd("dunst -conf ~/.config/dunst/hosts/desktop.conf")
        hl.exec_cmd("waybar -c ~/.config/waybar/hosts/desktop.json -s ~/.config/waybar/hosts/desktop.css")
        hl.exec_cmd("gsettings set org.gnome.desktop.interface font-name 'JetBrainsMono Nerd Font 11'")
        hl.exec_cmd("/opt/Koala.Clash/koala-clash")
    else
        hl.exec_cmd("dunst -conf ~/.config/dunst/hosts/laptop.conf")
        hl.exec_cmd("waybar -c ~/.config/waybar/hosts/laptop.json -s ~/.config/waybar/hosts/laptop.css")
        hl.exec_cmd("gsettings set org.gnome.desktop.interface font-name 'JetBrainsMono Nerd Font 10.5'")
        hl.exec_cmd("env GDK_SCALE=2 WEBKIT_DISABLE_DMABUF_RENDERER=1 /opt/Koala.Clash/koala-clash")
    end

    hl.exec_cmd("wallpaper-toggle init")
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

-- Force Wayland native toolkits (fixes GTK/Qt mouse click offset and HiDPI scaling bugs)
hl.env("GDK_BACKEND", "wayland,x11,*")
hl.env("QT_QPA_PLATFORM", "wayland;xcb")
hl.env("SDL_VIDEODRIVER", "wayland")
hl.env("CLUTTER_BACKEND", "wayland")
hl.env("ELECTRON_OZONE_PLATFORM_HINT", "auto")


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
hl.bind(mainMod .. " + B", hl.dsp.exec_cmd("blueman-manager"))
hl.bind(mainMod .. " + D", hl.dsp.exec_cmd("gsimplecal"))
hl.bind(mainMod .. " + slash", hl.dsp.exec_cmd("cheatsheet"))
hl.bind(mainMod .. " + question", hl.dsp.exec_cmd("cheatsheet"))
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

-- Media Keys (Volume & Player)
hl.bind("XF86AudioRaiseVolume",  hl.dsp.exec_cmd("swayosd-client --output-volume raise"))
hl.bind("XF86AudioLowerVolume",  hl.dsp.exec_cmd("swayosd-client --output-volume lower"))
hl.bind("XF86AudioMute",         hl.dsp.exec_cmd("swayosd-client --output-volume mute-toggle"))

hl.bind("XF86AudioPlay",         hl.dsp.exec_cmd("playerctl play-pause"))
hl.bind("XF86AudioNext",         hl.dsp.exec_cmd("playerctl next"))
hl.bind("XF86AudioPrev",         hl.dsp.exec_cmd("playerctl previous"))

-- Laptop-only Hardware Controls & Hotkeys
if hostname ~= "cachyos-pc" then
    -- Wi-Fi Manager Menu
    hl.bind(mainMod .. " + W",       hl.dsp.exec_cmd("wifi-menu"))

    -- Screen Brightness (GMUX unlocked + Catppuccin OSD)
    hl.bind("XF86MonBrightnessUp",   hl.dsp.exec_cmd("brightness-osd + 5%"))
    hl.bind("XF86MonBrightnessDown", hl.dsp.exec_cmd("brightness-osd - 5%"))
    hl.bind("F2",                    hl.dsp.exec_cmd("brightness-osd + 5%"))
    hl.bind("F1",                    hl.dsp.exec_cmd("brightness-osd - 5%"))
    hl.bind("code:233",              hl.dsp.exec_cmd("brightness-osd + 5%"))
    hl.bind("code:232",              hl.dsp.exec_cmd("brightness-osd - 5%"))

    -- Apple Keyboard F3 (Mission Control) -> Round-robin Window Cycle (Tiled -> Maximized -> Floating)
    hl.bind("XF86LaunchA",           hl.dsp.exec_cmd("~/dotfiles/scripts/window-cycle.sh"))
    hl.bind("XF86Explorer",          hl.dsp.exec_cmd("~/dotfiles/scripts/window-cycle.sh"))

    -- Apple Keyboard F4 (Launchpad) -> Fuzzel App Launcher
    hl.bind("XF86LaunchB",           hl.dsp.exec_cmd(menu))
    hl.bind("XF86Search",            hl.dsp.exec_cmd(menu))

    -- Keyboard Backlight (Apple SMC + Catppuccin OSD)
    hl.bind("XF86KbdBrightnessUp",   hl.dsp.exec_cmd("kbd-brightness-osd + 5%"))
    hl.bind("XF86KbdBrightnessDown", hl.dsp.exec_cmd("kbd-brightness-osd - 5%"))
    hl.bind("F6",                    hl.dsp.exec_cmd("kbd-brightness-osd + 5%"))
    hl.bind("F5",                    hl.dsp.exec_cmd("kbd-brightness-osd - 5%"))
end


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

-- Float utility, settings and dialog windows (prevents tiling squeeze & click offset bugs)
local float_apps = {
    "nm-connection-editor",
    "pavucontrol",
    "blueman-manager",
    "gnome-power-statistics",
    "xdg-desktop-portal-gtk",
    "org.gnome.FileRoller",
    "zenity",
    "gsimplecal",
}

for _, cls in ipairs(float_apps) do
    hl.window_rule({
        name   = "float-" .. cls,
        match  = { class = cls },
        float  = true,
        center = true,
    })
end

-- Fixed adequate dimensions for utility managers (prevents half-screen tiling squeeze)
hl.window_rule({
    name   = "size-blueman-manager",
    match  = { class = "blueman-manager" },
    size   = "720 480",
    center = true,
})

hl.window_rule({
    name   = "size-pavucontrol",
    match  = { class = "pavucontrol" },
    size   = "720 500",
    center = true,
})

hl.window_rule({
    name   = "size-gsimplecal",
    match  = { class = "gsimplecal" },
    size   = "340 230",
    center = true,
})


