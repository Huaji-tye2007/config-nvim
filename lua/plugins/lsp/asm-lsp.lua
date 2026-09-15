-- ~/.config/nvim/lua/asm-lsp.lua

vim.lsp.config("asm-lsp", {
    cmd = { "asm-lsp" },
    filetypes = { "asm", "s", "S", 'vmasm' },
    root_markers = { '.git', '.asm-lsp.toml' },
})
