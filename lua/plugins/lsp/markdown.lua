-- ~/.config/nvim/lua/plugins/lsp/markdown.lua
local ns = vim.api.nvim_create_namespace("markdownlint-cli2")

local function run_markdownlint(bufnr)
    bufnr = bufnr or 0
    if vim.bo[bufnr].filetype ~= "markdown" then
        return
    end
    local lines = vim.api.nvim_buf_get_lines(bufnr, 0, -1, false)
    local input = table.concat(lines, "\n")

    vim.system(
        { "markdownlint-cli2", "-" },
        { stdin = input, text = true },
        vim.schedule_wrap(function(result)
            local output = result.stderr or ""
            local out_lines = vim.split(output, "\n", { trimempty = true })

            local qf = vim.fn.getqflist({
                lines = out_lines,
                efm = "stdin:%l:%c %m,stdin:%l %m",
            })

            local diagnostics = {}
            for _, item in ipairs(qf.items or {}) do
                if item.valid == 1 then
                    table.insert(diagnostics, {
                        lnum = item.lnum - 1,
                        col = (item.col or 1) - 1,
                        message = item.text,
                        severity = vim.diagnostic.severity.WARN,
                        source = "markdownlint",
                    })
                end
            end

            vim.diagnostic.set(ns, bufnr, diagnostics)
        end)
    )
end

vim.api.nvim_create_autocmd({ "BufWritePost", "InsertLeave" }, {
    pattern = "*.md",
    callback = function(args)
        run_markdownlint(args.buf)
    end,
})
