-- native plugin manager for 0.12 or later

vim.pack.add({
    -- Themes
    { src = "https://github.com/folke/tokyonight.nvim" },

    -- Status Bar
    { src = "https://github.com/nvim-tree/nvim-web-devicons" },
    { src = "https://github.com/nvim-lualine/lualine.nvim" },

    -- File browser
    -- { src = "https://github.com/nvim-tree/nvim-tree.lua" },
    { src = "https://github.com/MunifTanjim/nui.nvim" },
    { src = "https://github.com/nvim-neo-tree/neo-tree.nvim" },

    -- LSP
    { src = "https://github.com/mason-org/mason.nvim" },
    { src = "https://github.com/mason-org/mason-lspconfig.nvim" },
    { src = "https://github.com/neovim/nvim-lspconfig" },

    -- Debugging & DAP
    { src = "https://github.com/mfussenegger/nvim-dap" },
    { src = "https://codeberg.org/Jorenar/nvim-dap-disasm.git" },
    {
        src = "https://github.com/igorlfs/nvim-dap-view",
        version = vim.version.range("1.*")
    },
    { src = "https://github.com/akinsho/toggleterm.nvim" },
    { src = "https://github.com/ryanmsnyder/toggleterm-manager.nvim" },
    -- { src ="https://github.com/rcarriga/nvim-dap-ui"},

    -- Inline diagnostic
    { src = "https://github.com/rachartier/tiny-inline-diagnostic.nvim" },

    -- New TreeSitter for Neovim 0.12+
    {
        src = "https://github.com/nvim-treesitter/nvim-treesitter",
        version = "main"
    },

    -- Completion
    { src = "https://github.com/hrsh7th/nvim-cmp" },
    { src = "https://github.com/hrsh7th/cmp-nvim-lsp" },
    { src = "https://github.com/hrsh7th/cmp-path" },
    { src = "https://github.com/hrsh7th/cmp-cmdline" },
    { src = "https://github.com/L3MON4D3/LuaSnip" },
    { src = "https://github.com/saadparwaiz1/cmp_luasnip" },
    { src = "https://github.com/hrsh7th/cmp-buffer" },
    { src = "https://github.com/hrsh7th/cmp-nvim-lua" },
    { src = "https://github.com/onsails/lspkind.nvim" },

    -- Auto-pairs
    { src = "https://github.com/windwp/nvim-autopairs" },

    -- Formatter
    { src = "https://github.com/stevearc/conform.nvim" },

    -- Telescope & multi-media
    { src = "https://github.com/nvim-lua/plenary.nvim" },
    { src = "https://github.com/nvim-telescope/telescope-live-grep-args.nvim" },
    { src = "https://github.com/3rd/image.nvim" },
    { src = "https://github.com/nvim-telescope/telescope.nvim" },
    { src = "https://github.com/folke/snacks.nvim" },

    -- git
    { src = "https://github.com/lewis6991/gitsigns.nvim" },
    { src = "https://github.com/NeogitOrg/neogit" },

    -- copilot
    { src = "https://github.com/github/copilot.vim" },
})
