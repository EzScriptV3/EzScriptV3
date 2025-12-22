--[[
    EZScript GUI - Multi-functional Roblox Script
    Powered by WindUI
]]

local WindUI

do
    local ok, result = pcall(function()
        return require("./src/Init")
    end)
    
    if ok then
        WindUI = result
    else 
        WindUI = loadstring(game:HttpGet("https://raw.githubusercontent.com/Footagesus/WindUI/main/dist/main.lua"))()
    end
end

-- EZSCRIPT CORE
-- Variables
local Player = game.Players.LocalPlayer
local Character = Player.Character or Player.CharacterAdded:Wait()
local Humanoid = Character:WaitForChild("Humanoid")
local RunService = game:GetService("RunService")
local LightingService = game:GetService("Lighting")
local UserInputService = game:GetService("UserInputService")
local TeleportService = game:GetService("TeleportService")
local HttpService = game:GetService("HttpService")
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")

-- State Flags
local FlyEnabled = false
local Invisible = false
local NoclipEnabled = false
local ESPEnabled = false
local AntiAFKEnabled = false
local InfJumpEnabled = false
local BrightnessEnabled = false
local AutoClickerEnabled = false
local MM2ESPEnabled = false
local FloatingEnabled = false
local SpeedBoostEnabled = false
local GodModeEnabled = false
local NoClipPermEnabled = false
local AntiSlowEnabled = false
local AutoFarmEnabled = false
local AimBotEnabled = false
local NoRecoilEnabled = false
local InstantRespawnEnabled = false
local AutoCollectEnabled = false

-- Settings
local FlySpeed = 50
local ClickSpeed = 10
local WalkSpeed = 16
local JumpPower = 50
local AimBotFOV = 50
local BackgroundType = "Default" -- Default, Gradient, Blur, Color

-- Connections
local FlyConnection, NoclipConnection, AFKConnection, InfJumpConnection, AutoClickerConnection, MM2ESPConnection, SpeedConnection, AimBotConnection

-- Storages
local ESPBoxes = {}
local MM2HighlightInstances = {}
local OriginalValues = {}
local BackgroundObjects = {}

-- Background Functions
local function ApplyBackground(type, color1, color2)
    -- Remove existing backgrounds
    for _, obj in pairs(BackgroundObjects) do
        if obj then
            obj:Destroy()
        end
    end
    BackgroundObjects = {}
    
    local mainFrame = Window:FindFirstChildWhichIsA("Frame")
    if not mainFrame then return end
    
    if type == "Default" then
        -- Default WindUI background
        mainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
        
    elseif type == "Gradient" then
        -- Gradient background
        local gradient = Instance.new("UIGradient")
        gradient.Color = ColorSequence.new{
            ColorSequenceKeypoint.new(0, color1 or Color3.fromRGB(30, 30, 40)),
            ColorSequenceKeypoint.new(1, color2 or Color3.fromRGB(15, 15, 25))
        }
        gradient.Rotation = 45
        gradient.Parent = mainFrame
        table.insert(BackgroundObjects, gradient)
        
    elseif type == "Color" then
        -- Solid color background
        mainFrame.BackgroundColor3 = color1 or Color3.fromRGB(25, 25, 35)
        
    elseif type == "Blur" then
        -- Blur effect (simulated with transparency)
        mainFrame.BackgroundTransparency = 0.3
        mainFrame.BackgroundColor3 = Color3.fromRGB(10, 10, 15)
    end
end

-- 1. ToggleFly()
local function ToggleFly()
    FlyEnabled = not FlyEnabled
    if FlyEnabled then
        local BodyGyro = Instance.new("BodyGyro")
        local BodyVelocity = Instance.new("BodyVelocity")
        BodyGyro.Parent = Character.HumanoidRootPart
        BodyVelocity.Parent = Character.HumanoidRootPart
        BodyGyro.MaxTorque = Vector3.new(9e9, 9e9, 9e9)
        BodyGyro.CFrame = Character.HumanoidRootPart.CFrame
        BodyVelocity.MaxForce = Vector3.new(9e9, 9e9, 9e9)
        BodyVelocity.Velocity = Vector3.new(0, 0, 0)
        
        FlyConnection = RunService.Heartbeat:Connect(function()
            if FlyEnabled and Character and Character.HumanoidRootPart then
                BodyVelocity.Velocity = Vector3.new(0, 0, 0)
                local cam = workspace.CurrentCamera.CFrame
                if UserInputService:IsKeyDown(Enum.KeyCode.W) then
                    BodyVelocity.Velocity = BodyVelocity.Velocity + (cam.LookVector * FlySpeed)
                end
                if UserInputService:IsKeyDown(Enum.KeyCode.S) then
                    BodyVelocity.Velocity = BodyVelocity.Velocity - (cam.LookVector * FlySpeed)
                end
                if UserInputService:IsKeyDown(Enum.KeyCode.A) then
                    BodyVelocity.Velocity = BodyVelocity.Velocity - (cam.RightVector * FlySpeed)
                end
                if UserInputService:IsKeyDown(Enum.KeyCode.D) then
                    BodyVelocity.Velocity = BodyVelocity.Velocity + (cam.RightVector * FlySpeed)
                end
                if UserInputService:IsKeyDown(Enum.KeyCode.Space) then
                    BodyVelocity.Velocity = BodyVelocity.Velocity + Vector3.new(0, FlySpeed, 0)
                end
                if UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) then
                    BodyVelocity.Velocity = BodyVelocity.Velocity - Vector3.new(0, FlySpeed, 0)
                end
            end
        end)
    else
        if FlyConnection then FlyConnection:Disconnect() end
        for _, obj in pairs(Character.HumanoidRootPart:GetChildren()) do
            if obj:IsA("BodyGyro") or obj:IsA("BodyVelocity") then
                obj:Destroy()
            end
        end
    end
end

-- 2. UpdateFlySpeed(newSpeed)
local function UpdateFlySpeed(newSpeed)
    FlySpeed = newSpeed
    if FlyEnabled then
        ToggleFly()
        wait(0.1)
        ToggleFly()
    end
end

-- 3. ToggleInvisibility()
local function ToggleInvisibility()
    Invisible = not Invisible
    for _, part in pairs(Character:GetChildren()) do
        if part:IsA("BasePart") then
            part.Transparency = Invisible and 1 or 0
            if part:IsA("MeshPart") or part:IsA("Part") then
                part.CastShadow = not Invisible
            end
        end
    end
    for _, accessory in pairs(Character:GetDescendants()) do
        if accessory:IsA("Accessory") and accessory:FindFirstChild("Handle") then
            accessory.Handle.Transparency = Invisible and 1 or 0
        end
    end
end

-- 4. ToggleNoclip()
local function ToggleNoclip()
    NoclipEnabled = not NoclipEnabled
    if NoclipEnabled then
        NoclipConnection = RunService.Stepped:Connect(function()
            if Character then
                for _, part in pairs(Character:GetDescendants()) do
                    if part:IsA("BasePart") then
                        part.CanCollide = false
                    end
                end
            end
        end)
    else
        if NoclipConnection then NoclipConnection:Disconnect() end
    end
end

-- 5. TeleportForward()
local function TeleportForward()
    local rootPart = Character.HumanoidRootPart
    local newPosition = rootPart.Position + (rootPart.CFrame.LookVector * 50)
    rootPart.CFrame = CFrame.new(newPosition)
end

-- 6. TeleportToRandomPlayer()
local function TeleportToRandomPlayer()
    local players = Players:GetPlayers()
    local validPlayers = {}
    for _, player in pairs(players) do
        if player ~= Player and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
            table.insert(validPlayers, player)
        end
    end
    if #validPlayers > 0 then
        local randomPlayer = validPlayers[math.random(1, #validPlayers)]
        Character.HumanoidRootPart.CFrame = randomPlayer.Character.HumanoidRootPart.CFrame
    end
end

-- 7. TeleportToPlayer(playerName)
local function TeleportToPlayer(playerName)
    local targetPlayer = Players:FindFirstChild(playerName)
    if targetPlayer and targetPlayer.Character and targetPlayer.Character:FindFirstChild("HumanoidRootPart") then
        Character.HumanoidRootPart.CFrame = targetPlayer.Character.HumanoidRootPart.CFrame
        return true
    end
    return false
end

-- 8. BringPlayer(playerName)
local function BringPlayer(playerName)
    local targetPlayer = Players:FindFirstChild(playerName)
    if targetPlayer and targetPlayer.Character and targetPlayer.Character:FindFirstChild("HumanoidRootPart") then
        targetPlayer.Character.HumanoidRootPart.CFrame = Character.HumanoidRootPart.CFrame
        return true
    end
    return false
end

-- 9. BringAllPlayers()
local function BringAllPlayers()
    local players = Players:GetPlayers()
    for _, player in pairs(players) do
        if player ~= Player and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
            player.Character.HumanoidRootPart.CFrame = Character.HumanoidRootPart.CFrame
        end
    end
end

-- 10. ToggleESP()
local function createESP(targetPlayer)
    local character = targetPlayer.Character
    if not character then return end
    local oldHighlight = character:FindFirstChild("ESP_Highlight")
    if oldHighlight then oldHighlight:Destroy() end
    local highlight = Instance.new("Highlight")
    highlight.Name = "ESP_Highlight"
    highlight.FillColor = Color3.fromRGB(255, 0, 0)
    highlight.OutlineColor = Color3.fromRGB(255, 255, 255)
    highlight.FillTransparency = 0.7
    highlight.OutlineTransparency = 0
    highlight.Parent = character
    ESPBoxes[targetPlayer] = highlight
end

local function removeESP(targetPlayer)
    if ESPBoxes[targetPlayer] then
        ESPBoxes[targetPlayer]:Destroy()
        ESPBoxes[targetPlayer] = nil
    end
end

local function ToggleESP()
    ESPEnabled = not ESPEnabled
    if ESPEnabled then
        for _, targetPlayer in pairs(Players:GetPlayers()) do
            if targetPlayer ~= Player and targetPlayer.Character then
                createESP(targetPlayer)
            end
        end
    else
        for targetPlayer, highlight in pairs(ESPBoxes) do
            if highlight then highlight:Destroy() end
        end
        ESPBoxes = {}
    end
end

-- 11. ToggleSpeedBoost()
local function ToggleSpeedBoost()
    SpeedBoostEnabled = not SpeedBoostEnabled
    if SpeedBoostEnabled then
        Humanoid.WalkSpeed = 100
    else
        Humanoid.WalkSpeed = WalkSpeed
    end
end

-- 12. ToggleGodMode()
local function ToggleGodMode()
    GodModeEnabled = not GodModeEnabled
    if GodModeEnabled then
        Humanoid.MaxHealth = math.huge
        Humanoid.Health = math.huge
    else
        Humanoid.MaxHealth = 100
        Humanoid.Health = 100
    end
end

-- 13. ToggleInfJump()
local function ToggleInfJump()
    InfJumpEnabled = not InfJumpEnabled
    if InfJumpEnabled then
        InfJumpConnection = UserInputService.JumpRequest:Connect(function()
            if InfJumpEnabled and Character and Humanoid then
                Humanoid:ChangeState("Jumping")
            end
        end)
    else
        if InfJumpConnection then InfJumpConnection:Disconnect() end
    end
end

-- 14. ToggleAntiAFK()
local function ToggleAntiAFK()
    AntiAFKEnabled = not AntiAFKEnabled
    if AntiAFKEnabled then
        AFKConnection = RunService.Heartbeat:Connect(function()
            pcall(function()
                local virtualUser = game:GetService("VirtualUser")
                virtualUser:CaptureController()
                virtualUser:ClickButton2(Vector2.new())
            end)
        end)
    else
        if AFKConnection then AFKConnection:Disconnect() end
    end
end

-- 15. ToggleBrightness()
local function ToggleBrightness()
    BrightnessEnabled = not BrightnessEnabled
    if BrightnessEnabled then
        LightingService.Brightness = 10
        LightingService.Ambient = Color3.new(1, 1, 1)
        LightingService.OutdoorAmbient = Color3.new(1, 1, 1)
        LightingService.GlobalShadows = false
    else
        LightingService.Brightness = 2
        LightingService.Ambient = Color3.new(0.5, 0.5, 0.5)
        LightingService.OutdoorAmbient = Color3.new(0.5, 0.5, 0.5)
        LightingService.GlobalShadows = true
    end
end

-- 16. ToggleNightMode()
local function ToggleNightMode()
    LightingService.Ambient = Color3.fromRGB(10, 10, 30)
    LightingService.OutdoorAmbient = Color3.fromRGB(10, 10, 30)
    LightingService.Brightness = 0.5
    LightingService.FogColor = Color3.fromRGB(5, 5, 15)
    LightingService.FogEnd = 500
    LightingService.GlobalShadows = true
end

-- 17. ToggleAutoClicker()
local function ToggleAutoClicker()
    AutoClickerEnabled = not AutoClickerEnabled
    if AutoClickerEnabled then
        AutoClickerConnection = RunService.Heartbeat:Connect(function()
            if AutoClickerEnabled then
                local mouse = Player:GetMouse()
                pcall(function()
                    local virtualInput = game:GetService("VirtualInputManager")
                    virtualInput:SendMouseButtonEvent(mouse.X, mouse.Y, 0, true, game, 1)
                    wait(0.01)
                    virtualInput:SendMouseButtonEvent(mouse.X, mouse.Y, 0, false, game, 1)
                end)
                wait(1 / ClickSpeed)
            end
        end)
    else
        if AutoClickerConnection then AutoClickerConnection:Disconnect() end
    end
end

-- 18. UpdateClickSpeed(newSpeed)
local function UpdateClickSpeed(newSpeed)
    ClickSpeed = newSpeed
    if AutoClickerEnabled then
        ToggleAutoClicker()
        wait(0.1)
        ToggleAutoClicker()
    end
end

-- 19. ToggleNoRecoil()
local function ToggleNoRecoil()
    NoRecoilEnabled = not NoRecoilEnabled
    if NoRecoilEnabled then
        WindUI:Notify({
            Title = "No Recoil",
            Content = "No Recoil enabled (Simulated)"
        })
    else
        WindUI:Notify({
            Title = "No Recoil",
            Content = "No Recoil disabled"
        })
    end
end

-- 20. ToggleAntiSlow()
local function ToggleAntiSlow()
    AntiSlowEnabled = not AntiSlowEnabled
    if AntiSlowEnabled then
        if Character then
            for _, part in pairs(Character:GetDescendants()) do
                if part:IsA("BasePart") then
                    part.Velocity = Vector3.new(0, 0, 0)
                end
            end
        end
        WindUI:Notify({
            Title = "Anti Slow",
            Content = "Anti Slow enabled (Simulated)"
        })
    else
        WindUI:Notify({
            Title = "Anti Slow",
            Content = "Anti Slow disabled"
        })
    end
end

-- 21. ToggleInstantRespawn()
local function ToggleInstantRespawn()
    InstantRespawnEnabled = not InstantRespawnEnabled
    if InstantRespawnEnabled then
        WindUI:Notify({
            Title = "Instant Respawn",
            Content = "Instant Respawn enabled (Simulated)"
        })
    else
        WindUI:Notify({
            Title = "Instant Respawn",
            Content = "Instant Respawn disabled"
        })
    end
end

-- 22. ToggleAutoCollect()
local function ToggleAutoCollect()
    AutoCollectEnabled = not AutoCollectEnabled
    if AutoCollectEnabled then
        WindUI:Notify({
            Title = "Auto Collect",
            Content = "Auto Collect enabled (Simulated)"
        })
    else
        WindUI:Notify({
            Title = "Auto Collect",
            Content = "Auto Collect disabled"
        })
    end
end

-- 23. GetServerInfo()
local function GetServerInfo()
    local players = Players:GetPlayers()
    local maxPlayers = Players.MaxPlayers
    local placeId = game.PlaceId
    local jobId = game.JobId
    
    local fps = "Calculating..."
    pcall(function() 
        fps = tostring(math.floor(1 / RunService.RenderStepped:Wait())) 
    end)
    
    return {
        Players = #players .. "/" .. maxPlayers,
        FPS = fps,
        PlaceID = placeId,
        ServerID = jobId:sub(1, 8).."...",
        GameName = game:GetService("MarketplaceService"):GetProductInfo(placeId).Name
    }
end

-- 24. ResetAll()
local function ResetAll()
    FlyEnabled = false
    if FlyConnection then FlyConnection:Disconnect() end
    NoclipEnabled = false
    if NoclipConnection then NoclipConnection:Disconnect() end
    AntiAFKEnabled = false
    if AFKConnection then AFKConnection:Disconnect() end
    InfJumpEnabled = false
    if InfJumpConnection then InfJumpConnection:Disconnect() end
    AutoClickerEnabled = false
    if AutoClickerConnection then AutoClickerConnection:Disconnect() end
    if MM2ESPConnection then MM2ESPConnection:Disconnect() end
    if SpeedConnection then SpeedConnection:Disconnect() end
    if AimBotConnection then AimBotConnection:Disconnect() end
    
    for _, obj in pairs(Character.HumanoidRootPart:GetChildren()) do
        if obj:IsA("BodyGyro") or obj:IsA("BodyVelocity") then obj:Destroy() end
    end
    
    Invisible = false
    for _, part in pairs(Character:GetChildren()) do
        if part:IsA("BasePart") then part.Transparency = 0 end
    end
    
    ESPEnabled = false
    for targetPlayer, highlight in pairs(ESPBoxes) do
        if highlight then highlight:Destroy() end
    end
    ESPBoxes = {}
    
    MM2ESPEnabled = false
    for player, highlight in pairs(MM2HighlightInstances) do
        if highlight then highlight:Destroy() end
    end
    MM2HighlightInstances = {}
    
    Humanoid.JumpPower = JumpPower
    Humanoid.WalkSpeed = WalkSpeed
    FlySpeed = 50
    ClickSpeed = 10
    AimBotFOV = 50
    
    FloatingEnabled = false
    SpeedBoostEnabled = false
    GodModeEnabled = false
    NoClipPermEnabled = false
    AntiSlowEnabled = false
    AutoFarmEnabled = false
    AimBotEnabled = false
    NoRecoilEnabled = false
    InstantRespawnEnabled = false
    AutoCollectEnabled = false
    
    LightingService.Brightness = 2
    LightingService.Ambient = Color3.new(0.5, 0.5, 0.5)
    LightingService.OutdoorAmbient = Color3.new(0.5, 0.5, 0.5)
    LightingService.FogEnd = 100000
    LightingService.GlobalShadows = true
    
    WindUI:Notify({
        Title = "Reset Complete",
        Content = "All features have been reset to default"
    })
end

-- 25. UpdatePlayerList()
local function UpdatePlayerList()
    local players = Players:GetPlayers()
    local list = "=== Online Players ===\n"
    for _, player in pairs(players) do
        list = list .. player.Name .. (player == Player and " (You)" or "") .. "\n"
    end
    list = list .. "====================="
    
    WindUI:Notify({
        Title = "Player List",
        Content = list
    })
end

-- 26. SetWalkSpeed(speed)
local function SetWalkSpeed(speed)
    WalkSpeed = speed
    if not SpeedBoostEnabled then
        Humanoid.WalkSpeed = speed
    end
end

-- 27. SetJumpPower(power)
local function SetJumpPower(power)
    JumpPower = power
    Humanoid.JumpPower = power
end

-- 28. ServerHop()
local function ServerHop()
    local servers = {}
    local success, data = pcall(function()
        return HttpService:JSONDecode(game:HttpGet("https://games.roblox.com/v1/games/" .. game.PlaceId .. "/servers/Public?sortOrder=Asc&limit=100"))
    end)
    
    if success and data and data.data then
        for _, server in pairs(data.data) do
            if server.playing < server.maxPlayers and server.id ~= game.JobId then
                table.insert(servers, server.id)
            end
        end
        
        if #servers > 0 then
            local randomServer = servers[math.random(1, #servers)]
            TeleportService:TeleportToPlaceInstance(game.PlaceId, randomServer, Player)
        else
            WindUI:Notify({
                Title = "Server Hop",
                Content = "No available servers found"
            })
        end
    else
        WindUI:Notify({
            Title = "Server Hop",
            Content = "Failed to fetch server list"
        })
    end
end

-- 29. RejoinServer()
local function RejoinServer()
    TeleportService:Teleport(game.PlaceId, Player)
end

-- 30. CopyServerID()
local function CopyServerID()
    setclipboard(game.JobId)
    WindUI:Notify({
        Title = "Copied",
        Content = "Server ID copied to clipboard: " .. game.JobId
    })
end

-- Key binds
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    
    if input.KeyCode == Enum.KeyCode.Q then
        ToggleFly()
    elseif input.KeyCode == Enum.KeyCode.R then
        TeleportForward()
    elseif input.KeyCode == Enum.KeyCode.T then
        ToggleInvisibility()
    elseif input.KeyCode == Enum.KeyCode.Z then
        TeleportToRandomPlayer()
    elseif input.KeyCode == Enum.KeyCode.P then
        UpdatePlayerList()
    end
end)

-- Handlers
Player.CharacterAdded:Connect(function(newChar)
    Character = newChar
    Humanoid = newChar:WaitForChild("Humanoid")
    task.wait(1)
    if SpeedBoostEnabled then
        Humanoid.WalkSpeed = 100
    else
        Humanoid.WalkSpeed = WalkSpeed
    end
    Humanoid.JumpPower = JumpPower
end)

Players.PlayerAdded:Connect(function(newPlayer)
    if ESPEnabled then
        newPlayer.CharacterAdded:Connect(function()
            wait(1)
            createESP(newPlayer)
        end)
    end
end)

Players.PlayerRemoving:Connect(function(player)
    removeESP(player)
end)

print("EZScript loaded successfully!")
print("Keybinds:")
print("Q - Fly")
print("R - Teleport Forward")
print("T - Invisibility")
print("Z - Teleport to Random Player")
print("P - Show Player List")

-- */ WINDOW CREATION /* --
local Window = WindUI:CreateWindow({
    Title = "EZScript Hub  |  Multi-Functional",
    Folder = "ezscript",
    IconSize = 22*2,
    NewElements = true,
    HideSearchBar = false,
    
    OpenButton = {
        Title = "Open EZScript",
        CornerRadius = UDim.new(1,0),
        StrokeThickness = 3,
        Enabled = true,
        Draggable = true,
        OnlyMobile = false,
        Color = ColorSequence.new(
            Color3.fromHex("#30FF6A"), 
            Color3.fromHex("#e7ff2f")
        )
    },
    Topbar = {
        Height = 44,
        ButtonsType = "Mac",
    },
})

-- Tags
Window:Tag({
    Title = "v2.1",
    Icon = "zap",
    Color = Color3.fromHex("#1c1c1c")
})

-- Colors
local Purple = Color3.fromHex("#7775F2")
local Yellow = Color3.fromHex("#ECA201")
local Green = Color3.fromHex("#10C550")
local Grey = Color3.fromHex("#83889E")
local Blue = Color3.fromHex("#257AF7")
local Red = Color3.fromHex("#EF4F1D")
local Cyan = Color3.fromHex("#00FFFF")
local Pink = Color3.fromHex("#FF69B4")
local Orange = Color3.fromHex("#FFA500")

-- */ MOVEMENT TAB /* --
do
    local MovementTab = Window:Tab({
        Title = "Movement",
        Icon = "move",
        IconColor = Blue,
    })
    
    -- Increased spacing between sections
    MovementTab:Space({ Columns = 2 })
    
    -- Flight Section
    local FlightSection = MovementTab:Section({
        Title = "Flight",
        Box = true,
        Opened = true,
    })
    
    FlightSection:Toggle({
        Title = "Enable Flight",
        Desc = "Fly around the map (Press Q)",
        Callback = ToggleFly,
        Flag = "FlyToggle"
    })
    
    FlightSection:Slider({
        Title = "Flight Speed",
        Desc = "Adjust flight movement speed",
        Step = 5,
        Value = {
            Min = 20,
            Max = 200,
            Default = FlySpeed,
        },
        Callback = UpdateFlySpeed,
        Flag = "FlySpeedSlider"
    })
    
    -- Increased spacing
    MovementTab:Space({ Columns = 2 })
    
    -- Speed Section
    local SpeedSection = MovementTab:Section({
        Title = "Speed & Jump",
        Box = true,
        Opened = true,
    })
    
    SpeedSection:Toggle({
        Title = "Speed Boost",
        Desc = "Increase walking speed",
        Callback = ToggleSpeedBoost,
        Flag = "SpeedBoostToggle"
    })
    
    SpeedSection:Slider({
        Title = "Walk Speed",
        Desc = "Set default walking speed",
        Step = 1,
        Value = {
            Min = 16,
            Max = 200,
            Default = WalkSpeed,
        },
        Callback = SetWalkSpeed,
        Flag = "WalkSpeedSlider"
    })
    
    SpeedSection:Toggle({
        Title = "Infinite Jump",
        Desc = "Jump without limits",
        Callback = ToggleInfJump,
        Flag = "InfJumpToggle"
    })
    
    SpeedSection:Slider({
        Title = "Jump Power",
        Desc = "Set jump height",
        Step = 5,
        Value = {
            Min = 50,
            Max = 300,
            Default = JumpPower,
        },
        Callback = SetJumpPower,
        Flag = "JumpPowerSlider"
    })
    
    SpeedSection:Button({
        Title = "Super Jump (10s)",
        Desc = "Temporary super jump power",
        Callback = ActivateSuperJump
    })
    
    -- Increased spacing
    MovementTab:Space({ Columns = 2 })
    
    -- Noclip Section
    local NoclipSection = MovementTab:Section({
        Title = "Collision",
        Box = true,
        Opened = true,
    })
    
    NoclipSection:Toggle({
        Title = "Noclip",
        Desc = "Walk through walls and objects",
        Callback = ToggleNoclip,
        Flag = "NoclipToggle"
    })
    
    NoclipSection:Toggle({
        Title = "Anti Slow",
        Desc = "Prevent slowing effects",
        Callback = ToggleAntiSlow,
        Flag = "AntiSlowToggle"
    })
end

-- */ TELEPORT TAB /* --
do
    local TeleportTab = Window:Tab({
        Title = "Teleport",
        Icon = "navigation",
        IconColor = Green,
    })
    
    -- Increased spacing
    TeleportTab:Space({ Columns = 2 })
    
    -- Quick Teleport Section
    local QuickTP = TeleportTab:Section({
        Title = "Quick Teleport",
        Box = true,
        Opened = true,
    })
    
    QuickTP:Button({
        Title = "Teleport Forward",
        Desc = "Teleport 50 studs forward (Press R)",
        Callback = TeleportForward
    })
    
    QuickTP:Button({
        Title = "Teleport to Random Player",
        Desc = "Teleport to random online player (Press Z)",
        Callback = TeleportToRandomPlayer
    })
    
    QuickTP:Button({
        Title = "Teleport to Sky",
        Desc = "Teleport high up in the sky",
        Callback = function()
            local currentPosition = Character.HumanoidRootPart.Position
            Character.HumanoidRootPart.CFrame = CFrame.new(currentPosition.X, 1000, currentPosition.Z)
        end
    })
    
    -- Increased spacing
    TeleportTab:Space({ Columns = 2 })
    
    -- Player Teleport Section
    local PlayerTP = TeleportTab:Section({
        Title = "Player Teleport",
        Box = true,
        Opened = true,
    })
    
    local tpInput = PlayerTP:Input({
        Title = "Player Name",
        Desc = "Enter player name to teleport to",
        Placeholder = "Username",
        Callback = function(name)
            if TeleportToPlayer(name) then
                WindUI:Notify({
                    Title = "Teleport",
                    Content = "Teleported to " .. name
                })
            else
                WindUI:Notify({
                    Title = "Teleport Failed",
                    Content = "Player not found or offline"
                })
            end
        end
    })
    
    PlayerTP:Button({
        Title = "Bring Player",
        Desc = "Bring specified player to you",
        Callback = function()
            local name = tpInput:Get()
            if BringPlayer(name) then
                WindUI:Notify({
                    Title = "Bring",
                    Content = "Brought " .. name .. " to you"
                })
            else
                WindUI:Notify({
                    Title = "Bring Failed",
                    Content = "Player not found or offline"
                })
            end
        end
    })
    
    PlayerTP:Button({
        Title = "Bring All Players",
        Desc = "Bring all online players to you",
        Callback = BringAllPlayers
    })
    
    -- Increased spacing
    TeleportTab:Space({ Columns = 2 })
    
    -- Server Section
    local ServerSection = TeleportTab:Section({
        Title = "Server",
        Box = true,
        Opened = true,
    })
    
    ServerSection:Button({
        Title = "Server Hop",
        Desc = "Join a different server",
        Callback = ServerHop
    })
    
    ServerSection:Button({
        Title = "Rejoin Server",
        Desc = "Rejoin current server",
        Callback = RejoinServer
    })
    
    ServerSection:Button({
        Title = "Copy Server ID",
        Desc = "Copy current server ID to clipboard",
        Callback = CopyServerID
    })
end

-- */ VISUAL TAB /* --
do
    local VisualTab = Window:Tab({
        Title = "Visual",
        Icon = "eye",
        IconColor = Purple,
    })
    
    -- Increased spacing
    VisualTab:Space({ Columns = 2 })
    
    -- ESP Section
    local ESPSection = VisualTab:Section({
        Title = "ESP",
        Box = true,
        Opened = true,
    })
    
    ESPSection:Toggle({
        Title = "Player ESP",
        Desc = "See players through walls",
        Callback = ToggleESP,
        Flag = "ESPToggle"
    })
    
    ESPSection:Toggle({
        Title = "MM2 ESP",
        Desc = "Murder Mystery 2 role ESP",
        Callback = function(state)
            MM2ESPEnabled = state
            if state then
                WindUI:Notify({
                    Title = "MM2 ESP",
                    Content = "MM2 ESP enabled (Simulated)"
                })
            else
                WindUI:Notify({
                    Title = "MM2 ESP",
                    Content = "MM2 ESP disabled"
                })
            end
        end,
        Flag = "MM2ESPToggle"
    })
    
    -- Increased spacing
    VisualTab:Space({ Columns = 2 })
    
    -- Visibility Section
    local VisibilitySection = VisualTab:Section({
        Title = "Visibility",
        Box = true,
        Opened = true,
    })
    
    VisibilitySection:Toggle({
        Title = "Invisibility",
        Desc = "Become invisible to others (Press T)",
        Callback = ToggleInvisibility,
        Flag = "InvisibilityToggle"
    })
    
    -- Increased spacing
    VisualTab:Space({ Columns = 2 })
    
    -- Lighting Section
    local LightingSection = VisualTab:Section({
        Title = "Lighting",
        Box = true,
        Opened = true,
    })
    
    LightingSection:Toggle({
        Title = "Full Bright",
        Desc = "Remove all shadows and darkness",
        Callback = ToggleBrightness,
        Flag = "BrightnessToggle"
    })
    
    LightingSection:Button({
        Title = "Night Mode",
        Desc = "Apply dark atmospheric lighting",
        Callback = ToggleNightMode
    })
    
    LightingSection:Button({
        Title = "Reset Lighting",
        Desc = "Restore default lighting settings",
        Callback = function()
            LightingService.Brightness = 2
            LightingService.Ambient = Color3.new(0.5, 0.5, 0.5)
            LightingService.OutdoorAmbient = Color3.new(0.5, 0.5, 0.5)
            LightingService.FogEnd = 100000
            LightingService.GlobalShadows = true
            WindUI:Notify({
                Title = "Lighting Reset",
                Content = "Lighting restored to default"
            })
        end
    })
end

-- */ COMBAT TAB /* --
do
    local CombatTab = Window:Tab({
        Title = "Combat",
        Icon = "target",
        IconColor = Red,
    })
    
    -- Increased spacing
    CombatTab:Space({ Columns = 2 })
    
    -- Aim Assist Section
    local AimSection = CombatTab:Section({
        Title = "Aim Assist",
        Box = true,
        Opened = true,
    })
    
    AimSection:Toggle({
        Title = "Aimbot",
        Desc = "Auto aim at nearest player",
        Callback = function(state)
            AimBotEnabled = state
            if state then
                WindUI:Notify({
                    Title = "Aimbot",
                    Content = "Aimbot enabled (Simulated)"
                })
            else
                WindUI:Notify({
                    Title = "Aimbot",
                    Content = "Aimbot disabled"
                })
            end
        end,
        Flag = "AimbotToggle"
    })
    
    AimSection:Slider({
        Title = "Aimbot FOV",
        Desc = "Field of view for aimbot",
        Step = 5,
        Value = {
            Min = 10,
            Max = 360,
            Default = AimBotFOV,
        },
        Callback = function(value)
            AimBotFOV = value
        end,
        Flag = "AimbotFOVSlider"
    })
    
    AimSection:Toggle({
        Title = "No Recoil",
        Desc = "Remove weapon recoil",
        Callback = ToggleNoRecoil,
        Flag = "NoRecoilToggle"
    })
    
    -- Increased spacing
    CombatTab:Space({ Columns = 2 })
    
    -- Auto Section
    local AutoSection = CombatTab:Section({
        Title = "Automation",
        Box = true,
        Opened = true,
    })
    
    AutoSection:Toggle({
        Title = "Auto Clicker",
        Desc = "Automatically click mouse",
        Callback = ToggleAutoClicker,
        Flag = "AutoClickerToggle"
    })
    
    AutoSection:Slider({
        Title = "Click Speed",
        Desc = "Clicks per second",
        Step = 1,
        Value = {
            Min = 1,
            Max = 50,
            Default = ClickSpeed,
        },
        Callback = UpdateClickSpeed,
        Flag = "ClickSpeedSlider"
    })
    
    AutoSection:Toggle({
        Title = "Auto Collect",
        Desc = "Automatically collect items",
        Callback = ToggleAutoCollect,
        Flag = "AutoCollectToggle"
    })
    
    AutoSection:Toggle({
        Title = "Auto Farm",
        Desc = "Automatically farm resources",
        Callback = function(state)
            AutoFarmEnabled = state
            if state then
                WindUI:Notify({
                    Title = "Auto Farm",
                    Content = "Auto Farm enabled (Simulated)"
                })
            else
                WindUI:Notify({
                    Title = "Auto Farm",
                    Content = "Auto Farm disabled"
                })
            end
        end,
        Flag = "AutoFarmToggle"
    })
end

-- */ UTILITY TAB /* --
do
    local UtilityTab = Window:Tab({
        Title = "Utility",
        Icon = "wrench",
        IconColor = Yellow,
    })
    
    -- Increased spacing
    UtilityTab:Space({ Columns = 2 })
    
    -- Protection Section
    local ProtectionSection = UtilityTab:Section({
        Title = "Protection",
        Box = true,
        Opened = true,
    })
    
    ProtectionSection:Toggle({
        Title = "God Mode",
        Desc = "Become invincible",
        Callback = ToggleGodMode,
        Flag = "GodModeToggle"
    })
    
    ProtectionSection:Toggle({
        Title = "Instant Respawn",
        Desc = "Respawn instantly after death",
        Callback = ToggleInstantRespawn,
        Flag = "InstantRespawnToggle"
    })
    
    ProtectionSection:Toggle({
        Title = "Anti-AFK",
        Desc = "Prevent AFK kick",
        Callback = ToggleAntiAFK,
        Flag = "AntiAFKToggle"
    })
    
    -- Increased spacing
    UtilityTab:Space({ Columns = 2 })
    
    -- Character Section
    local CharacterSection = UtilityTab:Section({
        Title = "Character",
        Box = true,
        Opened = true,
    })
    
    CharacterSection:Button({
        Title = "Reset Character",
        Desc = "Reset your character",
        Callback = function()
            Humanoid.Health = 0
        end
    })
    
    CharacterSection:Button({
        Title = "Heal Character",
        Desc = "Restore full health",
        Callback = function()
            Humanoid.Health = Humanoid.MaxHealth
            WindUI:Notify({
                Title = "Healed",
                Content = "Character fully healed"
            })
        end
    })
    
    -- Increased spacing
    UtilityTab:Space({ Columns = 2 })
    
    -- Tools Section
    local ToolsSection = UtilityTab:Section({
        Title = "Tools",
        Box = true,
        Opened = true,
    })
    
    ToolsSection:Button({
        Title = "Get Tools",
        Desc = "Give yourself basic tools",
        Callback = function()
            local tool1 = Instance.new("Tool")
            tool1.Name = "Sword"
            tool1.Parent = Player.Backpack
            
            local tool2 = Instance.new("Tool")
            tool2.Name = "Gun"
            tool2.Parent = Player.Backpack
            
            WindUI:Notify({
                Title = "Tools Added",
                Content = "Basic tools added to backpack"
            })
        end
    })
    
    ToolsSection:Button({
        Title = "Remove Tools",
        Desc = "Remove all tools from backpack",
        Callback = function()
            for _, tool in pairs(Player.Backpack:GetChildren()) do
                if tool:IsA("Tool") then
                    tool:Destroy()
                end
            end
            WindUI:Notify({
                Title = "Tools Removed",
                Content = "All tools removed from backpack"
            })
        end
    })
end

-- */ INFO TAB /* --
do
    local InfoTab = Window:Tab({
        Title = "Information",
        Icon = "info",
        IconColor = Cyan,
    })
    
    -- Increased spacing
    InfoTab:Space({ Columns = 2 })
    
    -- Server Info Section
    local ServerInfoSection = InfoTab:Section({
        Title = "Server Information",
        Box = true,
        Opened = true,
    })
    
    ServerInfoSection:Button({
        Title = "Get Server Info",
        Desc = "Show detailed server information",
        Callback = function()
            local info = GetServerInfo()
            WindUI:Notify({
                Title = "Server Information",
                Content = string.format("Game: %s\nPlayers: %s\nFPS: %s\nPlace ID: %s\nServer ID: %s",
                    info.GameName, info.Players, info.FPS, info.PlaceID, info.ServerID)
            })
        end
    })
    
    ServerInfoSection:Button({
        Title = "Show Player List",
        Desc = "Display all online players",
        Callback = UpdatePlayerList
    })
    
    ServerInfoSection:Button({
        Title = "Copy Place ID",
        Desc = "Copy game ID to clipboard",
        Callback = function()
            setclipboard(tostring(game.PlaceId))
            WindUI:Notify({
                Title = "Copied",
                Content = "Place ID copied to clipboard"
            })
        end
    })
    
    -- Increased spacing
    InfoTab:Space({ Columns = 2 })
    
    -- Script Info Section
    local ScriptInfoSection = InfoTab:Section({
        Title = "Script Information",
        Box = true,
        Opened = true,
    })
    
    ScriptInfoSection:Paragraph({
        Title = "EZScript v2.1",
        Desc = "Multi-functional Roblox cheat script\nFeatures: Flight, ESP, Teleport, Combat\nHotkeys: Q, R, T, Z, P",
        Image = "zap"
    })
    
    ScriptInfoSection:Button({
        Title = "Show Hotkeys",
        Desc = "Display all available hotkeys",
        Callback = function()
            WindUI:Notify({
                Title = "Hotkeys",
                Content = "Q - Toggle Flight\nR - Teleport Forward\nT - Toggle Invisibility\nZ - Teleport to Random Player\nP - Show Player List"
            })
        end
    })
    
    ScriptInfoSection:Button({
        Title = "Test Notifications",
        Desc = "Test notification system",
        Callback = function()
            WindUI:Notify({
                Title = "Test Notification",
                Content = "This is a test notification from EZScript",
                Icon = "check"
            })
        end
    })
end

-- */ SETTINGS TAB /* --
do
    local SettingsTab = Window:Tab({
        Title = "Settings",
        Icon = "settings",
        IconColor = Grey,
    })
    
    -- Increased spacing
    SettingsTab:Space({ Columns = 2 })
    
    -- Config Section
    local ConfigSection = SettingsTab:Section({
        Title = "Configuration",
        Box = true,
        Opened = true,
    })
    
    local ConfigManager = Window.ConfigManager
    local ConfigName = "ezscript_config"
    
    local ConfigNameInput = ConfigSection:Input({
        Title = "Config Name",
        Desc = "Enter name for configuration",
        Value = ConfigName,
        Callback = function(value)
            ConfigName = value
        end
    })
    
    ConfigSection:Button({
        Title = "Save Configuration",
        Desc = "Save current settings to config",
        Callback = function()
            Window.CurrentConfig = ConfigManager:Config(ConfigName)
            if Window.CurrentConfig:Save() then
                WindUI:Notify({
                    Title = "Configuration Saved",
                    Content = "Settings saved to '" .. ConfigName .. "'"
                })
            end
        end
    })
    
    ConfigSection:Button({
        Title = "Load Configuration",
        Desc = "Load settings from config",
        Callback = function()
            Window.CurrentConfig = ConfigManager:CreateConfig(ConfigName)
            if Window.CurrentConfig:Load() then
                WindUI:Notify({
                    Title = "Configuration Loaded",
                    Content = "Settings loaded from '" .. ConfigName .. "'"
                })
            end
        end
    })
    
    -- Increased spacing
    SettingsTab:Space({ Columns = 2 })
    
    -- Background Section
    local BackgroundSection = SettingsTab:Section({
        Title = "GUI Background",
        Box = true,
        Opened = true,
    })
    
    local bgDropdown = BackgroundSection:Dropdown({
        Title = "Background Type",
        Desc = "Select GUI background style",
        Values = {
            {
                Title = "Default",
                Desc = "Default dark background",
                Callback = function()
                    BackgroundType = "Default"
                    ApplyBackground("Default")
                    WindUI:Notify({
                        Title = "Background",
                        Content = "Default background applied"
                    })
                end
            },
            {
                Title = "Gradient",
                Desc = "Gradient background",
                Callback = function()
                    BackgroundType = "Gradient"
                    ApplyBackground("Gradient", Color3.fromRGB(30, 30, 40), Color3.fromRGB(15, 15, 25))
                    WindUI:Notify({
                        Title = "Background",
                        Content = "Gradient background applied"
                    })
                end
            },
            {
                Title = "Solid Color",
                Desc = "Single color background",
                Callback = function()
                    BackgroundType = "Color"
                    ApplyBackground("Color", Color3.fromRGB(25, 25, 35))
                    WindUI:Notify({
                        Title = "Background",
                        Content = "Solid color background applied"
                    })
                end
            },
            {
                Title = "Blur Effect",
                Desc = "Transparent blur effect",
                Callback = function()
                    BackgroundType = "Blur"
                    ApplyBackground("Blur")
                    WindUI:Notify({
                        Title = "Background",
                        Content = "Blur effect applied"
                    })
                end
            }
        },
        Value = "Default"
    })
    
    BackgroundSection:Colorpicker({
        Title = "Background Color 1",
        Desc = "Primary background color",
        Default = Color3.fromRGB(30, 30, 40),
        Callback = function(color)
            if BackgroundType == "Gradient" then
                ApplyBackground("Gradient", color, Color3.fromRGB(15, 15, 25))
            elseif BackgroundType == "Color" then
                ApplyBackground("Color", color)
            end
        end
    })
    
    BackgroundSection:Colorpicker({
        Title = "Background Color 2",
        Desc = "Secondary gradient color",
        Default = Color3.fromRGB(15, 15, 25),
        Callback = function(color)
            if BackgroundType == "Gradient" then
                ApplyBackground("Gradient", Color3.fromRGB(30, 30, 40), color)
            end
        end
    })
    
    BackgroundSection:Button({
        Title = "Apply Background",
        Desc = "Apply current background settings",
        Callback = function()
            if BackgroundType == "Default" then
                ApplyBackground("Default")
            elseif BackgroundType == "Gradient" then
                ApplyBackground("Gradient", Color3.fromRGB(30, 30, 40), Color3.fromRGB(15, 15, 25))
            elseif BackgroundType == "Color" then
                ApplyBackground("Color", Color3.fromRGB(25, 25, 35))
            elseif BackgroundType == "Blur" then
                ApplyBackground("Blur")
            end
            WindUI:Notify({
                Title = "Background Applied",
                Content = "Background settings updated"
            })
        end
    })
    
    -- Increased spacing
    SettingsTab:Space({ Columns = 2 })
    
    -- UI Customization Section
    local UICustomSection = SettingsTab:Section({
        Title = "UI Customization",
        Box = true,
        Opened = true,
    })
    
    UICustomSection:Colorpicker({
        Title = "Accent Color",
        Desc = "Change UI accent color",
        Default = Color3.fromHex("#30FF6A"),
        Callback = function(color)
            WindUI:Notify({
                Title = "Color Changed",
                Content = "Accent color updated (Visual only)"
            })
        end
    })
    
    UICustomSection:Toggle({
        Title = "Compact Mode",
        Desc = "Enable compact UI layout",
        Callback = function(state)
            if state then
                Window:SetUIScale(0.8)
                WindUI:Notify({
                    Title = "Compact Mode",
                    Content = "Compact mode enabled"
                })
            else
                Window:SetUIScale(1)
                WindUI:Notify({
                    Title = "Compact Mode",
                    Content = "Compact mode disabled"
                })
            end
        end,
        Flag = "CompactModeToggle"
    })
    
    UICustomSection:Slider({
        Title = "UI Transparency",
        Desc = "Adjust GUI transparency",
        Step = 0.05,
        Value = {
            Min = 0,
            Max = 0.5,
            Default = 0,
        },
        Callback = function(value)
            local mainFrame = Window:FindFirstChildWhichIsA("Frame")
            if mainFrame then
                mainFrame.BackgroundTransparency = value
            end
        end,
        Flag = "UITransparencySlider"
    })
    
    -- Increased spacing
    SettingsTab:Space({ Columns = 2 })
    
    -- Control Section
    local ControlSection = SettingsTab:Section({
        Title = "Controls",
        Box = true,
        Opened = true,
    })
    
    ControlSection:Button({
        Title = "Reset All Features",
        Desc = "Disable all features and reset settings",
        Color = Color3.fromHex("#ff4830"),
        Callback = ResetAll
    })
    
    ControlSection:Button({
        Title = "Reload GUI",
        Desc = "Reload the EZScript interface",
        Callback = function()
            Window:Destroy()
            WindUI:Notify({
                Title = "Reloading",
                Content = "EZScript GUI will reload..."
            })
            wait(1)
            loadstring(game:HttpGet("https://raw.githubusercontent.com/YourRepo/EZScript/main/main.lua"))()
        end
    })
    
    ControlSection:Button({
        Title = "Destroy GUI",
        Desc = "Close EZScript interface",
        Color = Color3.fromHex("#ff4830"),
        Callback = function()
            Window:Destroy()
            WindUI:Notify({
                Title = "GUI Destroyed",
                Content = "EZScript interface closed"
            })
        end
    })
    
    ControlSection:Paragraph({
        Title = "Current Settings",
        Desc = string.format("Fly Speed: %d\nWalk Speed: %d\nJump Power: %d\nClick Speed: %d\nBackground: %s",
            FlySpeed, WalkSpeed, JumpPower, ClickSpeed, BackgroundType),
        Image = "settings"
    })
end

-- Apply default background on startup
task.spawn(function()
    wait(1) -- Wait for GUI to load
    ApplyBackground("Default")
end)

-- Startup Notification
WindUI:Notify({
    Title = "EZScript v2.1 Loaded",
    Content = "GUI successfully loaded! Use hotkeys or interface.",
    Icon = "check",
    Duration = 5
})
