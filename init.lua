-- ui2
require("vim._core.ui2").enable({})

require("core.options")
require("core.keymaps")

-- Load plugins
require("plugins.plugin-set")

-- Load common plugin-setup
require("plugins.tokyonight")
require("plugins.nvimwebdevicons")
require("plugins.lualine")
require("plugins.nvim-tree")
require("plugins.tinyinline")
require("plugins.cmp")
require("plugins.comment")
require("plugins.autopairs")
require("plugins.conform")
require("plugins.telescope")
require("plugins.gitsigns")
require("plugins.dap")
require("plugins.dap-disam")
require("plugins.dap-view")

-- Load lsp set-up
require("plugins.lsp.lsp_conf")
