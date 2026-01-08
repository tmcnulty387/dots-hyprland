-- Custom NvChad theme that mirrors the current kitty/quickshell terminal palette
-- Reads ~/.local/state/quickshell/user/generated/terminal/sequences.txt on startup and
-- falls back to a fixed palette if the file is missing.

local default_palette = {
  background = "#1A1A1D",
  foreground = "#CCDBD5",
  cursor = "#CCDBD5",
  palette = {
    [0] = "#1A1A1D",
    [1] = "#8383FF",
    [2] = "#64DCF0",
    [3] = "#75FCDD",
    [4] = "#88AFD3",
    [5] = "#98A6EF",
    [6] = "#92D1F9",
    [7] = "#CCDBD5",
    [8] = "#C3B5C0",
    [9] = "#BCB9FF",
    [10] = "#F7FDFF",
    [11] = "#FFFFFF",
    [12] = "#C7DFF4",
    [13] = "#D3D7FF",
    [14] = "#F8FBFF",
    [15] = "#E0E3E8",
  },
}

local function hex_to_rgb(hex)
  hex = hex:gsub("#", "")
  return tonumber(hex:sub(1, 2), 16), tonumber(hex:sub(3, 4), 16), tonumber(hex:sub(5, 6), 16)
end

local function blend(a, b, alpha)
  local ar, ag, ab = hex_to_rgb(a)
  local br, bg, bb = hex_to_rgb(b)

  local r = math.floor(ar + (br - ar) * alpha + 0.5)
  local g = math.floor(ag + (bg - ag) * alpha + 0.5)
  local bl = math.floor(ab + (bb - ab) * alpha + 0.5)

  return string.format("#%02x%02x%02x", r, g, bl)
end

local function darken(hex, amount)
  return blend(hex, "#000000", amount)
end

local function parse_sequences()
  local path = vim.fn.expand "~/.local/state/quickshell/user/generated/terminal/sequences.txt"
  local ok, lines = pcall(vim.fn.readfile, path)

  if not ok or not lines or vim.tbl_isempty(lines) then
    return vim.deepcopy(default_palette)
  end

  local data = table.concat(lines, "\n")
  local palette = { palette = {} }

  for idx, hex in data:gmatch "%]4;(%d+);#(%x%x%x%x%x%x)" do
    idx = tonumber(idx, 10)
    if idx and idx <= 15 then
      palette.palette[idx] = "#" .. hex
    end
  end

  local fg = data:match "%]10;#(%x%x%x%x%x%x)"
  local bg = data:match "%]11;%[[^#]*#(%x%x%x%x%x%x)" or data:match "%]11;#(%x%x%x%x%x%x)"
  local cursor = data:match "%]12;#(%x%x%x%x%x%x)"

  palette.foreground = fg and ("#" .. fg) or nil
  palette.background = bg and ("#" .. bg) or nil
  palette.cursor = cursor and ("#" .. cursor) or nil

  local resolved = vim.deepcopy(default_palette)

  for i = 0, 15 do
    resolved.palette[i] = palette.palette[i] or resolved.palette[i]
  end

  resolved.foreground = palette.foreground or resolved.foreground
  resolved.background = palette.background or resolved.background
  resolved.cursor = palette.cursor or resolved.cursor

  return resolved
end

local colors = parse_sequences()

local subtle = blend(colors.background, colors.foreground, 0.22)
local surface = blend(colors.background, colors.foreground, 0.28)
local surface2 = blend(colors.background, colors.foreground, 0.36)
local comment = blend(colors.foreground, colors.background, 0.5)
local bright = blend(colors.foreground, "#ffffff", 0.18)

local M = {}

M.base_16 = {
  base00 = colors.background,
  base01 = colors.palette[0],
  base02 = subtle,
  base03 = colors.palette[8],
  base04 = bright,
  base05 = colors.foreground,
  base06 = colors.palette[15],
  base07 = colors.palette[11],
  base08 = colors.palette[1],
  base09 = colors.palette[9],
  base0A = colors.palette[3],
  base0B = colors.palette[2],
  base0C = colors.palette[6],
  base0D = colors.palette[4],
  base0E = colors.palette[5],
  base0F = colors.palette[8],
}

M.base_30 = {
  white = M.base_16.base06,
  darker_black = darken(colors.background, 0.08),
  black = colors.background,
  black2 = subtle,
  one_bg = surface,
  one_bg2 = surface2,
  one_bg3 = blend(colors.background, colors.foreground, 0.44),
  grey = blend(colors.background, colors.foreground, 0.5),
  grey_fg = blend(colors.background, colors.foreground, 0.58),
  grey_fg2 = blend(colors.background, colors.foreground, 0.66),
  light_grey = blend(colors.background, colors.foreground, 0.74),
  red = M.base_16.base08,
  baby_pink = M.base_16.base09,
  pink = M.base_16.base0E,
  line = surface,
  green = M.base_16.base0B,
  vibrant_green = M.base_16.base0A,
  blue = M.base_16.base0D,
  nord_blue = M.base_16.base0C,
  yellow = M.base_16.base0A,
  sun = M.base_16.base0F,
  purple = M.base_16.base0E,
  dark_purple = darken(M.base_16.base0E, 0.25),
  teal = M.base_16.base0C,
  orange = M.base_16.base09,
  cyan = M.base_16.base0C,
  statusline_bg = subtle,
  lightbg = surface,
  pmenu_bg = M.base_16.base0D,
  folder_bg = M.base_16.base0D,
}

M.polish_hl = {
  defaults = {
    CursorLine = { bg = M.base_30.one_bg },
    CursorLineNr = { fg = M.base_16.base06 },
    LineNr = { fg = M.base_30.grey },
    Visual = { bg = M.base_30.one_bg2 },
    NormalFloat = { bg = M.base_30.one_bg },
    FloatBorder = { fg = M.base_16.base05, bg = M.base_30.one_bg },
    Pmenu = { bg = M.base_30.one_bg, fg = M.base_16.base05 },
    PmenuSel = { bg = M.base_30.pmenu_bg, fg = M.base_16.base00 },
  },
  syntax = {
    Comment = { fg = comment },
    ["@comment"] = { fg = comment },
  },
}

M.type = "dark"

return M
