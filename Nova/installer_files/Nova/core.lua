-- /nova/core.lua
local ui         = require("/nova/ui")
local paintutils = paintutils
local pkgDir     = "/nova/packages/"
local ICON_SIZE  = 8
local w, h       = term.getSize()
local openWindows = {}

-- list installed packages
local function getPackages()
  local t = {}
  if fs.exists(pkgDir) then
    for _, f in ipairs(fs.list(pkgDir)) do
      if f:sub(-4)==".lua" then
        local name = f:sub(1,-5)
        table.insert(t, {
          name = name,
          path = pkgDir..f,
          iconPath = pkgDir..name..".nfp"  -- still support custom icons if you add them
        })
      end
    end
  end
  return t
end

-- draw desktop background
local function drawBG()
  term.setBackgroundColor(colors.cyan)
  term.clear()
  term.setTextColor(colors.white)
  term.setCursorPos(2,1)
  write("Nova OS")
end

-- draw taskbar with menu, window count and clock
local function drawTaskbar()
  term.setBackgroundColor(colors.gray)
  term.setCursorPos(1,h)
  write(string.rep(" ", w))

  ui.taskButton(2, h, "[Menu]")
  ui.taskButton(12, h, "["..#openWindows.." win]")

  local tm = textutils.formatTime(os.time(), true)
  term.setCursorPos(w-#tm-1, h)
  term.setTextColor(colors.white)
  write(tm)
end

-- draw icons in a grid
local function drawIcons(pkgs)
  local cols = math.floor((w - 4) / (ICON_SIZE + 4))
  for i,pkg in ipairs(pkgs) do
    local col = (i-1) % cols
    local row = math.floor((i-1) / cols)
    local x = 2 + col*(ICON_SIZE+4)
    local y = 3 + row*(ICON_SIZE+2)

    -- draw either custom icon file or default
    if fs.exists(pkg.iconPath) then
      local img = paintutils.loadImage(pkg.iconPath)
      paintutils.drawImage(img, x, y)
    else
      -- default: black box
      paintutils.drawBox(x, y, x+ICON_SIZE-1, y+ICON_SIZE-1, colors.black)
      -- blue dot in center
      local cx = x + math.floor(ICON_SIZE/2)
      local cy = y + math.floor(ICON_SIZE/2)
      term.setBackgroundColor(colors.blue)
      term.setCursorPos(cx, cy)
      write(" ")
    end

    -- label underneath
    term.setBackgroundColor(colors.cyan)
    term.setCursorPos(x, y + ICON_SIZE)
    term.setTextColor(colors.white)
    write(pkg.name)
  end
end

-- hit‑testing icon clicks
local function clickedPackage(mx, my, pkgs)
  local cols = math.floor((w - 4) / (ICON_SIZE + 4))
  for i,pkg in ipairs(pkgs) do
    local col = (i-1) % cols
    local row = math.floor((i-1) / cols)
    local ix = 2 + col*(ICON_SIZE+4)
    local iy = 3 + row*(ICON_SIZE+2)
    if mx>=ix and mx< ix+ICON_SIZE and my>=iy and my< iy+ICON_SIZE then
      return pkg
    end
  end
end

-- main loop
while true do
  local pkgs = getPackages()
  drawBG()
  drawIcons(pkgs)
  drawTaskbar()

  local _, _, x, y = os.pullEvent("mouse_click")
  if y == h then
    -- future: menu or window list handling
  else
    local pkg = clickedPackage(x, y, pkgs)
    if pkg then
      table.insert(openWindows, pkg.name)
      shell.run(pkg.path)
      table.remove(openWindows)
    end
  end
end
