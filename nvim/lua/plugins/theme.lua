return {
	-- 1. Everforest temasını indir ve arka plan ayarını yap
	{
		"sainnhe/everforest",
		lazy = false,
		priority = 1000,
		config = function()
			-- Arka planı 'hard' olarak ayarlar
			vim.g.everforest_background = "hard"
		end,
	},

	{
		"LazyVim/LazyVim",
		opts = {
			colorscheme = "sunset-drive",
		},
	},
}
