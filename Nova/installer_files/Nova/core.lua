-- /nova/core.lua
local desktop = require("/nova/desktop")
local term, shell, os, colors = term, shell, os, colors

-- One‑time setup
desktop.ensurePackages()

-- Main event loop
while true do
  local apps = desktop.getApps()
  desktop.drawDesktop(apps)

  local event, button, x, y = os.pullEvent("mouse_click")
  local w, h = term.getSize()

  -- Shell button?
  if y == h and x >= 2 and x <= 8 then
    term.setBackgroundColor(colors.black)
    term.clear()
    term.setCursorPos(1,1)
    term.setTextColor(colors.white)
    print("Nova Shell (type 'exit' to return)")
    shell.run("lua")

  else
    -- Desktop clicks
    local action, app = desktop.handleClick(apps, x, y)
    if action == "open" then
      term.clear()
      shell.run(app.path)
    elseif not app then
      -- empty space → drag
      desktop.handleDrag(apps)
    end
  end
end
