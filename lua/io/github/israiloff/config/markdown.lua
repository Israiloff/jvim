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

local HOST = "127.0.0.1"
local PORT = 33235

livepreview.setup({
	address = HOST,
	-- The port the previous plugin used, so a bookmark or a firewall rule that
	-- pointed at the preview still does.
	port = PORT,
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

---The address this buffer is served at, or `nil` when it is outside the root.
---
---Built here rather than read from the plugin, which prints it once with
---`print` and is overwritten by the next message that comes along — and the
---next message, when a language server is starting, is never far away.
---@param bufnr integer
---@return string|nil
local function preview_url(bufnr)
	local path = vim.api.nvim_buf_get_name(bufnr)

	if path == "" then
		return nil
	end

	local relative = require("livepreview.utils").get_relative_path(path, vim.fs.normalize(vim.uv.cwd() or ""))

	if not relative then
		return nil
	end

	return ("http://%s:%d/%s"):format(HOST, PORT, vim.uri_encode(relative))
end

-- The previous plugin started itself when a Markdown buffer appeared and echoed
-- the address, and both are worth keeping. Nothing opens the page for you —
-- inside a container there is no browser to open it with — so the address is
-- the whole interface, and it goes through `vim.notify`, which puts it in the
-- activity panel and keeps it in `:JvimNotifyLog` rather than on a message line
-- that the next redraw takes away.
--
-- One server covers the whole working directory, so it is started once; the
-- address is reported for every document, because every document has its own.
local group = vim.api.nvim_create_augroup("JvimLivePreview", { clear = true })

---The directory the running server is serving, or `nil` when none is running.
local function served_root()
	local server = livepreview.serverObj
	return server and server.webroot and vim.fs.normalize(server.webroot) or nil
end

local function start_once()
	local root = vim.fs.normalize(vim.uv.cwd() or "")
	local serving = served_root()

	-- The server reads the working directory once, when it starts, and never
	-- looks again — while `is_running` stays true for the rest of the session.
	-- Open a second project and its `README.md` was served out of the first
	-- one's directory: the right path against the wrong root, so the address
	-- answered with a document from the project you had left.
	if serving and serving ~= root then
		pcall(vim.cmd, "LivePreview close")
	end

	if not livepreview.is_running() then
		pcall(vim.cmd, "LivePreview start")
	end

	local url = preview_url(vim.api.nvim_get_current_buf())

	if url then
		vim.notify(url, vim.log.levels.INFO, { title = "Live preview" })
	end
end

vim.api.nvim_create_autocmd("FileType", {
	group = group,
	pattern = SUPPORTED,
	callback = function()
		vim.schedule(start_once)
	end,
})
