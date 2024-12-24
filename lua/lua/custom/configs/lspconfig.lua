local base = require("plugins.configs.lspconfig")
local capabilities = base.capabilities
local lspconfig = require("lspconfig")
local util = require("lspconfig.util")

local servers = {
    "clangd",
    "pyright",
    "html",
    "cssls",
    "tailwindcss",
    "templ",
    "sqlls"    -- Add SQL language server
}

-- Register 'templ' as a Go-related filetype
vim.filetype.add({ extension = { templ = "templ" } })
vim.treesitter.language.register('templ', 'go')

local on_attach = function(client, bufnr)
    local opts = { noremap = true, silent = true, buffer = bufnr }
    vim.keymap.set('n', '<leader>rn', vim.lsp.buf.rename, opts)
    vim.keymap.set('n', '<leader>ca', vim.lsp.buf.code_action, opts)
    vim.keymap.set('n', 'gd', vim.lsp.buf.definition, opts)
    vim.keymap.set('n', 'gi', vim.lsp.buf.implementation, opts)
    vim.keymap.set('n', 'gr', require('telescope.builtin').lsp_references, opts)
    vim.keymap.set('n', 'K', vim.lsp.buf.hover, opts)
end

-- Setup each server
for _, lsp in ipairs(servers) do
    lspconfig[lsp].setup {
        on_attach = on_attach,
        capabilities = capabilities,
    }
end

-- Setup null-ls
local null_ls = require("null-ls")
local null_opts = {
    debug = true,
    sources = {
        null_ls.builtins.formatting.clang_format,
        null_ls.builtins.diagnostics.mypy,
        null_ls.builtins.formatting.black,
        null_ls.builtins.formatting.gofumpt,
        null_ls.builtins.formatting.goimports_reviser,
        null_ls.builtins.formatting.templ,
    },
}

-- Make sure we have a tree-sitter grammar for the language
local treesitter_parser_config = require("nvim-treesitter.parsers").get_parser_configs()
treesitter_parser_config.templ = {
    install_info = {
        url = "https://github.com/vrischmann/tree-sitter-templ.git",
        files = { "src/parser.c", "src/scanner.c" },
        branch = "master",
    },
}

-- Register the templ LSP configuration
local configs = require('lspconfig.configs')
if not configs.templ then
    configs.templ = {
        default_config = {
            cmd = { "templ", "lsp" },
            filetypes = { 'templ' },
            root_dir = util.root_pattern("go.mod", ".git"),
            settings = {},
        },
    }
end

-- Setup HTML LSP with support for templ files
lspconfig.html.setup({
    on_attach = on_attach,
    capabilities = capabilities,
    filetypes = { "html", "templ" },
})

return null_opts
