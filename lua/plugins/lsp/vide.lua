-- ~/.config/nvim/lua/plugins/lsp/vide.lua
vim.lsp.config('vide', {
    cmd = { 'vide' },
    filetypes = { 'verilog', 'systemverilog' },
    root_markers = { 'vide.toml', '.git' },
    init_options = {
        diagnostics = {
            update = 'onType',
        },
        inlayHints = {
            port = {
                connection = {
                    enable = true,
                },
            },
        },
    },
})
