local which_key = require("which-key")

which_key.setup({
	plugins = {
		marks = true, -- shows a list of your marks on ' and `
		registers = true, -- shows your registers on " in NORMAL or <C-r> in INSERT mode
		-- the presets plugin, adds help for a bunch of default keybindings in Neovim
		-- No actual key bindings are created
		spelling = {
			enabled = false, -- enabling this will show WhichKey when pressing z= to select spelling suggestions
			suggestions = 20, -- how many suggestions should be shown in the list?
		},
		presets = {
			operators = false, -- adds help for operators like d, y, ...
			motions = false, -- adds help for motions
			text_objects = false, -- help for text objects triggered after entering an operator
			windows = false, -- default bindings on <c-w>
			nav = false, -- misc bindings to work with windows
			z = false, -- bindings for folds, spelling and others prefixed with z
			g = false, -- bindings for prefixed with g
		},
	},
	-- add operators that will trigger motion and text object completion
	-- to enable all native operators, set the preset / operators plugin above
	operators = { gc = "Comments" },
	key_labels = {
		-- override the label used to display some keys. It doesn't effect WK in any other way.
		-- For example:
		-- ["<space>"] = "SPC",
		-- ["<cr>"] = "RET",
		-- ["<tab>"] = "TAB",
	},
	motions = {
		count = true,
	},
	icons = {
		breadcrumb = "»", -- symbol used in the command line area that shows your active key combo
		separator = "➜", -- symbol used between a key and it's label
		group = "+", -- symbol prepended to a group
	},
	popup_mappings = {
		scroll_down = "<c-d>", -- binding to scroll down inside the popup
		scroll_up = "<c-u>", -- binding to scroll up inside the popup
	},
	window = {
		border = "single", -- none, single, double, shadow
		position = "bottom", -- bottom, top
		margin = { 1, 0, 1, 0 }, -- extra window margin [top, right, bottom, left]. When between 0 and 1, will be treated as a percentage of the screen size.
		padding = { 1, 2, 1, 2 }, -- extra window padding [top, right, bottom, left]
		winblend = 0, -- value between 0-100 0 for fully opaque and 100 for fully transparent
		zindex = 1000, -- positive value to position WhichKey above other floating windows.
	},
	layout = {
		height = { min = 4, max = 25 }, -- min and max height of the columns
		width = { min = 20, max = 50 }, -- min and max width of the columns
		spacing = 3, -- spacing between columns
		align = "left", -- align columns left, center or right
	},
	ignore_missing = false, -- enable this to hide mappings for which you didn't specify a label
	hidden = { "<silent>", "<cmd>", "<Cmd>", "<CR>", "^:", "^ ", "^call ", "^lua " }, -- hide mapping boilerplate
	show_help = true, -- show a help message in the command line for using WhichKey
	show_keys = true, -- show the currently pressed key and its label as a message in the command line
	triggers = "auto", -- automatically setup triggers
	-- triggers = {"<leader>"} -- or specify a list manually
	-- list of triggers, where WhichKey should not wait for timeoutlen and show immediately
	triggers_nowait = {
		-- marks
		"`",
		"'",
		"g`",
		"g'",
		-- registers
		'"',
		"<c-r>",
		-- spelling
		"z=",
	},
	triggers_blacklist = {
		-- list of mode / prefixes that should never be hooked by WhichKey
		-- this is mostly relevant for keymaps that start with a native binding
		i = { "j", "k" },
		v = { "j", "k" },
	},
	-- disable the WhichKey popup for certain buf types and file types.
	-- Disabled by default for Telescope
	disable = {
		buftypes = {},
		filetypes = {},
	},
})

which_key.register({
	f = { "<cmd>Telescope find_files<cr>", "Find Files" },
	u = { "<cmd>so<cr>", "Update configs" },
	c = { "<cmd>bd<cr>", "Close buffer" },
	q = { "<cmd>confirm q<CR>", "Quit" },
	e = { "<cmd>NvimTreeToggle<CR>", "Explorer" },
	l = {
		name = "Code",
		d = { "<cmd>Telescope diagnostics bufnr=0 theme=get_ivy<cr>", "Buffer Diagnostics" },
		w = { "<cmd>Telescope diagnostics<cr>", "Diagnostics" },
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
		l = { "<cmd>mess<CR>", "Show notification log" },
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
	g = {
		name = "Git",
		g = { "<cmd>lua require 'lvim.core.terminal'.lazygit_toggle()<cr>", "Lazygit" },
		j = { "<cmd>lua require 'gitsigns'.nav_hunk('next', {navigation_message = false})<cr>", "Next Hunk" },
		k = { "<cmd>lua require 'gitsigns'.nav_hunk('prev', {navigation_message = false})<cr>", "Prev Hunk" },
		l = { "<cmd>lua require 'gitsigns'.blame_line()<cr>", "Blame" },
		L = { "<cmd>lua require 'gitsigns'.blame_line({full=true})<cr>", "Blame Line (full)" },
		p = { "<cmd>lua require 'gitsigns'.preview_hunk()<cr>", "Preview Hunk" },
		r = { "<cmd>lua require 'gitsigns'.reset_hunk()<cr>", "Reset Hunk" },
		R = { "<cmd>lua require 'gitsigns'.reset_buffer()<cr>", "Reset Buffer" },
		s = { "<cmd>lua require 'gitsigns'.stage_hunk()<cr>", "Stage Hunk" },
		u = {
			"<cmd>lua require 'gitsigns'.undo_stage_hunk()<cr>",
			"Undo Stage Hunk",
		},
		o = { "<cmd>Telescope git_status<cr>", "Open changed file" },
		b = { "<cmd>Telescope git_branches<cr>", "Checkout branch" },
		c = { "<cmd>Telescope git_commits<cr>", "Checkout commit" },
		C = {
			"<cmd>Telescope git_bcommits<cr>",
			"Checkout commit(for current file)",
		},
		d = {
			"<cmd>Gitsigns diffthis HEAD<cr>",
			"Git Diff",
		},
	},
	["/"] = {
		"<Plug>(comment_toggle_linewise_current)",
		"Comment current line",
	},
}, {
	prefix = "<leader>",
	mode = "n",
})

which_key.register({
	["/"] = {
		"<Plug>(comment_toggle_linewise_visual)",
		"Comment",
	},
}, {
	prefix = "<leader>",
	mode = { "v" },
})

which_key.register({
	a = {
		name = "Open AI",
		c = { "<cmd>ChatGPT<CR>", "ChatGPT" },
		e = { "<cmd>ChatGPTEditWithInstruction<CR>", "Edit with instruction" },
		g = { "<cmd>ChatGPTRun grammar_correction<CR>", "Grammar Correction" },
		t = { "<cmd>ChatGPTRun translate<CR>", "Translate" },
		k = { "<cmd>ChatGPTRun keywords<CR>", "Keywords" },
		d = { "<cmd>ChatGPTRun docstring<CR>", "Docstring" },
		a = { "<cmd>ChatGPTRun add_tests<CR>", "Add Tests" },
		o = { "<cmd>ChatGPTRun optimize_code<CR>", "Optimize Code" },
		s = { "<cmd>ChatGPTRun summarize<CR>", "Summarize" },
		f = { "<cmd>ChatGPTRun fix_bugs<CR>", "Fix Bugs" },
		x = { "<cmd>ChatGPTRun explain_code<CR>", "Explain Code" },
		r = { "<cmd>ChatGPTRun roxygen_edit<CR>", "Roxygen Edit" },
		l = { "<cmd>ChatGPTRun code_readability_analysis<CR>", "Code Readability Analysis" },
	},
	A = {
		name = "Copilot",
		p = { "<cmd>Copilot panel<CR>", "Open Copilot Panel" },
	},
	l = {
		name = "Code",
		a = { "<cmd>lua vim.lsp.buf.code_action()<cr>", "Action" },
		f = { "<cmd>Format<cr>", "Format" },
	},
}, {
	prefix = "<leader>",
	mode = { "n", "v" },
})
