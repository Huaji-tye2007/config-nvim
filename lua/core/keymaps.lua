vim.g.mapleader = " "

local map = vim.keymap.set

-- shorten the leader key timeoutlen only in insert mode
vim.api.nvim_create_autocmd('InsertEnter', {
    callback = function() vim.o.timeoutlen = 150 end
})
vim.api.nvim_create_autocmd('InsertLeave', {
    callback = function() vim.o.timeoutlen = 1000 end
})

-- insert mode
map("i", "jk", "<ESC>")
map("i", "<C-C>", "<ESC>")

-- visual mode
map("v", "J", ":m '>+1<CR>gv=gv")
map("v", "K", ":m '<-2<CR>gv=gv")

-- normal mode
-- window
map("n", "<leader>sv", "<C-W>v") -- split vertically
-- map("n", "<leader>sh", "<C-W>s") -- split horizontally; temprorily conflict with telescope
map("n", "<leader>wq", "<C-W>q") -- window quit
map("n", "<C-H>", "<C-W>h")
map("n", "<C-J>", "<C-W>j")
map("n", "<C-K>", "<C-W>k")
map("n", "<C-L>", "<C-W>l")
-- window resizing
map("n", "<C-Up>", "<cmd>resize +2<CR>", { desc = "Increase window height" })
map("n", "<C-Down>", "<cmd>resize -2<CR>", { desc = "Decrease window height" })
map("n", "<C-Left>", "<cmd>vertical resize -2<CR>", { desc = "Decrease window width" })
map("n", "<C-Right>", "<cmd>vertical resize +2<CR>", { desc = "Increase window width" })
-- tab
map("n", "<leader>tn", ":tabnew<CR>")
map("n", "<leader>te", ":tabedit")
map("n", "<leader>tc", ":tabclose<CR>")
map("n", "<C-]>", "gt") -- move to next tab
map("n", "<C-[>", "gT") -- move to next tab
-- line
map("n", "<leader>l", "$")
map("n", "<leader>h", "^")

-- cancel highlight
map("n", "<leader>nh", ":nohl<CR>")

-- tiny-inline diagnostic
map("n", "<leader>dt", "<cmd>TinyInlineDiag toggle<cr>", { desc = "Toggle diagnostics" })

-- formatter shortcut
map({ "n", "v" }, "<leader>fm", function()
    require("conform").format({
        lsp_fallback = true,
        async = false,
        timeout_ms = 500,
    })
end, { desc = "Format the current file or selected area." })

-- NvimTree Toggle
map({ "n", "v", "i" }, "<leader>tt", ":NvimTreeToggle<CR>", { noremap = true, silent = true })

-- buffer
map("n", "<leader>bd", ":bdelete<CR>", { desc = "Close Current Buffer", silent = true })
