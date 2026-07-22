-- ~/.config/nvim/lua/plugins/lsp/lsp_conf.lua

-- init mason
require("mason").setup({
    ui = {
        icons = {
            package_installed = "✓",
            package_pending = "➜",
            package_uninstalled = "✗"
        }
    }
})

-- all server completion support
local cmp_nvim_lsp = require("cmp_nvim_lsp")
local capabilities = cmp_nvim_lsp.default_capabilities();
vim.lsp.config('*', { capabilities = capabilities })

-- init mason-lspconfig
require("mason-lspconfig").setup()

-- load every lsp config lua files
require("plugins.lsp.lua")
-- require("plugins.lsp.python")
-- require("plugins.lsp.c")

-- start the servers
vim.lsp.enable({
    "lua_ls",
    "pyright",
    -- "ast_grep",
    "marksman",     -- markdown
    "slang-server", -- verilog
    "clangd",
})
