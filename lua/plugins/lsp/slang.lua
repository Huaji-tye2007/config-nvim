-- ~/.config/nvim/lua/plugins/lsp/slang.lua
-- require('lspconfig.configs').slang_server = nil
vim.lsp.config('slang_server', {
    filetype = { 'verilog', 'systemverilog' },
    root_markers = { '.git', '.slang' },
    cmd = { 'slang-server', '--std', '1364-2005' }
})
