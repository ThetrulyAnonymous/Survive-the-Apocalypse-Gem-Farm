-- GAME SERVICES
local Workspace = game:GetService("Workspace")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local CoreGui = game:GetService("CoreGui")
local HttpService = game:GetService("HttpService")
local HttpService = game:GetService("HttpService")

 
-- CONFIGURATION & REFERENCES

local LocalPlayer = Players.LocalPlayer or Players:GetPropertyChangedSignal("LocalPlayer"):Wait()
local character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
local MapFolder = Workspace:WaitForChild("Map")
local TilesFolder = MapFolder:WaitForChild("Tiles")
local DroppedItemsFolder = Workspace:WaitForChild("DroppedItems")
local AdjustBackpackRemote = ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("Tools"):WaitForChild("AdjustBackpack")
local PlayAgainRemote = ReplicatedStorage.Remotes.Misc:FindFirstChild("VotePlayAgain")
local humanoidRootPart = character:WaitForChild("HumanoidRootPart")
local humanoid = character:WaitForChild("Humanoid")

-- GAME DATA
local Generator = nil
local chosenBox = nil
local success = nil
local Vector3_zero = Vector3.new(0, 0, 0)
local crawlRaycastParams = RaycastParams.new()
crawlRaycastParams.FilterType = Enum.RaycastFilterType.Exclude
crawlRaycastParams.RespectCanCollide = false
crawlRaycastParams.CollisionGroup = "Default"


-- Files Setting up
local FILE_NAME = "PrevRunData.txt"
local CONFIG_FILE = "FarmConfig.txt"

if not isfile(FILE_NAME) then writefile(FILE_NAME, "") end

if not isfile(CONFIG_FILE) then
    local defaultSettings = {HideNameActive = false, OptimisedFarmActive = false, KeySystem = false}
    writefile(CONFIG_FILE, HttpService:JSONEncode(defaultSettings))
end

-- Cleaning up Left-over GUI
local TargetContainer = gethui and gethui() or (cloneref and cloneref(CoreGui) or CoreGui)
local existingUI = TargetContainer:FindFirstChild("ApocalypseControlPanel")
if existingUI then existingUI:Destroy() end
