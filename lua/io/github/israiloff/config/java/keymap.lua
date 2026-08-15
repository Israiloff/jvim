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

-- ---------------------------------------------------------------------------
-- Normal mode
-- ---------------------------------------------------------------------------
which_key.add({
	{ "<leader>j", group = icons.ui.Java .. " Java" },
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
	{ "<leader>jda", "<cmd>lua require'dap'.continue()<cr>", desc = icons.java.Attach .. " Attach (select config)" },
	{ "<leader>jdb", "<cmd>lua require'dap'.step_back()<cr>", desc = icons.java.StepBack .. " Step back" },
	{ "<leader>jdc", "<cmd>lua require'dap'.continue()<cr>", desc = icons.java.Continue .. " Continue" },
	{ "<leader>jdC", "<cmd>lua require'dap'.run_to_cursor()<cr>", desc = icons.java.RunToCursor .. " Run to cursor" },
	{ "<leader>jdd", "<cmd>lua require'dap'.disconnect()<cr>", desc = icons.java.Disconnect .. " Disconnect" },
	{ "<leader>jdg", "<cmd>lua require'dap'.session()<cr>", desc = icons.java.GetSession .. " Get session" },
	{ "<leader>jdi", "<cmd>lua require'dap'.step_into()<cr>", desc = icons.java.StepInto .. " Step into" },
	{ "<leader>jdo", "<cmd>lua require'dap'.step_over()<cr>", desc = icons.java.StepOver .. " Step over" },
	{ "<leader>jdp", "<cmd>lua require'dap'.pause()<cr>", desc = icons.java.Pause .. " Pause" },
	{ "<leader>jdq", "<cmd>lua require'dap'.close()<cr>", desc = icons.java.Close .. " Quit" },
	{ "<leader>jdr", "<cmd>lua require'dap'.repl.toggle()<cr>", desc = icons.java.ToggleRepl .. " Toggle repl" },
	{ "<leader>jds", "<cmd>lua require'dap'.continue()<cr>", desc = icons.java.Start .. " Start" },
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
	{ "<leader>jmC", "<cmd>lua exec_in_terminal_horizontal('mvn clean')<CR>", desc = icons.maven.Clean .. " Clean" },
	{
		"<leader>jmc",
		"<cmd>lua vim.cmd('silent !rm -rf target') vim.cmd('lua exec_in_terminal_horizontal(\"mvn compile\")')<CR>",
		desc = icons.maven.Compile .. " Compile",
	},
	{
		"<leader>jmd",
		"<cmd>lua vim.cmd('silent !rm -rf target') vim.cmd('lua exec_in_terminal_horizontal(\"mvn deploy\")')<CR>",
		desc = icons.maven.Deploy .. " Deploy",
	},
	{
		"<leader>jme",
		"<cmd>lua exec_in_terminal_horizontal('mvn dependency:purge-local-repository')<CR>",
		desc = icons.maven.Purge .. " Purge local repository",
	},
	{
		"<leader>jmi",
		"<cmd>lua vim.cmd('silent !rm -rf target') vim.cmd('lua exec_in_terminal_horizontal(\"mvn install\")')<CR>",
		desc = icons.maven.Install .. " Install",
	},
	{
		"<leader>jmp",
		"<cmd>lua vim.cmd('silent !rm -rf target') vim.cmd('lua exec_in_terminal_horizontal(\"mvn package\")')<CR>",
		desc = icons.maven.Package .. " Package",
	},
	{
		"<leader>jmP",
		"<cmd>lua vim.cmd('silent !rm -rf target') vim.cmd('lua exec_in_terminal_horizontal(\"mvn package -DskipTests\")')<CR>",
		desc = icons.maven.PackageSkipTests .. " Package (skip tests)",
	},
	{
		"<leader>jmr",
		"<cmd>lua exec_in_terminal_horizontal('mvn clean -U dependency:resolve')<CR>",
		desc = icons.maven.Refresh .. " Refresh dependencies",
	},
	{
		"<leader>jmt",
		"<cmd>lua vim.cmd('silent !rm -rf target') vim.cmd('lua exec_in_terminal_horizontal(\"mvn test\")')<CR>",
		desc = icons.maven.Test .. " Test",
	},

	{ "<leader>jg", group = icons.gradle.Logo .. " Gradle" },
	{
		"<leader>jgb",
		"<cmd>lua exec_in_terminal_horizontal('./gradlew build')<CR>",
		desc = icons.gradle.Build .. " Build",
	},
	{
		"<leader>jgc",
		"<cmd>lua exec_in_terminal_horizontal('./gradlew clean')<CR>",
		desc = icons.gradle.Clean .. " Clean",
	},
	{
		"<leader>jgr",
		"<cmd>lua exec_in_terminal_horizontal('./gradlew --refresh-dependencies')<CR>",
		desc = icons.gradle.Refresh .. " Refresh deps",
	},
	{
		"<leader>jgt",
		"<cmd>lua exec_in_terminal_horizontal('./gradlew test')<CR>",
		desc = icons.gradle.Test .. " Test",
	},
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
