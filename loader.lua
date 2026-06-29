-- ========================================
-- VORTEX LOADER - LOAD DARI GITHUB
-- ========================================

print("Loading VORTEX from GitHub...")

-- Load fungsi
local fungsi = loadstring(game:HttpGet("https://raw.githubusercontent.com/Zryx1/ZeffScript/main/fungsi.lua"))()
if fungsi then
    print("[VORTEX] Fungsi loaded!")
else
    warn("[VORTEX] Gagal load fungsi!")
end

-- Load menu
local menu = loadstring(game:HttpGet("https://raw.githubusercontent.com/Zryx1/ZeffScript/main/menu.lua"))()
if menu then
    print("[VORTEX] Menu loaded!")
else
    warn("[VORTEX] Gagal load menu!")
end

print("========================")
print("VORTEX READY!")
print("========================")
