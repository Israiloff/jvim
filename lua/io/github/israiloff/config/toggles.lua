-- Runtime switches for the boolean options in `properties.lua`.
--
-- Each one does three things when flipped:
--
--   1. updates the loaded `properties` table, so anything that reads the option
--      per call — the logger, transparency — follows immediately;
--   2. persists the new value to `properties-local.lua`, so it survives a
--      restart and an update of the tracked config;
--   3. runs the option's `apply` hook, for modules that copied the value into
--      their own state at load time.
--
-- Everything registered here applies without a restart. Options that cannot
-- (the AI provider, Spring Boot support) keep their own menus, because their
-- cost is a language server that has already been started with the old value.
local M = {}

local properties = require("io.github.israiloff.config.properties")
local local_properties = require("io.github.israiloff.config.local-properties")
local icons = require("io.github.israiloff.config.icons")

local TITLE = "JVIM"

local function activity_setter(key)
	return function(value)
		require("io.github.israiloff.config.activity").set_option(key, value)
	end
end

---@class jvim.Toggle
---@field path string[] location within `properties`
---@field label string shown in the which-key menu
---@field icon string
---@field apply? fun(value: boolean) for modules holding their own copy
local items = {
	transparent = {
		path = { "gui", "transparent" },
		label = "Transparency",
		icon = icons.ui.Transparency,
		apply = function()
			require("io.github.israiloff.config.transparent").refresh()
		end,
	},
	activity = {
		path = { "gui", "activity", "enabled" },
		label = "Activity panel",
		icon = icons.ui.Notification,
		apply = activity_setter("enabled"),
	},
	activity_lazy = {
		path = { "gui", "activity", "lazy" },
		label = "Plugin loads",
		icon = icons.kind.Module,
		apply = activity_setter("lazy"),
	},
	activity_lsp = {
		path = { "gui", "activity", "lsp" },
		label = "LSP progress",
		icon = icons.ui.Refresh,
		apply = activity_setter("lsp"),
	},
	activity_notify = {
		path = { "gui", "activity", "notify" },
		label = "Notifications in panel",
		icon = icons.ui.Notification,
		apply = activity_setter("notify"),
	},
	logger = {
		path = { "logger", "enabled" },
		label = "Logging",
		icon = icons.ui.ListUnordered,
	},
	logger_debug = {
		path = { "logger", "level", "debug" },
		label = "Debug",
		icon = icons.diagnostics.Hint,
	},
	logger_info = {
		path = { "logger", "level", "info" },
		label = "Info",
		icon = icons.diagnostics.Information,
	},
	logger_warn = {
		path = { "logger", "level", "warn" },
		label = "Warn",
		icon = icons.diagnostics.Warning,
	},
	logger_error = {
		path = { "logger", "level", "error" },
		label = "Error",
		icon = icons.diagnostics.Error,
	},
}

local function read(path)
	local node = properties

	for _, key in ipairs(path) do
		if type(node) ~= "table" then
			return nil
		end
		node = node[key]
	end

	return node
end

local function write(path, value)
	local node = properties

	for index = 1, #path - 1 do
		if type(node[path[index]]) ~= "table" then
			node[path[index]] = {}
		end
		node = node[path[index]]
	end

	node[path[#path]] = value
end

function M.is_on(name)
	local item = items[name]
	return item ~= nil and read(item.path) == true
end

function M.set(name, value)
	local item = items[name]

	if not item then
		vim.notify("Unknown toggle: " .. tostring(name), vim.log.levels.ERROR, { title = TITLE })
		return
	end

	value = value == true

	write(item.path, value)

	if not local_properties.set(item.path, value, TITLE) then
		return
	end

	if item.apply then
		local ok, err = pcall(item.apply, value)
		if not ok then
			vim.notify(
				"Failed to apply " .. item.label .. ": " .. tostring(err),
				vim.log.levels.ERROR,
				{ title = TITLE }
			)
			return
		end
	end

	vim.notify(item.label .. ": " .. M.state_label(name), vim.log.levels.INFO, { title = TITLE })
end

function M.toggle(name)
	M.set(name, not M.is_on(name))
end

function M.state_label(name)
	return M.is_on(name) and "On" or "Off"
end

---Callback for a which-key mapping.
function M.action(name)
	return function()
		M.toggle(name)
	end
end

---Description for a which-key mapping.
---
---Returned as a function on purpose: which-key v3 treats a function `desc` as a
---getter and calls it every time the popup is drawn, so the menu shows the
---current state rather than whatever it was when the spec was registered.
function M.desc(name)
	return function()
		local item = items[name]
		if not item then
			return tostring(name)
		end
		return item.icon .. " " .. item.label .. " [" .. M.state_label(name) .. "]"
	end
end

function M.show_status()
	local order = {
		"transparent",
		"activity",
		"activity_lazy",
		"activity_lsp",
		"activity_notify",
		"logger",
		"logger_debug",
		"logger_info",
		"logger_warn",
		"logger_error",
	}

	local lines = {}
	for _, name in ipairs(order) do
		table.insert(lines, ("%-24s %s"):format(items[name].label, M.state_label(name)))
	end
	table.insert(lines, "Override: " .. (local_properties.exists() and local_properties.path() or "not created"))

	vim.notify(table.concat(lines, "\n"), vim.log.levels.INFO, { title = TITLE })
end

if vim.fn.exists(":JvimToggle") == 0 then
	vim.api.nvim_create_user_command("JvimToggle", function(opts)
		M.toggle(opts.args)
	end, {
		nargs = 1,
		complete = function()
			return vim.tbl_keys(items)
		end,
		desc = "Flip one of the configuration switches",
	})
end

if vim.fn.exists(":JvimToggleStatus") == 0 then
	vim.api.nvim_create_user_command("JvimToggleStatus", function()
		M.show_status()
	end, {
		desc = "Show the state of every configuration switch",
	})
end

return M
