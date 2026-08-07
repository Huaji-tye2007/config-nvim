-- ~/.config/nvim/lua/plugins/lsp/slang.lua
vim.lsp.config('slang-server', {
    filetypes = { 'verilog', 'systemverilog' },
    root_markers = { '.git', '.slang' },
    cmd = { 'slang-server', '--std', '1364-2005' }
})
