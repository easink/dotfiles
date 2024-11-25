local wezterm     = require 'wezterm'

local col_base03  = '#002b36'
local col_base02  = '#073642'
local col_base01  = '#586e75'
local col_base00  = '#657b83'
local col_base0   = '#839496'
local col_base1   = '#93a1a1'
local col_base2   = '#eee8d5'
local col_base3   = '#fdf6e3'
local col_yellow  = '#b58900'
local col_orange  = '#cb4b16'
local col_red     = '#dc322f'
local col_magenta = '#d33682'
local col_violet  = '#6c71c4'
local col_blue    = '#268bd2'
local col_cyan    = '#2aa198'
local col_green   = '#859900'

local my_colors   = {
    foreground    = col_base00,
    background    = col_base03,
    cursor_border = col_base1,
    cursor_bg     = col_base01,
    cursor_fg     = col_base1,

    ansi          = {
        col_base02,
        col_red,
        col_green,
        col_yellow,
        col_blue,
        col_magenta,
        col_cyan,
        col_base2,
    },
    brights       = {
        col_base03,
        col_orange,
        col_base01,
        col_base00,
        col_base0,
        col_violet,
        col_base1,
        col_base3,
    }
}

-- local mustang_colors = {
--     background = '#1a1a1a',
--     foreground = '#ffffff',

--     ansi       = {
--         '#000000',
--         '#ff6565',
--         '#93d44f',
--         '#eab93d',
--         '#204a87',
--         '#ce5c00',
--         '#89b6e2',
--         '#cccccc'
--     },
--     brights    = {
--         '#555753',
--         '#ff8d8d',
--         '#c8e7a8',
--         '#ffc123',
--         '#3465a4',
--         '#f57900',
--         '#46a4ff',
--         '#ffffff'
--     }
-- }

return {
    font = wezterm.font(
    -- 'UbuntuSansMono Nerd Font Mono',
        'DejaVuSansM Nerd Font Mono',
        {
            -- stretch = 'Expanded',
            -- stretch = 'Normal',
            weight = 'Regular',
        }
    ),
    font_size = 11.0,
    colors = my_colors,
    -- color_scheme = 'X::Erosion (terminal.sexy)',
    keys = {
        { key = 's', mods = 'ALT', action = wezterm.action.Search 'CurrentSelectionOrEmptyString' }
    },
    enable_tab_bar = false,
    scrollback_lines = 10000,
}
