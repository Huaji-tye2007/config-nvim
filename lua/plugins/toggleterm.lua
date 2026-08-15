-- ~/.config/nvim/lua/toggleterm.lua

local ok, toggleterm = pcall(require, "toggleterm")
if not ok then
    return
end

local okk, toggleterm_manager = pcall(require, "toggleterm-manager")
if not okk then
    return
end
local actions = toggleterm_manager.actions

toggleterm.setup({
    size = function(term)
        if term.direction == "horizontal" then
            return 15
        elseif term.direction == "vertical" then
            return vim.o.columns * 0.4
        end
    end,
    open_mapping = [[<C-\>]],
    hide_numbers = true,      -- 隐藏终端里的行号
    shade_terminals = true,   -- 终端背景颜色稍微调暗以便和代码区区分
    start_in_insert = true,   -- 唤出终端时直接进入 Insert 模式，方便立即敲命令
    insert_mappings = false,  -- 插入模式下是否支持 open_mapping
    terminal_mappings = false,
    persist_size = true,      -- 记住你调整过的终端大小
    direction = "horizontal", -- 默认打开方向：'vertical' | 'horizontal' | 'tab' | 'float'
    close_on_exit = true,     -- 命令执行完毕自动关闭窗口
    -- 悬浮终端的 UI 样式 float_opts = { border = "curved", -- 'single' | 'double' | 'shadow' | 'curved'
    winblend = 3,             -- 悬浮窗透明度
})

function _G.set_terminal_keymaps()
    local opts = { buffer = 0 }
    vim.keymap.set('t', '<esc>', [[<C-\><C-n>]], opts)
    vim.keymap.set('t', 'jk', [[<C-\><C-n>]], opts)
    vim.keymap.set('t', '<C-h>', [[<Cmd>wincmd h<CR>]], opts)
    vim.keymap.set('t', '<C-j>', [[<Cmd>wincmd j<CR>]], opts)
    vim.keymap.set('t', '<C-k>', [[<Cmd>wincmd k<CR>]], opts)
    vim.keymap.set('t', '<C-l>', [[<Cmd>wincmd l<CR>]], opts)
    vim.keymap.set('t', '<C-w>', [[<C-\><C-n><C-w>]], opts)
end

-- if you only want these mappings for toggle term use term://*toggleterm#* instead
vim.cmd('autocmd! TermOpen term://* lua set_terminal_keymaps()')

toggleterm_manager.setup({
    mappings = {                                                                  -- key mappings bound inside the telescope window
        i = {
            ["<CR>"] = { action = actions.toggle_term, exit_on_action = false },  -- toggles terminal open/closed
            ["<C-n>"] = { action = actions.create_term, exit_on_action = false }, -- creates a new terminal buffer
            ["<C-d>"] = { action = actions.delete_term, exit_on_action = false }, -- deletes a terminal buffer
            ["<C-r>"] = { action = actions.rename_term, exit_on_action = false }, -- provides a prompt to rename a terminal
        },
    },
    titles = {
        preview = "Preview", -- title of the preview buffer in telescope
        prompt = " Terminals", -- title of the prompt buffer in telescope
        results = "Results", -- title of the results buffer in telescope
    },
    results = {
        fields = { -- fields that will appear in the results of the telescope window
            "state", -- the state of the terminal buffer: h = hidden, a = active
            "space", -- adds space between fields, if desired
            "term_icon", -- a terminal icon
            "term_name", -- toggleterm's display_name if it exists, else the terminal's id assigned by toggleterm
        },
        separator = " ", -- the character that will be used to separate each field provided in results.fields
        term_icon = "", -- the icon that will be used for term_icon in results.fields
    },
    search = {
        field = "term_name" -- the field that telescope fuzzy search will use when typing in the prompt
    },
    sort = {
        field = "term_name", -- the field that will be used for sorting in the telesocpe results
        ascending = true,    -- whether or not the field provided above will be sorted in ascending or descending order
    },
})

vim.keymap.set('n', '<leader>tm', ":Telescope toggleterm_manager<CR>", { desc = "Toggle all terminals" })
