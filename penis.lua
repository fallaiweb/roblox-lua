local UserInputService = game:GetService("UserInputService")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local player = Players.LocalPlayer

local fly_enabled = false
local godmode_enabled = false
local invis_enabled = false
local speed_enabled = false
local ragdoll_enabled = false
local superjump_enabled = false
local mini_enabled = false
local big_enabled = false
local rainbow_enabled = false

local flySpeed = 60
local speedBoost = 100
local superJumpPower = 200
local normalJumpPower = 50
local bodyGyro, bodyVelocity = nil, nil

local function createStatusGui()
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "StatusGui"
    screenGui.ResetOnSpawn = false
    screenGui.Parent = player.PlayerGui

    local statusLabel = Instance.new("TextLabel")
    statusLabel.Name = "StatusLabel"
    statusLabel.Size = UDim2.new(0, 400, 0, 260)
    statusLabel.Position = UDim2.new(0, 10, 0, 10)
    statusLabel.BackgroundTransparency = 0.4
    statusLabel.BackgroundColor3 = Color3.fromRGB(30,30,30)
    statusLabel.TextColor3 = Color3.fromRGB(255,255,255)
    statusLabel.Font = Enum.Font.SourceSansBold
    statusLabel.TextSize = 20
    statusLabel.TextXAlignment = Enum.TextXAlignment.Left
    statusLabel.TextYAlignment = Enum.TextYAlignment.Top
    statusLabel.Parent = screenGui
    return statusLabel
end

local statusLabel = nil

local function updateStatus()
    if statusLabel then
        statusLabel.Text =
            "F1: Fly [" .. (fly_enabled and "ENABLED" or "DISABLED") .. "]\n" ..
            "F2: Unsichtbar [" .. (invis_enabled and "ENABLED" or "DISABLED") .. "]\n" ..
            "F3: Godmode [" .. (godmode_enabled and "ENABLED" or "DISABLED") .. "]\n" ..
            "F4: Speed Boost [" .. (speed_enabled and "ENABLED" or "DISABLED") .. "]\n" ..
            "F5: Ragdoll [" .. (ragdoll_enabled and "ENABLED" or "DISABLED") .. "]\n" ..
            "F6: Super Jump [" .. (superjump_enabled and "ENABLED" or "DISABLED") .. "]\n" ..
            "F7: Mini [" .. (mini_enabled and "ENABLED" or "DISABLED") .. "]\n" ..
            "F8: Big [" .. (big_enabled and "ENABLED" or "DISABLED") .. "]\n" ..
            "F9: Regenbogen [" .. (rainbow_enabled and "ENABLED" or "DISABLED") .. "]"
    end
end

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

local rainbowConnection = nil
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

local flyConnection = nil
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

local function setupCharacter(character)
    local humanoid = character:WaitForChild("Humanoid")
    local root = character:WaitForChild("HumanoidRootPart")

    if godmode_enabled then
        humanoid.MaxHealth = math.huge
        humanoid.Health = math.huge
    else
        humanoid.MaxHealth = 100
        humanoid.Health = 100
    end

    humanoid:GetPropertyChangedSignal("Health"):Connect(function()
        if godmode_enabled and humanoid.Health < humanoid.MaxHealth then
            humanoid.Health = humanoid.MaxHealth
        end
    end)

    setInvisibility(character, invis_enabled)
    setSpeed(humanoid, speed_enabled)
    setRagdoll(character, ragdoll_enabled)
    setSuperJump(humanoid, superjump_enabled)
    if mini_enabled then
        setMini(character, true)
    elseif big_enabled then
        setBig(character, true)
    end
    setRainbow(character, rainbow_enabled)

    if fly_enabled then
        enableFly(root)
        humanoid.PlatformStand = true
    else
        disableFly()
        humanoid.PlatformStand = false
    end
end

UserInputService.InputBegan:Connect(function(input, gp)
    if gp then return end
    local character = player.Character
    if not character then return end
    local humanoid = character:FindFirstChild("Humanoid")

    if input.KeyCode == Enum.KeyCode.F1 then
        fly_enabled = not fly_enabled
        if fly_enabled then
            enableFly(character.HumanoidRootPart)
            humanoid.PlatformStand = true
        else
            disableFly()
            humanoid.PlatformStand = false
        end
        updateStatus()
    elseif input.KeyCode == Enum.KeyCode.F2 then
        invis_enabled = not invis_enabled
        setInvisibility(character, invis_enabled)
        updateStatus()
    elseif input.KeyCode == Enum.KeyCode.F3 then
        godmode_enabled = not godmode_enabled
        if godmode_enabled then
            humanoid.MaxHealth = math.huge
            humanoid.Health = math.huge
        else
            humanoid.MaxHealth = 100
            humanoid.Health = 100
        end
        updateStatus()
    elseif input.KeyCode == Enum.KeyCode.F4 then
        speed_enabled = not speed_enabled
        setSpeed(humanoid, speed_enabled)
        updateStatus()
    elseif input.KeyCode == Enum.KeyCode.F5 then
        ragdoll_enabled = not ragdoll_enabled
        setRagdoll(character, ragdoll_enabled)
        updateStatus()
    elseif input.KeyCode == Enum.KeyCode.F6 then
        superjump_enabled = not superjump_enabled
        setSuperJump(humanoid, superjump_enabled)
        updateStatus()
    elseif input.KeyCode == Enum.KeyCode.F7 then
        mini_enabled = not mini_enabled
        big_enabled = false
        setMini(character, mini_enabled)
        setBig(character, false)
        updateStatus()
    elseif input.KeyCode == Enum.KeyCode.F8 then
        big_enabled = not big_enabled
        mini_enabled = false
        setBig(character, big_enabled)
        setMini(character, false)
        updateStatus()
    elseif input.KeyCode == Enum.KeyCode.F9 then
        rainbow_enabled = not rainbow_enabled
        setRainbow(character, rainbow_enabled)
        updateStatus()
    end
end)

local function onCharacterAdded(character)
    setupCharacter(character)
    if not statusLabel then
        statusLabel = createStatusGui()
    end
    updateStatus()
end

player.CharacterAdded:Connect(onCharacterAdded)
if player.Character then
    onCharacterAdded(player.Character)
end
