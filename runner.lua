-- runner.lua  ·  โหลดและรันสคริปต์ปลายทาง
-- return function(entry, BASE) -> ok, err

local LS = loadstring or load

return function(entry, BASE)
    local src, fn, ok, err, hErr, cErr

    if entry.path then
        src, hErr = game:HttpGet(BASE .. entry.path)
        if not src then return false, hErr or "HttpGet failed" end
        fn, cErr = LS(src)
        if not fn then return false, cErr end
        ok, err = pcall(fn)
        return ok, err

    elseif entry.url then
        src, hErr = game:HttpGet(entry.url)
        if not src then return false, hErr or "HttpGet failed" end
        fn, cErr = LS(src)
        if not fn then return false, cErr end
        ok, err = pcall(fn)
        return ok, err

    elseif entry.code then
        if type(entry.code) == "function" then
            ok, err = pcall(entry.code)
        else
            fn, cErr = LS(entry.code)
            if not fn then return false, cErr end
            ok, err = pcall(fn)
        end
        return ok, err

    else
        return false, "no path / url / code"
    end
end
