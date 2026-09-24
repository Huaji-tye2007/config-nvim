-- ~/.config/nvim/lua/plugins/lsp/latex.lua

-- Compilation and PDF preview are handled by vimtex (see plugins.vimtex);
-- texlab here only provides diagnostics/completion/go-to-reference.
vim.lsp.config('texlab', {
    settings = {
        texlab = {
            build = {
                onSave = false,
            },
            forwardSearch = {
                onSave = false,
            },
            chktex = {
                onOpenAndSave = true,
            },
        },
    },
})
