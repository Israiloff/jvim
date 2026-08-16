require("io.github.israiloff.config.buffer-ops")
local which_key = require("which-key")
local ai = require("io.github.israiloff.config.ai")
local icons = require("io.github.israiloff.config.icons")
local toggles = require("io.github.israiloff.config.toggles")

which_key.setup({
	-- Bottom-anchored list, the same layout v2 produced with `window.position`.
	preset = "classic",
	-- v2 relied on 'timeoutlen'; v3 has its own popup delay, set to match.
	delay = 300,
	plugins = {
		marks = true, -- shows a list of your marks on ' and `
		registers = true, -- shows your registers on " in NORMAL or <C-r> in INSERT mode
		spelling = {
			enabled = false, -- enabling this will show WhichKey when pressing z= to select spelling suggestions
			suggestions = 20, -- how many suggestions should be shown in the list?
		},
		-- The presets plugin adds help for a bunch of default Neovim keybindings.
		-- No actual key bindings are created.
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
	icons = {
		breadcrumb = icons.ui.DoubleChevronRight, -- symbol used in the command line area that shows your active key combo
		separator = icons.ui.ArrowRightSimple, -- symbol used between a key and it's label
		group = icons.ui.TriangleShortArrowRight .. " ", -- symbol prepended to a group
		-- Every mapping below carries its own glyph at the start of `desc`, so
		-- which-key's built-in icon rules would render a second, duplicate icon.
		mappings = false,
	},
	keys = {
		scroll_down = "<c-d>", -- binding to scroll down inside the popup
		scroll_up = "<c-u>", -- binding to scroll up inside the popup
	},
	win = {
		border = "single",
		padding = { 1, 2 }, -- extra window padding [top/bottom, right/left]
		zindex = 1000, -- positive value to position WhichKey above other floating windows
		wo = {
			winblend = 0, -- value between 0-100, 0 for fully opaque and 100 for fully transparent
		},
	},
	layout = {
		width = { min = 20 }, -- min width of the columns
		spacing = 3, -- spacing between columns
	},
	show_help = true, -- show a help message in the command line for using WhichKey
	show_keys = true, -- show the currently pressed key and its label as a message in the command line
	-- disable WhichKey for certain buffer types and file types
	disable = {
		bt = {},
		ft = {},
	},
})

-- ---------------------------------------------------------------------------
-- grug-far helpers
--
-- The prefills have to be resolved when the mapping fires, not when the spec is
-- built, so each of these returns a closure.
-- ---------------------------------------------------------------------------

---@param scope "file"|"global" limit the search to the current file or search everywhere
---@param replace boolean open in replace mode
local function grug_word(scope, replace)
	return function()
		local prefills = { search = vim.fn.expand("<cword>") }

		if scope == "file" then
			prefills.paths = vim.fn.expand("%")
		end

		require("grug-far").open({
			prefills = prefills,
			transient = true,
			replace = replace and "" or nil,
		})
	end
end

---@param scope "file"|"global"
local function grug_selection(scope)
	return function()
		require("grug-far").with_visual_selection({
			prefills = scope == "file" and { paths = vim.fn.expand("%") } or nil,
			transient = true,
		})
	end
end

local function grug_ui()
	require("grug-far").open({ transient = true })
end

-- ---------------------------------------------------------------------------
-- Normal mode
-- ---------------------------------------------------------------------------
which_key.add({
	{ "<leader>/", "<Plug>(comment_toggle_linewise_current)", desc = icons.ui.CommentCode .. " Comment current line" },
	{ "<leader>e", "<cmd>NvimTreeToggle<CR>", desc = icons.ui.EmptyFolderOpen .. " Explorer" },
	{ "<leader>f", "<cmd>Telescope find_files<cr>", desc = icons.ui.FindFile .. " Find file" },
	{ "<leader>m", "<cmd>Mason<cr>", desc = icons.ui.Mason .. " Mason" },
	{ "<leader>p", "<cmd>Telescope projects<cr>", desc = icons.ui.Project .. " Projects" },
	{ "<leader>q", "<cmd>confirm q<CR>", desc = icons.ui.SignOut .. " Quit" },
	{ "<leader>r", "<cmd>Telescope oldfiles<cr>", desc = icons.ui.Files .. " Recent files" },
	{ "<leader>u", "<cmd>so<cr>", desc = icons.ui.Refresh .. " Update configs" },

	{ "<leader>b", group = icons.kind.Buffer .. " Buffer" },
	{ "<leader>bc", "<cmd>CmCloseCurrentBuffer<cr>", desc = icons.ui.Close .. " Close current buffer" },
	{ "<leader>bC", "<cmd>CmCloseCurrentBuffer!<cr>", desc = icons.ui.CloseForce .. " Force close current buffer" },
	{ "<leader>bo", "<cmd>CmCloseOtherBuffers<cr>", desc = icons.ui.CloseOthers .. " Close other buffers" },
	{ "<leader>bO", "<cmd>CmCloseOtherBuffers!<cr>", desc = icons.ui.CloseOthersForce .. " Force close other buffers" },

	{ "<leader>F", group = icons.kind.File .. " File" },
	{ "<leader>Ff", "<cmd>Telescope file_history files<CR>", desc = icons.file.Files .. " Browse history files" },
	{ "<leader>Fh", "<cmd>Telescope file_history history<CR>", desc = icons.file.History .. " History" },
	{ "<leader>Fl", "<cmd>Telescope file_history log<CR>", desc = icons.file.Log .. " Change log" },

	{ "<leader>g", group = icons.git.Git .. " Git" },
	{ "<leader>gb", "<cmd>Telescope git_branches<cr>", desc = icons.git.Branch .. " Checkout branch" },
	{ "<leader>gc", "<cmd>Telescope git_commits<cr>", desc = icons.git.Commits .. " Checkout commit" },
	{ "<leader>gC", "<cmd>Telescope git_bcommits<cr>", desc = icons.git.Commit .. " Checkout commit of current file" },
	{ "<leader>gd", "<cmd>Gitsigns diffthis HEAD<cr>", desc = icons.git.Diff .. " Git diff" },
	{
		"<leader>gj",
		"<cmd>lua require 'gitsigns'.nav_hunk('next', {navigation_message = false})<cr>",
		desc = icons.git.LineModified .. " Hunk next",
	},
	{
		"<leader>gk",
		"<cmd>lua require 'gitsigns'.nav_hunk('prev', {navigation_message = false})<cr>",
		desc = icons.git.LineModifiedPreview .. " Hunk previous",
	},
	{ "<leader>gl", "<cmd>lua require 'gitsigns'.blame_line()<cr>", desc = icons.git.Blame .. " Blame line" },
	{
		"<leader>gL",
		"<cmd>lua require 'gitsigns'.blame_line({full=true})<cr>",
		desc = icons.git.BlameFull .. " Blame full",
	},
	{ "<leader>go", "<cmd>Telescope git_status<cr>", desc = icons.git.FileUnstaged .. " Open changed file" },
	{ "<leader>gp", "<cmd>lua require 'gitsigns'.preview_hunk()<cr>", desc = icons.git.HunkPreview .. " Hunk preview" },
	{ "<leader>gr", "<cmd>lua require 'gitsigns'.reset_hunk()<cr>", desc = icons.git.HunkReset .. " Hunk reset" },
	{ "<leader>gR", "<cmd>lua require 'gitsigns'.reset_buffer()<cr>", desc = icons.git.BufferReset .. " Buffer reset" },
	{ "<leader>gs", "<cmd>lua require 'gitsigns'.stage_hunk()<cr>", desc = icons.git.HunkStage .. " Hunk stage" },
	{
		"<leader>gu",
		"<cmd>lua require 'gitsigns'.undo_stage_hunk()<cr>",
		desc = icons.git.HunkUnstage .. " Hunk undo stage",
	},

	{ "<leader>l", group = icons.diagnostics.Hint .. " Code actions" },
	{
		"<leader>ld",
		"<cmd>Telescope diagnostics bufnr=0 theme=get_ivy<cr>",
		desc = icons.diagnostics.Scan .. " Document diagnostics",
	},
	{ "<leader>li", "<cmd>LspInfo<cr>", desc = icons.diagnostics.Information .. " LSP client information" },
	{
		"<leader>lj",
		"<cmd>lua vim.diagnostic.jump({ count = 1, float = true })<cr>",
		desc = icons.ui.ArrowCircleDown .. " Next diagnostics",
	},
	{
		"<leader>lk",
		"<cmd>lua vim.diagnostic.jump({ count = -1, float = true })<cr>",
		desc = icons.ui.ArrowCircleUp .. " Previous diagnostics",
	},
	{ "<leader>lr", "<cmd>lua vim.lsp.buf.rename()<cr>", desc = icons.lsp.rename .. " Rename" },
	{ "<leader>lw", "<cmd>Telescope diagnostics<cr>", desc = icons.diagnostics.ScanBold .. " Workspace diagnostics" },

	{ "<leader>n", group = icons.ui.Notification .. " Notifications" },
	-- `:messages` no longer carries notifications: they are rendered in the
	-- activity panel and retained separately, so the two logs are listed apart.
	{ "<leader>nl", "<cmd>JvimNotifyLog<CR>", desc = icons.ui.ListUnordered .. " Log" },
	{ "<leader>nc", "<cmd>JvimNotifyClear<CR>", desc = icons.ui.Close .. " Clear log" },
	{ "<leader>nd", "<cmd>JvimActivityDismiss<CR>", desc = icons.ui.CloseOthers .. " Dismiss panel" },
	{ "<leader>nm", "<cmd>mess<CR>", desc = icons.ui.List .. " Vim messages" },

	-- The logger is what feeds most of the notifications, so its switches sit
	-- with them rather than in the UI menu.
	{ "<leader>nL", group = icons.ui.ListUnordered .. " Logger" },
	{ "<leader>nLe", toggles.action("logger"), desc = toggles.desc("logger") },
	{ "<leader>nLd", toggles.action("logger_debug"), desc = toggles.desc("logger_debug") },
	{ "<leader>nLi", toggles.action("logger_info"), desc = toggles.desc("logger_info") },
	{ "<leader>nLw", toggles.action("logger_warn"), desc = toggles.desc("logger_warn") },
	{ "<leader>nLr", toggles.action("logger_error"), desc = toggles.desc("logger_error") },

	-- Everything under `gui.` in properties.lua.
	{ "<leader>U", group = icons.ui.Settings .. " UI" },
	{ "<leader>Ut", toggles.action("transparent"), desc = toggles.desc("transparent") },
	{ "<leader>Ua", toggles.action("activity"), desc = toggles.desc("activity") },
	{ "<leader>Up", toggles.action("activity_lazy"), desc = toggles.desc("activity_lazy") },
	{ "<leader>Ul", toggles.action("activity_lsp"), desc = toggles.desc("activity_lsp") },
	{ "<leader>Un", toggles.action("activity_notify"), desc = toggles.desc("activity_notify") },
	{ "<leader>Us", "<cmd>JvimToggleStatus<CR>", desc = icons.ui.List .. " All switches" },

	{ "<leader>P", group = icons.kind.Module .. " Plugins" },
	{ "<leader>Pc", "<cmd>Lazy clean<cr>", desc = icons.plugin.Clean .. " Clean" },
	{ "<leader>Pd", "<cmd>Lazy debug<cr>", desc = icons.plugin.Debug .. " Debug" },
	{ "<leader>Pi", "<cmd>Lazy install<cr>", desc = icons.plugin.Install .. " Install" },
	{ "<leader>Pl", "<cmd>Lazy log<cr>", desc = icons.ui.List .. " Log" },
	{ "<leader>Pp", "<cmd>Lazy profile<cr>", desc = icons.plugin.Profile .. " Profile" },
	{ "<leader>Ps", "<cmd>Lazy sync<cr>", desc = icons.plugin.Sync .. " Sync" },
	{ "<leader>PS", "<cmd>Lazy clear<cr>", desc = icons.plugin.Status .. " Status" },
	{ "<leader>Pu", "<cmd>Lazy update<cr>", desc = icons.plugin.Update .. " Update" },

	{ "<leader>s", group = icons.ui.Search .. " Search" },
	{ "<leader>sc", "<cmd>Telescope colorscheme<cr>", desc = icons.kind.Color .. " Colorscheme" },
	{ "<leader>sC", "<cmd>Telescope commands<cr>", desc = icons.ui.List .. " Commands" },
	{ "<leader>sf", "<cmd>Telescope find_files<cr>", desc = icons.ui.Search .. " Find file" },
	{ "<leader>sh", "<cmd>Telescope help_tags<cr>", desc = icons.ui.Help .. " Find help" },
	{ "<leader>sH", "<cmd>Telescope highlights<cr>", desc = icons.ui.SearchList .. " Find highlight groups" },
	{ "<leader>sk", "<cmd>Telescope keymaps<cr>", desc = icons.ui.Keymap .. " Keymaps" },
	{ "<leader>sl", "<cmd>Telescope resume<cr>", desc = icons.ui.Resume .. " Resume last search" },
	{ "<leader>sM", "<cmd>Telescope man_pages<cr>", desc = icons.os.Linux .. " Man pages" },
	{
		"<leader>sp",
		"<cmd>lua require('telescope.builtin').colorscheme({enable_preview = true})<cr>",
		desc = icons.kind.ColorBold .. " Colorscheme with preview",
	},
	{ "<leader>st", "<cmd>Telescope live_grep<cr>", desc = icons.kind.Text .. " Text" },
	{ "<leader>su", grug_ui, desc = icons.search.Gui .. " Open grug UI" },
	{ "<leader>s]", "<cmd>Telescope registers<cr>", desc = icons.ui.Registers .. " Registers" },
})

-- ---------------------------------------------------------------------------
-- grug-far search/replace, identical keys in normal and visual mode
-- ---------------------------------------------------------------------------
which_key.add({
	mode = { "n", "v" },
	{ "<leader>s", group = icons.ui.Search .. " Search" },
	{
		"<leader>sr",
		grug_word("file", true),
		desc = icons.search.ReplaceCurrent .. " Replace word under cursor in current file",
	},
	{ "<leader>sR", grug_word("global", true), desc = icons.search.ReplaceGlobal .. " Replace word under cursor" },
	{
		"<leader>sw",
		grug_word("file", false),
		desc = icons.search.SearchCurrent .. " Search word under cursor in current file",
	},
	{ "<leader>sW", grug_word("global", false), desc = icons.search.SearchGlobal .. " Search word under cursor" },
})

-- ---------------------------------------------------------------------------
-- Visual mode
-- ---------------------------------------------------------------------------
which_key.add({
	mode = "v",
	{ "<leader>/", "<Plug>(comment_toggle_linewise_visual)", desc = icons.ui.CommentCode .. " Comment" },
	{ "<leader>f", group = icons.ui.FindFile .. " Find/Replace" },
	{ "<leader>fs", grug_selection("file"), desc = "Search selection in current file" },
	{ "<leader>fS", grug_selection("global"), desc = "Search selection globally" },
})

-- ---------------------------------------------------------------------------
-- Shared between normal and visual mode
-- ---------------------------------------------------------------------------
which_key.add({
	mode = { "n", "v" },
	{ "<leader>l", group = icons.diagnostics.Hint .. " Code actions" },
	{ "<leader>la", "<cmd>lua vim.lsp.buf.code_action()<cr>", desc = icons.code.Refactor .. " Action" },
	{ "<leader>lf", "<cmd>CmFormat<cr>", desc = icons.code.Format .. " Format" },

	-- The group label reports the provider that is live in this session.
	{ "<leader>A", group = "AI [" .. ai.get_provider_label(ai.get_runtime_provider()) .. "]" },
	{
		"<leader>Ac",
		function()
			ai.select_provider(ai.providers.COPILOT)
		end,
		desc = "Use Copilot on next start",
	},
	{
		"<leader>Ad",
		function()
			ai.select_provider(ai.providers.NONE)
		end,
		desc = "Disable AI on next start",
	},
	{ "<leader>Ae", ai.edit_local_properties, desc = "Edit local properties" },
	{ "<leader>As", ai.show_status, desc = "Status" },
	{
		"<leader>At",
		function()
			ai.select_provider(ai.providers.TABBY)
		end,
		desc = "Use Tabby on next start",
	},
	-- v2 built this entry conditionally at load time; `cond` lets which-key
	-- re-evaluate it instead, so the entry follows the active provider.
	{
		"<leader>Ap",
		"<cmd>Copilot panel<CR>",
		desc = icons.copilot.Panel .. " Panel",
		cond = function()
			return ai.is(ai.providers.COPILOT)
		end,
	},
})
