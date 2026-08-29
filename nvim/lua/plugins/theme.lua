return {
	-- 1. Install Everforest theme and configure background
	{
		"sainnhe/everforest",
		lazy = false,
		priority = 1000,
		config = function()
			-- Set background to 'hard'
			vim.g.everforest_background = "hard"
		end,
	},

	{
		"LazyVim/LazyVim",
		opts = {
			-- colorscheme = "sunset-drive",
			colorscheme = "hybrid",
		},
	},
}
