-- /nova/desktop.lua
local fs, term, os, colors = fs, term, os, colors
local M = {}

local ICON = 3
local positions = {}
local lastClickTime, lastClickedApp = 0, nil
local DOUBLE_CLICK_INTERVAL = 0.5

-- Ensure the packages folder exists
function M.ensurePackages()
  if not fs.exists("/nova/packages") then
    fs.makeDir("/nova/packages")
  end
end

-- Lay out icon grid
function M.ensurePos(apps)
  local w, h = term.getSize()
  local cols = math.floor(w / (ICON + 4))
  for i,app in ipairs(apps) do
    if not positions[app.name] then
      local col = (i-1) % cols
      local row = math.floor((i-1) / cols)
      positions[app.name] = {
        x = 2 + col*(ICON+4),
        y = 2 + row*(ICON+4)
      }
    end
  end
end

-- Gather all apps (AppStore + installed packages)
function M.getApps()
  local apps = {
    { name="AppStore", path="/nova/apps/AppStore.lua" }
  }
  for _,f in ipairs(fs.list("/nova/packages")) do
    if f:sub(-4) == ".lua" then
      local name = f:sub(1, -5)
      table.insert(apps, {
        name = name,
        path = "/nova/packages/" .. f
      })
    end
  end
  M.ensurePos(apps)
  return apps
end

-- Draw the full desktop (background, icons, taskbar)
function M.drawDesktop(apps)
  local w, h = term.getSize()
  -- background
  term.setBackgroundColor(colors.cyan)
  term.clear()
  term.setTextColor(colors.white)
  -- icons + labels
  for _,app in ipairs(apps) do
    local p = positions[app.name]
    -- icon (3×3)
    term.setBackgroundColor(colors.black)
    for dx=0,ICON-1 do for dy=0,ICON-1 do
      term.setCursorPos(p.x+dx, p.y+dy)
      write(" ")
    end end
    term.setBackgroundColor(colors.blue)
    term.setCursorPos(p.x+1, p.y+1)
    write(" ")
    -- label
    term.setBackgroundColor(colors.cyan)
    term.setCursorPos(p.x, p.y+ICON)
    local lbl = app.name
    if #lbl > ICON+1 then lbl = lbl:sub(1,ICON+1) end
    write(lbl)
  end
  -- taskbar & Shell button
  term.setBackgroundColor(colors.gray)
  term.setCursorPos(1, h)
  write(string.rep(" ", w))
  term.setCursorPos(2, h)
  term.setBackgroundColor(colors.black)
  term.setTextColor(colors.white)
  write("[Shell]")
end

-- Find which app (if any) is under (x,y)
function M.findApp(apps, x, y)
  for _,app in ipairs(apps) do
    local p = positions[app.name]
    if x >= p.x and x < p.x + ICON
      and y >= p.y and y < p.y + ICON then
      return app
    end
  end
end

-- Dragging logic
function M.handleDrag(apps)
  local _,_,sx,sy = os.pullEvent("mouse_click")
  local app = M.findApp(apps, sx, sy)
  if not app then return end
  while true do
    local ev,_,dx,dy = os.pullEvent()
    if ev == "mouse_drag" then
      positions[app.name].x = dx - 1
      positions[app.name].y = dy - 1
      M.drawDesktop(apps)
    elseif ev == "mouse_up" then
      break
    end
  end
end

-- Click logic with double‑click detection
-- Returns action="open" on a valid double‑click, or "select" on first click
function M.handleClick(apps, x, y)
  local now = os.clock()
  local app = M.findApp(apps, x, y)
  if app then
    if lastClickedApp == app.name 
       and (now - lastClickTime) <= DOUBLE_CLICK_INTERVAL then
      lastClickedApp = nil
      return "open", app
    else
      lastClickedApp = app.name
      lastClickTime = now
      return "select", app
    end
  end
  return nil, nil
end

return M
