return {
	{
		"nvim-treesitter/nvim-treesitter",
		run = ":TSUpdate",
	},
	{
		"nvim-lua/plenary.nvim",
	},
	{
		"folke/which-key.nvim",
		event = "VeryLazy",
		init = function()
			vim.o.timeout = true
			vim.o.timeoutlen = 300
		end,
		opts = {},
	},
	{
		"neovim/nvim-lspconfig",
	},
	{
		"israiloff/darcula-java",
		dependencies = "rktjmp/lush.nvim",
	},
	{
		"github/copilot.vim",
	},
	{
		"dawsers/telescope-file-history.nvim",
	},
	{
		"Pocco81/auto-save.nvim",
	},
	{
		"folke/todo-comments.nvim",
		opts = {},
	},
	{
		"nvim-telescope/telescope.nvim",
	},
	{
		"nvimtools/none-ls.nvim",
	},
	{
		"hrsh7th/nvim-cmp",
		dependencies = {
			"hrsh7th/cmp-nvim-lsp",
			"hrsh7th/cmp-buffer",
			"hrsh7th/cmp-path",
			"hrsh7th/cmp-cmdline",
			"L3MON4D3/LuaSnip",
			"saadparwaiz1/cmp_luasnip",
		},
		opts = function(_, opts)
			opts.sources = opts.sources or {}
			table.insert(opts.sources, {
				name = "lazydev",
				group_index = 0,
			})
		end,
	},
	{
		"williamboman/mason.nvim",
	},
	{
		"williamboman/mason-lspconfig.nvim",
	},
	{
		"mhartington/formatter.nvim",
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
	{
		"nvim-tree/nvim-tree.lua",
		version = "*",
		lazy = false,
		dependencies = {
			"nvim-tree/nvim-web-devicons",
		},
	},
	{
		"lewis6991/gitsigns.nvim",
	},
	{
		"tamago324/lir.nvim",
	},
	{
		"akinsho/bufferline.nvim",
		version = "*",
	},
	{
		"kevinhwang91/nvim-ufo",
		dependencies = "kevinhwang91/promise-async",
	},
	{
		"nvim-lualine/lualine.nvim",
	},
	{
		"archibate/lualine-time",
	},
	{
		"xiyaowong/transparent.nvim",
	},
	{
		"lukas-reineke/indent-blankline.nvim",
		main = "ibl",
		opts = {},
	},
}
