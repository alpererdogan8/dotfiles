return {
	-- 1. Install Everforest theme and configure background
	-- {
	-- 	"sainnhe/everforest",
	-- 	lazy = false,
	-- 	priority = 1000,
	-- 	config = function()
	-- 		-- Set background to 'hard'
	-- 		vim.g.everforest_background = "hard"
	-- 	end,
	-- },

	{
		"rebelot/kanagawa.nvim",
		lazy = false,
		priority = 1000,
		opts = {
			theme = "wave", -- "wave", "dragon", or "lotus"
		},
		config = function(_, opts)
			require("kanagawa").setup(opts)
			vim.cmd("colorscheme kanagawa-wave")
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
