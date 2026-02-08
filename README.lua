getgenv().HitboxExpanderEnabled = true
getgenv().TeamCheck = true
getgenv().HitboxSize = 10

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer

local ActiveCharacters = {}

local function Setup(character)
    if not character then return end

    local hrp = character:WaitForChild("HumanoidRootPart", 5)
    if not hrp then return end

    hrp.Size = Vector3.new(
        getgenv().HitboxSize,
        getgenv().HitboxSize,
        getgenv().HitboxSize
    )
    hrp.Transparency = 0.5
    hrp.Material = Enum.Material.Neon
    hrp.BrickColor = BrickColor.new("Really red")
    hrp.CanCollide = false

    ActiveCharacters[character] = hrp
end

local function Cleanup(character)
    ActiveCharacters[character] = nil
end

local function MonitorHRP(character)
    character.DescendantAdded:Connect(function(desc)
        if desc:IsA("BasePart") and desc.Name == "HumanoidRootPart" then
            task.wait()
            Setup(character)
        end
    end)
end

local function ExpandHitbox(player)
    if player == LocalPlayer then return end
    if getgenv().TeamCheck and player.Team == LocalPlayer.Team then return end

    if player.Character then
        Setup(player.Character)
        MonitorHRP(player.Character)
    end

    player.CharacterAdded:Connect(function(char)
        Setup(char)
        MonitorHRP(char)
    end)

    player.CharacterRemoving:Connect(Cleanup)
end

local function ApplyToAll()
    for _, player in ipairs(Players:GetPlayers()) do
        ExpandHitbox(player)
    end

    Players.PlayerAdded:Connect(ExpandHitbox)
end

local HeartbeatConnection

if getgenv().HitboxExpanderEnabled then
    pcall(function()
        setsimulationradius(math.huge, math.huge)
    end)

    ApplyToAll()

    HeartbeatConnection = RunService.Heartbeat:Connect(function()
        for character, hrp in pairs(ActiveCharacters) do
            if hrp and hrp.Parent and hrp:IsA("BasePart") then
                hrp.Size = Vector3.new(
                    getgenv().HitboxSize,
                    getgenv().HitboxSize,
                    getgenv().HitboxSize
                )
            end
        end
    end)
end
