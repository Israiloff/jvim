local icons = require("io.github.israiloff.config.icons")
local dashboard = require("alpha.themes.dashboard")
local properties = require("io.github.israiloff.config.properties")

dashboard.section.header.val = {
	[[          JJJJJJJJJJJVVVVVVVV           VVVVVVVVIIIIIIIIIIMMMMMMMM               MMMMMMMM]],
	[[          J:::::::::JV::::::V           V::::::VI::::::::IM:::::::M             M:::::::M]],
	[[          J:::::::::JV::::::V           V::::::VI::::::::IM::::::::M           M::::::::M]],
	[[          JJ:::::::JJV::::::V           V::::::VII::::::IIM:::::::::M         M:::::::::M]],
	[[            J:::::J   V:::::V           V:::::V   I::::I  M::::::::::M       M::::::::::M]],
	[[            J:::::J    V:::::V         V:::::V    I::::I  M:::::::::::M     M:::::::::::M]],
	[[            J:::::J     V:::::V       V:::::V     I::::I  M:::::::M::::M   M::::M:::::::M]],
	[[            J:::::j      V:::::V     V:::::V      I::::I  M::::::M M::::M M::::M M::::::M]],
	[[            J:::::J       V:::::V   V:::::V       I::::I  M::::::M  M::::M::::M  M::::::M]],
	[[JJJJJJJ     J:::::J        V:::::V V:::::V        I::::I  M::::::M   M:::::::M   M::::::M]],
	[[J:::::J     J:::::J         V:::::V:::::V         I::::I  M::::::M    M:::::M    M::::::M]],
	[[J::::::J   J::::::J          V:::::::::V          I::::I  M::::::M     MMMMM     M::::::M]],
	[[J:::::::JJJ:::::::J           V:::::::V         II::::::IIM::::::M               M::::::M]],
	[[ JJ:::::::::::::JJ             V:::::V          I::::::::IM::::::M               M::::::M]],
	[[   JJ:::::::::JJ                V:::V           I::::::::IM::::::M               M::::::M]],
	[[     JJJJJJJJJ                   VVV            IIIIIIIIIIMMMMMMMM               MMMMMMMM]],
}

-- Set the menu
dashboard.section.buttons.val = {
	dashboard.button("f", icons.ui.FindFile .. " Find file", ":Telescope find_files<CR>"),
	dashboard.button("e", icons.ui.NewFile .. " New file", ":ene <BAR> startinsert <CR>"),
	dashboard.button("p", icons.ui.Project .. " Projects", ":Telescope projects<CR>"),
	dashboard.button("r", icons.ui.History .. " Recent files", ":Telescope oldfiles<CR>"),
	dashboard.button("t", icons.ui.FindText .. " Find text", ":Telescope live_grep<CR>"),
	dashboard.button("q", icons.ui.SignOut .. " Quit", ":qa<CR>"),
}

-- Set footer
dashboard.section.footer.val = {
	"Java NeoVim IDE v" .. properties.version,
}

return dashboard
