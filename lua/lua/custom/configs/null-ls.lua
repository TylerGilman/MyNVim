local null_ls = require("null-ls")

-- Custom templ formatter
local templ_format = {
    method = null_ls.methods.FORMATTING,
    filetypes = { "templ" },
    generator = null_ls.generator({
        command = "templ",
        args = { "fmt", "$FILENAME" },
        to_stdin = true,
    }),
}

local opts = {
  debug = true,
  sources = {
    null_ls.builtins.formatting.clang_format,
    null_ls.builtins.diagnostics.mypy,
    null_ls.builtins.formatting.black,
    null_ls.builtins.formatting.gofumpt,
    null_ls.builtins.formatting.goimports_reviser,
    -- Add the custom templ formatter
    templ_format,
  },
  on_attach = function(client, bufnr)
    if client.supports_method("textDocument/formatting") then
      local augroup = vim.api.nvim_create_augroup("LspFormatting", {})
      vim.api.nvim_clear_autocmds({ group = augroup, buffer = bufnr })
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
