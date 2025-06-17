-- /startup.lua
term.clear()
term.setCursorPos(1,1)
print("Nova OS Booting...")
sleep(1)
print("Welcome to Nova OS!")
sleep(0.5)
shell.run("/nova/core.lua")
