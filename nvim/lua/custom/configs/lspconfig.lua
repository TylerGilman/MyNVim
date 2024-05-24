local base = require("plugins.configs.lspconfig")
local capabilities = base.capabilities

local lspconfig = require("lspconfig")
local util = require("lspconfig.util")

local servers = {"clangd", "pyright", "htmx", "gopls", "html-lsp", "css-lsp", "tailwindcss-language-server", "templ"}

vim.filetype.add({ extension = { templ = "templ" } })

local on_attach = function(_, _)
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

-- Separate configuration for gopls with additional settings
lspconfig.gopls.setup {
  on_attach = on_attach,
  capabilities = capabilities,
  cmd = {"gopls"},
  filetypes = {"go", "gomod", "gowork", "gotmpl"},
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

