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

-- Timing calibration adjustment
task.wait(3)

local Workspace = game:GetService("Workspace")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")

local MapFolder            = getgenv().MapFolder
local DroppedItemsFolder   = getgenv().DroppedItemsFolder
local PlayAgainRemote      = getgenv().PlayAgainRemote
local humanoidRootPart     = getgenv().humanoidRootPart
local humanoid             = getgenv().humanoid
local character            = getgenv().character
local LocalPlayer          = getgenv().LocalPlayer
local FILE_NAME			   = getgenv().FILE_NAME

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

local function WriteData(logString)
    local content = isfile(FILE_NAME) and readfile(FILE_NAME) or ""
    local lines = string.split(content, "\n")
    
    local activeLogs = {}
    for _, val in ipairs(lines) do
        if val ~= "" then table.insert(activeLogs, val) end
    end
    
    if #activeLogs >= 500 then
        table.remove(activeLogs, 1)
    end
    
    table.insert(activeLogs, logString)
    
    local savedString = table.concat(activeLogs, "\n") .. "\n"
    writefile(FILE_NAME, savedString)
end
 
-- --- Safety and Escape Protocols ---
local function evacuateServer(reason)
    Log("EVACUATION SWITCH ACTIVATED! " .. reason, "[SECURITY] : ")
    task.spawn(function()
        pcall(function() PlayAgainRemote:FireServer() end)
        Log("ESCAPING BY PLAYING AGAIN!", "[SECURITY] : ")
        task.wait(1.0)
 
        -- Fallback escape mechanism
        LocalPlayer:Kick("[WARNING] " .. reason)
    end)
 
    error("Script Termination")
end

-- --- Background Environments ---
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
    local structures = Workspace:WaitForChild("Structures")
    local generator = structures and structures:WaitForChild("Generator")
    if generator then
        Generator = generator:GetPivot().Position
    else
        -- Fallback default positional estimate to prevent crashing the line
        Generator = Vector3.new(0, 0, 0)
    end
end

local excludeFuel = {}

local function FindShortPath()
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
            
            local TwoNodeDist = math.sqrt((fuel1X - fuel2X)^2 + (fuel1Z - fuel2Z)^2)
            local dist1 = math.sqrt((snodeX - fuel1X)^2 + (snodeZ - fuel1Z)^2) + TwoNodeDist + math.sqrt((enodeX - fuel2X)^2 + (enodeZ - fuel2Z)^2)
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

local function FuelTeleport(targetFuel) 
    local fuelUnion = targetFuel:FindFirstChild("Union") or targetFuel.PrimaryPart
    local itemDrag = targetFuel:FindFirstChild("ItemDrag")
    local networkRemote = itemDrag and itemDrag:FindFirstChild("RequestNetworkOwnership")
 
    if fuelUnion and networkRemote then
        pcall(function()
            networkRemote:FireServer(fuelUnion)
        end)
        task.wait(0.1) 
        pcall(function()
            targetFuel:PivotTo(CFrame.new(Generator) + Vector3.new(0, 1, 0))
        end)
        task.wait(0.15) 
    end
end

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
        
        local rayResult = Workspace:Raycast(currentPos, direction * 6, crawlRaycastParams)
        if rayResult and rayResult.Instance then
            local parentModel = rayResult.Instance:FindFirstAncestorOfClass("Model")
            if parentModel or (rayResult.Instance:IsA("BasePart") and rayResult.Instance.Size.Magnitude > 3) then
                lastWallDetectedTime = os.clock()
            end
        end
        
        local currentAllowedSpeed = 10
        if os.clock() - lastWallDetectedTime >= 0.5 then
            currentAllowedSpeed = 30
        end
        
        local dt = RunService.Heartbeat:Wait()
        
        local activeStepDistance = currentAllowedSpeed * dt
        if activeStepDistance > totalDistance then 
            activeStepDistance = totalDistance 
        end
        
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

local function SafeWrite(logline) pcall(WriteData, logline) end

-- --- PIPELINE EXECUTION ENGINE ---
local function Main()
    Log("===================================================================", "")
    Log("This is the V2 of the original gem farm script", "[NOTICE] : ")
    Log("===================================================================", "")

    humanoid:ChangeState(Enum.HumanoidStateType.Physics)
    GoDown()
    humanoid:ChangeState(Enum.HumanoidStateType.Running)

    Log("Waiting for fuels to load", "[MAIN] : ")
    while true do
        local children = DroppedItemsFolder:GetChildren()
        local FuelLoaded = 0
        for _, child in ipairs(children) do
            if child.Name == "Fuel" then FuelLoaded = FuelLoaded + 1 end
        end
        if FuelLoaded >= 5 then break end
        task.wait(0.2)
    end
    task.wait(0.5)

    Log("Starting the Farm", "[MAIN] : ")
    Log("===================================================================", "")
    local StartTime = os.clock()
	local attempt = 1
	local TwoFuels, fuel1, fuel2

	while attempt <= 10 do
		getGeneratorPosition()
		TwoFuels = FindShortPath()
        fuel1 = TwoFuels[1]
        fuel2 = TwoFuels[2]
		
		if fuel1 and fuel2 and chosenBox then break end
		Log(string.format("Map items not ready (Attempt %d/%d). Retrying in 1.0s...", attempt, 10), "[ANOMALY] : ")
		task.wait(1.0)
		attempt = attempt + 1
	end
	if not fuel1 or not fuel2 or not chosenBox then
        Log("Assets failed to load (make sure to add task.wait(seconds) on top of loadstring), restarting the run", "[ANOMALY] : ")
		PlayAgainRemote:FireServer()
		return
    end

    -- Go to first fuel
    Log("Going to the first fuel", "[MAIN] : ")
    GoTo(fuel1:GetPivot().Position)
    task.wait(0.2)
    FuelTeleport(fuel1)
    Log(string.format("Going to Fuel 1 completion: %.2f seconds", os.clock() - StartTime), "[MAIN] : ")
    Log("===================================================================", "")
    task.wait(0.1)

    -- Go to second fuel
    Log("Going to the second fuel", "[MAIN] : ")
    GoTo(fuel2:GetPivot().Position)
    task.wait(0.2)
    FuelTeleport(fuel2)
    Log(string.format("Going to Fuel 2 completion: %.2f seconds", os.clock() - StartTime), "[MAIN] : ")
    Log("===================================================================", "")
    task.wait(0.1)

    -- Go to Power Box
    Log("Going to the Power Plant", "[MAIN] : ")
    GoTo(chosenBox:GetPivot().Position)
    -- FIXED: Fixed mismatched destination tracking strings in runtime splits
    Log(string.format("Arrived at Power Plant Box: %.2f seconds", os.clock() - StartTime), "[MAIN] : ")
    Log("===================================================================", "")

    local Prompt = chosenBox:WaitForChild("Prompt")
    local SparkObject = chosenBox:WaitForChild("Door"):WaitForChild("Doorpart1"):WaitForChild("Sparks")
    if fireproximityprompt then
        -- FIXED: Added a maximum iteration escape gate to safeguard against infinite prompt activation locks
        local checks = 0
        while checks < 50 do
            local SparkActive = SparkObject.Enabled
            fireproximityprompt(Prompt)
            if not SparkActive then break end
            task.wait(0.1)
            checks = checks + 1
        end
    else 
        Log("The fireproximityprompt is unsupported on your executor, RIP", "[SYSTEM] : ")
    end
    Log("Power Box has been fixed", "[MAIN] : ")
    Log("===================================================================", "")

    local FinishTime = os.clock() - StartTime
    Log(string.format("🏆 TOTAL RUN TIME SUMMARY: %.2f seconds", FinishTime), "[MAIN] : ")
	SafeWrite(string.format("[ RUN SUCCESSFUL ] : Completed in %.2f seconds", FinishTime))
    task.wait(0.1)
    Log("Run finished, starting a new run", "[SYSTEM] : ")
    pcall(function() PlayAgainRemote:FireServer() end)
end

SpawnPlatform()
Noclip()

if #Players:GetPlayers() > 1 then
	for _, ply in ipairs(Players:GetPlayers()) do
        if ply ~= LocalPlayer then SafeWrite("[ WARNING ] : Player " .. ply.Name .. " has entered the Server") end
    end
    evacuateServer("Pre-existing player DETECTED!")
end

Players.PlayerAdded:Connect(function(newPlayer)
    if newPlayer ~= LocalPlayer then
		SafeWrite("[ WARNING ] : Player " .. newPlayer.Name .. " has entered the Server")
        evacuateServer("Player (" .. newPlayer.Name .. ") entering the server DETECTED!")
    end
end)

task.spawn(function()
    task.wait(40.0) 
    if PlayAgainRemote then
        SafeWrite("[ ANOMALY ] : You took too long in a run, something went wrong!")
        pcall(function() PlayAgainRemote:FireServer() end)
    end
end)

task.spawn(function()
    task.wait(45.0) 
    local LobbyID = 90148635862803 
    local TeleportService = game:GetService("TeleportService")
    Log("Failed to initiate (Play Again), returning to lobby", "[ANOMALY] : ")
    pcall(function() TeleportService:Teleport(LobbyID, LocalPlayer) end)
end)
 
character:GetAttributeChangedSignal("Dead"):Connect(function()
    SafeWrite("[ ANOMALY ] : You died in a run, something went wrong!")
    pcall(function() PlayAgainRemote:FireServer() end)
end)
 
Main()
