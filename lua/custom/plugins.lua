local plugins = {
  {
    "williamboman/mason.nvim",
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
  },
  {
    "nvim-neotest/nvim-nio"
  },
{
  "mfussenegger/nvim-dap",
  lazy = false,  -- or remove event/ft triggers
  config = function(_, _)
    require("core.utils").load_mappings("dap")
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
