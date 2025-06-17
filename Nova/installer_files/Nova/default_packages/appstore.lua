-- /nova/apps/appstore.lua
local http = http
local fs   = fs
local term = term
local textutils = textutils

if not http then
  print("Error: HTTP API disabled")
  return
end

-- Config
local INDEX_URL = "https://jxoj.github.io/CC/Nova/apps/packages.json"
local margin    = 2
local rowHeight = 3

-- State
local allApps     = {}    -- full index
local filtered    = {}    -- matching search
local searchText  = ""
local scrollIndex = 1
local focusSearch = false

-- Fetch index once
local function fetchIndex()
  local res = http.get(INDEX_URL)
  if not res then error("Failed to fetch app index") end
  local t = textutils.unserializeJSON(res.readAll())
  res.close()
  return t
end

-- Rebuild filtered list from searchText
local function rebuildFilter()
  filtered = {}
  for name, info in pairs(allApps) do
    if name:lower():find(searchText:lower()) or info.description:lower():find(searchText:lower()) then
      table.insert(filtered, { name=name, desc=info.description, url=info.url })
    end
  end
  table.sort(filtered, function(a,b) return a.name < b.name end)
  scrollIndex = 1
end

-- Draw the whole UI
local function drawUI()
  local w,h = term.getSize()
  term.clear()
  -- Title bar
  term.setCursorPos(margin,1)
  term.setTextColor(colors.white)
  term.setBackgroundColor(colors.gray)
  term.write(" Nova AppStore ")
  
  -- Search box
  term.setBackgroundColor(colors.lightGray)
  term.setTextColor(colors.black)
  term.setCursorPos(margin,2)
  term.write("Search: "..searchText)
  -- fill rest of line
  term.write(string.rep(" ", w - #("Search: "..searchText) - margin))
  
  -- List area
  local maxRows = math.floor((h - 3) / rowHeight)
  for i=1, maxRows do
    local idx = scrollIndex + i - 1
    local y   = 2 + (i-1)*rowHeight + 1
    if idx > #filtered then break end
    local app = filtered[idx]
    -- Name
    term.setBackgroundColor(colors.cyan)
    term.setTextColor(colors.white)
    term.setCursorPos(margin, y)
    term.write(" " .. app.name)
    -- Description
    term.setBackgroundColor(colors.cyan)
    term.setTextColor(colors.white)
    term.setCursorPos(margin, y+1)
    local desc = app.desc
    if #desc > w - margin*2 - 12 then
      desc = desc:sub(1, w - margin*2 - 15) .. "..."
    end
    term.write(" " .. desc)
    -- Button
    local btnLabel, btnColor = "Install", colors.green
    if fs.exists("/nova/packages/"..app.name..".lua") then
      btnLabel, btnColor = "Uninstall", colors.red
    end
    local bx = w - margin - #btnLabel - 2
    term.setBackgroundColor(btnColor)
    term.setTextColor(colors.white)
    term.setCursorPos(bx, y)
    term.write(" "..btnLabel.." ")
  end
  
  -- Scrollbar hint
  if #filtered > maxRows then
    term.setBackgroundColor(colors.gray)
    term.setTextColor(colors.white)
    term.setCursorPos(w, 3)
    term.write("^")
    term.setCursorPos(w, h)
    term.write("v")
  end
  
  -- Restore default
  term.setBackgroundColor(colors.cyan)
  term.setTextColor(colors.white)
end

-- Handle click events
local function onClick(x,y)
  local w,h = term.getSize()
  -- Click into search box?
  if y == 2 and x >= margin and x <= margin + #"Search: "..searchText then
    focusSearch = true
    return
  else
    focusSearch = false
  end
  
  -- Click on list?
  if y >= 4 then
    local i = math.floor((y-4) / rowHeight) + 1
    local idx = scrollIndex + i - 1
    if idx >=1 and idx <= #filtered then
      local app = filtered[idx]
      -- Determine button X range
      local btnLabel = fs.exists("/nova/packages/"..app.name..".lua") and "Uninstall" or "Install"
      local bx = w - margin - #btnLabel - 2
      local by = 4 + (i-1)*rowHeight -1
      if y == by and x >= bx and x <= bx + #btnLabel +1 then
        -- Invoke install or uninstall
        if btnLabel == "Install" then
          shell.run("/install.lua", "install", app.name)
        else
          shell.run("/nova/uninstall.lua", "uninstall", app.name)
        end
        rebuildFilter()
        drawUI()
      end
    end
  end
  
  -- Click on scrollbar
  local maxRows = math.floor((h - 3) / rowHeight)
  if #filtered > maxRows then
    if x == w then
      if y == 3 and scrollIndex > 1 then
        scrollIndex = scrollIndex - 1
      elseif y == h and scrollIndex + maxRows -1 < #filtered then
        scrollIndex = scrollIndex + 1
      end
      drawUI()
    end
  end
end

-- Handle character input for search
local function onChar(ch)
  if focusSearch then
    if ch == "\b" then
      searchText = searchText:sub(1, -2)
    else
      searchText = searchText .. ch
    end
    rebuildFilter()
    drawUI()
  end
end

-- Initialization
allApps = fetchIndex()
rebuildFilter()
drawUI()

-- Event loop
while true do
  local e, p1, p2, p3 = os.pullEvent()
  if e == "mouse_click" then
    onClick(p2, p3)
  elseif e == "char" then
    onChar(p1)
  elseif e == "key" and p1 == keys.backspace and focusSearch then
    onChar("\b")
  end
end
