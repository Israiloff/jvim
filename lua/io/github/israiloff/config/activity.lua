-- Bottom-right activity indicator.
--
-- Two sources feed the same widget:
--
--   * lazy.nvim plugin loads (`User LazyLoad`). The event fires *after* the plugin
--     finished loading and carries the elapsed time, so these are reported as
--     completed toasts (⚡ name 14.2ms cmd) rather than a fake spinner.
--
--   * LSP work-done progress (`LspProgress`). This one is genuinely in flight, so
--     it gets the animated spinner. It is the reason this module exists: jdtls
--     spends 20-30 seconds indexing a project without a single character of
--     feedback otherwise.
--
-- The window never takes focus and never enters the buffer list.
local M = {}

local properties = require("io.github.israiloff.config.properties")

local config = vim.tbl_deep_extend("force", {
	enabled = true,
	-- Report lazy.nvim plugin loads.
	lazy = true,
	-- Report LSP progress.
	lsp = true,
	-- How long a finished entry stays on screen, in milliseconds.
	linger_ms = 1200,
	-- Spinner tick, in milliseconds.
	interval_ms = 80,
	-- Widest the window is allowed to get, in columns. Shrinks on narrow terminals.
	max_width = 60,
	-- Most entries shown at once; older ones are dropped first.
	max_entries = 6,
}, (properties.gui and properties.gui.activity) or {})

local SPINNER = { "⠋", "⠙", "⠹", "⠸", "⠼", "⠴", "⠦", "⠧", "⠇", "⠏" }
local LAZY_ICON = "⚡"
local DONE_ICON = "✓"

local NS = vim.api.nvim_create_namespace("JvimActivity")

local state = {
	-- Ordered list of entries. Each is { key, icon_kind, name, detail, expires_at }.
	entries = {},
	buf = nil,
	win = nil,
	timer = nil,
	frame = 1,
	-- Column widths, held steady while the window stays open (see build_lines).
	sticky_name_width = nil,
	sticky_detail_width = nil,
	-- Plugin loads during startup are noise; `:Lazy profile` already reports them.
	-- Flipped on shortly after the UI settles.
	armed = false,
}

-- ---------------------------------------------------------------------------
-- Highlights
-- ---------------------------------------------------------------------------
local function apply_highlights()
	vim.api.nvim_set_hl(0, "JvimActivityIcon", { link = "DiagnosticInfo", default = true })
	vim.api.nvim_set_hl(0, "JvimActivityName", { link = "Normal", default = true })
	vim.api.nvim_set_hl(0, "JvimActivityDetail", { link = "Comment", default = true })
end

-- ---------------------------------------------------------------------------
-- Window
-- ---------------------------------------------------------------------------
local function ensure_buf()
	if state.buf and vim.api.nvim_buf_is_valid(state.buf) then
		return state.buf
	end

	state.buf = vim.api.nvim_create_buf(false, true)
	vim.bo[state.buf].bufhidden = "hide"
	vim.bo[state.buf].filetype = "jvim-activity"
	return state.buf
end

local function close_window()
	if state.win and vim.api.nvim_win_is_valid(state.win) then
		pcall(vim.api.nvim_win_close, state.win, true)
	end
	state.win = nil
	-- Column widths are sticky only for the lifetime of a window.
	state.sticky_name_width = nil
	state.sticky_detail_width = nil
end

local function truncate(text, width)
	if vim.fn.strdisplaywidth(text) <= width then
		return text
	end
	return vim.fn.strcharpart(text, 0, width - 1) .. "…"
end

---Build the display lines plus the highlight ranges for each of them.
---
---Laid out as a two-column table so the timings and percentages line up:
---
---    ⚡ telescope.nvim          14.2ms  cmd
---    ⠙ jdtls        Starting Java Language Server  27%
---
---Extmark columns are byte offsets while the layout is measured in display
---cells, so the two are tracked separately.
local function build_lines()
	local spinner = SPINNER[state.frame]

	-- Icons differ in cell width (⚡ is wide, braille frames are narrow), so the
	-- icon slot is padded to a fixed width to keep the name column aligned.
	local ICON_CELLS = 2
	-- " " + icon slot + " " + name + "  " + detail
	local CHROME = 1 + ICON_CELLS + 1 + 2

	local rows = {}
	for _, entry in ipairs(state.entries) do
		local icon = entry.icon_kind == "spinner" and spinner
			or (entry.icon_kind == "lazy" and LAZY_ICON or DONE_ICON)
		table.insert(rows, { icon = icon, name = entry.name, detail = entry.detail or "" })
	end

	-- Shrink rather than disappear on a narrow terminal.
	local max_width = math.min(config.max_width, math.max(vim.o.columns - 8, 24))

	-- The detail column may grow until the name column is down to MIN_NAME cells;
	-- the name column then takes whatever is left. Both are truncated to fit, so a
	-- line can never exceed max_width.
	local MIN_NAME = 14
	local detail_cap = math.max(max_width - CHROME - MIN_NAME, 8)
	local detail_width = 0
	for _, row in ipairs(rows) do
		row.detail = truncate(row.detail, detail_cap)
		detail_width = math.max(detail_width, vim.fn.strdisplaywidth(row.detail))
	end

	local name_budget = math.max(max_width - CHROME - detail_width, 8)
	local name_width = 0
	for _, row in ipairs(rows) do
		row.name = truncate(row.name, name_budget)
		name_width = math.max(name_width, vim.fn.strdisplaywidth(row.name))
	end

	-- Column widths only ever grow while the window is on screen. Without this the
	-- layout twitches on every tick as entries with different name lengths come
	-- and go, which is very visible during the jdtls startup burst.
	name_width = math.max(name_width, state.sticky_name_width or 0)
	detail_width = math.max(detail_width, state.sticky_detail_width or 0)
	state.sticky_name_width = name_width
	state.sticky_detail_width = detail_width

	local lines, marks = {}, {}

	for _, row in ipairs(rows) do
		local icon_pad = string.rep(" ", math.max(ICON_CELLS - vim.fn.strdisplaywidth(row.icon), 0))
		local prefix = " " .. row.icon .. icon_pad .. " "
		local name_start = #prefix
		local name_end = name_start + #row.name

		local line = prefix .. row.name
		local detail_start = nil

		if detail_width > 0 then
			-- Pad the name column, then right-align the detail column.
			local pad = name_width - vim.fn.strdisplaywidth(row.name)
			local gap = detail_width - vim.fn.strdisplaywidth(row.detail)
			line = line .. string.rep(" ", pad + 2 + gap)
			detail_start = #line
			line = line .. row.detail
		end

		table.insert(lines, line)
		table.insert(marks, {
			icon = { 1, name_start },
			name = { name_start, name_end },
			detail = (detail_start and row.detail ~= "") and { detail_start, #line } or nil,
		})
	end

	return lines, marks
end

local function render()
	if #state.entries == 0 then
		close_window()
		return
	end

	local lines, marks = build_lines()
	local width = 0
	for _, line in ipairs(lines) do
		width = math.max(width, vim.fn.strdisplaywidth(line))
	end
	width = math.min(width + 1, config.max_width)
	local height = #lines

	-- Not enough room to draw without fighting the editor for space.
	if vim.o.columns < width + 6 or vim.o.lines < height + 6 then
		close_window()
		return
	end

	local buf = ensure_buf()
	vim.bo[buf].modifiable = true
	vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)
	vim.bo[buf].modifiable = false

	vim.api.nvim_buf_clear_namespace(buf, NS, 0, -1)
	for i, mark in ipairs(marks) do
		local row = i - 1
		vim.api.nvim_buf_set_extmark(buf, NS, row, mark.icon[1], {
			end_col = mark.icon[2],
			hl_group = "JvimActivityIcon",
		})
		vim.api.nvim_buf_set_extmark(buf, NS, row, mark.name[1], {
			end_col = mark.name[2],
			hl_group = "JvimActivityName",
		})
		if mark.detail then
			vim.api.nvim_buf_set_extmark(buf, NS, row, mark.detail[1], {
				end_col = mark.detail[2],
				hl_group = "JvimActivityDetail",
			})
		end
	end

	local win_config = {
		relative = "editor",
		width = width,
		height = height,
		-- Sit above the statusline and the command line.
		row = vim.o.lines - height - 4,
		col = vim.o.columns - width - 3,
		style = "minimal",
		border = "single",
		focusable = false,
		zindex = 40,
	}

	if state.win and vim.api.nvim_win_is_valid(state.win) then
		-- NOTE: `noautocmd` is only valid when opening a window; passing it to
		-- nvim_win_set_config raises "cannot be used with existing windows".
		vim.api.nvim_win_set_config(state.win, win_config)
	else
		win_config.noautocmd = true
		state.win = vim.api.nvim_open_win(buf, false, win_config)
		vim.wo[state.win].winblend = 0
		vim.wo[state.win].winhighlight = "Normal:NormalFloat,FloatBorder:FloatBorder"
	end
end

-- ---------------------------------------------------------------------------
-- Timer
-- ---------------------------------------------------------------------------
local function stop_timer()
	if state.timer then
		state.timer:stop()
		state.timer:close()
		state.timer = nil
	end
end

local function tick()
	state.frame = state.frame % #SPINNER + 1

	local now = vim.uv.now()
	local kept = {}
	for _, entry in ipairs(state.entries) do
		if not entry.expires_at or entry.expires_at > now then
			table.insert(kept, entry)
		end
	end
	state.entries = kept

	render()

	if #state.entries == 0 then
		stop_timer()
	end
end

local function start_timer()
	if state.timer then
		return
	end

	state.timer = vim.uv.new_timer()
	state.timer:start(
		config.interval_ms,
		config.interval_ms,
		vim.schedule_wrap(function()
			-- A failure here must not leave a stuck window or a runaway timer,
			-- but it must not vanish silently either.
			local ok, err = pcall(tick)
			if not ok then
				state.entries = {}
				stop_timer()
				close_window()
				require("io.github.israiloff.config.logger").error(
					"io.github.israiloff.config.activity",
					"activity indicator failed: " .. tostring(err)
				)
			end
		end)
	)
end

-- ---------------------------------------------------------------------------
-- Entries
-- ---------------------------------------------------------------------------
local function upsert(entry)
	for i, existing in ipairs(state.entries) do
		if existing.key == entry.key then
			state.entries[i] = entry
			start_timer()
			return
		end
	end

	table.insert(state.entries, entry)
	while #state.entries > config.max_entries do
		table.remove(state.entries, 1)
	end
	start_timer()
end

local function remove(key)
	for i, existing in ipairs(state.entries) do
		if existing.key == key then
			table.remove(state.entries, i)
			return
		end
	end
end

-- ---------------------------------------------------------------------------
-- Sources
-- ---------------------------------------------------------------------------
local function on_lazy_load(name)
	if not state.armed or not name then
		return
	end

	local ok, lazy_config = pcall(require, "lazy.core.config")
	local loaded = ok and lazy_config.plugins[name] and lazy_config.plugins[name]._.loaded or nil

	local detail
	if loaded then
		local parts = {}
		if loaded.time then
			-- lazy.nvim records hrtime deltas, i.e. nanoseconds.
			table.insert(parts, ("%.1fms"):format(loaded.time / 1e6))
		end
		-- Whichever handler pulled the plugin in: cmd / event / ft / keys / require.
		for _, reason in ipairs({ "cmd", "event", "ft", "keys" }) do
			if loaded[reason] then
				table.insert(parts, tostring(loaded[reason]))
				break
			end
		end
		if #parts == 0 and loaded.plugin then
			table.insert(parts, loaded.plugin)
		end
		detail = table.concat(parts, "  ")
	end

	upsert({
		key = "lazy:" .. name,
		icon_kind = "lazy",
		name = name,
		detail = detail,
		expires_at = vim.uv.now() + config.linger_ms,
	})
end

local function on_lsp_progress(args)
	local data = args.data
	if not data or not data.params or not data.params.value then
		return
	end

	local client = vim.lsp.get_client_by_id(data.client_id)
	if not client then
		return
	end

	local value = data.params.value
	local key = ("lsp:%d:%s"):format(data.client_id, tostring(data.params.token))

	if value.kind == "end" then
		-- Briefly show the finished state instead of blinking out.
		upsert({
			key = key,
			icon_kind = "done",
			name = client.name,
			detail = value.message or "done",
			expires_at = vim.uv.now() + config.linger_ms,
		})
		return
	end

	local detail = value.message or value.title or ""
	-- jdtls bakes the percentage into the message ("Initialize Workspace - 40%"),
	-- so only append it when the message does not already carry one.
	if value.percentage and not detail:match("%d%%") then
		detail = detail ~= "" and (detail .. "  " .. value.percentage .. "%") or (value.percentage .. "%")
	end

	upsert({
		key = key,
		icon_kind = "spinner",
		name = client.name,
		detail = detail,
		-- No expiry: an in-flight task lives until its "end" report arrives. The
		-- LspDetach handler below covers servers that die mid-progress.
		expires_at = nil,
	})
end

-- ---------------------------------------------------------------------------
-- Setup
-- ---------------------------------------------------------------------------
function M.setup()
	if not config.enabled then
		return
	end

	apply_highlights()

	local group = vim.api.nvim_create_augroup("JvimActivity", { clear = true })

	vim.api.nvim_create_autocmd("ColorScheme", {
		group = group,
		callback = apply_highlights,
	})

	if config.lazy then
		vim.api.nvim_create_autocmd("User", {
			group = group,
			pattern = "LazyLoad",
			callback = function(args)
				on_lazy_load(args.data)
			end,
		})

		-- Stay quiet through the startup cascade; `:Lazy profile` already reports
		-- it, and a wall of toasts on every launch is noise.
		--
		-- Armed off VimEnter rather than lazy.nvim's VeryLazy: VeryLazy rides on
		-- UIEnter, which never fires in a headless session, and the indicator must
		-- not stay permanently disabled there. The delay covers the VeryLazy burst.
		local function arm()
			vim.defer_fn(function()
				state.armed = true
			end, 500)
		end

		if vim.v.vim_did_enter == 1 then
			arm()
		else
			vim.api.nvim_create_autocmd("VimEnter", {
				group = group,
				once = true,
				callback = arm,
			})
		end
	end

	if config.lsp then
		vim.api.nvim_create_autocmd("LspProgress", {
			group = group,
			callback = function(args)
				pcall(on_lsp_progress, args)
			end,
		})

		-- A crashed server never sends its "end" report.
		vim.api.nvim_create_autocmd("LspDetach", {
			group = group,
			callback = function(args)
				local prefix = ("lsp:%d:"):format(args.data.client_id)
				for i = #state.entries, 1, -1 do
					if state.entries[i].key:sub(1, #prefix) == prefix then
						table.remove(state.entries, i)
					end
				end
			end,
		})
	end

	vim.api.nvim_create_autocmd("VimResized", {
		group = group,
		callback = function()
			if #state.entries > 0 then
				pcall(render)
			end
		end,
	})

	vim.api.nvim_create_autocmd("VimLeavePre", {
		group = group,
		callback = function()
			stop_timer()
			close_window()
		end,
	})

	vim.api.nvim_create_user_command("JvimActivityDismiss", function()
		state.entries = {}
		stop_timer()
		close_window()
	end, { desc = "Dismiss the activity indicator" })
end

-- Exposed for the dismiss command and for ad-hoc testing.
function M.push(name, detail, opts)
	opts = opts or {}
	upsert({
		key = opts.key or ("manual:" .. name),
		icon_kind = opts.icon_kind or "spinner",
		name = name,
		detail = detail,
		expires_at = opts.linger and (vim.uv.now() + config.linger_ms) or nil,
	})
end

function M.dismiss(key)
	remove(key)
end

return M
