-- ~/.config/nvim/lua/plugins/telescope.lua

local telescope = require("telescope")
local lga_actions = require("telescope-live-grep-args.actions")

telescope.setup({
    defaults = {
        mappings = {
            i = {
            },
        },
    },
    extentions = {
        auto_quoting = false,
        mappings = {
            i = {
            },
        },
    }
})

telescope.load_extension("live_grep_args")

-- Telescope
local map = vim.keymap.set
local builtin = require('telescope.builtin')
map('n', '<leader>ff', builtin.find_files, {})
map("n", "<leader>fg",
    ":lua require('telescope').extensions.live_grep_args.live_grep_args()<CR>", {})
map('n', '<leader>fb', builtin.buffers, {})
map('n', '<leader>ws', builtin.lsp_workspace_symbols, {})
map('n', '<leader>gc', builtin.git_commits, {})
map('n', '<leader>sh', builtin.search_history, {})
map('n', '<leader>fh', builtin.help_tags, {})
