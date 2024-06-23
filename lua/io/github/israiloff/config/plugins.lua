return {
    {
        "nvim-treesitter/nvim-treesitter",
        run = ":TSUpdate"
    },
    {
        "nvim-lua/plenary.nvim"
    },
    {
        "folke/which-key.nvim",
        event = "VeryLazy",
        init = function()
                    vim.o.timeout = true
                    vim.o.timeoutlen = 300
                end,
        opts = { }
    },
    {
        "mfussenegger/nvim-jdtls",
    },
    {
        "israiloff/darcula-java",
        dependencies = "rktjmp/lush.nvim"
    },
    {
        "petertriho/nvim-scrollbar",
    },
    {
        "danymat/neogen",
        dependencies = "nvim-treesitter/nvim-treesitter",
    },
    {
        "jackMort/ChatGPT.nvim",
        dependencies = {
            "MunifTanjim/nui.nvim",
            "folke/trouble.nvim",
            "nvim-telescope/telescope.nvim"
        }
    },
    {
        "github/copilot.vim"
    },
    {
        "dawsers/telescope-file-history.nvim"
    },
    {
        "olimorris/persisted.nvim",
        lazy = false,
        config = true,
    },
    {
        "Pocco81/auto-save.nvim"
    },
    {
        "archibate/lualine-time"
    },
    {
        "iamcco/markdown-preview.nvim",
        cmd = { "MarkdownPreviewToggle", "MarkdownPreview", "MarkdownPreviewStop" },
        ft = { "markdown" },
        build = function()
            vim.fn["mkdp#util#install"]()
        end,
    },
    {
        "folke/todo-comments.nvim",
        opts = {}
    },
    {
        "nvim-telescope/telescope.nvim",
    },
    {
        "neovim/nvim-lspconfig"
    },
    {
        "nvimtools/none-ls.nvim",
    },
    {
    "hrsh7th/nvim-cmp",
    requires = {
      "hrsh7th/cmp-nvim-lsp",
      "hrsh7th/cmp-buffer",
      "hrsh7th/cmp-path",
      "hrsh7th/cmp-cmdline",
      "L3MON4D3/LuaSnip",
      "saadparwaiz1/cmp_luasnip"
    },
    },
    {
        "williamboman/mason.nvim",
    },
    {
        "williamboman/mason-lspconfig.nvim",
    },
}
