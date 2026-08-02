-- ~/.config/nvim/lua/plugins/tokyonights.lua

-- safely load
local status_ok, tokyonight = pcall(require, "tokyonight")
if not status_ok then
    return
end

tokyonight.setup({
    style = "moon",
    light_style = "day",
    transparent = true,
    terminal_colors = true,
    styles = {
        comments = { italic = true },
        keywords = { italic = true },
        functions = {},
        variables = {},
        sidebars = "dark",
        floats = "dark",
    },
    dim_inactive = true,
    on_highlights = function(hl, c)
        hl.LineNr = { fg = "#ff9e64" }
        hl.CursorLineNr = { fg = "#ff9e64" }
        hl.LineNrAbove = { fg = "#ff9e64" }
        hl.LineNrBelow = { fg = "#ff9e64" }
        local transparent_groups = {
            "NeoTreeNormal",
            "NeoTreeNormalNC",
            "NeoTreeFloatNormal",
            "NeoTreeFloatBorder",
            "NeoTreePopupNormal",
            "NeoTreePopupBorder",
            "NuiComponentsPopupHint",
            "NuiComponentsPopupBorder",
            "NormalFloat",
            "FloatBorder",
            "TelescopeNormal",
            "TelescopeBorder",
            "TelescopePromptNormal",
            "TelescopeResultsNormal",
            "TelescopePreviewNormal"
        }

        for _, group in ipairs(transparent_groups) do
            if hl[group] then
                hl[group].bg = "none"
            else
                hl[group] = { bg = "none" }
            end
        end
    end,
})

vim.cmd.colorscheme("tokyonight")
