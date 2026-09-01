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

	{ "<leader>jm", group = icons.maven.Logo .. " Maven" },
	{
		"<leader>jmC",
		"<cmd>lua require('io.github.israiloff.config.java.build').maven('clean')<cr>",
		desc = icons.maven.Clean .. " Clean",
	},
	{
		"<leader>jmc",
		"<cmd>lua require('io.github.israiloff.config.java.build').maven('clean compile')<cr>",
		desc = icons.maven.Compile .. " Compile",
	},
	{
		"<leader>jmd",
		"<cmd>lua require('io.github.israiloff.config.java.build').maven('clean deploy')<cr>",
		desc = icons.maven.Deploy .. " Deploy",
	},
	{
		"<leader>jme",
		"<cmd>lua require('io.github.israiloff.config.java.build').maven('dependency:purge-local-repository')<cr>",
		desc = icons.maven.Purge .. " Purge local repository",
	},
	{
		"<leader>jmi",
		"<cmd>lua require('io.github.israiloff.config.java.build').maven('clean install')<cr>",
		desc = icons.maven.Install .. " Install",
	},
	{
		"<leader>jmp",
		"<cmd>lua require('io.github.israiloff.config.java.build').maven('clean package')<cr>",
		desc = icons.maven.Package .. " Package",
	},
	{
		"<leader>jmP",
		"<cmd>lua require('io.github.israiloff.config.java.build').maven('clean package -DskipTests')<cr>",
		desc = icons.maven.PackageSkipTests .. " Package (skip tests)",
	},
	{
		"<leader>jmr",
		"<cmd>lua require('io.github.israiloff.config.java.build').maven('clean -U dependency:resolve')<cr>",
		desc = icons.maven.Refresh .. " Refresh dependencies",
	},
	{
		"<leader>jmt",
		"<cmd>lua require('io.github.israiloff.config.java.build').maven('clean test')<cr>",
		desc = icons.maven.Test .. " Test",
	},

	-- The same intentions as the Maven menu, on the same keys: `c` compiles,
	-- `i` installs into the local repository, `t` tests. Gradle spells them
	-- differently — a Maven install is `publishToMavenLocal`, a package is
	-- `assemble` — but which of the two a project uses should not change what
	-- you press. `clean` is prepended for the same reason it is in the Maven
	-- goals: an incremental build that reuses a stale output is the one bug
	-- these entries exist to rule out.
	{ "<leader>jg", group = icons.gradle.Logo .. " Gradle" },
	{
		"<leader>jgb",
		"<cmd>lua require('io.github.israiloff.config.java.build').gradle('clean build')<cr>",
		desc = icons.gradle.Build .. " Build",
	},
	{
		"<leader>jgB",
		"<cmd>lua require('io.github.israiloff.config.java.build').gradle('clean build -x test')<cr>",
		desc = icons.gradle.BuildSkipTests .. " Build (skip tests)",
	},
	{
		"<leader>jgC",
		"<cmd>lua require('io.github.israiloff.config.java.build').gradle('clean')<cr>",
		desc = icons.gradle.Clean .. " Clean",
	},
	{
		"<leader>jgc",
		"<cmd>lua require('io.github.israiloff.config.java.build').gradle('clean classes')<cr>",
		desc = icons.gradle.Compile .. " Compile",
	},
	{
		"<leader>jgd",
		"<cmd>lua require('io.github.israiloff.config.java.build').gradle('clean publish')<cr>",
		desc = icons.gradle.Publish .. " Publish",
	},
	{
		"<leader>jgi",
		"<cmd>lua require('io.github.israiloff.config.java.build').gradle('clean publishToMavenLocal')<cr>",
		desc = icons.gradle.Install .. " Install to Maven local",
	},
	{
		"<leader>jgl",
		"<cmd>lua require('io.github.israiloff.config.java.build').gradle('tasks')<cr>",
		desc = icons.gradle.Tasks .. " List tasks",
	},
	{
		"<leader>jgp",
		"<cmd>lua require('io.github.israiloff.config.java.build').gradle('clean assemble')<cr>",
		desc = icons.gradle.Assemble .. " Assemble",
	},
	{
		"<leader>jgr",
		"<cmd>lua require('io.github.israiloff.config.java.build').gradle('--refresh-dependencies')<cr>",
		desc = icons.gradle.Refresh .. " Refresh dependencies",
	},
	{
		"<leader>jgt",
		"<cmd>lua require('io.github.israiloff.config.java.build').gradle('clean test')<cr>",
		desc = icons.gradle.Test .. " Test",
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
