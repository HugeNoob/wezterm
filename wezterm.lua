-- Pull in the wezterm API
local wezterm = require("wezterm")
local act = wezterm.action

-- This table will hold the configuration.
local config = {}

-- In newer versions of wezterm, use the config_builder which will
-- help provide clearer error messages
if wezterm.config_builder then
    config = wezterm.config_builder()
end

-- Default start WSL if on Windows
if wezterm.target_triple == "x86_64-pc-windows-msvc" then
    config.default_domain = "WSL:Ubuntu"
    config.wsl_domains = {
        {
            name = "WSL:Ubuntu",
            distribution = "Ubuntu",
            default_cwd = "/mnt/c/Users/Lingxi",
        },
    }
end

wezterm.on("update-right-status", function(window, pane)
    -- Show LEADER on
    local leader = ""
    if window:leader_is_active() then
        leader = "  LEADER  "
    end

    -- Show which key table is active in the status area
    local key_table = window:active_key_table()
    local name = ""
    if key_table then
        name = "  Active key table: " .. key_table .. "  "
    end

    -- Title for path
    local title = pane:get_title()

    -- generate padding to center title by adding half of width (cols), half
    -- of title length, length of date string and integrated buttons width
    --
    -- if there are any theming in date or title use `wezterm.column.width`
    local padding = wezterm.pad_right("", 2)

    window:set_right_status(wezterm.format({
        { Background = { Color = "#d79921" } },
        { Text = leader },
        { Background = { Color = "#cc241d" } },
        { Text = name },
        { Background = { Color = "#333333" } },
        { Text = " " .. title .. " " },
        { Background = { Color = "#333333" } },
        { Text = padding },
    }))
end)

-- Disable font ligatures
config.harfbuzz_features = { "calt=0", "clig=0", "liga=0" }

-- Disable command line bell
config.audible_bell = "Disabled"

-- timeout_milliseconds defaults to 1000 and can be omitted
config.leader = { key = "a", mods = "CTRL", timeout_milliseconds = 1000 }
config.keys = {
    {
        key = "-",
        mods = "LEADER",
        action = act.SplitVertical({ domain = "CurrentPaneDomain" }),
    },
    {
        key = "|",
        mods = "LEADER|SHIFT",
        action = act.SplitHorizontal({ domain = "CurrentPaneDomain" }),
    },
    -- Send "CTRL-A" to the terminal when pressing CTRL-A, CTRL-A
    {
        key = "a",
        mods = "LEADER|CTRL",
        action = act.SendKey({ key = "a", mods = "CTRL" }),
    },
    {
        key = "r",
        mods = "LEADER",
        action = act.ActivateKeyTable({
            name = "resize_pane",
            one_shot = false,
        }),
    },
    {
        key = "a",
        mods = "LEADER",
        action = act.ActivateKeyTable({
            name = "activate_pane",
            timeout_milliseconds = 1000,
        }),
    },
}

config.key_tables = {
    -- Defines the keys that are active in our resize-pane mode.
    -- Since we're likely to want to make multiple adjustments,
    -- we made the activation one_shot=false. We therefore need
    -- to define a key assignment for getting out of this mode.
    -- 'resize_pane' here corresponds to the name="resize_pane" in
    -- the key assignments above.
    resize_pane = {
        { key = "LeftArrow",  action = act.AdjustPaneSize({ "Left", 1 }) },
        { key = "h",          action = act.AdjustPaneSize({ "Left", 1 }) },
        { key = "RightArrow", action = act.AdjustPaneSize({ "Right", 1 }) },
        { key = "l",          action = act.AdjustPaneSize({ "Right", 1 }) },
        { key = "UpArrow",    action = act.AdjustPaneSize({ "Up", 1 }) },
        { key = "k",          action = act.AdjustPaneSize({ "Up", 1 }) },
        { key = "DownArrow",  action = act.AdjustPaneSize({ "Down", 1 }) },
        { key = "j",          action = act.AdjustPaneSize({ "Down", 1 }) },

        -- Cancel the mode by pressing escape
        { key = "Escape",     action = "PopKeyTable" },
    },

    -- Defines the keys that are active in our activate-pane mode.
    -- 'activate_pane' here corresponds to the name="activate_pane" in
    -- the key assignments above.
    activate_pane = {
        { key = "LeftArrow",  action = act.ActivatePaneDirection("Left") },
        { key = "h",          action = act.ActivatePaneDirection("Left") },
        { key = "RightArrow", action = act.ActivatePaneDirection("Right") },
        { key = "l",          action = act.ActivatePaneDirection("Right") },
        { key = "UpArrow",    action = act.ActivatePaneDirection("Up") },
        { key = "k",          action = act.ActivatePaneDirection("Up") },
        { key = "DownArrow",  action = act.ActivatePaneDirection("Down") },
        { key = "j",          action = act.ActivatePaneDirection("Down") },
    },
}

config.color_scheme = "Gruvbox Dark (Gogh)"

return config
