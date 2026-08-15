-- OSC 52 lets yanks reach the *local* clipboard from a remote session.
--
-- It used to be installed unconditionally, which broke pasting on local machines:
-- OSC 52 *reads* are unsupported by most terminals (iTerm2 included), so `"+p`
-- would silently return nothing or hang. Only take over the clipboard when there
-- is actually no local one to talk to.
local function has_local_clipboard()
	return vim.fn.executable("pbcopy") == 1
		or vim.fn.executable("wl-copy") == 1
		or vim.fn.executable("xclip") == 1
		or vim.fn.executable("xsel") == 1
		or vim.fn.executable("win32yank.exe") == 1
end

local is_remote = vim.env.SSH_TTY ~= nil or vim.env.SSH_CONNECTION ~= nil

if not is_remote and has_local_clipboard() then
	return
end

local osc52 = require("vim.ui.clipboard.osc52")

vim.g.clipboard = {
	name = "OSC 52",
	copy = {
		["+"] = osc52.copy("+"),
		["*"] = osc52.copy("*"),
	},
	paste = {
		["+"] = osc52.paste("+"),
		["*"] = osc52.paste("*"),
	},
}
