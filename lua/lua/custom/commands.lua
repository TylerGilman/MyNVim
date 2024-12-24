vim.api.nvim_create_user_command('ToggleSyntax', function()
    if vim.g.syntax_on then
        vim.cmd('syntax off')
        vim.cmd('TSDisable highlight')
        print('Syntax highlighting disabled')
    else
        vim.cmd('syntax on')
        vim.cmd('TSEnable highlight')
        print('Syntax highlighting enabled')
    end
    vim.g.syntax_on = not vim.g.syntax_on
end, {})
