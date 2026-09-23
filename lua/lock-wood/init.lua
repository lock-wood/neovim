local M = {}

local defaults = {
	transparent = false, -- disable background colours (use terminal bg)
	dim_inactive = false, -- darker background in unfocused windows
	terminal_colors = true, -- set vim.g.terminal_color_* for :terminal
	styles = {
		comments = { italic = true },
		keywords = { bold = true },
		functions = { bold = true },
		types = { bold = true, italic = true },
	},
	-- Called with the highlight table before it is applied; lets users
	-- override or add groups: overrides = function(hl, p) hl.Normal = ... end
	overrides = nil,
}

M.options = vim.deepcopy(defaults)

function M.setup(opts)
	M._setup_called = true
	-- Legacy: merge any options previously set via vim.g.lock-wood_opts.
	local legacy = vim.g.lock - wood_opts or {}
	M.options = vim.tbl_deep_extend("force", vim.deepcopy(defaults), legacy, opts or {})
	-- Re-apply immediately if the scheme is already active.
	if vim.g.colors_name == "lock-wood" then
		M.load()
	end
end

local function build_highlights(p, o)
	local transparent = o.transparent

	local bg = transparent and p.none or p.bg_primary
	local bg_alt = transparent and p.none or p.bg_secondary
	local bg_dark = transparent and p.none or p.bg_dark
	local bg_float = p.bg_secondary -- floats keep a bg even when transparent

	local fg = p.white_bright
	local comment = p.black_bright
	local dim = p.black_dark

	local keyword = p.magenta_bright
	local func = p.blue_bright
	local type_hl = p.cyan_bright
	local constant = p.red_bright
	local string_hl = p.green_bright
	local operator = p.white_dark
	local identifier = p.white_dark

	local error_fg = p.red_bright
	local warning_fg = p.yellow_bright
	local info_fg = p.cyan_bright
	local hint_fg = p.blue_bright
	local ok_fg = p.green_bright

	local selection = p.blue_dark

	local hl = {
		-- ── Base editor ─────────────────────────────────────────────────
		Normal = { fg = fg, bg = bg },
		NormalNC = { fg = fg, bg = o.dim_inactive and bg_dark or bg },
		NormalFloat = { fg = fg, bg = bg_float },
		FloatBorder = { fg = p.border, bg = bg_float },
		FloatTitle = { fg = p.cyan_bright, bg = bg_float, bold = true },
		FloatFooter = { fg = comment, bg = bg_float },
		NonText = { fg = p.border },
		EndOfBuffer = { fg = p.border },
		Whitespace = { fg = p.bg_highlight },
		Conceal = { fg = dim },
		WinSeparator = { fg = p.border, bg = bg },
		VertSplit = { link = "WinSeparator" },
		ColorColumn = { bg = p.bg_secondary },

		Comment = vim.tbl_extend("force", { fg = comment }, o.styles.comments),

		-- ── Syntax ──────────────────────────────────────────────────────
		Keyword = vim.tbl_extend("force", { fg = keyword }, o.styles.keywords),
		Function = vim.tbl_extend("force", { fg = func }, o.styles.functions),
		Type = vim.tbl_extend("force", { fg = type_hl }, o.styles.types),
		Constant = { fg = constant },
		String = { fg = string_hl },
		Character = { fg = string_hl },
		Number = { fg = constant },
		Float = { fg = constant },
		Boolean = { fg = constant },
		Operator = { fg = operator },
		Identifier = { fg = identifier },

		Statement = { fg = keyword },
		Conditional = { fg = keyword },
		Repeat = { fg = keyword },
		Label = { fg = keyword },
		Exception = { fg = keyword },

		PreProc = { fg = p.yellow_bright },
		Include = { fg = p.yellow_bright },
		Define = { fg = p.yellow_bright },
		Macro = { fg = p.yellow_bright },
		PreCondit = { fg = p.yellow_bright },

		StorageClass = { fg = type_hl },
		Structure = { fg = type_hl },
		Typedef = { fg = type_hl },

		Special = { fg = p.cyan_bright },
		SpecialChar = { fg = p.cyan_bright },
		SpecialComment = { fg = p.cyan_dark, italic = true },
		Tag = { fg = p.magenta_bright },
		Delimiter = { fg = p.white_dark },
		Debug = { fg = p.red_dark },

		MatchParen = { bg = p.bg_highlight, bold = true },
		SpecialKey = { fg = p.magenta_dark },
		Directory = { fg = p.blue_bright },
		Title = { fg = p.blue_bright, bold = true },

		Underlined = { fg = p.blue_bright, underline = true },
		Bold = { bold = true },
		Italic = { italic = true },
		Error = { fg = error_fg },
		Todo = { fg = bg == p.none and p.bg_primary or bg, bg = p.yellow_bright, bold = true },
		Ignore = { fg = dim },

		-- ── Cursor & selection ──────────────────────────────────────────
		Cursor = { fg = p.bg_primary, bg = p.yellow_bright },
		lCursor = { link = "Cursor" },
		CursorIM = { link = "Cursor" },
		TermCursor = { link = "Cursor" },
		CursorLine = { bg = p.bg_secondary },
		CursorColumn = { bg = p.bg_secondary },
		Visual = { bg = selection },
		VisualNOS = { bg = selection },
		Search = { fg = p.bg_primary, bg = p.yellow_bright },
		IncSearch = { fg = p.bg_primary, bg = p.cyan_bright },
		CurSearch = { link = "IncSearch" },
		Substitute = { fg = p.bg_primary, bg = p.red_bright },

		-- ── Gutter ──────────────────────────────────────────────────────
		LineNr = { fg = dim, bg = transparent and p.none or bg },
		LineNrAbove = { fg = dim },
		LineNrBelow = { fg = dim },
		CursorLineNr = { fg = p.white_bright, bg = p.bg_secondary, bold = true },
		SignColumn = { bg = bg },
		CursorLineSign = { bg = p.bg_secondary },
		FoldColumn = { fg = dim, bg = bg },
		CursorLineFold = { fg = dim, bg = p.bg_secondary },
		Folded = { fg = p.white_dark, bg = p.bg_highlight },

		-- ── Diff ────────────────────────────────────────────────────────
		DiffAdd = { bg = p.diff_add_bg },
		DiffChange = { bg = p.diff_change_bg },
		DiffDelete = { fg = p.red_dark, bg = p.diff_delete_bg },
		DiffText = { bg = p.diff_text_bg },
		Added = { fg = p.green_bright },
		Changed = { fg = p.yellow_bright },
		Removed = { fg = p.red_bright },

		-- ── Statusline / tabs / winbar ──────────────────────────────────
		StatusLine = { fg = p.white_bright, bg = p.bg_secondary },
		StatusLineNC = { fg = p.border, bg = p.bg_secondary },
		TabLine = { fg = p.border, bg = p.bg_secondary },
		TabLineSel = { fg = p.white_bright, bg = bg, bold = true },
		TabLineFill = { fg = p.border, bg = p.bg_secondary },
		WinBar = { fg = p.white_bright, bg = p.bg_secondary },
		WinBarNC = { fg = p.border, bg = p.bg_secondary },

		-- ── Popup menu ──────────────────────────────────────────────────
		Pmenu = { fg = p.white_bright, bg = bg_float },
		PmenuSel = { fg = p.bg_primary, bg = p.blue_bright },
		PmenuKind = { fg = p.cyan_bright, bg = bg_float },
		PmenuKindSel = { fg = p.bg_primary, bg = p.blue_bright },
		PmenuExtra = { fg = comment, bg = bg_float },
		PmenuExtraSel = { fg = p.bg_primary, bg = p.blue_bright },
		PmenuSbar = { bg = p.bg_secondary },
		PmenuThumb = { bg = p.border },
		WildMenu = { link = "PmenuSel" },

		-- ── Messages ────────────────────────────────────────────────────
		ErrorMsg = { fg = error_fg },
		WarningMsg = { fg = warning_fg },
		ModeMsg = { fg = p.cyan_bright },
		MoreMsg = { fg = p.green_bright },
		Question = { fg = p.cyan_bright },
		MsgArea = { fg = fg },
		MsgSeparator = { fg = p.border, bg = p.bg_secondary },

		-- ── Spell ───────────────────────────────────────────────────────
		SpellBad = { sp = error_fg, undercurl = true },
		SpellCap = { sp = warning_fg, undercurl = true },
		SpellLocal = { sp = info_fg, undercurl = true },
		SpellRare = { sp = hint_fg, undercurl = true },

		-- ── Quickfix ────────────────────────────────────────────────────
		QuickFixLine = { bg = selection, bold = true },
		qfLineNr = { fg = dim },
		qfFileName = { fg = p.blue_bright },

		-- ── Diagnostics ─────────────────────────────────────────────────
		DiagnosticError = { fg = error_fg },
		DiagnosticWarn = { fg = warning_fg },
		DiagnosticInfo = { fg = info_fg },
		DiagnosticHint = { fg = hint_fg },
		DiagnosticOk = { fg = ok_fg },
		DiagnosticUnderlineError = { sp = error_fg, undercurl = true },
		DiagnosticUnderlineWarn = { sp = warning_fg, undercurl = true },
		DiagnosticUnderlineInfo = { sp = info_fg, undercurl = true },
		DiagnosticUnderlineHint = { sp = hint_fg, undercurl = true },
		DiagnosticUnderlineOk = { sp = ok_fg, undercurl = true },
		DiagnosticVirtualTextError = { fg = error_fg, bg = p.diff_delete_bg },
		DiagnosticVirtualTextWarn = { fg = warning_fg, bg = p.diff_change_bg },
		DiagnosticVirtualTextInfo = { fg = info_fg, bg = p.bg_highlight },
		DiagnosticVirtualTextHint = { fg = hint_fg, bg = p.bg_highlight },
		DiagnosticVirtualTextOk = { fg = ok_fg, bg = p.diff_add_bg },
		DiagnosticFloatingError = { fg = error_fg, bg = bg_float },
		DiagnosticFloatingWarn = { fg = warning_fg, bg = bg_float },
		DiagnosticFloatingInfo = { fg = info_fg, bg = bg_float },
		DiagnosticFloatingHint = { fg = hint_fg, bg = bg_float },
		DiagnosticSignError = { fg = error_fg, bg = bg },
		DiagnosticSignWarn = { fg = warning_fg, bg = bg },
		DiagnosticSignInfo = { fg = info_fg, bg = bg },
		DiagnosticSignHint = { fg = hint_fg, bg = bg },
		DiagnosticDeprecated = { sp = comment, strikethrough = true },
		DiagnosticUnnecessary = { fg = comment, sp = comment, undercurl = true },

		-- ── LSP core ────────────────────────────────────────────────────
		LspReferenceText = { bg = p.bg_highlight },
		LspReferenceRead = { bg = p.bg_highlight },
		LspReferenceWrite = { bg = p.bg_highlight, underline = true },
		LspSignatureActiveParameter = { fg = p.yellow_bright, bold = true },
		LspInlayHint = { fg = dim, bg = transparent and p.none or p.bg_secondary, italic = true },
		LspCodeLens = { fg = comment, italic = true },
		LspCodeLensSeparator = { fg = dim },

		-- ── Treesitter ──────────────────────────────────────────────────
		["@comment"] = { link = "Comment" },
		["@comment.documentation"] = { link = "SpecialComment" },
		["@comment.error"] = { fg = p.bg_primary, bg = error_fg, bold = true },
		["@comment.warning"] = { fg = p.bg_primary, bg = warning_fg, bold = true },
		["@comment.todo"] = { link = "Todo" },
		["@comment.note"] = { fg = p.bg_primary, bg = info_fg, bold = true },

		["@string"] = { link = "String" },
		["@string.documentation"] = { fg = string_hl, italic = true },
		["@string.regexp"] = { fg = p.cyan_bright },
		["@string.escape"] = { fg = p.cyan_bright },
		["@string.special"] = { link = "Special" },
		["@string.special.symbol"] = { fg = constant },
		["@string.special.url"] = { fg = p.blue_bright, underline = true },
		["@string.special.path"] = { fg = p.blue_bright },
		["@character"] = { link = "Character" },
		["@character.special"] = { link = "SpecialChar" },
		["@number"] = { link = "Number" },
		["@number.float"] = { link = "Float" },
		["@boolean"] = { link = "Boolean" },

		["@keyword"] = { link = "Keyword" },
		["@keyword.function"] = { link = "Keyword" },
		["@keyword.operator"] = { fg = keyword },
		["@keyword.import"] = { link = "Include" },
		["@keyword.type"] = { link = "Keyword" },
		["@keyword.modifier"] = { link = "Keyword" },
		["@keyword.repeat"] = { link = "Repeat" },
		["@keyword.return"] = { fg = keyword, italic = true },
		["@keyword.debug"] = { link = "Debug" },
		["@keyword.exception"] = { link = "Exception" },
		["@keyword.conditional"] = { link = "Conditional" },
		["@keyword.conditional.ternary"] = { link = "Operator" },
		["@keyword.directive"] = { link = "PreProc" },
		["@keyword.directive.define"] = { link = "Define" },

		["@function"] = { link = "Function" },
		["@function.builtin"] = { fg = p.cyan_bright },
		["@function.call"] = { fg = func },
		["@function.macro"] = { link = "Macro" },
		["@function.method"] = { link = "Function" },
		["@function.method.call"] = { fg = func },
		["@constructor"] = { fg = type_hl },

		["@type"] = { link = "Type" },
		["@type.builtin"] = { fg = p.cyan_dark, italic = true },
		["@type.definition"] = { link = "Typedef" },

		["@constant"] = { link = "Constant" },
		["@constant.builtin"] = { fg = constant, italic = true },
		["@constant.macro"] = { link = "Macro" },

		["@variable"] = { fg = identifier },
		["@variable.builtin"] = { fg = p.magenta_dark, italic = true },
		["@variable.parameter"] = { fg = func },
		["@variable.parameter.builtin"] = { fg = func, italic = true },
		["@variable.member"] = { fg = p.white_bright },

		["@module"] = { fg = p.cyan_dark },
		["@module.builtin"] = { fg = p.cyan_dark, italic = true },
		["@label"] = { link = "Label" },
		["@attribute"] = { fg = p.cyan_dark, italic = true },
		["@attribute.builtin"] = { fg = p.cyan_dark, italic = true },
		["@property"] = { fg = p.white_bright },

		["@operator"] = { link = "Operator" },
		["@punctuation.delimiter"] = { link = "Delimiter" },
		["@punctuation.bracket"] = { fg = p.white_dark },
		["@punctuation.special"] = { fg = p.cyan_bright },

		["@markup.strong"] = { bold = true },
		["@markup.italic"] = { italic = true },
		["@markup.strikethrough"] = { strikethrough = true },
		["@markup.underline"] = { underline = true },
		["@markup.heading"] = { link = "Title" },
		["@markup.heading.1"] = { fg = p.blue_bright, bold = true },
		["@markup.heading.2"] = { fg = p.cyan_bright, bold = true },
		["@markup.heading.3"] = { fg = p.green_bright, bold = true },
		["@markup.heading.4"] = { fg = p.yellow_bright, bold = true },
		["@markup.heading.5"] = { fg = p.magenta_bright, bold = true },
		["@markup.heading.6"] = { fg = p.red_bright, bold = true },
		["@markup.quote"] = { fg = comment, italic = true },
		["@markup.math"] = { fg = p.cyan_bright },
		["@markup.link"] = { fg = p.blue_bright },
		["@markup.link.label"] = { fg = p.cyan_bright },
		["@markup.link.url"] = { fg = p.blue_bright, underline = true },
		["@markup.raw"] = { fg = p.green_dark },
		["@markup.raw.block"] = { fg = p.white_dark },
		["@markup.list"] = { fg = p.magenta_bright },
		["@markup.list.checked"] = { fg = p.green_bright },
		["@markup.list.unchecked"] = { fg = dim },

		["@diff.plus"] = { link = "Added" },
		["@diff.minus"] = { link = "Removed" },
		["@diff.delta"] = { link = "Changed" },

		["@tag"] = { link = "Tag" },
		["@tag.builtin"] = { fg = p.magenta_bright, italic = true },
		["@tag.attribute"] = { fg = p.cyan_dark },
		["@tag.delimiter"] = { fg = p.white_dark },

		-- Legacy captures still used by some queries/plugins
		["@parameter"] = { fg = func },
		["@method"] = { link = "Function" },
		["@field"] = { fg = p.white_bright },
		["@punctuation"] = { fg = p.white_dark },
		["@delimiter"] = { link = "Delimiter" },

		-- ── PHP ─────────────────────────────────────────────────────────
		-- $variables get a warm tan so chains like $foo->bar read as
		-- tan -> dim arrow -> white property instead of all-white
		["@variable.php"] = { fg = p.yellow_dark },
		["@variable.builtin.php"] = { fg = p.magenta_dark, italic = true }, -- $this, superglobals
		["@variable.parameter.php"] = { fg = func },
		["@variable.member.php"] = { fg = p.white_bright }, -- ->property
		["@constant.php"] = { fg = constant }, -- class/global constants
		["@type.php"] = { fg = type_hl },
		["@module.php"] = { fg = p.cyan_dark }, -- namespaces (App\Models\...)
		["@attribute.php"] = { fg = p.cyan_dark, italic = true }, -- #[Attribute]
		["@function.method.call.php"] = { fg = func },
		["@keyword.modifier.php"] = { fg = keyword, italic = true }, -- public/private/readonly/static
		["@string.special.symbol.php"] = { fg = constant },
		["@punctuation.special.php"] = { fg = p.magenta_dark }, -- "{$var}" interpolation braces
		["@tag.delimiter.php"] = { fg = p.red_dark }, -- <?php ?>
		["@keyword.directive.php"] = { fg = p.red_dark }, -- declare(...)

		-- Legacy php.vim syntax groups (non-treesitter fallback)
		phpVarSelector = { fg = p.yellow_dark }, -- the $ sigil
		phpIdentifier = { fg = p.yellow_dark },
		phpMethodsVar = { fg = p.white_bright },
		phpMemberSelector = { fg = p.white_dark }, -- -> and ::
		phpFunctions = { fg = p.cyan_bright },
		phpStaticClasses = { fg = type_hl },
		phpStorageClass = { fg = keyword, italic = true },
		phpStructure = { fg = keyword },
		phpNullValue = { fg = constant, italic = true },
		phpBoolean = { link = "Boolean" },
		phpSuperglobals = { fg = p.magenta_dark, italic = true },
		phpMagicConstants = { fg = constant, italic = true },
		phpDocTags = { fg = p.cyan_dark, italic = true },
		phpDocParam = { fg = func, italic = true },

		-- ── Blade (Laravel) ─────────────────────────────────────────────
		-- tree-sitter-blade captures
		["@keyword.directive.blade"] = { fg = keyword, bold = true }, -- @if, @foreach, @section...
		["@function.blade"] = { fg = keyword, bold = true }, -- some queries tag directives as functions
		["@punctuation.bracket.blade"] = { fg = p.yellow_dark }, -- {{ }}, {!! !!}
		["@punctuation.special.blade"] = { fg = p.yellow_dark },
		["@comment.blade"] = { link = "Comment" }, -- {{-- --}}

		-- Legacy vim-blade syntax groups (non-treesitter fallback)
		bladeKeyword = { fg = keyword, bold = true },
		bladeDelimiter = { fg = p.yellow_dark },
		bladeEcho = { fg = p.white_bright },
		bladeComment = { link = "Comment" },
		bladePhpParenBlock = { fg = p.white_dark },

		-- ── LSP semantic tokens ─────────────────────────────────────────
		["@lsp.type.class"] = { link = "@type" },
		["@lsp.type.comment"] = {}, -- defer to treesitter
		["@lsp.type.decorator"] = { link = "@attribute" },
		["@lsp.type.enum"] = { link = "@type" },
		["@lsp.type.enumMember"] = { link = "@constant" },
		["@lsp.type.function"] = { link = "@function" },
		["@lsp.type.interface"] = { link = "@type" },
		["@lsp.type.macro"] = { link = "@function.macro" },
		["@lsp.type.method"] = { link = "@function.method" },
		["@lsp.type.namespace"] = { link = "@module" },
		["@lsp.type.parameter"] = { link = "@variable.parameter" },
		["@lsp.type.property"] = { link = "@property" },
		["@lsp.type.struct"] = { link = "@type" },
		["@lsp.type.type"] = { link = "@type" },
		["@lsp.type.typeParameter"] = { link = "@type" },
		["@lsp.type.variable"] = { link = "@variable" },
		["@lsp.mod.readonly"] = { link = "@constant" },
		["@lsp.mod.deprecated"] = { strikethrough = true },
		["@lsp.typemod.function.defaultLibrary"] = { link = "@function.builtin" },
		["@lsp.typemod.variable.defaultLibrary"] = { link = "@variable.builtin" },
		["@lsp.typemod.variable.global"] = { link = "@constant" },
		["@lsp.type.variable.php"] = { fg = p.yellow_dark }, -- match @variable.php
		["@lsp.type.parameter.php"] = { fg = func },
		["@lsp.type.property.php"] = { fg = p.white_bright },

		-- ── Telescope ───────────────────────────────────────────────────
		TelescopeNormal = { fg = p.white_bright, bg = bg_float },
		TelescopeBorder = { fg = p.border, bg = bg_float },
		TelescopePromptNormal = { fg = p.white_bright, bg = p.bg_highlight },
		TelescopePromptBorder = { fg = p.border, bg = p.bg_highlight },
		TelescopePromptTitle = { fg = p.bg_primary, bg = p.blue_bright, bold = true },
		TelescopePromptPrefix = { fg = p.cyan_bright, bg = p.bg_highlight },
		TelescopePromptCounter = { fg = comment, bg = p.bg_highlight },
		TelescopeResultsTitle = { fg = p.bg_primary, bg = p.cyan_bright, bold = true },
		TelescopePreviewTitle = { fg = p.bg_primary, bg = p.green_bright, bold = true },
		TelescopeSelection = { fg = p.white_bright, bg = selection },
		TelescopeSelectionCaret = { fg = p.cyan_bright, bg = selection },
		TelescopeMultiSelection = { fg = p.magenta_bright, bg = selection },
		TelescopeMatching = { fg = p.yellow_bright, bold = true },

		-- ── nvim-cmp / blink.cmp ────────────────────────────────────────
		CmpItemAbbr = { fg = p.white_bright },
		CmpItemAbbrDeprecated = { fg = p.border, strikethrough = true },
		CmpItemAbbrMatch = { fg = p.blue_bright, bold = true },
		CmpItemAbbrMatchFuzzy = { fg = p.blue_bright },
		CmpItemMenu = { fg = comment },
		CmpItemKind = { fg = p.cyan_bright },
		CmpItemKindText = { fg = p.white_dark },
		CmpItemKindMethod = { fg = func },
		CmpItemKindFunction = { fg = func },
		CmpItemKindConstructor = { fg = type_hl },
		CmpItemKindField = { fg = p.white_bright },
		CmpItemKindVariable = { fg = identifier },
		CmpItemKindClass = { fg = type_hl },
		CmpItemKindInterface = { fg = type_hl },
		CmpItemKindModule = { fg = p.cyan_dark },
		CmpItemKindProperty = { fg = p.white_bright },
		CmpItemKindUnit = { fg = constant },
		CmpItemKindValue = { fg = constant },
		CmpItemKindEnum = { fg = type_hl },
		CmpItemKindKeyword = { fg = keyword },
		CmpItemKindSnippet = { fg = p.green_bright },
		CmpItemKindColor = { fg = p.magenta_bright },
		CmpItemKindFile = { fg = p.blue_bright },
		CmpItemKindReference = { fg = p.cyan_bright },
		CmpItemKindFolder = { fg = p.blue_bright },
		CmpItemKindEnumMember = { fg = constant },
		CmpItemKindConstant = { fg = constant },
		CmpItemKindStruct = { fg = type_hl },
		CmpItemKindEvent = { fg = p.yellow_bright },
		CmpItemKindOperator = { fg = operator },
		CmpItemKindTypeParameter = { fg = type_hl },
		BlinkCmpMenu = { link = "Pmenu" },
		BlinkCmpMenuBorder = { link = "FloatBorder" },
		BlinkCmpMenuSelection = { link = "PmenuSel" },
		BlinkCmpLabelMatch = { link = "CmpItemAbbrMatch" },
		BlinkCmpDoc = { link = "NormalFloat" },
		BlinkCmpDocBorder = { link = "FloatBorder" },

		-- ── Gitsigns ────────────────────────────────────────────────────
		GitSignsAdd = { fg = p.green_bright },
		GitSignsChange = { fg = p.yellow_bright },
		GitSignsDelete = { fg = p.red_bright },
		GitSignsAddNr = { fg = p.green_bright },
		GitSignsChangeNr = { fg = p.yellow_bright },
		GitSignsDeleteNr = { fg = p.red_bright },
		GitSignsAddLn = { bg = p.diff_add_bg },
		GitSignsChangeLn = { bg = p.diff_change_bg },
		GitSignsDeleteLn = { bg = p.diff_delete_bg },
		GitSignsAddInline = { bg = p.diff_text_bg },
		GitSignsChangeInline = { bg = p.diff_text_bg },
		GitSignsDeleteInline = { bg = p.diff_delete_bg },
		GitSignsCurrentLineBlame = { fg = dim, italic = true },

		-- git commit / diff filetypes
		diffAdded = { link = "Added" },
		diffRemoved = { link = "Removed" },
		diffChanged = { link = "Changed" },
		diffFile = { fg = p.blue_bright },
		diffLine = { fg = p.magenta_bright },
		diffIndexLine = { fg = comment },
		gitcommitSummary = { fg = p.white_bright },
		gitcommitOverflow = { fg = error_fg },

		-- ── nvim-tree ───────────────────────────────────────────────────
		NvimTreeNormal = { fg = fg, bg = bg_dark },
		NvimTreeNormalNC = { fg = fg, bg = bg_dark },
		NvimTreeWinSeparator = { fg = p.border, bg = bg_dark },
		NvimTreeRootFolder = { fg = p.magenta_bright, bold = true },
		NvimTreeFolderIcon = { fg = p.blue_bright },
		NvimTreeFolderName = { fg = p.blue_bright },
		NvimTreeOpenedFolderName = { fg = p.blue_bright, bold = true },
		NvimTreeEmptyFolderName = { fg = dim },
		NvimTreeSymlink = { fg = p.cyan_bright },
		NvimTreeSpecialFile = { fg = p.yellow_bright },
		NvimTreeExecFile = { fg = p.green_bright },
		NvimTreeGitDirty = { fg = p.yellow_bright },
		NvimTreeGitNew = { fg = p.green_bright },
		NvimTreeGitDeleted = { fg = p.red_bright },
		NvimTreeIndentMarker = { fg = p.border },
		NvimTreeCursorLine = { bg = p.bg_secondary },

		-- ── neo-tree ────────────────────────────────────────────────────
		NeoTreeNormal = { fg = fg, bg = bg_dark },
		NeoTreeNormalNC = { fg = fg, bg = bg_dark },
		NeoTreeWinSeparator = { fg = p.border, bg = bg_dark },
		NeoTreeRootName = { fg = p.magenta_bright, bold = true },
		NeoTreeDirectoryIcon = { fg = p.blue_bright },
		NeoTreeDirectoryName = { fg = p.blue_bright },
		NeoTreeFileName = { fg = fg },
		NeoTreeSymbolicLinkTarget = { fg = p.cyan_bright },
		NeoTreeIndentMarker = { fg = p.border },
		NeoTreeGitAdded = { fg = p.green_bright },
		NeoTreeGitModified = { fg = p.yellow_bright },
		NeoTreeGitDeleted = { fg = p.red_bright },
		NeoTreeGitUntracked = { fg = p.green_dark },
		NeoTreeGitConflict = { fg = p.red_bright, bold = true },
		NeoTreeGitIgnored = { fg = dim },
		NeoTreeDimText = { fg = dim },
		NeoTreeDotfile = { fg = comment },
		NeoTreeCursorLine = { bg = p.bg_secondary },
		NeoTreeFloatBorder = { link = "FloatBorder" },
		NeoTreeFloatTitle = { link = "FloatTitle" },
		NeoTreeTabActive = { fg = p.white_bright, bg = bg, bold = true },
		NeoTreeTabInactive = { fg = p.border, bg = p.bg_secondary },

		-- ── oil.nvim ────────────────────────────────────────────────────
		OilDir = { fg = p.blue_bright },
		OilLink = { fg = p.cyan_bright },
		OilCopy = { fg = p.yellow_bright },
		OilMove = { fg = p.magenta_bright },
		OilCreate = { fg = p.green_bright },
		OilDelete = { fg = p.red_bright },

		-- ── which-key ───────────────────────────────────────────────────
		WhichKey = { fg = p.cyan_bright, bold = true },
		WhichKeyGroup = { fg = p.blue_bright },
		WhichKeyDesc = { fg = p.white_bright },
		WhichKeySeparator = { fg = comment },
		WhichKeyNormal = { link = "NormalFloat" },
		WhichKeyBorder = { link = "FloatBorder" },
		WhichKeyValue = { fg = comment },

		-- ── lazy.nvim ───────────────────────────────────────────────────
		LazyNormal = { link = "NormalFloat" },
		LazyH1 = { fg = p.bg_primary, bg = p.blue_bright, bold = true },
		LazyH2 = { fg = p.blue_bright, bold = true },
		LazyButton = { fg = p.white_dark, bg = p.bg_highlight },
		LazyButtonActive = { fg = p.bg_primary, bg = p.blue_bright, bold = true },
		LazySpecial = { fg = p.cyan_bright },
		LazyProgressDone = { fg = p.green_bright },
		LazyProgressTodo = { fg = dim },
		LazyReasonPlugin = { fg = p.magenta_bright },
		LazyReasonEvent = { fg = p.yellow_bright },
		LazyReasonCmd = { fg = p.cyan_bright },
		LazyReasonFt = { fg = p.green_bright },
		LazyReasonKeys = { fg = p.blue_bright },
		LazyDimmed = { fg = comment },
		LazyCommit = { fg = p.yellow_dark },

		-- ── mason.nvim ──────────────────────────────────────────────────
		MasonNormal = { link = "NormalFloat" },
		MasonHeader = { fg = p.bg_primary, bg = p.blue_bright, bold = true },
		MasonHighlight = { fg = p.cyan_bright },
		MasonHighlightBlock = { fg = p.bg_primary, bg = p.cyan_bright },
		MasonHighlightBlockBold = { fg = p.bg_primary, bg = p.cyan_bright, bold = true },
		MasonMuted = { fg = comment },
		MasonMutedBlock = { fg = p.white_dark, bg = p.bg_highlight },
		MasonError = { fg = error_fg },

		-- ── indent-blankline (v3) / mini.indentscope ────────────────────
		IblIndent = { fg = p.bg_highlight },
		IblWhitespace = { fg = p.bg_highlight },
		IblScope = { fg = p.border },
		IndentBlanklineChar = { fg = p.bg_highlight }, -- v2 fallback
		IndentBlanklineContextChar = { fg = p.border },
		MiniIndentscopeSymbol = { fg = p.border },

		-- ── nvim-notify ─────────────────────────────────────────────────
		NotifyBackground = { bg = p.bg_primary },
		NotifyERRORBorder = { fg = error_fg },
		NotifyWARNBorder = { fg = warning_fg },
		NotifyINFOBorder = { fg = info_fg },
		NotifyDEBUGBorder = { fg = comment },
		NotifyTRACEBorder = { fg = p.magenta_bright },
		NotifyERRORIcon = { fg = error_fg },
		NotifyWARNIcon = { fg = warning_fg },
		NotifyINFOIcon = { fg = info_fg },
		NotifyDEBUGIcon = { fg = comment },
		NotifyTRACEIcon = { fg = p.magenta_bright },
		NotifyERRORTitle = { fg = error_fg, bold = true },
		NotifyWARNTitle = { fg = warning_fg, bold = true },
		NotifyINFOTitle = { fg = info_fg, bold = true },
		NotifyDEBUGTitle = { fg = comment, bold = true },
		NotifyTRACETitle = { fg = p.magenta_bright, bold = true },

		-- ── noice.nvim ──────────────────────────────────────────────────
		NoiceCmdlinePopup = { link = "NormalFloat" },
		NoiceCmdlinePopupBorder = { link = "FloatBorder" },
		NoiceCmdlineIcon = { fg = p.cyan_bright },
		NoiceConfirmBorder = { link = "FloatBorder" },
		NoiceVirtualText = { fg = comment, italic = true },

		-- ── trouble.nvim ────────────────────────────────────────────────
		TroubleNormal = { fg = fg, bg = bg_dark },
		TroubleNormalNC = { fg = fg, bg = bg_dark },
		TroubleText = { fg = p.white_dark },
		TroubleCount = { fg = p.magenta_bright, bold = true },
		TroubleIndent = { fg = p.border },

		-- ── flash.nvim / leap / hop ─────────────────────────────────────
		FlashBackdrop = { fg = dim },
		FlashLabel = { fg = p.bg_primary, bg = p.magenta_bright, bold = true },
		FlashMatch = { fg = p.bg_primary, bg = p.blue_bright },
		FlashCurrent = { fg = p.bg_primary, bg = p.cyan_bright },
		LeapBackdrop = { fg = dim },
		LeapLabel = { fg = p.bg_primary, bg = p.magenta_bright, bold = true },
		LeapMatch = { fg = p.bg_primary, bg = p.blue_bright },
		HopNextKey = { fg = p.magenta_bright, bold = true },
		HopNextKey1 = { fg = p.blue_bright, bold = true },
		HopNextKey2 = { fg = p.cyan_bright },
		HopUnmatched = { fg = dim },

		-- ── vim-illuminate ──────────────────────────────────────────────
		IlluminatedWordText = { bg = p.bg_highlight },
		IlluminatedWordRead = { bg = p.bg_highlight },
		IlluminatedWordWrite = { bg = p.bg_highlight, underline = true },

		-- ── treesitter-context ──────────────────────────────────────────
		TreesitterContext = { bg = p.bg_secondary },
		TreesitterContextBottom = { sp = p.border, underline = true },
		TreesitterContextLineNumber = { fg = dim, bg = p.bg_secondary },

		-- ── rainbow-delimiters ──────────────────────────────────────────
		RainbowDelimiterRed = { fg = p.red_bright },
		RainbowDelimiterYellow = { fg = p.yellow_bright },
		RainbowDelimiterBlue = { fg = p.blue_bright },
		RainbowDelimiterOrange = { fg = p.yellow_dark },
		RainbowDelimiterGreen = { fg = p.green_bright },
		RainbowDelimiterViolet = { fg = p.magenta_bright },
		RainbowDelimiterCyan = { fg = p.cyan_bright },

		-- ── dashboard / alpha / snacks ──────────────────────────────────
		DashboardHeader = { fg = p.blue_bright },
		DashboardFooter = { fg = comment, italic = true },
		DashboardIcon = { fg = p.cyan_bright },
		DashboardDesc = { fg = p.white_bright },
		DashboardKey = { fg = p.magenta_bright },
		DashboardShortCut = { fg = p.magenta_bright },
		AlphaHeader = { fg = p.blue_bright },
		AlphaFooter = { fg = comment, italic = true },
		AlphaButtons = { fg = p.white_bright },
		AlphaShortcut = { fg = p.magenta_bright },
		SnacksDashboardHeader = { fg = p.blue_bright },
		SnacksDashboardFooter = { fg = comment, italic = true },
		SnacksDashboardDesc = { fg = p.white_bright },
		SnacksDashboardIcon = { fg = p.cyan_bright },
		SnacksDashboardKey = { fg = p.magenta_bright },

		-- ── diffview.nvim ───────────────────────────────────────────────
		DiffviewDiffAdd = { bg = p.diff_add_bg },
		DiffviewDiffChange = { bg = p.diff_change_bg },
		DiffviewDiffDelete = { fg = p.border, bg = p.diff_delete_bg },
		DiffviewDiffText = { bg = p.diff_text_bg },
		DiffviewFilePanelTitle = { fg = p.blue_bright, bold = true },
		DiffviewFilePanelCounter = { fg = p.magenta_bright },
		DiffviewFilePanelFileName = { fg = fg },

		-- ── bufferline ──────────────────────────────────────────────────
		BufferLineFill = { bg = transparent and p.none or p.bg_dark },
		BufferLineBackground = { fg = p.border, bg = p.bg_secondary },
		BufferLineBufferSelected = { fg = p.white_bright, bg = bg, bold = true },
		BufferLineBufferVisible = { fg = p.white_dark, bg = p.bg_secondary },
		BufferLineSeparator = { fg = p.bg_dark, bg = p.bg_secondary },
		BufferLineSeparatorSelected = { fg = p.bg_dark, bg = bg },
		BufferLineIndicatorSelected = { fg = p.blue_bright, bg = bg },
		BufferLineModified = { fg = p.yellow_bright, bg = p.bg_secondary },
		BufferLineModifiedSelected = { fg = p.yellow_bright, bg = bg },

		-- ── mini.nvim (common modules) ──────────────────────────────────
		MiniStatuslineModeNormal = { fg = p.bg_primary, bg = p.blue_bright, bold = true },
		MiniStatuslineModeInsert = { fg = p.bg_primary, bg = p.green_bright, bold = true },
		MiniStatuslineModeVisual = { fg = p.bg_primary, bg = p.magenta_bright, bold = true },
		MiniStatuslineModeReplace = { fg = p.bg_primary, bg = p.red_bright, bold = true },
		MiniStatuslineModeCommand = { fg = p.bg_primary, bg = p.yellow_bright, bold = true },
		MiniStatuslineInactive = { fg = p.border, bg = p.bg_secondary },
		MiniPickMatchCurrent = { bg = selection },
		MiniPickMatchRanges = { fg = p.yellow_bright, bold = true },
		MiniPickPrompt = { fg = p.cyan_bright },
		MiniFilesTitle = { link = "FloatTitle" },
		MiniFilesTitleFocused = { fg = p.blue_bright, bold = true },
		MiniDiffSignAdd = { fg = p.green_bright },
		MiniDiffSignChange = { fg = p.yellow_bright },
		MiniDiffSignDelete = { fg = p.red_bright },
		MiniCursorword = { bg = p.bg_highlight },
		MiniJump = { fg = p.bg_primary, bg = p.magenta_bright },

		-- ── fugitive ────────────────────────────────────────────────────
		fugitiveHeader = { fg = p.blue_bright, bold = true },
		fugitiveStagedHeading = { fg = p.green_bright, bold = true },
		fugitiveUnstagedHeading = { fg = p.yellow_bright, bold = true },
		fugitiveUntrackedHeading = { fg = p.magenta_bright, bold = true },

		-- ── health ──────────────────────────────────────────────────────
		healthSuccess = { fg = p.bg_primary, bg = p.green_bright },
		healthError = { fg = error_fg },
		healthWarning = { fg = warning_fg },
	}

	return hl
end

--- Apply the colorscheme. Called from colors/lock-wood.lua.
function M.load()
	local opts = M.options
	-- Legacy: honour vim.g.lock-wood_opts when setup() was never called.
	if not M._setup_called and vim.g.lock - wood_opts then
		opts = vim.tbl_deep_extend("force", vim.deepcopy(defaults), vim.g.lock - wood_opts)
	end

	if vim.g.colors_name then
		vim.cmd("hi clear")
	end
	vim.o.termguicolors = true
	vim.o.background = "dark"
	vim.g.colors_name = "lock-wood"

	local p = require("lock-wood.palette")
	local hl = build_highlights(p, opts)

	if type(opts.overrides) == "function" then
		opts.overrides(hl, p)
	elseif type(opts.overrides) == "table" then
		hl = vim.tbl_deep_extend("force", hl, opts.overrides)
	end

	for group, spec in pairs(hl) do
		vim.api.nvim_set_hl(0, group, spec)
	end

	if opts.terminal_colors then
		vim.g.terminal_color_0 = p.black_dark
		vim.g.terminal_color_1 = p.red_dark
		vim.g.terminal_color_2 = p.green_dark
		vim.g.terminal_color_3 = p.yellow_dark
		vim.g.terminal_color_4 = p.blue_dark
		vim.g.terminal_color_5 = p.magenta_dark
		vim.g.terminal_color_6 = p.cyan_dark
		vim.g.terminal_color_7 = p.white_dark
		vim.g.terminal_color_8 = p.black_bright
		vim.g.terminal_color_9 = p.red_bright
		vim.g.terminal_color_10 = p.green_bright
		vim.g.terminal_color_11 = p.yellow_bright
		vim.g.terminal_color_12 = p.blue_bright
		vim.g.terminal_color_13 = p.magenta_bright
		vim.g.terminal_color_14 = p.cyan_bright
		vim.g.terminal_color_15 = p.white_bright
	end
end

return M
