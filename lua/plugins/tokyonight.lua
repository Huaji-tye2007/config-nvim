-- ~/.config/nvim/lua/plugins/tokyonights.lua

-- safely load
local status_ok, tokyonight = pcall(require, "tokyonight")
if not status_ok then
    return
end

tokyonight.setup({
    style = "moon",
    light_style = "day",
    transparent = false,
    terminal_colors = true,
    styles = {
      comments = { italic = true }, 
      keywords = { italic = true },
      functions = { },
      variables = { },
      sidebars = "dark", 
      floats = "dark", 
    },
    dim_inactive = true,
})

vim.cmd.colorscheme("tokyonight")
