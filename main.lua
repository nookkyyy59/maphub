-- main.lua  ·  KUGA x BAR hub  ·  entry point
-- URL โฮสต์ของ hub (ต้องมี / ปิดท้าย)
local BASE = "https://raw.githubusercontent.com/nookkyyy59/maphub/refs/heads/main/"

local LS = loadstring or load

local function fetch(path)
    local src = game:HttpGet(BASE .. path)
    local fn, err = LS(src)
    if not fn then
        error("[kuga] load fail " .. path .. ": " .. tostring(err))
    end
    return fn()
end

-- 1) โหลด registry → ตรวจ PlaceId
local registry = fetch("registry.lua")
local guard    = fetch("guard.lua")

local LP = game:GetService("Players").LocalPlayer

local regEntry, kickMsg = guard(registry, game.PlaceId)
if not regEntry then
    pcall(function() LP:Kick(kickMsg) end)
    return
end

-- 2) โหลด manifest ของแมพนั้นเท่านั้น
local folder = regEntry.folder
local manifest = fetch("maps/" .. folder .. "/manifest.lua")

-- 3) ต่อ path ของทุกสคริปต์
for _, s in ipairs(manifest.scripts or {}) do
    if s.file then
        s.path = "maps/" .. folder .. "/" .. s.file
    end
end

-- 4) สร้าง UI + ผูก runner
local runner  = fetch("runner.lua")
local buildUI = fetch("ui.lua")

buildUI(manifest, function(scriptEntry)
    return runner(scriptEntry, BASE)
end)

print("[kuga] " .. (manifest.team or "?") .. " · " .. manifest.name)
