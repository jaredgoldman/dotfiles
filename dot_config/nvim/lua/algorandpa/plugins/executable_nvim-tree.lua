local setup, nvimtree = pcall(require, "nvim-tree")
if not setup then
	return
end

vim.g.loaded = 1
vim.g.loaded_netrwPlugin = 1
vim.opt.termguicolors = true

vim.cmd([[ highlight NVimTreeIndentMarker guifg=#3FC5FF ]])
vim.cmd([[ set encoding=UTF-8]])

nvimtree.setup({
	update_focused_file = {
		enable = true,
		update_root = true,
	},
	actions = {
		open_file = {
			window_picker = {
				enable = false,
			},
		},
    use_system_clipboard = true,
	},
    view = {
        side = 'right'
    }
})
