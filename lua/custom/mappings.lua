local M = {}

M.dap = {
  plugin = true,
  n = {
      ["<leader>db"] = {
        "<cmd> DapToggleBreakpoint <CR>",
        "ADD breakpoint at line",
      },
      ["<leader>dr"] = {
        "<cmd> DapContinue <CR>",
        "Start or continue the debugger",
      }
    }
}

M.dap_python = {
  plugin = true,
  n = {
    ["<leader>dpr"] = {
      function()
        require('dap-python').test_method()
      end
    }
  }
}

M.cpp = {
  plugin = true,
  n = {
    ["<leader>ctr"] = {
      function()
        vim.cmd("CMakeRun")
      end,
      "CMake Run",
    },
    ["<leader>ctb"] = {
      function()
        vim.cmd("CMakeBuild")
      end,
      "CMake Build",
    },
  },
}


return M
