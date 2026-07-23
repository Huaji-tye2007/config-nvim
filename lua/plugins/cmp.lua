-- ~/.config/nvim/lua/plugins/cmp.lua

-- Safely load
local cmp_status_ok, cmp = pcall(require, "cmp")
if not cmp_status_ok then
    return
end

local snip_status_ok, luasnip = pcall(require, "luasnip")
if not snip_status_ok then
    return
end

local status_ok, lspkind = pcall(require, "lspkind")
if not status_ok then
    return
end

require("luasnip.loaders.from_vscode").lazy_load()

local check_backspace = function()
    local col = vim.fn.col "." - 1
    return col == 0 or vim.fn.getline("."):sub(col, col):match "%s"
end

local source_mapping = {
    nvim_lsp = "[LSP]",
    nvim_lua = "[LUA]",
    luasnip = "[SNIP]",
    buffer = "[BUF]",
    path = "[PATH]",
    -- treesitter = "[TREE]",
    ["vim-dadbod-completion"] = "[DB]",
}

cmp.setup({
    window = {
        completion = cmp.config.window.bordered({ border = "rounded" }),
        documentation = cmp.config.window.bordered({ border = "rounded" }),
    },
    formatting = {
        format = lspkind.cmp_format({
            mode = "symbol_text",
            ellipsis_char = "...",
            before = function(entry, item)
                return item
            end,
            menu = source_mapping,
        }),
    },
    sorting = {
        priority_weight = 2,
        comparators = {
            cmp.config.compare.offset,
            cmp.config.compare.exact,
            cmp.config.compare.score,
            cmp.config.compare.recently_used,
            cmp.config.compare.kind,
            cmp.config.compare.sort_text,
            cmp.config.compare.length,
            cmp.config.compare.order,
        },
    },
    snippet = {
        expand = function(args)
            require('luasnip').lsp_expand(args.body)
        end,
    },
    mapping = cmp.mapping.preset.insert({
        ['<C-b>'] = cmp.mapping.scroll_docs(-4),
        ['<C-f>'] = cmp.mapping.scroll_docs(4),
        ['<C-e>'] = cmp.mapping.abort(),
        ['<CR>'] = cmp.mapping.confirm({ select = true }),

        ["<Tab>"] = cmp.mapping(function(fallback)
            if cmp.visible() then
                cmp.select_next_item()
            elseif luasnip.expandable() then
                luasnip.expand()
            elseif luasnip.expand_or_jumpable() then
                luasnip.expand_or_jump()
            elseif check_backspace() then
                fallback()
            else
                fallback()
            end
        end, {
            "i",
            "s",
        }),

        ["<S-Tab>"] = cmp.mapping(function(fallback)
            if cmp.visible() then
                cmp.select_prev_item()
            elseif luasnip.jumpable(-1) then
                luasnip.jump(-1)
            else
                fallback()
            end
        end, {
            "i",
            "s",
        }),
    }),

    sources = cmp.config.sources({
        {
            name = "luasnip",
            group_index = 1,
            option = { use_show_condition = true },
            entry_filter = function()
                local context = require("cmp.config.context")
                return not context.in_treesitter_capture("string")
                    and not context.in_syntax_group("String")
            end,
        },
        {
            name = "nvim_lsp",
            group_index = 2,
            option = {
                markdown = {
                    keyword_pattern = [[\S\+]],
                },
            },
        },
        {
            name = "nvim_lua",
            group_index = 3,
        },
        {
            name = "path",
            keyword_length = 4,
            group_index = 4,
        },
        {
            name = "buffer",
            keyword_length = 3,
            group_index = 5,
            option = {
                get_bufnrs = function()
                    local bufs = {}
                    for _, win in ipairs(vim.api.nvim_list_wins()) do
                        bufs[vim.api.nvim_win_get_buf(win)] = true
                    end
                    return vim.tbl_keys(bufs)
                end,
            },
        },
    })
})
