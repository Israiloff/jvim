vim.keymap.set(
    "n",
    "<M-5>",
    "<cmd>TermExec cmd='mvn clean -U dependency:resolve' direction='horizontal' go_back=0<CR>",
    {
        desc = "Java refresh maven dependencies",
    }
)
vim.keymap.set("n", "<M-7>", "<Cmd>lua require('dapui').toggle({reset = true})<CR>", { desc = "Java toggle DAP UI" })
vim.keymap.set("n", "<M-8>", "<Cmd>lua require('dap').step_over()<CR>", { desc = "Java debug step over" })
vim.keymap.set("n", "<M-9>", "<Cmd>lua require('dap').continue()<CR>", { desc = "Java debug continue" })
vim.keymap.set("n", "<M-0>", "<Cmd>lua require('dap').disconnect()<CR>", { desc = "Java debug stop" })

-- Same keymaps for MAC OS
vim.keymap.set(
    "n",
    "∞",
    "<cmd>TermExec cmd='mvn clean -U dependency:resolve' direction='horizontal' go_back=0<CR>",
    {
        desc = "Java refresh maven dependencies",
    }
)                                                                                                                                   -- Option + 5
vim.keymap.set("n", "¶", "<Cmd>lua require('dapui').toggle({reset = true})<CR>", { desc = "Java toggle DAP UI" })                   -- Option + 7
vim.keymap.set("n", "•", "<Cmd>lua require('dap').step_over()<CR>", { desc = "Java debug step over" })                              -- Option + 8
vim.keymap.set("n", "ª", "<Cmd>lua require('dap').continue()<CR>", { desc = "Java debug continue" })                                -- Option + 9
vim.keymap.set("n", "º", "<Cmd>lua require('dap').disconnect()<CR>", { desc = "Java debug stop" })                                  -- Option + 0

local which_key_status, which_key = pcall(require, "which-key")
if which_key_status then
    local icons = require("io.github.israiloff.config.icons")
    which_key.register({
        j = {
            name = icons.ui.Java .. " Java",
            o = { "<Cmd>lua require('jdtls').organize_imports()<CR>", icons.java.OptimizeCode .. " Organize imports" },
            v = { "<Cmd>lua require('jdtls').extract_variable()<CR>", icons.java.Variable .. " Extract variable" },
            c = { "<Cmd>lua require('jdtls').extract_constant()<CR>", icons.java.Constant .. " Extract constant" },
            t = { "<Cmd>lua require('jdtls').test_nearest_method()<CR>", icons.java.MethodTest .. " Run test method" },
            T = { "<Cmd>lua require('jdtls').test_class()<CR>", icons.java.ClassTest .. " Run test class" },
            u = { "<Cmd>lua require('jdtls').update_project_config()<CR>", icons.java.UpdateConfig .. " Update config" },
            d = {
                name = icons.ui.DebugConsole .. " Debug",
                t = { "<cmd>lua require'dap'.toggle_breakpoint()<cr>", icons.java.Bug .. " Toggle breakpoint" },
                b = { "<cmd>lua require'dap'.step_back()<cr>", icons.java.StepBack .. " Step back" },
                c = { "<cmd>lua require'dap'.continue()<cr>", icons.java.Continue .. " Continue" },
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
        },
    }, {
        prefix = "<leader>",
        mode = "n",
    })
    which_key.register({
        j = {
            name = icons.ui.Java .. " Java",
            v = {
                "<Esc><Cmd>lua require('jdtls').extract_variable(true)<CR>",
                icons.java.Variable .. " Extract variable",
            },
            c = {
                "<Esc><Cmd>lua require('jdtls').extract_constant(true)<CR>",
                icons.java.Constant .. " Extract constant",
            },
            m = { "<Esc><Cmd>lua require('jdtls').extract_method(true)<CR>", icons.java.Method .. " Extract method" },
        },
    }, {
        prefix = "<leader>",
        mode = "v",
    })
end
