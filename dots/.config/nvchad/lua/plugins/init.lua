return {
  {
    "stevearc/conform.nvim",
    -- event = 'BufWritePre', -- uncomment for format on save
    opts = require "configs.conform",
  },

  -- These are some examples, uncomment them if you want to see them work!
  {
    "neovim/nvim-lspconfig",
    config = function()
      require "configs.lspconfig"
    end,
  },

  {
    "zbirenbaum/copilot.lua",
    cmd = "Copilot",
    build = ":Copilot auth",
    event = "BufReadPost",
    opts = {
      suggestion = {
        enabled = not vim.g.ai_cmp,
        auto_trigger = true,
        hide_during_completion = vim.g.ai_cmp,
        keymap = {
          accept = "<M-l>",
          next = "<M-]>",
          prev = "<M-[>",
        },
      },
      panel = { enabled = false },
      filetypes = {
        markdown = true,
        help = true,
      },
    },
    config = function(_, opts)
      require("copilot").setup(opts)
      local suggestion = require "copilot.suggestion"

      vim.keymap.set("i", "<M-j>", function()
        suggestion.toggle_auto_trigger()
      end, { desc = "Copilot toggle auto trigger" })

      vim.keymap.set("i", "<M-k>", function()
        if type(suggestion.trigger) == "function" then
          suggestion.trigger()
        elseif type(suggestion.show) == "function" then
          suggestion.show()
        elseif type(suggestion.request) == "function" then
          suggestion.request()
        elseif type(suggestion.schedule) == "function" then
          suggestion.schedule()
        elseif type(suggestion.next) == "function" then
          suggestion.next()
        end
      end, { desc = "Copilot trigger suggestion" })
    end,
  },

  -- test new blink
  -- { import = "nvchad.blink.lazyspec" },

  -- {
  -- 	"nvim-treesitter/nvim-treesitter",
  -- 	opts = {
  -- 		ensure_installed = {
  -- 			"vim", "lua", "vimdoc",
  --      "html", "css"
  -- 		},
  -- 	},
  -- },

  -- Limit completion to LSP/snippets (no buffer/text alphabetical suggestions)
  {
    "hrsh7th/nvim-cmp",
    opts = function(_, opts)
      local cmp = require "cmp"
      local luasnip = require "luasnip"

      opts = opts or {}
      opts.sources = {
        { name = "nvim_lsp" },
        { name = "luasnip" },
        { name = "async_path" },
      }
      opts.mapping = vim.tbl_extend("force", opts.mapping or {}, {
        ["<Tab>"] = cmp.mapping(function(fallback)
          if cmp.visible() then
            cmp.confirm { select = true }
          elseif luasnip.expand_or_jumpable() then
            luasnip.expand_or_jump()
          else
            fallback()
          end
        end, { "i", "s" }),
        ["<CR>"] = cmp.config.disable,
      })
      return opts
    end,
  },
}
