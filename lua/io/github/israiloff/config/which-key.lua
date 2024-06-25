local icons = require("io.github.israiloff.config.icons")
local which_key = require("which-key")

which_key.register({
	f = { "<cmd>Telescope find_files<cr>", "Find Files" },
	u = { "<cmd>so<cr>", "Update configs" },
	c = { "<cmd>Ex<cr>", "Close buffer" },
	q = { "<cmd>confirm q<CR>", "Quit" },
	e = { "<cmd>NvimTreeToggle<CR>", "Explorer" },
	l = {
		name = "Code",
		a = { "<cmd>lua vim.lsp.buf.code_action()<cr>", "Action" },
		d = { "<cmd>Telescope diagnostics bufnr=0 theme=get_ivy<cr>", "Buffer Diagnostics" },
		w = { "<cmd>Telescope diagnostics<cr>", "Diagnostics" },
		f = { "<cmd>Format<cr>", "Format" },
		i = { "<cmd>LspInfo<cr>", "Info" },
		j = { "<cmd>lua vim.diagnostic.goto_next()<cr>", "Next Diagnostic" },
		k = { "<cmd>lua vim.diagnostic.goto_prev()<cr>", "Prev Diagnostic" },
		r = { "<cmd>lua vim.lsp.buf.rename()<cr>", "Rename" },
	},
}, { prefix = "<leader>", mode = "n" })
