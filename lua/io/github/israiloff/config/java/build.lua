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

local TITLE = "Build"

---The terminal of the most recent build, kept so the output can be recalled.
local state = { terminal = nil }

---Directory of the current buffer, or the working directory for scratch ones.
local function buffer_directory()
	local name = vim.api.nvim_buf_get_name(0)

	if name == "" then
		return vim.fn.getcwd()
	end

	return vim.fs.dirname(name)
end

---Nearest ancestor directory holding one of `markers`.
local function project_root(markers)
	local marker = vim.fs.find(markers, { upward = true, path = buffer_directory(), type = "file" })[1]

	if not marker then
		return nil
	end

	return vim.fs.dirname(marker)
end

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

---Run `goals` in the Maven project the current file belongs to.
---@param goals string
function M.maven(goals)
	local root = project_root({ "pom.xml" })

	if not root then
		vim.notify("No pom.xml above " .. buffer_directory() .. ".", vim.log.levels.WARN, { title = TITLE })
		return
	end

	run("mvn " .. goals, root, "maven")
end

---Run `tasks` through the Gradle wrapper of the current project.
---@param tasks string
function M.gradle(tasks)
	local root = project_root({ "gradlew", "settings.gradle", "settings.gradle.kts", "build.gradle" })

	if not root then
		vim.notify("No Gradle project above " .. buffer_directory() .. ".", vim.log.levels.WARN, { title = TITLE })
		return
	end

	run("./gradlew " .. tasks, root, "gradle")
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
