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

which_key.register({
	j = {
		name = icons.ui.Java .. " Java",
		o = { "<Cmd>lua require('jdtls').organize_imports()<CR>", icons.java.OptimizeCode .. " Organize imports" },
		v = { "<Cmd>lua require('jdtls').extract_variable()<CR>", icons.java.Variable .. " Extract variable" },
		c = { "<Cmd>lua require('jdtls').extract_constant()<CR>", icons.java.Constant .. " Extract constant" },
		u = { "<Cmd>lua require('jdtls').update_project_config()<CR>", icons.java.UpdateConfig .. " Update config" },

		d = {
			name = icons.ui.DebugConsole .. " Debug",
			t = { "<cmd>lua require'dap'.toggle_breakpoint()<cr>", icons.java.Bug .. " Toggle breakpoint" },
			b = { "<cmd>lua require'dap'.step_back()<cr>", icons.java.StepBack .. " Step back" },
			c = { "<cmd>lua require'dap'.continue()<cr>", icons.java.Continue .. " Continue" },
			a = { "<cmd>lua require'dap'.continue()<cr>", icons.java.Attach .. " Attach (select config)" },
			C = { "<cmd>lua require'dap'.run_to_cursor()<cr>", icons.java.RunToCursor .. " Run to cursor" },
			d = { "<cmd>lua require'dap'.disconnect()<cr>", icons.java.Disconnect .. " Disconnect" },
			g = { "<cmd>lua require'dap'.session()<cr>", icons.java.GetSession .. " Get session" },
			i = { "<cmd>lua require'dap'.step_into()<cr>", icons.java.StepInto .. " Step into" },
			o = { "<cmd>lua require'dap'.step_over()<cr>", icons.java.StepOver .. " Step over" },
			u = { "<cmd>lua require'dap'.step_out()<cr>", icons.java.StepOut .. " Step out" },
			p = { "<cmd>lua require'dap'.pause()<cr>", icons.java.Pause .. " Pause" },
			r = { "<cmd>lua require'dap'.repl.toggle()<cr>", icons.java.ToggleRepl .. " Toggle repl" },
			s = { "<cmd>lua require'dap'.continue()<cr>", icons.java.Start .. " Start" },
			q = { "<cmd>lua require'dap'.close()<cr>", icons.java.Close .. " Quit" },
			U = { "<cmd>lua require'dapui'.toggle({reset = true})<cr>", icons.java.BugFix .. " Toggle DAP UI" },
		},

		t = {
			name = icons.code.Tests .. " Test",
			m = { "<Cmd>lua require('jdtls').test_nearest_method()<CR>", icons.java.MethodTest .. " Run test method" },
			c = { "<Cmd>lua require('jdtls').test_class()<CR>", icons.java.ClassTest .. " Run test class" },
			u = { "<Cmd>lua require('dapui').toggle({reset = true})<CR>", icons.java.DebugUI .. " Toggle DAP UI" },
		},

		m = {
			name = icons.maven.Logo .. " Maven",
			r = {
				"<cmd>lua exec_in_terminal_horizontal('mvn clean -U dependency:resolve')<CR>",
				icons.maven.Refresh .. " Refresh dependencies",
			},
			p = { "<cmd>lua exec_in_terminal_horizontal('mvn clean package')<CR>", icons.maven.Package .. " Package" },
			i = { "<cmd>lua exec_in_terminal_horizontal('mvn clean install')<CR>", icons.maven.Install .. " Install" },
			d = { "<cmd>lua exec_in_terminal_horizontal('mvn clean deploy')<CR>", icons.maven.Deploy .. " Deploy" },
			t = { "<cmd>lua exec_in_terminal_horizontal('mvn clean test')<CR>", icons.maven.Test .. " Test" },
			e = {
				"<cmd>lua exec_in_terminal_horizontal('mvn dependency:purge-local-repository')<CR>",
				icons.maven.Purge .. " Purge local repository",
			},
			P = {
				"<cmd>lua exec_in_terminal_horizontal('mvn clean package -DskipTests')<CR>",
				icons.maven.PackageSkipTests .. " Package (skip tests)",
			},
			c = { "<cmd>lua exec_in_terminal_horizontal('mvn clean compile')<CR>", icons.maven.Compile .. " Compile" },
			C = { "<cmd>lua exec_in_terminal_horizontal('mvn clean')<CR>", icons.maven.Clean .. " Clean" },
		},

		g = {
			name = icons.gradle.Logo .. " Gradle",
			t = { "<cmd>lua exec_in_terminal_horizontal('./gradlew test')<CR>", icons.gradle.Test .. " Test" },
			b = { "<cmd>lua exec_in_terminal_horizontal('./gradlew build')<CR>", icons.gradle.Build .. " Build" },
			c = { "<cmd>lua exec_in_terminal_horizontal('./gradlew clean')<CR>", icons.gradle.Clean .. " Clean" },
			r = {
				"<cmd>lua exec_in_terminal_horizontal('./gradlew --refresh-dependencies')<CR>",
				icons.gradle.Refresh .. " Refresh deps",
			},
		},
	},
}, { prefix = "<leader>", mode = "n" })

which_key.register({
	j = {
		name = icons.ui.Java .. " Java",
		v = { "<Esc><Cmd>lua require('jdtls').extract_variable(true)<CR>", icons.java.Variable .. " Extract variable" },
		c = { "<Esc><Cmd>lua require('jdtls').extract_constant(true)<CR>", icons.java.Constant .. " Extract constant" },
		m = { "<Esc><Cmd>lua require('jdtls').extract_method(true)<CR>", icons.java.Method .. " Extract method" },
	},
}, { prefix = "<leader>", mode = "v" })
