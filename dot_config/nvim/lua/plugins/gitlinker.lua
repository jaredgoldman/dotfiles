-- lua/plugins/gitlinker.lua
return {
  "linrongbin16/gitlinker.nvim",
  keys = {
    { "<leader>gy", "<cmd>GitLink<cr>",  mode = { "n", "v" }, desc = "Copy git link" },
    { "<leader>gY", "<cmd>GitLink!<cr>", mode = { "n", "v" }, desc = "Open git link" },
  },
  opts = {},
}
