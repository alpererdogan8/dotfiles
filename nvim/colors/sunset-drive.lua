-- Ghostty Dark — Neovim colorscheme
-- Kaynak: Ghostty terminal palette'inden uyarlanmıştır

vim.cmd("hi clear")
if vim.fn.exists("syntax_on") then
	vim.cmd("syntax reset")
end
vim.g.colors_name = "sunset-drive"
vim.o.termguicolors = true
vim.o.background = "dark"

local c = {
	bg = "#0f0f1a",
	bg_dim = "#0a0a13",
	bg_alt = "#1a1a2e",
	surface = "#252535",
	overlay = "#5c6675",
	muted = "#ffffff",
	subtle = "#8888a0",
	fg = "#ededfe",
	fg_dim = "#ededff",

	-- Normal palette
	black = "#3e3e4b",
	red = "#ff0063",
	green = "#00f992",
	yellow = "#ffe900",
	blue = "#00a4ff",
	magenta = "#ff57fd",
	cyan = "#00ffed",
	white = "#ededff",

	-- Bright palette
	br_black = "#ffffff",
	br_red = "#ff948b",
	br_green = "#00fcb9",
	br_yellow = "#ffff68",
	br_blue = "#3ea0ff",
	br_magenta = "#ff93ff",
	br_cyan = "#38ffff",
	br_white = "#f8f8ff",

	none = "NONE",
}

local function hl(group, opts)
	vim.api.nvim_set_hl(0, group, opts)
end

-- ─── Editor ──────────────────────────────────────────────────
hl("Normal", { fg = c.fg, bg = c.bg })
hl("NormalFloat", { fg = c.fg, bg = c.bg_alt })
hl("NormalNC", { fg = c.fg_dim, bg = c.bg })
hl("ColorColumn", { bg = c.bg_dim })
hl("Cursor", { fg = c.bg, bg = c.fg })
hl("CursorLine", { bg = c.bg_alt })
hl("CursorColumn", { bg = c.bg_alt })
hl("CursorLineNr", { fg = c.blue, bold = true })
hl("LineNr", { fg = c.overlay })
hl("SignColumn", { fg = c.overlay, bg = c.bg })
hl("VertSplit", { fg = c.overlay, bg = c.bg })
hl("WinSeparator", { fg = c.overlay, bg = c.bg })
hl("Folded", { fg = c.subtle, bg = c.bg_alt })
hl("FoldColumn", { fg = c.overlay, bg = c.bg })
hl("EndOfBuffer", { fg = c.bg_dim })
hl("Conceal", { fg = c.overlay })
hl("NonText", { fg = c.overlay })
hl("Whitespace", { fg = c.overlay })
hl("SpecialKey", { fg = c.overlay })
hl("MatchParen", { fg = c.cyan, underline = true, bold = true })
hl("Visual", { bg = c.surface })
hl("VisualNOS", { bg = c.surface })

-- ─── Statusline ───────────────────────────────────────────────
hl("StatusLine", { fg = c.fg, bg = c.surface })
hl("StatusLineNC", { fg = c.subtle, bg = c.bg_alt })
hl("TabLine", { fg = c.subtle, bg = c.surface })
hl("TabLineFill", { bg = c.bg_dim })
hl("TabLineSel", { fg = c.fg, bg = c.bg, bold = true })
hl("WinBar", { fg = c.subtle, bg = c.bg })
hl("WinBarNC", { fg = c.overlay, bg = c.bg })

-- ─── Popup / Search ───────────────────────────────────────────
hl("Pmenu", { fg = c.fg, bg = c.bg_alt })
hl("PmenuSel", { fg = c.bg, bg = c.blue })
hl("PmenuSbar", { bg = c.surface })
hl("PmenuThumb", { bg = c.overlay })
hl("FloatBorder", { fg = c.overlay, bg = c.bg_alt })
hl("FloatTitle", { fg = c.blue, bg = c.bg_alt, bold = true })
hl("Search", { fg = c.bg, bg = c.yellow })
hl("IncSearch", { fg = c.bg, bg = c.cyan })
hl("CurSearch", { fg = c.bg, bg = c.cyan, bold = true })
hl("Substitute", { fg = c.bg, bg = c.red })

-- ─── Messages ─────────────────────────────────────────────────
hl("ModeMsg", { fg = c.green, bold = true })
hl("MsgArea", { fg = c.fg })
hl("MoreMsg", { fg = c.cyan })
hl("Question", { fg = c.yellow })
hl("ErrorMsg", { fg = c.red, bold = true })
hl("WarningMsg", { fg = c.br_red })

-- ─── Diagnostics ──────────────────────────────────────────────
hl("DiagnosticError", { fg = c.red })
hl("DiagnosticWarn", { fg = c.br_red })
hl("DiagnosticInfo", { fg = c.blue })
hl("DiagnosticHint", { fg = c.cyan })
hl("DiagnosticOk", { fg = c.green })
hl("DiagnosticUnderlineError", { sp = c.red, undercurl = true })
hl("DiagnosticUnderlineWarn", { sp = c.br_red, undercurl = true })
hl("DiagnosticUnderlineInfo", { sp = c.blue, undercurl = true })
hl("DiagnosticUnderlineHint", { sp = c.cyan, undercurl = true })
hl("DiagnosticVirtualTextError", { fg = c.red, bg = c.bg_alt })
hl("DiagnosticVirtualTextWarn", { fg = c.br_red, bg = c.bg_alt })
hl("DiagnosticVirtualTextInfo", { fg = c.blue, bg = c.bg_alt })
hl("DiagnosticVirtualTextHint", { fg = c.cyan, bg = c.bg_alt })

-- ─── Syntax ───────────────────────────────────────────────────
hl("Comment", { fg = c.muted, italic = true })
hl("Constant", { fg = c.br_magenta })
hl("String", { fg = c.green })
hl("Character", { fg = c.br_green })
hl("Number", { fg = c.br_yellow })
hl("Float", { fg = c.br_yellow })
hl("Boolean", { fg = c.magenta })
hl("Identifier", { fg = c.fg })
hl("Function", { fg = c.blue })
hl("Statement", { fg = c.magenta })
hl("Conditional", { fg = c.magenta })
hl("Repeat", { fg = c.magenta })
hl("Label", { fg = c.cyan })
hl("Operator", { fg = c.cyan })
hl("Keyword", { fg = c.magenta, bold = true })
hl("Exception", { fg = c.red })
hl("PreProc", { fg = c.br_cyan })
hl("Include", { fg = c.br_cyan })
hl("Define", { fg = c.br_cyan })
hl("Macro", { fg = c.br_cyan })
hl("Type", { fg = c.yellow })
hl("StorageClass", { fg = c.yellow })
hl("Structure", { fg = c.yellow })
hl("Typedef", { fg = c.yellow })
hl("Special", { fg = c.br_cyan })
hl("SpecialChar", { fg = c.br_cyan })
hl("Delimiter", { fg = c.subtle })
hl("SpecialComment", { fg = c.subtle, italic = true })
hl("Debug", { fg = c.red })
hl("Underlined", { underline = true })
hl("Ignore", { fg = c.overlay })
hl("Error", { fg = c.red, bold = true })
hl("Todo", { fg = c.bg, bg = c.yellow, bold = true })

-- ─── Treesitter ───────────────────────────────────────────────
hl("@variable", { fg = c.fg })
hl("@variable.builtin", { fg = c.br_red })
hl("@variable.parameter", { fg = c.br_magenta })
hl("@variable.member", { fg = c.br_blue })
hl("@constant", { fg = c.br_magenta })
hl("@constant.builtin", { fg = c.magenta, bold = true })
hl("@constant.macro", { fg = c.br_cyan })
hl("@string", { fg = c.green })
hl("@string.escape", { fg = c.br_green })
hl("@string.special", { fg = c.br_cyan })
hl("@number", { fg = c.br_yellow })
hl("@float", { fg = c.br_yellow })
hl("@boolean", { fg = c.magenta })
hl("@function", { fg = c.blue })
hl("@function.builtin", { fg = c.br_blue })
hl("@function.call", { fg = c.blue })
hl("@function.macro", { fg = c.br_cyan })
hl("@function.method", { fg = c.blue })
hl("@function.method.call", { fg = c.br_blue })
hl("@constructor", { fg = c.yellow })
hl("@operator", { fg = c.cyan })
hl("@keyword", { fg = c.magenta, bold = true })
hl("@keyword.import", { fg = c.br_cyan })
hl("@keyword.return", { fg = c.red })
hl("@keyword.exception", { fg = c.red })
hl("@keyword.operator", { fg = c.cyan })
hl("@keyword.coroutine", { fg = c.magenta })
hl("@type", { fg = c.yellow })
hl("@type.builtin", { fg = c.yellow, bold = true })
hl("@type.definition", { fg = c.yellow })
hl("@attribute", { fg = c.br_cyan })
hl("@namespace", { fg = c.br_cyan })
hl("@module", { fg = c.br_cyan })
hl("@label", { fg = c.cyan })
hl("@comment", { fg = c.muted, italic = true })
hl("@comment.todo", { fg = c.bg, bg = c.yellow, bold = true })
hl("@comment.error", { fg = c.bg, bg = c.red, bold = true })
hl("@comment.warning", { fg = c.bg, bg = c.br_red, bold = true })
hl("@comment.note", { fg = c.bg, bg = c.blue, bold = true })
hl("@punctuation.delimiter", { fg = c.subtle })
hl("@punctuation.bracket", { fg = c.subtle })
hl("@punctuation.special", { fg = c.cyan })
hl("@markup.heading", { fg = c.blue, bold = true })
hl("@markup.strong", { bold = true })
hl("@markup.italic", { italic = true })
hl("@markup.link", { fg = c.br_blue, underline = true })
hl("@markup.raw", { fg = c.green })
hl("@tag", { fg = c.magenta })
hl("@tag.attribute", { fg = c.yellow })
hl("@tag.delimiter", { fg = c.subtle })
hl("@diff.plus", { fg = c.green })
hl("@diff.minus", { fg = c.red })
hl("@diff.delta", { fg = c.yellow })

-- ─── LSP ──────────────────────────────────────────────────────
hl("LspReferenceText", { bg = c.surface })
hl("LspReferenceRead", { bg = c.surface })
hl("LspReferenceWrite", { bg = c.surface, underline = true })
hl("LspInlayHint", { fg = c.overlay, italic = true })

-- ─── Git (Gitsigns) ───────────────────────────────────────────
hl("GitSignsAdd", { fg = c.green })
hl("GitSignsChange", { fg = c.yellow })
hl("GitSignsDelete", { fg = c.red })
hl("GitSignsAddNr", { fg = c.green })
hl("GitSignsChangeNr", { fg = c.yellow })
hl("GitSignsDeleteNr", { fg = c.red })
hl("GitSignsAddLn", { bg = c.bg_alt })
hl("GitSignsChangeLn", { bg = c.bg_alt })
hl("DiffAdd", { bg = "#0d2b1a" })
hl("DiffChange", { bg = "#1e1e00" })
hl("DiffDelete", { bg = "#2b0a12" })
hl("DiffText", { bg = "#333300" })

-- ─── Telescope ────────────────────────────────────────────────
hl("TelescopeNormal", { fg = c.fg, bg = c.bg_alt })
hl("TelescopeBorder", { fg = c.overlay, bg = c.bg_alt })
hl("TelescopePromptNormal", { fg = c.fg, bg = c.surface })
hl("TelescopePromptBorder", { fg = c.surface, bg = c.surface })
hl("TelescopePromptTitle", { fg = c.bg, bg = c.blue, bold = true })
hl("TelescopePreviewTitle", { fg = c.bg, bg = c.cyan, bold = true })
hl("TelescopeResultsTitle", { fg = c.bg, bg = c.magenta, bold = true })
hl("TelescopeSelection", { fg = c.fg, bg = c.surface })
hl("TelescopeSelectionCaret", { fg = c.cyan })
hl("TelescopeMatching", { fg = c.yellow, bold = true })

-- ─── NeoTree ──────────────────────────────────────────────────
hl("NeoTreeNormal", { fg = c.fg, bg = c.bg_dim })
hl("NeoTreeNormalNC", { fg = c.fg, bg = c.bg_dim })
hl("NeoTreeDirectoryName", { fg = c.blue })
hl("NeoTreeDirectoryIcon", { fg = c.blue })
hl("NeoTreeFileName", { fg = c.fg })
hl("NeoTreeGitAdded", { fg = c.green })
hl("NeoTreeGitModified", { fg = c.yellow })
hl("NeoTreeGitDeleted", { fg = c.red })

-- ─── Which-Key ────────────────────────────────────────────────
hl("WhichKey", { fg = c.cyan })
hl("WhichKeyGroup", { fg = c.blue })
hl("WhichKeyDesc", { fg = c.fg })
hl("WhichKeySeparator", { fg = c.overlay })
hl("WhichKeyFloat", { bg = c.bg_alt })
hl("WhichKeyBorder", { fg = c.overlay, bg = c.bg_alt })

-- ─── nvim-cmp ─────────────────────────────────────────────────
hl("CmpItemAbbr", { fg = c.fg })
hl("CmpItemAbbrMatch", { fg = c.yellow, bold = true })
hl("CmpItemAbbrMatchFuzzy", { fg = c.yellow })
hl("CmpItemKind", { fg = c.cyan })
hl("CmpItemMenu", { fg = c.subtle })

-- ─── Lualine (terminal colors referansı için) ─────────────────
-- Lualine'da theme = "auto" veya özel tablo kullanabilirsin.
-- Aşağıda lualine için renk tablosu export edilmiştir:
vim.g.ghostty_dark_colors = c
