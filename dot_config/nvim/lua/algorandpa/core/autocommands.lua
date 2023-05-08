-- Automatically run PrettierAsync
function format_js()
    vim.cmd('PrettierAsync')
end

vim.cmd([[
    augroup auto_commands
      autocmd!
      autocmd BufWritePost *.js,*.ts,*.svelte lua format_js()
    augroup END
]])
