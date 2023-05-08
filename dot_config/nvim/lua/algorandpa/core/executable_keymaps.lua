vim.g.mapleader = " "
local keymap = vim.keymap

keymap.set("n", "<leader>nh", ":nohl<CR>")
keymap.set("n", "x", '"_x')
keymap.set("n", "<leader>+", "<C-a>")
keymap.set("n", "<leader>-", "<C-x>")

-- split windows
keymap.set("n", "<leader>sv", "<C-w>s")        -- split window vertically
keymap.set("n", "<leader>sh", "<C-w>v")        -- split window horizontally
keymap.set("n", "<leader>se", "<C-w>=")        -- make split windows even width
keymap.set("n", "<leader>sx", ":close<CR>")    -- close current split window

keymap.set("n", "<leader>to", ":tabnew<CR>")   -- open new tab
keymap.set("n", "<leader>tx", ":tabclose<CR>") -- close curent tab
keymap.set("n", "<leader>tp", ":tabn<CR>")     -- go to next tab
keymap.set("n", "<leader>tn", ":tabp<CR>")     -- go to previous tab

-- plugin keymaps
-- vim-maximizer
keymap.set("n", "<leader>sm", ":MaximizerToggle<CR>")

-- nvim-tree
keymap.set("n", "<leader>e", ":NvimTreeToggle<CR>")
keymap.set("n", "<leader>f", ":NvimTreeFindFile<CR>")

-- telescope
keymap.set("n", "<leader>ff", "<cmd>Telescope find_files<cr>")
keymap.set("n", "<leader>fs", "<cmd>Telescope live_grep<cr>")
keymap.set("n", "<leader>fc", "<cmd>Telescope grep_string<cr>")
keymap.set("n", "<leader>fb", "<cmd>Telescope buffers<cr>")
keymap.set("n", "<leader>fh", "<cmd>Telescope help_tags<cr>")

-- line movement
keymap.set("n", "<A-j>", ":m ,-2<CR>==")

-- Packer
keymap.set("n", "<leader>ps", ":PackerSync<CR>")

-- LSP
keymap.set("n", "<leader>ls", ":LspStop<CR>")
keymap.set("n", "<leader>lo", ":LspStart<CR>")

-- Copilot
vim.api.nvim_set_keymap("i", "<C-j>", 'copilot#Accept("<CR>")', { silent = true, expr = true })

--  ChatGPT
keymap.set("n", "<leader>cc", ":ChatGPT<CR>")

-- Key mappings for completion navigation and confirmation
vim.api.nvim_set_keymap('i', '<CR>', 'coc#pum#visible() ? coc#pum#confirm() : "\\<CR>"',
    { expr = true, noremap = true, silent = true })
vim.api.nvim_set_keymap('i', '<silent><expr> <CR>', 'coc#pum#visible() ? coc#_select_confirm() : "\\<C-g>u\\<CR>"',
    { expr = true, noremap = true, silent = true })
vim.api.nvim_set_keymap('i', '<silent><expr> <CR>',
    'coc#pumvisible() ? coc#_select_confirm() : "\\<C-g>u\\<CR>\\<C-r>=coc#on_enter()\\<CR>"',
    { expr = true, noremap = true, silent = true })
vim.api.nvim_set_keymap('i', '<silent><expr> <CR>',
    'coc#pumvisible() and coc#pum#info()["index"] != -1 ? coc#pum#confirm() : "\\<C-g>u\\<CR>"',
    { expr = true, noremap = true, silent = true })
