local actions = require("telescope.actions")

require("telescope").setup({
	defaults = {
		-- Default configuration for telescope goes here:
		-- config_key = value,
		mappings = {
			i = {
				["<esc>"] = actions.close,
				["<C-u>"] = false,
			},
		},
	},
})

