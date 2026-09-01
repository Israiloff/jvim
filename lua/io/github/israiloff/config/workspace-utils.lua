local M = {}

local uv = vim.uv or vim.loop

---The markers that identify a Gradle project.
---
---`settings.gradle` is listed as well as `build.gradle`: a Gradle root is
---allowed to carry nothing but the settings file, and in a multi-project build
---that is exactly what it carries.
M.GRADLE_MARKERS = { "settings.gradle", "settings.gradle.kts", "build.gradle", "build.gradle.kts" }

---The markers that identify a Maven project.
M.MAVEN_MARKERS = { "pom.xml" }

---Files that mark a directory as part of a Java build, either tool.
local BUILD_MARKERS = vim.list_extend(vim.list_slice(M.MAVEN_MARKERS), M.GRADLE_MARKERS)

function M.realpath(p)
	return uv.fs_realpath(p) or vim.fn.fnamemodify(p, ":p")
end

function M.workspace_name_from_path(p)
	local rp = M.realpath(p)
	local h = vim.fn.sha256(rp):sub(1, 12)
	local tail = vim.fn.fnamemodify(rp, ":t")
	return tail .. "-" .. h
end

---Whether `dir` holds one of `markers`.
---@param dir string
---@param markers string[]
local function has_marker(dir, markers)
	for _, marker in ipairs(markers) do
		if uv.fs_stat(dir .. "/" .. marker) then
			return true
		end
	end

	return false
end

---Directory of the current buffer, or the working directory for scratch ones.
---@return string
function M.buffer_directory()
	local name = vim.api.nvim_buf_get_name(0)

	if name == "" then
		return vim.fn.getcwd()
	end

	return vim.fs.dirname(name)
end

---Root of the build of kind `markers` the current buffer belongs to, or `nil`
---when the buffer is not inside one.
---
---Both build tools describe a multi-module project with a build file in every
---module, so the nearest marker above a source file is the module, not the
---project: `service/build.gradle` rather than the `settings.gradle` beside it
---that actually declares the modules. Importing the module on its own gives
---JDTLS a project whose siblings are unresolved dependencies, and points the
---build runner at a directory with no wrapper in it.
---
---Climbing while the parent still looks like a build therefore lands on the
---aggregator POM or the settings file, which is what the project is. The walk
---stops at the home directory, so a stray build file higher up cannot swallow
---every project below it.
---@param markers string[]
---@return string|nil
function M.find_build_root(markers)
	local marker = vim.fs.find(markers, { upward = true, path = M.buffer_directory(), type = "file" })[1]

	if not marker then
		return nil
	end

	local home = M.realpath(vim.fn.expand("~"))
	local root = vim.fs.dirname(marker)
	local parent = vim.fs.dirname(root)

	while parent and parent ~= root and parent ~= home and has_marker(parent, markers) do
		root = parent
		parent = vim.fs.dirname(root)
	end

	return root
end

---Find project root for Java (Maven/Gradle) based on current buffer.
---Falls back to the Git root, then to cwd.
function M.find_java_root()
	-- Whichever build file is nearest decides which of the two tools the file
	-- belongs to, and the climb then stays inside that tool: a Gradle sample
	-- checked into a Maven repository is its own project, not the bottom of the
	-- POM above it.
	local marker = vim.fs.find(BUILD_MARKERS, { upward = true, path = M.buffer_directory(), type = "file" })[1]
	local root = marker
		and M.find_build_root(
			vim.tbl_contains(M.MAVEN_MARKERS, vim.fs.basename(marker)) and M.MAVEN_MARKERS or M.GRADLE_MARKERS
		)

	if not root then
		-- A source tree with no build file at all: a scratch project, or one
		-- opened before its build was written. The Git root is the best guess
		-- left, and the wrappers are listed because a checkout is not always one.
		root = vim.fs.root(0, { ".git", "gradlew", "mvnw" }) or vim.fn.getcwd()
	end

	return M.realpath(root)
end

return M
