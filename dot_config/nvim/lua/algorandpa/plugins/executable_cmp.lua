local cmp = require('cmp')
local cmp_lsp = require('cmp_nvim_lsp')

local function should_enable_cmp()
    -- Get the current file type
    local file_type = vim.api.nvim_buf_get_option(0, 'filetype')

    -- Define the file types where cmp should be disabled
    local disabled_file_types = { 'svelte' }

    -- Check if the current file type is in the disabled list
    for _, ft in ipairs(disabled_file_types) do
        if ft == file_type then
            return false
        end
    end

    return true
end

cmp.setup({
    window = {
        documentation = cmp.config.window.bordered(),
    },
    mapping = {
        ["<CR>"] = cmp.mapping.confirm({ select = true }),
        ["<Tab>"] = cmp.mapping.select_next_item({ behavior = cmp.SelectBehavior.Insert }),
        ["<S-Tab>"] = cmp.mapping.select_prev_item({ behavior = cmp.SelectBehavior.Insert }),
    },
    sources = {
        { name = "path" },
        { name = "nvim_lsp" },
        {
            name = "buffer",
            keyword_length = 3,
            option = {
                get_bufnrs = function()
                    return vim.api.nvim_list_bufs()
                end,
            },
        },
        { name = "luasnip", keyword_length = 2 },
    },
})
