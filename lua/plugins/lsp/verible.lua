-- ~/.config/nvim/lua/plugins/lsp/verible.lua
vim.lsp.config('verible', {
    cmd = { "verible-verilog-ls", "--rules_config_search" }
})
