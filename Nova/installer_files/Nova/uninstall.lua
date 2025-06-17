-- /nova/uninstall.lua
local args = {...}
if args[1]=="uninstall" and args[2] then
  local path = "/nova/packages/"..args[2]..".lua"
  if fs.exists(path) then
    fs.delete(path)
    print("Removed "..args[2])
  else
    print("Not installed: "..args[2])
  end
else
  print("Usage: uninstall <pkg>")
end
