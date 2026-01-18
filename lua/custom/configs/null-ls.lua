local augroup = vim.api.nvim_create_augroup("LspFormatting", {})
local null_ls = require("null-ls")

local opts = {
  sources = {
    null_ls.builtins.formatting.clang_format,
    -- mypy with dmypy daemon (matching Cursor settings)
    null_ls.builtins.diagnostics.mypy.with({
      extra_args = function()
        local cwd = vim.fn.getcwd()
        local dmypy_path = cwd .. "/env/bin/dmypy"
        -- Use dmypy if it exists in the project's venv
        if vim.fn.executable(dmypy_path) == 1 then
          return { "--dmypy", "--dmypy-executable", dmypy_path }
        end
        return {}
      end,
    }),
    null_ls.builtins.formatting.black,
    null_ls.builtins.formatting.gofumpt,
    null_ls.builtins.formatting.goimports_reviser,
  },
  on_attach = function(client, bufnr)
    if client.supports_method("textDocument/formatting") then
      vim.api.nvim_clear_autocmds({
        group = augroup,
        buffer = bufnr,
      })
      vim.api.nvim_create_autocmd("BufWritePre", {
        group = augroup,
        buffer = bufnr,
        callback = function()
          vim.lsp.buf.format({ bufnr = bufnr })
        end,
      })
    end
  end,
}

return opts
