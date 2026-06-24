local Workspace = game:GetService("Workspace")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local HttpService = game:GetService("HttpService")

local LocalPlayer     = getgenv().LocalPlayer
local character       = getgenv().character
local TargetContainer = getgenv().TargetContainer
local MapFolder       = getgenv().MapFolder
local TilesFolder     = getgenv().TilesFolder
local FILE_NAME       = getgenv().FILE_NAME
local CONFIG_FILE     = getgenv().CONFIG_FILE

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "ApocalypseControlPanel"
ScreenGui.IgnoreGuiInset = true 
ScreenGui.DisplayOrder = -1      
ScreenGui.ResetOnSpawn = false   
ScreenGui.Parent = TargetContainer

-- Theme Palettes
local BG_COLOR = Color3.fromRGB(11, 14, 20)      
local PANEL_COLOR = Color3.fromRGB(16, 21, 30)   
local NEON_CYAN = Color3.fromRGB(0, 243, 255)    
local MAT_GREEN = Color3.fromRGB(0, 255, 140)    

local function ApplyCyberBorder(parent, accentColor)
    local stroke = Instance.new("UIStroke")
    stroke.Thickness = 1.2
    stroke.Color = accentColor or Color3.fromRGB(40, 55, 75)
    stroke.Transparency = 0.2
    stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    stroke.Parent = parent

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 4)
    corner.Parent = parent
end

-- --- 2. THE ABSOLUTE FULL-SCREEN BACKGROUND ---
local MainBackground = Instance.new("Frame")
MainBackground.Name = "MainBackground"
MainBackground.Size = UDim2.new(1, 0, 1, 0)
MainBackground.BackgroundColor3 = BG_COLOR
MainBackground.ZIndex = 1
MainBackground.ClipsDescendants = true 
MainBackground.Parent = ScreenGui

-- --- 3. TOP NAVIGATION CONTAINERS (ENLARGED SCREEN HEADER) ---
local TopBar = Instance.new("Frame")
TopBar.Name = "TopBar"
TopBar.Size = UDim2.new(0.8, 0, 0, 60)
TopBar.Position = UDim2.new(0.1, 0, 0, 15) 
TopBar.BackgroundColor3 = PANEL_COLOR
TopBar.ZIndex = 3
TopBar.Parent = MainBackground
ApplyCyberBorder(TopBar)

local StatusLabel = Instance.new("TextLabel")
StatusLabel.Name = "StatusLabel"
StatusLabel.Size = UDim2.new(1, -20, 1, -16) 
StatusLabel.Position = UDim2.new(0, 10, 0, 8)
StatusLabel.BackgroundTransparency = 1
StatusLabel.Font = Enum.Font.Code
StatusLabel.TextScaled = true 
StatusLabel.TextColor3 = MAT_GREEN
StatusLabel.Text = "SCRIPT ACTIVATED"
StatusLabel.ZIndex = 4
StatusLabel.Parent = TopBar

local TimerPanel = Instance.new("Frame")
TimerPanel.Name = "TimerPanel"
TimerPanel.Size = UDim2.new(0.22, 0, 0, 32)
TimerPanel.Position = UDim2.new(0.39, 0, 0, 83)
TimerPanel.BackgroundColor3 = PANEL_COLOR
TimerPanel.ZIndex = 3
TimerPanel.Parent = MainBackground
ApplyCyberBorder(TimerPanel)

local TimerLabel = Instance.new("TextLabel")
TimerLabel.Name = "TimerLabel"
TimerLabel.Size = UDim2.new(1, 0, 1, 0)
TimerLabel.Position = UDim2.new(0, 0, 0, 0)
TimerLabel.BackgroundTransparency = 1
TimerLabel.Font = Enum.Font.Code
TimerLabel.TextScaled = true 
TimerLabel.TextColor3 = Color3.fromRGB(160, 180, 200)
TimerLabel.Text = "00:00:00"
TimerLabel.ZIndex = 4
TimerLabel.Parent = TimerPanel

local TimerPadding = Instance.new("UIPadding")
TimerPadding.PaddingTop = UDim.new(0, 4)
TimerPadding.PaddingBottom = UDim.new(0, 4)
TimerPadding.PaddingLeft = UDim.new(0, 8)
TimerPadding.PaddingRight = UDim.new(0, 8)
TimerPadding.Parent = TimerLabel

-- --- 4. TABS NAVIGATION SIDEBAR ---
local TabFrame = Instance.new("Frame")
TabFrame.Name = "TabFrame"
TabFrame.Size = UDim2.new(0, 60, 1, -145) 
TabFrame.Position = UDim2.new(0, 10, 0, 130) 
TabFrame.BackgroundColor3 = PANEL_COLOR
TabFrame.ZIndex = 3
TabFrame.Parent = MainBackground
ApplyCyberBorder(TabFrame)

local MainTabBtn = Instance.new("TextButton")
MainTabBtn.Name = "MainTabButton"
MainTabBtn.Size = UDim2.new(1, -10, 0.48, 0)
MainTabBtn.Position = UDim2.new(0, 5, 0, 6)
MainTabBtn.BackgroundColor3 = Color3.fromRGB(24, 33, 46)
MainTabBtn.Text = "" 
MainTabBtn.ZIndex = 4
MainTabBtn.Parent = TabFrame
ApplyCyberBorder(MainTabBtn, Color3.fromRGB(35, 45, 60))

local MainRotatedText = Instance.new("TextLabel")
MainRotatedText.Size = UDim2.new(0, 120, 0, 30) 
MainRotatedText.Position = UDim2.new(0.5, -60, 0.5, -15) 
MainRotatedText.Rotation = 90 
MainRotatedText.BackgroundTransparency = 1
MainRotatedText.Font = Enum.Font.Code
MainRotatedText.TextScaled = true
MainRotatedText.TextColor3 = NEON_CYAN
MainRotatedText.Text = "MAIN"
MainRotatedText.ZIndex = 5
MainRotatedText.Parent = MainTabBtn

local PrevTabBtn = Instance.new("TextButton")
PrevTabBtn.Name = "PrevTabButton"
PrevTabBtn.Size = UDim2.new(1, -10, 0.48, 0)
PrevTabBtn.Position = UDim2.new(0, 5, 0.52, -6)
PrevTabBtn.BackgroundColor3 = Color3.fromRGB(18, 22, 30)
PrevTabBtn.Text = "" 
PrevTabBtn.ZIndex = 4
PrevTabBtn.Parent = TabFrame
ApplyCyberBorder(PrevTabBtn, Color3.fromRGB(35, 45, 60))

local PrevRotatedText = Instance.new("TextLabel")
PrevRotatedText.Size = UDim2.new(0, 120, 0, 30)
PrevRotatedText.Position = UDim2.new(0.5, -60, 0.5, -15)
PrevRotatedText.Rotation = 90 
PrevRotatedText.BackgroundTransparency = 1
PrevRotatedText.Font = Enum.Font.Code
PrevRotatedText.TextScaled = true
PrevRotatedText.TextColor3 = Color3.fromRGB(120, 140, 160)
PrevRotatedText.Text = "PREVIOUS RUNS"
PrevRotatedText.ZIndex = 5
PrevRotatedText.Parent = PrevTabBtn

-- --- 5. VISUALIZER MAP MONITOR PANEL ---
local MapPanel = Instance.new("Frame")
MapPanel.Name = "MapPanel"
MapPanel.BackgroundColor3 = PANEL_COLOR
MapPanel.ZIndex = 3
MapPanel.Parent = MainBackground
ApplyCyberBorder(MapPanel)

local MapTitle = Instance.new("TextLabel")
MapTitle.Name = "MapTitle"
MapTitle.Size = UDim2.new(1, -10, 0, 35) 
MapTitle.Position = UDim2.new(0, 10, 0, 5)
MapTitle.BackgroundTransparency = 1
MapTitle.Font = Enum.Font.Sarpanch
MapTitle.TextSize = 26 
MapTitle.TextColor3 = NEON_CYAN
MapTitle.Text = "LIVE MAP (ABOVE VIEW)"
MapTitle.TextXAlignment = Enum.TextXAlignment.Left
MapTitle.ZIndex = 4
MapTitle.Parent = MapPanel

local MapScreen = Instance.new("ViewportFrame")
MapScreen.Name = "MapScreen"
MapScreen.Size = UDim2.new(1, -16, 1, -50) 
MapScreen.Position = UDim2.new(0, 8, 0, 42) 
MapScreen.BackgroundColor3 = Color3.fromRGB(6, 8, 12) 
MapScreen.Ambient = Color3.fromRGB(180, 185, 195)        
MapScreen.LightColor = Color3.fromRGB(230, 225, 215)    
MapScreen.LightDirection = Vector3.new(0.2, -1, 0.2)    
MapScreen.BorderSizePixel = 0
MapScreen.ZIndex = 4
MapScreen.Parent = MapPanel

-- ===================================================================
-- --- PART 2: RADAR INDICATORS & RIGHT CONSOLE SEGMENTS ---
-- ===================================================================

local PlayerIcon = Instance.new("ImageLabel")
PlayerIcon.Name = "PlayerIcon"
PlayerIcon.AnchorPoint = Vector2.new(0.5, 0.5)
PlayerIcon.Position = UDim2.new(0.5, 0, 0.5, 0)
PlayerIcon.BackgroundTransparency = 1
PlayerIcon.Size = UDim2.new(0.05, 0, 0.05, 0)
PlayerIcon.Image = "rbxassetid://134669175143859"
PlayerIcon.ZIndex = 5
PlayerIcon.Parent = MapScreen

local ClonesFolder = Instance.new("Folder")
ClonesFolder.Name = "Clones"
ClonesFolder.Parent = MapScreen

task.spawn(function()
    if not MapFolder then return end
    if not TilesFolder then return end

    local HumanoidRootPart = character:WaitForChild("HumanoidRootPart")

    LocalPlayer.CharacterAdded:Connect(function(NewChar)
        getgenv().character = NewChar
        HumanoidRootPart = NewChar:WaitForChild("HumanoidRootPart")
    end)
    
    local function CloneModel(object)
        if object:IsA("Model") then
            local clone = object:Clone()
            clone.Parent = ClonesFolder
        end
    end

    for _, object in ipairs(TilesFolder:GetChildren()) do CloneModel(object) end
    
    TilesFolder.ChildAdded:Connect(function(newObject)
        task.wait(0.5)
        if newObject and newObject.Parent then CloneModel(newObject) end
    end)

    local Range = 700
    local Height = 1500
    local Fov = math.deg(2 * math.atan(Range / (2 * Height)))
    local Camera = Instance.new("Camera")
    Camera.CameraType = Enum.CameraType.Scriptable
    Camera.FieldOfView = Fov
    MapScreen.CurrentCamera = Camera
    
    RunService.RenderStepped:Connect(function()
        if not HumanoidRootPart then return end
        local PlayerPos = HumanoidRootPart.Position
        local CameraSkyPos = Vector3.new(PlayerPos.X, 4 + Height, PlayerPos.Z)
        local CameraLookAt = Vector3.new(PlayerPos.X, 4, PlayerPos.Z)
        Camera.CFrame = CFrame.new(CameraSkyPos, CameraLookAt)
    end)
end)

local TerminalPanel = Instance.new("Frame")
TerminalPanel.Name = "TerminalPanel"
TerminalPanel.BackgroundColor3 = PANEL_COLOR
TerminalPanel.ZIndex = 3
TerminalPanel.Parent = MainBackground
ApplyCyberBorder(TerminalPanel)

local LogTitle = Instance.new("TextLabel")
LogTitle.Size = UDim2.new(1, -10, 0, 35) 
LogTitle.Position = UDim2.new(0, 10, 0, 5)
LogTitle.BackgroundTransparency = 1
LogTitle.Font = Enum.Font.Sarpanch
LogTitle.TextSize = 26 
LogTitle.TextColor3 = NEON_CYAN
LogTitle.Text = "TERMINAL LOGS"
LogTitle.TextXAlignment = Enum.TextXAlignment.Left 
LogTitle.ZIndex = 4
LogTitle.Parent = TerminalPanel

local LogScrollFrame = Instance.new("ScrollingFrame")
LogScrollFrame.Name = "TerminalLogs"
LogScrollFrame.BackgroundColor3 = Color3.fromRGB(6, 8, 12)
LogScrollFrame.BorderSizePixel = 0
LogScrollFrame.ScrollBarThickness = 5
LogScrollFrame.ScrollBarImageColor3 = NEON_CYAN
LogScrollFrame.ZIndex = 4
LogScrollFrame.Parent = TerminalPanel

local UIList = Instance.new("UIListLayout")
UIList.SortOrder = Enum.SortOrder.LayoutOrder
UIList.Padding = UDim.new(0, 3)
UIList.Parent = LogScrollFrame

local UserPanel = Instance.new("ScrollingFrame") 
UserPanel.Name = "UserPanel"
UserPanel.BackgroundColor3 = PANEL_COLOR
UserPanel.ZIndex = 3
UserPanel.Parent = MainBackground
ApplyCyberBorder(UserPanel)

UserPanel.BorderSizePixel = 0
UserPanel.ScrollBarThickness = 5 
UserPanel.ScrollBarImageColor3 = NEON_CYAN
UserPanel.AutomaticCanvasSize = Enum.AutomaticSize.Y 
UserPanel.CanvasSize = UDim2.new(0, 0, 0, 0) 

local UserPadding = Instance.new("UIPadding")
UserPadding.PaddingLeft = UDim.new(0, 10)
UserPadding.PaddingTop = UDim.new(0, 10)
UserPadding.PaddingBottom = UDim.new(0, 15) 
UserPadding.Parent = UserPanel

local ProfilePic = Instance.new("ImageLabel")
ProfilePic.Name = "ProfilePic"
ProfilePic.Size = UDim2.new(0, 80, 0, 80)
ProfilePic.Position = UDim2.new(0, 5, 0, 5) 
ProfilePic.BackgroundColor3 = Color3.fromRGB(20, 25, 35)
ProfilePic.ZIndex = 4
ProfilePic.Parent = UserPanel
ApplyCyberBorder(ProfilePic, NEON_CYAN or Color3.fromRGB(0, 243, 255))

local function CreateCombinedStatLine(text, positionY, color, fontSize)
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, -95, 0, 20)
    label.Position = UDim2.new(0, 100, 0, positionY)
    label.BackgroundTransparency = 1
    label.Font = Enum.Font.Code
    label.TextSize = fontSize or 20
    label.TextColor3 = color or Color3.fromRGB(240, 245, 255)
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Text = text
    label.ZIndex = 4
    label.Parent = UserPanel
    return label
end

-- ===================================================================
-- --- PART 3: USER PROFILE SECTION ---
-- ===================================================================

local UsernameLabel = CreateCombinedStatLine("SYSTEM_USER", 5, Color3.fromRGB(255, 255, 255), 30)
local GemCountLabel = CreateCombinedStatLine("TOTAL GEMS: 0", 33, Color3.fromRGB(230, 190, 50))
local ClassLabel = CreateCombinedStatLine("Current Class: None", 64, Color3.fromRGB(180, 200, 220))

local HealthLabel = CreateCombinedStatLine("Health: 100", 86, Color3.fromRGB(23, 230, 37))
local HungerLabel = CreateCombinedStatLine("Hunger: 100", 107, Color3.fromRGB(230, 164, 23)) 

local ACCENT_CYAN = NEON_CYAN or Color3.fromRGB(0, 243, 255)
local ACCENT_GREEN = MAT_GREEN or Color3.fromRGB(0, 255, 140)

local HideNameBtn = Instance.new("TextButton")
HideNameBtn.Name = "HideNameBtn"
HideNameBtn.Size = UDim2.new(1, -120, 0, 20)
HideNameBtn.Position = UDim2.new(0, 20, 0, 170) 
HideNameBtn.BackgroundTransparency = 1
HideNameBtn.Font = Enum.Font.Code
HideNameBtn.TextSize = 30
HideNameBtn.TextColor3 = Color3.fromRGB(180, 190, 200)
HideNameBtn.TextXAlignment = Enum.TextXAlignment.Left
HideNameBtn.Text = "[ ] Hide Username"
HideNameBtn.ZIndex = 4
HideNameBtn.Parent = UserPanel

local OptimisedFarmBtn = Instance.new("TextButton")
OptimisedFarmBtn.Name = "OptimisedFarmBtn"
OptimisedFarmBtn.Size = UDim2.new(1, -120, 0, 20)
OptimisedFarmBtn.Position = UDim2.new(0, 20, 0, 220) 
OptimisedFarmBtn.BackgroundTransparency = 1
OptimisedFarmBtn.Font = Enum.Font.Code
OptimisedFarmBtn.TextSize = 30
OptimisedFarmBtn.TextColor3 = Color3.fromRGB(180, 190, 200)
OptimisedFarmBtn.TextXAlignment = Enum.TextXAlignment.Left
OptimisedFarmBtn.Text = "[ ] Optimised Farming Mode"
OptimisedFarmBtn.ZIndex = 4
OptimisedFarmBtn.Parent = UserPanel

local OptimisedFarm = Instance.new("TextLabel")
OptimisedFarm.Name = "OptimisedFarmtext"
OptimisedFarm.Size = UDim2.new(1, -50, 0, 80)
OptimisedFarm.Position = UDim2.new(0, 20, 0, 250) 
OptimisedFarm.BackgroundTransparency = 1
OptimisedFarm.Font = Enum.Font.Code
OptimisedFarm.TextSize = 20
OptimisedFarm.TextColor3 = Color3.fromRGB(100, 115, 130) 
OptimisedFarm.TextXAlignment = Enum.TextXAlignment.Left
OptimisedFarm.TextYAlignment = Enum.TextYAlignment.Top
OptimisedFarm.TextWrapped = true
OptimisedFarm.Text = "Note: Enabling this will replace the current UI with low-quality simple UI for upcoming runs for maximum performance"
OptimisedFarm.ZIndex = 4
OptimisedFarm.Parent = UserPanel

local PreviousRunsPanel = Instance.new("ScrollingFrame")
PreviousRunsPanel.Name = "PreviousRunsPanel"
PreviousRunsPanel.Size = UDim2.new(1, -16, 1, -40)
PreviousRunsPanel.Position = UDim2.new(0, 8, 0, 32)
PreviousRunsPanel.BackgroundColor3 = Color3.fromRGB(6, 8, 12) 
PreviousRunsPanel.BorderSizePixel = 0 
PreviousRunsPanel.Visible = false 
PreviousRunsPanel.ZIndex = 4
PreviousRunsPanel.Parent = MapPanel

local PrevRunList = Instance.new("UIListLayout")
PrevRunList.SortOrder = Enum.SortOrder.LayoutOrder
PrevRunList.Padding = UDim.new(0, 8)
PrevRunList.Parent = PreviousRunsPanel

local PrevRunPadding = Instance.new("UIPadding")
PrevRunPadding.PaddingLeft = UDim.new(0, 8)
PrevRunPadding.PaddingTop = UDim.new(0, 8) 
PrevRunPadding.Parent = PreviousRunsPanel

local function RecalculateMonitorLayout()
    local screenWidth = MainBackground.AbsoluteSize.X
    local screenHeight = MainBackground.AbsoluteSize.Y
    
    local targetSquareSide = screenHeight - 145 
    
    MapPanel.Size = UDim2.new(0, targetSquareSide, 0, targetSquareSide)
    MapPanel.Position = UDim2.new(0, 80, 0, 130)
    
    PreviousRunsPanel.Size = MapScreen.Size
    PreviousRunsPanel.Position = MapScreen.Position
    
    LogScrollFrame.Size = UDim2.new(1, -16, 1, -49)
    LogScrollFrame.Position = UDim2.new(0, 8, 0, 42)
    local remainingXPosition = 80 + targetSquareSide + 15
    local remainingWidth = screenWidth - remainingXPosition - 10
    
    local terminalHeight = (targetSquareSide * 0.55) - 10
    TerminalPanel.Size = UDim2.new(0, remainingWidth, 0, terminalHeight)
    TerminalPanel.Position = UDim2.new(0, remainingXPosition, 0, 130)
    
    local userPanelYPosition = 130 + terminalHeight + 15
    local userPanelHeight = (130 + targetSquareSide) - userPanelYPosition
    
    UserPanel.Size = UDim2.new(0, remainingWidth, 0, userPanelHeight)
    UserPanel.Position = UDim2.new(0, remainingXPosition, 0, userPanelYPosition)
end

RecalculateMonitorLayout()
MainBackground:GetPropertyChangedSignal("AbsoluteSize"):Connect(RecalculateMonitorLayout)

getgenv().LogToTerminal = function(message, header)
    local LogLine = Instance.new("TextLabel")
    LogLine.Size = UDim2.new(1, -10, 0, 25)
    LogLine.BackgroundTransparency = 1
    LogLine.Font = Enum.Font.Code
    LogLine.TextSize = 18
    LogLine.TextColor3 = MAT_GREEN
    LogLine.TextXAlignment = Enum.TextXAlignment.Left
    LogLine.Text = header .. tostring(message)
    LogLine.ZIndex = 5
    LogLine.Parent = LogScrollFrame
    
    LogScrollFrame.CanvasSize = UDim2.new(0, 0, 0, UIList.AbsoluteContentSize.Y)
    task.wait(0.01)
    LogScrollFrame.CanvasPosition = Vector2.new(0, math.max(0, LogScrollFrame.CanvasSize.Y.Offset - LogScrollFrame.AbsoluteSize.Y))
end
LogToTerminalPanel = LogToTerminal

local function DataManager()
    local CharacterFolder = Workspace:WaitForChild("Characters")
    local Character = CharacterFolder:WaitForChild(LocalPlayer.Name)
    local Humanoid = Character:WaitForChild("Humanoid")

    GemCountLabel.Text = "TOTAL GEMS: " .. tostring(LocalPlayer:GetAttribute("Gems") or 0)
    local activeClass = LocalPlayer:GetAttribute("Class") or "None"
    ClassLabel.Text = "Current Class: " .. tostring(activeClass)

    local function SyncHealth()
        local health = Humanoid:GetAttribute("Health") or 100
        HealthLabel.Text = "Health: " .. tostring(math.round(health))
    end
    local function SyncHunger()
        local hunger = Character:GetAttribute("Hunger") or 100
        HungerLabel.Text = "Hunger: " .. tostring(math.round(hunger))
    end
    Humanoid:GetAttributeChangedSignal("Health"):Connect(SyncHealth)
    Character:GetAttributeChangedSignal("Hunger"):Connect(SyncHunger)
    
    SyncHealth()
    SyncHunger()
end

task.spawn(pcall, DataManager)

-- --- CONFIGURATION PERSISTENCE CORE MODULE ---
local function LoadConfigProfile()
    if isfile(CONFIG_FILE) then
        local success, data = pcall(function() return HttpService:JSONDecode(readfile(CONFIG_FILE)) end)
        if success and type(data) == "table" then return data end
    end
    return {HideNameActive = false, OptimisedFarmActive = false} 
end

local function SaveConfigProfile(configData) 
    writefile(CONFIG_FILE, HttpService:JSONEncode(configData)) 
end

local Config_Data = LoadConfigProfile()
local OptimisedFarmEnabled = Config_Data.OptimisedFarmActive

local function ChangeUser()
    if Config_Data.HideNameActive then
        HideNameBtn.Text = "[X] Hide Username"
        HideNameBtn.TextColor3 = ACCENT_CYAN
        UsernameLabel.Text = "The Gem Farmer"
        LogToTerminal("Successfully hides the username", "[SYSTEM] : ")
    else
        HideNameBtn.Text = "[ ] Hide Username"
        HideNameBtn.TextColor3 = Color3.fromRGB(180, 190, 200)
        UsernameLabel.Text = LocalPlayer.Name 
        LogToTerminal("Successfully unhides the username", "[SYSTEM] : ")
    end
end

local function OptimisedFarming()
    if Config_Data.OptimisedFarmActive then
        OptimisedFarmBtn.Text = "[X] Optimised Farming Mode"
        OptimisedFarmBtn.TextColor3 = ACCENT_GREEN
        OptimisedFarmEnabled = true
        LogToTerminal("ENABLED OPTIMISED FARM MODE! THIS WILL ONLY AFFECT UPCOMING RUNS", "[SYSTEM] : ")
    else
        OptimisedFarmBtn.Text = "[ ] Optimised Farming Mode"
        OptimisedFarmBtn.TextColor3 = Color3.fromRGB(180, 190, 200)
        OptimisedFarmEnabled = false
        LogToTerminal("OPTIMISED FARM MODE DISABLED!", "[SYSTEM] : ")
    end
end

OptimisedFarming()

HideNameBtn.MouseButton1Click:Connect(function()
    Config_Data.HideNameActive = not Config_Data.HideNameActive
    SaveConfigProfile(Config_Data)
    ChangeUser()
end)

OptimisedFarmBtn.MouseButton1Click:Connect(function()
    Config_Data.OptimisedFarmActive = not Config_Data.OptimisedFarmActive
    SaveConfigProfile(Config_Data)
    OptimisedFarming()
end)

-- ===================================================================
-- --- PART 4: FILESYSTEM HANDLERS & NAVIGATION PIPELINES ---
-- ===================================================================

PreviousRunsPanel.ScrollBarThickness = 5
PreviousRunsPanel.ScrollBarImageColor3 = NEON_CYAN

local function RenderFileLogsToTab()
    -- FIXED: Cleaned up the undefined variable safety check edge case loop rule
    for _, child in ipairs(PreviousRunsPanel:GetChildren()) do
        if child:IsA("TextLabel") then 
            child:Destroy() 
        end
    end
    
    local content = readfile(FILE_NAME)
    local lines = string.split(content, "\n")
    
    local chunkLines = {}
    local validLineIndex = 1
    local currentChunkIndex = 1
    
    local function CreateTextChunk(linesArray, index)
        local ChunkLabel = Instance.new("TextLabel")
        ChunkLabel.Name = "Chunk_" .. tostring(index)
        ChunkLabel.BackgroundTransparency = 1
        ChunkLabel.Font = Enum.Font.Code
        ChunkLabel.TextSize = 18
        ChunkLabel.LineHeight = 1.45
        ChunkLabel.TextXAlignment = Enum.TextXAlignment.Left
        ChunkLabel.TextYAlignment = Enum.TextYAlignment.Top
        ChunkLabel.RichText = true
        ChunkLabel.AutomaticSize = Enum.AutomaticSize.Y 
        ChunkLabel.Size = UDim2.new(1, -16, 0, 0)
        ChunkLabel.ZIndex = 5
        ChunkLabel.LayoutOrder = index
        ChunkLabel.Text = table.concat(linesArray, "\n")
        ChunkLabel.Parent = PreviousRunsPanel
    end
    
    for _, lineText in ipairs(lines) do
        if lineText ~= "" then
            local hexColor = "#B4BEC8" 
            
            if string.find(lineText, "SUCCESSFUL") then
                hexColor = "#00FF8C"    
            elseif string.find(lineText, "ANOMALY") then
                hexColor = "#FF8C00"    
            elseif string.find(lineText, "WARNING") then
                hexColor = "#FF2850"    
            end
            
            local formattedLine = string.format("<font color=\"%s\">%03d. %s</font>", hexColor, validLineIndex, lineText)
            table.insert(chunkLines, formattedLine)
            
            if #chunkLines >= 50 then
                CreateTextChunk(chunkLines, currentChunkIndex)
                currentChunkIndex = currentChunkIndex + 1
                chunkLines = {} 
            end
            
            validLineIndex = validLineIndex + 1
        end
    end
    
    if #chunkLines > 0 then
        CreateTextChunk(chunkLines, currentChunkIndex)
    end
    
    task.wait(0.02)
    PreviousRunsPanel.CanvasSize = UDim2.new(0, 0, 0, PrevRunList.AbsoluteContentSize.Y + 20)
end

task.spawn(RenderFileLogsToTab)

local WriteData = function(logString)
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

local function SwitchToTab(tabName)
    if tabName == "MAIN" then
        MainTabBtn.UIStroke.Color = NEON_CYAN
        MainTabBtn.BackgroundColor3 = Color3.fromRGB(24, 33, 46)
        MainRotatedText.TextColor3 = NEON_CYAN
        
        PrevTabBtn.UIStroke.Color = Color3.fromRGB(35, 45, 60)
        PrevTabBtn.BackgroundColor3 = Color3.fromRGB(18, 22, 30)
        PrevRotatedText.TextColor3 = Color3.fromRGB(120, 140, 160)
        
        if MapTitle then MapTitle.Text = "LIVE MAP (ABOVE VIEW)" end
        MapScreen.Visible = true
        PreviousRunsPanel.Visible = false
    elseif tabName == "PREV_RUNS" then
        PrevTabBtn.UIStroke.Color = NEON_CYAN
        PrevTabBtn.BackgroundColor3 = Color3.fromRGB(24, 33, 46)
        PrevRotatedText.TextColor3 = NEON_CYAN
        
        MainTabBtn.UIStroke.Color = Color3.fromRGB(35, 45, 60)
        MainTabBtn.BackgroundColor3 = Color3.fromRGB(18, 22, 30)
        MainRotatedText.TextColor3 = Color3.fromRGB(120, 140, 160)
        
        if MapTitle then MapTitle.Text = "PREVIOUS RUNS" end
        MapScreen.Visible = false
        PreviousRunsPanel.Visible = true
    end
end

MainTabBtn.MouseButton1Click:Connect(function() SwitchToTab("MAIN") end)
PrevTabBtn.MouseButton1Click:Connect(function() SwitchToTab("PREV_RUNS") end)

task.spawn(function()
    local startEpoch = os.time()
    while task.wait(1) do
        if not TimerLabel then break end
        local elapsed = os.time() - startEpoch
        local hours = math.floor(elapsed / 3600)
        local minutes = math.floor((elapsed % 3600) / 60)
        local seconds = elapsed % 60
        TimerLabel.Text = string.format("%02d:%02d:%02d", hours, minutes, seconds)
    end
end)

task.spawn(function()
    task.wait(2.5) 
    pcall(function() 
        RunService:Set3dRenderingEnabled(false) 
    end)
    LogToTerminal("3D RENDERING HAS BEEN DISABLED, YOUR DEVICE WILL NO LONGER OVERHEAT", "[SYSTEM] : ")
end)

task.spawn(function()
    ChangeUser()
    task.wait(2)
    pcall(function()
        local content, isReady = Players:GetUserThumbnailAsync(LocalPlayer.UserId, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size150x150)
        if isReady then 
            ProfilePic.Image = content 
        end
    end)
end)

LogToTerminal("SYSTEM FULLY SYNCED AND OPERATIONAL", "[SYSTEM] : ")
