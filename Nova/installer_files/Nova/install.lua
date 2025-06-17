-- /nova/install.lua
local INDEX = "https://jxoj.github.io/CC/Nova/packages.json"
if not http then
  print("Error: HTTP API disabled")
  return
end

-- ensure packages folder
if not fs.exists("/nova/packages") then fs.makeDir("/nova/packages") end

local function fetchIndex()
  local res = http.get(INDEX)
  if not res then error("Failed to fetch index") end
  local txt = res.readAll(); res.close()
  return textutils.unserializeJSON(txt) or {}
end

local function install(name)
  local idx = fetchIndex()
  local pkg = idx[name]
  if not pkg then
    print("No such package: "..name); return
  end
  print("Downloading "..name.."...")
  local r = http.get(pkg.url)
  if not r then error("Failed to download "..pkg.url) end
  local data = r.readAll(); r.close()
  local path = "/nova/packages/"..name..".lua"
  local f = fs.open(path, "w"); f.write(data); f.close()
  print("Installed to "..path)
end

local args = {...}
if args[1]=="install" and args[2] then
  install(args[2])
else
  print("Usage: nova install <package>")
end
