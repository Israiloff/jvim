-- Live preview for Markdown, AsciiDoc, HTML and SVG.
--
-- This replaced `iamcco/markdown-preview.nvim`, which had not been touched
-- since October 2023 and could not do two things that matter when reading
-- documentation: show more than one document at a time, and follow a link from
-- one document to another.
--
-- Neither was a rendering limit; both followed from how that plugin was built.
-- A page there was `/page/<buffer number>` and its contents were pushed over a
-- socket from the buffer, so a document that was not open had no page at all,
-- and the server had no route that served a file by path. This one is an
-- ordinary static server over the working directory: every file is reachable at
-- its own path and converted on the way out, so a relative link is just a link.
local livepreview = require("livepreview")

local SUPPORTED = { "markdown", "asciidoc", "html", "svg" }

livepreview.setup({
	address = "127.0.0.1",
	-- The port the previous plugin used, so a bookmark or a firewall rule that
	-- pointed at the preview still does.
	port = 33235,
	-- `false` roots the server at the working directory rather than at the
	-- folder of the file being previewed. That is what makes a link to
	-- `../other/doc.md` resolve: the whole project is reachable, not one folder.
	dynamic_root = false,
	sync_scroll = true,
	picker = "telescope",
	-- Not a browser — the shell's no-op, run instead of one.
	--
	-- The plugin always opens the URL it prints, and there is no setting that
	-- says "don't". The previous configuration deliberately printed the address
	-- and left the opening to you, so that is preserved here by handing the
	-- opener a command that does nothing.
	browser = "true",
})

-- The previous plugin started itself when a Markdown buffer appeared, and that
-- is worth keeping: the address shows up without asking for it. One server
-- covers the whole working directory now, so this only ever fires once.
local group = vim.api.nvim_create_augroup("JvimLivePreview", { clear = true })

local function start_once()
	if livepreview.is_running() then
		return
	end

	pcall(vim.cmd, "LivePreview start")
end

vim.api.nvim_create_autocmd("FileType", {
	group = group,
	pattern = SUPPORTED,
	callback = start_once,
})

-- The `FileType` event that loaded this plugin has already fired by the time
-- the autocommand above exists, so the buffer that triggered it would be the
-- one buffer that never started a server.
if vim.tbl_contains(SUPPORTED, vim.bo.filetype) then
	vim.schedule(start_once)
end
