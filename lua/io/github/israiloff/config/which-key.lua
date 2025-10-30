require("io.github.israiloff.config.buffer-ops")
local which_key = require("which-key")
local icons = require("io.github.israiloff.config.icons")

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
            z = false,   -- bindings for folds, spelling and others prefixed with z
            g = false,   -- bindings for prefixed with g
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
        breadcrumb = icons.ui.DoubleChevronRight,  -- symbol used in the command line area that shows your active key combo
        separator = icons.ui.ArrowRightSimple,     -- symbol used between a key and it's label
        group = icons.ui.TriangleShortArrowRight .. " ", -- symbol prepended to a group
    },
    popup_mappings = {
        scroll_down = "<c-d>", -- binding to scroll down inside the popup
        scroll_up = "<c-u>", -- binding to scroll up inside the popup
    },
    window = {
        border = "single",  -- none, single, double, shadow
        position = "bottom", -- bottom, top
        margin = { 1, 0, 1, 0 }, -- extra window margin [top, right, bottom, left]. When between 0 and 1, will be treated as a percentage of the screen size.
        padding = { 1, 2, 1, 2 }, -- extra window padding [top, right, bottom, left]
        winblend = 0,       -- value between 0-100 0 for fully opaque and 100 for fully transparent
        zindex = 1000,      -- positive value to position WhichKey above other floating windows.
    },
    layout = {
        height = { min = 4, max = 25 },                                            -- min and max height of the columns
        width = { min = 20, max = 50 },                                            -- min and max width of the columns
        spacing = 3,                                                               -- spacing between columns
        align = "left",                                                            -- align columns left, center or right
    },
    ignore_missing = false,                                                        -- enable this to hide mappings for which you didn't specify a label
    hidden = { "<silent>", "<cmd>", "<Cmd>", "<CR>", "^:", "^ ", "^call ", "^lua " }, -- hide mapping boilerplate
    show_help = true,                                                              -- show a help message in the command line for using WhichKey
    show_keys = true,                                                              -- show the currently pressed key and its label as a message in the command line
    triggers = "auto",                                                             -- automatically setup triggers
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
    f = {
        "<cmd>Telescope find_files<cr>",
        icons.ui.FindFile .. " Find files",
    },
    u = {
        "<cmd>so<cr>",
        icons.ui.Refresh .. " Update configs",
    },
    b = {
        name = icons.kind.Buffer .. " Buffer",
        c = {
            "<cmd>:CmCloseCurrentBuffer<cr>",
            icons.ui.Close .. " Close current buffer",
        },
        C = {
            "<cmd>:CmCloseCurrentBuffer!<cr>",
            icons.ui.CloseForce .. " Force close current buffer",
        },
        o = {
            "<cmd>:CmCloseOtherBuffers<cr>",
            icons.ui.CloseOthers .. " Close other buffers",
        },
        O = {
            "<cmd>:CmCloseOtherBuffers!<cr>",
            icons.ui.CloseOthersForce .. " Force close other buffers",
        },
    },
    q = {
        "<cmd>confirm q<CR>",
        icons.ui.SignOut .. " Quit",
    },
    e = {
        "<cmd>NvimTreeToggle<CR>",
        icons.ui.EmptyFolderOpen .. " Explorer",
    },
    l = {
        name = icons.diagnostics.Hint .. " Code actions",
        d = {
            "<cmd>Telescope diagnostics bufnr=0 theme=get_ivy<cr>",
            icons.diagnostics.Scan .. " Document diagnostics",
        },
        w = { "<cmd>Telescope diagnostics<cr>", icons.diagnostics.ScanBold .. " Workspace diagnostics" },
        i = { "<cmd>LspInfo<cr>", icons.diagnostics.Information .. " LSP client information" },
        j = { "<cmd>lua vim.diagnostic.goto_next()<cr>", icons.ui.ArrowCircleDown .. " Next diagnostics" },
        k = { "<cmd>lua vim.diagnostic.goto_prev()<cr>", icons.ui.ArrowCircleUp .. " Previous diagnostics" },
        r = { "<cmd>lua vim.lsp.buf.rename()<cr>", icons.lsp.rename .. " Rename" },
    },
    F = {
        name = icons.kind.File .. " File",
        h = {
            "<cmd>Telescope file_history history<CR>",
            icons.file.History .. " History",
        },
        l = {
            "<cmd>Telescope file_history log<CR>",
            icons.file.Log .. " Change log",
        },
        f = {
            "<cmd>Telescope file_history files<CR>",
            icons.file.Files .. " Browse history files",
        },
    },
    n = {
        name = icons.ui.Notification .. " Notifications",
        l = { "<cmd>mess<CR>", icons.ui.ListUnordered .. " Log" },
    },
    s = {
        name = icons.ui.Search .. " Search",
        c = { "<cmd>Telescope colorscheme<cr>", icons.kind.Color .. " Colorscheme" },
        f = { "<cmd>Telescope find_files<cr>", icons.ui.Search .. " Find file" },
        h = { "<cmd>Telescope help_tags<cr>", icons.ui.Help .. " Find help" },
        H = { "<cmd>Telescope highlights<cr>", icons.ui.SearchList .. " Find highlight groups" },
        M = { "<cmd>Telescope man_pages<cr>", icons.os.Linux .. " Man pages" },
        r = { "<cmd>Telescope oldfiles<cr>", icons.kind.File .. " Open recent file" },
        R = { "<cmd>Telescope registers<cr>", icons.ui.Registers .. " Registers" },
        t = { "<cmd>Telescope live_grep<cr>", icons.kind.Text .. " Text" },
        k = { "<cmd>Telescope keymaps<cr>", icons.ui.Keymap .. " Keymaps" },
        C = { "<cmd>Telescope commands<cr>", icons.ui.List .. " Commands" },
        l = { "<cmd>Telescope resume<cr>", icons.ui.Resume .. " Resume last search" },
        p = {
            "<cmd>lua require('telescope.builtin').colorscheme({enable_preview = true})<cr>",
            icons.kind.ColorBold .. " Colorscheme with preview",
        },
    },
    g = {
        name = icons.git.Git .. " Git",
        j = {
            "<cmd>lua require 'gitsigns'.nav_hunk('next', {navigation_message = false})<cr>",
            icons.git.LineModified .. " Hunk next",
        },
        k = {
            "<cmd>lua require 'gitsigns'.nav_hunk('prev', {navigation_message = false})<cr>",
            icons.git.LineModifiedPreview .. " Hunk previous",
        },
        l = { "<cmd>lua require 'gitsigns'.blame_line()<cr>", icons.git.Blame .. " Blame line" },
        L = { "<cmd>lua require 'gitsigns'.blame_line({full=true})<cr>", icons.git.BlameFull .. " Blame full" },
        p = { "<cmd>lua require 'gitsigns'.preview_hunk()<cr>", icons.git.HunkPreview .. " Hunk preview" },
        r = { "<cmd>lua require 'gitsigns'.reset_hunk()<cr>", icons.git.HunkReset .. " Hunk reset" },
        R = { "<cmd>lua require 'gitsigns'.reset_buffer()<cr>", icons.git.BufferReset .. " Buffer reset" },
        s = { "<cmd>lua require 'gitsigns'.stage_hunk()<cr>", icons.git.HunkStage .. " Hunk stage" },
        u = { "<cmd>lua require 'gitsigns'.undo_stage_hunk()<cr>", icons.git.HunkUnstage .. " Hunk undo stage" },
        o = { "<cmd>Telescope git_status<cr>", icons.git.FileUnstaged .. " Open changed file" },
        b = { "<cmd>Telescope git_branches<cr>", icons.git.Branch .. " Checkout branch" },
        c = { "<cmd>Telescope git_commits<cr>", icons.git.Commits .. " Checkout commit" },
        C = { "<cmd>Telescope git_bcommits<cr>", icons.git.Commit .. " Checkout commit of current file" },
        d = { "<cmd>Gitsigns diffthis HEAD<cr>", icons.git.Diff .. " Git diff" },
    },
    ["/"] = {
        "<Plug>(comment_toggle_linewise_current)",
        icons.ui.CommentCode .. " Comment current line",
    },
    P = {
        name = icons.kind.Module .. " Plugins",
        i = { "<cmd>Lazy install<cr>", icons.plugin.Install .. " Install" },
        s = { "<cmd>Lazy sync<cr>", icons.plugin.Sync .. " Sync" },
        S = { "<cmd>Lazy clear<cr>", icons.plugin.Status .. " Status" },
        c = { "<cmd>Lazy clean<cr>", icons.plugin.Clean .. " Clean" },
        u = { "<cmd>Lazy update<cr>", icons.plugin.Update .. " Update" },
        p = { "<cmd>Lazy profile<cr>", icons.plugin.Profile .. " Profile" },
        l = { "<cmd>Lazy log<cr>", icons.ui.List .. " Log" },
        d = { "<cmd>Lazy debug<cr>", icons.plugin.Debug .. " Debug" },
    },
    p = {
        "<cmd>Telescope projects<cr>",
        icons.ui.Project .. " Projects",
    },
    r = {
        "<cmd>Telescope oldfiles<cr>",
        icons.ui.Files .. " Recent files",
    },
    m = {
        "<cmd>Mason<cr>",
        icons.ui.Mason .. " Mason",
    },
}, {
    prefix = "<leader>",
    mode = "n",
})

which_key.register({
    ["/"] = {
        "<Plug>(comment_toggle_linewise_visual)",
        icons.ui.CommentCode .. " Comment",
    },
}, {
    prefix = "<leader>",
    mode = { "v" },
})

which_key.register({
    A = {
        name = icons.copilot.Logo .. " Copilot",
        p = { "<cmd>Copilot panel<CR>", icons.copilot.Panel .. " Panel" },
    },
    l = {
        name = icons.diagnostics.Hint .. " Code actions",
        a = { "<cmd>lua vim.lsp.buf.code_action()<cr>", icons.code.Refactor .. " Action" },
        f = { "<cmd>CmFormat<cr>", icons.code.Format .. " Format" },
    },
}, {
    prefix = "<leader>",
    mode = { "n", "v" },
})
