-- load defaults (sets up lua_ls and base config)
require("nvchad.configs.lspconfig").defaults()

local nvlsp = require "nvchad.configs.lspconfig"

-- Add custom LSP keybindings via autocmd
vim.api.nvim_create_autocmd("LspAttach", {
  group = vim.api.nvim_create_augroup("UserLspConfig", {}),
  callback = function(ev)
    local opts = { buffer = ev.buf, silent = true }
    vim.keymap.set('n', 'gD', vim.lsp.buf.declaration, opts)
    vim.keymap.set('n', 'gd', vim.lsp.buf.definition, opts)
    vim.keymap.set('n', '<leader>gi', vim.lsp.buf.implementation, opts)
    vim.keymap.set('n', 'gr', require('telescope.builtin').lsp_references, opts)
    vim.keymap.set('n', 'K', vim.lsp.buf.hover, opts)
    vim.keymap.set('n', '<leader>rn', vim.lsp.buf.rename, opts)
    vim.keymap.set('n', '<leader>ca', vim.lsp.buf.code_action, opts)
  end,
})

-- Register 'templ' as a Go-related filetype
vim.filetype.add({ extension = { templ = "templ" } })

-- Servers with default config
local servers = { "html", "cssls", "tailwindcss", "templ", "eslint" }
for _, server in ipairs(servers) do
  vim.lsp.enable(server)
end

-- Pyright (matching Cursor/cursorpyright settings)
vim.lsp.config("pyright", {
  settings = {
    python = {
      analysis = {
        autoImportCompletions = false,
        autoSearchPaths = false,
        diagnosticMode = "openFilesOnly",
      },
    },
  },
})
vim.lsp.enable("pyright")

-- Rust Analyzer
vim.lsp.config("rust_analyzer", {
  settings = {
    ["rust-analyzer"] = {
      checkOnSave = {
        command = "clippy",
      },
    },
  },
})
vim.lsp.enable("rust_analyzer")

-- TypeScript/JavaScript
vim.lsp.config("ts_ls", {
  init_options = {
    preferences = {
      disableSuggestions = false,
    },
  },
})
vim.lsp.enable("ts_ls")

-- Ruff (fast Python linter/formatter) - works alongside pyright
vim.lsp.enable("ruff")

-- HTML with templ support
vim.lsp.config("html", {
  filetypes = { "html", "templ" },
})
vim.lsp.enable("html")

-- Clangd with extra options
vim.lsp.config("clangd", {
  cmd = {
    "clangd",
    "--background-index",
    "--clang-tidy",
    "--header-insertion=iwyu",
    "--completion-style=detailed",
    "--function-arg-placeholders",
    "--fallback-style=llvm",
  },
  init_options = {
    usePlaceholders = true,
    completeUnimported = true,
    clangdFileStatus = true,
  },
})
vim.lsp.enable("clangd")

-- Tree-sitter grammar for templ
local ok, parsers = pcall(require, "nvim-treesitter.parsers")
if ok then
  local treesitter_parser_config = parsers.get_parser_configs()
  treesitter_parser_config.templ = {
    install_info = {
      url = "https://github.com/vrischmann/tree-sitter-templ.git",
      files = { "src/parser.c", "src/scanner.c" },
      branch = "master",
    },
  }
end
