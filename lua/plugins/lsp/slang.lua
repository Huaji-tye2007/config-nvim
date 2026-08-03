-- ~/.config/nvim/lua/plugins/lsp/slang.lua
vim.lsp.config('slang_server', {
    filetype = { 'verilog', 'systemverilog' },
    root_markers = { '.git', '.slang' },
    cmd = { 'slang-server', '--std', '1364-2005' }
})
