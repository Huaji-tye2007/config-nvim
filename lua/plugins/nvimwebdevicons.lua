-- ~/.config/nvim/lua/plugins/nvimwebdevicons.lua

-- Safely load
local status_ok, nvimwebdevicons = pcall(require, "nvimwebdevicons")
if not status_ok then
    return
end

nvimwebdevicons.setup({
    color_icons = true,
    default = true,
    strict = true,
    blend = 0.5,
})
