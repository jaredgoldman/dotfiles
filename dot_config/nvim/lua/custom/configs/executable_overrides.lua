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
    "c",
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
}

M.mason = {
  ensure_installed = {
    -- lua stuff
    "lua-language-server",
    "stylua",

    -- web dev stuff
    "css-lsp",
    "html-lsp",
    "typescript-language-server",
    "deno",
    "prettier",
    "intelephense",
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
