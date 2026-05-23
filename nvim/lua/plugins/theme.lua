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

	-- 2. LazyVim'e varsayılan temanın artık Everforest olduğunu söyle
	{
		"LazyVim/LazyVim",
		opts = {
			colorscheme = "everforest",
		},
	},

	{
		"LazyVim/LazyVim",
		opts = {
			colorscheme = "sunset-drive",
		},
	},
}
