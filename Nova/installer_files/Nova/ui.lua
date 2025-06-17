-- /nova/ui.lua
local ui = {}

--- Draw a 3×3 default icon at (x,y)
function ui.drawDefaultIcon(x, y)
  -- black 3×3
  paintutils.drawBox(x, y, x+2, y+2, colors.black)
  -- blue center dot
  paintutils.drawPixel(x+1, y+1, colors.blue)
end

return ui
