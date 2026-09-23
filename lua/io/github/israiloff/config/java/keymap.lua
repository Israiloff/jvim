local log_status, log = pcall(require, "io.github.israiloff.config.logger")
if not log_status then
	print("Error: 'io.github.israiloff.config.logger' not found")
	return
end

local logger_name = "io.github.israiloff.config.java.keymap"

local which_key_status, which_key = pcall(require, "which-key")
if not which_key_status then
	log.error(logger_name, "'which-key' not found")
	return
end

local icons = require("io.github.israiloff.config.icons")
local spring = require("io.github.israiloff.config.java.spring")
local workspace_utils = require("io.github.israiloff.config.workspace-utils")

local M = {}

-- ---------------------------------------------------------------------------
-- Build tools
--
-- Only the tool the project actually uses is offered. A Maven project has no
-- `assemble` task and a Gradle project has no `package` goal, so a menu that
-- lists both is half wrong wherever you open it.
--
-- These are plain buffer-local keymaps rather than a which-key spec, and that
-- is the whole point. `which_key.add` detaches every trigger it owns — the
-- `<leader>` mapping included — and only puts them back on the next turn of the
-- event loop. Calling it from `on_attach`, which is to say a second or two
-- after a Java file opens and while the server is busy, meant that a space
-- pressed inside that window did nothing at all.
--
-- which-key does not need the call. It builds its menu by reading the keymaps
-- that actually exist, buffer-local ones included, and takes the label from
-- `desc`. The group headings below stay in the shared spec: a group whose
-- children are absent from this buffer has nothing under it and is dropped.
-- ---------------------------------------------------------------------------

local maven = {
	prefix = "<leader>jm",
	markers = workspace_utils.MAVEN_MARKERS,
	runner = "maven",
	entries = {
		{ "C", icons.maven.Clean, "Clean", "clean" },
		{ "c", icons.maven.Compile, "Compile", "clean compile" },
		{ "d", icons.maven.Deploy, "Deploy", "clean deploy" },
		{ "e", icons.maven.Purge, "Purge local repository", "dependency:purge-local-repository" },
		{ "i", icons.maven.Install, "Install", "clean install" },
		{ "p", icons.maven.Package, "Package", "clean package" },
		{ "P", icons.maven.PackageSkipTests, "Package (skip tests)", "clean package -DskipTests" },
		{ "r", icons.maven.Refresh, "Refresh dependencies", "clean -U dependency:resolve" },
		{ "t", icons.maven.Test, "Test", "clean test" },
	},
}

local gradle = {
	prefix = "<leader>jg",
	markers = workspace_utils.GRADLE_MARKERS,
	runner = "gradle",
	entries = {
		{ "b", icons.gradle.Build, "Build", "clean build" },
		{ "B", icons.gradle.BuildSkipTests, "Build (skip tests)", "clean build -x test" },
		{ "C", icons.gradle.Clean, "Clean", "clean" },
		{ "c", icons.gradle.Compile, "Compile", "clean classes" },
		{ "d", icons.gradle.Publish, "Publish", "clean publish" },
		{ "i", icons.gradle.Install, "Install to Maven local", "clean publishToMavenLocal" },
		{ "l", icons.gradle.Tasks, "List tasks", "tasks" },
		{ "p", icons.gradle.Assemble, "Assemble", "clean assemble" },
		{ "r", icons.gradle.Refresh, "Refresh dependencies", "--refresh-dependencies" },
		{ "t", icons.gradle.Test, "Test", "clean test" },
	},
}

---Give `bufnr` the menu for the build tool its project uses.
---
---A project that carries both build files gets both menus, which is the honest
---answer: it really can be built either way. One that carries neither — a
---source tree opened before its build was written — gets no build menu at all
---rather than one whose every entry fails.
---@param bufnr integer
function M.setup_buffer(bufnr)
	if not vim.api.nvim_buf_is_valid(bufnr) or vim.b[bufnr].jvim_build_menu then
		return
	end

	for _, tool in ipairs({ maven, gradle }) do
		if workspace_utils.find_build_root(tool.markers, bufnr) then
			for _, item in ipairs(tool.entries) do
				local key, icon, label, arguments = item[1], item[2], item[3], item[4]

				vim.keymap.set("n", tool.prefix .. key, function()
					require("io.github.israiloff.config.java.build")[tool.runner](arguments)
				end, { buffer = bufnr, silent = true, desc = icon .. " " .. label })
			end
		end
	end

	-- Marked either way: a project with no build file should not be walked up
	-- again every time the server attaches another buffer of it.
	vim.b[bufnr].jvim_build_menu = true
end

-- ---------------------------------------------------------------------------
-- Normal mode
-- ---------------------------------------------------------------------------
which_key.add({
	{ "<leader>j", group = icons.ui.Java .. " Java" },
	{
		"<leader>jb",
		"<cmd>lua require('io.github.israiloff.config.java.build').toggle_output()<cr>",
		desc = icons.ui.DebugConsole .. " Build output",
	},
	{ "<leader>jc", "<Cmd>lua require('jdtls').compile()<CR>", desc = icons.java.Compile .. " Compile" },
	{ "<leader>jC", "<Cmd>lua require('jdtls').extract_constant()<CR>", desc = icons.java.Constant .. " Extract constant" },
	{ "<leader>jM", "<Cmd>lua require('jdtls').extract_method(true)<CR>", desc = icons.java.Method .. " Extract method" },
	{ "<leader>jo", "<Cmd>lua require('jdtls').organize_imports()<CR>", desc = icons.java.OptimizeCode .. " Organize imports" },
	{ "<leader>jr", "<Cmd>lua require('jdtls').build_projects()<CR>", desc = icons.java.Build .. " Rebuild" },
	{ "<leader>ju", "<Cmd>lua require('jdtls').update_projects_config()<CR>", desc = icons.java.UpdateConfig .. " Update config" },
	{
		"<leader>jV",
		"<Cmd>lua require('jdtls').extract_variable_all()<CR>",
		desc = icons.java.Variable .. " Extract variable",
	},

	{ "<leader>jd", group = icons.ui.DebugConsole .. " Debug" },
	{
		"<leader>jda",
		"<cmd>lua require('io.github.israiloff.config.java.debug').attach()<cr>",
		desc = icons.java.Attach .. " Attach to remote JVM",
	},
	{ "<leader>jdb", "<cmd>lua require'dap'.step_back()<cr>", desc = icons.java.StepBack .. " Step back" },
	{
		"<leader>jdc",
		"<cmd>lua require'dap'.continue()<cr>",
		desc = icons.java.Continue .. " Continue (asks when nothing is running)",
	},
	{ "<leader>jdC", "<cmd>lua require'dap'.run_to_cursor()<cr>", desc = icons.java.RunToCursor .. " Run to cursor" },
	{ "<leader>jdd", "<cmd>lua require'dap'.disconnect()<cr>", desc = icons.java.Disconnect .. " Disconnect" },
	{ "<leader>jdg", "<cmd>lua require'dap'.session()<cr>", desc = icons.java.GetSession .. " Get session" },
	{ "<leader>jdi", "<cmd>lua require'dap'.step_into()<cr>", desc = icons.java.StepInto .. " Step into" },
	{ "<leader>jdo", "<cmd>lua require'dap'.step_over()<cr>", desc = icons.java.StepOver .. " Step over" },
	{ "<leader>jdp", "<cmd>lua require'dap'.pause()<cr>", desc = icons.java.Pause .. " Pause" },
	{ "<leader>jdq", "<cmd>lua require'dap'.close()<cr>", desc = icons.java.Close .. " Quit" },
	{ "<leader>jdr", "<cmd>lua require'dap'.repl.toggle()<cr>", desc = icons.java.ToggleRepl .. " Toggle repl" },
	{
		"<leader>jds",
		"<cmd>lua require('io.github.israiloff.config.java.debug').start()<cr>",
		desc = icons.java.Start .. " Start (main class)",
	},
	{ "<leader>jdt", "<cmd>lua require'dap'.toggle_breakpoint()<cr>", desc = icons.java.Bug .. " Toggle breakpoint" },
	{ "<leader>jdu", "<cmd>lua require'dap'.step_out()<cr>", desc = icons.java.StepOut .. " Step out" },
	{
		"<leader>jdU",
		"<cmd>lua require'dapui'.toggle({reset = true})<cr>",
		desc = icons.java.BugFix .. " Toggle DAP UI",
	},

	{ "<leader>jm", group = icons.maven.Logo .. " Maven" },
	{ "<leader>jg", group = icons.gradle.Logo .. " Gradle" },

	{ "<leader>jt", group = icons.code.Tests .. " Test" },
	{ "<leader>jtc", "<Cmd>lua require('jdtls').test_class()<CR>", desc = icons.java.ClassTest .. " Run test class" },
	{
		"<leader>jtm",
		"<Cmd>lua require('jdtls').test_nearest_method()<CR>",
		desc = icons.java.MethodTest .. " Run test method",
	},
	{
		"<leader>jtu",
		"<Cmd>lua require('dapui').toggle({reset = true})<CR>",
		desc = icons.java.DebugUI .. " Toggle DAP UI",
	},

	-- Spring Boot support lives here rather than at the top level: it is only
	-- meaningful in a Java project, and this whole spec is registered from
	-- jdtls's on_attach. The label reports what is live in this session, which
	-- is not necessarily what is configured — the jdtls bundles the Spring
	-- server needs are only read when the client starts.
	{ "<leader>js", group = icons.spring.Logo .. " Spring [" .. spring.get_label(spring.is_enabled()) .. "]" },
	{
		"<leader>jse",
		function()
			spring.set_enabled(true)
		end,
		desc = icons.spring.Enable .. " Enable on next start",
	},
	{
		"<leader>jsd",
		function()
			spring.set_enabled(false)
		end,
		desc = icons.spring.Disable .. " Disable on next start",
	},
	{ "<leader>jst", spring.toggle, desc = icons.ui.Refresh .. " Toggle" },
	{ "<leader>jss", spring.show_status, desc = icons.spring.Status .. " Status" },
})

-- ---------------------------------------------------------------------------
-- Visual mode
-- ---------------------------------------------------------------------------
which_key.add({
	mode = "v",
	{ "<leader>j", group = icons.ui.Java .. " Java" },
	{
		"<leader>jC",
		"<Esc><Cmd>lua require('jdtls').extract_constant(true)<CR>",
		desc = icons.java.Constant .. " Extract constant",
	},
	{
		"<leader>jM",
		"<Esc><Cmd>lua require('jdtls').extract_method(true)<CR>",
		desc = icons.java.Method .. " Extract method",
	},
	{
		"<leader>jV",
		"<Esc><Cmd>lua require('jdtls').extract_variable(true)<CR>",
		desc = icons.java.Variable .. " Extract variable",
	},
})

return M
