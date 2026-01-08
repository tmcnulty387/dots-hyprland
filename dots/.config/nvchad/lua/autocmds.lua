require "nvchad.autocmds"

-- Recompile/reload highlights on startup so the kitty-derived theme is applied
vim.api.nvim_create_autocmd("VimEnter", {
  group = vim.api.nvim_create_augroup("Base46KittyReload", { clear = true }),
  callback = function()
    pcall(function()
      require("base46").load_all_highlights()
    end)
  end,
})

-- Ensure the custom kitty theme is discoverable in the NvChad theme picker
vim.api.nvim_create_autocmd("User", {
  pattern = "VeryLazy",
  group = vim.api.nvim_create_augroup("KittyThemePicker", { clear = true }),
  callback = function()
    local ok_utils, utils = pcall(require, "nvchad.utils")
    local ok_state, state = pcall(require, "nvchad.themes.state")

    if not (ok_utils and ok_state) then
      return
    end

    local themes = utils.list_themes()

    if not vim.tbl_contains(themes, "kitty") then
      table.insert(themes, "kitty")
    end

    state.val = themes
    state.themes_shown = themes
  end,
})
