local M = {}

local uv = vim.uv or vim.loop

function M.realpath(p)
	return uv.fs_realpath(p) or vim.fn.fnamemodify(p, ":p")
end

function M.workspace_name_from_path(p)
	local rp = M.realpath(p)
	local h = vim.fn.sha256(rp):sub(1, 12)
	local tail = vim.fn.fnamemodify(rp, ":t")
	return tail .. "-" .. h
end

---Find project root for Java (Maven/Gradle) based on current buffer.
---Falls back to cwd.
function M.find_java_root()
	local markers = {
		"pom.xml",
		"mvnw",
		"build.gradle",
		"build.gradle.kts",
		"settings.gradle",
		"settings.gradle.kts",
		"gradlew",
		".git",
	}

	local root = vim.fs.root(0, markers) or vim.fn.getcwd()
	return M.realpath(root)
end

return M
