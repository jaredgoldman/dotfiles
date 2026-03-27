-- ~/.config/nvim/lua/plugins/markdown-preview.lua
return {
  "iamcco/markdown-preview.nvim",
  build = "cd app && yarn install",
  ft = { "markdown" },
  config = function()
    vim.g.mkdp_preview_options = {
      mermaid = { theme = "default" },
    }
    vim.g.mkdp_auto_start = 0
    vim.g.mkdp_open_to_the_world = 0
    vim.g.mkdp_browser = "google-chrome" -- or firefox
  end,
}
