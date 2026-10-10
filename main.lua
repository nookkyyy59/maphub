-- main.lua · KUGA x BAR hub
local BASE = "https://raw.githubusercontent.com/nookkyyy59/maphub/refs/heads/main/"
local LS = loadstring or load

local function fetch(path)
    local src = game:HttpGet(BASE .. path)
    local fn, err = LS(src)
    if not fn then error("[kuga] load fail "..path..": "..tostring(err)) end
    return fn()
end

local registry = fetch("registry.lua")
local guard    = fetch("guard.lua")
local LP       = game:GetService("Players").LocalPlayer

local regEntry, kickMsg = guard(registry, game.PlaceId)
if not regEntry then
    pcall(function() LP:Kick(kickMsg) end)
    return
end

local folder   = regEntry.folder
local manifest = fetch("maps/"..folder.."/manifest.lua")

for _, s in ipairs(manifest.scripts or {}) do
    if s.file then s.path = "maps/"..folder.."/"..s.file end
end

local runner  = fetch("runner.lua")
local buildUI = fetch("ui.lua")

buildUI(manifest, function(scriptEntry)
    return runner(scriptEntry, BASE)
end)

print("[kuga] "..(manifest.team or "?").." · "..manifest.name)
