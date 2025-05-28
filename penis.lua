local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

local player = Players.LocalPlayer

-- Feature-Status
local features = {
    {name="Fly",           key="F1",  enabled=false},
    {name="Unsichtbar",    key="F2",  enabled=false},
    {name="Godmode",       key="F3",  enabled=false},
    {name="Speed Boost",   key="F4",  enabled=false},
    {name="Ragdoll",       key="F5",  enabled=false},
    {name="Super Jump",    key="F6",  enabled=false},
    {name="Mini",          key="F7",  enabled=false},
    {name="Big",           key="F8",  enabled=false},
    {name="Regenbogen",    key="F9",  enabled=false},
}

-- Einstellungen
local flySpeed = 60
local speedBoost = 100
local superJumpPower = 200
local normalJumpPower = 50
local bodyGyro, bodyVelocity = nil, nil
local rainbowConnection = nil
local flyConnection = nil

-- Hilfsfunktionen für Features
local function setInvisibility(character, enabled)
    for _, part in pairs(character:GetDescendants()) do
        if part:IsA("BasePart") then
            part.LocalTransparencyModifier = enabled and 0.8 or 0
            if part.Name == "Head" then
                local face = part:FindFirstChildOfClass("Decal")
                if face then
                    face.Transparency = enabled and 1 or 0
                end
            end
        elseif part:IsA("Accessory") then
            for _, handle in pairs(part:GetChildren()) do
                if handle:IsA("BasePart") then
                    handle.LocalTransparencyModifier = enabled and 0.8 or 0
                end
            end
        end
    end
end

local function setSpeed(humanoid, enabled)
    humanoid.WalkSpeed = enabled and speedBoost or 16
end

local function setRagdoll(character, enabled)
    local humanoid = character:FindFirstChildOfClass("Humanoid")
    if humanoid then
        if enabled then
            humanoid:ChangeState(Enum.HumanoidStateType.Physics)
        else
            humanoid:ChangeState(Enum.HumanoidStateType.GettingUp)
        end
    end
end

local function setSuperJump(humanoid, enabled)
    humanoid.JumpPower = enabled and superJumpPower or normalJumpPower
end

local function setMini(character, enabled)
    for _, part in pairs(character:GetDescendants()) do
        if part:IsA("BasePart") then
            part.Size = enabled and (part.Size * 0.5) or (part.Size * 2)
        end
    end
end

local function setBig(character, enabled)
    for _, part in pairs(character:GetDescendants()) do
        if part:IsA("BasePart") then
            part.Size = enabled and (part.Size * 2) or (part.Size * 0.5)
        end
    end
end

local function setRainbow(character, enabled)
    if rainbowConnection then
        rainbowConnection:Disconnect()
        rainbowConnection = nil
    end
    if enabled then
        rainbowConnection = RunService.RenderStepped:Connect(function()
            local t = tick()
            for _, part in pairs(character:GetDescendants()) do
                if part:IsA("BasePart") then
                    part.Color = Color3.fromHSV((t*0.2)%1,1,1)
                end
            end
        end)
    else
        for _, part in pairs(character:GetDescendants()) do
            if part:IsA("BasePart") then
                part.Color = Color3.fromRGB(163, 162, 165)
            end
        end
    end
end

local function enableFly(root)
    if not bodyGyro then
        bodyGyro = Instance.new("BodyGyro")
        bodyGyro.D = 10
        bodyGyro.P = 10000
        bodyGyro.MaxTorque = Vector3.new(1e9, 1e9, 1e9)
        bodyGyro.Parent = root
    end
    if not bodyVelocity then
        bodyVelocity = Instance.new("BodyVelocity")
        bodyVelocity.MaxForce = Vector3.new(1e9, 1e9, 1e9)
        bodyVelocity.Parent = root
    end
    flyConnection = RunService.RenderStepped:Connect(function()
        local camera = workspace.CurrentCamera
        bodyGyro.CFrame = camera.CFrame
        local moveVec = Vector3.new()
        if UserInputService:IsKeyDown(Enum.KeyCode.W) then
            moveVec = moveVec + camera.CFrame.LookVector
        end
        if UserInputService:IsKeyDown(Enum.KeyCode.S) then
            moveVec = moveVec - camera.CFrame.LookVector
        end
        if UserInputService:IsKeyDown(Enum.KeyCode.A) then
            moveVec = moveVec - camera.CFrame.RightVector
        end
        if UserInputService:IsKeyDown(Enum.KeyCode.D) then
            moveVec = moveVec + camera.CFrame.RightVector
        end
        if UserInputService:IsKeyDown(Enum.KeyCode.Space) then
            moveVec = moveVec + Vector3.new(0,1,0)
        end
        if UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then
            moveVec = moveVec - Vector3.new(0,1,0)
        end
        bodyVelocity.Velocity = moveVec.Magnitude > 0 and moveVec.Unit * flySpeed or Vector3.new(0,0,0)
    end)
end

local function disableFly()
    if flyConnection then flyConnection:Disconnect() flyConnection = nil end
    if bodyGyro then bodyGyro:Destroy() bodyGyro = nil end
    if bodyVelocity then bodyVelocity:Destroy() bodyVelocity = nil end
end

-- GUI erstellen
local function createGui()
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "FunPowersGui"
    screenGui.ResetOnSpawn = false
    screenGui.Parent = player.PlayerGui

    local frame = Instance.new("Frame")
    frame.Name = "MainFrame"
    frame.Size = UDim2.new(0, 420, 0, 260)
    frame.Position = UDim2.new(0, 40, 0, 60)
    frame.BackgroundColor3 = Color3.fromRGB(30, 32, 36)
    frame.BorderSizePixel = 0
    frame.BackgroundTransparency = 0.05
    frame.AnchorPoint = Vector2.new(0,0)
    frame.Parent = screenGui

    local uicorner = Instance.new("UICorner", frame)
    uicorner.CornerRadius = UDim.new(0, 16)

    local title = Instance.new("TextLabel")
    title.Text = "Roblox Fun Powers"
    title.Size = UDim2.new(1, 0, 0, 38)
    title.Position = UDim2.new(0, 0, 0, 0)
    title.BackgroundTransparency = 1
    title.TextColor3 = Color3.fromRGB(255, 215, 0)
    title.Font = Enum.Font.FredokaOne
    title.TextSize = 28
    title.Parent = frame

    local grid = Instance.new("UIGridLayout")
    grid.CellSize = UDim2.new(0, 190, 0, 48)
    grid.CellPadding = UDim2.new(0, 10, 0, 10)
    grid.FillDirection = Enum.FillDirection.Horizontal
    grid.SortOrder = Enum.SortOrder.LayoutOrder
    grid.StartCorner = Enum.StartCorner.TopLeft
    grid.Parent = frame
    grid.Padding = UDim.new(0, 0)

    grid.HorizontalAlignment = Enum.HorizontalAlignment.Center
    grid.VerticalAlignment = Enum.VerticalAlignment.Center

    frame.ClipsDescendants = true
    grid.Parent = frame
    grid.SortOrder = Enum.SortOrder.LayoutOrder
    grid.CellSize = UDim2.new(0, 190, 0, 48)
    grid.CellPadding = UDim2.new(0, 10, 0, 10)

    -- Buttons anlegen
    local buttons = {}
    for i, feat in ipairs(features) do
        local btn = Instance.new("TextButton")
        btn.Name = feat.name.."Btn"
        btn.Size = UDim2.new(0, 190, 0, 48)
        btn.BackgroundColor3 = Color3.fromRGB(40,40,40)
        btn.TextColor3 = feat.enabled and Color3.fromRGB(20,220,80) or Color3.fromRGB(255,255,255)
        btn.Font = Enum.Font.GothamBold
        btn.TextSize = 20
        btn.Text = string.format("[%s] %s: %s", feat.key, feat.name, feat.enabled and "An" or "Aus")
        btn.LayoutOrder = i
        btn.AutoButtonColor = true
        btn.Parent = frame
        table.insert(buttons, btn)
    end

    -- Button-Click-Logik
    local function updateButtons()
        for i, btn in ipairs(buttons) do
            local feat = features[i]
            btn.Text = string.format("[%s] %s: %s", feat.key, feat.name, feat.enabled and "An" or "Aus")
            btn.TextColor3 = feat.enabled and Color3.fromRGB(20,220,80) or Color3.fromRGB(255,255,255)
            btn.BackgroundColor3 = feat.enabled and Color3.fromRGB(30,60,30) or Color3.fromRGB(40,40,40)
        end
    end

    for i, btn in ipairs(buttons) do
        btn.MouseButton1Click:Connect(function()
            features[i].enabled = not features[i].enabled
            updateButtons()
            -- Feature-Logik anwenden
            local character = player.Character
            if not character then return end
            local humanoid = character:FindFirstChild("Humanoid")
            if features[i].name == "Fly" then
                if features[i].enabled then
                    enableFly(character.HumanoidRootPart)
                    humanoid.PlatformStand = true
                else
                    disableFly()
                    humanoid.PlatformStand = false
                end
            elseif features[i].name == "Unsichtbar" then
                setInvisibility(character, features[i].enabled)
            elseif features[i].name == "Godmode" then
                if features[i].enabled then
                    humanoid.MaxHealth = math.huge
                    humanoid.Health = math.huge
                else
                    humanoid.MaxHealth = 100
                    humanoid.Health = 100
                end
            elseif features[i].name == "Speed Boost" then
                setSpeed(humanoid, features[i].enabled)
            elseif features[i].name == "Ragdoll" then
                setRagdoll(character, features[i].enabled)
            elseif features[i].name == "Super Jump" then
                setSuperJump(humanoid, features[i].enabled)
            elseif features[i].name == "Mini" then
                features[7].enabled = true
                features[8].enabled = false
                setMini(character, true)
                setBig(character, false)
                updateButtons()
            elseif features[i].name == "Big" then
                features[8].enabled = true
                features[7].enabled = false
                setBig(character, true)
                setMini(character, false)
                updateButtons()
            elseif features[i].name == "Regenbogen" then
                setRainbow(character, features[i].enabled)
            end
        end)
    end

    updateButtons()
    return screenGui
end

-- Feature-Logik beim Spawn anwenden
local function setupCharacter(character)
    local humanoid = character:WaitForChild("Humanoid")
    local root = character:WaitForChild("HumanoidRootPart")

    -- Godmode
    if features[3].enabled then
        humanoid.MaxHealth = math.huge
        humanoid.Health = math.huge
    else
        humanoid.MaxHealth = 100
        humanoid.Health = 100
    end

    humanoid:GetPropertyChangedSignal("Health"):Connect(function()
        if features[3].enabled and humanoid.Health < humanoid.MaxHealth then
            humanoid.Health = humanoid.MaxHealth
        end
    end)

    setInvisibility(character, features[2].enabled)
    setSpeed(humanoid, features[4].enabled)
    setRagdoll(character, features[5].enabled)
    setSuperJump(humanoid, features[6].enabled)
    if features[7].enabled then
        setMini(character, true)
    elseif features[8].enabled then
        setBig(character, true)
    end
    setRainbow(character, features[9].enabled)

    if features[1].enabled then
        enableFly(root)
        humanoid.PlatformStand = true
    else
        disableFly()
        humanoid.PlatformStand = false
    end
end

-- GUI nur einmal erstellen
local gui = createGui()

-- Charakter-Setup nach Respawn
local function onCharacterAdded(character)
    setupCharacter(character)
end

player.CharacterAdded:Connect(onCharacterAdded)
if player.Character then
    onCharacterAdded(player.Character)
end
