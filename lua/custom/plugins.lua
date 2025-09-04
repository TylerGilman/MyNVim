local plugins = {
  {
    "williamboman/mason.nvim",
    cmd = { "Mason", "MasonInstall", "MasonInstallAll", "MasonUpdate" },  -- Add this line
    opts = {
      ensure_installed = {
        "pyright",
        "clangd",
        "clang-format",
        "codelldb",
        "mypy",
        "ruff",
        "black",
        "debugpy",
        "golines",
        "goimports",
        "htmx-lsp",
        "css-lsp",
        "html-lsp",
        "tailwindcss-language-server",
        "templ",
      }
    },
    config = function(_, opts)
      require("mason").setup(opts)
      -- Create MasonInstallAll command
      vim.api.nvim_create_user_command("MasonInstallAll", function()
        vim.cmd("MasonInstall " .. table.concat(opts.ensure_installed, " "))
      end, {})
    end,
  },
  {
    'yacineMTB/dingllm.nvim',
    dependencies = { 'nvim-lua/plenary.nvim' },
    config = function()
      local system_prompt =
        'You should replace the code that you are sent, only following the comments. Do not talk at all. Only output valid code. Do not provide any backticks that surround the code. Never ever output backticks like this ```. Any comment that is asking you for something should be removed after you satisfy them. Other comments should left alone. Do not output backticks'
      local helpful_prompt = 'You are a helpful assistant. What I have sent are my notes so far.'
      local dingllm = require 'dingllm'


      local function handle_open_router_spec_data(data_stream)
        local success, json = pcall(vim.json.decode, data_stream)
        if success then
          if json.choices and json.choices[1] and json.choices[1].text then
            local content = json.choices[1].text
            if content then
              dingllm.write_string_at_cursor(content)
            end
          end
        else
          print("non json " .. data_stream)
        end
      end

      local function custom_make_openai_spec_curl_args(opts, prompt)
        local url = opts.url
        local api_key = opts.api_key_name and os.getenv(opts.api_key_name)
        local data = {
          prompt = prompt,
          model = opts.model,
          temperature = 0.7,
          stream = true,
        }
        local args = { '-N', '-X', 'POST', '-H', 'Content-Type: application/json', '-d', vim.json.encode(data) }
        if api_key then
          table.insert(args, '-H')
          table.insert(args, 'Authorization: Bearer ' .. api_key)
        end
        table.insert(args, url)
        return args
      end


      local function llama_405b_base()
        dingllm.invoke_llm_and_stream_into_editor({
          url = 'https://openrouter.ai/api/v1/chat/completions',
          model = 'meta-llama/llama-3.1-405b',
          api_key_name = 'OPEN_ROUTER_API_KEY',
          max_tokens = '128',
          replace = false,
        }, custom_make_openai_spec_curl_args, handle_open_router_spec_data)
      end

      local function groq_replace()
        dingllm.invoke_llm_and_stream_into_editor({
          url = 'https://api.groq.com/openai/v1/chat/completions',
          model = 'llama-3.1-70b-versatile',
          api_key_name = 'GROQ_API_KEY',
          system_prompt = system_prompt,
          replace = true,
        }, dingllm.make_openai_spec_curl_args, dingllm.handle_openai_spec_data)
      end

      local function groq_help()
        dingllm.invoke_llm_and_stream_into_editor({
          url = 'https://api.groq.com/openai/v1/chat/completions',
          model = 'llama-3.1-70b-versatile',
          api_key_name = 'GROQ_API_KEY',
          system_prompt = helpful_prompt,
          replace = false,
        }, dingllm.make_openai_spec_curl_args, dingllm.handle_openai_spec_data)
      end

      local function llama405b_replace()
        dingllm.invoke_llm_and_stream_into_editor({
          url = 'https://api.lambdalabs.com/v1/chat/completions',
          model = 'hermes-3-llama-3.1-405b-fp8',
          api_key_name = 'LAMBDA_API_KEY',
          system_prompt = system_prompt,
          replace = true,
        }, dingllm.make_openai_spec_curl_args, dingllm.handle_openai_spec_data)
      end

      local function llama405b_help()
        dingllm.invoke_llm_and_stream_into_editor({
          url = 'https://api.lambdalabs.com/v1/chat/completions',
          model = 'hermes-3-llama-3.1-405b-fp8',
          api_key_name = 'LAMBDA_API_KEY',
          system_prompt = helpful_prompt,
          replace = false,
        }, dingllm.make_openai_spec_curl_args, dingllm.handle_openai_spec_data)
      end

      local function anthropic_help()
        dingllm.invoke_llm_and_stream_into_editor({
          url = 'https://api.anthropic.com/v1/messages',
          model = 'claude-3-5-sonnet-20241022',
          api_key_name = 'ANTHROPIC_API_KEY',
          system_prompt = helpful_prompt,
          replace = false,
        }, dingllm.make_anthropic_spec_curl_args, dingllm.handle_anthropic_spec_data)
      end

      local function anthropic_replace()
        dingllm.invoke_llm_and_stream_into_editor({
          url = 'https://api.anthropic.com/v1/messages',
          model = 'claude-3-5-sonnet-20241022',
          api_key_name = 'ANTHROPIC_API_KEY',
          system_prompt = system_prompt,
          replace = true,
        }, dingllm.make_anthropic_spec_curl_args, dingllm.handle_anthropic_spec_data)
      end

      vim.keymap.set({ 'n', 'v' }, '<leader>k', groq_replace, { desc = 'llm groq' })
      vim.keymap.set({ 'n', 'v' }, '<leader>K', groq_help, { desc = 'llm groq_help' })
      vim.keymap.set({ 'n', 'v' }, '<leader>L', llama405b_help, { desc = 'llm llama405b_help' })
      vim.keymap.set({ 'n', 'v' }, '<leader>l', llama405b_replace, { desc = 'llm llama405b_replace' })
      vim.keymap.set({ 'n', 'v' }, '<leader>I', anthropic_help, { desc = 'llm anthropic_help' })
      vim.keymap.set({ 'n', 'v' }, '<leader>i', anthropic_replace, { desc = 'llm anthropic' })
      vim.keymap.set({ 'n', 'v' }, '<leader>o', llama_405b_base, { desc = 'llama base' })
    end,
  },
  {
    "nvim-neotest/nvim-nio"  -- Add this dependency
  },
  {
    "mfussenegger/nvim-dap",
    lazy = false,
    config = function()
      vim.keymap.set("n", "<leader>db", "<cmd>DapToggleBreakpoint<CR>", { desc = "Toggle breakpoint" })
      vim.keymap.set("n", "<leader>dr", "<cmd>DapContinue<CR>", { desc = "Continue debugger" })
    end,
  },
  {
    "theprimeagen/harpoon",
    branch = "harpoon2",
    dependencies = { "nvim-lua/plenary.nvim" },
    config = function()
      require("harpoon"):setup()
    end,
    keys = {
      { "<leader>A", function() require("harpoon"):list():append() end, desc = "harpoon file", },
      { "<leader>a", function() local harpoon = require("harpoon") harpoon.ui:toggle_quick_menu(harpoon:list()) end, desc = "harpoon quick menu", },
      { "<leader>1", function() require("harpoon"):list():select(1) end, desc = "harpoon to file 1", },
      { "<leader>2", function() require("harpoon"):list():select(2) end, desc = "harpoon to file 2", },
      { "<leader>3", function() require("harpoon"):list():select(3) end, desc = "harpoon to file 3", },
      { "<leader>4", function() require("harpoon"):list():select(4) end, desc = "harpoon to file 4", },
      { "<leader>5", function() require("harpoon"):list():select(5) end, desc = "harpoon to file 5", },
    },
  },
  {
    "mfussenegger/nvim-dap-python",
    ft = "python",
    dependencies = {
      "mfussenegger/nvim-dap",
      "rcarriga/nvim-dap-ui",
    },
    config = function(_, opts)
      local path = "~/.local/share/nvim/mason/packages/debugpy/venv/bin/python"
      require("dap-python").setup(path)
      require("core.utils").load_mappings("dap_python")
    end,
  },
  {
    "rcarriga/nvim-dap-ui",
    event = "VeryLazy",
    dependencies = "mfussenegger/nvim-dap",
    config = function()
      local dap = require("dap")
      local dapui = require("dapui")
      dapui.setup()
      dap.listeners.after.event_initialized["dapui_config"] = function()
        dapui.open()
      end
      dap.listeners.before.event_terminated["dapui_config"] = function()
        dapui.close()
      end
      dap.listeners.before.event_exited["dapui_config"] = function()
        dapui.close()
      end
    end
  },
  {
    "jay-babu/mason-nvim-dap.nvim",
    event = "VeryLazy",
    dependencies = {
      "williamboman/mason.nvim",
      "mfussenegger/nvim-dap",
      "rcarriga/nvim-dap-ui",
    },
    opts = {
      -- optionally ensure codelldb is installed automatically:
      ensure_installed = { "codelldb" },

      -- The handlers table allows us to customize certain debuggers
      handlers = {
        -- default handler:
        function(config)
          require("mason-nvim-dap").default_setup(config)
        end,

        -- override codelldb handler
        codelldb = function(config)
          -- Here you define your debug configurations for C, C++
          config.configurations = {
            {
              -- This name shows in :DapStart ...
              name = "Launch file (C/C++)",
              type = "codelldb",
              request = "launch",
              -- Ask for an executable to debug
              program = function()
                return vim.fn.input("Path to executable: ", vim.fn.getcwd() .. "/build/", "file")
              end,
              cwd = "${workspaceFolder}",
              stopOnEntry = false,
              -- You can pass other codelldb-specific options here if needed
            },
          }

          -- Finalize with default setup
          require("mason-nvim-dap").default_setup(config)
        end,
      },
    },
  },
  {
    "joerdav/templ.vim"
  },
  {
    "nvimtools/none-ls.nvim",
    event = "VeryLazy",
    opts = function()
      return require "custom.configs.null-ls"
    end,
  },
  {
    "neovim/nvim-lspconfig",
    config = function()
      require "plugins.configs.lspconfig"
      require "custom.configs.lspconfig"
    end,
  },
  {
    "p00f/clangd_extensions.nvim",
    lazy = true,
    config = function() end,
    opts = {
      inlay_hints = {
        inline = false,
      },
      ast = {
        --These require codicons (https://github.com/microsoft/vscode-codicons)
        role_icons = {
          type = "",
          declaration = "",
          expression = "",
          specifier = "",
          statement = "",
          ["template argument"] = "",
        },
        kind_icons = {
          Compound = "",
          Recovery = "",
          TranslationUnit = "",
          PackExpansion = "",
          TemplateTypeParm = "",
          TemplateTemplateParm = "",
          TemplateParamObject = "",
        },
      },
    },
  },
  {
    "Civitasv/cmake-tools.nvim",
    opts = {
      cmake_command = "cmake",
      cmake_build_directory = "build",
      cmake_generate_options = { "-D", "CMAKE_EXPORT_COMPILE_COMMANDS=1" },
    },
  }
}
return plugins
