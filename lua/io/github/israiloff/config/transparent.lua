local prop_status, properties = pcall(require, "io.github.israiloff.config.properties")

if not prop_status or not properties.gui.transparent then
	return
end

local hl_groups_list = {
	"Normal",
	"SignColumn",
	"NormalNC",
	"TelescopeBorder",
	"NvimTreeNormal",
	"NvimTreeNormalNC",
	"EndOfBuffer",
	"MsgArea",
    "WinBarNC",
}

for _, group in ipairs(hl_groups_list) do
	vim.cmd("highlight " .. group .. " guibg=NONE ctermbg=NONE")
end
