return {
  -- Ensure prettier is installed
  {
    "mason-org/mason.nvim",
    opts = function(_, opts)
      opts.ensure_installed = opts.ensure_installed or {}
      vim.list_extend(opts.ensure_installed, { "prettier" })
    end,
  },

  -- Configure conform.nvim to use prettier and respect project configs
  {
    "stevearc/conform.nvim",
    opts = {
      formatters_by_ft = {
        javascript = { "prettier" },
        typescript = { "prettier" },
        javascriptreact = { "prettier" },
        typescriptreact = { "prettier" },
        vue = { "prettier" },
        css = { "prettier" },
        scss = { "prettier" },
        less = { "prettier" },
        html = { "prettier" },
        json = { "prettier" },
        jsonc = { "prettier" },
        yaml = { "prettier" },
        markdown = { "prettier" },
        graphql = { "prettier" },
        handlebars = { "prettier" },
      },
      formatters = {
        prettier = {
          -- Prettier will automatically look for config files in this order:
          -- - .prettierrc (JSON/YAML)
          -- - .prettierrc.json / .prettierrc.yml / .prettierrc.yaml
          -- - .prettierrc.js / .prettierrc.cjs / prettier.config.js / prettier.config.cjs
          -- - package.json (in "prettier" key)
          -- This ensures project-specific configs are always respected
          prepend_args = function(self, ctx)
            -- Only use --config-precedence if no local config exists
            -- This ensures we respect any prettier config files in the project
            return { "--config-precedence", "prefer-file" }
          end,
        },
      },
    },
  },
}
