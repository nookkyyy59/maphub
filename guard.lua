-- guard.lua  ·  ตรวจว่า PlaceId มีใน registry ไหม
-- return function(registry, placeId) -> entry | nil, kickMsg

return function(registry, placeId)
    local entry = registry[placeId]
    if entry then return entry, nil end
    return nil, "ไม่พบ ID แมพนี้: " .. tostring(placeId)
end
