-- ~/.config/nvim/lua/plugins/nvim-tree.lua

-- Safely load
local status_ok, nvimtree = pcall(require, "nvim-tree")
if not status_ok then
    return
end

-- disable netrw
vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1

nvimtree.setup({
    sort = {
      sorter = "case_sensitive",
    },
    view = {
      width = 20,
    },
    renderer = {
      group_empty = true,
    },
    filters = {
      dotfiles = true,
    },
})
