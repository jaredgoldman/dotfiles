local ensure_packer = function()
    local fn = vim.fn
    local install_path = fn.stdpath("data") .. "/site/pack/packer/start/packer.nvim"
    if fn.empty(fn.glob(install_path)) > 0 then
        fn.system({ "git", "clone", "--depth", "1", "https://github.com/wbthomason/packer.nvim", install_path })
        vim.cmd([[packadd packer.nvim]])
        return true
    end
    return false
end

local packer_bootstrap = ensure_packer()

return require("packer").startup(function(use)
    use("wbthomason/packer.nvim")
    use("folke/tokyonight.nvim")
    -- $tmux & split window view navigation
    use("christoomey/vim-tmux-navigator")
    use("szw/vim-maximizer")
    -- Multi-line editing
    use("mg979/vim-visual-multi")
    -- Essential plugins
    use("tpope/vim-surround")
    use("vim-scripts/ReplaceWithRegister")
    -- Commenting
    use("numToStr/Comment.nvim") -- lua
    use("nvim-lua/plenary.nvim")
    -- File explorer
    use {
        'kyazdani42/nvim-tree.lua',
        requires = { 'kyazdani42/nvim-web-devicons' },
        config = [[require('algorandpa.plugins.nvim-tree')]],
    }
    -- Statusline
    use("nvim-lualine/lualine.nvim")
    -- Fuzzy finding
    use({ "nvim-telescope/telescope-fzf-native.nvim", run = "make" })
    use({ "nvim-telescope/telescope.nvim", branch = "0.1.x" })
    -- CoPilot
    use({ "github/copilot.vim" })
    -- Autoclose tags
    use({ "alvan/vim-closetag" })
    -- Prettier
    use { 'prettier/vim-prettier', run = 'yarn install' }
    -- Git conflicts
    use { 'akinsho/git-conflict.nvim', tag = "*", config = function()
        require('git-conflict').setup()
    end }
    -- Autopairs
    use {
        "windwp/nvim-autopairs",
        config = function() require("nvim-autopairs").setup {} end
    }
    use { 'leafOfTree/vim-svelte-plugin' }
    -- chatGPT
    use({
        "jackMort/ChatGPT.nvim",
        config = function()
            require("chatgpt").setup()
        end,
        requires = {
            "MunifTanjim/nui.nvim",
            "nvim-lua/plenary.nvim",
            "nvim-telescope/telescope.nvim"
        }
    })
    -- COC
    use { 'neoclide/coc.nvim', branch = 'release' }
    -- LSP Zero
    use({
        "VonHeikemen/lsp-zero.nvim",
        requires = {
            -- LSP Support
            { "neovim/nvim-lspconfig" },
            { "williamboman/mason.nvim" },
            { "williamboman/mason-lspconfig.nvim" },

            -- Autocompletion
            { "hrsh7th/nvim-cmp" },
            { "hrsh7th/cmp-buffer" },
            { "hrsh7th/cmp-path" },
            { "saadparwaiz1/cmp_luasnip" },
            { "hrsh7th/cmp-nvim-lsp" },
            { "hrsh7th/cmp-nvim-lua" },

            -- Snippets
            { "L3MON4D3/LuaSnip" },
            { "rafamadriz/friendly-snippets" },
            { "https://github.com/ctrlpvim/ctrlp.vim.git" },
            { "junegunn/fzf" },
            { "saadparwaiz1/cmp_luasnip" },
        },
    })

    if packer_bootstrap then
        require("packer").sync()
    end
end)
