-- Bottom-right activity panel.
--
-- Three sources feed the same widget:
--
--   * lazy.nvim plugin loads (`User LazyLoad`). The event fires *after* the plugin
--     finished loading and carries the elapsed time, so these are reported as
--     completed toasts (⚡ name 14.2ms cmd) rather than a fake spinner.
--
--   * LSP work-done progress (`LspProgress`). This one is genuinely in flight, so
--     it gets the animated spinner. It is the reason this module exists: jdtls
--     spends 20-30 seconds indexing a project without a single character of
--     feedback otherwise. A spinner is not trusted indefinitely though — see
--     `lsp_stale_ms` for the servers that forget to close a task.
--
--   * Notifications. `vim.notify` is replaced so that everything routed through
--     it — the project logger included — lands in this panel instead of the
--     message area, where it would push the cursor line around and force a
--     "Press ENTER" prompt on anything multi-line.
--
-- Because the panel expires entries, notifications are also kept in a bounded
-- history readable with `:JvimNotifyLog`. They cannot be written to `:messages`
-- instead: `:silent echomsg` suppresses the history entry along with the echo,
-- and every variant that does record also draws to the screen, which is the one
-- thing this panel exists to avoid.
--
-- The window never takes focus and never enters the buffer list.
local M = {}

local properties = require("io.github.israiloff.config.properties")
local icons = require("io.github.israiloff.config.icons")

local config = vim.tbl_deep_extend("force", {
	enabled = true,
	-- Report lazy.nvim plugin loads.
	lazy = true,
	-- Report LSP progress.
	lsp = true,
	-- How long an in-flight LSP task may stay silent before the panel gives up
	-- on it, in milliseconds. jdtls hands every Eclipse job its own progress
	-- token and only ever sends the closing `end` report once the job either
	-- calls `done()` or works its way to `totalWork`; a job that dies or blocks
	-- in between leaves the token dangling, and the spinner would otherwise
	-- animate for the rest of the session. Reports are throttled to a few
	-- hundred milliseconds, so a task that says nothing for a minute is stuck,
	-- not slow.
	lsp_stale_ms = 60000,
	-- Route `vim.notify` into the panel.
	notify = true,
	-- How long a finished entry stays on screen, in milliseconds.
	linger_ms = 1200,
	-- How long a notification stays on screen, per level. Errors get longer:
	-- a message you cannot finish reading is no better than no message.
	notify_linger_ms = {
		error = 8000,
		warn = 6000,
		info = 4000,
		debug = 3000,
	},
	-- Most wrapped lines a single notification may occupy.
	notify_max_lines = 6,
	-- Notifications retained for `:JvimNotifyLog`.
	notify_history = 200,
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

local LEVELS = vim.log.levels

local LEVEL_ICON = {
	[LEVELS.ERROR] = icons.diagnostics.Error,
	[LEVELS.WARN] = icons.diagnostics.Warning,
	[LEVELS.INFO] = icons.diagnostics.Information,
	[LEVELS.DEBUG] = icons.diagnostics.Hint,
	[LEVELS.TRACE] = icons.diagnostics.Hint,
}

local LEVEL_HL = {
	[LEVELS.ERROR] = "JvimActivityError",
	[LEVELS.WARN] = "JvimActivityWarn",
	[LEVELS.INFO] = "JvimActivityInfo",
	[LEVELS.DEBUG] = "JvimActivityDebug",
	[LEVELS.TRACE] = "JvimActivityDebug",
}

local LEVEL_LINGER = {
	[LEVELS.ERROR] = "error",
	[LEVELS.WARN] = "warn",
	[LEVELS.INFO] = "info",
	[LEVELS.DEBUG] = "debug",
	[LEVELS.TRACE] = "debug",
}

local LEVEL_LABEL = {
	[LEVELS.ERROR] = "ERROR",
	[LEVELS.WARN] = "WARN",
	[LEVELS.INFO] = "INFO",
	[LEVELS.DEBUG] = "DEBUG",
	[LEVELS.TRACE] = "TRACE",
}

local NS = vim.api.nvim_create_namespace("JvimActivity")

local state = {
	-- Ordered list of entries. Activity entries are
	-- { key, icon_kind, name, detail, expires_at }; notifications are
	-- { key, kind = "notify", level, title, message, expires_at }. `expires_at`
	-- is a deadline for finished entries and a watchdog for in-flight ones.
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
	-- Monotonic counter, so every notification gets its own entry rather than
	-- overwriting the previous one.
	notify_seq = 0,
	-- Bounded log of everything that came through `vim.notify`, kept because
	-- panel entries expire. Read with `:JvimNotifyLog`.
	history = {},
}

-- ---------------------------------------------------------------------------
-- Highlights
-- ---------------------------------------------------------------------------
local function apply_highlights()
	vim.api.nvim_set_hl(0, "JvimActivityIcon", { link = "DiagnosticInfo", default = true })
	vim.api.nvim_set_hl(0, "JvimActivityName", { link = "Normal", default = true })
	vim.api.nvim_set_hl(0, "JvimActivityDetail", { link = "Comment", default = true })
	vim.api.nvim_set_hl(0, "JvimActivityError", { link = "DiagnosticError", default = true })
	vim.api.nvim_set_hl(0, "JvimActivityWarn", { link = "DiagnosticWarn", default = true })
	vim.api.nvim_set_hl(0, "JvimActivityInfo", { link = "DiagnosticInfo", default = true })
	vim.api.nvim_set_hl(0, "JvimActivityDebug", { link = "Comment", default = true })
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

-- Hard-split on display cells. Used for the pathological case of a single
-- "word" wider than the panel — a stack trace path or a URL.
local function split_by_cells(text, width)
	local parts, current, current_width = {}, "", 0

	for _, char in ipairs(vim.fn.split(text, "\\zs")) do
		local char_width = vim.fn.strdisplaywidth(char)
		if current ~= "" and current_width + char_width > width then
			table.insert(parts, current)
			current, current_width = "", 0
		end
		current = current .. char
		current_width = current_width + char_width
	end

	if current ~= "" then
		table.insert(parts, current)
	end

	return parts
end

---Wrap a message to `width` cells, honouring the newlines it already contains.
local function wrap(text, width)
	local lines = {}

	for _, paragraph in ipairs(vim.split(text, "\n", { plain = true })) do
		if paragraph:match("^%s*$") then
			table.insert(lines, "")
		else
			local current = ""

			for word in paragraph:gmatch("%S+") do
				local candidate = current == "" and word or (current .. " " .. word)

				if vim.fn.strdisplaywidth(candidate) <= width then
					current = candidate
				else
					if current ~= "" then
						table.insert(lines, current)
						current = ""
					end

					local pieces = split_by_cells(word, width)
					for index = 1, #pieces - 1 do
						table.insert(lines, pieces[index])
					end
					current = pieces[#pieces] or ""
				end
			end

			if current ~= "" then
				table.insert(lines, current)
			end
		end
	end

	return lines
end

-- ---------------------------------------------------------------------------
-- Rows
--
-- One entry produces one or more physical rows. Activity entries keep the
-- original two-column table layout; notifications wrap across as many rows as
-- their message needs.
-- ---------------------------------------------------------------------------
local function notify_rows(entry, text_width)
	local icon = LEVEL_ICON[entry.level] or LEVEL_ICON[LEVELS.INFO]
	local icon_hl = LEVEL_HL[entry.level] or "JvimActivityInfo"
	local body = wrap(entry.message, text_width)
	local rows = {}

	local function push(row_icon, text, text_hl)
		table.insert(rows, {
			kind = "text",
			icon = row_icon,
			icon_hl = icon_hl,
			text = text,
			text_hl = text_hl,
		})
	end

	-- With a title the icon row names the source and the message is indented
	-- under it; without one the message simply starts next to the icon.
	if entry.title and entry.title ~= "" then
		push(icon, truncate(entry.title, text_width), "JvimActivityName")
		for _, line in ipairs(body) do
			push(nil, line, "JvimActivityDetail")
		end
	else
		for index, line in ipairs(body) do
			push(index == 1 and icon or nil, line, index == 1 and "JvimActivityName" or "JvimActivityDetail")
		end
	end

	local limit = math.max(config.notify_max_lines, 1)
	while #rows > limit do
		table.remove(rows)
		rows[#rows].text = truncate(rows[#rows].text .. " …", text_width)
	end

	return rows
end

---Build the display lines plus the highlight ranges for each of them.
---
---Activity rows are laid out as a two-column table so the timings and
---percentages line up:
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

	-- Shrink rather than disappear on a narrow terminal.
	local max_width = math.min(config.max_width, math.max(vim.o.columns - 8, 24))
	local text_width = math.max(max_width - (1 + ICON_CELLS + 1), 12)

	local rows = {}
	for _, entry in ipairs(state.entries) do
		if entry.kind == "notify" then
			vim.list_extend(rows, notify_rows(entry, text_width))
		else
			local icon = entry.icon_kind == "spinner" and spinner
				or (entry.icon_kind == "lazy" and LAZY_ICON or DONE_ICON)
			table.insert(rows, {
				kind = "columns",
				icon = icon,
				icon_hl = "JvimActivityIcon",
				name = entry.name,
				detail = entry.detail or "",
			})
		end
	end

	-- The detail column may grow until the name column is down to MIN_NAME cells;
	-- the name column then takes whatever is left. Both are truncated to fit, so a
	-- line can never exceed max_width.
	local MIN_NAME = 14
	local detail_cap = math.max(max_width - CHROME - MIN_NAME, 8)
	local detail_width = 0
	for _, row in ipairs(rows) do
		if row.kind == "columns" then
			row.detail = truncate(row.detail, detail_cap)
			detail_width = math.max(detail_width, vim.fn.strdisplaywidth(row.detail))
		end
	end

	local name_budget = math.max(max_width - CHROME - detail_width, 8)
	local name_width = 0
	for _, row in ipairs(rows) do
		if row.kind == "columns" then
			row.name = truncate(row.name, name_budget)
			name_width = math.max(name_width, vim.fn.strdisplaywidth(row.name))
		end
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
		local icon = row.icon or ""
		local icon_pad = string.rep(" ", math.max(ICON_CELLS - vim.fn.strdisplaywidth(icon), 0))
		local prefix = " " .. icon .. icon_pad .. " "
		local spans = {}

		if row.icon then
			table.insert(spans, { 1, #prefix - 1, row.icon_hl })
		end

		local line
		if row.kind == "columns" then
			local text_start = #prefix
			line = prefix .. row.name
			table.insert(spans, { text_start, #line, "JvimActivityName" })

			if detail_width > 0 then
				-- Pad the name column, then right-align the detail column.
				local pad = name_width - vim.fn.strdisplaywidth(row.name)
				local gap = detail_width - vim.fn.strdisplaywidth(row.detail)
				line = line .. string.rep(" ", pad + 2 + gap)
				local detail_start = #line
				line = line .. row.detail
				if row.detail ~= "" then
					table.insert(spans, { detail_start, #line, "JvimActivityDetail" })
				end
			end
		else
			local text_start = #prefix
			line = prefix .. row.text
			if row.text ~= "" then
				table.insert(spans, { text_start, #line, row.text_hl })
			end
		end

		table.insert(lines, line)
		table.insert(marks, spans)
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
	for i, spans in ipairs(marks) do
		local row = i - 1
		for _, span in ipairs(spans) do
			vim.api.nvim_buf_set_extmark(buf, NS, row, span[1], {
				end_col = span[2],
				hl_group = span[3],
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

-- Defined further down, next to the notification plumbing it belongs to;
-- forward-declared because `tick` records the LSP tasks it gives up on.
local record_history

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
		elseif entry.icon_kind == "spinner" then
			-- A task that ran out of time never reported that it finished. The
			-- panel drops it rather than spinning forever, but the server is
			-- most likely still stuck on it, so leave a trace in the log.
			record_history(
				LEVELS.DEBUG,
				entry.name,
				("gave up on \"%s\" after %ds without a report"):format(
					(entry.detail and entry.detail ~= "") and entry.detail or "an unnamed task",
					math.floor(config.lsp_stale_ms / 1000)
				)
			)
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
	if not config.enabled or not config.lazy or not state.armed or not name then
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
	if not config.enabled or not config.lsp then
		return
	end

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
		-- Every report pushes the deadline back, so a task that keeps talking
		-- keeps its spinner. One that goes quiet is dropped by `tick`: servers
		-- do abandon progress tokens without ever sending the closing report
		-- (see `lsp_stale_ms`), and there is no other signal that it happened.
		expires_at = vim.uv.now() + config.lsp_stale_ms,
	})
end

function record_history(level, title, message)
	table.insert(state.history, {
		time = os.date("%H:%M:%S"),
		level = level,
		title = title,
		message = message,
	})

	local limit = math.max(config.notify_history, 1)
	while #state.history > limit do
		table.remove(state.history, 1)
	end
end

local function on_notify(message, level, opts)
	message = type(message) == "string" and message or vim.inspect(message)
	level = type(level) == "number" and level or LEVELS.INFO

	local title = opts and opts.title or nil
	record_history(level, title, message)

	state.notify_seq = state.notify_seq + 1

	local linger = config.notify_linger_ms[LEVEL_LINGER[level] or "info"] or config.notify_linger_ms.info

	upsert({
		key = "notify:" .. state.notify_seq,
		kind = "notify",
		level = level,
		title = title,
		message = message,
		expires_at = vim.uv.now() + linger,
	})
end

-- ---------------------------------------------------------------------------
-- Notification log
-- ---------------------------------------------------------------------------
local LOG_NS = vim.api.nvim_create_namespace("JvimNotifyLog")

---Render the retained notifications into a scratch buffer.
---
---One line per message, continuation lines indented under it, so the log stays
---greppable:
---
---    00:03:46  WARN   [probe] logger line routed through the panel
function M.show_log()
	local lines, spans = {}, {}

	for _, item in ipairs(state.history) do
		local label = LEVEL_LABEL[item.level] or "INFO"
		local head = ("%s  %-5s  "):format(item.time, label)
		local prefix = item.title and ("[" .. item.title .. "] ") or ""
		local body = vim.split(item.message, "\n", { plain = true })

		table.insert(spans, {
			row = #lines,
			from = #item.time + 2,
			to = #item.time + 2 + #label,
			hl = LEVEL_HL[item.level] or "JvimActivityInfo",
		})
		table.insert(lines, head .. prefix .. (body[1] or ""))

		for index = 2, #body do
			table.insert(lines, string.rep(" ", #head) .. body[index])
		end
	end

	if #lines == 0 then
		lines = { "(no notifications yet)" }
	end

	local buf = vim.api.nvim_create_buf(false, true)
	vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)
	vim.bo[buf].modifiable = false
	vim.bo[buf].bufhidden = "wipe"
	vim.bo[buf].filetype = "jvim-notify-log"

	for _, span in ipairs(spans) do
		pcall(vim.api.nvim_buf_set_extmark, buf, LOG_NS, span.row, span.from, {
			end_col = span.to,
			hl_group = span.hl,
		})
	end

	vim.cmd("botright split")
	vim.api.nvim_win_set_buf(0, buf)
	vim.api.nvim_win_set_height(0, math.min(math.max(#lines + 1, 8), math.floor(vim.o.lines / 2)))
	vim.wo[0].number = false
	vim.wo[0].relativenumber = false
	vim.wo[0].wrap = false

	-- Jump to the newest entry; a log you have to scroll to is a log you ignore.
	pcall(vim.api.nvim_win_set_cursor, 0, { #lines, 0 })

	vim.keymap.set("n", "q", "<cmd>close<cr>", { buffer = buf, nowait = true, desc = "Close notification log" })
end

function M.clear_log()
	state.history = {}
end

-- ---------------------------------------------------------------------------
-- Setup
-- ---------------------------------------------------------------------------
local original_notify = vim.notify

local function install_notify()
	-- Re-entrancy guard: the panel's own failure path logs, and the logger calls
	-- `vim.notify`. Without this a broken render would recurse until the stack
	-- gave out instead of reporting itself.
	local inside = false

	vim.notify = function(message, level, opts)
		if inside or not config.enabled or not config.notify then
			return original_notify(message, level, opts)
		end

		inside = true
		local ok, err = pcall(on_notify, message, level, opts)
		inside = false

		if not ok then
			-- Never lose the caller's message because the panel misbehaved.
			original_notify(message, level, opts)
			original_notify("activity panel failed: " .. tostring(err), LEVELS.ERROR)
		end
	end
end

---Flip one of the panel's switches at runtime.
---
---Every source is gated at handler time rather than at registration time, so
---the which-key toggles in `config/toggles.lua` take effect without a restart.
---@param key "enabled"|"lazy"|"lsp"|"notify"
---@param value boolean
function M.set_option(key, value)
	config[key] = value

	if key == "enabled" and not value then
		state.entries = {}
		stop_timer()
		close_window()
	end
end

function M.setup()
	apply_highlights()

	local group = vim.api.nvim_create_augroup("JvimActivity", { clear = true })

	vim.api.nvim_create_autocmd("ColorScheme", {
		group = group,
		callback = apply_highlights,
	})

	-- Installed unconditionally: the replacement delegates to the original
	-- whenever the panel is off, which is also what makes the switch reversible
	-- inside a running session.
	install_notify()

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

	vim.api.nvim_create_autocmd("LspProgress", {
		group = group,
		callback = function(args)
			pcall(on_lsp_progress, args)
		end,
	})

	-- A crashed server never sends its "end" report. `LspDetach` also fires for
	-- every single buffer that lets go of a server that is still running —
	-- closing one Java file would otherwise wipe the progress of a perfectly
	-- healthy jdtls — so the entries are only dropped once the client itself is
	-- gone. The check is deferred because the client is still registered while
	-- the event runs.
	vim.api.nvim_create_autocmd("LspDetach", {
		group = group,
		callback = function(args)
			local client_id = args.data.client_id
			vim.schedule(function()
				local client = vim.lsp.get_client_by_id(client_id)
				if client and not client:is_stopped() then
					return
				end

				local prefix = ("lsp:%d:"):format(client_id)
				for i = #state.entries, 1, -1 do
					if state.entries[i].key:sub(1, #prefix) == prefix then
						table.remove(state.entries, i)
					end
				end
				render()
			end)
		end,
	})

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
	end, { desc = "Dismiss the activity panel" })

	vim.api.nvim_create_user_command("JvimNotifyLog", function()
		M.show_log()
	end, { desc = "Show retained notifications" })

	vim.api.nvim_create_user_command("JvimNotifyClear", function()
		M.clear_log()
	end, { desc = "Drop the retained notifications" })
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
