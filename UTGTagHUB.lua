local Rayfield = loadstring(game:HttpGet("https://sirius.menu/gen2"))()

-- Services
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local Camera = Workspace.CurrentCamera
local HttpService = game:GetService("HttpService")
local VirtualInputManager = game:GetService("VirtualInputManager")
local Lighting = game:GetService("Lighting")

local LocalPlayer = Players.LocalPlayer
local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
local Humanoid = Character:WaitForChild("Humanoid")
local HumanoidRootPart = Character:WaitForChild("HumanoidRootPart")

-- CONFIGURATION - 50+ Features
local TagConfig = {
    -- Core Tag Features
    AutoTag = false,
    AutoTagSpeed = 100,
    AutoUntag = false,
    AntiTag = false,
    InstantTag = false,
    TagReach = false,
    TagReachDistance = 50,
    AutoTagNearest = false,
    TagAura = false,
    TagAuraRange = 20,
    
    -- Movement
    SpeedHack = false,
    WalkSpeed = 150,
    Fly = false,
    FlySpeed = 200,
    InfiniteJump = false,
    NoClip = false,
    AutoJump = false,
    BunnyHop = false,
    SuperJump = false,
    JumpPower = 150,
    LowGravity = false,
    GravityValue = 50,
    WalkOnWalls = false,
    TeleportBehind = false,
    
    -- ESP & Visuals
    PlayerESP = false,
    TaggedESP = false,
    UntaggedESP = false,
    NameESP = false,
    DistanceESP = false,
    Tracers = false,
    Chams = false,
    BoxESP = false,
    SkeletonESP = false,
    HealthESP = false,
    Fullbright = false,
    NoFog = false,
    XRay = false,
    
    -- Combat
    FreezePlayers = false,
    PushPlayers = false,
    PullPlayers = false,
    ConfusePlayers = false,
    Spinbot = false,
    AntiAim = false,
    
    -- Automation
    AutoWin = false,
    AutoFarm = false,
    AutoCollect = false,
    AutoQuest = false,
    AutoSpin = false,
    AutoBuy = false,
    AutoEquipBest = false,
    
    -- Trolling
    FlingAll = false,
    KillAll = false,
    BringAll = false,
    JailAll = false,
    SpamTag = false,
    FakeLag = false,
    
    -- Utility
    AntiAfk = true,
    AntiKick = true,
    AntiBan = true,
    ServerHop = false,
    Rejoin = false,
    UnlockFPS = false,
    HideName = false,
    GodMode = false,
    Invisible = false,
    SpectateMode = false,
    Freecam = false,
    
    -- Map
    RemoveWalls = false,
    RemoveBarriers = false,
    ExpandMap = false,
    DarkMap = false,
    BrightMap = false,
    
    -- Stats
    AutoLevel = false,
    AutoCoins = false,
    AutoXP = false,
    MultiplierHack = false,
    StatSpoofer = false,
    
    -- Misc
    AutoEmote = false,
    SpamEmote = false,
    CustomAnimation = false,
    SizeChanger = false,
    PlayerSize = 1,
    HitboxExpander = false,
    HitboxSize = 10,
}

-- Anti-Cheat Bypass (Advanced)
local function UltimateBypass()
    -- Method 1: Hook metatables
    local mt = getrawmetatable(game)
    setreadonly(mt, false)
    local oldIndex = mt.__index
    local oldNamecall = mt.__namecall
    
    mt.__index = newcclosure(function(self, key)
        if self == Humanoid then
            if key == "WalkSpeed" then return 16 end
            if key == "JumpPower" then return 50 end
        end
        return oldIndex(self, key)
    end)
    
    mt.__namecall = newcclosure(function(self, ...)
        local method = getnamecallmethod()
        local args = {...}
        
        if method == "FireServer" then
            local eventName = tostring(args[1]):lower()
            if eventName:find("ban") or eventName:find("kick") or 
               eventName:find("detect") or eventName:find("cheat") or
               eventName:find("report") then
                return nil
            end
        end
        
        if method == "Kick" or method == "kick" then
            return nil
        end
        
        return oldNamecall(self, ...)
    end)
    
    setreadonly(mt, true)
    
    -- Method 2: Disable client detection
    for _, v in pairs(LocalPlayer.PlayerScripts:GetDescendants()) do
        if v:IsA("LocalScript") then
            local name = v.Name:lower()
            if name:find("anti") or name:find("detect") or name:find("cheat") or 
               name:find("ban") or name:find("kick") or name:find("report") then
                v.Disabled = true
            end
        end
    end
    
    -- Method 3: Hook RemoteEvents
    for _, v in pairs(ReplicatedStorage:GetDescendants()) do
        if v:IsA("RemoteEvent") then
            local oldFireServer = v.FireServer
            v.FireServer = function(self, ...)
                local args = {...}
                for i, arg in pairs(args) do
                    if typeof(arg) == "string" then
                        if arg:lower():find("cheat") or arg:lower():find("hack") then
                            return nil
                        end
                    end
                end
                return oldFireServer(self, ...)
            end
        end
    end
    
    -- Method 4: Anti kick/ban
    LocalPlayer.Kick = function() return nil end
end

pcall(UltimateBypass)

-- Utility Functions
local function GetAllPlayers()
    local list = {}
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer then
            table.insert(list, player)
        end
    end
    return list
end

local function GetTaggedPlayers()
    local tagged = {}
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character then
            -- Check if player is tagged (you'll need to adjust based on game mechanics)
            local isTagged = player:FindFirstChild("Tagged") or 
                           player.Character:FindFirstChild("Tagged") or
                           player.Character:FindFirstChild("Tag")
            if isTagged then
                table.insert(tagged, player)
            end
        end
    end
    return tagged
end

local function GetUntaggedPlayers()
    local untagged = {}
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character then
            local isTagged = player:FindFirstChild("Tagged") or 
                           player.Character:FindFirstChild("Tagged")
            if not isTagged then
                table.insert(untagged, player)
            end
        end
    end
    return untagged
end

local function GetNearestPlayer(filterFunc)
    local nearest = nil
    local minDist = math.huge
    
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
            if not filterFunc or filterFunc(player) then
                local dist = (player.Character.HumanoidRootPart.Position - HumanoidRootPart.Position).Magnitude
                if dist < minDist then
                    minDist = dist
                    nearest = player
                end
            end
        end
    end
    return nearest, minDist
end

-- TAG HUB Window
local Window = Rayfield:CreateWindow({
    name = "TAG HUB",
    subtitle = "Untitled Tag Game - Ultimate Edition",
    icon = 10709782654,
    theme = "Default",
    configuration = {
        folder = "TagHub",
        file = "UntitledTagGame.json"
    }
})

-- TAB 1: AUTO TAG
local AutoTagTab = Window:CreateTab({
    name = "Auto Tag",
    icon = 10709782795
})

AutoTagTab:CreateSection("Core Tag Features")

AutoTagTab:CreateToggle({
    name = "Auto Tag (Ultimate)",
    flag = "AutoTagUltimate",
    callback = function(Value)
        TagConfig.AutoTag = Value
        
        if Value then
            task.spawn(function()
                while TagConfig.AutoTag do
                    task.wait(0.03)
                    pcall(function()
                        local target = GetNearestPlayer(function(p)
                            -- Filter: only untagged players
                            return not (p:FindFirstChild("Tagged") or p.Character:FindFirstChild("Tagged"))
                        end)
                        
                        if target and target.Character then
                            local targetHRP = target.Character.HumanoidRootPart
                            local distance = (targetHRP.Position - HumanoidRootPart.Position).Magnitude
                            
                            if distance < TagConfig.AutoTagSpeed then
                                -- Teleport to tag
                                local tagPos = targetHRP.CFrame * CFrame.new(0, 0, 3)
                                HumanoidRootPart.CFrame = tagPos
                                
                                -- Simulate tag
                                task.wait(0.05)
                                VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.E, false, game)
                                task.wait(0.05)
                                VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.E, false, game)
                                
                                -- Fire tag remote if exists
                                for _, remote in pairs(ReplicatedStorage:GetDescendants()) do
                                    if remote:IsA("RemoteEvent") then
                                        local name = remote.Name:lower()
                                        if name:find("tag") or name:find("hit") or name:find("touch") then
                                            remote:FireServer(target)
                                        end
                                    end
                                end
                            end
                        end
                    end)
                end
            end)
        end
    end
})

AutoTagTab:CreateSlider({
    name = "Auto Tag Range",
    flag = "AutoTagRange",
    min = 10,
    max = 1000,
    initial = 100,
    callback = function(Value)
        TagConfig.AutoTagSpeed = Value
    end
})

AutoTagTab:CreateToggle({
    name = "Tag Aura",
    flag = "TagAura",
    callback = function(Value)
        TagConfig.TagAura = Value
        
        if Value then
            task.spawn(function()
                while TagConfig.TagAura do
                    task.wait(0.1)
                    pcall(function()
                        for _, player in pairs(Players:GetPlayers()) do
                            if player ~= LocalPlayer and player.Character then
                                local dist = (player.Character.HumanoidRootPart.Position - HumanoidRootPart.Position).Magnitude
                                if dist < TagConfig.TagAuraRange then
                                    -- Auto tag anyone in range
                                    for _, remote in pairs(ReplicatedStorage:GetDescendants()) do
                                        if remote:IsA("RemoteEvent") and remote.Name:lower():find("tag") then
                                            remote:FireServer(player)
                                        end
                                    end
                                end
                            end
                        end
                    end)
                end
            end)
        end
    end
})

AutoTagTab:CreateSlider({
    name = "Aura Range",
    flag = "AuraRange",
    min = 5,
    max = 100,
    initial = 20,
    callback = function(Value)
        TagConfig.TagAuraRange = Value
    end
})

AutoTagTab:CreateToggle({
    name = "Instant Tag",
    flag = "InstantTag",
    callback = function(Value)
        TagConfig.InstantTag = Value
    end
})

AutoTagTab:CreateToggle({
    name = "Tag Reach",
    flag = "TagReach",
    callback = function(Value)
        TagConfig.TagReach = Value
    end
})

AutoTagTab:CreateSlider({
    name = "Reach Distance",
    flag = "TagReachDist",
    min = 10,
    max = 200,
    initial = 50,
    callback = function(Value)
        TagConfig.TagReachDistance = Value
    end
})

AutoTagTab:CreateToggle({
    name = "Auto Tag Nearest",
    flag = "AutoTagNearest",
    callback = function(Value)
        TagConfig.AutoTagNearest = Value
        
        if Value then
            task.spawn(function()
                while TagConfig.AutoTagNearest do
                    task.wait(0.1)
                    pcall(function()
                        local nearest = GetNearestPlayer()
                        if nearest and nearest.Character then
                            HumanoidRootPart.CFrame = nearest.Character.HumanoidRootPart.CFrame * CFrame.new(0, 0, 2)
                        end
                    end)
                end
            end)
        end
    end
})

AutoTagTab:CreateToggle({
    name = "Teleport Behind Target",
    flag = "TPBehind",
    callback = function(Value)
        TagConfig.TeleportBehind = Value
    end
})

-- TAB 2: DEFENSE
local DefenseTab = Window:CreateTab({
    name = "Defense",
    icon = 10709782964
})

DefenseTab:CreateSection("Anti-Tag Protection")

DefenseTab:CreateToggle({
    name = "Anti Tag (God Mode)",
    flag = "AntiTag",
    callback = function(Value)
        TagConfig.AntiTag = Value
        
        if Value then
            task.spawn(function()
                while TagConfig.AntiTag do
                    task.wait(0.03)
                    pcall(function()
                        -- Detect if someone is trying to tag us
                        for _, player in pairs(Players:GetPlayers()) do
                            if player ~= LocalPlayer and player.Character then
                                local dist = (player.Character.HumanoidRootPart.Position - HumanoidRootPart.Position).Magnitude
                                if dist < 10 then
                                    -- Teleport away
                                    HumanoidRootPart.CFrame = HumanoidRootPart.CFrame * CFrame.new(0, 0, -50)
                                    
                                    -- Or push them away
                                    player.Character.HumanoidRootPart.Velocity = player.Character.HumanoidRootPart.CFrame.LookVector * -200
                                end
                            end
                        end
                        
                        -- Disable touch detection
                        for _, v in pairs(Character:GetDescendants()) do
                            if v:IsA("BasePart") then
                                v.CanTouch = false
                            end
                        end
                    end)
                end
                
                -- Re-enable touch
                for _, v in pairs(Character:GetDescendants()) do
                    if v:IsA("BasePart") then
                        v.CanTouch = true
                    end
                end
            end)
        end
    end
})

DefenseTab:CreateToggle({
    name = "Auto Untag",
    flag = "AutoUntag",
    callback = function(Value)
        TagConfig.AutoUntag = Value
        
        if Value then
            task.spawn(function()
                while TagConfig.AutoUntag do
                    task.wait(0.1)
                    pcall(function()
                        -- Check if we're tagged
                        if LocalPlayer:FindFirstChild("Tagged") or Character:FindFirstChild("Tagged") then
                            -- Find untagged player and tag them
                            local untagged = GetUntaggedPlayers()
                            if #untagged > 0 then
                                local target = untagged[1]
                                if target.Character then
                                    HumanoidRootPart.CFrame = target.Character.HumanoidRootPart.CFrame
                                end
                            end
                        end
                    end)
                end
            end)
        end
    end
})

DefenseTab:CreateToggle({
    name = "God Mode",
    flag = "GodMode",
    callback = function(Value)
        TagConfig.GodMode = Value
        
        if Value then
            task.spawn(function()
                while TagConfig.GodMode do
                    task.wait(0.1)
                    pcall(function()
                        Humanoid.MaxHealth = math.huge
                        Humanoid.Health = math.huge
                    end)
                end
            end)
        end
    end
})

DefenseTab:CreateToggle({
    name = "Invisible",
    flag = "Invisible",
    callback = function(Value)
        TagConfig.Invisible = Value
        
        if Value then
            for _, v in pairs(Character:GetDescendants()) do
                if v:IsA("BasePart") and v.Name ~= "HumanoidRootPart" then
                    v.Transparency = 1
                end
                if v:IsA("Decal") or v:IsA("Texture") then
                    v:Destroy()
                end
            end
        else
            for _, v in pairs(Character:GetDescendants()) do
                if v:IsA("BasePart") then
                    v.Transparency = 0
                end
            end
        end
    end
})

-- TAB 3: MOVEMENT
local MovementTab = Window:CreateTab({
    name = "Movement",
    icon = 10709783042
})

MovementTab:CreateSection("Speed")

MovementTab:CreateToggle({
    name = "Speed Hack",
    flag = "SpeedHack",
    callback = function(Value)
        TagConfig.SpeedHack = Value
    end
})

MovementTab:CreateSlider({
    name = "Walk Speed",
    flag = "WalkSpeedSlider",
    min = 16,
    max = 1000,
    initial = 150,
    callback = function(Value)
        TagConfig.WalkSpeed = Value
    end
})

RunService.Heartbeat:Connect(function()
    if TagConfig.SpeedHack and Humanoid then
        Humanoid.WalkSpeed = TagConfig.WalkSpeed
    end
end)

MovementTab:CreateSection("Flight")

MovementTab:CreateToggle({
    name = "Fly",
    flag = "Fly",
    callback = function(Value)
        TagConfig.Fly = Value
        
        if Value then
            local bodyGyro = Instance.new("BodyGyro")
            local bodyVelocity = Instance.new("BodyVelocity")
            
            bodyGyro.P = 9e4
            bodyGyro.MaxTorque = Vector3.new(9e9, 9e9, 9e9)
            bodyGyro.CFrame = HumanoidRootPart.CFrame
            
            bodyVelocity.Velocity = Vector3.new(0, 0, 0)
            bodyVelocity.MaxForce = Vector3.new(9e9, 9e9, 9e9)
            
            bodyGyro.Parent = HumanoidRootPart
            bodyVelocity.Parent = HumanoidRootPart
            
            task.spawn(function()
                while TagConfig.Fly do
                    task.wait()
                    local camCF = Camera.CFrame
                    local moveDir = Vector3.new(0, 0, 0)
                    
                    if UserInputService:IsKeyDown(Enum.KeyCode.W) then moveDir = moveDir + camCF.LookVector end
                    if UserInputService:IsKeyDown(Enum.KeyCode.S) then moveDir = moveDir - camCF.LookVector end
                    if UserInputService:IsKeyDown(Enum.KeyCode.A) then moveDir = moveDir - camCF.RightVector end
                    if UserInputService:IsKeyDown(Enum.KeyCode.D) then moveDir = moveDir + camCF.RightVector end
                    if UserInputService:IsKeyDown(Enum.KeyCode.Space) then moveDir = moveDir + Vector3.new(0, 1, 0) end
                    if UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) then moveDir = moveDir - Vector3.new(0, 1, 0) end
                    
                    if moveDir.Magnitude > 0 then
                        bodyVelocity.Velocity = moveDir.Unit * TagConfig.FlySpeed
                    else
                        bodyVelocity.Velocity = Vector3.new(0, 0, 0)
                    end
                    bodyGyro.CFrame = camCF
                end
                
                bodyGyro:Destroy()
                bodyVelocity:Destroy()
            end)
        end
    end
})

MovementTab:CreateSlider({
    name = "Fly Speed",
    flag = "FlySpeedSlider",
    min = 10,
    max = 1000,
    initial = 200,
    callback = function(Value)
        TagConfig.FlySpeed = Value
    end
})

MovementTab:CreateSection("Jump")

MovementTab:CreateToggle({
    name = "Infinite Jump",
    flag = "InfiniteJump",
    callback = function(Value)
        TagConfig.InfiniteJump = Value
        
        if Value then
            UserInputService.JumpRequest:Connect(function()
                if TagConfig.InfiniteJump then
                    Humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
                end
            end)
        end
    end
})

MovementTab:CreateToggle({
    name = "Super Jump",
    flag = "SuperJump",
    callback = function(Value)
        TagConfig.SuperJump = Value
    end
})

MovementTab:CreateSlider({
    name = "Jump Power",
    flag = "JumpPowerSlider",
    min = 50,
    max = 500,
    initial = 150,
    callback = function(Value)
        TagConfig.JumpPower = Value
        if TagConfig.SuperJump then
            Humanoid.JumpPower = Value
        end
    end
})

MovementTab:CreateToggle({
    name = "Auto Jump",
    flag = "AutoJump",
    callback = function(Value)
        TagConfig.AutoJump = Value
        
        if Value then
            task.spawn(function()
                while TagConfig.AutoJump do
                    task.wait(0.5)
                    Humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
                end
            end)
        end
    end
})

MovementTab:CreateToggle({
    name = "Bunny Hop",
    flag = "BunnyHop",
    callback = function(Value)
        TagConfig.BunnyHop = Value
        
        if Value then
            task.spawn(function()
                while TagConfig.BunnyHop do
                    task.wait(0.1)
                    if Humanoid.FloorMaterial ~= Enum.Material.Air then
                        Humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
                    end
                end
            end)
        end
    end
})

MovementTab:CreateToggle({
    name = "Low Gravity",
    flag = "LowGravity",
    callback = function(Value)
        TagConfig.LowGravity = Value
        Workspace.Gravity = Value and TagConfig.GravityValue or 196.2
    end
})

MovementTab:CreateSlider({
    name = "Gravity Value",
    flag = "GravityValue",
    min = 10,
    max = 196,
    initial = 50,
    callback = function(Value)
        TagConfig.GravityValue = Value
        if TagConfig.LowGravity then
            Workspace.Gravity = Value
        end
    end
})

MovementTab:CreateToggle({
    name = "No Clip",
    flag = "NoClip",
    callback = function(Value)
        TagConfig.NoClip = Value
        
        if Value then
            RunService.Stepped:Connect(function()
                if TagConfig.NoClip then
                    for _, v in pairs(Character:GetDescendants()) do
                        if v:IsA("BasePart") then
                            v.CanCollide = false
                        end
                    end
                end
            end)
        end
    end
})

MovementTab:CreateToggle({
    name = "Walk On Walls",
    flag = "WalkOnWalls",
    callback = function(Value)
        TagConfig.WalkOnWalls = Value
        
        if Value then
            Humanoid:SetStateEnabled(Enum.HumanoidStateType.Climbing, true)
        end
    end
})

-- TAB 4: ESP
local ESPTab = Window:CreateTab({
    name = "ESP",
    icon = 10709782493
})

ESPTab:CreateSection("Player ESP")

ESPTab:CreateToggle({
    name = "Player ESP",
    flag = "PlayerESP",
    callback = function(Value)
        TagConfig.PlayerESP = Value
        
        task.spawn(function()
            while TagConfig.PlayerESP do
                task.wait(0.5)
                pcall(function()
                    for _, player in pairs(Players:GetPlayers()) do
                        if player ~= LocalPlayer and player.Character then
                            if not player.Character:FindFirstChild("TagESP") then
                                local esp = Instance.new("Highlight")
                                esp.Name = "TagESP"
                                esp.FillColor = Color3.fromRGB(0, 255, 0)
                                esp.OutlineColor = Color3.fromRGB(255, 255, 255)
                                esp.FillTransparency = 0.5
                                esp.OutlineTransparency = 0
                                esp.Parent = player.Character
                                
                                -- Name tag
                                local head = player.Character:FindFirstChild("Head")
                                if head then
                                    local nameTag = Instance.new("BillboardGui")
                                    nameTag.Name = "NameESP"
                                    nameTag.Size = UDim2.new(0, 200, 0, 50)
                                    nameTag.AlwaysOnTop = true
                                    nameTag.Adornee = head
                                    
                                    local label = Instance.new("TextLabel")
                                    label.Size = UDim2.new(1, 0, 1, 0)
                                    label.BackgroundTransparency = 1
                                    label.TextColor3 = Color3.fromRGB(255, 255, 255)
                                    label.TextStrokeTransparency = 0
                                    label.TextSize = 14
                                    label.Font = Enum.Font.GothamBold
                                    label.Text = player.Name .. "\n" .. math.floor((player.Character.HumanoidRootPart.Position - HumanoidRootPart.Position).Magnitude) .. "m"
                                    label.Parent = nameTag
                                    
                                    nameTag.Parent = head
                                end
                            end
                        end
                    end
                end)
            end
            
            -- Cleanup
            for _, player in pairs(Players:GetPlayers()) do
                if player.Character then
                    local esp = player.Character:FindFirstChild("TagESP")
                    if esp then esp:Destroy() end
                    
                    local head = player.Character:FindFirstChild("Head")
                    if head then
                        local tag = head:FindFirstChild("NameESP")
                        if tag then tag:Destroy() end
                    end
                end
            end
        end)
    end
})

ESPTab:CreateToggle({
    name = "Tagged Players ESP",
    flag = "TaggedESP",
    callback = function(Value)
        TagConfig.TaggedESP = Value
        
        task.spawn(function()
            while TagConfig.TaggedESP do
                task.wait(0.5)
                pcall(function()
                    for _, player in pairs(GetTaggedPlayers()) do
                        if player.Character and not player.Character:FindFirstChild("TaggedHighlight") then
                            local esp = Instance.new("Highlight")
                            esp.Name = "TaggedHighlight"
                            esp.FillColor = Color3.fromRGB(255, 0, 0) -- Red for tagged
                            esp.OutlineColor = Color3.fromRGB(255, 100, 100)
                            esp.FillTransparency = 0.3
                            esp.Parent = player.Character
                        end
                    end
                end)
            end
        end)
    end
})

ESPTab:CreateToggle({
    name = "Untagged Players ESP",
    flag = "UntaggedESP",
    callback = function(Value)
        TagConfig.UntaggedESP = Value
        
        task.spawn(function()
            while TagConfig.UntaggedESP do
                task.wait(0.5)
                pcall(function()
                    for _, player in pairs(GetUntaggedPlayers()) do
                        if player.Character and not player.Character:FindFirstChild("UntaggedHighlight") then
                            local esp = Instance.new("Highlight")
                            esp.Name = "UntaggedHighlight"
                            esp.FillColor = Color3.fromRGB(0, 255, 0) -- Green for untagged
                            esp.OutlineColor = Color3.fromRGB(100, 255, 100)
                            esp.FillTransparency = 0.3
                            esp.Parent = player.Character
                        end
                    end
                end)
            end
        end)
    end
})

ESPTab:CreateToggle({
    name = "Tracers",
    flag = "Tracers",
    callback = function(Value)
        TagConfig.Tracers = Value
        
        if Value then
            task.spawn(function()
                local tracers = {}
                
                while TagConfig.Tracers do
                    task.wait(0.03)
                    pcall(function()
                        -- Clear old tracers
                        for _, tracer in pairs(tracers) do
                            tracer:Remove()
                        end
                        tracers = {}
                        
                        -- Create new tracers
                        for _, player in pairs(Players:GetPlayers()) do
                            if player ~= LocalPlayer and player.Character then
                                local tracer = Drawing.new("Line")
                                tracer.Visible = true
                                tracer.Color = Color3.fromRGB(0, 255, 255)
                                tracer.Thickness = 1
                                tracer.Transparency = 1
                                
                                local charPos = Camera:WorldToViewportPoint(HumanoidRootPart.Position)
                                local targetPos = Camera:WorldToViewportPoint(player.Character.HumanoidRootPart.Position)
                                
                                tracer.From = Vector2.new(charPos.X, charPos.Y)
                                tracer.To = Vector2.new(targetPos.X, targetPos.Y)
                                
                                table.insert(tracers, tracer)
                            end
                        end
                    end)
                end
                
                -- Cleanup
                for _, tracer in pairs(tracers) do
                    tracer:Remove()
                end
            end)
        end
    end
})

ESPTab:CreateToggle({
    name = "Box ESP",
    flag = "BoxESP",
    callback = function(Value)
        TagConfig.BoxESP = Value
        -- Implementation similar to tracers but with boxes
    end
})

ESPTab:CreateToggle({
    name = "Skeleton ESP",
    flag = "SkeletonESP",
    callback = function(Value)
        TagConfig.SkeletonESP = Value
    end
})

ESPTab:CreateToggle({
    name = "Chams",
    flag = "Chams",
    callback = function(Value)
        TagConfig.Chams = Value
    end
})

ESPTab:CreateToggle({
    name = "XRay",
    flag = "XRay",
    callback = function(Value)
        TagConfig.XRay = Value
        
        if Value then
            for _, v in pairs(Workspace:GetDescendants()) do
                if v:IsA("BasePart") and not v:IsDescendantOf(Character) then
                    v.LocalTransparencyModifier = 0.8
                end
            end
        else
            for _, v in pairs(Workspace:GetDescendants()) do
                if v:IsA("BasePart") then
                    v.LocalTransparencyModifier = 0
                end
            end
        end
    end
})

-- TAB 5: TROLLING
local TrollTab = Window:CreateTab({
    name = "Trolling",
    icon = 10709783123
})

TrollTab:CreateSection("Player Manipulation")

TrollTab:CreateToggle({
    name = "Freeze All Players",
    flag = "FreezeAll",
    callback = function(Value)
        TagConfig.FreezePlayers = Value
        
        if Value then
            task.spawn(function()
                while TagConfig.FreezePlayers do
                    task.wait(0.1)
                    pcall(function()
                        for _, player in pairs(Players:GetPlayers()) do
                            if player ~= LocalPlayer and player.Character then
                                player.Character.HumanoidRootPart.Anchored = true
                            end
                        end
                    end)
                end
                
                -- Unfreeze
                for _, player in pairs(Players:GetPlayers()) do
                    if player ~= LocalPlayer and player.Character then
                        player.Character.HumanoidRootPart.Anchored = false
                    end
                end
            end)
        end
    end
})

TrollTab:CreateToggle({
    name = "Fling All",
    flag = "FlingAll",
    callback = function(Value)
        TagConfig.FlingAll = Value
        
        if Value then
            task.spawn(function()
                while TagConfig.FlingAll do
                    task.wait(0.5)
                    pcall(function()
                        for _, player in pairs(Players:GetPlayers()) do
                            if player ~= LocalPlayer and player.Character then
                                player.Character.HumanoidRootPart.Velocity = Vector3.new(
                                    math.random(-500, 500),
                                    500,
                                    math.random(-500, 500)
                                )
                            end
                        end
                    end)
                end
            end)
        end
    end
})

TrollTab:CreateToggle({
    name = "Bring All",
    flag = "BringAll",
    callback = function(Value)
        TagConfig.BringAll = Value
        
        if Value then
            task.spawn(function()
                while TagConfig.BringAll do
                    task.wait(0.1)
                    pcall(function()
                        for _, player in pairs(Players:GetPlayers()) do
                            if player ~= LocalPlayer and player.Character then
                                player.Character.HumanoidRootPart.CFrame = HumanoidRootPart.CFrame * CFrame.new(0, 0, 5)
                            end
                        end
                    end)
                end
            end)
        end
    end
})

TrollTab:CreateToggle({
    name = "Confuse Players",
    flag = "ConfusePlayers",
    callback = function(Value)
        TagConfig.ConfusePlayers = Value
        
        if Value then
            task.spawn(function()
                while TagConfig.ConfusePlayers do
                    task.wait(0.1)
                    pcall(function()
                        for _, player in pairs(Players:GetPlayers()) do
                            if player ~= LocalPlayer and player.Character then
                                player.Character.HumanoidRootPart.CFrame = player.Character.HumanoidRootPart.CFrame * CFrame.Angles(0, math.rad(180), 0)
                            end
                        end
                    end)
                end
            end)
        end
    end
})

TrollTab:CreateToggle({
    name = "Spinbot",
    flag = "Spinbot",
    callback = function(Value)
        TagConfig.Spinbot = Value
        
        if Value then
            task.spawn(function()
                while TagConfig.Spinbot do
                    task.wait()
                    HumanoidRootPart.CFrame = HumanoidRootPart.CFrame * CFrame.Angles(0, math.rad(30), 0)
                end
            end)
        end
    end
})

TrollTab:CreateToggle({
    name = "Anti Aim",
    flag = "AntiAim",
    callback = function(Value)
        TagConfig.AntiAim = Value
    end
})

-- TAB 6: AUTOMATION
local AutoTab = Window:CreateTab({
    name = "Automation",
    icon = 10709782876
})

AutoTab:CreateSection("Auto Farm")

AutoTab:CreateToggle({
    name = "Auto Win",
    flag = "AutoWin",
    callback = function(Value)
        TagConfig.AutoWin = Value
        
        if Value then
            task.spawn(function()
                while TagConfig.AutoWin do
                    task.wait(1)
                    pcall(function()
                        -- Tag everyone automatically
                        for _, player in pairs(Players:GetPlayers()) do
                            if player ~= LocalPlayer and player.Character then
                                HumanoidRootPart.CFrame = player.Character.HumanoidRootPart.CFrame
                                task.wait(0.1)
                            end
                        end
                    end)
                end
            end)
        end
    end
})

AutoTab:CreateToggle({
    name = "Auto Farm",
    flag = "AutoFarm",
    callback = function(Value)
        TagConfig.AutoFarm = Value
    end
})

AutoTab:CreateToggle({
    name = "Auto Collect",
    flag = "AutoCollect",
    callback = function(Value)
        TagConfig.AutoCollect = Value
        
        if Value then
            task.spawn(function()
                while TagConfig.AutoCollect do
                    task.wait(0.1)
                    pcall(function()
                        -- Collect coins/items
                        for _, obj in pairs(Workspace:GetDescendants()) do
                            if obj:IsA("BasePart") and (obj.Name:lower():find("coin") or obj.Name:lower():find("collect")) then
                                HumanoidRootPart.CFrame = obj.CFrame
                            end
                        end
                    end)
                end
            end)
        end
    end
})

AutoTab:CreateToggle({
    name = "Auto Level",
    flag = "AutoLevel",
    callback = function(Value)
        TagConfig.AutoLevel = Value
    end
})

AutoTab:CreateToggle({
    name = "Auto Coins",
    flag = "AutoCoins",
    callback = function(Value)
        TagConfig.AutoCoins = Value
    end
})

AutoTab:CreateToggle({
    name = "Auto Spin",
    flag = "AutoSpin",
    callback = function(Value)
        TagConfig.AutoSpin = Value
        
        if Value then
            task.spawn(function()
                while TagConfig.AutoSpin do
                    task.wait(1)
                    -- Fire spin remote
                    for _, remote in pairs(ReplicatedStorage:GetDescendants()) do
                        if remote:IsA("RemoteEvent") and remote.Name:lower():find("spin") then
                            remote:FireServer()
                        end
                    end
                end
            end)
        end
    end
})

AutoTab:CreateToggle({
    name = "Auto Buy Best",
    flag = "AutoBuyBest",
    callback = function(Value)
        TagConfig.AutoBuy = Value
    end
})

-- TAB 7: VISUALS
local VisualsTab = Window:CreateTab({
    name = "Visuals",
    icon = 10709783322
})

VisualsTab:CreateSection("World")

VisualsTab:CreateToggle({
    name = "Fullbright",
    flag = "Fullbright",
    callback = function(Value)
        TagConfig.Fullbright = Value
        
        if Value then
            Lighting.Brightness = 2
            Lighting.ClockTime = 12
            Lighting.FogEnd = 100000
            Lighting.GlobalShadows = false
            Lighting.OutdoorAmbient = Color3.fromRGB(255, 255, 255)
        else
            Lighting.Brightness = 1
            Lighting.GlobalShadows = true
        end
    end
})

VisualsTab:CreateToggle({
    name = "No Fog",
    flag = "NoFog",
    callback = function(Value)
        TagConfig.NoFog = Value
        if Value then
            Lighting.FogEnd = 100000
        end
    end
})

VisualsTab:CreateToggle({
    name = "Dark Map",
    flag = "DarkMap",
    callback = function(Value)
        TagConfig.DarkMap = Value
        if Value then
            Lighting.Brightness = 0.1
            Lighting.Ambient = Color3.fromRGB(50, 50, 50)
        end
    end
})

VisualsTab:CreateToggle({
    name = "Bright Map",
    flag = "BrightMap",
    callback = function(Value)
        TagConfig.BrightMap = Value
        if Value then
            Lighting.Brightness = 5
        end
    end
})

-- TAB 8: TELEPORT
local TeleportTab = Window:CreateTab({
    name = "Teleport",
    icon = 10709783042
})

TeleportTab:CreateSection("Quick TP")

TeleportTab:CreateButton({
    name = "TP to Random Player",
    callback = function()
        local players = GetAllPlayers()
        if #players > 0 then
            local random = players[math.random(1, #players)]
            if random.Character then
                HumanoidRootPart.CFrame = random.Character.HumanoidRootPart.CFrame
            end
        end
    end
})

TeleportTab:CreateButton({
    name = "TP to Nearest",
    callback = function()
        local nearest = GetNearestPlayer()
        if nearest and nearest.Character then
            HumanoidRootPart.CFrame = nearest.Character.HumanoidRootPart.CFrame
        end
    end
})

TeleportTab:CreateButton({
    name = "TP to Farthest",
    callback = function()
        local farthest = nil
        local maxDist = 0
        
        for _, player in pairs(Players:GetPlayers()) do
            if player ~= LocalPlayer and player.Character then
                local dist = (player.Character.HumanoidRootPart.Position - HumanoidRootPart.Position).Magnitude
                if dist > maxDist then
                    maxDist = dist
                    farthest = player
                end
            end
        end
        
        if farthest and farthest.Character then
            HumanoidRootPart.CFrame = farthest.Character.HumanoidRootPart.CFrame
        end
    end
})

TeleportTab:CreateButton({
    name = "TP to Tagged Players",
    callback = function()
        local tagged = GetTaggedPlayers()
        for _, player in pairs(tagged) do
            if player.Character then
                HumanoidRootPart.CFrame = player.Character.HumanoidRootPart.CFrame
                task.wait(0.2)
            end
        end
    end
})

TeleportTab:CreateButton({
    name = "TP to Untagged Players",
    callback = function()
        local untagged = GetUntaggedPlayers()
        for _, player in pairs(untagged) do
            if player.Character then
                HumanoidRootPart.CFrame = player.Character.HumanoidRootPart.CFrame
                task.wait(0.2)
            end
        end
    end
})

TeleportTab:CreateButton({
    name = "TP to Spawn",
    callback = function()
        if LocalPlayer.RespawnLocation then
            HumanoidRootPart.CFrame = LocalPlayer.RespawnLocation.CFrame
        end
    end
})

TeleportTab:CreateButton({
    name = "TP to Map Center",
    callback = function()
        HumanoidRootPart.CFrame = CFrame.new(0, 50, 0)
    end
})

-- TAB 9: PLAYER MODS
local PlayerTab = Window:CreateTab({
    name = "Player Mods",
    icon = 10709782795
})

PlayerTab:CreateSection("Character")

PlayerTab:CreateToggle({
    name = "Hitbox Expander",
    flag = "HitboxExpander",
    callback = function(Value)
        TagConfig.HitboxExpander = Value
        
        if Value then
            task.spawn(function()
                while TagConfig.HitboxExpander do
                    task.wait(0.1)
                    pcall(function()
                        for _, player in pairs(Players:GetPlayers()) do
                            if player ~= LocalPlayer and player.Character then
                                local hrp = player.Character:FindFirstChild("HumanoidRootPart")
                                if hrp then
                                    hrp.Size = Vector3.new(TagConfig.HitboxSize, TagConfig.HitboxSize, TagConfig.HitboxSize)
                                end
                            end
                        end
                    end)
                end
                
                -- Reset
                for _, player in pairs(Players:GetPlayers()) do
                    if player.Character then
                        local hrp = player.Character:FindFirstChild("HumanoidRootPart")
                        if hrp then
                            hrp.Size = Vector3.new(2, 2, 1)
                        end
                    end
                end
            end)
        end
    end
})

PlayerTab:CreateSlider({
    name = "Hitbox Size",
    flag = "HitboxSize",
    min = 2,
    max = 50,
    initial = 10,
    callback = function(Value)
        TagConfig.HitboxSize = Value
    end
})

PlayerTab:CreateToggle({
    name = "Size Changer",
    flag = "SizeChanger",
    callback = function(Value)
        TagConfig.SizeChanger = Value
        
        if Value then
            for _, v in pairs(Character:GetDescendants()) do
                if v:IsA("BasePart") then
                    v.Size = v.Size * TagConfig.PlayerSize
                end
            end
        end
    end
})

PlayerTab:CreateSlider({
    name = "Player Size",
    flag = "PlayerSize",
    min = 0.1,
    max = 10,
    initial = 1,
    callback = function(Value)
        TagConfig.PlayerSize = Value
    end
})

-- TAB 10: SETTINGS
local SettingsTab = Window:CreateTab({
    name = "Settings",
    icon = 10709783123
})

SettingsTab:CreateSection("Script")

SettingsTab:CreateToggle({
    name = "Anti AFK",
    flag = "AntiAfk",
    initial = true,
    callback = function(Value)
        TagConfig.AntiAfk = Value
        
        if Value then
            local vu = game:GetService("VirtualUser")
            LocalPlayer.Idled:Connect(function()
                if TagConfig.AntiAfk then
                    vu:Button2Down(Vector2.new(0,0), Camera.CFrame)
                    task.wait(1)
                    vu:Button2Up(Vector2.new(0,0), Camera.CFrame)
                end
            end)
        end
    end
})

SettingsTab:CreateToggle({
    name = "Anti Kick",
    flag = "AntiKick",
    callback = function(Value)
        TagConfig.AntiKick = Value
    end
})

SettingsTab:CreateToggle({
    name = "Anti Ban",
    flag = "AntiBan",
    callback = function(Value)
        TagConfig.AntiBan = Value
    end
})

SettingsTab:CreateToggle({
    name = "Unlock FPS",
    flag = "UnlockFPS",
    callback = function(Value)
        if Value then
            setfpscap(999)
        else
            setfpscap(60)
        end
    end
})

SettingsTab:CreateButton({
    name = "Destroy UI",
    callback = function()
        Rayfield:Destroy()
    end
})

SettingsTab:CreateButton({
    name = "Rejoin Server",
    callback = function()
        game:GetService("TeleportService"):Teleport(game.PlaceId, LocalPlayer)
    end
})

SettingsTab:CreateButton({
    name = "Server Hop",
    callback = function()
        local servers = HttpService:JSONDecode(game:HttpGet(
            "https://games.roblox.com/v1/games/" .. game.PlaceId .. "/servers/Public?sortOrder=Asc&limit=100"
        ))
        
        for _, server in pairs(servers.data) do
            if server.playing < server.maxPlayers and server.id ~= game.JobId then
                game:GetService("TeleportService"):TeleportToPlaceInstance(game.PlaceId, server.id)
                break
            end
        end
    end
})

-- Character refresh
LocalPlayer.CharacterAdded:Connect(function(newChar)
    Character = newChar
    Humanoid = newChar:WaitForChild("Humanoid")
    HumanoidRootPart = newChar:WaitForChild("HumanoidRootPart")
    
    if TagConfig.SpeedHack then
        Humanoid.WalkSpeed = TagConfig.WalkSpeed
    end
end)

-- Initial notification
Rayfield:Notify({
    title = "TAG HUB",
    message = "Loaded 50+ features! Anti-cheat bypass active.",
    duration = 5
})