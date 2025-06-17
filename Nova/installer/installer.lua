-- installer.lua
local root = "https://jxoj.github.io/CC/Nova/installer_files"
local files = {
  -- root startup
  { url = root.."/startup.lua",          path = "/startup.lua" },
  -- Nova core files
  { url = root.."/Nova/core.lua",        path = "/nova/core.lua" },
  { url = root.."/Nova/ui.lua",          path = "/nova/ui.lua"   },
  { url = root.."/Nova/install.lua",     path = "/nova/install.lua" },
  { url = root.."/Nova/default_packages/appstore.lua",     path = "/nova/packages/AppStore.lua" },
}

-- ensure HTTP API is available
if not http then
  print("Error: HTTP API disabled!")
  return
end

-- create directories
local function ensureDir(p)
  local dir = p:match("(.+)/[^/]+$")
  if dir and not fs.exists(dir) then
    fs.makeDir(dir)
  end
end

-- download a single file
local function download(f)
  print("Downloading "..f.url.." → "..f.path)
  local res = http.get(f.url)
  if not res then
    print("  FAILED")
    return false
  end
  ensureDir(f.path)
  local h = fs.open(f.path, "w")
  h.write(res.readAll())
  h.close()
  res.close()
  return true
end

-- install all files
for _, f in ipairs(files) do
  if not download(f) then
    print("Installation aborted.")
    return
  end
end

-- create packages folder
if not fs.exists("/nova/packages") then
  fs.makeDir("/nova/packages")
end

print("\nInstallation complete!")
print("Reboot to start Nova OS:  reboot")
