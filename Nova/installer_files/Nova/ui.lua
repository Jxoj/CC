-- /nova/ui.lua
local ui = {}

-- draw a taskbar button
function ui.taskButton(x, y, label)
  term.setCursorPos(x, y)
  term.setBackgroundColor(colors.darkGray)
  term.setTextColor(colors.white)
  write(label)
  term.setBackgroundColor(colors.gray)
end

return ui
