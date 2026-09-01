-- File-type icons that the installed font can actually draw.
--
-- nvim-web-devicons picks its glyphs from the newest Nerd Fonts, and a font
-- installed a release or two ago does not have all of them. A codepoint the
-- font is missing draws as nothing at all, so the file simply has no icon —
-- which is what happens to `.yaml`, `.yml` and `.css` here, and to nothing
-- else: of the four hundred and eighty-nine extensions it knows, those are the
-- only three whose glyph is absent.
--
-- The replacements come from the Seti set, which has been in Nerd Fonts for
-- years and carries an icon for each of these file types anyway. Updating the
-- font is the other way out of it, and this keeps the icons whether that
-- happens or not.
local devicons = require("nvim-web-devicons")

devicons.set_icon({
	yaml = { icon = "", color = "#D70000", cterm_color = "160", name = "Yaml" },
	yml = { icon = "", color = "#D70000", cterm_color = "160", name = "Yml" },
	css = { icon = "", color = "#563D7C", cterm_color = "60", name = "Css" },
})
