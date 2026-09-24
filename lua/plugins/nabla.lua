-- ~/.config/nvim/lua/plugins/nabla.lua

local ok, nabla = pcall(require, "nabla")
if not ok then
    return
end

vim.keymap.set("n", "<leader>mp", function()
    nabla.popup()
end, { desc = "Preview math formula under cursor (nabla)" })
