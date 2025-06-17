-- /nova/ui.lua
-- UI helper functions for Nova OS

local ui = {}

--- Draws an app icon label background.
-- @param x number: X position (1-based)
-- @param y number: Y position (1-based)
-- @param label string: The text to display inside brackets
function ui.appIcon(x, y, label)
  term.setCursorPos(x, y)
  term.setBackgroundColor(colors.white)
  term.setTextColor(colors.black)
  write("[" .. label .. "]")
  -- restore desktop background color
  term.setBackgroundColor(colors.cyan)
end

--- Draws a button on the taskbar.
-- @param x number: X position (1-based)
-- @param y number: Y position (1-based, should be bottom row)
-- @param label string: Button text (including its own brackets)
function ui.taskButton(x, y, label)
  term.setCursorPos(x, y)
  term.setBackgroundColor(colors.darkGray)
  term.setTextColor(colors.white)
  write(label)
  -- restore taskbar background
  term.setBackgroundColor(colors.gray)
end

return ui
