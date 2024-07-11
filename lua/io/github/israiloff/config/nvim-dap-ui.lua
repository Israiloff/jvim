local log_status, log = pcall(require, "io.github.israiloff.config.logger")

if not log_status then
	print("Error: 'io.github.israiloff.config.logger' not found")
	return
end

local dap_status, _ = pcall(require, "dap")

if not dap_status then
	log.error("'nvim.dap' not found")
	return
end

local dap_ui_status, dapui = pcall(require, "dapui")

if not dap_ui_status then
	log.error("'nvim-dap-ui' not found")
	return
end

local icons_status, icons = pcall(require, "io.github.israiloff.config.icons")

if not icons_status then
	log.warn("'io.github.israiloff.config.icons' not found. Dap UI will not be configured")
	return
end

dapui.setup({
	icons = {
		expanded = icons.dap.Expanded,
		collapsed = icons.dap.Collapsed,
		circular = icons.dap.Circular,
		current_frame = icons.dap.CurrentFrame,
	},
	mappings = {
		expand = { "<CR>" },
		open = "o",
		remove = "d",
		edit = "e",
		repl = "r",
		toggle = "t",
	},
	-- Use this to override mappings for specific elements
	element_mappings = {},
	expand_lines = true,
	layouts = {
		{
			elements = {
				{ id = "scopes", size = 0.33 },
				{ id = "breakpoints", size = 0.17 },
				{ id = "stacks", size = 0.25 },
				{ id = "watches", size = 0.25 },
			},
			size = 0.33,
			position = "right",
		},
		{
			elements = {
				{ id = "repl", size = 0.45 },
				{ id = "console", size = 0.55 },
			},
			size = 0.27,
			position = "bottom",
		},
	},
	controls = {
		enabled = true,
		-- Display controls in this element
		element = "repl",
		icons = {
			pause = icons.dap.Pause,
			play = icons.dap.Play,
			step_into = icons.dap.StepInto,
			step_over = icons.dap.StepOver,
			step_out = icons.dap.StepOut,
			step_back = icons.dap.StepBack,
			run_last = icons.dap.RunLast,
			terminate = icons.dap.Terminate,
		},
	},
	floating = {
		max_height = 0.9,
		max_width = 0.5, -- Floats will be treated as percentage of your screen.
		border = "single",
		mappings = {
			close = { "q", "<Esc>" },
		},
	},
	windows = { indent = 1 },
	render = {
		max_type_length = nil, -- Can be integer or nil.
		max_value_lines = 100, -- Can be integer or nil.
		indent = 2,
	},
	force_buffers = true,
})

vim.fn.sign_define("DapBreakpoint", {
	text = icons.ui.Bug,
	texthl = "DapBreakpointHL",
	linehl = "",
	numhl = "",
})

vim.fn.sign_define("DapBreakpointRejected", {
	text = icons.ui.Bug,
	texthl = "DapBreakpointRejectedHL",
	linehl = "",
	numhl = "",
})

vim.fn.sign_define("DapStopped", {
	text = icons.ui.BoldArrowRight,
	texthl = "DapStoppedHL",
	linehl = "",
	numhl = "",
})
