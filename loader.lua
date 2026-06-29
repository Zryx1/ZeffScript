
-- ========================================
-- VORTEX LOADER
-- Load Menu + Fungsi sekaligus
-- ========================================

print("Loading VORTEX...")

-- Load fungsi dulu
local fungsi = loadstring(game:HttpGet("https://zeffvortexscript.vercel.app/fungsi.lua"))()
if fungsi then
    print("Fungsi loaded!")
end

-- Load menu
local menu = loadstring(game:HttpGet("https://zeffvortexscript.vercel.app/menu.lua"))()
if menu then
    print("Menu loaded!")
end

print("VORTEX READY!")
