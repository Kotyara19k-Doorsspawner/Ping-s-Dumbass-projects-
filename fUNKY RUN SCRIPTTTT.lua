local StaminaGui = Instance.new("ScreenGui")
local Bar = Instance.new("Frame")
local Fill = Instance.new("Frame")

StaminaGui.Name = "StaminaGui"
StaminaGui.Parent = game:GetService("CoreGui")
StaminaGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

Bar.Name = "Bar"
Bar.Parent = StaminaGui
Bar.AnchorPoint = Vector2.new(0.5, 0)
Bar.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
Bar.BorderSizePixel = 0
Bar.Position = UDim2.new(0.5, 0, 1, -120)
Bar.Size = UDim2.new(0, 400, 0, 20)

Fill.Name = "Fill"
Fill.Parent = Bar
Fill.AnchorPoint = Vector2.new(0.5, 0)
Fill.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
Fill.BorderSizePixel = 0
Fill.Position = UDim2.new(0.5, 0, 0, 1)
Fill.Size = UDim2.new(1, -2, 1, -2)

-- Services

local Players = game:GetService("Players")
local UIS = game:GetService("UserInputService")

-- Variables

local Plr = Players.LocalPlayer
local Char = Plr.Character or Plr.CharacterAdded:Wait()
local Hum = Char:WaitForChild("Humanoid")

local stamina, staminaMax = 100, 100
local sprintTime = 7
local cooldown = false

local ModuleScripts = {
    MainGame = require(Plr.PlayerGui.MainUI.Initiator.Main_Game),
}

-- Setup

local nIdx; nIdx = hookmetamethod(game, "__newindex", newcclosure(function(t, k, v)
    if k == "WalkSpeed" then
        if ModuleScripts.MainGame.chase then
            v = ModuleScripts.MainGame.crouching and 15 or 22
        elseif ModuleScripts.MainGame.crouching then
            v = 8
        else
            v = isSprinting and 20 or 12
        end
    end

    return nIdx(t, k, v)
end))

-- Scripts

sprintTime = math.max(sprintTime - 1, 1)

UIS.InputBegan:Connect(function(key, gameProcessed)
    if not gameProcessed and key.KeyCode == Enum.KeyCode.Q and not cooldown and not ModuleScripts.MainGame.crouching then
        -- Sprinting
        
        isSprinting = true
        Hum.WalkSpeed = 22

        while UIS:IsKeyDown(Enum.KeyCode.Q) and stamina > 0 do
            stamina = math.max(stamina - 1, 0)
            Fill.Size = UDim2.new(1 / staminaMax * stamina, -2, 1, -2)

            task.wait(sprintTime / 100)
        end

        -- Reset

        isSprinting = false
        Hum.WalkSpeed = 12

        if stamina == 0 then
            -- Cooldown

            cooldown = true

            for i = 1, staminaMax, 1 do
                stamina = i
                Fill.Size = UDim2.new(1 / staminaMax * i, -2, 1, -2)

                task.wait(sprintTime / 50)
            end

            cooldown = false
        else
            -- Refill

            while not UIS:IsKeyDown(Enum.KeyCode.Q) do
                stamina = math.min(stamina + 1, staminaMax)
                Fill.Size = UDim2.new(1 / staminaMax * stamina, -2, 1, -2)

                task.wait(sprintTime / 50)
            end
        end        
    end
end)

Hum.WalkSpeed = 12