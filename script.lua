-- ====================================================================
-- FLUENTY HUB PREMIUM - VERSÃO ULTRA OTIMIZADA E CORRIGIDA PARA DELTA
-- ====================================================================

local Fluent = loadstring(game:HttpGet("https://github.com"))()
local SaveManager = loadstring(game:HttpGet("https://githubusercontent.com"))()
local InterfaceManager = loadstring(game:HttpGet("https://githubusercontent.com"))()

local Player = game.Players.LocalPlayer
local RunService = game:GetService("RunService")
local Lighting = game:GetService("Lighting")

-- Configurações de Estado Global
local Config = {
    Speed = 16,
    Jump = 50,
    Fly = false,
    KeepFly = false,
    KeepSpeed = false,
    ESP = false,
    FastMode = false,
    NoShake = false,
    FullBright = false,
    TargetSlot = nil,
    SavedTool = nil
}

-- Criando a Janela Principal (Interface Premium)
local Window = Fluent:CreateWindow({
    Title = "Fluenty Hub",
    SubTitle = "by Mobile Optimizer",
    TabWidth = 140,
    Size = UDim2.fromOffset(460, 320),
    Acrylic = false, -- Desativado para melhor FPS no Mobile
    Theme = "Dark",
    MinimizeKey = Enum.KeyCode.LeftControl -- Botão flutuante na tela cuidará disso no Mobile
})

-- Abas do Menu
local Tabs = {
    Inventory = Window:AddTab({ Title = "Slots & Itens", Icon = "backpack" }),
    Movement = Window:AddTab({ Title = "Movimentação", Icon = "run" }),
    Visuals = Window:AddTab({ Title = "Visual & FPS", Icon = "eye" })
}

-- ====================================================================
-- ABA 1: GERENCIADOR DE INVENTÁRIO (SLOTS)
-- ====================================================================
local SlotDropdown = Tabs.Inventory:AddDropdown("SelectSlot", {
    Title = "Escolha o Slot para Monitorar",
    Values = {"Slot 1", "Slot 2", "Slot 3", "Slot 4", "Slot 5", "Slot 6", "Slot 7", "Slot 8", "Slot 9"},
    CurrentValue = "Slot 1",
    Callback = function(Value)
        local num = tonumber(Value:match("%d+"))
        Config.TargetSlot = num
    end
})

local ItemStatusLabel = Tabs.Inventory:AddParagraph({
    Title = "Status do Item Salvo",
    Content = "Nenhum item travado no slot ainda."
})

local function scanInventory()
    local tools = Player.Backpack:GetChildren()
    if Player.Character then
        for _, t in pairs(Player.Character:GetChildren()) do
            if t:IsA("Tool") then table.insert(tools, t) end
        end
    end
    
    if Config.TargetSlot and tools[Config.TargetSlot] then
        Config.SavedTool = tools[Config.TargetSlot]
        ItemStatusLabel:SetTitle("Item Salvo: " .. tools[Config.TargetSlot].Name)
        ItemStatusLabel:SetDesc("Este item será forçado na sua mão após o respawn.")
    else
        ItemStatusLabel:SetTitle("Status do Item Salvo")
        ItemStatusLabel:SetDesc("Slot vazio ou item indisponível.")
    end
end

Tabs.Inventory:AddButton({
    Title = "🔄 Sincronizar / Refresh Inventário",
    Description = "Clique se mudar de item ou coletar algo novo",
    Callback = scanInventory
})

-- ====================================================================
-- ABA 2: MOVIMENTAÇÃO (FLY & WALKSPEED)
-- ====================================================================
local SpeedSlider = Tabs.Movement:AddSlider("SpeedSlider", {
    Title = "Ajustar WalkSpeed",
    Description = "Velocidade de Corrida",
    Default = 16,
    Min = 16,
    Max = 250,
    Rounding = 0,
    Callback = function(Value)
        Config.Speed = Value
    end
})

local JumpSlider = Tabs.Movement:AddSlider("JumpSlider", {
    Title = "Ajustar JumpPower",
    Description = "Altura do Pulo",
    Default = 50,
    Min = 50,
    Max = 500,
    Rounding = 0,
    Callback = function(Value)
        Config.Jump = Value
    end
})

local FlyToggle = Tabs.Movement:AddToggle("FlyToggle", {Title = "Ativar Fly (Voo Livre)", Default = false})
FlyToggle:OnChanged(function()
    Config.Fly = FlyToggle.Value
end)

Tabs.Movement:AddToggle("KeepFlyToggle", {Title = "Manter Fly Após a Morte", Default = false}):OnChanged(function(v) Config.KeepFly = v end)
Tabs.Movement:AddToggle("KeepSpeedToggle", {Title = "Manter Velocidade Após a Morte", Default = false}):OnChanged(function(v) Config.KeepSpeed = v end)

-- ====================================================================
-- ABA 3: VISUAIS & FPS (ESP, FASTMODE, BRIGHT)
-- ====================================================================
Tabs.Visuals:AddToggle("ESPToggle", {Title = "Player ESP (Ver pelas Paredes)", Default = false}):OnChanged(function(v) Config.ESP = v end)
Tabs.Visuals:AddToggle("FastModeToggle", {Title = "Fast Mode (Remover Texturas / +FPS)", Default = false}):OnChanged(function(v) Config.FastMode = v end)
Tabs.Visuals:AddToggle("NoShakeToggle", {Title = "Anular Tremor de Câmera", Default = false}):OnChanged(function(v) Config.NoShake = v end)
Tabs.Visuals:AddToggle("BrightToggle", {Title = "FullBright (Iluminação Máxima)", Default = false}):OnChanged(function(v) Config.FullBright = v end)

-- ====================================================================
-- MOTORES INTERNOS DO SCRIPT (LOGICA DE EXECUÇÃO CORRIGIDA)
-- ====================================================================

-- Motor de Voo Tridimensional por Câmera (Física Forçada)
local flyAttachment, flyLinearVelocity, flyAlignOrient
local function updateFly()
    local char = Player.Character
    local root = char and char:FindFirstChild("HumanoidRootPart")
    local hum = char and char:FindFirstChildOfClass("Humanoid")
    
    if Config.Fly and root and hum and workspace.CurrentCamera then
        if not flyLinearVelocity then
            flyAttachment = Instance.new("Attachment")
            flyAttachment.Parent = root
            
            flyLinearVelocity = Instance.new("LinearVelocity")
            flyLinearVelocity.MaxForce = 9e9
            flyLinearVelocity.Attachment0 = flyAttachment
            flyLinearVelocity.Parent = root
            
            flyAlignOrient = Instance.new("AlignOrientation")
            flyAlignOrient.MaxTorque = 9e9
            flyAlignOrient.Attachment0 = flyAttachment
            flyAlignOrient.Parent = root
            
            hum.PlatformStand = true
        end
        
        local camCFrame = workspace.CurrentCamera.CFrame
        local moveDirection = hum.MoveDirection
        local velocity = Vector3.new(0, 0, 0)
        
        if moveDirection.Magnitude > 0 then
            velocity = camCFrame.LookVector * (moveDirection.Z * -70) + camCFrame.RightVector * (moveDirection.X * 70)
        end
        
        flyLinearVelocity.VectorVelocity = velocity
        flyAlignOrient.CFrame = camCFrame
    else
        if flyLinearVelocity then flyLinearVelocity:Destroy() flyLinearVelocity = nil end
        if flyAlignOrient then flyAlignOrient:Destroy() flyAlignOrient = nil end
        if flyAttachment then flyAttachment:Destroy() flyAttachment = nil end
        if hum then hum.PlatformStand = false end
    end
end

-- Monitoramento Contínuo por RenderStepped
RunService.RenderStepped:Connect(function()
    local char = Player.Character
    if char then
        local hum = char:FindFirstChildOfClass("Humanoid")
        
        -- Garante a Velocidade e Pulo interseptando alterações do servidor
        if hum and not Config.Fly then
            hum.WalkSpeed = Config.Speed
            if hum.UseJumpPower then hum.JumpPower = Config.Jump else hum.JumpHeight = Config.Jump / 3 end
        end
        
        updateFly()
        
        -- No Camera Shake
        if Config.NoShake and Player:FindFirstChild("PlayerScripts") then
            local s = Player.PlayerScripts:FindFirstChild("CameraShaker", true) or char:FindFirstChild("CameraShake", true)
            if s then pcall(function() s:Destroy() end) end
        end
    end
    
    -- FullBright Estável
    if Config.FullBright then
        Lighting.Ambient = Color3.fromRGB(255, 255, 255)
        Lighting.OutdoorAmbient = Color3.fromRGB(255, 255, 255)
        Lighting.GlobalShadows = false
    end
end)

-- Sistema de ESP Dinâmico sem Lag
local espBoxes = {}
task.spawn(function()
    while true do
        task.wait(0.5)
        if Config.ESP then
            for _, p in pairs(game.Players:GetPlayers()) do
                if p ~= Player and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
                    if p.Character:FindFirstChild("Humanoid") and p.Character.Humanoid.Health > 0 then
                        if not espBoxes[p] or not espBoxes[p].Parent then
                            local box = Instance.new("Highlight")
                            box.FillColor = Color3.fromRGB(255, 0, 0)
                            box.OutlineColor = Color3.fromRGB(255, 255, 255)
                            box.FillTransparency = 0.5
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

-- Otimizador Fast Mode Avançado
task.spawn(function()
    while true do
        task.wait(2)
        if Config.FastMode then
            for _, obj in pairs(workspace:GetDescendants()) do
                if obj:IsA("BasePart") and obj.Material ~= Enum.Material.SmoothPlastic then
                    obj.Material = Enum.Material.SmoothPlastic
                    obj.Reflectance = 0
                end
            end
        end
    end
end)

-- Mecanismo Inteligente de Respawn (Pós-Morte)
Player.CharacterAdding:Connect(function(newCharacter)

