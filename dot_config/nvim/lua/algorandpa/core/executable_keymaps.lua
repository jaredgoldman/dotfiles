vim.g.mapleader = " "
local keymap = vim.keymap
local opts = { noremap = true, silent = true }

keymap.set("n", "<leader>nh", ":nohl<CR>", opts)
keymap.set("n", "x", '"_x', opts)
keymap.set("n", "<leader>+", "<C-a>", opts)
keymap.set("n", "<leader>-", "<C-x>", opts)

-- split windows
keymap.set("n", "<leader>sv", "<C-w>s", opts)        -- split window vertically
keymap.set("n", "<leader>sh", "<C-w>v", opts)        -- split window horizontally
keymap.set("n", "<leader>se", "<C-w>=", opts)        -- make split windows even width
keymap.set("n", "<leader>sx", ":close<CR>", opts)    -- close current split window

keymap.set("n", "<leader>to", ":tabnew<CR>", opts)   -- open new tab
keymap.set("n", "<leader>tx", ":tabclose<CR>", opts) -- close curent tab
keymap.set("n", "<leader>tp", ":tabn<CR>", opts)     -- go to next tab
keymap.set("n", "<leader>tn", ":tabp<CR>", opts)     -- go to previous tab

-- plugin keymaps
-- vim-maximizer
keymap.set("n", "<leader>sm", ":MaximizerToggle<CR>", opts)

-- nvim-tree
keymap.set("n", "<leader>e", ":NvimTreeToggle<CR>", opts)
keymap.set("n", "<leader>f", ":NvimTreeFindFile<CR>", opts)

-- telescope
keymap.set("n", "<leader>ff", "<cmd>Telescope find_files<cr>", opts)
keymap.set("n", "<leader>fs", "<cmd>Telescope live_grep<cr>", opts)
keymap.set("n", "<leader>fc", "<cmd>Telescope grep_string<cr>", opts)
keymap.set("n", "<leader>fb", "<cmd>Telescope buffers<cr>", opts)
keymap.set("n", "<leader>fh", "<cmd>Telescope help_tags<cr>", opts)
-- line movement Visual Block --
-- Move text up and down
keymap.set("x", "J", ":move '>+1<CR>gv-gv", opts)
keymap.set("x", "K", ":move '<-2<CR>gv-gv", opts)
keymap.set("x", "<A-j>", ":move '>+1<CR>gv-gv", opts)
keymap.set("x", "<A-k>", ":move '<-2<CR>gv-gv", opts)

-- Packer
keymap.set("n", "<leader>ps", ":PackerSync<CR>", opts)

-- LSP
keymap.set("n", "<leader>ls", ":LspStop<CR>", opts)
keymap.set("n", "<leader>lo", ":LspStart<CR>", opts)

-- Copilo
vim.api.nvim_set_keymap("i", "<C-j>", 'copilot#Accept("<CR>")', { silent = true, expr = true })
