local ai = require("io.github.israiloff.config.ai")

-- Loading a config module by name, for use as a lazy.nvim `config` handler.
local function conf(name)
	return function()
		require("io.github.israiloff.config." .. name)
	end
end

-- Events that mean "the user actually opened something to edit".
local BUF_ENTER = { "BufReadPre", "BufNewFile" }
local BUF_POST = { "BufReadPost", "BufNewFile" }

return {
	-- -----------------------------------------------------------------------
	-- Core / library
	-- -----------------------------------------------------------------------
	{
		"nvim-lua/plenary.nvim",
		lazy = true,
	},

	-- -----------------------------------------------------------------------
	-- Colorscheme — must be in place before anything paints.
	-- -----------------------------------------------------------------------
	{
		"israiloff/darcula-java",
		lazy = false,
		priority = 1000,
		dependencies = {
			"rktjmp/lush.nvim",
		},
		config = function()
			require("io.github.israiloff.config.theme")
			require("io.github.israiloff.config.colors")
			require("io.github.israiloff.config.transparent")
		end,
	},

	-- -----------------------------------------------------------------------
	-- Treesitter
	-- -----------------------------------------------------------------------
	{
		"nvim-treesitter/nvim-treesitter",
		event = BUF_POST,
		cmd = { "TSUpdate", "TSInstall", "TSInstallInfo" },
		build = ":TSUpdate",
		branch = "master",
		config = conf("treesitter"),
	},

	-- -----------------------------------------------------------------------
	-- LSP stack
	--
	-- mason must be set up before mason-lspconfig, and both must be in place
	-- before the first FileType fires — hence BufReadPre rather than VeryLazy.
	-- -----------------------------------------------------------------------
	{
		"neovim/nvim-lspconfig",
		event = BUF_ENTER,
		dependencies = {
			{
				"williamboman/mason.nvim",
				cmd = { "Mason", "MasonInstall", "MasonUninstall", "MasonUpdate", "MasonLog" },
				config = conf("mason"),
			},
			{
				"williamboman/mason-lspconfig.nvim",
			},
			{
				"WhoIsSethDaniel/mason-tool-installer.nvim",
				cmd = { "MasonToolsInstall", "MasonToolsUpdate", "MasonToolsClean" },
				config = conf("mason-tool-installer"),
			},
			"hrsh7th/cmp-nvim-lsp",
		},
		config = function()
			require("io.github.israiloff.config.mason")
			require("io.github.israiloff.config.mason-lspconfig")
			require("io.github.israiloff.config.lsp-servers")
			require("io.github.israiloff.config.lspconfig")
			-- Must run before any client attaches: `lsp-utils.global_on_attach`
			-- hands buffers to navic, and navic needs its winbar autocmds in place.
			-- Deliberately NOT the nvim-navic spec's own `config` — that module
			-- requires the plugin, so lazy would re-enter it and deadlock.
			require("io.github.israiloff.config.nvim-navic").setup()
		end,
	},
	{
		"SmiteshP/nvim-navic",
		lazy = true,
	},
	{
		"nvimtools/none-ls.nvim",
		event = BUF_ENTER,
		dependencies = {
			"nvim-lua/plenary.nvim",
			"nvimtools/none-ls-extras.nvim",
		},
		config = conf("none-ls"),
	},
	{
		"folke/lazydev.nvim",
		ft = "lua",
		opts = {
			library = {
				{ path = "luvit-meta/library", words = { "vim%.uv" } },
			},
		},
	},
	{ "Bilal2453/luvit-meta", lazy = true },

	-- -----------------------------------------------------------------------
	-- Completion
	-- -----------------------------------------------------------------------
	{
		"hrsh7th/nvim-cmp",
		event = { "InsertEnter", "CmdlineEnter" },
		dependencies = {
			"hrsh7th/cmp-nvim-lsp",
			"hrsh7th/cmp-buffer",
			"hrsh7th/cmp-path",
			"hrsh7th/cmp-cmdline",
			"L3MON4D3/LuaSnip",
			"saadparwaiz1/cmp_luasnip",
			"onsails/lspkind.nvim",
		},
		config = conf("nvim-cmp"),
	},

	-- -----------------------------------------------------------------------
	-- AI completion
	-- -----------------------------------------------------------------------
	{
		"github/copilot.vim",
		event = "InsertEnter",
		enabled = function()
			return ai.is(ai.providers.COPILOT)
		end,
		init = function()
			vim.g.copilot_no_tab_map = true
			vim.g.copilot_assume_mapped = true
		end,
		config = conf("copilot"),
	},
	{
		"TabbyML/vim-tabby",
		event = "InsertEnter",
		enabled = function()
			return ai.is(ai.providers.TABBY)
		end,
		dependencies = {
			"neovim/nvim-lspconfig",
		},
		init = function()
			vim.g.tabby_agent_start_command = ai.get_tabby_agent_start_command()
			vim.g.tabby_inline_completion_trigger = ai.get_tabby_inline_completion_trigger()
			vim.g.tabby_inline_completion_keybinding_accept = ""
		end,
		config = conf("tabby"),
	},

	-- -----------------------------------------------------------------------
	-- Java
	-- -----------------------------------------------------------------------
	{
		"mfussenegger/nvim-jdtls",
		ft = "java",
		dependencies = {
			-- NOTE: archived upstream and still calls the removed
			-- `vim.lsp.buf_get_clients()`. Kept for now, but only loads for Java.
			"markwoodhall/vim-codelens",
		},
	},
	{
		-- Uber-jar consumed directly by config/lsp-servers.lua; no Lua to load.
		"Israiloff/lemminx-compiled",
		version = "v0.28.0",
		lazy = false,
	},

	-- -----------------------------------------------------------------------
	-- Debugging
	-- -----------------------------------------------------------------------
	{
		"mfussenegger/nvim-dap",
		lazy = true,
		config = conf("nvim-dap"),
	},
	{
		"rcarriga/nvim-dap-ui",
		lazy = true,
		dependencies = {
			"mfussenegger/nvim-dap",
			"nvim-neotest/nvim-nio",
		},
		config = conf("nvim-dap-ui"),
	},

	-- -----------------------------------------------------------------------
	-- Telescope
	-- -----------------------------------------------------------------------
	{
		"nvim-telescope/telescope.nvim",
		cmd = "Telescope",
		dependencies = {
			"nvim-lua/plenary.nvim",
			"nvim-telescope/telescope-dap.nvim",
			"dawsers/telescope-file-history.nvim",
			"ahmedkhalf/project.nvim",
		},
		config = function()
			require("io.github.israiloff.config.project-nvim")
			require("io.github.israiloff.config.telescope-file-history")
			require("io.github.israiloff.config.telescope")
		end,
	},
	{
		"MagicDuck/grug-far.nvim",
		cmd = "GrugFar",
		opts = {},
	},

	-- -----------------------------------------------------------------------
	-- UI
	-- -----------------------------------------------------------------------
	{
		"goolord/alpha-nvim",
		event = "VimEnter",
		config = conf("alpha"),
	},
	{
		"nvim-tree/nvim-tree.lua",
		version = "*",
		cmd = { "NvimTreeToggle", "NvimTreeOpen", "NvimTreeFocus", "NvimTreeFindFile" },
		dependencies = {
			"nvim-tree/nvim-web-devicons",
		},
		config = conf("nvim-tree"),
	},
	{
		"akinsho/bufferline.nvim",
		version = "*",
		event = "VeryLazy",
		dependencies = {
			"nvim-tree/nvim-web-devicons",
		},
		config = conf("bufferline"),
	},
	{
		"nvim-lualine/lualine.nvim",
		event = "VeryLazy",
		dependencies = {
			"nvim-tree/nvim-web-devicons",
		},
		config = conf("lualine"),
	},
	{
		"lukas-reineke/indent-blankline.nvim",
		event = BUF_POST,
		main = "ibl",
		opts = {},
	},
	{
		"petertriho/nvim-scrollbar",
		event = BUF_POST,
		config = conf("nvim-scrollbar"),
	},
	{
		"folke/which-key.nvim",
		event = "VeryLazy",
		version = "v2.1.0",
		init = function()
			vim.o.timeout = true
			vim.o.timeoutlen = 300
		end,
		config = conf("which-key"),
	},
	{
		"tamago324/lir.nvim",
		event = "VeryLazy",
		dependencies = {
			"nvim-lua/plenary.nvim",
			"nvim-tree/nvim-web-devicons",
		},
		config = conf("lir"),
	},

	-- -----------------------------------------------------------------------
	-- Editing
	-- -----------------------------------------------------------------------
	{
		"lewis6991/gitsigns.nvim",
		event = BUF_ENTER,
		config = conf("gitsigns"),
	},
	{
		"numToStr/Comment.nvim",
		event = "VeryLazy",
		config = conf("comment"),
	},
	{
		"folke/todo-comments.nvim",
		event = BUF_POST,
		dependencies = { "nvim-lua/plenary.nvim" },
		opts = {},
	},
	{
		"akinsho/toggleterm.nvim",
		version = "*",
		cmd = { "ToggleTerm", "TermExec" },
		keys = { "<M-1>", "<M-2>", "<M-3>", "¡", "™", "£" },
		config = conf("toggleterm"),
	},
	{
		"mhartington/formatter.nvim",
		cmd = { "Format", "FormatWrite", "FormatLock", "FormatWriteLock" },
		config = conf("formatter-nvim"),
	},
	-- -----------------------------------------------------------------------
	-- Installed but currently inert — no setup() call anywhere. Kept lazy so they
	-- cost nothing; candidates for removal.
	-- -----------------------------------------------------------------------
	{ "Pocco81/auto-save.nvim", lazy = true },
	{ "archibate/lualine-time", lazy = true },

	{
		"iamcco/markdown-preview.nvim",
		cmd = { "MarkdownPreviewToggle", "MarkdownPreview", "MarkdownPreviewStop" },
		ft = { "markdown" },
		build = "cd app && yarn install",
		init = conf("markdown"),
	},
}
