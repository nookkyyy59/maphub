-- ui.lua · build (uses ui_core)
-- return function(mapEntry, onRun, BASE) -> ScreenGui
local LS = loadstring or load

return function(mapEntry, onRun, BASE)
    local core = LS(game:HttpGet(BASE .. "ui_core.lua"))()
    local C                = core.C
    local EMOJI            = core.EMOJI
    local playSound        = core.playSound
    local pickParent       = core.pickParent
    local new              = core.new
    local corner           = core.corner
    local stroke           = core.stroke
    local gradient         = core.gradient
    local tween            = core.tween
    local attachRipple     = core.attachRipple
    local attachPressScale = core.attachPressScale
    local attachBloom      = core.attachBloom
    local attachTapMotion  = core.attachTapMotion
    local attachAurora     = core.attachAurora
    local attachShimmer    = core.attachShimmer
    local spawnToast       = core.spawnToast
    local makeDraggable    = core.makeDraggable

    local Lighting = game:GetService("Lighting")
    local UIS      = game:GetService("UserInputService")

    local parent = pickParent()
    local cam    = workspace.CurrentCamera

    local function computeSize()
        local vp = cam.ViewportSize
        return math.max(math.min(460, vp.X - 32), 300),
               math.max(math.min(580, vp.Y - 72), 400)
    end
    local W, H = computeSize()

    local blur = Instance.new("BlurEffect")
    blur.Size = 0; blur.Parent = Lighting
    tween(blur, 0.35, { Size = 14 })

    local gui = new("ScreenGui", { Name="KugaBarHub", ResetOnSpawn=false, IgnoreGuiInset=true, ZIndexBehavior=Enum.ZIndexBehavior.Sibling }, { parent })

    local root = new("CanvasGroup", { Name="Root", Size=UDim2.fromOffset(W,H), Position=UDim2.new(0.5,0,0.5,0), AnchorPoint=Vector2.new(0.5,0.5), BackgroundColor3=C.bg, BackgroundTransparency=0.02, BorderSizePixel=0, GroupTransparency=1, Active=true }, { gui, corner(12) })

    attachAurora(root, W, H)

    local rootStroke = stroke(C.line, 1, 0.1); rootStroke.Parent = root
    gradient({ ColorSequenceKeypoint.new(0,C.accent), ColorSequenceKeypoint.new(0.5,C.line), ColorSequenceKeypoint.new(1,C.accent2) }, 45).Parent = rootStroke

    local rootScale = Instance.new("UIScale", root); rootScale.Scale = 0.9

    local header = new("Frame", { Name="Header", Size=UDim2.new(1,0,0,98), BackgroundColor3=C.panel, BackgroundTransparency=0.35, BorderSizePixel=0, ZIndex=10 }, { root, corner(12) })
    gradient({ ColorSequenceKeypoint.new(0,C.panel2), ColorSequenceKeypoint.new(1,C.panel) }, 90).Parent = header

    new("Frame", { Size=UDim2.new(1,0,0,1), Position=UDim2.new(0,0,1,-1), BackgroundColor3=C.line, BackgroundTransparency=0.25, BorderSizePixel=0, ZIndex=11 }, { header })
    new("Frame", { Size=UDim2.fromOffset(3,42), Position=UDim2.fromOffset(0,28), BackgroundColor3=C.accent, BorderSizePixel=0, ZIndex=11 }, { header, corner(2) })

    new("TextLabel", { Size=UDim2.new(1,-70,0,15), Position=UDim2.fromOffset(20,14), BackgroundTransparency=1, Font=Enum.Font.GothamBold, TextSize=11, TextColor3=C.accent, TextXAlignment=Enum.TextXAlignment.Left, Text="◇  KUGA x BAR  ·  HUB", ZIndex=12 }, { header })
    new("TextLabel", { Size=UDim2.new(1,-70,0,26), Position=UDim2.fromOffset(20,32), BackgroundTransparency=1, Font=Enum.Font.GothamBold, TextSize=20, TextColor3=C.text, TextXAlignment=Enum.TextXAlignment.Left, TextTruncate=Enum.TextTruncate.AtEnd, Text=mapEntry.name, ZIndex=12 }, { header })
    new("TextLabel", { Size=UDim2.new(1,-70,0,14), Position=UDim2.fromOffset(20,64), BackgroundTransparency=1, Font=Enum.Font.Gotham, TextSize=10, TextColor3=C.dim, TextXAlignment=Enum.TextXAlignment.Left, TextTruncate=Enum.TextTruncate.AtEnd, Text="👥 "..(mapEntry.team or "ไม่ระบุค่าย").."    🆔 "..tostring(game.PlaceId), ZIndex=12 }, { header })

    local closeBtn = new("TextButton", { Size=UDim2.fromOffset(30,30), Position=UDim2.new(1,-42,0,14), BackgroundColor3=C.panel2, BorderSizePixel=0, Font=Enum.Font.GothamBold, TextSize=16, TextColor3=C.dim, Text="×", AutoButtonColor=false, ZIndex=12 }, { header, corner(8) })
    attachPressScale(closeBtn, 1)
    attachBloom(closeBtn, C.bad, C.accent2)
    closeBtn.MouseEnter:Connect(function() tween(closeBtn,0.14,{ BackgroundColor3=Color3.fromRGB(60,30,34), TextColor3=C.bad }) end)
    closeBtn.MouseLeave:Connect(function() tween(closeBtn,0.14,{ BackgroundColor3=C.panel2, TextColor3=C.dim }) end)
    attachShimmer(header)

    local list = new("ScrollingFrame", { Name="List", Size=UDim2.new(1,-24,1,-98-52), Position=UDim2.fromOffset(12,110), BackgroundTransparency=1, BorderSizePixel=0, ScrollBarThickness=4, ScrollBarImageColor3=C.line, ScrollBarImageTransparency=0.3, CanvasSize=UDim2.new(0,0,0,0), AutomaticCanvasSize=Enum.AutomaticSize.Y, ScrollingDirection=Enum.ScrollingDirection.Y, ElasticBehavior=Enum.ElasticBehavior.WhenScrollable, ZIndex=20 }, { root })
    new("UIListLayout", { Padding=UDim.new(0,8), SortOrder=Enum.SortOrder.LayoutOrder }, { list })

    local status = new("TextLabel", { Name="Status", Size=UDim2.new(1,-24,0,28), Position=UDim2.new(0,12,1,-38), BackgroundTransparency=1, Font=Enum.Font.Gotham, TextSize=11, TextColor3=C.dim2, TextXAlignment=Enum.TextXAlignment.Left, TextTruncate=Enum.TextTruncate.AtEnd, Text="◇  พร้อมใช้งาน   ·   "..#(mapEntry.scripts or {}).." สคริปต์", ZIndex=21 }, { root })

    local function setStatus(text, color)
        status.Text = text; status.TextColor3 = color or C.dim2
        status.TextTransparency = 1
        tween(status, 0.28, { TextTransparency = 0 })
    end

    local closing = false
    local function destroyHub(thenFn)
        if closing then return end
        closing = true
        tween(root, 0.18, { GroupTransparency = 1 }, Enum.EasingStyle.Quad, Enum.EasingDirection.In)
        tween(rootScale, 0.22, { Scale = 0.94 }, Enum.EasingStyle.Quad, Enum.EasingDirection.In)
        tween(blur, 0.22, { Size = 0 }, Enum.EasingStyle.Quad, Enum.EasingDirection.In)
        task.delay(0.24, function()
            blur:Destroy(); gui:Destroy()
            if thenFn then task.spawn(thenFn) end
        end)
    end

    closeBtn.MouseButton1Click:Connect(function() playSound("close"); destroyHub() end)

    local rankW = 40
    for i, s in ipairs(mapEntry.scripts or {}) do
        local emoji = s.emoji or EMOJI[((i-1) % #EMOJI) + 1]

        local row = new("Frame", { Name="Row_"..i, Size=UDim2.new(1,0,0,72), BackgroundColor3=C.row, BackgroundTransparency=1, BorderSizePixel=0, ClipsDescendants=false, LayoutOrder=i, ZIndex=22 }, { list, corner(10) })
        local rowStroke = stroke(C.line, 1, 0.35); rowStroke.Parent = row

        task.delay(i * 0.03, function()
            if not row.Parent then return end
            tween(row, 0.22, { BackgroundTransparency = 0.15 })
        end)

        new("TextLabel", { Size=UDim2.fromOffset(rankW,72), Position=UDim2.fromOffset(0,0), BackgroundTransparency=1, Font=Enum.Font.GothamBold, TextSize=11, TextColor3=C.dim2, Text=string.format("%02d", i), ZIndex=23 }, { row })
        new("Frame", { Size=UDim2.new(0,1,0,44), Position=UDim2.fromOffset(rankW-2,14), BackgroundColor3=C.line, BackgroundTransparency=0.5, BorderSizePixel=0, ZIndex=23 }, { row })

        local icon = new("TextLabel", { Size=UDim2.fromOffset(36,36), Position=UDim2.fromOffset(rankW+8,18), BackgroundColor3=C.panel2, BackgroundTransparency=0.4, BorderSizePixel=0, Font=Enum.Font.GothamBold, TextSize=18, TextColor3=C.text, Text=emoji, ZIndex=24 }, { row, corner(8) })

        new("TextLabel", { Size=UDim2.new(1,-220,0,20), Position=UDim2.fromOffset(rankW+54,14), BackgroundTransparency=1, Font=Enum.Font.GothamSemibold, TextSize=13, TextColor3=C.text, TextXAlignment=Enum.TextXAlignment.Left, TextTruncate=Enum.TextTruncate.AtEnd, Text=s.name, ZIndex=24 }, { row })
        new("TextLabel", { Size=UDim2.new(1,-220,0,16), Position=UDim2.fromOffset(rankW+54,36), BackgroundTransparency=1, Font=Enum.Font.Gotham, TextSize=11, TextColor3=C.dim, TextXAlignment=Enum.TextXAlignment.Left, TextTruncate=Enum.TextTruncate.AtEnd, Text=s.desc or "—", ZIndex=24 }, { row })

        if s.team then
            new("TextLabel", { Size=UDim2.fromOffset(70,14), Position=UDim2.new(1,-180,0,16), BackgroundColor3=C.panel2, BackgroundTransparency=0.3, BorderSizePixel=0, Font=Enum.Font.GothamBold, TextSize=9, TextColor3=C.accent, Text=tostring(s.team):upper(), ZIndex=24 }, { row, corner(4) })
        end

        local runBtn = new("TextButton", { Name="Run", Size=UDim2.fromOffset(84,40), Position=UDim2.new(1,-96,0.5,-20), BackgroundColor3=Color3.fromRGB(46,96,68), BorderSizePixel=0, Font=Enum.Font.GothamBold, TextSize=12, TextColor3=Color3.fromRGB(240,248,240), Text="▶  รัน", AutoButtonColor=false, ZIndex=25 }, { row, corner(8) })
        gradient({ ColorSequenceKeypoint.new(0,Color3.fromRGB(58,130,88)), ColorSequenceKeypoint.new(1,Color3.fromRGB(38,84,60)) }, 90).Parent = runBtn

        attachPressScale(runBtn, 1)
        attachRipple(runBtn)
        local bloom = attachBloom(runBtn, C.good, Color3.fromRGB(120,240,170))
        attachTapMotion(runBtn, runBtn.Position, bloom)

        runBtn.MouseEnter:Connect(function() tween(runBtn, 0.14, { BackgroundColor3 = Color3.fromRGB(62,138,96) }) end)
        runBtn.MouseLeave:Connect(function() tween(runBtn, 0.14, { BackgroundColor3 = Color3.fromRGB(46,96,68) }) end)

        if UIS.MouseEnabled then
            row.MouseEnter:Connect(function()
                tween(row, 0.18, { BackgroundColor3=C.rowHi, BackgroundTransparency=0.05 })
                tween(icon, 0.22, { Size=UDim2.fromOffset(40,40), Position=UDim2.fromOffset(rankW+6,16), TextSize=20 }, Enum.EasingStyle.Back)
                tween(rowStroke, 0.18, { Color=C.accent, Transparency=0.7 })
            end)
            row.MouseLeave:Connect(function()
                tween(row, 0.18, { BackgroundColor3=C.row, BackgroundTransparency=0.15 })
                tween(icon, 0.22, { Size=UDim2.fromOffset(36,36), Position=UDim2.fromOffset(rankW+8,18), TextSize=18 }, Enum.EasingStyle.Back)
                tween(rowStroke, 0.18, { Color=C.line, Transparency=0.35 })
            end)
        end

        runBtn.MouseButton1Click:Connect(function()
            setStatus("⏳  กำลังรัน: "..s.name, C.accent)
            playSound("run")
            spawnToast(root, "เรียกใช้ "..s.name, C.good, "▶")
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
        tween(root, 0.18, { Size = UDim2.fromOffset(nw, nh) })
    end)

    playSound("open")
    tween(root, 0.28, { GroupTransparency = 0 }, Enum.EasingStyle.Quint)
    tween(rootScale, 0.38, { Scale = 1 }, Enum.EasingStyle.Back)

    return gui
end
