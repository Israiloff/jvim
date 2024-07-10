local dap = require("dap")

dap.adapters.java = {
	type = "executable",
	command = "java",
	args = {
		"-jar",
		vim.fn.stdpath("data")
			.. "/mason/packages/java-debug/com.microsoft.java.debug.plugin/target/com.microsoft.java.debug.plugin-*.jar",
	},
}

dap.configurations.java = {
	{
		type = "java",
		request = "launch",
		name = "Launch Java",
		mainClass = function()
			return vim.fn.input("Path to main class > ", vim.fn.getcwd() .. "/", "file")
		end,
		projectName = function()
			return vim.fn.input("Path to project > ", vim.fn.getcwd(), "file")
		end,
		cwd = "${workspaceFolder}",
	},
}
