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
        icons.ui.FindFile .. " Find Files",
    },
    u = {
        "<cmd>so<cr>",
        icons.ui.Refresh .. " Update configs",
    },
    c = {
        "<cmd>bd<cr>",
        icons.ui.Close .. " Close buffer",
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
        name = icons.diagnostics.Hint .. " Code Actions",
        d = { "<cmd>Telescope diagnostics bufnr=0 theme=get_ivy<cr>", "Buffer Diagnostics" },
        w = { "<cmd>Telescope diagnostics<cr>", "Diagnostics" },
        i = { "<cmd>LspInfo<cr>", "Info" },
        j = { "<cmd>lua vim.diagnostic.goto_next()<cr>", "Next Diagnostic" },
        k = { "<cmd>lua vim.diagnostic.goto_prev()<cr>", "Prev Diagnostic" },
        r = { "<cmd>lua vim.lsp.buf.rename()<cr>", "Rename" },
    },
    F = {
        name = icons.kind.File .. " File",
        h = {
            "<cmd>Telescope file_history history<CR>",
            icons.file.History .. " View the file’s history",
        },
        l = {
            "<cmd>Telescope file_history log<CR>",
            icons.file.Log .. " View the file’s history incrementally",
        },
        f = {
            "<cmd>Telescope file_history files<CR>",
            icons.file.Files .. " View every file in the repo",
        },
    },
    n = {
        name = icons.ui.Notification .. " Notifications",
        l = { "<cmd>mess<CR>", "Show notification log" },
    },
    s = {
        name = icons.ui.Search .. " Search",
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
        name = icons.git.Git .. " Git",
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
        icons.ui.CommentCode .. " Comment current line",
    },
    P = {
        name = icons.kind.Module .. " Plugins",
        i = { "<cmd>Lazy install<cr>", "Install" },
        s = { "<cmd>Lazy sync<cr>", "Sync" },
        S = { "<cmd>Lazy clear<cr>", "Status" },
        c = { "<cmd>Lazy clean<cr>", "Clean" },
        u = { "<cmd>Lazy update<cr>", "Update" },
        p = { "<cmd>Lazy profile<cr>", "Profile" },
        l = { "<cmd>Lazy log<cr>", "Log" },
        d = { "<cmd>Lazy debug<cr>", "Debug" },
    },
    p = {
        "<cmd>Telescope projects<cr>",
        icons.ui.Project .. " Projects",
    },
    r = {
        "<cmd>Telescope oldfiles<cr>",
        icons.ui.Files .. " Recent Files",
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
    a = {
        name = icons.misc.Robot .. " Open AI",
        c = { "<cmd>ChatGPT<CR>", icons.gpt.Chat .. " ChatGPT" },
        e = { "<cmd>ChatGPTEditWithInstruction<CR>", icons.text.Edit .. " Edit with instruction" },
        g = { "<cmd>ChatGPTRun grammar_correction<CR>", icons.text.Correct .. " Grammar Correction" },
        t = { "<cmd>ChatGPTRun translate<CR>", icons.gpt.Translate .. " Translate" },
        k = { "<cmd>ChatGPTRun keywords<CR>", icons.text.Keyword .. " Keywords" },
        d = { "<cmd>ChatGPTRun docstring<CR>", icons.gpt.Docstring .. " Docstring" },
        a = { "<cmd>ChatGPTRun add_tests<CR>", icons.code.Tests .. " Add Tests" },
        o = { "<cmd>ChatGPTRun optimize_code<CR>", icons.code.OptimizeCode .. " Optimize Code" },
        s = { "<cmd>ChatGPTRun summarize<CR>", icons.gpt.Chat .. " Summarize" },
        f = { "<cmd>ChatGPTRun fix_bugs<CR>", icons.code.BugFix .. " Fix Bugs" },
        x = { "<cmd>ChatGPTRun explain_code<CR>", icons.gpt.ExplainCode .. " Explain Code" },
        r = { "<cmd>ChatGPTRun roxygen_edit<CR>", icons.gpt.Edit .. " Roxygen Edit" },
        l = { "<cmd>ChatGPTRun code_readability_analysis<CR>", icons.gpt.Readability .. " Code Readability Analysis" },
    },
    A = {
        name = icons.Copilot.Logo .. " Copilot",
        p = { "<cmd>Copilot panel<CR>", icons.Copilot.Panel .. " Open Copilot Panel" },
    },
    l = {
        name = icons.diagnostics.Hint .. " Code Actions",
        a = { "<cmd>lua vim.lsp.buf.code_action()<cr>", "Action" },
        f = { "<cmd>CmFormat<cr>", "Format" },
    },
}, {
    prefix = "<leader>",
    mode = { "n", "v" },
})
