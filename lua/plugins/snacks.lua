-- ~/.config/nvim/lua/plugins/snacks.lua

local ok, snacks = pcall(require, "snacks")
if not ok then
    return
end

snacks.setup({})
