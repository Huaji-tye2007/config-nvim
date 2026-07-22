-- ~/.config/nvim/lua/plugins/new_treesitter.lua

local ok, treesitter = pcall(require, "nvim-treesitter")
if not ok then
    return
end

treesitter.setup({
    ensure_installed = {
        'c', 'cpp', 'lua', 'python', 'markdown', 'query' },
    install_dir = vim.fn.stdpath('data') .. '/site',
})
