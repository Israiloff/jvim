vim.keymap.set(
	"n",
	"<M-5>",
	"<cmd>TermExec cmd='mvn clean -U dependency:resolve' direction='horizontal' go_back=0<CR>",
	{
		desc = "Refresh maven dependencies",
	}
)
vim.keymap.set("n", "<M-7>", "<Cmd>lua require('dapui').toggle({reset = true})<CR>", { desc = "Toggle DAP UI" })
vim.keymap.set("n", "<M-8>", "<Cmd>lua require('dap').step_over()<CR>", { desc = "Debug step over" })
vim.keymap.set("n", "<M-9>", "<Cmd>lua require('dap').continue()<CR>", { desc = "Debug continue" })
vim.keymap.set("n", "<M-0>", "<Cmd>lua require('dap').disconnect()<CR>", { desc = "Debug stop" })

local which_key_status, which_key = pcall(require, "which-key")
if which_key_status then
	local icons = require("io.github.israiloff.config.icons")
	which_key.register({
		j = {
			name = icons.ui.Java .. " Java",
			o = { "<Cmd>lua require('jdtls').organize_imports()<CR>", "Organize Imports" },
			v = { "<Cmd>lua require('jdtls').extract_variable()<CR>", "Extract Variable" },
			c = { "<Cmd>lua require('jdtls').extract_constant()<CR>", "Extract Constant" },
			t = { "<Cmd>lua require('jdtls').test_nearest_method()<CR>", "Test Method" },
			T = { "<Cmd>lua require('jdtls').test_class()<CR>", "Test Class" },
			u = { "<Cmd>lua require('jdtls').update_project_config()<CR>", "Update Config" },
			d = {
				name = icons.ui.DebugConsole .. " Debug",
				t = { "<cmd>lua require'dap'.toggle_breakpoint()<cr>", "Toggle Breakpoint" },
				b = { "<cmd>lua require'dap'.step_back()<cr>", "Step Back" },
				c = { "<cmd>lua require'dap'.continue()<cr>", "Continue" },
				C = { "<cmd>lua require'dap'.run_to_cursor()<cr>", "Run To Cursor" },
				d = { "<cmd>lua require'dap'.disconnect()<cr>", "Disconnect" },
				g = { "<cmd>lua require'dap'.session()<cr>", "Get Session" },
				i = { "<cmd>lua require'dap'.step_into()<cr>", "Step Into" },
				o = { "<cmd>lua require'dap'.step_over()<cr>", "Step Over" },
				u = { "<cmd>lua require'dap'.step_out()<cr>", "Step Out" },
				p = { "<cmd>lua require'dap'.pause()<cr>", "Pause" },
				r = { "<cmd>lua require'dap'.repl.toggle()<cr>", "Toggle Repl" },
				s = { "<cmd>lua require'dap'.continue()<cr>", "Start" },
				q = { "<cmd>lua require'dap'.close()<cr>", "Quit" },
				U = { "<cmd>lua require'dapui'.toggle({reset = true})<cr>", "Toggle UI" },
			},
		},
	}, {
		prefix = "<leader>",
		mode = "n",
	})
	which_key.register({
		j = {
			name = icons.ui.Java .. " Java",
			v = { "<Esc><Cmd>lua require('jdtls').extract_variable(true)<CR>", "Extract Variable" },
			c = { "<Esc><Cmd>lua require('jdtls').extract_constant(true)<CR>", "Extract Constant" },
			m = { "<Esc><Cmd>lua require('jdtls').extract_method(true)<CR>", "Extract Method" },
		},
	}, {
		prefix = "<leader>",
		mode = "v",
	})
end
