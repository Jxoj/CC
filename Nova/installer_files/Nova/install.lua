-- /nova/install.lua
local INDEX = "https://jxoj.github.io/CC/Nova/apps/packages.json"
assert(http, "HTTP API disabled")

if not fs.exists("/nova/packages") then fs.makeDir("/nova/packages") end

local function fetchIndex()
  local r = http.get(INDEX); assert(r, "Failed to fetch index")
  local data = textutils.unserializeJSON(r.readAll()); r.close()
  return data
end

local args = {...}
if args[1]=="install" and args[2] then
  local idx = fetchIndex()
  local pkg = idx[args[2]]
  if not pkg then return print("No such pkg: "..args[2]) end
  print("Installing "..args[2].."...")
  local r = http.get(pkg.url); assert(r, "Download failed")
  local f = fs.open("/nova/packages/"..args[2]..".lua","w")
  f.write(r.readAll()); f.close(); r.close()
  print("Done.")
else
  print("Usage: install <pkg>")
end
