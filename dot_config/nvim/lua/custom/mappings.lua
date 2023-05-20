---@type MappingsTable
local M = {}
local opts = { noremap = true, silent = true }
M.general = {
    n = {
        ["<leader>nh"] = { ":nohl<CR>", "nohl", opts },
        ["x"] = { '"_x', "", opts },
        ["<leader>+"] = { "<C-a>", "", opts },
        ["<leader>-"] = { "<C-x>", "", opts },
        ["<leader>sv"] = { "<C-w>s", "split window vertically", opts },
        ["<leader>sh"] = { "<C-w>v", "split window horizontally", opts },
        ["<leader>se"] = { "<C-w>=", "make split windows even width", opts },
        ["<leader>sx"] = { ":close<CR>", "close current split window", opts },
        ["<leader>to"] = { ":tabnew<CR>", "open new tab", opts },
        ["<leader>tx"] = { ":tabclose<CR>", "close current tab", opts },
        ["<leader>tp"] = { ":tabn<CR>", "go to next tab", opts },
        ["<leader>tn"] = { ":tabp<CR>", "go to previous tab", opts },
        ["<leader>sm"] = { ":MaximizerToggle<CR>", "vim-maximizer", opts },
        ["<leader>e"] = { ":NvimTreeToggle<CR>", "nvim-tree", opts },
        ["<leader>f"] = { ":NvimTreeFindFile<CR>", "nvim-tree", opts },
        ["<leader>ff"] = { "<cmd>Telescope find_files<cr>", "telescope", opts },
        ["<leader>fs"] = { "<cmd>Telescope live_grep<cr>", "telescope", opts },
        ["<leader>fc"] = { "<cmd>Telescope grep_string<cr>", "telescope", opts },
        ["<leader>fb"] = { "<cmd>Telescope buffers<cr>", "telescope", opts },
        ["<leader>fh"] = { "<cmd>Telescope help_tags<cr>", "telescope", opts },
        ["<leader>ps"] = { ":PackerSync<CR>", "Packer", opts },
        ["<leader>ls"] = { ":LspStop<CR>", "LSP", opts },
        ["<leader>lo"] = { ":LspStart<CR>", "LSP", opts },
    },

    x = {
        ["J"] = { ":move '>+1<CR>gv-gv", "Move text up", opts },
        ["K"] = { ":move '<-2<CR>gv-gv", "Move text down", opts },
        ["<A-j>"] = { ":move '>+1<CR>gv-gv", "Move text up", opts },
        ["<A-k>"] = { ":move '<-2<CR>gv-gv", "Move text down", opts },
    },

    i = {
        ["<C-j>"] = { 'copilot#Accept("<CR>")', "Copilot accept", { silent = true, expr = true } },
    }
}

return M
