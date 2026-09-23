-- lock-wood palette
-- Every colour used by the theme lives here so tweaks stay in one place.

local function rgb(r, g, b)
	return string.format("#%02x%02x%02x", r, g, b)
end

local P = {
	-- Backgrounds
	bg_primary = rgb(26, 28, 32), -- main editor background
	bg_secondary = rgb(36, 40, 50), -- statusline, floats, cursorline
	bg_dark = rgb(20, 22, 26), -- darker shade (sidebars, dim inactive)
	bg_highlight = rgb(44, 49, 61), -- subtle highlight (references, folds)

	border = rgb(72, 68, 83),

	-- ANSI "dark" row
	black_dark = rgb(78, 80, 91),
	red_dark = rgb(192, 130, 129),
	green_dark = rgb(117, 156, 117),
	yellow_dark = rgb(170, 153, 128),
	blue_dark = rgb(37, 74, 101),
	magenta_dark = rgb(174, 133, 171),
	cyan_dark = rgb(105, 155, 152),
	white_dark = rgb(182, 178, 198),

	-- ANSI "bright" row
	black_bright = rgb(80, 76, 94),
	red_bright = rgb(180, 135, 135),
	green_bright = rgb(105, 159, 104),
	yellow_bright = rgb(155, 147, 97),
	blue_bright = rgb(88, 123, 152),
	magenta_bright = rgb(175, 152, 193),
	cyan_bright = rgb(107, 155, 151),
	white_bright = rgb(183, 178, 193),

	-- Muted background tints for diffs (kept dark so text stays readable)
	diff_add_bg = rgb(35, 48, 37),
	diff_change_bg = rgb(48, 45, 32),
	diff_delete_bg = rgb(52, 34, 34),
	diff_text_bg = rgb(45, 62, 52),
}

P.none = "NONE"

return P
