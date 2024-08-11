local log_status, log = pcall(require, "io.github.israiloff.config.logger")

if not log_status then
    vim.notify("Logger not found. Aborting null-ls configuration.", vim.log.levels.ERROR)
    return
end

local logger_name = "io.github.israiloff.config.none-ls"

local null_ls_status, null_ls = pcall(require, "null-ls")

if not null_ls_status then
    log.error(logger_name, "'null-ls' not found. Aborting null-ls configuration.")
    return
end

local lsp_utils_status, lsp_utils = pcall(require, "io.github.israiloff.config.lsp-utils")

if not lsp_utils_status then
    log.error(logger_name, "'lsp-utils' not found. Aborting null-ls configuration.")
    return
end

local formatting = null_ls.builtins.formatting
local diagnostics = null_ls.builtins.diagnostics

null_ls.setup({
    debug = false,
    sources = {
        formatting.prettier.with({
            extra_args = function(params)
                if params.filetype == "ruby" then
                    return { "--config", "--plugin=@prettier/plugin-ruby" }
                end

                return {
                    "--config",
                    "--arrow-parens",
                    "avoid",
                }
            end,
            extra_filetypes = { "ruby" },
        }),
        formatting.black.with({ extra_args = { "--fast" } }),
        formatting.stylua,
        formatting.sql_formatter,
        formatting.golines,
        formatting.gofmt,
        formatting.shfmt,
        diagnostics.rubocop,
        require("none-ls.diagnostics.eslint"),
    },
})
