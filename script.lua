-- ====================================================================
-- ULTRA HUB MOBILE - VERSÃO DEFINITIVA PARA GITHUB E DELTA EXECUTOR
-- ====================================================================
local Player = game.Players.LocalPlayer
local RunService = game:GetService("RunService")
local Lighting = game:GetService("Lighting")

-- Criar a interface de forma estável no Mobile (Ignora restrições do Delta)
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "DeltaUltimateHub"
ScreenGui.ResetOnSpawn = false
pcall(function()
    ScreenGui.Parent = Player:WaitForChild("PlayerGui", 10)
end)

-- Sistema de Arrastar Janelas via Touch Manual (Evita travamentos comuns de tela)
local function makeDraggable(frame)
    local dragging, dragInput, dragStart, startPos
    frame.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = frame.Position
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then dragging = false end
            end)
        end
    end)
    frame.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseValueUp or input.UserInputType == Enum.UserInputType.Touch then
            dragInput = input
        end
    end)
    RunService.RenderStepped:Connect(function()
        if dragging and dragInput then
            local delta = dragInput.Position - dragStart
            frame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)
end

-- ====================================================================
-- JANELA 1: GERENCIADOR DE INVENTÁRIO (SLOTS)
-- ====================================================================
local MainFrame = Instance.new("Frame")
MainFrame.Parent = ScreenGui
MainFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
MainFrame.Position = UDim2.new(0.05, 0, 0.2, 0)
MainFrame.Size = UDim2.new(0, 240, 0, 340)
MainFrame.Active = true
makeDraggable(MainFrame)

local Title = Instance.new("TextLabel")
Title.Parent = MainFrame
Title.BackgroundColor3 = Color3.fromRGB(40, 40, 45)
Title.Size = UDim2.new(1, 0, 0, 30)
Title.Font = Enum.Font.SourceSansBold
Title.Text = "  GERENCIADOR DE SLOTS"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.TextSize = 14
Title.TextXAlignment = Enum.TextXAlignment.Left

local RefreshBtn = Instance.new("TextButton")
RefreshBtn.Parent = MainFrame
RefreshBtn.BackgroundColor3 = Color3.fromRGB(0, 120, 220)
RefreshBtn.Position = UDim2.new(1, -75, 0, 3)
RefreshBtn.Size = UDim2.new(0, 70, 0, 24)
RefreshBtn.Font = Enum.Font.SourceSansBold
RefreshBtn.Text = "🔄 Refresh"
RefreshBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
RefreshBtn.TextSize = 12

local Scroll = Instance.new("ScrollingFrame")
Scroll.Parent = MainFrame
Scroll.BackgroundTransparency = 1
Scroll.Position = UDim2.new(0, 5, 0, 35)
Scroll.Size = UDim2.new(1, -10, 1, -45)
Scroll.CanvasSize = UDim2.new(0, 0, 0, 320)
Scroll.ScrollBarThickness = 3

local ListLayout = Instance.new("UIListLayout")
ListLayout.Parent = Scroll
ListLayout.Padding = UDim.new(0, 4)

local targetSlot = nil
local savedToolName = nil
local slotButtons = {}

local function refreshInventoryUI()
    for i = 1, 9 do
        if slotButtons[i] then
            slotButtons[i].Text = "Slot " .. i .. ": [Vazio]"
            slotButtons[i].TextColor3 = Color3.fromRGB(140, 140, 140)
        end
    end
    local tools = Player.Backpack:GetChildren()
    if Player.Character then
        for _, t in pairs(Player.Character:GetChildren()) do
            if t:IsA("Tool") then table.insert(tools, t) end
        end
    end
    for i = 1, 9 do
        if slotButtons[i] and tools[i] then
            slotButtons[i].Text = "Slot " .. i .. ": " .. tools[i].Name
            slotButtons[i].TextColor3 = Color3.fromRGB(255, 255, 255)
            if targetSlot == i then savedToolName = tools[i].Name end
        end
    end
end

for i = 1, 9 do
    local SlotBtn = Instance.new("TextButton")
    SlotBtn.Parent = Scroll
    SlotBtn.Size = UDim2.new(1, 0, 0, 28)
    SlotBtn.BackgroundColor3 = Color3.fromRGB(35, 35, 40)
    SlotBtn.Font = Enum.Font.SourceSans
    SlotBtn.TextSize = 13
    slotButtons[i] = SlotBtn

    SlotBtn.MouseButton1Click:Connect(function()
        for j = 1, 9 do if slotButtons[j] then slotButtons[j].BackgroundColor3 = Color3.fromRGB(35, 35, 40) end end
        SlotBtn.BackgroundColor3 = Color3.fromRGB(0, 100, 180)
        targetSlot = i
        local tools = Player.Backpack:GetChildren()
        if Player.Character then
            for _, t in pairs(Player.Character:GetChildren()) do if t:IsA("Tool") then table.insert(tools, t) end end
        end
        savedToolName = tools[i] and tools[i].Name or nil
    end)
end
RefreshBtn.MouseButton1Click:Connect(refreshInventoryUI)

-- ====================================================================
-- JANELA 2: MOVEMENT & VISUAL TOOLS
-- ====================================================================
local ToolsFrame = Instance.new("Frame")
ToolsFrame.Parent = ScreenGui
ToolsFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
ToolsFrame.Position = UDim2.new(0, 260, 0, 50)
ToolsFrame.Size = UDim2.new(0, 230, 0, 400)
ToolsFrame.Active = true
makeDraggable(ToolsFrame)

local ToolsTitle = Instance.new("TextLabel")
ToolsTitle.Parent = ToolsFrame
ToolsTitle.BackgroundColor3 = Color3.fromRGB(45, 45, 50)
ToolsTitle.Size = UDim2.new(1, 0, 0, 30)
ToolsTitle.Font = Enum.Font.SourceSansBold
ToolsTitle.Text = "  MOVIMENTAÇÃO E VISUAIS"
ToolsTitle.TextColor3 = Color3.fromRGB(255, 255, 255)
ToolsTitle.TextSize = 14
ToolsTitle.TextXAlignment = Enum.TextXAlignment.Left

local SpeedInput = Instance.new("TextBox")
SpeedInput.Parent = ToolsFrame
SpeedInput.Position = UDim2.new(0, 10, 0, 40)
SpeedInput.Size = UDim2.new(1, -20, 0, 28)
SpeedInput.BackgroundColor3 = Color3.fromRGB(35, 35, 40)
SpeedInput.Text = "Definir Velocidade (Ex: 60)"
SpeedInput.TextColor3 = Color3.fromRGB(180, 180, 180)
SpeedInput.TextSize = 12
SpeedInput.ClearTextOnFocus = true

local customSpeed = 16
local flying = false
local keepFly = false
local keepSpeed = false
local espActive = false
local fastMode = false
local noShake = false
local fullBright = false

SpeedInput.FocusLost:Connect(function()
    customSpeed = tonumber(SpeedInput.Text) or 16
end)

local function createToggle(parent, text, pos, callback)
    local btn = Instance.new("TextButton")
    btn.Parent = parent
    btn.Position = pos
    btn.Size = UDim2.new(1, -20, 0, 30)
    btn.BackgroundColor3 = Color3.fromRGB(45, 45, 50)
    btn.Font = Enum.Font.SourceSansBold
    btn.Text = text .. ": OFF"
    btn.TextColor3 = Color3.fromRGB(230, 70, 70)
    btn.TextSize = 12
    
    local state = false
    btn.MouseButton1Click:Connect(function()
        state = not state
        btn.Text = state and text .. ": ON" or text .. ": OFF"
        btn.BackgroundColor3 = state and Color3.fromRGB(40, 140, 70) or Color3.fromRGB(45, 45, 50)
        btn.TextColor3 = state and Color3.fromRGB(255, 255, 255) or Color3.fromRGB(230, 70, 70)
        callback(state)
    end)
    return btn
end

-- Instanciação dos Controles
createToggle(ToolsFrame, "Fly (Voo Livre)", UDim2.new(0, 10, 0, 75), function(v) flying = v end)
createToggle(ToolsFrame, "Keep Fly on Death", UDim2.new(0, 10, 0, 110), function(v) keepFly = v end)
createToggle(ToolsFrame, "Keep Speed on Death", UDim2.new(0, 10, 0, 145), function(v) keepSpeed = v end)
createToggle(ToolsFrame, "Player ESP", UDim2.new(0, 10, 0, 180), function(v) espActive = v end)
createToggle(ToolsFrame, "Fast Mode (Otimizar)", UDim2.new(0, 10, 0, 215), function(v) fastMode = v end)
createToggle(ToolsFrame, "No Camera Shake", UDim2.new(0, 10, 0, 250), function(v) noShake = v end)
createToggle(ToolsFrame, "FullBright (Luminar)", UDim2.new(0, 10, 0, 285), function(v) fullBright = v end)

local CloseBtn = Instance.new("TextButton")
CloseBtn.Parent = MainFrame
CloseBtn.BackgroundColor3 = Color3.fromRGB(180, 40, 40)
CloseBtn.Position = UDim2.new(1, -22, 0, 4)
CloseBtn.Size = UDim2.new(0, 18, 0, 18)
CloseBtn.Text = "X"
CloseBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
CloseBtn.MouseButton1Click:Connect(function() ScreenGui:Destroy() end)

-- ====================================================================
-- SISTEMAS INTERNOS (MOTORES E REPETIÇÕES)
-- ====================================================================

-- Loop de ESP (Ver através das paredes)
local espBoxes = {}
task.spawn(function()
    while true do
        task.wait(0.5)
        if espActive then
            for _, p in pairs(game.Players:GetPlayers()) do
                if p ~= Player and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
                    if p.Character:FindFirstChild("Humanoid") and p.Character.Humanoid.Health > 0 then
                        if not espBoxes[p] or not espBoxes[p].Parent then
                            local box = Instance.new("BoxHandleAdornment")
                            box.Size = p.Character:GetExtentsSize() + Vector3.new(0.3, 0.3, 0.3)
                            box.AlwaysOnTop = true
                            box.ZIndex = 5
                            box.Color3 = Color3.fromRGB(255, 215, 0)
                            box.Transparency = 0.6
                            box.Adornee = p.Character
                            box.Parent = p.Character:FindFirstChild("HumanoidRootPart")
                            espBoxes[p] = box
                        end
                    end
                end
            end
        else
            for p, box in pairs(espBoxes) do pcall(function() box:Destroy() end) end
            table.clear(espBoxes)
        end
    end
end)

-- Sistema Corrigido de Voo Livre (Segue Direção da Câmera)
