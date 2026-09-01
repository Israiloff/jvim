-- Running Maven and Gradle from the editor.
--
-- The build used to be typed into the shared horizontal terminal: the same one
-- `<M-1>` opens, created once with whatever directory Neovim happened to start
-- in and reused for every project afterwards. A build therefore ran wherever
-- that shell was sitting rather than in the project, and the `rm -rf target`
-- that preceded half of the goals ran in Neovim's current directory — a blind
-- recursive delete against an unknown path.
--
-- Builds now get a window of their own: a dedicated terminal, spawned in the
-- directory of the project the current file belongs to, running the build as
-- its own process instead of feeding keystrokes to an interactive shell. The
-- `rm -rf` is gone; `clean` is a build-tool goal and is passed as one.
local M = {}

local workspace_utils = require("io.github.israiloff.config.workspace-utils")

local TITLE = "Build"

---The terminal of the most recent build, kept so the output can be recalled.
local state = { terminal = nil }

---Open a fresh terminal on `command`, replacing the previous build output.
local function run(command, root, name)
	local ok, terminal = pcall(require, "toggleterm.terminal")

	if not ok then
		vim.notify("toggleterm not found.", vim.log.levels.ERROR, { title = TITLE })
		return
	end

	if state.terminal then
		pcall(function()
			state.terminal:shutdown()
		end)
	end

	state.terminal = terminal.Terminal:new({
		cmd = command,
		dir = root,
		direction = "horizontal",
		display_name = name,
		hidden = true,
		-- The window survives the process: an exit code and the last lines of a
		-- failed build are the whole point of watching it.
		close_on_exit = false,
		auto_scroll = true,
		-- Nothing is typed into a build, and normal mode keeps the output
		-- scrollable the moment it appears.
		on_open = function()
			vim.cmd("stopinsert")
		end,
		on_exit = function(_, _, exit_code)
			if exit_code == 0 then
				vim.notify(command .. " finished.", vim.log.levels.INFO, { title = TITLE })
			else
				vim.notify(
					command .. " failed with exit code " .. tostring(exit_code) .. ".",
					vim.log.levels.ERROR,
					{ title = TITLE }
				)
			end
		end,
	})

	state.terminal:open()
end

---The executable that should drive the build in `root`.
---
---A wrapper checked into the project pins the build tool's version, and on a
---machine that never installed the tool at all it is the only thing that can
---run the build — the common case for Gradle, which is rarely on `PATH`
---because every project ships `gradlew`. It only lives at the root of the
---project, which is why the root has to be the outermost one rather than the
---module the current file happens to sit in.
---@param root string
---@param wrapper string name of the wrapper script, without an extension
---@param fallback string name of the tool as installed system-wide
---@return string|nil
local function launcher(root, wrapper, fallback)
	local script = vim.fn.has("win32") == 1 and (wrapper .. ".bat") or wrapper

	if vim.fn.executable(root .. "/" .. script) == 1 then
		-- Relative, so the build output names the wrapper rather than repeating
		-- the absolute path of the project on every line.
		return "." .. (vim.fn.has("win32") == 1 and "\\" or "/") .. script
	end

	if vim.fn.executable(fallback) == 1 then
		return fallback
	end

	return nil
end

---Run `arguments` through `tool` in the project the current file belongs to.
---@param tool { markers: string[], wrapper: string, fallback: string, label: string }
---@param arguments string
local function build(tool, arguments)
	local root = workspace_utils.find_build_root(tool.markers)

	if not root then
		vim.notify(
			("No %s project above %s."):format(tool.label, workspace_utils.buffer_directory()),
			vim.log.levels.WARN,
			{ title = TITLE }
		)
		return
	end

	local executable = launcher(root, tool.wrapper, tool.fallback)

	if not executable then
		vim.notify(
			("Neither %s/%s nor %s on PATH."):format(root, tool.wrapper, tool.fallback),
			vim.log.levels.ERROR,
			{ title = TITLE }
		)
		return
	end

	run(executable .. " " .. arguments, root, tool.label:lower())
end

local MAVEN = {
	markers = workspace_utils.MAVEN_MARKERS,
	wrapper = "mvnw",
	fallback = "mvn",
	label = "Maven",
}

local GRADLE = {
	markers = workspace_utils.GRADLE_MARKERS,
	wrapper = "gradlew",
	fallback = "gradle",
	label = "Gradle",
}

---Run `goals` in the Maven project the current file belongs to.
---@param goals string
function M.maven(goals)
	build(MAVEN, goals)
end

---Run `tasks` in the Gradle project the current file belongs to.
---@param tasks string
function M.gradle(tasks)
	build(GRADLE, tasks)
end

---Show or hide the output of the most recent build.
function M.toggle_output()
	if not state.terminal then
		vim.notify("Nothing has been built yet.", vim.log.levels.INFO, { title = TITLE })
		return
	end

	state.terminal:toggle()
end

return M
