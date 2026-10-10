-- ui_core.lua · helpers + effects
local TweenService = game:GetService("TweenService")
local RunService   = game:GetService("RunService")
local UIS          = game:GetService("UserInputService")
local SoundService = game:GetService("SoundService")
local Players      = game:GetService("Players")
local LP           = Players.LocalPlayer

local SOUNDS = {open="rbxassetid://",close="rbxassetid://",hover="rbxassetid://",press="rbxassetid://",run="rbxassetid://"}
local VOL    = {open=0.45,close=0.40,hover=0.12,press=0.32,run=0.50}

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
    local id=SOUNDS[key]
    if not id or id=="rbxassetid://" then return end
    local s=Instance.new("Sound")
    s.SoundId=id; s.Volume=VOL[key] or 0.3; s.Parent=SoundService
    s:Play(); s.Ended:Connect(function() s:Destroy() end)
    task.delay(3,function() if s.Parent then s:Destroy() end end)
end

local function pickParent()
    if gethui then local ok,h=pcall(gethui); if ok and h then return h end end
    local ok,cg=pcall(function() return game:GetService("CoreGui") end)
    if ok and cg then
        local p=Instance.new("Folder")
        if pcall(function() p.Parent=cg end) then return cg end
        p:Destroy()
    end
    return LP:WaitForChild("PlayerGui")
end

local function new(class,props,children)
    local i=Instance.new(class)
    for k,v in pairs(props or {}) do i[k]=v end
    for _,c in ipairs(children or {}) do c.Parent=i end
    return i
end
local function corner(r) return new("UICorner",{CornerRadius=UDim.new(0,r or 8)}) end
local function stroke(c,t,tr) return new("UIStroke",{Color=c or C.line,Thickness=t or 1,Transparency=tr or 0,ApplyStrokeMode=Enum.ApplyStrokeMode.Border}) end
local function gradient(stops,rot) return new("UIGradient",{Color=ColorSequence.new(stops),Rotation=rot or 0}) end
local function tween(o,t,p,s,d)
    local x=TweenService:Create(o,TweenInfo.new(t,s or Enum.EasingStyle.Quad,d or Enum.EasingDirection.Out),p)
    x:Play(); return x
end

local function attachRipple(btn)
    btn.ClipsDescendants=true
    btn.MouseButton1Down:Connect(function(x,y)
        local rx=x-btn.AbsolutePosition.X
        local ry=y-btn.AbsolutePosition.Y
        local size=math.max(btn.AbsoluteSize.X,btn.AbsoluteSize.Y)*1.6
        local rip=new("Frame",{Size=UDim2.fromOffset(size,size),Position=UDim2.fromOffset(rx-size/2,ry-size/2),BackgroundColor3=C.text,BackgroundTransparency=0.72,BorderSizePixel=0,ZIndex=btn.ZIndex+2},{btn,corner(999)})
        tween(rip,0.55,{Size=UDim2.fromOffset(size*2,size*2),BackgroundTransparency=1})
        task.delay(0.55,function() rip:Destroy() end)
    end)
end

local function attachPressScale(btn,base)
    base=base or 1
    local s=Instance.new("UIScale",btn); s.Scale=base
    btn.MouseButton1Down:Connect(function() tween(s,0.08,{Scale=base*0.92}) end)
    btn.MouseButton1Up:Connect(function() tween(s,0.22,{Scale=base},Enum.EasingStyle.Back) end)
    btn.MouseLeave:Connect(function() tween(s,0.22,{Scale=base},Enum.EasingStyle.Back) end)
    return s
end

local function attachBloom(btn,cIn,cOut)
    cIn=cIn or C.accent; cOut=cOut or C.accent2
    local glow=new("Frame",{Size=UDim2.new(1,6,1,6),Position=UDim2.fromOffset(-3,-3),BackgroundColor3=cOut,BackgroundTransparency=0.85,BorderSizePixel=0,ZIndex=btn.ZIndex-1},{btn.Parent,corner(12)})
    local sync
    sync=RunService.Heartbeat:Connect(function()
        if not (btn.Parent and glow.Parent) then sync:Disconnect() return end
        glow.Size=UDim2.new(1,6,1,6)
        glow.Position=UDim2.fromOffset(btn.Position.X.Offset-3,btn.Position.Y.Offset-3)
    end)
    local sIn=stroke(cIn,1,0.45); sIn.Parent=btn
    local sOut=stroke(cOut,3,0.80); sOut.Parent=btn
    task.spawn(function()
        while btn.Parent do
            tween(sOut,1.6,{Transparency=0.65},Enum.EasingStyle.Sine,Enum.EasingDirection.InOut)
            tween(glow,1.6,{BackgroundTransparency=0.78},Enum.EasingStyle.Sine,Enum.EasingDirection.InOut)
            task.wait(1.6)
            if not btn.Parent then break end
            tween(sOut,1.6,{Transparency=0.85},Enum.EasingStyle.Sine,Enum.EasingDirection.InOut)
            tween(glow,1.6,{BackgroundTransparency=0.88},Enum.EasingStyle.Sine,Enum.EasingDirection.InOut)
            task.wait(1.6)
        end
    end)
    local function flash(s)
        s=s or 1
        tween(sIn,0.06,{Transparency=math.max(0,0.45-0.35*s),Thickness=1+s})
        tween(sOut,0.06,{Transparency=math.max(0,0.80-0.55*s),Thickness=3+2*s})
        tween(glow,0.06,{BackgroundTransparency=math.max(0.4,0.85-0.4*s)})
        task.delay(0.10,function()
            if not btn.Parent then return end
            tween(sIn,0.35,{Transparency=0.45,Thickness=1})
            tween(sOut,0.35,{Transparency=0.80,Thickness=3})
            tween(glow,0.35,{BackgroundTransparency=0.85})
        end)
    end
    btn.MouseEnter:Connect(function() flash(0.4) end)
    return {flash=flash}
end

local function attachTapMotion(btn,basePos,bloom)
    basePos=basePos or btn.Position
    local sel=false
    local thr
    btn.MouseButton1Down:Connect(function()
        tween(btn,0.08,{Position=UDim2.new(basePos.X.Scale,basePos.X.Offset-3,basePos.Y.Scale,basePos.Y.Offset)})
        if bloom then bloom.flash(1) end
        playSound("press")
    end)
    btn.MouseButton1Up:Connect(function() tween(btn,0.28,{Position=basePos},Enum.EasingStyle.Back) end)
    btn.MouseLeave:Connect(function() sel=false; tween(btn,0.22,{Position=basePos},Enum.EasingStyle.Back) end)
    btn.MouseEnter:Connect(function()
        sel=true
        if thr then return end
        thr=task.spawn(function()
            local up=true
            while sel and btn.Parent do
                tween(btn,0.9,{Position=UDim2.new(basePos.X.Scale,basePos.X.Offset,basePos.Y.Scale,basePos.Y.Offset+(up and -2 or 0))},Enum.EasingStyle.Sine,Enum.EasingDirection.InOut)
                task.wait(0.9)
                up=not up
            end
            if btn.Parent then tween(btn,0.2,{Position=basePos}) end
            thr=nil
        end)
    end)
end

local function attachAurora(parent,w,h)
    local wrap=new("Frame",{Size=UDim2.fromScale(1,1),BackgroundTransparency=1,ClipsDescendants=true,ZIndex=0},{parent,corner(12)})
    local pals={{C.accent,C.accent2},{C.accent3,C.accent}}
    local blobs={}
    for i=1,2 do
        local pal=pals[i]
        local blob=new("Frame",{Size=UDim2.fromOffset(w*0.9,h*0.55),Position=UDim2.fromOffset((i-1)*w*0.4-w*0.2,(i-1)*h*0.3),BackgroundColor3=pal[1],BackgroundTransparency=0.88,BorderSizePixel=0,ZIndex=0},{wrap,corner(999)})
        gradient({ColorSequenceKeypoint.new(0,pal[1]),ColorSequenceKeypoint.new(1,pal[2])},i*60).Parent=blob
        blobs[i]=blob
    end
    task.spawn(function()
        local t=0
        while wrap.Parent do
            t=t+0.006
            for i,b in ipairs(blobs) do
                if not b.Parent then break end
                local ph=t+i*2.1
                b.Position=UDim2.fromOffset((i-1)*w*0.4-w*0.2+math.sin(ph)*(w*0.08),(i-1)*h*0.3+math.cos(ph*0.8)*(h*0.05))
            end
            task.wait(1/30)
        end
    end)
    local vig=new("Frame",{Size=UDim2.fromScale(1,1),BackgroundColor3=C.bgDeep,BackgroundTransparency=0.55,BorderSizePixel=0,ZIndex=1},{wrap,corner(12)})
    new("UIGradient",{Transparency=NumberSequence.new({NumberSequenceKeypoint.new(0,0.9),NumberSequenceKeypoint.new(0.35,0.4),NumberSequenceKeypoint.new(0.65,0.4),NumberSequenceKeypoint.new(1,0.9)}),Rotation=90}).Parent=vig
end

local function attachShimmer(header)
    local shim=new("Frame",{Size=UDim2.new(0.3,0,1,0),Position=UDim2.fromOffset(-200,0),BackgroundColor3=Color3.fromRGB(255,255,255),BackgroundTransparency=0.85,BorderSizePixel=0,ZIndex=5},{header})
    new("UIGradient",{Transparency=NumberSequence.new({NumberSequenceKeypoint.new(0,1),NumberSequenceKeypoint.new(0.5,0),NumberSequenceKeypoint.new(1,1)}),Rotation=90}).Parent=shim
    task.delay(0.35,function()
        if not shim.Parent then return end
        tween(shim,1.0,{Position=UDim2.new(1,200,0,0)},Enum.EasingStyle.Quart,Enum.EasingDirection.Out)
        task.delay(1.05,function() if shim.Parent then shim:Destroy() end end)
    end)
end

local function spawnToast(parent,text,color,icon)
    icon=icon or "✨"
    local toast=new("Frame",{Size=UDim2.fromOffset(260,48),Position=UDim2.new(1,-240,1,-68),BackgroundColor3=C.panel2,BackgroundTransparency=1,BorderSizePixel=0,ZIndex=200},{parent,corner(10)})
    stroke(color or C.accent,1,0.5).Parent=toast
    new("TextLabel",{Size=UDim2.fromOffset(30,48),Position=UDim2.fromOffset(8,0),BackgroundTransparency=1,Font=Enum.Font.GothamBold,TextSize=16,TextColor3=color or C.accent,Text=icon,ZIndex=201},{toast})
    new("TextLabel",{Size=UDim2.new(1,-50,1,0),Position=UDim2.fromOffset(42,0),BackgroundTransparency=1,Font=Enum.Font.GothamSemibold,TextSize=12,TextColor3=C.text,TextXAlignment=Enum.TextXAlignment.Left,TextTruncate=Enum.TextTruncate.AtEnd,Text=text,ZIndex=201},{toast})
    tween(toast,0.24,{Position=UDim2.new(1,-280,1,-68),BackgroundTransparency=0.1},Enum.EasingStyle.Back)
    task.delay(2.6,function()
        if not toast.Parent then return end
        tween(toast,0.22,{Position=UDim2.new(1,-240,1,-68),BackgroundTransparency=1},Enum.EasingStyle.Quad,Enum.EasingDirection.In)
        task.delay(0.24,function() toast:Destroy() end)
    end)
end

local function makeDraggable(frame,handle)
    local dragging,dragStart,startPos
    handle.InputBegan:Connect(function(input)
        if input.UserInputType==Enum.UserInputType.MouseButton1 or input.UserInputType==Enum.UserInputType.Touch then
            dragging=true; dragStart=input.Position; startPos=frame.Position
            input.Changed:Connect(function()
                if input.UserInputState==Enum.UserInputState.End then dragging=false end
            end)
        end
    end)
    UIS.InputChanged:Connect(function(input)
        if not dragging then return end
        if input.UserInputType==Enum.UserInputType.MouseMovement or input.UserInputType==Enum.UserInputType.Touch then
            local d=input.Position-dragStart
            frame.Position=UDim2.new(startPos.X.Scale,startPos.X.Offset+d.X,startPos.Y.Scale,startPos.Y.Offset+d.Y)
        end
    end)
end

return {
    C=C, EMOJI=EMOJI,
    playSound=playSound, pickParent=pickParent,
    new=new, corner=corner, stroke=stroke, gradient=gradient, tween=tween,
    attachRipple=attachRipple, attachPressScale=attachPressScale,
    attachBloom=attachBloom, attachTapMotion=attachTapMotion,
    attachAurora=attachAurora, attachShimmer=attachShimmer,
    spawnToast=spawnToast, makeDraggable=makeDraggable,
}
