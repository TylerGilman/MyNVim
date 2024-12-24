local M = {}


M.dap = {
  plugin = true,
  n = {
    ["<leader>db"] = {
      "<cmd> DapToggleBreakpoint <CR>",
      "Toggle breakpoint",
    },
    ["<leader>dr"] = {
      "<cmd> DapContinue <CR>",
      "Continue debugger",
    },
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
    ["<leader>cm"] = { "<cmd> CMakeBuild <CR>", "CMake Build" },
    ["<leader>cr"] = { "<cmd> CMakeRun <CR>", "CMake Run" },
  }
}

return M
