-- /startup.lua
term.clear()
term.setCursorPos(1,1)
term.setTextColor(colors.lightGray)
print("Booting Nova OS...")
sleep(1)
print("Loading components...")
sleep(0.5)
shell.run("/nova/core.lua")
