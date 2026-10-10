-- ui.lua · KUGA x BAR hub
local TweenService = game:GetService("TweenService")
local UIS          = game:GetService("UserInputService")
local Lighting     = game:GetService("Lighting")
local SoundService = game:GetService("SoundService")
local Players      = game:GetService("Players")
local LP           = Players.LocalPlayer

local SOUNDS = {open="rbxassetid://",close="rbxassetid://",hover="rbxassetid://",press="rbxassetid://",run="rbxassetid://"}
local VOL = {open=0.45,close=0.40,hover=0.12,press=0.32,run=0.50}

local C = {
    bg=Color3.fromRGB(12,14,19), bgDeep=Color3.fromRGB(8,10,14),
    panel=Color3.fromRGB(20,23,30), panel2=Color3.fromRGB(26,30,38),
    row=Color3.fromRGB(22,25,32), rowHi=Color3.fromRGB(32,37,47),
    line=Color3.fromRGB(42,47,58), text=Color3.fromRGB(238,241,248),
    dim=Color3.fromRGB(140,148,162), dim2=Color3.fromRGB(96,104,118),
    accent=Color3.fromRGB(88,166,255), accent2=Color3.fromRGB(120,100,255),
    accent3=Color3.fromRGB(240,120,200), good=Color3.fromRGB(80,200,130),
    bad=Color3.fromRGB(230,110,110),
}
local EMOJI = {"🔥","⚡","🎯","💎","🚀","👾","🛡️","🌟","🍀","🐉","🎮","✨"}

local function playSound(key)
    local id = SOUNDS[key]
    if not id or id == "rbxassetid://" then return end
    local s = Instance.new("Sound")
    s.SoundId = id; s.Volume = VOL[key] or 0.3; s.Parent = SoundService
    s:Play(); s.Ended:Connect(function() s:Destroy() end)
    task.delay(3, function() if s.Parent then s:Destroy() end end)
end

local function pickParent()
    if gethui then local ok,h = pcall(gethui); if ok and h then return h end end
    local ok, cg = pcall(function() return game:GetService("CoreGui") end)
    if ok and cg then
        local p = Instance.new("Folder")
        if pcall(function() p.Parent = cg end) then return cg end
        p:Destroy()
    end
    return LP:WaitForChild("PlayerGui")
end

local function new(class, props, children)
    local i = Instance.new(class)
    for k, v in pairs(props or {}) do i[k] = v end
    for _, c in ipairs(children or {}) do c.Parent = i end
    return i
end
local function corner(r) return new("UICorner", {CornerRadius = UDim.new(0, r or 8)}) end
local function stroke(c, t, tr)
    return new("UIStroke", {Color=c or C.line, Thickness=t or 1, Transparency=tr or 0, ApplyStrokeMode=Enum.ApplyStrokeMode.Border})
end
local function gradient(stops, rot)
    return new("UIGradient", {Color=ColorSequence.new(stops), Rotation=rot or 0})
end
local function tween(o, t, p, s, d)
    local x = TweenService:Create(o, TweenInfo.new(t, s or Enum.EasingStyle.Quad, d or Enum.EasingDirection.Out), p)
    x:Play(); return x
end

-- effects
local function attachRipple(btn)
    btn.ClipsDescendants = true
    btn.MouseButton1Down:Connect(function(x, y)
        local rx = x - btn.AbsolutePosition.X
        local ry = y - btn.AbsolutePosition.Y
        local size = math.max(btn.AbsoluteSize.X, btn.AbsoluteSize.Y) * 1.6
        local rip = new("Frame", {
            Size=UDim2.fromOffset(size,size),
            Position=UDim2.fromOffset(rx-size/2, ry-size/2),
            BackgroundColor3=C.text, BackgroundTransparency=0.72,
            BorderSizePixel=0, ZIndex=btn.ZIndex+2,
        }, {btn, corner(999)})
        tween(rip, 0.55, {Size=UDim2.fromOffset(size*2,size*2), BackgroundTransparency=1})
        task.delay(0.55, function() rip:Destroy() end)
    end)
end

local function attachPressScale(btn, base)
    base = base or 1
    local s = Instance.new("UIScale", btn); s.Scale = base
    btn.MouseButton1Down:Connect(function() tween(s, 0.08, {Scale=base*0.92}) end)
    btn.MouseButton1Up:Connect(function() tween(s, 0.22, {Scale=base}, Enum.EasingStyle.Back) end)
    btn.MouseLeave:Connect(function() tween(s, 0.22, {Scale=base}, Enum.EasingStyle.Back) end)
    return s
end

local function attachBloom(btn, cIn, cOut)
    cIn = cIn or C.accent; cOut = cOut or C.accent2
    local glow = new("Frame", {
        Size=UDim2.new(1,6,1,6), Position=UDim2.fromOffset(-3,-3),
        BackgroundColor3=cOut, BackgroundTransparency=0.85,
        BorderSizePixel=0, ZIndex=btn.ZIndex-1,
    }, {btn.Parent, corner(12)})
    local sIn = stroke(cIn, 1, 0.45); sIn.Parent = btn
    local sOut = stroke(cOut, 3, 0.80); sOut.Parent = btn
    task.spawn(function()
        while btn.Parent do
            tween(sOut, 1.6, {Transparency=0.65}, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut)
            tween(glow, 1.6, {BackgroundTransparency=0.78}, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut)
            task.wait(1.6)
            if not btn.Parent then break end
            tween(sOut, 1.6, {Transparency=0.85}, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut)
            tween(glow, 1.6, {BackgroundTransparency=0.88}, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut)
            task.wait(1.6)
        end
    end)
    btn.MouseEnter:Connect(function()
        tween(sIn, 0.06, {Transparency=0.10, Thickness=2})
        tween(sOut, 0.06, {Transparency=0.25, Thickness=5})
        tween(glow, 0.06, {BackgroundTransparency=0.45})
        task.delay(0.10, function()
            if not btn.Parent then return end
            tween(sIn, 0.35, {Transparency=0.45, Thickness=1})
            tween(sOut, 0.35, {Transparency=0.80, Thickness=3})
            tween(glow, 0.35, {BackgroundTransparency=0.85})
        end)
    end)
end

local function attachTapMotion(btn, basePos)
    basePos = basePos or btn.Position
    local sel = false
    local thr
    btn.MouseButton1Down:Connect(function()
        tween(btn, 0.08, {Position=UDim2.new(basePos.X.Scale, basePos.X.Offset-3, basePos.Y.Scale, basePos.Y.Offset)})
        playSound("press")
    end)
    btn.MouseButton1Up:Connect(function() tween(btn, 0.28, {Position=basePos}, Enum.EasingStyle.Back) end)
    btn.MouseLeave:Connect(function() sel = false; tween(btn, 0.22, {Position=basePos}, Enum.EasingStyle.Back) end)
    btn.MouseEnter:Connect(function()
        sel = true
        if thr then return end
        thr = task.spawn(function()
            local up = true
            while sel and btn.Parent do
                tween(btn, 0.9, {Position=UDim2.new(basePos.X.Scale, basePos.X.Offset, basePos.Y.Scale, basePos.Y.Offset + (up and -2 or 0))}, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut)
                task.wait(0.9); up = not up
            end
            if btn.Parent then tween(btn, 0.2, {Position=basePos}) end
            thr = nil
        end)
    end)
end

local function attachAurora(parent, w, h)
    local wrap = new("Frame", {Size=UDim2.fromScale(1,1), BackgroundTransparency=1, ClipsDescendants=true, ZIndex=0}, {parent, corner(12)})
    local pals = {{C.accent, C.accent2}, {C.accent3, C.accent}}
    local blobs = {}
    for i = 1, 2 do
        local pal = pals[i]
        local blob = new("Frame", {
            Size=UDim2.fromOffset(w*0.9, h*0.55),
            Position=UDim2.fromOffset((i-1)*w*0.4 - w*0.2, (i-1)*h*0.3),
            BackgroundColor3=pal[1], BackgroundTransparency=0.88, BorderSizePixel=0, ZIndex=0,
        }, {wrap, corner(999)})
        gradient({ColorSequenceKeypoint.new(0,pal[1]), ColorSequenceKeypoint.new(1,pal[2])}, i*60).Parent = blob
        blobs[i] = blob
    end
    task.spawn(function()
        local t = 0
        while wrap.Parent do
            t = t + 0.006
            for i, b in ipairs(blobs) do
                if not b.Parent then break end
                local ph = t + i*2.1
                b.Position = UDim2.fromOffset(
                    (i-1)*w*0.4 - w*0.2 + math.sin(ph)*(w*0.08),
                    (i-1)*h*0.3 + math.cos(ph*0.8)*(h*0.05))
            end
            task.wait(1/30)
        end
    end)
    local vig = new("Frame", {Size=UDim2.fromScale(1,1), BackgroundColor3=C.bgDeep, BackgroundTransparency=0.55, BorderSizePixel=0, ZIndex=1}, {wrap, corner(12)})
    new("UIGradient", {
        Transparency=NumberSequence.new({
            NumberSequenceKeypoint.new(0,0.9), NumberSequenceKeypoint.new(0.35,0.4),
            NumberSequenceKeypoint.new(0.65,0.4), NumberSequenceKeypoint.new(1,0.9)}),
        Rotation=90,
    }).Parent = vig
end

local function attachShimmer(header)
    local shim = new("Frame", {
        Size=UDim2.new(0.3,0,1,0), Position=UDim2.fromOffset(-200,0),
        BackgroundColor3=Color3.fromRGB(255,255,255), BackgroundTransparency=0.85,
        BorderSizePixel=0, ZIndex=5,
    }, {header})
    new("UIGradient", {
        Transparency=NumberSequence.new({NumberSequenceKeypoint.new(0,1),NumberSequenceKeypoint.new(0.5,0),NumberSequenceKeypoint.new(1,1)}),
        Rotation=90,
    }).Parent = shim
    task.delay(0.35, function()
        if not shim.Parent then return end
        tween(shim, 1.0, {Position=UDim2.new(1,200,0,0)}, Enum.EasingStyle.Quart, Enum.EasingDirection.Out)
        task.delay(1.05, function() if shim.Parent then shim:Destroy() end end)
    end)
end

local function makeDraggable(frame, handle)
    local dragging, dragStart, startPos
    handle.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true; dragStart = input.Position; startPos = frame.Position
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then dragging = false end
            end)
        end
    end)
    UIS.InputChanged:Connect(function(input)
        if not dragging then return end
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
            local d = input.Position - dragStart
            frame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + d.X, startPos.Y.Scale, startPos.Y.Offset + d.Y)
        end
    end)
end

-- build
return function(mapEntry, onRun)
    local parent = pickParent()
    local cam = workspace.CurrentCamera

    local function computeSize()
        local vp = cam.ViewportSize
        return math.max(math.min(460, vp.X - 32), 300),
               math.max(math.min(580, vp.Y - 72), 400)
    end
    local W, H = computeSize()

    local gui = new("ScreenGui", {Name="KugaBarHub", ResetOnSpawn=false, IgnoreGuiInset=true, ZIndexBehavior=Enum.ZIndexBehavior.Sibling}, {parent})

    local root = new("CanvasGroup", {
        Name="Root", Size=UDim2.fromOffset(W,H),
        Position=UDim2.new(0.5,0,0.5,0), AnchorPoint=Vector2.new(0.5,0.5),
        BackgroundColor3=C.bg, BackgroundTransparency=0.02, BorderSizePixel=0,
        GroupTransparency=1, Active=true,
    }, {gui, corner(12)})

    attachAurora(root, W, H)

    local rootStroke = stroke(C.line, 1, 0.1); rootStroke.Parent = root
    gradient({ColorSequenceKeypoint.new(0,C.accent),ColorSequenceKeypoint.new(0.5,C.line),ColorSequenceKeypoint.new(1,C.accent2)},45).Parent = rootStroke

    local rootScale = Instance.new("UIScale", root); rootScale.Scale = 0.9

    -- header
    local header = new("Frame", {Name="Header", Size=UDim2.new(1,0,0,98), BackgroundColor3=C.panel, BackgroundTransparency=0.35, BorderSizePixel=0, ZIndex=10}, {root, corner(12)})
    gradient({ColorSequenceKeypoint.new(0,C.panel2),ColorSequenceKeypoint.new(1,C.panel)},90).Parent = header

    new("Frame", {Size=UDim2.new(1,0,0,1), Position=UDim2.new(0,0,1,-1), BackgroundColor3=C.line, BackgroundTransparency=0.25, BorderSizePixel=0, ZIndex=11}, {header})
    new("Frame", {Size=UDim2.fromOffset(3,42), Position=UDim2.fromOffset(0,28), BackgroundColor3=C.accent, BorderSizePixel=0, ZIndex=11}, {header, corner(2)})

    new("TextLabel", {Size=UDim2.new(1,-70,0,15), Position=UDim2.fromOffset(20,14), BackgroundTransparency=1, Font=Enum.Font.GothamBold, TextSize=11, TextColor3=C.accent, TextXAlignment=Enum.TextXAlignment.Left, Text="◇  KUGA x BAR  ·  HUB", ZIndex=12}, {header})
    new("TextLabel", {Size=UDim2.new(1,-70,0,26), Position=UDim2.fromOffset(20,32), BackgroundTransparency=1, Font=Enum.Font.GothamBold, TextSize=20, TextColor3=C.text, TextXAlignment=Enum.TextXAlignment.Left, TextTruncate=Enum.TextTruncate.AtEnd, Text=mapEntry.name, ZIndex=12}, {header})
    new("TextLabel", {Size=UDim2.new(1,-70,0,14), Position=UDim2.fromOffset(20,64), BackgroundTransparency=1, Font=Enum.Font.Gotham, TextSize=10, TextColor3=C.dim, TextXAlignment=Enum.TextXAlignment.Left, TextTruncate=Enum.TextTruncate.AtEnd, Text="👥 "..(mapEntry.team or "ไม่ระบุค่าย").."    🆔 "..tostring(game.PlaceId), ZIndex=12}, {header})

    local closeBtn = new("TextButton", {Size=UDim2.fromOffset(30,30), Position=UDim2.new(1,-42,0,14), BackgroundColor3=C.panel2, BorderSizePixel=0, Font=Enum.Font.GothamBold, TextSize=16, TextColor3=C.dim, Text="×", AutoButtonColor=false, ZIndex=12}, {header, corner(8)})
    attachPressScale(closeBtn, 1)
    attachBloom(closeBtn, C.bad, C.accent2)
    closeBtn.MouseEnter:Connect(function() tween(closeBtn, 0.14, {BackgroundColor3=Color3.fromRGB(60,30,34), TextColor3=C.bad}) end)
    closeBtn.MouseLeave:Connect(function() tween(closeBtn, 0.14, {BackgroundColor3=C.panel2, TextColor3=C.dim}) end)
    attachShimmer(header)

    -- list
    local list = new("ScrollingFrame", {
        Name="List", Size=UDim2.new(1,-24,1,-98-52), Position=UDim2.fromOffset(12,110),
        BackgroundTransparency=1, BorderSizePixel=0, ScrollBarThickness=4,
        ScrollBarImageColor3=C.line, ScrollBarImageTransparency=0.3,
        CanvasSize=UDim2.new(0,0,0,0), AutomaticCanvasSize=Enum.AutomaticSize.Y,
        ScrollingDirection=Enum.ScrollingDirection.Y,
        ElasticBehavior=Enum.ElasticBehavior.WhenScrollable, ZIndex=20,
    }, {root})
    new("UIListLayout", {Padding=UDim.new(0,8), SortOrder=Enum.SortOrder.LayoutOrder}, {list})

    local status = new("TextLabel", {
        Name="Status", Size=UDim2.new(1,-24,0,28), Position=UDim2.new(0,12,1,-38),
        BackgroundTransparency=1, Font=Enum.Font.Gotham, TextSize=11, TextColor3=C.dim2,
        TextXAlignment=Enum.TextXAlignment.Left, TextTruncate=Enum.TextTruncate.AtEnd,
        Text="◇  พร้อมใช้งาน   ·   "..#(mapEntry.scripts or {}).." สคริปต์", ZIndex=21,
    }, {root})

    local function setStatus(text, color)
        status.Text = text; status.TextColor3 = color or C.dim2
        status.TextTransparency = 1
        tween(status, 0.28, {TextTransparency=0})
    end

    -- blur after gui built
    local blur = Instance.new("BlurEffect")
    blur.Size = 0; blur.Parent = Lighting
    tween(blur, 0.35, {Size=14})

    local closing = false
    local function destroyHub(thenFn)
        if closing then return end
        closing = true
        tween(root, 0.18, {GroupTransparency=1}, Enum.EasingStyle.Quad, Enum.EasingDirection.In)
        tween(rootScale, 0.22, {Scale=0.94}, Enum.EasingStyle.Quad, Enum.EasingDirection.In)
        tween(blur, 0.22, {Size=0}, Enum.EasingStyle.Quad, Enum.EasingDirection.In)
        task.delay(0.24, function()
            blur:Destroy(); gui:Destroy()
            if thenFn then task.spawn(thenFn) end
        end)
    end

    closeBtn.MouseButton1Click:Connect(function()
        playSound("close"); destroyHub()
    end)

    -- rows
    local rankW = 40
    for i, s in ipairs(mapEntry.scripts or {}) do
        local emoji = s.emoji or EMOJI[((i-1) % #EMOJI) + 1]

        local row = new("Frame", {
            Name="Row_"..i, Size=UDim2.new(1,0,0,72), BackgroundColor3=C.row,
            BackgroundTransparency=1, BorderSizePixel=0, ClipsDescendants=false,
            LayoutOrder=i, ZIndex=22,
        }, {list, corner(10)})
        local rowStroke = stroke(C.line, 1, 0.35); rowStroke.Parent = row

        task.delay(i * 0.03, function()
            if not row.Parent then return end
            tween(row, 0.22, {BackgroundTransparency=0.15})
        end)

        new("TextLabel", {Size=UDim2.fromOffset(rankW,72), Position=UDim2.fromOffset(0,0), BackgroundTransparency=1, Font=Enum.Font.GothamBold, TextSize=11, TextColor3=C.dim2, Text=string.format("%02d", i), ZIndex=23}, {row})
        new("Frame", {Size=UDim2.new(0,1,0,44), Position=UDim2.fromOffset(rankW-2,14), BackgroundColor3=C.line, BackgroundTransparency=0.5, BorderSizePixel=0, ZIndex=23}, {row})

        local icon = new("TextLabel", {Size=UDim2.fromOffset(36,36), Position=UDim2.fromOffset(rankW+8,18), BackgroundColor3=C.panel2, BackgroundTransparency=0.4, BorderSizePixel=0, Font=Enum.Font.GothamBold, TextSize=18, TextColor3=C.text, Text=emoji, ZIndex=24}, {row, corner(8)})

        new("TextLabel", {Size=UDim2.new(1,-220,0,20), Position=UDim2.fromOffset(rankW+54,14), BackgroundTransparency=1, Font=Enum.Font.GothamSemibold, TextSize=13, TextColor3=C.text, TextXAlignment=Enum.TextXAlignment.Left, TextTruncate=Enum.TextTruncate.AtEnd, Text=s.name, ZIndex=24}, {row})
        new("TextLabel", {Size=UDim2.new(1,-220,0,16), Position=UDim2.fromOffset(rankW+54,36), BackgroundTransparency=1, Font=Enum.Font.Gotham, TextSize=11, TextColor3=C.dim, TextXAlignment=Enum.TextXAlignment.Left, TextTruncate=Enum.TextTruncate.AtEnd, Text=s.desc or "—", ZIndex=24}, {row})

        if s.team then
            new("TextLabel", {Size=UDim2.fromOffset(70,14), Position=UDim2.new(1,-180,0,16), BackgroundColor3=C.panel2, BackgroundTransparency=0.3, BorderSizePixel=0, Font=Enum.Font.GothamBold, TextSize=9, TextColor3=C.accent, Text=tostring(s.team):upper(), ZIndex=24}, {row, corner(4)})
        end

        local runBtn = new("TextButton", {
            Name="Run", Size=UDim2.fromOffset(84,40), Position=UDim2.new(1,-96,0.5,-20),
            BackgroundColor3=Color3.fromRGB(46,96,68), BorderSizePixel=0,
            Font=Enum.Font.GothamBold, TextSize=12, TextColor3=Color3.fromRGB(240,248,240),
            Text="▶  รัน", AutoButtonColor=false, ZIndex=25,
        }, {row, corner(8)})
        gradient({ColorSequenceKeypoint.new(0,Color3.fromRGB(58,130,88)), ColorSequenceKeypoint.new(1,Color3.fromRGB(38,84,60))}, 90).Parent = runBtn

        attachPressScale(runBtn, 1)
        attachRipple(runBtn)
        attachBloom(runBtn, C.good, Color3.fromRGB(120,240,170))
        attachTapMotion(runBtn, runBtn.Position)

        runBtn.MouseEnter:Connect(function() tween(runBtn, 0.14, {BackgroundColor3=Color3.fromRGB(62,138,96)}) end)
        runBtn.MouseLeave:Connect(function() tween(runBtn, 0.14, {BackgroundColor3=Color3.fromRGB(46,96,68)}) end)

        if UIS.MouseEnabled then
            row.MouseEnter:Connect(function()
                tween(row, 0.18, {BackgroundColor3=C.rowHi, BackgroundTransparency=0.05})
                tween(icon, 0.22, {Size=UDim2.fromOffset(40,40), Position=UDim2.fromOffset(rankW+6,16), TextSize=20}, Enum.EasingStyle.Back)
                tween(rowStroke, 0.18, {Color=C.accent, Transparency=0.7})
            end)
            row.MouseLeave:Connect(function()
                tween(row, 0.18, {BackgroundColor3=C.row, BackgroundTransparency=0.15})
                tween(icon, 0.22, {Size=UDim2.fromOffset(36,36), Position=UDim2.fromOffset(rankW+8,18), TextSize=18}, Enum.EasingStyle.Back)
                tween(rowStroke, 0.18, {Color=C.line, Transparency=0.35})
            end)
        end

        runBtn.MouseButton1Click:Connect(function()
            setStatus("⏳  กำลังรัน: "..s.name, C.accent)
            playSound("run")
            task.delay(0.12, function() playSound("close") end)
            destroyHub(function()
                local ok, err = onRun(s)
                if not ok then warn("[kuga] run failed: "..tostring(err)) end
            end)
        end)
    end

    makeDraggable(root, header)

    local conn
    conn = cam:GetPropertyChangedSignal("ViewportSize"):Connect(function()
        if not root.Parent then conn:Disconnect() return end
        local nw, nh = computeSize()
        tween(root, 0.18, {Size=UDim2.fromOffset(nw, nh)})
    end)

    playSound("open")
    tween(root, 0.28, {GroupTransparency=0}, Enum.EasingStyle.Quint)
    tween(rootScale, 0.38, {Scale=1}, Enum.EasingStyle.Back)

    return gui
end
