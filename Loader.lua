getgenv().Workspace = game:GetService("Workspace")
getgenv().RunService = game:GetService("RunService")
getgenv().Players = game:GetService("Players")
getgenv().ReplicatedStorage = game:GetService("ReplicatedStorage")
getgenv().CoreGui = game:GetService("CoreGui")
getgenv().HttpService = game:GetService("HttpService")

-- CONFIGURATION & REFERENCES
local lp = Players.LocalPlayer
if not lp then
    while not Players.LocalPlayer do task.wait() end
    lp = Players.LocalPlayer
end
getgenv().LocalPlayer = lp

getgenv().character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
getgenv().MapFolder = Workspace:WaitForChild("Map")
getgenv().TilesFolder = MapFolder:WaitForChild("Tiles")
getgenv().DroppedItemsFolder = Workspace:WaitForChild("DroppedItems")
getgenv().AdjustBackpackRemote = ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("Tools"):WaitForChild("AdjustBackpack")
getgenv().PlayAgainRemote = ReplicatedStorage.Remotes.Misc:FindFirstChild("VotePlayAgain")
getgenv().humanoidRootPart = character:WaitForChild("HumanoidRootPart")
getgenv().humanoid = character:WaitForChild("Humanoid")

-- ENVIRONMENT & FILES DATA
getgenv().FILE_NAME = "PrevRunData.txt"
getgenv().CONFIG_FILE = "FarmConfig.txt"
getgenv().TargetContainer = gethui and gethui() or (cloneref and cloneref(CoreGui) or CoreGui)

-- Files Setting up
if isfile and writefile then
    if not isfile(FILE_NAME) then writefile(FILE_NAME, "") end
    if not isfile(CONFIG_FILE) then
        local defaultSettings = {HideNameActive = false, OptimisedFarmActive = false, KeySystem = false}
        writefile(CONFIG_FILE, HttpService:JSONEncode(defaultSettings))
    end
end

-- Cleaning up Left-over GUI (Now safe because TargetContainer is initialized above!)
local existingUI = TargetContainer:FindFirstChild("ApocalypseControlPanel")
if existingUI then existingUI:Destroy() end
