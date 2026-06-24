local EncodingService = game:GetService("EncodingService")

local b = buffer.create(6)
buffer.writestring(b, 0, "UNIXAT")

local compressed = EncodingService:CompressBuffer(b, Enum.CompressionAlgorithm.Zstd, 22)
local decompressed = EncodingService:DecompressBuffer(compressed, Enum.CompressionAlgorithm.Zstd)

if buffer.readstring(decompressed, 0, 6) ~= "UNIXAT" then
    error("attempt to call a nil value")
end

if not game:IsLoaded() then
    game.Loaded:Wait()
end

-- This is based on your pings so the finding fuel function doesn't break (adjust it to your liking)
task.wait(3)

-- SERVICES --

--[[
local Workspace = game:GetService("Workspace")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
]]
 
-- --- CONFIGURATION & REFERENCES ---
--[[
local LocalPlayer = Players.LocalPlayer
local character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
]]


local Workspace = game:GetService("Workspace")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

 
-- --- CONFIGURATION & REFERENCES ---

local LocalPlayer = Players.LocalPlayer
local character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
local MapFolder = Workspace:WaitForChild("Map")
local DroppedItemsFolder = Workspace:WaitForChild("DroppedItems")
local AdjustBackpackRemote = ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("Tools"):WaitForChild("AdjustBackpack")
local PlayAgainRemote = ReplicatedStorage.Remotes.Misc:FindFirstChild("VotePlayAgain")
local humanoidRootPart = character:WaitForChild("HumanoidRootPart")
local humanoid = character:WaitForChild("Humanoid")
 
local Generator = nil
local chosenBox = nil

local success = nil

local Vector3_zero = Vector3.new(0, 0, 0)
local crawlRaycastParams = RaycastParams.new()
crawlRaycastParams.FilterType = Enum.RaycastFilterType.Exclude
crawlRaycastParams.RespectCanCollide = false
crawlRaycastParams.CollisionGroup = "Default"

local function Log(message, linebreaker)
    task.spawn(function()
        while not LogToTerminal do task.wait(0.05) end
        LogToTerminal(message, linebreaker)
    end)
end
 
-- --- Safety First Lads You gotta be the sneakiest to be the ultimate gem grinder ---
local function evacuateServer(reason)
    Log("EVACUATION SWITCH ACTIVATED! " .. reason, "[SECURITY] : ")
    task.spawn(function()
      pcall(function() PlayAgainRemote:FireServer() end)
      Log("ESCAPING BY PLAYING AGAIN!", "[SECURITY] : ")
      task.wait(1.0) -- Waiting for the remote to work
 
      -- 2. Forceful escape by getting kicked if the remote is slow as heck
      LocalPlayer:Kick("[WARNING] " .. reason)
    end)
 
	-- Stops the script immediately
    error("Script Termination")
end

-- Background functions that will run silently ---
local function SpawnPlatform()    
    local platform = Instance.new("Part")
    platform.Name = "UndergroundFarmFloor"
    platform.Size = Vector3.new(1300, 1, 1300) 
    platform.Transparency = 1
    platform.Anchored = true
    platform.CanCollide = true
    platform.Position = Vector3.new(humanoidRootPart.Position.X, humanoidRootPart.Position.Y - 13, humanoidRootPart.Position.Z)
    platform.Parent = Workspace
end

local function Noclip()
    RunService.Stepped:Connect(function()
        if not character or not character.Parent then return end
        
        local descendants = character:GetDescendants()
        for i = 1, #descendants do
            local child = descendants[i]
            if child:IsA("BasePart") and child.CanCollide then
                if child.Name ~= "UndergroundFarmFloor" then
                    child.CanCollide = false
                end
            end
        end
        
        if humanoidRootPart then
            humanoidRootPart.AssemblyLinearVelocity = Vector3_zero
        end
    end)
end

local function FindPowerBox()
  local BoxData = {}
  local tiles = MapFolder:WaitForChild("Tiles"):GetChildren()
  local shortdist = math.huge
  local BoxXZ = {0,0}
  local currPos = humanoidRootPart.Position

  for _, child in ipairs(tiles) do
    if child.Name == "Power Plant" then
      local powerBox = child:FindFirstChild("Power Box")
      if powerBox then
        local boxPos = powerBox:GetPivot().Position
        local dist = (currPos - boxPos).Magnitude

        if dist < shortdist then
          shortdist = dist
          chosenBox = powerBox
          BoxXZ[1], BoxXZ[2] = boxPos.X, boxPos.Z
        end
      end
    end
  end
  return BoxXZ
end
 
local function getGeneratorPosition()
  local structures = Workspace:WaitForChild("Structures", 5)
  local generator = structures and structures:WaitForChild("Generator", 5)
  Generator = generator:GetPivot().Position
end

local excludeFuel = {}

local function FindShortPath()
  -- First, find all suitable fuels to add nodes to the network
  local playerPos = humanoidRootPart.Position
  local FuelVertices = {}
  local children = DroppedItemsFolder:GetChildren()

  for _, item in ipairs(children) do
    if item.Name == "Fuel" and not excludeFuel[item] then
      local fuelPos = item:GetPivot().Position
      local height = fuelPos.Y - playerPos.Y

      if height > 0 and height <= 10 then
        table.insert(FuelVertices, {Instance = item, Coord = {fuelPos.X, fuelPos.Z}})
      else
        excludeFuel[item] = true
      end
    end
  end

  -- Find the shortest path from start to two fuel to power box
  local TwoNodes = {nil, nil}
  local shortdist = math.huge
  local BoxCoord = FindPowerBox()

  local snodeX, snodeZ = playerPos.X, playerPos.Z
  local enodeX, enodeZ = BoxCoord[1], BoxCoord[2]
  for i = 1, #FuelVertices do
    local fuel1 = FuelVertices[i]
    local fuel1X, fuel1Z = fuel1.Coord[1], fuel1.Coord[2]

    for j = i+1, #FuelVertices do
      local fuel2 = FuelVertices[j]
      local fuel2X, fuel2Z = fuel2.Coord[1], fuel2.Coord[2]
      -- Find distance between two fuels
      local TwoNodeDist = math.sqrt((fuel1X - fuel2X)^2 + (fuel1Z - fuel2Z)^2)
      -- Choice 1: You -> Fuel 1 -> Fuel 2 -> Power Box
      local dist1 = math.sqrt((snodeX - fuel1X)^2 + (snodeZ - fuel1Z)^2) + TwoNodeDist + math.sqrt((enodeX - fuel2X)^2 + (enodeZ - fuel2Z)^2)
      -- Choice 2: You -> Fuel 2 -> Fuel 1 -> Power Box
      local dist2 = math.sqrt((snodeX - fuel2X)^2 + (snodeZ - fuel2Z)^2) + TwoNodeDist + math.sqrt((enodeX - fuel1X)^2 + (enodeZ - fuel1Z)^2)

      if dist1 < dist2 then
        if dist1 < shortdist then
          shortdist = dist1
          TwoNodes[1] = fuel1.Instance
          TwoNodes[2] = fuel2.Instance
        end
      elseif dist2 < shortdist then
        shortdist = dist2
        TwoNodes[1] = fuel2.Instance
        TwoNodes[2] = fuel1.Instance
      end
    end
  end
  return TwoNodes
end

-- The more overpowered version, it can literally teleport fuel to the generator (People gonna skid this thing hard trust me)
local function FuelTeleport(targetFuel) 
    local fuelUnion = targetFuel:FindFirstChild("Union") or targetFuel.PrimaryPart
    local itemDrag = targetFuel:FindFirstChild("ItemDrag")
    local networkRemote = itemDrag and itemDrag:FindFirstChild("RequestNetworkOwnership")
 
    if fuelUnion and networkRemote then
        -- Hippity Hoppity the fuel is now my property
        pcall(function()
            networkRemote:FireServer(fuelUnion)
        end)
        -- small delay so it doesn't blow up
        task.wait(0.1) 
        pcall(function()
            targetFuel:PivotTo(CFrame.new(Generator) + Vector3.new(0, 1, 0))
        end)

        task.wait(0.15) 
    end
end

local RunService = game:GetService("RunService")

local function GoTo(targetPos)
    local lockedYHeight = humanoidRootPart.Position.Y
    local finalTarget = Vector3.new(targetPos.X, lockedYHeight, targetPos.Z)
    local lastWallDetectedTime = 0
    local farmFloor = Workspace:FindFirstChild("UndergroundFarmFloor")
    
    crawlRaycastParams.FilterDescendantsInstances = {character, farmFloor}

    while true do
        local currentPos = humanoidRootPart.Position
        local remainingVector = finalTarget - currentPos
        local totalDistance = math.sqrt(remainingVector.X^2 + remainingVector.Z^2)
        
        -- Arrival check
        if totalDistance <= 2 then
            humanoidRootPart.CFrame = CFrame.new(finalTarget)
            humanoidRootPart.AssemblyLinearVelocity = Vector3_zero
            humanoidRootPart.AssemblyAngularVelocity = Vector3_zero
            humanoidRootPart.Anchored = true
            task.wait(0.05)
            humanoidRootPart.Anchored = false 
            break
        end
        
        local direction = remainingVector.Unit
        
        -- Wall prediction raycast (6 studs ahead)
        local rayResult = Workspace:Raycast(currentPos, direction * 6, crawlRaycastParams)
        if rayResult and rayResult.Instance then
            local parentModel = rayResult.Instance:FindFirstAncestorOfClass("Model")
            if parentModel or (rayResult.Instance:IsA("BasePart") and rayResult.Instance.Size.Magnitude > 3) then
                lastWallDetectedTime = os.clock()
            end
        end
        
        -- Determine physical speed (studs per second)
        local currentAllowedSpeed = 10
        if os.clock() - lastWallDetectedTime >= 0.5 then
            currentAllowedSpeed = 30
        end
        
        -- Yield for exactly one frame and get the precise elapsed time (dt)
        local dt = RunService.Heartbeat:Wait()
        
        -- Calculate exact distance to travel this frame
        local activeStepDistance = currentAllowedSpeed * dt
        if activeStepDistance > totalDistance then 
            activeStepDistance = totalDistance 
        end
        
        -- Apply the frame-rate-independent movement
        local nextPosition = currentPos + (direction * activeStepDistance)
        humanoidRootPart.CFrame = CFrame.new(nextPosition.X, lockedYHeight, nextPosition.Z)
        humanoidRootPart.AssemblyLinearVelocity = Vector3_zero
        humanoidRootPart.AssemblyAngularVelocity = Vector3_zero
    end
end

local function GoDown()
    if not humanoidRootPart or not humanoidRootPart.Parent then return end

    local currentPos = humanoidRootPart.Position
    local targetY = currentPos.Y - 9
    local lockedX = currentPos.X
    local lockedZ = currentPos.Z

    while true do
        if not humanoidRootPart or not humanoidRootPart.Parent then break end
        
        local loopPos = humanoidRootPart.Position
        local remainingDistance = loopPos.Y - targetY

        if remainingDistance <= 0.25 or remainingDistance <= 0.1 then
            humanoidRootPart.CFrame = CFrame.new(lockedX, targetY, lockedZ)
            humanoidRootPart.AssemblyLinearVelocity = Vector3.new(0, -5, 0)
            humanoidRootPart.AssemblyAngularVelocity = Vector3.new(0, 0, 0)
            humanoidRootPart.Anchored = true
            task.wait(0.05)
            humanoidRootPart.Anchored = false
            break
        end

        local nextY = loopPos.Y - 0.15
        humanoidRootPart.CFrame = CFrame.new(lockedX, nextY, lockedZ)
        task.wait(0.025)
    end
end

-- --- PIPELINE EXECUTION ENGINE ---
local function Main()
    Log("===================================================================", "")
    Log("This is the V2 of the original gem farm script", "[NOTICE] : ")
    Log("===================================================================", "")

    task.wait(0.3)
    humanoid:ChangeState(Enum.HumanoidStateType.Physics)
    GoDown()
    humanoid:ChangeState(Enum.HumanoidStateType.Running)

    Log("Waiting for fuels to load", "[MAIN] : ")
    while true do
      local children = DroppedItemsFolder:GetChildren()
      local count = 0
      local FuelLoaded = 0
      for _, child in ipairs(children) do
        if child.Name == "Fuel" then FuelLoaded = FuelLoaded + 1 end
      end
      if FuelLoaded >= 5 then break end
      task.wait(0.2)
    end
    task.wait(1)

    Log("Starting the Farm", "[MAIN] : ")
    Log("===================================================================", "")
    local StartTime = os.clock()
    getGeneratorPosition()
    local TwoFuels = FindShortPath()
    local fuel1 = TwoFuels[1]
    local fuel2 = TwoFuels[2]

    -- Go to first fuel
    Log("Going to the first fuel", "[MAIN] : ")
    GoTo(fuel1:GetPivot().Position)
    task.wait(0.2)
    FuelTeleport(fuel1)
    print()
    Log(string.format("Going to Fuel 1 completion: %.2f seconds", os.clock() - StartTime), "[MAIN] : ")
    Log("===================================================================", "")
    task.wait(0.1)

    Log("Going to the second fuel", "[MAIN] : ")
    GoTo(fuel2:GetPivot().Position)
    task.wait(0.2)
    FuelTeleport(fuel2)
    Log(string.format("Going to Fuel 2 completion: %.2f seconds", os.clock() - StartTime), "[MAIN] : ")
    Log("===================================================================", "")
    task.wait(0.1)

    Log("Going to the Power Plant", "[MAIN] : ")
    GoTo(chosenBox:GetPivot().Position)
    Log(string.format("Going to Fuel 2 completion: %.2f seconds", os.clock() - StartTime), "[MAIN] : ")
    Log("===================================================================", "")

    local Prompt = chosenBox:WaitForChild("Prompt")
    local SparkObject = chosenBox:WaitForChild("Door"):WaitForChild("Doorpart1"):WaitForChild("Sparks")
    if fireproximityprompt then
      while true do
        local SparkActive = SparkObject.Enabled
        fireproximityprompt(Prompt)
        if not SparkActive then break end
        task.wait(0.1)
      end
    else Log("The fireproximityprompt is unsupported on your executor, RIP", "[SYSTEM] : ")
    end
    Log("Power Box has been fixed", "[MAIN] : ")
    Log("===================================================================", "")

    local FinishTime = os.clock() - StartTime
    Log(string.format("🏆 TOTAL RUN TIME SUMMARY: %.2f seconds", FinishTime), "[MAIN] : ")
    task.wait(0.1)
    Log("Run finished, starting a new run", "[SYSTEM] : ")
    pcall(function() PlayAgainRemote:FireServer() end)
end

SpawnPlatform()
Noclip()

-- Mod joined? RUUNNN
if #Players:GetPlayers() > 1 then
    evacuateServer("Pre-existing player DETECTED!")
end
-- Hire a security man for any sussy people
Players.PlayerAdded:Connect(function(newPlayer)
    if newPlayer ~= LocalPlayer then
        evacuateServer("Player (" .. newPlayer.Name .. ") entering the server DETECTED!")
    end
end)

-- If a run somehow fails (either finding fuel function broke or smth), it will do a fresh new run
task.spawn(function()
    task.wait(40.0) -- Timeout limit
 
    if PlayAgainRemote then
        Log("The run is taking too long, restarting the run", "[ANOMALY] : ")
        local error = nil
        success, error = pcall(function() PlayAgainRemote:FireServer() end)
    end
end)

-- If PlayAgain remote SOMEHOW broke, just teleport to lobby
task.spawn(function()
  task.wait(45.0) -- Timeout limit

  local LobbyID = 90148635862803 
  local TeleportService = game:GetService("TeleportService")
  Log("Failed to initiate (Play Again), returning to lobby", "[ANOMALY] : ")
  pcall(function() TeleportService:Teleport(LobbyID, LocalPlayer) end)
end)
 
-- If you somehow died, it will do a fresh new run
LocalPlayer.Character:GetAttributeChangedSignal("Dead"):Connect(function()
  Log("You died, restarting the run", "[ANOMALY] : ")
  pcall(function() PlayAgainRemote:FireServer() end)
end)
 
Main()
