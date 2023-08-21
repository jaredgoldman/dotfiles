local overrides = require "custom.configs.overrides"
---@type NvPluginSpec[]
local plugins = {

  {
    "neovim/nvim-lspconfig",
    dependencies = {
      -- format & linting
      {
        "jose-elias-alvarez/null-ls.nvim",
        config = function()
          require "custom.configs.null-ls"
        end,
      },
    },
    config = function()
      require "plugins.configs.lspconfig"
      require "custom.configs.lspconfig"
    end, -- Override to setup mason-lspconfig
  },

  {
    "williamboman/mason.nvim",
    opts = overrides.mason,
  },

  {
    "nvim-treesitter/nvim-treesitter",
    opts = overrides.treesitter,
  },

  {
    "nvim-tree/nvim-tree.lua",
    opts = overrides.nvimtree,
  },
  -- Install a plugin
  {
    "max397574/better-escape.nvim",
    event = "InsertEnter",
    config = function()
      require("better_escape").setup()
    end,
  },

  {
    "github/copilot.vim",
    lazy = false,
    enabled = false,
  },
  {
    "prettier/vim-prettier",
    run = "yarn install",
  },

  {
    "mattn/emmet-vim",
  },
  {
    "windwp/nvim-ts-autotag",
    lazy = false,
    config = function()
      require("nvim-ts-autotag").setup {
        filetypes = { "html", "javascript", "javascriptreact", "typescriptreact", "svelte", "vue" },
        enable_close_on_slash = false,
      }
    end,
  },
  { "akinsho/git-conflict.nvim", version = "*", config = true, lazy = false },
  { "f-person/git-blame.nvim", lazy = false },
  {"b0o/schemastore.nvim"}

}

return plugins
