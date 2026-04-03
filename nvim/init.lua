-- Disable netrw for nvim-tree
vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1

-- Bootstrap lazy.nvim (Automatic Installation)
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not (vim.uv or vim.loop).fs_stat(lazypath) then
  vim.fn.system({
    "git",
    "clone",
    "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    "--branch=stable",
    lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)

-- Plugin Setup Block
require("lazy").setup({
  -- Image.nvim Image Viewer
  {
    "3rd/image.nvim",
    enabled = function()
      return #vim.api.nvim_list_uis() > 0
    end,
    opts = {
      processor = "magick_rock",
    },
  },

  -- Fuzzy Finder
  {
    "nvim-telescope/telescope.nvim",
    tag = "0.1.8",
    dependencies = {
      "nvim-lua/plenary.nvim",
      { "nvim-telescope/telescope-fzf-native.nvim", build = "make" },
    },
    config = function()
      local telescope = require("telescope")
      telescope.setup({})
      pcall(telescope.load_extension, "fzf")
    end,
  },

  -- Treesitter (parser manager + highlights)
  {
    "nvim-treesitter/nvim-treesitter",
    lazy = false,
    build = ":TSUpdate",
    config = function()
      require("nvim-treesitter").setup({
        ensure_installed = {
          "bash",
          "c",
          "cpp",
          "css",
          "html",
          "java",
          "javascript",
          "typescript",
          "tsx",
          "json",
          "jsonc",
          "kotlin",
          "lua",
          "markdown",
          "markdown_inline",
          "php",
          "python",
          "sql",
          "swift",
          "vue",
          "xml",
          "yaml",
        },
        auto_install = true,
      })
      pcall(vim.treesitter.language.register, "json", "jsonc")

      vim.api.nvim_create_autocmd("FileType", {
        pattern = {
          "bash",
          "c",
          "cpp",
          "css",
          "html",
          "java",
          "javascript",
          "typescript",
          "tsx",
          "json",
          "jsonc",
          "kotlin",
          "lua",
          "markdown",
          "php",
          "python",
          "sql",
          "swift",
          "vue",
          "xml",
          "yaml",
        },
        callback = function(args)
          pcall(vim.treesitter.start, args.buf)
        end,
      })
    end,
  },

  -- LSP & Package Management
  { "williamboman/mason.nvim", opts = {} },

  -- Modern Completion Engine (Blink.cmp)
  {
    "saghen/blink.cmp",
    dependencies = "rafamadriz/friendly-snippets",
    version = "*",
    opts = {
      keymap = { preset = "default" },
      sources = {
        default = { "lsp", "path", "snippets", "buffer" },
      },
    },
  },

  -- Python specialized features
  {
    "linux-cultist/venv-selector.nvim",
    dependencies = {
      "neovim/nvim-lspconfig",
      "nvim-telescope/telescope.nvim",
      "mfussenegger/nvim-dap-python",
    },
    opts = {
      name = { "venv", ".venv", "env", ".env" },
      auto_refresh = false,
    },
    keys = {
      { "<leader>vs", "<cmd>VenvSelect<cr>", desc = "Select VirtualEnv" },
    },
  },

  -- C/C++ specialized features
  {
    "p00f/clangd_extensions.nvim",
    lazy = true,
    config = function()
      require("clangd_extensions").setup({
        inlay_hints = { inline = true },
      })
    end,
  },

  -- File Explorer (Edit filesystem like a buffer)
  {
    "stevearc/oil.nvim",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    opts = {
      default_file_explorer = true,
      columns = {
        "icon",
        "permissions",
        "size",
        "mtime",
      },
      view_options = {
        sort = {
          { "mtime", "desc" },
          { "name", "asc" },
        },
      },
    },
  },

  -- Tree Explorer (sidebar)
  {
    "nvim-tree/nvim-tree.lua",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    cmd = { "NvimTreeToggle", "NvimTreeFocus" },
    opts = {
      sort_by = "case_sensitive",
      view = {
        width = 36,
        side = "left",
      },
      renderer = {
        group_empty = true,
      },
      filters = {
        dotfiles = false,
      },
      git = {
        enable = true,
        ignore = false,
      },
    },
  },

  -- Status Line
  {
    "nvim-lualine/lualine.nvim",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    opts = {
      options = { theme = "auto" },
    },
  },

  -- Keybinding Helper
  {
    "folke/which-key.nvim",
    event = "VeryLazy",
    opts = {},
  },

  -- Git signs/blame in gutter
  {
    "lewis6991/gitsigns.nvim",
    event = { "BufReadPre", "BufNewFile" },
    opts = {
      current_line_blame = true,
      current_line_blame_opts = { delay = 250 },
      signs = {
        add = { text = "│" },
        change = { text = "│" },
        delete = { text = "_" },
        topdelete = { text = "‾" },
        changedelete = { text = "~" },
        untracked = { text = "┆" },
      },
    },
  },

  -- Better diagnostics/location list UI
  {
    "folke/trouble.nvim",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    opts = {},
    keys = {
      { "<leader>xx", "<cmd>Trouble diagnostics toggle<cr>", desc = "Trouble Diagnostics" },
      { "<leader>xq", "<cmd>Trouble qflist toggle<cr>", desc = "Trouble Quickfix" },
      { "<leader>xl", "<cmd>Trouble loclist toggle<cr>", desc = "Trouble Loclist" },
      {
        "<leader>xr",
        "<cmd>Trouble lsp toggle focus=false win.position=right<cr>",
        desc = "Trouble LSP refs",
      },
    },
  },

  -- Linting
  {
    "mfussenegger/nvim-lint",
    event = { "BufReadPre", "BufNewFile" },
    config = function()
      local lint = require("lint")
      lint.linters_by_ft = {
        javascript = { "eslint_d", "eslint" },
        javascriptreact = { "eslint_d", "eslint" },
        typescript = { "eslint_d", "eslint" },
        typescriptreact = { "eslint_d", "eslint" },
        vue = { "eslint_d", "eslint" },
        python = { "ruff" },
        sh = { "shellcheck" },
        bash = { "shellcheck" },
        yaml = { "yamllint" },
        markdown = { "markdownlint" },
      }

      local lint_augroup = vim.api.nvim_create_augroup("nvim-lint", { clear = true })
      vim.api.nvim_create_autocmd({ "BufEnter", "BufWritePost", "InsertLeave" }, {
        group = lint_augroup,
        callback = function()
          lint.try_lint()
        end,
      })
    end,
  },

  -- Editing QoL trio
  {
    "windwp/nvim-autopairs",
    event = "InsertEnter",
    opts = { check_ts = true },
    enabled = false,
  },
  {
    "numToStr/Comment.nvim",
    opts = {},
  },
  {
    "kylechui/nvim-surround",
    version = "*",
    event = "VeryLazy",
    opts = {},
  },

  -- TODO/FIXME comment highlighter
  {
    "folke/todo-comments.nvim",
    dependencies = { "nvim-lua/plenary.nvim" },
    event = { "BufReadPost", "BufNewFile" },
    opts = {},
  },

  -- Optional high-contrast theme profile
  {
    "folke/tokyonight.nvim",
    lazy = false,
    priority = 1000,
  },

  -- Markdown preview
  {
    "toppair/peek.nvim",
    event = "VeryLazy",
    build = function()
      if vim.fn.executable("deno") == 1 then
        vim.fn.system({ "deno", "task", "--quiet", "build:fast" })
        if vim.v.shell_error ~= 0 then
          vim.schedule(function()
            vim.notify("peek.nvim: build failed; run :Lazy build peek.nvim after installing deno", vim.log.levels.WARN)
          end)
        end
      else
        vim.schedule(function()
          vim.notify("peek.nvim: deno not found; markdown preview build skipped", vim.log.levels.WARN)
        end)
      end
    end,
    config = function()
      require("peek").setup({
        auto_load = true,
        close_on_bdelete = true,
        syntax = true,
        theme = "dark",
        update_on_change = true,
        app = "webview",
        filetype = { "markdown" },
        throttle_at = 200000,
        throttle_time = "auto",
      })
      vim.api.nvim_create_user_command("PeekOpen", require("peek").open, {})
      vim.api.nvim_create_user_command("PeekClose", require("peek").close, {})
    end,
  },

  -- Code formatter
  {
    "stevearc/conform.nvim",
    config = function()
      require("conform").setup({
        formatters_by_ft = {
          lua = { "stylua" },
          python = { "isort", "black" },
          rust = { "rustfmt", lsp_format = "fallback" },
          javascript = { "prettierd", "prettier", stop_after_first = true },
          javascriptreact = { "prettierd", "prettier", stop_after_first = true },
          typescript = { "prettierd", "prettier", stop_after_first = true },
          typescriptreact = { "prettierd", "prettier", stop_after_first = true },
          vue = { "prettierd", "prettier", stop_after_first = true },
          json = { "prettier_json_no_trailing" },
          jsonc = { "prettier_json_no_trailing" },
          yaml = { "prettierd", "prettier", stop_after_first = true },
          markdown = { "prettierd", "prettier", stop_after_first = true },
          html = { "prettierd", "prettier", stop_after_first = true },
          css = { "prettierd", "prettier", stop_after_first = true },
          scss = { "prettierd", "prettier", stop_after_first = true },
          xml = { "xmlformat", "xmlformatter", "xmllint", stop_after_first = true },
          java = { "google-java-format" },
          kotlin = { "ktlint" },
          php = { "php_cs_fixer", "pint", "phpcbf", stop_after_first = true },
          cs = { "csharpier" },
          swift = { "swiftformat", "swift_format", stop_after_first = true },
          sql = { "sql_formatter", "sqlfmt", stop_after_first = true },
          c = { "clang_format" },
          cpp = { "clang_format" },
          sh = { "shfmt" },
          bash = { "shfmt" },
        },
        formatters = {
          stylua = {
            prepend_args = {
              "--indent-type",
              "Spaces",
              "--indent-width",
              "2",
              "--column-width",
              "100",
            },
          },
          rustfmt = {
            prepend_args = { "--config", "max_width=100,tab_spaces=2" },
          },
          prettier = {
            prepend_args = { "--tab-width", "2", "--print-width", "100" },
          },
          prettierd = {
            prepend_args = { "--tab-width", "2", "--print-width", "100" },
          },
          prettier_json_no_trailing = {
            inherit = false,
            command = "prettier",
            args = {
              "--stdin-filepath",
              "$FILENAME",
              "--tab-width",
              "2",
              "--print-width",
              "100",
              "--trailing-comma",
              "none",
            },
          },
          clang_format = {
            prepend_args = { "--style", "{IndentWidth: 2, ColumnLimit: 100}" },
          },
          shfmt = {
            prepend_args = { "-i", "2", "-s" },
          },
        },
        format_on_save = {
          timeout_ms = 800,
          lsp_format = "fallback",
        },
      })
    end,
  },

  -- LSP Configuration
  {
    "neovim/nvim-lspconfig",
    dependencies = {
      "williamboman/mason.nvim",
      "williamboman/mason-lspconfig.nvim",
    },
    config = function()
      require("mason").setup()
      require("mason-lspconfig").setup({
        ensure_installed = { "pyright", "clangd" },
      })

      vim.api.nvim_create_autocmd("LspAttach", {
        callback = function(args)
          local opts = { buffer = args.buf }
          vim.keymap.set("n", "gd", vim.lsp.buf.definition, opts)
          vim.keymap.set("n", "K", vim.lsp.buf.hover, opts)
          vim.keymap.set("n", "<leader>rn", vim.lsp.buf.rename, opts)
          vim.keymap.set("n", "<leader>ca", vim.lsp.buf.code_action, opts)
        end,
      })

      vim.lsp.config("pyright", {
        cmd = { "pyright-langserver", "--stdio" },
        filetypes = { "python" },
        root_markers = { ".git", "pyproject.toml", "setup.py" },
      })

      vim.lsp.config("clangd", {
        cmd = { "clangd" },
        filetypes = { "c", "cpp", "objc", "objcpp", "cuda", "proto" },
        root_markers = { ".git", "compile_commands.json", "Makefile" },
      })

      vim.lsp.enable("pyright")
      vim.lsp.enable("clangd")
    end,
  },
}, {
  -- lazy.nvim options
  rocks = {
    hererocks = true,
  },
})

-- General settings
-- Imported from legacy ~/.vimrc so this config is self-contained.
vim.cmd("syntax on")
vim.cmd("filetype plugin on")
vim.opt.termguicolors = true
vim.opt.textwidth = 0
vim.opt.ruler = true
vim.opt.number = true
vim.opt.hlsearch = true
vim.opt.wildmode = { "longest", "list" }
vim.opt.modelines = 5
vim.opt.ignorecase = true
vim.opt.smartcase = true
vim.opt.visualbell = false
pcall(vim.cmd, "colorscheme zenburn")

vim.g.mapleader = " "
vim.opt.termguicolors = true
vim.opt.expandtab = true
vim.opt.shiftwidth = 2
vim.opt.softtabstop = 2
-- vim.opt.textwidth = 0
vim.opt.formatoptions:remove({ "t", "c", "r" })
vim.opt.clipboard:append("unnamedplus")

pcall(function()
  vim.opt.guifont = "JetBrainsMono Nerd Font:h14"
end)

-- Enable OSC 52 clipboard
vim.g.clipboard = {
  name = "OSC 52",
  copy = {
    ["+"] = require("vim.ui.clipboard.osc52").copy("+"),
    ["*"] = require("vim.ui.clipboard.osc52").copy("*"),
  },
  paste = {
    ["+"] = require("vim.ui.clipboard.osc52").paste("+"),
    ["*"] = require("vim.ui.clipboard.osc52").paste("*"),
  },
}

-- Match language indentation defaults
vim.api.nvim_create_autocmd("FileType", {
  pattern = { "java", "kotlin", "python", "php", "cs", "swift", "xml" },
  callback = function()
    vim.opt_local.shiftwidth = 4
    vim.opt_local.softtabstop = 4
    vim.opt_local.tabstop = 4
  end,
})

vim.api.nvim_create_autocmd("FileType", {
  pattern = {
    "javascript",
    "javascriptreact",
    "typescript",
    "typescriptreact",
    "vue",
    "json",
    "jsonc",
    "yaml",
    "html",
    "css",
    "scss",
    "sql",
    "lua",
    "sh",
    "bash",
    "markdown",
    "c",
    "cpp",
  },
  callback = function()
    vim.opt_local.shiftwidth = 2
    vim.opt_local.softtabstop = 2
    vim.opt_local.tabstop = 2
  end,
})

-- Theme profile toggle: default zenburn <-> high-contrast tokyonight-moon
local high_contrast_theme = false
vim.keymap.set("n", "<leader>ut", function()
  if high_contrast_theme then
    vim.cmd("colorscheme zenburn")
    high_contrast_theme = false
    vim.notify("Theme: zenburn")
  else
    vim.cmd("colorscheme tokyonight-moon")
    high_contrast_theme = true
    vim.notify("Theme: tokyonight-moon")
  end
end, { desc = "Toggle theme profile" })

-- Telescope (Fuzzy Finder)
vim.keymap.set("n", "<leader>ff", function()
  require("telescope.builtin").find_files()
end, { desc = "Find Files" })
vim.keymap.set("n", "<leader>fg", function()
  require("telescope.builtin").live_grep()
end, { desc = "Search Text" })
vim.keymap.set("n", "<leader>fb", function()
  require("telescope.builtin").buffers()
end, { desc = "List Buffers" })
vim.keymap.set("n", "<leader>ft", "<cmd>TodoTelescope<cr>", { desc = "Find TODO/FIXME" })

-- Oil.nvim (File Explorer)
vim.keymap.set("n", "-", "<CMD>Oil<CR>", { desc = "Open parent directory" })
vim.keymap.set("n", "<Esc>", function()
  if vim.bo.filetype == "oil" then
    require("oil").close()
  end
end, { desc = "Close oil float" })

-- nvim-tree (sidebar)
vim.keymap.set("n", "<leader>e", "<cmd>NvimTreeToggle<cr>", { desc = "Toggle file tree" })

-- Mason (LSP Manager)
vim.keymap.set("n", "<leader>m", "<CMD>Mason<CR>", { desc = "Open Mason UI" })

-- Block left and right clicks
local click_block_modes = { "n", "i" }
for _, mode in ipairs(click_block_modes) do
  vim.keymap.set(mode, "<LeftMouse>", "<Nop>", { silent = true })
  vim.keymap.set(mode, "<RightMouse>", "<Nop>", { silent = true })
end

-- Delete without yanking (black hole register)
vim.keymap.set({ "n", "v" }, "d", '"_d', { desc = "Delete without yanking" })
vim.keymap.set({ "n", "v" }, "x", '"_x', { desc = "Delete character without yanking" })

-- Cut line to system clipboard
vim.keymap.set("n", "dd", '"+dd', { desc = "Cut line to system clipboard" })


-- Legacy vimrc carry-overs
vim.keymap.set("n", ";;", "`^", { desc = "Jump to last insert position" })

for _, key in ipairs({ "<Up>", "<Down>", "<Left>", "<Right>" }) do
  vim.keymap.set({ "n", "v" }, key, "<Nop>", { silent = true })
end
for _, key in ipairs({ "<PageUp>", "<PageDown>" }) do
  vim.keymap.set("i", key, "<Nop>", { silent = true })
end

vim.api.nvim_create_autocmd("VimEnter", {
  callback = function()
    if vim.o.diff then
      pcall(vim.cmd, "colorscheme murphy")
    end
  end,
})

vim.api.nvim_create_autocmd("VimEnter", {
  callback = function()
    local highlights = {
      DiffText = "ctermfg=blue ctermbg=none",
      DiffAdd = "ctermfg=green ctermbg=none",
      DiffDelete = "ctermfg=red ctermbg=none",
      DiffChange = "ctermfg=yellow ctermbg=none",
    }
    for group, spec in pairs(highlights) do
      vim.cmd(("hi! %s %s"):format(group, spec))
    end
  end,
})

vim.api.nvim_create_user_command("DW", function()
  vim.cmd("vert new | set bt=nofile | r ++edit # | 0d_ | diffthis | wincmd p | diffthis")
end, { desc = "Diff current buffer against alternate file" })

vim.keymap.set("n", "<Esc><Esc>", "<cmd>DW<CR>", { desc = "Diff current buffer vs alternate" })
