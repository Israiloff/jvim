local icons = require("io.github.israiloff.config.icons")
local which_key = require("which-key")

which_key.register({
	f = { "<cmd>Telescope find_files<cr>", "Find Files" },
	u = { "<cmd>so<cr>", "Update configs" },
	c = { "<cmd>bd<cr>", "Close buffer" },
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
	F = {
		name = "File",
		h = { "<cmd>Telescope file_history history<CR>", "View the file’s history", mode = { "n" } },
		l = { "<cmd>Telescope file_history log<CR>", "View the file’s history incrementally", mode = { "n" } },
		f = { "<cmd>Telescope file_history files<CR>", "View every file in the repo", mode = { "n" } },
	},
	n = {
		name = "Notifications",
		l = { "<cmd>mess<CR>", "Show notification log", mode = { "n" } },
	},
	s = {
		name = "Search",
		b = { "<cmd>Telescope git_branches<cr>", "Checkout branch" },
		c = { "<cmd>Telescope colorscheme<cr>", "Colorscheme" },
		f = { "<cmd>Telescope find_files<cr>", "Find File" },
		h = { "<cmd>Telescope help_tags<cr>", "Find Help" },
		H = { "<cmd>Telescope highlights<cr>", "Find highlight groups" },
		M = { "<cmd>Telescope man_pages<cr>", "Man Pages" },
		r = { "<cmd>Telescope oldfiles<cr>", "Open Recent File" },
		R = { "<cmd>Telescope registers<cr>", "Registers" },
		t = { "<cmd>Telescope live_grep<cr>", "Text" },
		k = { "<cmd>Telescope keymaps<cr>", "Keymaps" },
		C = { "<cmd>Telescope commands<cr>", "Commands" },
		l = { "<cmd>Telescope resume<cr>", "Resume last search" },
		p = {
			"<cmd>lua require('telescope.builtin').colorscheme({enable_preview = true})<cr>",
			"Colorscheme with Preview",
		},
	},
}, { prefix = "<leader>", mode = "n" })
