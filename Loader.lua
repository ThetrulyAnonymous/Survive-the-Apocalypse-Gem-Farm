-- ===================================================================
-- --- PRIVATE ENGINE SERVICES (SCOPED LOCALLY FOR STEALTH) ---
-- ===================================================================
-- Keeping these local ensures they leave ZERO footprints in getgenv()
local Workspace         = game:GetService("Workspace")
local RunService        = game:GetService("RunService")
local Players           = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local CoreGui           = game:GetService("CoreGui")
local HttpService       = game:GetService("HttpService")

-- ===================================================================
-- --- GLOBAL DEPENDENCY PIPELINES (FOR UI & FARM CODE) ---
-- ===================================================================
-- PLAYER ARCHITECTURE LIFECYCLE
local lp = Players.LocalPlayer or Players.PlayerAdded:Wait()
if not lp then
    while not Players.LocalPlayer do task.wait() end
    lp = Players.LocalPlayer
end
getgenv().LocalPlayer = lp

getgenv().character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
getgenv().humanoidRootPart = character:WaitForChild("HumanoidRootPart")
getgenv().humanoid = character:WaitForChild("Humanoid")

-- MAP FRAMEWORK REFERENCES
getgenv().MapFolder = Workspace:WaitForChild("Map")
getgenv().TilesFolder = MapFolder:WaitForChild("Tiles")
getgenv().DroppedItemsFolder = Workspace:WaitForChild("DroppedItems")

-- REPLICATED REMOTE SYSTEM GATES
getgenv().AdjustBackpackRemote = ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("Tools"):WaitForChild("AdjustBackpack")
getgenv().PlayAgainRemote = ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("Misc"):WaitForChild("VotePlayAgain")

-- STORAGE NAMES
getgenv().FILE_NAME = "PrevRunData.txt"
getgenv().CONFIG_FILE = "FarmConfig.txt"

-- ULTRA-STEALTH UI CONTAINER ROUTING
getgenv().TargetContainer = (gethui and gethui()) or (cloneref and cloneref(CoreGui)) or CoreGui

-- --- FILES INITIALIZATION ---
if isfile and writefile then
    if not isfile(FILE_NAME) then 
        writefile(FILE_NAME, "") 
    end
    if not isfile(CONFIG_FILE) then
        local defaultSettings = {HideNameActive = false, OptimisedFarmActive = false, KeySystem = false}
        writefile(CONFIG_FILE, HttpService:JSONEncode(defaultSettings))
    end
end

-- --- CONTEXT GARBAGE CLEANUP ENGINE ---
local existingUI = TargetContainer:FindFirstChild("ApocalypseControlPanel")
if existingUI then 
    existingUI:Destroy() 
end
