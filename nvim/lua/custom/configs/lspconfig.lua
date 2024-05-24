local base = require("plugins.configs.lspconfig")
local capabilities = base.capabilities
local lspconfig = require("lspconfig")
local util = require("lspconfig.util")

local servers = {"clangd", "pyright", "htmx", "gopls", "html-lsp", "css-lsp", "tailwindcss-language-server", "templ" }


local on_attach = function(_, _)
  vim.filetype.add({ extension = { templ = "templ" } })
  vim.keymap.set('n', '<leader>nn', vim.lsp.buf.rename, {})
  vim.keymap.set('n', '<leader>ca', vim.lsp.buf.code_action, {})
  vim.keymap.set('n', 'gd', vim.lsp.buf.definition, {})
  vim.keymap.set('n', 'gi', vim.lsp.buf.implementation, {})
  vim.keymap.set('n', 'gr', require('telescope.builtin').lsp_references, {})
  vim.keymap.set('n', 'K', vim.lsp.buf.hover, {})
end

-- Setup each server
for _, lsp in ipairs(servers) do
  lspconfig[lsp].setup {
    on_attach = on_attach,
    capabilities = capabilities,
  }
end
-- Make sure we have a tree-sitter grammar for the language
local treesitter_parser_config = require "nvim-treesitter.parsers".get_parser_configs()
treesitter_parser_config.templ = treesitter_parser_config.templ or {
  install_info = {
    url = "https://github.com/vrischmann/tree-sitter-templ.git",
    files = { "src/parser.c", "src/scanner.c" },
    branch = "master",
  },
}

vim.treesitter.language.register('templ', 'templ')

-- Register the LSP as a config
local configs = require 'lspconfig.configs'
if not configs.templ then
  configs.templ = {
    default_config = {
      cmd = { "templ", "lsp" },
      filetypes = { 'templ' },
      root_dir = require "lspconfig.util".root_pattern("go.mod", ".git"),
      settings = {},
    },
  }
end

-- Separate configuration for gopls with additional settings
lspconfig.gopls.setup {
  on_attach = on_attach,
  capabilities = capabilities,
  cmd = {"gopls"},
  filetypes = {"go", "gomod", "gowork", "templ"},
  root_dir = util.root_pattern("go.work", "go.mod", ".git"),
  settings = {
    gopls = {
      completeUnimported = true,
      usePlaceholders = true,
      analyses = {
        unusedparams = true,
      },
    },
  },
}

lspconfig.html.setup({
    on_attach = on_attach,
    capabilities = capabilities,
    filetypes = { "html", "templ" },
})
