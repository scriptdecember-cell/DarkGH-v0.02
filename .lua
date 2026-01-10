-- Escape Tsunami For Brainrots Script (ULTRA PROTECTION)
-- Load UI Library
local Library = loadstring(game:HttpGet("https://pastefy.app/XKsCQo5n/raw"))()

-- Services
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- Detect Platform
local IsMobile = UserInputService.TouchEnabled and not UserInputService.KeyboardEnabled

-- Player
local Player = Players.LocalPlayer
local Character = Player.Character or Player.CharacterAdded:Wait()
local Humanoid = Character:WaitForChild("Humanoid")
local HumanoidRootPart = Character:WaitForChild("HumanoidRootPart")

-- Update on respawn
Player.CharacterAdded:Connect(function(char)
    Character = char
    Humanoid = char:WaitForChild("Humanoid")
    HumanoidRootPart = char:WaitForChild("HumanoidRootPart")
end)

-- Settings
getgenv().TsunamiSettings = getgenv().TsunamiSettings or {
    -- Auto Upgrade
    AutoUpgradeSpeed = false,
    SpeedUpgradeAmount = 10,
    AutoUpgradeBrainrot = false,
    SelectedSlot = "Slot1",
    UpgradeAllSlots = false,
    
    -- Auto Features
    AutoRebirth = false,
    AutoCollectMoney = false,
    CollectAllSlots = true,
    
    -- Movement
    Speed = false,
    SpeedAmount = 100,
    InfiniteJump = false,
    NoClip = false,
    
    -- Misc
    RemoveWater = false,
    AntiTsunami = false,
}

local S = getgenv().TsunamiSettings

-- ============================================
-- AUTO UPGRADE SPEED
-- ============================================

local AutoUpgradeSpeedConnection

local function UpgradeSpeed()
    pcall(function()
        ReplicatedStorage.RemoteFunctions.UpgradeSpeed:InvokeServer(S.SpeedUpgradeAmount)
    end)
end

local function StartAutoUpgradeSpeed()
    if AutoUpgradeSpeedConnection then return end
    
    AutoUpgradeSpeedConnection = RunService.Heartbeat:Connect(function()
        if S.AutoUpgradeSpeed then
            UpgradeSpeed()
            task.wait(0.5)
        end
    end)
end

local function StopAutoUpgradeSpeed()
    if AutoUpgradeSpeedConnection then
        AutoUpgradeSpeedConnection:Disconnect()
        AutoUpgradeSpeedConnection = nil
    end
end

-- ============================================
-- AUTO UPGRADE BRAINROT
-- ============================================

local AutoUpgradeBrainrotConnection

local function UpgradeBrainrot()
    pcall(function()
        if S.UpgradeAllSlots then
            -- Upgrade all 30 slots
            for i = 1, 30 do
                ReplicatedStorage.RemoteFunctions.UpgradeBrainrot:InvokeServer("Slot" .. i)
            end
        else
            -- Upgrade selected slot only
            ReplicatedStorage.RemoteFunctions.UpgradeBrainrot:InvokeServer(S.SelectedSlot)
        end
    end)
end

local function StartAutoUpgradeBrainrot()
    if AutoUpgradeBrainrotConnection then return end
    
    AutoUpgradeBrainrotConnection = RunService.Heartbeat:Connect(function()
        if S.AutoUpgradeBrainrot then
            UpgradeBrainrot()
            task.wait(0.5)
        end
    end)
end

local function StopAutoUpgradeBrainrot()
    if AutoUpgradeBrainrotConnection then
        AutoUpgradeBrainrotConnection:Disconnect()
        AutoUpgradeBrainrotConnection = nil
    end
end

-- ============================================
-- AUTO REBIRTH
-- ============================================

local AutoRebirthConnection

local function DoRebirth()
    pcall(function()
        ReplicatedStorage.RemoteFunctions.Rebirth:InvokeServer()
    end)
end

local function StartAutoRebirth()
    if AutoRebirthConnection then return end
    
    AutoRebirthConnection = RunService.Heartbeat:Connect(function()
        if S.AutoRebirth then
            DoRebirth()
            task.wait(2)
        end
    end)
end

local function StopAutoRebirth()
    if AutoRebirthConnection then
        AutoRebirthConnection:Disconnect()
        AutoRebirthConnection = nil
    end
end

-- ============================================
-- AUTO COLLECT MONEY
-- ============================================

local AutoCollectMoneyConnection

local function CollectMoney()
    pcall(function()
        if S.CollectAllSlots then
            -- Collect from all 30 slots
            for i = 1, 30 do
                ReplicatedStorage.RemoteEvents.CollectMoney:FireServer("Slot" .. i)
            end
        else
            -- Collect from selected slot only
            ReplicatedStorage.RemoteEvents.CollectMoney:FireServer(S.SelectedSlot)
        end
    end)
end

local function StartAutoCollectMoney()
    if AutoCollectMoneyConnection then return end
    
    AutoCollectMoneyConnection = RunService.Heartbeat:Connect(function()
        if S.AutoCollectMoney then
            CollectMoney()
            task.wait(0.1)
        end
    end)
end

local function StopAutoCollectMoney()
    if AutoCollectMoneyConnection then
        AutoCollectMoneyConnection:Disconnect()
        AutoCollectMoneyConnection = nil
    end
end

-- ============================================
-- ANTI TSUNAMI (PROVEN METHODS)
-- ============================================

local AntiTsunamiConnection
local HealthConnection
local DiedConnection

local function StartAntiTsunami()
    if AntiTsunamiConnection then return end
    
    -- Method 1: Disable Death State (CRITICAL)
    if Humanoid then
        pcall(function()
            Humanoid.BreakJointsOnDeath = false
            Humanoid:SetStateEnabled(Enum.HumanoidStateType.Dead, false)
            Humanoid:SetStateEnabled(Enum.HumanoidStateType.Ragdoll, false)
        end)
    end
    
    -- Method 2: Health Monitor - Prevent reaching 0
    HealthConnection = Humanoid.HealthChanged:Connect(function(health)
        if S.AntiTsunami then
            if health <= 1 then
                Humanoid.Health = Humanoid.MaxHealth
            end
        end
    end)
    
    -- Method 3: Hook Died Event
    DiedConnection = Humanoid.Died:Connect(function()
        if S.AntiTsunami then
            -- Revive instantly
            task.wait(0.1)
            if Humanoid then
                Humanoid.Health = Humanoid.MaxHealth
            end
        end
    end)
    
    -- Method 4: Continuous Protection Loop
    AntiTsunamiConnection = RunService.Heartbeat:Connect(function()
        if not S.AntiTsunami then return end
        
        pcall(function()
            -- Keep health high
            if Humanoid and Humanoid.Health < Humanoid.MaxHealth * 0.9 then
                Humanoid.Health = Humanoid.MaxHealth
            end
            
            -- Remove hitbox (common damage detection)
            if Character then
                for _, v in pairs(Character:GetChildren()) do
                    if v.Name:lower() == "hitbox" then
                        v:Destroy()
                    end
                end
            end
            
            -- Destroy water parts that touch player
            for _, obj in pairs(Workspace:GetDescendants()) do
                if obj:IsA("BasePart") then
                    local name = obj.Name:lower()
                    if name:find("tsunami") or 
                       name:find("water") or 
                       name:find("wave") or
                       name:find("flood") or
                       name:find("kill") or
                       obj.Material == Enum.Material.Water then
                        
                        -- Make it harmless
                        obj.CanCollide = false
                        obj.CanTouch = false
                        obj.Transparency = 1
                    end
                end
            end
            
            -- Remove damage scripts from character
            if Character then
                for _, obj in pairs(Character:GetDescendants()) do
                    if obj:IsA("Script") or obj:IsA("LocalScript") then
                        if obj.Name:lower():find("damage") or 
                           obj.Name:lower():find("drown") or
                           obj.Name:lower():find("kill") then
                            obj:Destroy()
                        end
                    end
                end
            end
            
            -- Block damage remotes
            for _, remote in pairs(ReplicatedStorage:GetDescendants()) do
                if remote:IsA("RemoteEvent") then
                    if remote.Name:lower():find("damage") or 
                       remote.Name:lower():find("kill") or
                       remote.Name:lower():find("death") then
                        pcall(function()
                            remote:Destroy()
                        end)
                    end
                end
            end
        end)
    end)
end

local function StopAntiTsunami()
    if AntiTsunamiConnection then
        AntiTsunamiConnection:Disconnect()
        AntiTsunamiConnection = nil
    end
    
    if HealthConnection then
        HealthConnection:Disconnect()
        HealthConnection = nil
    end
    
    if DiedConnection then
        DiedConnection:Disconnect()
        DiedConnection = nil
    end
    
    -- Re-enable death
    if Humanoid then
        pcall(function()
            Humanoid.BreakJointsOnDeath = true
            Humanoid:SetStateEnabled(Enum.HumanoidStateType.Dead, true)
        end)
    end
end

-- ============================================
-- REMOVE WATER
-- ============================================

local function RemoveWater()
    for _, obj in pairs(Workspace:GetDescendants()) do
        if obj:IsA("BasePart") then
            if obj.Name:lower():find("water") or 
               obj.Name:lower():find("tsunami") or
               obj.Material == Enum.Material.Water then
                obj:Destroy()
            end
        end
    end
end

-- ============================================
-- SPEED
-- ============================================

local SpeedConnection

local function StartSpeed()
    if SpeedConnection then return end
    
    SpeedConnection = RunService.Heartbeat:Connect(function()
        if S.Speed and Humanoid then
            Humanoid.WalkSpeed = S.SpeedAmount
        end
    end)
end

local function StopSpeed()
    if SpeedConnection then
        SpeedConnection:Disconnect()
        SpeedConnection = nil
    end
    if Humanoid then
        Humanoid.WalkSpeed = 16
    end
end

-- ============================================
-- NO CLIP
-- ============================================

local NoClipConnection

local function StartNoClip()
    if NoClipConnection then return end
    
    NoClipConnection = RunService.Stepped:Connect(function()
        if S.NoClip then
            for _, v in pairs(Character:GetDescendants()) do
                if v:IsA("BasePart") and v.CanCollide then
                    v.CanCollide = false
                end
            end
        end
    end)
end

local function StopNoClip()
    if NoClipConnection then
        NoClipConnection:Disconnect()
        NoClipConnection = nil
    end
end

-- ============================================
-- INFINITE JUMP
-- ============================================

local InfiniteJumpConnection

local function StartInfiniteJump()
    if InfiniteJumpConnection then return end
    
    InfiniteJumpConnection = UserInputService.JumpRequest:Connect(function()
        if S.InfiniteJump and Humanoid then
            Humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
        end
    end)
end

local function StopInfiniteJump()
    if InfiniteJumpConnection then
        InfiniteJumpConnection:Disconnect()
        InfiniteJumpConnection = nil
    end
end

-- ============================================
-- CREATE UI
-- ============================================

local Window = Library:New({
    Name = "Escape Tsunami | " .. (IsMobile and "Mobile" or "PC")
})

-- Auto Upgrade Tab
local UpgradeTab = Window:Tab({
    Name = "Auto Upgrade",
    Icon = "⬆️"
})

UpgradeTab:Toggle({
    Name = "Auto Upgrade Speed",
    Default = false,
    Callback = function(value)
        S.AutoUpgradeSpeed = value
        if value then
            StartAutoUpgradeSpeed()
            Window:Notify({
                Title = "Auto Upgrade Speed",
                Message = "Started!",
                Duration = 2,
                Type = "success"
            })
        else
            StopAutoUpgradeSpeed()
        end
    end
})

UpgradeTab:Slider({
    Name = "Speed Upgrade Amount",
    Min = 1,
    Max = 100,
    Default = 10,
    Callback = function(value)
        S.SpeedUpgradeAmount = value
    end
})

UpgradeTab:Toggle({
    Name = "Auto Upgrade Brainrot",
    Default = false,
    Callback = function(value)
        S.AutoUpgradeBrainrot = value
        if value then
            StartAutoUpgradeBrainrot()
            Window:Notify({
                Title = "Auto Upgrade Brainrot",
                Message = "Started!",
                Duration = 2,
                Type = "success"
            })
        else
            StopAutoUpgradeBrainrot()
        end
    end
})

UpgradeTab:Toggle({
    Name = "Upgrade All Slots",
    Default = false,
    Callback = function(value)
        S.UpgradeAllSlots = value
        if value then
            Window:Notify({
                Title = "Upgrade Mode",
                Message = "Upgrading ALL 30 slots!",
                Duration = 3,
                Type = "success"
            })
        else
            Window:Notify({
                Title = "Upgrade Mode",
                Message = "Upgrading " .. S.SelectedSlot .. " only",
                Duration = 2,
                Type = "info"
            })
        end
    end
})

UpgradeTab:Input({
    Name = "Brainrot Slot",
    Placeholder = "Slot1",
    Callback = function(value)
        if value ~= "" then
            S.SelectedSlot = value
            Window:Notify({
                Title = "Slot Changed",
                Message = "Now using: " .. value,
                Duration = 2,
                Type = "info"
            })
        end
    end
})

UpgradeTab:Label({
    Text = "Available slots: Slot1 to Slot30"
})

UpgradeTab:Label({
    Text = "⚠️ Upgrade All Slots uses more money!"
})

-- Auto Features Tab
local AutoTab = Window:Tab({
    Name = "Auto Features",
    Icon = "🤖"
})

AutoTab:Toggle({
    Name = "Auto Rebirth",
    Default = false,
    Callback = function(value)
        S.AutoRebirth = value
        if value then
            StartAutoRebirth()
            Window:Notify({
                Title = "Auto Rebirth",
                Message = "Enabled!",
                Duration = 2,
                Type = "success"
            })
        else
            StopAutoRebirth()
        end
    end
})

AutoTab:Button({
    Name = "Rebirth Once",
    Callback = function()
        DoRebirth()
        Window:Notify({
            Title = "Rebirth",
            Message = "Rebirth triggered!",
            Duration = 2,
            Type = "success"
        })
    end
})

AutoTab:Toggle({
    Name = "Auto Collect Money",
    Default = false,
    Callback = function(value)
        S.AutoCollectMoney = value
        if value then
            StartAutoCollectMoney()
            Window:Notify({
                Title = "Auto Collect Money",
                Message = "Started collecting!",
                Duration = 2,
                Type = "success"
            })
        else
            StopAutoCollectMoney()
        end
    end
})

AutoTab:Toggle({
    Name = "Collect All Slots",
    Default = true,
    Callback = function(value)
        S.CollectAllSlots = value
        if value then
            Window:Notify({
                Title = "Collect Mode",
                Message = "Collecting from ALL slots",
                Duration = 2,
                Type = "info"
            })
        else
            Window:Notify({
                Title = "Collect Mode",
                Message = "Collecting from " .. S.SelectedSlot,
                Duration = 2,
                Type = "info"
            })
        end
    end
})

AutoTab:Label({
    Text = "Collects from all 30 slots for max profit!"
})

-- Movement Tab
local MovementTab = Window:Tab({
    Name = "Movement",
    Icon = "🏃"
})

MovementTab:Toggle({
    Name = "Speed",
    Default = false,
    Callback = function(value)
        S.Speed = value
        if value then
            StartSpeed()
        else
            StopSpeed()
        end
    end
})

MovementTab:Slider({
    Name = "Speed Amount",
    Min = 16,
    Max = 500,
    Default = 100,
    Callback = function(value)
        S.SpeedAmount = value
    end
})

MovementTab:Toggle({
    Name = "Infinite Jump",
    Default = false,
    Callback = function(value)
        S.InfiniteJump = value
        if value then
            StartInfiniteJump()
        else
            StopInfiniteJump()
        end
    end
})

MovementTab:Toggle({
    Name = "No Clip",
    Default = false,
    Callback = function(value)
        S.NoClip = value
        if value then
            StartNoClip()
        else
            StopNoClip()
        end
    end
})

-- Misc Tab
local MiscTab = Window:Tab({
    Name = "Misc",
    Icon = "🔧"
})

MiscTab:Toggle({
    Name = "🌊 Anti Tsunami (GOD MODE)",
    Default = false,
    Callback = function(value)
        S.AntiTsunami = value
        if value then
            StartAntiTsunami()
            Window:Notify({
                Title = "GOD MODE ACTIVE!",
                Message = "You are now IMMORTAL!",
                Duration = 3,
                Type = "success"
            })
        else
            StopAntiTsunami()
            Window:Notify({
                Title = "God Mode",
                Message = "Disabled",
                Duration = 2,
                Type = "info"
            })
        end
    end
})

MiscTab:Label({
    Text = "✅ Disables death state"
})

MiscTab:Label({
    Text = "✅ Prevents health from reaching 0"
})

MiscTab:Label({
    Text = "✅ Auto revive on death"
})

MiscTab:Label({
    Text = "✅ Removes damage hitboxes"
})

MiscTab:Label({
    Text = "✅ Makes water harmless"
})

MiscTab:Button({
    Name = "Remove All Water",
    Callback = function()
        RemoveWater()
        Window:Notify({
            Title = "Water Removed",
            Message = "All water deleted from workspace!",
            Duration = 2,
            Type = "success"
        })
    end
})

-- Info Tab
local InfoTab = Window:Tab({
    Name = "Info",
    Icon = "ℹ️"
})

InfoTab:Label({
    Text = "Escape Tsunami For Brainrots"
})

InfoTab:Label({
    Text = "Platform: " .. (IsMobile and "📱 Mobile" or "💻 PC")
})

InfoTab:Label({
    Text = "Version: 0.02"
})

InfoTab:Label({
    Text = " "
})

InfoTab:Label({
    Text = "✨ NEW GOD MODE SYSTEM ✨"
})

InfoTab:Label({
    Text = " "
})

InfoTab:Label({
    Text = "How to use:"
})

InfoTab:Label({
    Text = "1. Enable Anti Tsunami (IMMORTAL!)"
})

InfoTab:Label({
    Text = "2. Enable Auto Upgrade Speed"
})

InfoTab:Label({
    Text = "3. Enable Auto Upgrade Brainrot"
})

InfoTab:Label({
    Text = "4. Enable Upgrade All Slots"
})

InfoTab:Label({
    Text = "5. Enable Auto Collect Money"
})

InfoTab:Label({
    Text = "6. Enable Auto Rebirth"
})

InfoTab:Label({
    Text = " "
})

InfoTab:Label({
    Text = "🔥 Features:"
})

InfoTab:Label({
    Text = "• Death State DISABLED"
})

InfoTab:Label({
    Text = "• Health Auto-Heal"
})

InfoTab:Label({
    Text = "• Instant Revive System"
})

InfoTab:Label({
    Text = "• Damage Immunity"
})

InfoTab:Label({
    Text = "• Water Protection"
})

-- Load Notification
Window:Notify({
    Title = "Tsunami Escape",
    Message = "God Mode system loaded! Enable Anti Tsunami!",
    Duration = 4,
    Type = "success"
})

-- Auto-enable Anti Tsunami on respawn
Player.CharacterAdded:Connect(function()
    task.wait(2)
    if S.AntiTsunami then
        Stop
