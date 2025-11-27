local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/xHeptc/Kavo-UI-Library/main/source.lua", true))()
local Window = Library.CreateLib("EZScript", "DarkTheme")

local Player = game.Players.LocalPlayer
local Character = Player.Character or Player.CharacterAdded:Wait()
local Humanoid = Character:WaitForChild("Humanoid")

-- Variables
local FlyEnabled = false
local Invisible = false
local NoclipEnabled = false
local ESPEnabled = false
local AntiAFKEnabled = false
local NotUpEnabled = false
local FlySpeed = 50
local InfJumpEnabled = false
local BrightnessEnabled = false
local AutoClickerEnabled = false
local ClickSpeed = 10 -- кликов в секунду

-- BaBfT Floating Variables
local ts = game:GetService("TweenService")
local uis = game:GetService("UserInputService")
local root = Character:WaitForChild("HumanoidRootPart")
local floatingEnabled = false

-- OBBY & HAS Variables
local ObbyEnabled = false
local HasEnabled = false

-- 99NIGHTS Variables
local NightModeEnabled = false
local SpeedBoostEnabled = false
local GodModeEnabled = false

local FlyConnection
local NoclipConnection
local AFKConnection
local ESPBoxes = {}
local InfJumpConnection
local LightingService
local AutoClickerConnection

-- Server Info Variables
local RunService = game:GetService("RunService")
local StatsService = game:GetService("Stats")

-- AUTOCLICKER FUNCTION
local function ToggleAutoClicker()
    AutoClickerEnabled = not AutoClickerEnabled
    
    if AutoClickerEnabled then
        Library:CreateNotification("AutoClicker", "AutoClicker ENABLED! Speed: " .. ClickSpeed .. " CPS", 3)
        
        AutoClickerConnection = RunService.Heartbeat:Connect(function()
            if AutoClickerEnabled then
                -- Создаем клик
                local mouse = Player:GetMouse()
                pcall(function()
                    local virtualInput = game:GetService("VirtualInputManager")
                    virtualInput:SendMouseButtonEvent(mouse.X, mouse.Y, 0, true, game, 1)
                    wait(0.01)
                    virtualInput:SendMouseButtonEvent(mouse.X, mouse.Y, 0, false, game, 1)
                end)
                
                -- Ждем в соответствии с выбранной скоростью
                wait(1 / ClickSpeed)
            end
        end)
    else
        if AutoClickerConnection then
            AutoClickerConnection:Disconnect()
            AutoClickerConnection = nil
        end
        Library:CreateNotification("AutoClicker", "AutoClicker DISABLED!", 3)
    end
end

local function UpdateClickSpeed(newSpeed)
    ClickSpeed = newSpeed
    if AutoClickerEnabled then
        -- Перезапускаем автокликер с новой скоростью
        ToggleAutoClicker()
        wait(0.1)
        ToggleAutoClicker()
    end
    Library:CreateNotification("AutoClicker", "Click speed set to: " .. ClickSpeed .. " CPS", 2)
end

-- BaBfT Floating Functions
local function applyFloat()
    if root:FindFirstChild("Float") then return end
    local bv = Instance.new("BodyVelocity")
    bv.Velocity = Vector3.new(0, 0, 0)
    bv.MaxForce = Vector3.new(0, math.huge, 0)
    bv.Name = "Float"
    bv.Parent = root
end

local function removeFloat()
    local float = root:FindFirstChild("Float")
    if float then
        float:Destroy()
    end
end

local function startFloating()
    floatingEnabled = true
    applyFloat()
    
    task.spawn(function()
        while floatingEnabled do
            if floatingEnabled then
                root.CFrame = CFrame.new(-60, 33, -122)
                wait()
                ts:Create(root, TweenInfo.new(15, Enum.EasingStyle.Linear), {CFrame = CFrame.new(-70, 40, 8695)}):Play()
                wait(15)
                ts:Create(root, TweenInfo.new(1, Enum.EasingStyle.Linear), {CFrame = CFrame.new(-56, -360, 9487)}):Play()
                wait(1)
            else
                wait()
            end
        end
    end)
end

local function stopFloating()
    floatingEnabled = false
    removeFloat()
end

-- 99NIGHTS Functions
local function ToggleNightMode()
    NightModeEnabled = not NightModeEnabled
    
    if NightModeEnabled then
        LightingService = game:GetService("Lighting")
        -- Устанавливаем ночной режим
        LightingService.Ambient = Color3.fromRGB(10, 10, 30)
        LightingService.OutdoorAmbient = Color3.fromRGB(10, 10, 30)
        LightingService.Brightness = 0.5
        LightingService.FogColor = Color3.fromRGB(5, 5, 15)
        LightingService.FogEnd = 500
        
        Library:CreateNotification("99NIGHTS", "Night Mode ACTIVATED!", 3)
    else
        if LightingService then
            -- Возвращаем стандартные настройки
            LightingService.Ambient = Color3.new(0.5, 0.5, 0.5)
            LightingService.OutdoorAmbient = Color3.new(0.5, 0.5, 0.5)
            LightingService.Brightness = 2
            LightingService.FogEnd = 100000
        end
        Library:CreateNotification("99NIGHTS", "Night Mode DEACTIVATED!", 3)
    end
end

local function ToggleSpeedBoost()
    SpeedBoostEnabled = not SpeedBoostEnabled
    
    if SpeedBoostEnabled then
        Humanoid.WalkSpeed = 100
        Library:CreateNotification("99NIGHTS", "Speed Boost ACTIVATED! (Speed: 100)", 3)
    else
        Humanoid.WalkSpeed = 16
        Library:CreateNotification("99NIGHTS", "Speed Boost DEACTIVATED!", 3)
    end
end

local function ToggleGodMode()
    GodModeEnabled = not GodModeEnabled
    
    if GodModeEnabled then
        Humanoid.MaxHealth = math.huge
        Humanoid.Health = math.huge
        Library:CreateNotification("99NIGHTS", "God Mode ACTIVATED!", 3)
    else
        Humanoid.MaxHealth = 100
        Humanoid.Health = 100
        Library:CreateNotification("99NIGHTS", "God Mode DEACTIVATED!", 3)
    end
end

local function ActivateSuperJump()
    Humanoid.JumpPower = 250
    Library:CreateNotification("99NIGHTS", "Super Jump ACTIVATED! (Power: 250)", 3)
    
    -- Автоматически сбрасываем через 10 секунд
    wait(10)
    if Humanoid then
        Humanoid.JumpPower = 50
        Library:CreateNotification("99NIGHTS", "Super Jump DEACTIVATED!", 3)
    end
end

local function TeleportToSky()
    local currentPosition = Character.HumanoidRootPart.Position
    Character.HumanoidRootPart.CFrame = CFrame.new(currentPosition.X, 1000, currentPosition.Z)
    Library:CreateNotification("99NIGHTS", "Teleported to SKY!", 3)
end

-- BRIGHTNESS FUNCTION
local function ToggleBrightness()
    BrightnessEnabled = not BrightnessEnabled
    
    if BrightnessEnabled then
        LightingService = game:GetService("Lighting")
        -- Сохраняем оригинальные настройки
        local originalBrightness = LightingService.Brightness
        local originalAmbient = LightingService.Ambient
        local originalOutdoorAmbient = LightingService.OutdoorAmbient
        
        -- Устанавливаем максимальную яркость
        LightingService.Brightness = 10
        LightingService.Ambient = Color3.new(1, 1, 1)
        LightingService.OutdoorAmbient = Color3.new(1, 1, 1)
        
        Library:CreateNotification("Brightness", "MAX Brightness ENABLED!", 3)
        
        -- Восстанавливаем настройки при выключении
        return function()
            LightingService.Brightness = originalBrightness
            LightingService.Ambient = originalAmbient
            LightingService.OutdoorAmbient = originalOutdoorAmbient
            Library:CreateNotification("Brightness", "Brightness DISABLED!", 3)
        end
    else
        if LightingService then
            -- Перезагружаем Lighting чтобы сбросить настройки
            LightingService.Brightness = 2
            LightingService.Ambient = Color3.new(0.5, 0.5, 0.5)
            LightingService.OutdoorAmbient = Color3.new(0.5, 0.5, 0.5)
        end
        Library:CreateNotification("Brightness", "Brightness DISABLED!", 3)
    end
end

-- INFINITE JUMP FUNCTION
local function ToggleInfJump()
    InfJumpEnabled = not InfJumpEnabled
    
    if InfJumpEnabled then
        InfJumpConnection = game:GetService("UserInputService").JumpRequest:Connect(function()
            if InfJumpEnabled and Character and Humanoid then
                Humanoid:ChangeState("Jumping")
            end
        end)
        Library:CreateNotification("OBBY", "Infinite Jump ENABLED!", 3)
    else
        if InfJumpConnection then
            InfJumpConnection:Disconnect()
            InfJumpConnection = nil
        end
        Library:CreateNotification("OBBY", "Infinite Jump DISABLED!", 3)
    end
end

-- ANTI-AFK FUNCTION
local function ToggleAntiAFK()
    AntiAFKEnabled = not AntiAFKEnabled
    
    if AntiAFKEnabled then
        AFKConnection = game:GetService("RunService").Heartbeat:Connect(function()
            pcall(function()
                local virtualUser = game:GetService("VirtualUser")
                virtualUser:CaptureController()
                virtualUser:ClickButton2(Vector2.new())
            end)
        end)
        Library:CreateNotification("AntiAFK", "Anti-AFK ENABLED!", 3)
    else
        if AFKConnection then
            AFKConnection:Disconnect()
            AFKConnection = nil
        end
        Library:CreateNotification("AntiAFK", "Anti-AFK DISABLED!", 3)
    end
end

-- FLY FUNCTION
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
        
        FlyConnection = game:GetService("RunService").Heartbeat:Connect(function()
            if FlyEnabled and Character and Character.HumanoidRootPart then
                BodyVelocity.Velocity = Vector3.new(0, 0, 0)
                
                if game:GetService("UserInputService"):IsKeyDown(Enum.KeyCode.W) then
                    BodyVelocity.Velocity = BodyVelocity.Velocity + (workspace.CurrentCamera.CFrame.LookVector * FlySpeed)
                end
                if game:GetService("UserInputService"):IsKeyDown(Enum.KeyCode.S) then
                    BodyVelocity.Velocity = BodyVelocity.Velocity - (workspace.CurrentCamera.CFrame.LookVector * FlySpeed)
                end
                if game:GetService("UserInputService"):IsKeyDown(Enum.KeyCode.A) then
                    BodyVelocity.Velocity = BodyVelocity.Velocity - (workspace.CurrentCamera.CFrame.RightVector * FlySpeed)
                end
                if game:GetService("UserInputService"):IsKeyDown(Enum.KeyCode.D) then
                    BodyVelocity.Velocity = BodyVelocity.Velocity + (workspace.CurrentCamera.CFrame.RightVector * FlySpeed)
                end
                
                if game:GetService("UserInputService"):IsKeyDown(Enum.KeyCode.Space) then
                    BodyVelocity.Velocity = BodyVelocity.Velocity + Vector3.new(0, FlySpeed, 0)
                end
                if game:GetService("UserInputService"):IsKeyDown(Enum.KeyCode.LeftShift) then
                    BodyVelocity.Velocity = BodyVelocity.Velocity - Vector3.new(0, FlySpeed, 0)
                end
            end
        end)
    else
        if FlyConnection then
            FlyConnection:Disconnect()
            FlyConnection = nil
        end
        
        for _, obj in pairs(Character.HumanoidRootPart:GetChildren()) do
            if obj:IsA("BodyGyro") or obj:IsA("BodyVelocity") then
                obj:Destroy()
            end
        end
    end
end

-- ФУНКЦИЯ ДЛЯ ИЗМЕНЕНИЯ СКОРОСТИ ПОЛЕТА
local function UpdateFlySpeed(newSpeed)
    FlySpeed = newSpeed
    if FlyEnabled then
        ToggleFly()
        wait(0.1)
        ToggleFly()
    end
end

-- TELEPORT FORWARD FUNCTION
local function TeleportForward()
    local distance = 50
    local rootPart = Character.HumanoidRootPart
    local newPosition = rootPart.Position + (rootPart.CFrame.LookVector * distance)
    rootPart.CFrame = CFrame.new(newPosition)
end

-- TELEPORT TO RANDOM PLAYER FUNCTION
local function TeleportToRandomPlayer()
    local players = game.Players:GetPlayers()
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

-- INVISIBILITY FUNCTION
local function ToggleInvisibility()
    Invisible = not Invisible
    if Invisible then
        for _, part in pairs(Character:GetChildren()) do
            if part:IsA("BasePart") then
                part.Transparency = 1
            end
        end
    else
        for _, part in pairs(Character:GetChildren()) do
            if part:IsA("BasePart") then
                part.Transparency = 0
            end
        end
    end
end

-- NOCLIP FUNCTION
local function ToggleNoclip()
    NoclipEnabled = not NoclipEnabled
    
    if NoclipEnabled then
        NoclipConnection = game:GetService("RunService").Stepped:Connect(function()
            if Character then
                for _, part in pairs(Character:GetDescendants()) do
                    if part:IsA("BasePart") then
                        part.CanCollide = false
                    end
                end
            end
        end)
    else
        if NoclipConnection then
            NoclipConnection:Disconnect()
            NoclipConnection = nil
        end
    end
end

-- ESP FUNCTION
local function createESP(targetPlayer)
    local character = targetPlayer.Character
    if not character then return end
    
    local oldHighlight = character:FindFirstChild("ESP_Highlight")
    if oldHighlight then
        oldHighlight:Destroy()
    end
    
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
    else
        if targetPlayer.Character then
            local highlight = targetPlayer.Character:FindFirstChild("ESP_Highlight")
            if highlight then
                highlight:Destroy()
            end
        end
    end
end

local function ToggleESP()
    ESPEnabled = not ESPEnabled
    
    if ESPEnabled then
        for _, targetPlayer in pairs(game.Players:GetPlayers()) do
            if targetPlayer ~= Player then
                if targetPlayer.Character then
                    createESP(targetPlayer)
                end
            end
        end
        Library:CreateNotification("HAS", "ESP ENABLED!", 3)
    else
        for targetPlayer, highlight in pairs(ESPBoxes) do
            if highlight then
                highlight:Destroy()
            end
        end
        ESPBoxes = {}
        
        for _, targetPlayer in pairs(game.Players:GetPlayers()) do
            if targetPlayer ~= Player and targetPlayer.Character then
                local highlight = targetPlayer.Character:FindFirstChild("ESP_Highlight")
                if highlight then
                    highlight:Destroy()
                end
            end
        end
        Library:CreateNotification("HAS", "ESP DISABLED!", 3)
    end
end

-- RESET FUNCTION
local function ResetAll()
    FlyEnabled = false
    if FlyConnection then
        FlyConnection:Disconnect()
        FlyConnection = nil
    end
    
    NoclipEnabled = false
    if NoclipConnection then
        NoclipConnection:Disconnect()
        NoclipConnection = nil
    end
    
    if AFKConnection then
        AFKConnection:Disconnect()
        AFKConnection = nil
    end
    
    if InfJumpConnection then
        InfJumpConnection:Disconnect()
        InfJumpConnection = nil
    end
    
    if AutoClickerConnection then
        AutoClickerConnection:Disconnect()
        AutoClickerConnection = nil
    end
    
    for _, obj in pairs(Character.HumanoidRootPart:GetChildren()) do
        if obj:IsA("BodyGyro") or obj:IsA("BodyVelocity") then
            obj:Destroy()
        end
    end
    
    Invisible = false
    for _, part in pairs(Character:GetChildren()) do
        if part:IsA("BasePart") then
            part.Transparency = 0
        end
    end
    
    ESPEnabled = false
    for targetPlayer, highlight in pairs(ESPBoxes) do
        if highlight then
            highlight:Destroy()
        end
    end
    ESPBoxes = {}
    
    Humanoid.JumpPower = 50
    Humanoid.WalkSpeed = 16
    Humanoid.MaxHealth = 100
    if Humanoid.Health > 100 then
        Humanoid.Health = 100
    end
    FlySpeed = 50
    ClickSpeed = 10
    
    NotUpEnabled = false
    AntiAFKEnabled = false
    InfJumpEnabled = false
    BrightnessEnabled = false
    AutoClickerEnabled = false
    
    -- Reset BaBfT floating
    stopFloating()
    
    -- Reset OBBY & HAS
    ObbyEnabled = false
    HasEnabled = false
    
    -- Reset 99NIGHTS
    NightModeEnabled = false
    SpeedBoostEnabled = false
    GodModeEnabled = false
    
    -- Reset brightness and lighting
    if LightingService then
        LightingService.Brightness = 2
        LightingService.Ambient = Color3.new(0.5, 0.5, 0.5)
        LightingService.OutdoorAmbient = Color3.new(0.5, 0.5, 0.5)
        LightingService.FogEnd = 100000
    end
end

-- SERVER INFO FUNCTION
local function GetServerInfo()
    local players = game.Players:GetPlayers()
    local maxPlayers = game.Players.MaxPlayers
    local placeId = game.PlaceId
    local jobId = game.JobId
    
    local fps = "Calculating..."
    pcall(function()
        fps = tostring(math.floor(1 / RunService.RenderStepped:Wait()))
    end)
    
    local ping = "Calculating..."
    pcall(function()
        local stats = StatsService:FindFirstChild("PerformanceStats")
        if stats then
            local pingStat = stats:FindFirstChild("Ping")
            if pingStat then
                ping = tostring(math.floor(pingStat:GetValue()))
            end
        end
    end)
    
    return {
        Players = #players .. "/" .. maxPlayers,
        FPS = fps,
        Ping = ping .. "ms",
        PlaceID = placeId,
        ServerID = jobId:sub(1, 8).."..."
    }
end

-- TAB 1: MAIN CONTROLS
local MainTab = Window:NewTab("Main")
local MainSection = MainTab:NewSection("Flight & Movement")

MainSection:NewKeybind("Fly", "Press Q to fly", Enum.KeyCode.Q, function()
    ToggleFly()
end)

MainSection:NewSlider("Fly Speed", "Current: " .. FlySpeed, 10, 200, function(value)
    UpdateFlySpeed(value)
end)

MainSection:NewSlider("Jump Power", "Current: 50", 50, 500, function(value)
    Humanoid.JumpPower = value
end)

MainSection:NewSlider("Walk Speed", "Current: 16", 16, 100, function(value)
    Humanoid.WalkSpeed = value
end)

-- Добавляем кнопку для яркости
MainSection:NewButton("MAX Brightness", "Toggle Maximum Brightness", function()
    ToggleBrightness()
end)

-- Новая секция для автокликера
local AutoClickerSection = MainTab:NewSection("Auto Clicker")

AutoClickerSection:NewToggle("Auto Clicker", "Enable Auto Clicker", function(state)
    ToggleAutoClicker()
end)

AutoClickerSection:NewSlider("Click Speed", "Current: " .. ClickSpeed .. " CPS", 1, 50, function(value)
    UpdateClickSpeed(value)
end)

-- TAB 2: TELEPORT
local TeleportTab = Window:NewTab("Teleport")
local TeleportSection = TeleportTab:NewSection("Teleport Controls")

TeleportSection:NewKeybind("Teleport Forward", "Press R to tp forward", Enum.KeyCode.R, function()
    TeleportForward()
end)

TeleportSection:NewKeybind("Invisibility", "Press T to toggle invisibility", Enum.KeyCode.T, function()
    ToggleInvisibility()
end)

TeleportSection:NewKeybind("TP Random Player", "Press Z to teleport to random player", Enum.KeyCode.Z, function()
    TeleportToRandomPlayer()
end)

-- TAB 3: VISUALS
local VisualsTab = Window:NewTab("Visuals")
local VisualsSection = VisualsTab:NewSection("Visual Features")

VisualsSection:NewToggle("Noclip", "Noclip Function", function(state)
    ToggleNoclip()
end)

VisualsSection:NewToggle("ESP", "ESP Function", function(state)
    ToggleESP()
end)

-- TAB 4: SERVER INFO
local ServerTab = Window:NewTab("Server Info")
local ServerSection = ServerTab:NewSection("Live Server Statistics")

local PlayersLabel = ServerSection:NewLabel("Players: Loading...")
local FPSLabel = ServerSection:NewLabel("FPS: Loading...")
local PingLabel = ServerSection:NewLabel("Ping: Loading...")
local PlaceIDLabel = ServerSection:NewLabel("Place ID: Loading...")
local ServerIDLabel = ServerSection:NewLabel("Server ID: Loading...")

spawn(function()
    while true do
        local info = GetServerInfo()
        PlayersLabel:UpdateLabel("Players: " .. info.Players)
        FPSLabel:UpdateLabel("FPS: " .. info.FPS)
        PingLabel:UpdateLabel("Ping: " .. info.Ping)
        PlaceIDLabel:UpdateLabel("Place ID: " .. info.PlaceID)
        ServerIDLabel:UpdateLabel("Server ID: " .. info.ServerID)
        wait(3)
    end
end)

ServerSection:NewButton("Rejoin Same Server", "Rejoin Same Server", function()
    local TeleportService = game:GetService("TeleportService")
    local placeId = game.PlaceId
    local serverId = game.JobId
    TeleportService:TeleportToPlaceInstance(placeId, serverId, Player)
end)

ServerSection:NewButton("Join New Server", "Join New Server", function()
    local TeleportService = game:GetService("TeleportService")
    local placeId = game.PlaceId
    TeleportService:Teleport(placeId, Player)
end)

-- Player List
local PlayerSection = ServerTab:NewSection("Online Players")

local function UpdatePlayerList()
    PlayerSection:Clear()
    
    for _, player in pairs(game.Players:GetPlayers()) do
        PlayerSection:NewLabel(player.Name .. (player == Player and " (You)" or ""))
    end
end

spawn(function()
    while true do
        UpdatePlayerList()
        wait(5)
    end
end)

-- TAB 5: ADDITIONAL FUNCTIONS
local ExtraTab = Window:NewTab("Extra")
local ExtraSection = ExtraTab:NewSection("Additional Functions")

ExtraSection:NewToggle("NotUp", "NotUp Function", function(state)
    NotUpEnabled = state
end)

ExtraSection:NewToggle("Anti-AFK", "Anti-AFK Function", function(state)
    ToggleAntiAFK()
end)

ExtraSection:NewButton("Reset Character", "Press to reset", function()
    if Character then
        Character:BreakJoints()
    end
end)

ExtraSection:NewButton("Reset All Settings", "Reset everything", function()
    ResetAll()
end)

-- ВКЛАДКА: BaBfT
local BaBfTTab = Window:NewTab("BaBfT")
local BaBfTSection1 = BaBfTTab:NewSection("BaBfT Features")

-- Добавляем функции для BaBfT вкладки
BaBfTSection1:NewButton("Activate AutoFarm 1", "Start Floating Animation", function()
    startFloating()
    Library:CreateNotification("AutoFarm", "Floating animation STARTED!", 3)
end)

BaBfTSection1:NewButton("Activate AutoFarm 2", "Stop Floating Animation", function()
    stopFloating()
    Library:CreateNotification("AutoFarm", "Floating animation STOPPED!", 3)
end)

BaBfTSection1:NewToggle("Active AntiAfk", "Enable Anti-AFK protection", function(state)
    ToggleAntiAFK()
end)

-- ВКЛАДКА: OBBY & HAS
local ObbyHasTab = Window:NewTab("OBBY & HAS")
local ObbySection = ObbyHasTab:NewSection("OBBY Features")

ObbySection:NewButton("Infinite Jump", "Toggle Infinite Jump", function()
    ToggleInfJump()
end)

ObbySection:NewButton("Anti-AFK", "Toggle Anti-AFK", function()
    ToggleAntiAFK()
end)

local HasSection = ObbyHasTab:NewSection("HAS Features")

HasSection:NewButton("ESP", "Toggle ESP", function()
    ToggleESP()
end)

HasSection:NewButton("Anti-AFK", "Toggle Anti-AFK", function()
    ToggleAntiAFK()
end)

-- ВКЛАДКА: 99NIGHTS
local NightsTab = Window:NewTab("99NIGHTS")
local NightsSection1 = NightsTab:NewSection("Night Features")

NightsSection1:NewButton("Night Mode", "Toggle Night Vision Mode", function()
    ToggleNightMode()
end)

NightsSection1:NewButton("Speed Boost", "Toggle Super Speed (100)", function()
    ToggleSpeedBoost()
end)

NightsSection1:NewButton("God Mode", "Toggle Invincibility", function()
    ToggleGodMode()
end)

local NightsSection2 = NightsTab:NewSection("Special Abilities")

NightsSection2:NewButton("Super Jump", "Activate Super Jump (10 sec)", function()
    ActivateSuperJump()
end)

NightsSection2:NewButton("Sky Teleport", "Teleport to Sky", function()
    TeleportToSky()
end)

NightsSection2:NewToggle("Infinite Jump", "Toggle Infinite Jump", function(state)
    ToggleInfJump()
end)

local NightsSection3 = NightsTab:NewSection("Night Settings")

NightsSection3:NewSlider("Jump Power", "Set Jump Power", 50, 500, function(value)
    Humanoid.JumpPower = value
    Library:CreateNotification("99NIGHTS", "Jump Power set to: " .. value, 2)
end)

NightsSection3:NewSlider("Walk Speed", "Set Walk Speed", 16, 200, function(value)
    Humanoid.WalkSpeed = value
    Library:CreateNotification("99NIGHTS", "Walk Speed set to: " .. value, 2)
end)

-- НОВАЯ ВКЛАДКА: MOBILE SUPPORT (после 99NIGHTS)
local MobileTab = Window:NewTab("Mobile Support")
local MobileSection1 = MobileTab:NewSection("Flight & Movement")

MobileSection1:NewButton("Fly", "Toggle Flying", function()
    ToggleFly()
end)

MobileSection1:NewButton("MAX Brightness", "Toggle Maximum Brightness", function()
    ToggleBrightness()
end)

MobileSection1:NewButton("Infinite Jump", "Toggle Infinite Jump", function()
    ToggleInfJump()
end)

local MobileSection2 = MobileTab:NewSection("Teleport & Visuals")

MobileSection2:NewButton("Teleport Forward", "Teleport Forward", function()
    TeleportForward()
end)

MobileSection2:NewButton("Invisibility", "Toggle Invisibility", function()
    ToggleInvisibility()
end)

MobileSection2:NewButton("TP Random Player", "Teleport to Random Player", function()
    TeleportToRandomPlayer()
end)

MobileSection2:NewButton("ESP", "Toggle ESP", function()
    ToggleESP()
end)

MobileSection2:NewButton("Noclip", "Toggle Noclip", function()
    ToggleNoclip()
end)

local MobileSection3 = MobileTab:NewSection("Auto Functions")

MobileSection3:NewToggle("Auto Clicker", "Enable Auto Clicker", function(state)
    ToggleAutoClicker()
end)

MobileSection3:NewToggle("Anti-AFK", "Enable Anti-AFK", function(state)
    ToggleAntiAFK()
end)

local MobileSection4 = MobileTab:NewSection("Character Control")

MobileSection4:NewButton("Reset Character", "Reset Character", function()
    if Character then
        Character:BreakJoints()
    end
end)

MobileSection4:NewButton("Reset All Settings", "Reset All Settings", function()
    ResetAll()
end)

-- CHARACTER RESPAWN HANDLER
Player.CharacterAdded:Connect(function(newChar)
    Character = newChar
    Humanoid = newChar:WaitForChild("Humanoid")
    root = newChar:WaitForChild("HumanoidRootPart")
    task.wait(1)
    ResetAll()
end)

-- ESP PLAYER HANDLERS
game.Players.PlayerAdded:Connect(function(newPlayer)
    if ESPEnabled then
        newPlayer.CharacterAdded:Connect(function()
            wait(1)
            createESP(newPlayer)
        end)
    end
    UpdatePlayerList()
end)

game.Players.PlayerRemoving:Connect(function(leavingPlayer)
    removeESP(leavingPlayer)
    UpdatePlayerList()
end)

-- INITIAL NOTIFICATION

Library:CreateNotification("EZScript", "Script loaded successfully! All functions available.", 5)
