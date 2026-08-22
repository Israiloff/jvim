-- Starting a Java debug session without going through the configuration picker.
--
-- `dap.continue()` offers every configuration registered for the filetype, so
-- starting the application meant choosing "Launch <main class>" out of a list
-- that also held the remote-attach entry — a prompt on every single start, with
-- the answer always the same. Launching and attaching are separate intentions,
-- so they are separate keys now, and only a genuine ambiguity (a project with
-- several main classes) is still worth asking about.
local M = {}

local TITLE = "Java debug"

---The dap module plus the java configurations matching `request`.
local function configurations(request)
	local ok, dap = pcall(require, "dap")

	if not ok then
		vim.notify("nvim-dap not found.", vim.log.levels.ERROR, { title = TITLE })
		return nil, {}
	end

	local matching = {}

	for _, configuration in ipairs(dap.configurations.java or {}) do
		if configuration.request == request then
			matching[#matching + 1] = configuration
		end
	end

	return dap, matching
end

---Run the single matching configuration, or ask when there is a real choice.
local function run(dap, matching, prompt, missing)
	if #matching == 0 then
		vim.notify(missing, vim.log.levels.WARN, { title = TITLE })
		return
	end

	if #matching == 1 then
		dap.run(matching[1])
		return
	end

	vim.ui.select(matching, {
		prompt = prompt,
		format_item = function(configuration)
			return configuration.name
		end,
	}, function(configuration)
		if configuration then
			dap.run(configuration)
		end
	end)
end

---Launch the application under the debugger.
function M.start()
	local dap, launch = configurations("launch")

	if not dap then
		return
	end

	-- Pressed while a session is already running this means "carry on", not
	-- "start a second copy of the application".
	if dap.session() then
		dap.continue()
		return
	end

	run(
		dap,
		launch,
		"Debug: select a main class",
		"No launch configuration yet — JDTLS resolves the main classes once the project is imported."
	)
end

---Attach to an already running JVM.
function M.attach()
	local dap, attach = configurations("attach")

	if not dap then
		return
	end

	run(dap, attach, "Debug: select a target to attach to", "No attach configuration registered.")
end

return M
