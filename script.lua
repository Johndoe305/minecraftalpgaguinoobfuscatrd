--// SERVICES
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UIS = game:GetService("UserInputService")
local player = Players.LocalPlayer
local guiParent = player:WaitForChild("PlayerGui")
local TextureInfo = require(game.ReplicatedStorage:WaitForChild("TextureInfo"))

--// CONFIG 
local BLOCOS = {
    coalore      = { nome = "Coal Ore",      icon = "⬛", cor = Color3.fromRGB(80,  80,  80)  },
    ironore      = { nome = "Iron Ore",      icon = "🟥", cor = Color3.fromRGB(255, 160, 130) },
    goldore      = { nome = "Gold Ore",      icon = "🟨", cor = Color3.fromRGB(255, 230, 50)  },
    diamondore   = { nome = "Diamond Ore",   icon = "🔷", cor = Color3.fromRGB(50,  230, 255) },
    lapisore     = { nome = "Lapis Ore",     icon = "🟦", cor = Color3.fromRGB(30,  100, 255) },
    coalblock    = { nome = "Coal Block",    icon = "⬛", cor = Color3.fromRGB(60,  60,  60)  },
    ironblock    = { nome = "Iron Block",    icon = "🟥", cor = Color3.fromRGB(255, 180, 160) },
    goldblock    = { nome = "Gold Block",    icon = "🟨", cor = Color3.fromRGB(255, 220, 60)  },
    diamondblock = { nome = "Diamond Block", icon = "🔷", cor = Color3.fromRGB(0,   210, 255) },
    lapisblock   = { nome = "Lapis Block",   icon = "🟦", cor = Color3.fromRGB(20,  80,  255) },
    emeraldblock = { nome = "Emerald Block", icon = "🟩", cor = Color3.fromRGB(0,   220, 100) },
}

local TEXTURAS_ALVO = {}
for key, info in pairs(BLOCOS) do
    local id = TextureInfo[key]
    if id then TEXTURAS_ALVO[tostring(id)] = info end
end

--// CORES
local COR_OURO      = Color3.fromRGB(255, 200, 50)
local COR_OCEANO    = Color3.fromRGB(0,   180, 255)
local COR_FLOAT     = Color3.fromRGB(100, 255, 200)
local COR_BG        = Color3.fromRGB(20,  20,  20)
local COR_BG_ATIVO  = Color3.fromRGB(35,  35,  45)
local COR_FUNDO     = Color3.fromRGB(10,  10,  10)
local COR_TITULO    = Color3.fromRGB(34,  139, 34)
local COR_JUMP      = Color3.fromRGB(150, 100, 255)
local COR_FALL      = Color3.fromRGB(255, 100, 100)
local COR_EXTRA     = Color3.fromRGB(255, 180, 100)

--// STATE
local espAtivo = false
local jumpAtivo = false
local fallAtivo = false
local extraExecutado = false
local marcados = {}
local totalEncontrados = 0
local guisCriadas = {}

--// FUNCTIONS
local function limparESP()
    for _, bg in ipairs(marcados) do pcall(bg.Destroy, bg) end
    marcados, totalEncontrados = {}, 0
end

local function escanearESP()
    limparESP()
    for _, obj in ipairs(workspace:GetDescendants()) do
        if obj:IsA("BasePart") then
            for _, child in ipairs(obj:GetChildren()) do
                if child:IsA("Decal") or child:IsA("Texture") then
                    local tex = tostring(child.Texture or "")
                    for id, info in pairs(TEXTURAS_ALVO) do
                        if tex:find(id, 1, true) then
                            totalEncontrados += 1
                            local bg = Instance.new("BillboardGui")
                            bg.Size = UDim2.new(0, 160, 0, 28)
                            bg.AlwaysOnTop = true
                            bg.MaxDistance = 500
                            bg.Adornee = obj
                            bg.Parent = obj
                            local lbl = Instance.new("TextLabel", bg)
                            lbl.Size = UDim2.new(1, 0, 1, 0)
                            lbl.BackgroundTransparency = 1
                            lbl.Text = info.icon .. " " .. info.nome
                            lbl.TextColor3 = info.cor
                            lbl.TextStrokeTransparency = 0
                            lbl.TextStrokeColor3 = Color3.new(0, 0, 0)
                            lbl.Font = Enum.Font.GothamBold
                            lbl.TextSize = 15
                            table.insert(marcados, bg)
                            break
                        end
                    end
                end
            end
        end
    end
end

--// LOCALENTITY
local entity = nil
local function findLocalEntity()
    for _, func in ipairs(getgc()) do
        if type(func) == "function" then
            local info = debug.getinfo(func)
            if info and info.source and info.source:find("LocalEntity") then
                local upvalues = debug.getupvalues(func)
                for _, v in ipairs(upvalues) do
                    if type(v) == "table" and v.Size ~= nil and v.Pos ~= nil then
                        return v
                    end
                end
            end
        end
    end
    return nil
end

--// GUI
local gui = Instance.new("ScreenGui")
gui.Name = "Bott"
gui.ResetOnSpawn = false
gui.IgnoreGuiInset = true
gui.Parent = guiParent

local main = Instance.new("Frame")
main.Size = UDim2.new(0, 260, 0, 220)
main.Position = UDim2.new(0.5, -130, 0.5, -135)
main.BackgroundColor3 = COR_FUNDO
main.Parent = gui
main.Active = true

Instance.new("UICorner", main).CornerRadius = UDim.new(0, 10)

local title = Instance.new("TextLabel", main)
title.Size = UDim2.new(1, 0, 0, 35)
title.BackgroundTransparency = 1
title.Text = "Minecraft Alpha"
title.TextColor3 = COR_TITULO
title.Font = Enum.Font.GothamBold
title.TextSize = 13

local container = Instance.new("Frame", main)
container.Size = UDim2.new(1, -20, 1, -45)
container.Position = UDim2.new(0, 10, 0, 38)
container.BackgroundTransparency = 1

local layout = Instance.new("UIListLayout", container)
layout.Padding = UDim.new(0, 5)

local function createButton(text)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, 0, 0, 34)
    btn.Text = text
    btn.BackgroundColor3 = COR_BG
    btn.Font = Enum.Font.GothamBold
    btn.TextSize = 13
    btn.Parent = container
    Instance.new("UICorner", btn)
    return btn
end

-- 💎 ESP
local espBtn = createButton("💎 Ore ESP: OFF")
espBtn.TextColor3 = COR_OURO
espBtn.Activated:Connect(function()
    espAtivo = not espAtivo
    espBtn.BackgroundColor3 = espAtivo and COR_BG_ATIVO or COR_BG
    espBtn.Text = espAtivo and "💎 Ore ESP: ON" or "💎 Ore ESP: OFF"
    if espAtivo then escanearESP() else limparESP() end
end)

-- 🦘 INFINITE JUMP
local jumpBtn = createButton("🦘 Infinite Jump: OFF")
jumpBtn.TextColor3 = COR_JUMP
jumpBtn.Activated:Connect(function()
    jumpAtivo = not jumpAtivo
    jumpBtn.BackgroundColor3 = jumpAtivo and COR_BG_ATIVO or COR_BG
    jumpBtn.Text = jumpAtivo and "🦘 Infinite Jump: ON" or "🦘 Infinite Jump: OFF"
    
    if jumpAtivo then
        if not entity then entity = findLocalEntity() end
        if entity then
            entity.OnGround = true
            print("🦘 Infinite Jump ATIVADO!")
        else
            print("❌ LocalEntity não encontrado")
            jumpAtivo = false
            jumpBtn.Text = "🦘 Infinite Jump: OFF"
        end
    else
        if entity then entity.OnGround = nil end
        print("🦘 Infinite Jump DESATIVADO")
    end
end)

-- 🛡️ ANTI FALL DAMAGE
local fallBtn = createButton("🛡️ Anti Fall Damage: OFF")
fallBtn.TextColor3 = COR_FALL
fallBtn.Activated:Connect(function()
    fallAtivo = not fallAtivo
    fallBtn.BackgroundColor3 = fallAtivo and COR_BG_ATIVO or COR_BG
    fallBtn.Text = fallAtivo and "🛡️ Anti Fall Damage: ON" or "🛡️ Anti Fall Damage: OFF"
    
    if fallAtivo then
        if not entity then entity = findLocalEntity() end
        if entity then
            print("🛡️ Anti Fall Damage ATIVADO!")
        else
            print("❌ LocalEntity não encontrado")
            fallAtivo = false
            fallBtn.Text = "🛡️ Anti Fall Damage: OFF"
        end
    else
        if entity then
            entity.lastPos = nil
        end
        print("🛡️ Anti Fall Damage DESATIVADO")
    end
end)

-- ⭐ EXTRA (click, não toggle)
local extraBtn = createButton("⭐ EXTRA")
extraBtn.TextColor3 = COR_EXTRA
extraBtn.Activated:Connect(function()
    if extraExecutado then
        extraBtn.Text = "⚠️ Already executed"
        task.wait(1)
        extraBtn.Text = "⭐ EXTRA"
        extraBtn.BackgroundColor3 = COR_BG
        return
    end
    
    extraExecutado = true
    extraBtn.Text = "⏳ Executing..."
    extraBtn.BackgroundColor3 = COR_BG_ATIVO
    
    local ok, err = pcall(function()
        loadstring(game:HttpGet("https://raw.githubusercontent.com/Johndoe305/ExtraGui/refs/heads/main/script.lua"))()
    end)
    
    if ok then
        extraBtn.Text = "✅ EXTRA EXECUTED"
        print("✅ Extra executado com sucesso!")
    else
        extraBtn.Text = "❌ Execution error"
        print("❌ Erro:", err)
        extraExecutado = false
    end
    
    -- ⭐ Volta ao normal depois de 1s
    task.wait(1)
    extraBtn.Text = "⭐ EXTRA"
    extraBtn.BackgroundColor3 = COR_BG
end)

-- DRAG
local dragging, dragStart, startPos
title.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true; dragStart = input.Position; startPos = main.Position
    end
end)
UIS.InputChanged:Connect(function(input)
    if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
        local delta = input.Position - dragStart
        main.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
end)
UIS.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = false
    end
end)

-- AUTO-UPDATE
task.spawn(function() while true do task.wait(30); if espAtivo then escanearESP() end end end)
Players.LocalPlayer.CharacterAdded:Connect(function()
    if espAtivo then task.wait(1); escanearESP() end
end)

-- LOOP do Infinite Jump
RunService.RenderStepped:Connect(function()
    if jumpAtivo and entity then
        entity.OnGround = true
    end
end)

-- LOOP do Anti Fall Damage
RunService.RenderStepped:Connect(function()
    if fallAtivo and entity then
        local char = player.Character
        if char then
            local root = char:FindFirstChild("HumanoidRootPart")
            if root then
                local currentPos = root.Position / 3
                entity.lastPos = currentPos + Vector3.new(0, -99999999, 0)
            end
        end
    end
end)

-- NOTIFICAÇÃO
game:GetService("StarterGui"):SetCore("SendNotification", {
    Title = "Made by Old Scripts";
    Text = "Script loaded";
    Icon = "rbxassetid://15794846967"; -- icone de virus so pra dar um pouco de susto kkkk
    Duration = 6;
    Button1 = "OK";
    Callback = callback;
})

-- Somzinho de carregado
task.spawn(function()
    local s = Instance.new("Sound")
    s.SoundId = "rbxassetid://3398620867"
    s.Volume = 0.4
    s.Parent = game:GetService("SoundService")
    s:Play()
    task.delay(3, function() s:Destroy() end)
end)

print("[loaded]")
