-- ~/.config/nvim/lua/plugins/neotree.lua

-- Safely load
local status_ok, neotree = pcall(require, "neo-tree")
if not status_ok then
    return
end

vim.diagnostic.config({
    signs = {
        text = {
            [vim.diagnostic.severity.ERROR] = '',
            [vim.diagnostic.severity.WARN] = '',
            [vim.diagnostic.severity.INFO] = '',
            [vim.diagnostic.severity.HINT] = '󰌵',
        },
    }
})

neotree.setup({
    sources = {
        "document_symbols",
        "filesystem",
        "buffers",
        "git_status",
    },
    source_selector = {
        winbar = true,
        statusline = false,
    },
    clipboard = {
        sync = "global",
    },
    close_if_last_window = false,
    window = {
        width = 35,
    },
})
