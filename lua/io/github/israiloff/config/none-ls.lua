local null_ls = require("null-ls")
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
