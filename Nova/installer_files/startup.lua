-- /startup.lua
term.clear()
term.setCursorPos(1,1)
term.setTextColor(colors.lightGray)
print("Booting Nova OS…")
sleep(1)
shell.run("/nova/core.lua")
