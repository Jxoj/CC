-- /nova/core.lua
local ui  = require("/nova/ui")
local fs  = fs
local w,h = term.getSize()
local ICON = 3

-- track per-session icon positions
local pos = {}
local function ensurePos(pkgs)
  local cols = math.floor(w / (ICON+4))
  local i=0
  for _,pkg in ipairs(pkgs) do
    if not pos[pkg.name] then
      local col=i%cols; local row=math.floor(i/cols)
      pos[pkg.name] = { x=2+col*(ICON+4), y=2+row*(ICON+4) }
    end
    i=i+1
  end
end

-- list installed + built‑ins
local function getPackages()
  local t={}
  -- shell and appstore built‑in
  table.insert(t,{name="Shell",     path="/nova/apps/terminal.lua"})
  table.insert(t,{name="AppStore",  path="/nova/appstore.lua"})
  -- installed packages
  if fs.exists("/nova/packages") then
    for _,f in ipairs(fs.list("/nova/packages")) do
      if f:sub(-4)==".lua" then
        local nm=f:sub(1,-5)
        table.insert(t,{name=nm,path="/nova/packages/"..f})
      end
    end
  end
  ensurePos(t)
  return t
end

-- draw everything
local function redraw(pkgs)
  term.clear(); term.setBackgroundColor(colors.cyan)
  term.clear()
  -- draw each icon
  for _,pkg in ipairs(pkgs) do
    local p=pos[pkg.name]
    ui.drawDefaultIcon(p.x,p.y)
    -- label
    term.setCursorPos(p.x,p.y+ICON)
    term.setBackgroundColor(colors.cyan)
    term.setTextColor(colors.white)
    write(pkg.name)
  end
end

-- find pkg clicked
local function findPkg(pkgs,x,y)
  for _,pkg in ipairs(pkgs) do
    local p=pos[pkg.name]
    if x>=p.x and x<p.x+ICON and y>=p.y and y<p.y+ICON then
      return pkg
    end
  end
end

-- drag logic
local function handleDrag(pkgs)
  local ev,btn,sx,sy = os.pullEvent("mouse_click")
  local pkg = findPkg(pkgs,sx,sy)
  if not pkg then return end
  -- drag until mouse_up
  while true do
    local e,button,dx,dy = os.pullEvent()
    if e=="mouse_drag" then
      pos[pkg.name].x = dx-1
      pos[pkg.name].y = dy-1
      redraw(pkgs)
    elseif e=="mouse_up" then
      break
    end
  end
end

-- main loop
while true do
  local pkgs = getPackages()
  redraw(pkgs)
  local e,btn,x,y = os.pullEvent()
  if e=="mouse_click" then
    local pkg = findPkg(pkgs,x,y)
    if pkg then
      -- click → launch
      shell.run(pkg.path)
      redraw(pkgs)
    end
  elseif e=="mouse_drag" then
    handleDrag(pkgs)
  end
end
