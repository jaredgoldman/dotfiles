vim.cmd("colorscheme tokyonight")

local status, _ = pcall(vim.cmd, ("colorscheme tokyonight"))
if not status then
    print("colorscheme not found")
    return
end
