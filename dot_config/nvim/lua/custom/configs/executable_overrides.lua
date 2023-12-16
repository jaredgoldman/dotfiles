local M = {}

M.treesitter = {
  ensure_installed = {
    "vim",
    "lua",
    "css",
    "javascript",
    "html",
    "typescript",
    "tsx",
    "markdown",
    "markdown_inline",
    "php",
  },
  indent = {
    enable = true,
  },
  highlight = {
    enable = true,
  },
  -- autotag = {
  --   enable = true,
  -- },
  context_commentstring = {
    enable = true,
  },
}

M.mason = {
  ensure_installed = {
    -- lua stuff
    "lua-language-server",
    "stylua",

    -- web dev stuff
    "css-lsp",
    "html-lsp",
    "json-lsp",
    "typescript-language-server",
    "deno",
    "prettier",
    "intelephense",
    "tailwindcss",
    "lua",
    "prisma-language-server",
    "graphql",
  },
}

-- git support in nvimtree
M.nvimtree = {
  git = {
    enable = true,
  },

  renderer = {
    highlight_git = true,
    icons = {
      show = {
        git = true,
      },
    },
  },
}

return M
