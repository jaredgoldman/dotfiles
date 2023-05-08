local opt = vim.opt
local api = vim.api
local g = vim.g
local cmd = vim.cmd

-- line numbers
opt.number = true

-- tabs & indentation
opt.tabstop = 4
opt.shiftwidth = 4
opt.expandtab = true
opt.autoindent = true
opt.softtabstop = 2

-- lne wrapping
opt.wrap = false

-- search settings
opt.ignorecase = true
opt.smartcase = true

-- cursor line
opt.cursorline = true

-- apparance
opt.termguicolors = true
opt.background = "dark"
opt.signcolumn = "yes"

-- backspace
opt.backspace = "indent,eol,start"

-- clipboard
opt.clipboard:append("unnamedplus")
api.nvim_set_option("clipboard", "unnamedplus")

-- split windows
opt.splitright = true
opt.splitbelow = true

opt.iskeyword:append("-")

opt.number = true
opt.titlestring = [[%f %h%m%r%w - %{v:progname} %{luaeval('current_tab()')}]]
opt.signcolumn = 'yes'

-- Show trailing whitespace
api.nvim_set_option("list", true)
api.nvim_set_option("listchars", "eol:$,nbsp:_,tab:>-,trail:~,extends:>,precedes:<")

-- Copilot
g.copilot_no_tab_map = true

-- remove whitespace on save
api.nvim_create_autocmd({ "BufWritePre" }, {
    pattern = { "*" },
    command = [[if &filetype !~# 'lsp' | %s/\s\+$//e | endif]],
})

-- COC
-- Enable tab scrolling in Coc.nvim
cmd([[
  inoremap <expr> <tab> pumvisible() ? "\<c-n>" : "\<tab>"
  inoremap <expr> <s-tab> pumvisible() ? "\<c-p>" : "\<s-tab>"
]])
