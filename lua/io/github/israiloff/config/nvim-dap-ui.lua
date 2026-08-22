local log_status, log = pcall(require, "io.github.israiloff.config.logger")

if not log_status then
    print("Error: 'io.github.israiloff.config.logger' not found")
    return
end

local logger_name = "io.github.israiloff.config.nvim-dap-ui"
local dap_status, dap = pcall(require, "dap")

if not dap_status then
    log.error(logger_name, "'nvim-dap' not found")
    return
end

local dap_ui_status, dapui = pcall(require, "dapui")

if not dap_ui_status then
    log.error(logger_name, "'nvim-dap-ui' not found")
    return
end

local icons_status, icons = pcall(require, "io.github.israiloff.config.icons")

if not icons_status then
    log.warn(logger_name, "'io.github.israiloff.config.icons' not found. Dap UI will not be configured")
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
                { id = "scopes",      size = 0.33 },
                { id = "breakpoints", size = 0.17 },
                { id = "stacks",      size = 0.25 },
                { id = "watches",     size = 0.25 },
            },
            size = 0.33,
            position = "right",
        },
        {
            elements = {
                { id = "repl",    size = 0.45 },
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
    numhl = "DapBreakpointHL",
})

vim.fn.sign_define("DapBreakpointRejected", {
    text = icons.ui.Bug,
    texthl = "DapBreakpointRejectedHL",
    linehl = "",
    numhl = "DapBreakpointRejectedHL",
})

vim.fn.sign_define("DapStopped", {
    text = icons.ui.BoldArrowRight,
    texthl = "DapStoppedHL",
    linehl = "",
    numhl = "DapStoppedHL",
})

local TITLE = "Debug"

-- How long the panels wait before closing themselves. `terminated` arrives from
-- the adapter a few milliseconds ahead of the debuggee's own exit status, and
-- the status is what decides whether the panels should go.
local GRACE_MS = 250

-- Why the session that is ending went wrong, or nil when it ended normally.
local failure = nil

-- Bumped for every session, so a close left over from the previous one cannot
-- take the panels of the next one down with it.
local generation = 0

local function fail(message)
    failure = message
    vim.notify(message, vim.log.levels.ERROR, { title = TITLE })
end

---Report a launch or attach request the adapter refused.
local function on_start(_, err)
    if err then
        fail("The debug session could not be started: " .. tostring(err))
    end
end

dap.listeners.after.launch["dapui_config"] = on_start

dap.listeners.after.attach["dapui_config"] = on_start

dap.listeners.after.event_initialized["dapui_config"] = function()
    failure = nil
    stopping = false
    generation = generation + 1
    dapui.open()
end

dap.listeners.after.event_breakpoint["dapui_config"] = function()
    dapui.open()
end

dap.listeners.after.event_stopped["dapui_config"] = function()
    dapui.open()
end

-- Ending a session from the editor kills the JVM, and a killed process still
-- exits non-zero — every Quit would otherwise be reported as a crash. The three
-- entry points that end a session are wrapped rather than watched: their
-- listeners only fire when the adapter answers, which is after the process is
-- already gone, and dapui's own stop buttons go through the very same table.
local stopping = false

for _, name in ipairs({ "terminate", "disconnect", "close" }) do
    local original = dap[name]

    if type(original) == "function" then
        dap[name] = function(...)
            stopping = true
            return original(...)
        end
    end
end

-- How a failed run used to disappear without a word: java-debug asks for
-- `runInTerminal`, so the program runs in a terminal nvim-dap spawns, and the
-- adapter then reports the end of the session as a bare `terminated` — no exit
-- code, and `Session.event_exited` in nvim-dap discards it even when one is
-- sent. Nothing upstream knows the program died. The pty does, so the status is
-- read from `TermClose` on the buffer nvim-dap names `[dap-terminal] ...`.
vim.api.nvim_create_autocmd("TermClose", {
    group = vim.api.nvim_create_augroup("jvim_dap_ui", { clear = true }),
    callback = function(event)
        if not vim.api.nvim_buf_get_name(event.buf):match("%[dap%-terminal%]") then
            return
        end

        local status = vim.v.event.status

        if status and status ~= 0 and not stopping then
            fail("The program exited with code " .. tostring(status) .. ". The debugger panels stay open.")
        end
    end,
})

local function close_ui()
    local current = generation

    vim.defer_fn(function()
        -- Closing takes the console with it, and after a failure that console
        -- is the only place the stack trace is left.
        if failure or current ~= generation then
            return
        end

        dapui.close()
    end, GRACE_MS)
end

-- Reporting and closing share one listener on purpose: two entries under the
-- same event are called in whatever order the table happens to iterate in, and
-- the panels would close before the failure that must keep them open is known.
dap.listeners.after.event_exited["dapui_config"] = function(_, body)
    local code = body and body.exitCode

    if code and code ~= 0 then
        fail("The program exited with code " .. tostring(code) .. ". The debugger panels stay open.")
        return
    end

    close_ui()
end

dap.listeners.after.event_terminated["dapui_config"] = close_ui

-- The adapter is not obliged to announce the end of a session, and java-debug
-- stays silent when the session is ended from the editor: neither `terminated`
-- nor `exited` arrives, so the panels outlived the session they belonged to.
-- The requests that end a session are therefore watched as well.
dap.listeners.after.terminate["dapui_config"] = close_ui

dap.listeners.after.disconnect["dapui_config"] = close_ui
