-- ====================================================================
-- KAVO HUB MOBILE - VERSÃO ULTRA PREMIUM E FLUIDA PARA DELTA
-- ====================================================================

-- Inicialização da Interface Nativa (Não baixa arquivos externos)
local Kavo = {}
local TweenService = game:GetService("TweenService")
local Player = game.Players.LocalPlayer
local RunService = game:GetService("RunService")
local Lighting = game:GetService("Lighting")

-- Criar a Base da UI de forma indestrutível no Delta
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "KavoHubMobile"
ScreenGui.ResetOnSpawn = false
pcall(function() ScreenGui.Parent = Player:WaitForChild("PlayerGui") end)

-- Botão Flutuante Móvel (Essencial para abrir/fechar no celular)
local ToggleBtn = Instance.new("TextButton")
ToggleBtn.Parent = ScreenGui
ToggleBtn.Size = UDim2.new(0, 55, 0, 35)
ToggleBtn.Position = UDim2.new(0.02, 0, 0.15, 0)
ToggleBtn.BackgroundColor3 = Color3.fromRGB(0, 120, 220)
ToggleBtn.Text = "MENU"
ToggleBtn.Font = Enum.Font.SourceSansBold
ToggleBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
ToggleBtn.TextSize = 13
ToggleBtn.ZIndex = 10

-- Tornar o botão flutuante arrastável na tela touch
local draggingBtn, dragInputBtn, dragStartBtn, startPosBtn
ToggleBtn.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        draggingBtn = true dragStartBtn = input.Position startPosBtn = ToggleBtn.Position
    end
end)
ToggleBtn.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.Touch then dragInputBtn = input end
end)
RunService.RenderStepped:Connect(function()
    if draggingBtn and dragInputBtn then
        local delta = dragInputBtn.Position - dragStartBtn
        ToggleBtn.Position = UDim2.new(startPosBtn.X.Scale, startPosBtn.X.Offset + delta.X, startPosBtn.Y.Scale, startPosBtn.Y.Offset + delta.Y)
    end
end)
ToggleBtn.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then draggingBtn = false end
end)

-- Painel Principal do Menu
local MainFrame = Instance.new("Frame")
MainFrame.Parent = ScreenGui
MainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
MainFrame.Position = UDim2.new(0.3, 0, 0.2, 0)
MainFrame.Size = UDim2.new(0, 380, 0, 260)
MainFrame.Active = true
MainFrame.Visible = true

-- Abrir e fechar o menu ao tocar no botão flutuante
ToggleBtn.MouseButton1Click:Connect(function()
    MainFrame.Visible = not MainFrame.Visible
end)

-- Sistema de Arrastar o Painel Principal
local dragging, dragInput, dragStart, startPos
MainFrame.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true dragStart = input.Position startPos = MainFrame.Position
    end
end)
MainFrame.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.Touch then dragInput = input end
end)
RunService.RenderStepped:Connect(function()
    if dragging and dragInput then
        local delta = dragInput.Position - dragStart
        MainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
end)
MainFrame.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then dragging = false end
end)

-- Título e Abas Laterais
local TopBar = Instance.new("Frame")
TopBar.Parent = MainFrame TopBar.Size = UDim2.new(1, 0, 0, 30) TopBar.BackgroundColor3 = Color3.fromRGB(30, 30, 35)

local Title = Instance.new("TextLabel")
Title.Parent = TopBar Title.Size = UDim2.new(1, -30, 1, 0) Title.Position = UDim2.new(0, 10, 0, 0)
Title.Text = "KAVO OPTIMIZED HUB" Title.Font = Enum.Font.SourceSansBold Title.TextColor3 = Color3.fromRGB(255, 255, 255) Title.TextSize = 14 Title.TextXAlignment = Enum.TextXAlignment.Left Title.BackgroundTransparency = 1

local TabContainer = Instance.new("Frame")
TabContainer.Parent = MainFrame TabContainer.Position = UDim2.new(0, 5, 0, 35) TabContainer.Size = UDim2.new(0, 100, 1, -40) TabContainer.BackgroundColor3 = Color3.fromRGB(25, 25, 30)

local ContentContainer = Instance.new("Frame")
ContentContainer.Parent = MainFrame ContentContainer.Position = UDim2.new(0, 110, 0, 35) ContentContainer.Size = UDim2.new(1, -115, 1, -40) ContentContainer.BackgroundTransparency = 1

local listLayout = Instance.new("UIListLayout") listLayout.Parent = TabContainer listLayout.Padding = UDim.new(0, 3)

-- Motores e Variáveis de Funcionamento Interno
local Config = { Speed = 16, Jump = 50, Fly = false, KeepFly = false, KeepSpeed = false, ESP = false, FastMode = false, NoShake = false, FullBright = false, TargetSlot = nil, SavedToolName = nil }

-- Criador Dinâmico de Abas
local currentTabFrame = nil
local function createTab(name)
    local tabBtn = Instance.new("TextButton")
    tabBtn.Parent = TabContainer tabBtn.Size = UDim2.new(1, 0, 0, 30) tabBtn.BackgroundColor3 = Color3.fromRGB(35, 35, 40)
    tabBtn.Text = name tabBtn.Font = Enum.Font.SourceSansBold tabBtn.TextColor3 = Color3.fromRGB(200, 200, 200) tabBtn.TextSize = 12
    
    local tabFrame = Instance.new("ScrollingFrame")
    tabFrame.Parent = ContentContainer tabFrame.Size = UDim2.new(1, 0, 1, 0) tabFrame.BackgroundTransparency = 1 tabFrame.Visible = false
    tabFrame.CanvasSize = UDim2.new(0, 0, 0, 400) tabFrame.ScrollBarThickness = 2
    local contentLayout = Instance.new("UIListLayout") contentLayout.Parent = tabFrame contentLayout.Padding = UDim.new(0, 5)

    tabBtn.MouseButton1Click:Connect(function()
        if currentTabFrame then currentTabFrame.Visible = false end
        tabFrame.Visible = true currentTabFrame = tabFrame
        for _, v in pairs(TabContainer:GetChildren()) do if v:IsA("TextButton") then v.BackgroundColor3 = Color3.fromRGB(35, 35, 40) end end
        tabBtn.BackgroundColor3 = Color3.fromRGB(0, 120, 220)
    end)
    if not currentTabFrame then tabFrame.Visible = true currentTabFrame = tabFrame tabBtn.BackgroundColor3 = Color3.fromRGB(0, 120, 220) end
    return tabFrame
end

-- Criador de Controles
local function addToggle(tab, text, callback)
    local btn = Instance.new("TextButton")
    btn.Parent = tab btn.Size = UDim2.new(1, -5, 0, 32) btn.BackgroundColor3 = Color3.fromRGB(35, 35, 40)
    btn.Text = text .. ": DESATIVADO" btn.Font = Enum.Font.SourceSansBold btn.TextColor3 = Color3.fromRGB(220, 70, 70) btn.TextSize = 12
    local state = false
    btn.MouseButton1Click:Connect(function()
        state = not state
        btn.Text = state and text .. ": ATIVADO" or text .. ": DESATIVADO"
        btn.BackgroundColor3 = state and Color3.fromRGB(40, 130, 65) or Color3.fromRGB(35, 35, 40)
        btn.TextColor3 = state and Color3.fromRGB(255, 255, 255) or Color3.fromRGB(220, 70, 70)
        callback(state)
    end)
end

local function addTextBox(tab, placeholder, callback)
    local box = Instance.new("TextBox")
    box.Parent = tab box.Size = UDim2.new(1, -5, 0, 30) box.BackgroundColor3 = Color3.fromRGB(30, 30, 35)
    box.Text = placeholder box.TextColor3 = Color3.fromRGB(160, 160, 160) box.TextSize = 12 box.ClearTextOnFocus = true
    box.FocusLost:Connect(function() callback(box.Text) end)
    return box
end

-- Instanciando as Abas
local Tab1 = createTab("Slots/Itens")
local Tab2 = createTab("Movimento")
local Tab3 = createTab("Visual/FPS")

-- Lógica dos Slots
local StatusLabel = Instance.new("TextLabel")
StatusLabel.Parent = Tab1 StatusLabel.Size = UDim2.new(1, -5, 0, 35) StatusLabel.BackgroundColor3 = Color3.fromRGB(30, 30, 35) StatusLabel.Text = "Nenhum slot travado" StatusLabel.Font = Enum.Font.SourceSansItalic StatusLabel.TextColor3 = Color3.fromRGB(200, 200, 200) StatusLabel.TextSize = 12

local function updateInventoryCheck()
    local tools = Player.Backpack:GetChildren()
    if Player.Character then
        for _, t in pairs(Player.Character:GetChildren()) do if t:IsA("Tool") then table.insert(tools, t) end end
    end
    if Config.TargetSlot and tools[Config.TargetSlot] then
        Config.SavedToolName = tools[Config.TargetSlot].Name
        StatusLabel.Text = "Item Monitorado [" .. Config.TargetSlot .. "]: " .. Config.SavedToolName
    else
        StatusLabel.Text = "Slot " .. (Config.TargetSlot or "?") .. " está vazio."
    end
end

addTextBox(Tab1, "Digitar número do Slot (1-9)", function(txt)
    local num = tonumber(txt)
    if num and num >= 1 and num <= 9 then Config.TargetSlot = num updateInventoryCheck() end
end)

local RefBtn = Instance.new("TextButton")
RefBtn.Parent = Tab1 RefBtn.Size = UDim2.new(1,-5,0,30) RefBtn.BackgroundColor3 = Color3.fromRGB(0,120,220) RefBtn.Text = "🔄 Refresh Sincronizar" RefBtn.Font = Enum.Font.SourceSansBold RefBtn.TextColor3 = Color3.fromRGB(255,255,255) RefBtn.TextSize = 12
RefBtn.MouseButton1Click:Connect(updateInventoryCheck)

-- Lógica de Movimentação
addTextBox(Tab2, "Definir Velocidade (Ex: 70)", function(txt) Config.Speed = tonumber(txt) or 16 end)
addTextBox(Tab2, "Definir Altura Pulo (Ex: 80)", function(txt) Config.Jump = tonumber(txt) or 50 end)
addToggle(Tab2, "Fly (Voo Tridimensional)", function(v) Config.Fly = v end)
addToggle(Tab2, "Manter Fly Pós-Morte", function(v) Config.KeepFly = v end)
addToggle(Tab2, "Manter Velocidade Pós-Morte", function(v) Config.KeepSpeed = v end)

-- Lógica de Visuais
addToggle(Tab3, "Player ESP", function(v) Config.ESP = v end)
addToggle(Tab3, "Fast Mode (Otimizar FPS)", function(v) Config.FastMode = v end)
addToggle(Tab3, "No Camera Shake", function(v) Config.NoShake = v end)
addToggle(Tab3, "FullBright (Iluminar)", function(v) Config.FullBright = v end)

-- Motores por Trás das Funções (Performance Forçada)
local flyGyro, flyVelocity
RunService.RenderStepped:Connect(function()
    local char = Player.Character

