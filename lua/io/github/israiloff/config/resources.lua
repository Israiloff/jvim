-- Live resource use of the processes Neovim is running.
--
-- The language servers this configuration starts are JVMs: jdtls is one, the
-- Spring Boot server is a second, and a debug session adds a third. Together
-- they are by far the heaviest thing on the machine, and nothing in the editor
-- says how heavy — a server that has been leaking all afternoon looks exactly
-- like one that started a minute ago until the fans come on.
--
-- The panel samples them and keeps the shape of that use over time: what a
-- process holds now, how far it has moved since it was first seen, its high
-- water mark, and a sparkline of the recent samples. Growth that never comes
-- back down is what a leak looks like from the outside.
--
-- Nothing is polled unless the panel is on screen, and whether it is on screen
-- is a saved switch rather than a per-session decision: watching a server grow
-- is something you either do or do not do, and having to ask for the panel
-- again after every restart is what stops anyone from watching at all.
local M = {}

local properties = require("io.github.israiloff.config.properties")

local NS = vim.api.nvim_create_namespace("jvim-resources")
local SPARK = { "▁", "▂", "▃", "▄", "▅", "▆", "▇", "█" }

local defaults = {
	-- Off by default: the panel is a diagnostic, not furniture.
	enabled = false,
	interval_ms = 2000,
	-- Rows are sorted by size, so the cut only ever loses the small fry.
	max_entries = 8,
	-- Samples kept per process for the sparkline.
	history = 12,
	max_width = 64,
	-- Growth over the first sample, in megabytes, before a row is called out.
	growth_warning_mb = 256,
}

local config = vim.tbl_deep_extend("force", defaults, (properties.gui or {}).resources or {})

local state = {
	buf = nil,
	win = nil,
	timer = nil,
	-- pid -> { label, baseline_kb, peak_kb, rss_kb, cpu, cpu_time, sampled_at, history }
	tracked = {},
	sampling = false,
}

-- ---------------------------------------------------------------------------
-- Highlights
-- ---------------------------------------------------------------------------
local function apply_highlights()
	vim.api.nvim_set_hl(0, "JvimResourcesTitle", { link = "Title", default = true })
	vim.api.nvim_set_hl(0, "JvimResourcesName", { link = "Normal", default = true })
	vim.api.nvim_set_hl(0, "JvimResourcesValue", { link = "Normal", default = true })
	vim.api.nvim_set_hl(0, "JvimResourcesMuted", { link = "Comment", default = true })
	vim.api.nvim_set_hl(0, "JvimResourcesGrowth", { link = "DiagnosticWarn", default = true })
	vim.api.nvim_set_hl(0, "JvimResourcesShrink", { link = "DiagnosticOk", default = true })
end

-- ---------------------------------------------------------------------------
-- Naming the processes
-- ---------------------------------------------------------------------------

---The pid of a language server.
---
---Neovim does not expose it: `client.rpc` hands out `request`, `notify`,
---`terminate` and `is_closing`, and the process handle stays inside the
---transport those close over. It is read back out of the closure, and every
---caller treats a missing pid as ordinary — the process still shows up in the
---panel, just under its command name rather than the server's.
local function client_pid(client)
	local terminate = client.rpc and client.rpc.terminate

	if type(terminate) ~= "function" then
		return nil
	end

	local index = 1

	while true do
		local name, value = debug.getupvalue(terminate, index)

		if not name then
			return nil
		end

		if type(value) == "table" then
			local transport = rawget(value, "transport")
			local sysobj = transport and rawget(transport, "sysobj")

			if sysobj and sysobj.pid then
				return sysobj.pid
			end
		end

		index = index + 1
	end
end

---pid -> language server name, for every client that is running.
local function server_names()
	local names = {}

	for _, client in ipairs(vim.lsp.get_clients()) do
		local pid = client_pid(client)

		if pid then
			names[pid] = client.name
		end
	end

	return names
end

-- ---------------------------------------------------------------------------
-- Sampling
-- ---------------------------------------------------------------------------

---Seconds held in a `ps` cpu time field: `MM:SS.ss` or `HH:MM:SS`.
local function cpu_seconds(field)
	local parts = vim.split(field, ":", { plain = true })
	local seconds = 0

	for _, part in ipairs(parts) do
		seconds = seconds * 60 + (tonumber(part) or 0)
	end

	return seconds
end

---Every process descending from this Neovim, itself included.
local function collect(output)
	local processes = {}
	local children = {}

	for _, line in ipairs(vim.split(output, "\n", { trimempty = true })) do
		local pid, parent, rss, cpu_time, command = line:match("^%s*(%d+)%s+(%d+)%s+(%d+)%s+(%S+)%s+(.*)$")

		-- The sampler is a child of this Neovim and would otherwise report
		-- itself, once per tick, forever.
		if pid and vim.fs.basename(vim.trim(command)) ~= "ps" then
			pid = tonumber(pid)
			parent = tonumber(parent)
			processes[pid] = {
				pid = pid,
				rss_kb = tonumber(rss) or 0,
				cpu_time = cpu_seconds(cpu_time),
				command = vim.fs.basename(vim.trim(command)),
			}
			children[parent] = children[parent] or {}
			table.insert(children[parent], pid)
		end
	end

	local ours = {}
	local queue = { vim.uv.os_getpid() }

	while #queue > 0 do
		local pid = table.remove(queue)
		local process = processes[pid]

		if process then
			table.insert(ours, process)

			for _, child in ipairs(children[pid] or {}) do
				table.insert(queue, child)
			end
		end
	end

	return ours
end

---Fold a snapshot into what is already known about each process.
local function absorb(processes)
	local names = server_names()
	local editor = vim.uv.os_getpid()
	local now = vim.uv.hrtime() / 1e9
	local seen = {}

	for _, process in ipairs(processes) do
		local entry = state.tracked[process.pid]
		seen[process.pid] = true

		if not entry then
			entry = {
				baseline_kb = process.rss_kb,
				peak_kb = process.rss_kb,
				history = {},
			}
			state.tracked[process.pid] = entry
		end

		-- The name is resolved on every sample: a server that attaches later
		-- stops being "java" the moment its client exists.
		if process.pid == editor then
			entry.label = "neovim"
		else
			entry.label = names[process.pid] or process.command
		end

		-- `ps` reports cpu time accumulated over the whole life of a process,
		-- which says nothing about what it is doing now. The share of the
		-- interval it actually spent running is the difference between samples.
		if entry.cpu_time and entry.sampled_at and now > entry.sampled_at then
			entry.cpu = (process.cpu_time - entry.cpu_time) / (now - entry.sampled_at) * 100
		end

		entry.cpu_time = process.cpu_time
		entry.sampled_at = now
		entry.rss_kb = process.rss_kb
		entry.peak_kb = math.max(entry.peak_kb, process.rss_kb)

		table.insert(entry.history, process.rss_kb)

		while #entry.history > config.history do
			table.remove(entry.history, 1)
		end
	end

	for pid in pairs(state.tracked) do
		if not seen[pid] then
			state.tracked[pid] = nil
		end
	end
end

-- ---------------------------------------------------------------------------
-- Formatting
-- ---------------------------------------------------------------------------
local function megabytes(kilobytes)
	local mb = kilobytes / 1024

	if mb >= 1024 then
		return string.format("%.1fG", mb / 1024)
	end

	return string.format("%.0fM", mb)
end

local function signed(kilobytes)
	local mb = kilobytes / 1024

	-- A megabyte either way is noise; only movement worth looking at gets a
	-- number, so the column reads as a list of what actually changed.
	if math.abs(mb) < 1 then
		return "·"
	end

	local sign = mb >= 0 and "+" or "-"

	mb = math.abs(mb)

	if mb >= 1024 then
		return string.format("%s%.1fG", sign, mb / 1024)
	end

	return string.format("%s%.0fM", sign, mb)
end

---Right-align by what the terminal draws: `string.format` counts bytes, and the
---columns hold multibyte marks.
local function pad(text, width)
	return string.rep(" ", math.max(0, width - vim.fn.strdisplaywidth(text))) .. text
end

---A sparkline over the samples, scaled between the smallest and the largest.
local function sparkline(history)
	if #history < 2 then
		return string.rep(" ", config.history)
	end

	local low, high = history[1], history[1]

	for _, value in ipairs(history) do
		low = math.min(low, value)
		high = math.max(high, value)
	end

	local span = high - low
	local out = {}

	for _, value in ipairs(history) do
		local level = span > 0 and math.floor((value - low) / span * (#SPARK - 1) + 0.5) or 0
		table.insert(out, SPARK[level + 1])
	end

	return string.rep(" ", config.history - #history) .. table.concat(out)
end

-- ---------------------------------------------------------------------------
-- Rendering
-- ---------------------------------------------------------------------------
local function ensure_buf()
	if state.buf and vim.api.nvim_buf_is_valid(state.buf) then
		return state.buf
	end

	state.buf = vim.api.nvim_create_buf(false, true)
	vim.bo[state.buf].bufhidden = "hide"
	vim.bo[state.buf].filetype = "jvim-resources"
	return state.buf
end

---Ordered rows, largest first, cut to `max_entries`.
local function rows()
	local ordered = {}

	for pid, entry in pairs(state.tracked) do
		table.insert(ordered, { pid = pid, entry = entry })
	end

	table.sort(ordered, function(left, right)
		return left.entry.rss_kb > right.entry.rss_kb
	end)

	local total = 0

	for _, row in ipairs(ordered) do
		total = total + row.entry.rss_kb
	end

	local dropped = math.max(0, #ordered - config.max_entries)

	while #ordered > config.max_entries do
		table.remove(ordered)
	end

	return ordered, total, dropped
end

local function build_lines()
	local ordered, total, dropped = rows()
	local name_width = 6

	for _, row in ipairs(ordered) do
		name_width = math.max(name_width, vim.fn.strdisplaywidth(row.entry.label))
	end

	name_width = math.min(name_width, 16)

	local lines = {}
	local marks = {}

	local function push(segments)
		local line = ""
		local spans = {}

		for _, segment in ipairs(segments) do
			local text = segment[1]

			if segment[2] then
				table.insert(spans, { #line, #line + #text, segment[2] })
			end

			line = line .. text
		end

		table.insert(lines, line)
		table.insert(marks, spans)
	end

	push({
		{ " resources ", "JvimResourcesTitle" },
		{ string.format("· %s across %d processes", megabytes(total), vim.tbl_count(state.tracked)), "JvimResourcesMuted" },
	})

	for _, row in ipairs(ordered) do
		local entry = row.entry
		local growth = entry.rss_kb - entry.baseline_kb
		local growth_group = "JvimResourcesMuted"

		if growth >= config.growth_warning_mb * 1024 then
			growth_group = "JvimResourcesGrowth"
		elseif growth < 0 then
			growth_group = "JvimResourcesShrink"
		end

		push({
			{ " " .. vim.fn.strcharpart(entry.label, 0, name_width), "JvimResourcesName" },
			{ string.rep(" ", math.max(1, name_width - vim.fn.strdisplaywidth(entry.label) + 1)) },
			{ pad(megabytes(entry.rss_kb), 6), "JvimResourcesValue" },
			{ " " .. pad(signed(growth), 6), growth_group },
			{ " " .. pad("▲" .. megabytes(entry.peak_kb), 7), "JvimResourcesMuted" },
			{ " " .. pad(string.format("%.1f%%", entry.cpu or 0), 6), "JvimResourcesMuted" },
			{ " " .. sparkline(entry.history), "JvimResourcesMuted" },
		})
	end

	if dropped > 0 then
		push({ { string.format(" … %d smaller process(es) not shown", dropped), "JvimResourcesMuted" } })
	end

	return lines, marks
end

local function close_window()
	if state.win and vim.api.nvim_win_is_valid(state.win) then
		pcall(vim.api.nvim_win_close, state.win, true)
	end

	state.win = nil
end

local function render()
	if not state.timer then
		return
	end

	local lines, marks = build_lines()
	local width = 0

	for _, line in ipairs(lines) do
		width = math.max(width, vim.fn.strdisplaywidth(line))
	end

	width = math.min(width + 1, config.max_width)

	local height = #lines
	local buf = ensure_buf()

	vim.bo[buf].modifiable = true
	vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)
	vim.bo[buf].modifiable = false

	vim.api.nvim_buf_clear_namespace(buf, NS, 0, -1)

	for index, spans in ipairs(marks) do
		for _, span in ipairs(spans) do
			pcall(vim.api.nvim_buf_set_extmark, buf, NS, index - 1, span[1], {
				end_col = span[2],
				hl_group = span[3],
			})
		end
	end

	-- Top right, clear of the activity panel in the bottom corner: the two are
	-- routinely on screen together, and a build that is being watched is
	-- exactly when notifications arrive.
	local win_config = {
		relative = "editor",
		width = width,
		height = height,
		row = 1,
		col = math.max(0, vim.o.columns - width - 3),
		style = "minimal",
		border = "single",
		focusable = false,
		zindex = 40,
	}

	if state.win and vim.api.nvim_win_is_valid(state.win) then
		vim.api.nvim_win_set_config(state.win, win_config)
	else
		win_config.noautocmd = true
		state.win = vim.api.nvim_open_win(buf, false, win_config)
		vim.wo[state.win].winblend = 0
		vim.wo[state.win].winhighlight = "Normal:NormalFloat,FloatBorder:FloatBorder"
	end
end

-- ---------------------------------------------------------------------------
-- Polling
-- ---------------------------------------------------------------------------
local function sample()
	if state.sampling then
		return
	end

	state.sampling = true

	local ok = pcall(
		vim.system,
		{ "ps", "-A", "-o", "pid=,ppid=,rss=,time=,comm=" },
		{ text = true },
		vim.schedule_wrap(function(result)
			state.sampling = false

			if not state.timer then
				return
			end

			if result.code ~= 0 then
				M.stop()
				vim.notify("Could not read process table: ps exited " .. tostring(result.code), vim.log.levels.ERROR, {
					title = "Resources",
				})
				return
			end

			absorb(collect(result.stdout or ""))
			render()
		end)
	)

	if not ok then
		state.sampling = false
		M.stop()
		vim.notify("Could not run ps.", vim.log.levels.ERROR, { title = "Resources" })
	end
end

-- ---------------------------------------------------------------------------
-- Public API
-- ---------------------------------------------------------------------------

---Whether the panel is on screen.
function M.is_running()
	return state.timer ~= nil
end

function M.start()
	if state.timer then
		return
	end

	apply_highlights()

	state.timer = vim.uv.new_timer()
	state.timer:start(0, config.interval_ms, vim.schedule_wrap(sample))
end

function M.stop()
	if state.timer then
		state.timer:stop()
		state.timer:close()
		state.timer = nil
	end

	close_window()
end

---Put the panel on screen, or take it off.
---
---The switch is what `toggles` persists, so this is the whole of applying it:
---the saved value has already been written by the time this runs.
---@param value boolean
function M.set_enabled(value)
	config.enabled = value == true

	if config.enabled then
		M.start()
	else
		M.stop()
	end
end

function M.toggle()
	-- Routed through `toggles` so the command and the UI menu cannot disagree
	-- about the state, and so flipping it here is remembered. Falls back to a
	-- plain start/stop if the switch registry is somehow unavailable, because a
	-- panel that will not open is worse than one that forgets.
	local ok, toggles = pcall(require, "io.github.israiloff.config.toggles")

	if ok then
		toggles.toggle("resources")
		return
	end

	M.set_enabled(not M.is_running())
end

---Forget the baselines and peaks, so growth is measured from now on.
function M.reset()
	for _, entry in pairs(state.tracked) do
		entry.baseline_kb = entry.rss_kb
		entry.peak_kb = entry.rss_kb
		entry.history = {}
	end

	if M.is_running() then
		render()
	end
end

function M.setup()
	vim.api.nvim_create_user_command("JvimResources", function()
		M.toggle()
	end, { desc = "Toggle the resource monitor" })

	vim.api.nvim_create_user_command("JvimResourcesReset", function()
		M.reset()
	end, { desc = "Measure resource growth from now on" })

	if config.enabled then
		M.start()
	end

	local group = vim.api.nvim_create_augroup("jvim_resources", { clear = true })

	vim.api.nvim_create_autocmd("VimLeavePre", {
		group = group,
		callback = function()
			M.stop()
		end,
	})

	vim.api.nvim_create_autocmd("ColorScheme", {
		group = group,
		callback = apply_highlights,
	})
end

return M
