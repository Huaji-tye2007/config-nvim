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

-- init mason-lspconfig
require("mason-lspconfig").setup()

-- load every lsp config lua files
require("plugins.lsp.lua")
require("plugins.lsp.markdown")
require("plugins.lsp.slang")
require("plugins.lsp.verible")

-- all server completion support
local cmp_nvim_lsp = require("cmp_nvim_lsp")
local capabilities = cmp_nvim_lsp.default_capabilities();
vim.lsp.config('*', { capabilities = capabilities })

-- start the servers
vim.lsp.enable({
    "lua_ls",
    "pyright",
    -- "ast_grep",
    "marksman",     -- markdown
    "tailwindcss",  -- css html and markdown
    "slang-server", -- verilog
    "verible",      -- verilog
    "clangd",
})

vim.filetype.add({
    extension = {
        v  = 'verilog',
        vh = 'verilog',
    }
})
