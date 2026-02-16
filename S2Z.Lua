local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")
local LocalPlayer = Players.LocalPlayer
local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
local Humanoid = Character:WaitForChild("Humanoid")
local HumanoidRootPart = Character:WaitForChild("HumanoidRootPart")
local Camera = Workspace.CurrentCamera

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "S2Z"
ScreenGui.Parent = game:GetService("CoreGui")

local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 200, 0, 120)
MainFrame.Position = UDim2.new(0, 20, 0.5, -60)
MainFrame.BackgroundColor3 = Color3.fromRGB(10, 10, 10)
MainFrame.BorderSizePixel = 0
MainFrame.Parent = ScreenGui

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, 0, 0, 30)
Title.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
Title.Text = "S2Z v1"
Title.TextColor3 = Color3.fromRGB(0, 255, 200)
Title.Font = Enum.Font.GothamBlack
Title.TextSize = 20
Title.Parent = MainFrame

local FlyBtn = Instance.new("TextButton")
FlyBtn.Size = UDim2.new(0.9, 0, 0, 50)
FlyBtn.Position = UDim2.new(0.05, 0, 0, 35)
FlyBtn.BackgroundColor3 = Color3.fromRGB(0, 100, 100)
FlyBtn.Text = "Anti: OFF"
FlyBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
FlyBtn.Font = Enum.Font.GothamBlack
FlyBtn.TextSize = 16
FlyBtn.Parent = MainFrame

local StatusLabel = Instance.new("TextLabel")
StatusLabel.Size = UDim2.new(1, -20, 0, 25)
StatusLabel.Position = UDim2.new(0, 10, 0, 90)
StatusLabel.BackgroundTransparency = 1
StatusLabel.Text = "off: Normal"
StatusLabel.TextColor3 = Color3.fromRGB(150, 150, 150)
StatusLabel.Font = Enum.Font.GothamBold
StatusLabel.TextSize = 11
StatusLabel.Parent = MainFrame

local Dragging = false
local DragStart = nil
local StartPos = nil

Title.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        Dragging = true
        DragStart = input.Position
        StartPos = MainFrame.Position
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if Dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
        local Delta = input.Position - DragStart
        MainFrame.Position = UDim2.new(StartPos.X.Scale, StartPos.X.Offset + Delta.X, StartPos.Y.Scale, StartPos.Y.Offset + Delta.Y)
    end
end)

UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        Dragging = false
    end
end)

local FlyEnabled = false
local FlyConnection = nil

-- ИСПРАВЛЕНО: функция называется BuryLegs, не Start
local function BuryLegs()
    HumanoidRootPart.CFrame = HumanoidRootPart.CFrame - Vector3.new(0, 5, 0)
end

local function StartFly()
    BuryLegs() -- Теперь вызываем правильную функцию

    FlyConnection = RunService.Heartbeat:Connect(function()
        if not FlyEnabled then return end

        local speed = 50
        local moveDir = Vector3.zero

        if UserInputService:IsKeyDown(Enum.KeyCode.W) then
            moveDir = moveDir + Camera.CFrame.LookVector
        end
        if UserInputService:IsKeyDown(Enum.KeyCode.S) then
            moveDir = moveDir - Camera.CFrame.LookVector
        end
        if UserInputService:IsKeyDown(Enum.KeyCode.A) then
            moveDir = moveDir - Camera.CFrame.RightVector
        end
        if UserInputService:IsKeyDown(Enum.KeyCode.D) then
            moveDir = moveDir + Camera.CFrame.RightVector
        end
        if UserInputService:IsKeyDown(Enum.KeyCode.Space) then
            moveDir = moveDir + Vector3.new(0, 1, 0)
        end
        if UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) then
            moveDir = moveDir - Vector3.new(0, 1, 0)
        end

        if moveDir.Magnitude > 0 then
            HumanoidRootPart.Velocity = moveDir.Unit * speed
        else
            HumanoidRootPart.Velocity = Vector3.zero
        end

        Humanoid.PlatformStand = true
    end)
end

local function StopFly()
    if FlyConnection then
        FlyConnection:Disconnect()
        FlyConnection = nil
    end
    Humanoid.PlatformStand = false
end

FlyBtn.MouseButton1Click:Connect(function()
    FlyEnabled = not FlyEnabled

    if FlyEnabled then
        FlyBtn.BackgroundColor3 = Color3.fromRGB(0, 200, 100)
        FlyBtn.Text = "Anti: ON"
        StatusLabel.Text = "Legs: Underground"
        StatusLabel.TextColor3 = Color3.fromRGB(0, 255, 100)
        StartFly()
    else
        FlyBtn.BackgroundColor3 = Color3.fromRGB(0, 100, 100)
        FlyBtn.Text = "Anti: OFF"
        StatusLabel.Text = "Legs: Normal"
        StatusLabel.TextColor3 = Color3.fromRGB(150, 150, 150)
        StopFly()
    end
end)

LocalPlayer.CharacterAdded:Connect(function(char)
    Character = char
    Humanoid = char:WaitForChild("Humanoid")
    HumanoidRootPart = char:WaitForChild("HumanoidRootPart")

    if FlyEnabled then
        task.wait(0.1)
        StartFly()
    end
end)

UserInputService.InputBegan:Connect(function(input)
    if input.KeyCode == Enum.KeyCode.RightShift then
        MainFrame.Visible = not MainFrame.Visible
    end
end)

print("S2Z v1 Loaded")
print("RightShift - Toggle UI")
FlyBtn.Font = Enum.Font.GothamBlack
FlyBtn.TextSize = 16
FlyBtn.Parent = MainFrame

local StatusLabel = Instance.new("TextLabel")
StatusLabel.Size = UDim2.new(1, -20, 0, 25)
StatusLabel.Position = UDim2.new(0, 10, 0, 90)
StatusLabel.BackgroundTransparency = 1
StatusLabel.Text = "off: Normal"
StatusLabel.TextColor3 = Color3.fromRGB(150, 150, 150)
StatusLabel.Font = Enum.Font.GothamBold
StatusLabel.TextSize = 11
StatusLabel.Parent = MainFrame

local Dragging = false
local DragStart = nil
local StartPos = nil

Title.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        Dragging = true
        DragStart = input.Position
        StartPos = MainFrame.Position
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if Dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
        local Delta = input.Position - DragStart
        MainFrame.Position = UDim2.new(StartPos.X.Scale, StartPos.X.Offset + Delta.X, StartPos.Y.Scale, StartPos.Y.Offset + Delta.Y)
    end
end)

UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        Dragging = false
    end
end)

local FlyEnabled = false
local FlyConnection = nil

local function Start()
    HumanoidRootPart.CFrame = HumanoidRootPart.CFrame - Vector3.new(0, 5, 0)
end

local function StartFly()
    BuryLegs()
    
    FlyConnection = RunService.Heartbeat:Connect(function()
        if not FlyEnabled then return end
        
        local speed = 50
        local moveDir = Vector3.zero
        
        if UserInputService:IsKeyDown(Enum.KeyCode.W) then
            moveDir = moveDir + Camera.CFrame.LookVector
        end
        if UserInputService:IsKeyDown(Enum.KeyCode.S) then
            moveDir = moveDir - Camera.CFrame.LookVector
        end
        if UserInputService:IsKeyDown(Enum.KeyCode.A) then
            moveDir = moveDir - Camera.CFrame.RightVector
        end
        if UserInputService:IsKeyDown(Enum.KeyCode.D) then
            moveDir = moveDir + Camera.CFrame.RightVector
        end
        if UserInputService:IsKeyDown(Enum.KeyCode.Space) then
            moveDir = moveDir + Vector3.new(0, 1, 0)
        end
        if UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) then
            moveDir = moveDir - Vector3.new(0, 1, 0)
        end
        
        if moveDir.Magnitude > 0 then
            HumanoidRootPart.Velocity = moveDir.Unit * speed
        else
            HumanoidRootPart.Velocity = Vector3.zero
        end
        
        Humanoid.PlatformStand = true
    end)
end

local function StopFly()
    if FlyConnection then
        FlyConnection:Disconnect()
        FlyConnection = nil
    end
    Humanoid.PlatformStand = false
end

FlyBtn.MouseButton1Click:Connect(function()
    FlyEnabled = not FlyEnabled
    
    if FlyEnabled then
        FlyBtn.BackgroundColor3 = Color3.fromRGB(0, 200, 100)
        FlyBtn.Text = "Anti: ON"
        StatusLabel.Text = "Legs: Underground"
        StatusLabel.TextColor3 = Color3.fromRGB(0, 255, 100)
        StartFly()
    else
        FlyBtn.BackgroundColor3 = Color3.fromRGB(0, 100, 100)
        FlyBtn.Text = "Anti: OFF"
        StatusLabel.Text = "Legs: Normal"
        StatusLabel.TextColor3 = Color3.fromRGB(150, 150, 150)
        StopFly()
    end
end)

LocalPlayer.CharacterAdded:Connect(function(char)
    Character = char
    Humanoid = char:WaitForChild("Humanoid")
    HumanoidRootPart = char:WaitForChild("HumanoidRootPart")
    
    if FlyEnabled then
        task.wait(0.1)
        StartFly()
    end
end)

UserInputService.InputBegan:Connect(function(input)
    if input.KeyCode == Enum.KeyCode.RightShift then
        MainFrame.Visible = not MainFrame.Visible
    end
end)

print("S2Z v1 Loaded")
print("RightShift - Toggle UI")
