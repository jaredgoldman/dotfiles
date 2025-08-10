require("nvim-treesitter.configs").setup({
	ensure_installed = {
		"svelte",
		"javascript",
		"typescript",
		"tsx",
		"html",
		"css",
		"json",
		"lua",
		"python",
	},
	highlight = {
		enable = true,
		additional_vim_regex_highlighting = false,
	},
	indent = {
		enable = true,
	},
	autotag = {
		enable = true,
	},
})

-- Enable update on insert
vim.lsp.handlers["textDocument/publishDiagnostics"] = vim.lsp.with(vim.lsp.diagnostic.on_publish_diagnostics, {
	underline = true,
	virtual_text = {
		spacing = 5,
		min = vim.diagnostic.severity.WARN, -- Updated from severity_limit
	},
	update_in_insert = true,
})
-- severity_limit is deprecated, use {min = severity} See vim.diagnostic.severity instead. :help deprecated Feature will be removed in Nvim 0.11
