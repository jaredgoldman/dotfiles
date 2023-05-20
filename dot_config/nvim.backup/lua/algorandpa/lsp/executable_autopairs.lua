local npairs = require('nvim-autopairs')

npairs.setup({
    check_ts = true,
    ts_config = {
        lua = { 'string' },
        javascript = { 'template_string' },
        java = false,
    },
})
