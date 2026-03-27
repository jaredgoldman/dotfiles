-- Filetypes where biome can be used as a formatter
local biome_fts = {
  "javascript",
  "typescript",
  "javascriptreact",
  "typescriptreact",
  "json",
  "jsonc",
  "css",
}

-- Filetypes that only prettier handles (biome doesn't support these)
local prettier_only_fts = {
  "vue",
  "scss",
  "less",
  "html",
  "yaml",
  "markdown",
  "graphql",
  "handlebars",
}

--- Check if biome config exists in the project root
---@param ctx table conform formatter context
---@return boolean
local function has_biome_config(ctx)
  local root = vim.fs.root(ctx.buf, { "biome.json", "biome.jsonc" })
  return root ~= nil
end

--- Build formatters_by_ft with biome priority for supported filetypes
local function build_formatters_by_ft()
  local formatters_by_ft = {}

  for _, ft in ipairs(biome_fts) do
    formatters_by_ft[ft] = { "biome", "prettier", stop_after_first = true }
  end

  for _, ft in ipairs(prettier_only_fts) do
    formatters_by_ft[ft] = { "prettier" }
  end

  return formatters_by_ft
end

return {
  {
    "mason-org/mason.nvim",
    opts = function(_, opts)
      opts.ensure_installed = opts.ensure_installed or {}
      vim.list_extend(opts.ensure_installed, { "prettier", "biome" })
    end,
  },

  {
    "stevearc/conform.nvim",
    opts = {
      formatters_by_ft = build_formatters_by_ft(),
      formatters = {
        biome = {
          condition = function(self, ctx)
            return has_biome_config(ctx)
          end,
        },
        prettier = {
          prepend_args = function(self, ctx)
            return { "--config-precedence", "prefer-file" }
          end,
        },
      },
    },
  },
}
