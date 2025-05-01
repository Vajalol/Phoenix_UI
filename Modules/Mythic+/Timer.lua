-- Phoenix_UI: Timer Submodule for Mythic+
-- Provides enhanced timers and progress tracking for Mythic+ dungeons

local addonName, Phoenix = ...
local MythicPlus = Phoenix.Modules.MythicPlus
local Timer = MythicPlus:NewModule("Timer", "AceEvent-3.0", "AceTimer-3.0")
local L = MythicPlus.L

-- Frame references
local timerFrame, objectiveFrame
local deathCounter
local pridefulTimer

-- Cache for timer data
local timerData = {
    startTime = 0,
    endTime = 0,
    timeLimit = 0,
    inProgress = false,
    deaths = 0,
    timeLost = 0,
    currentProgress = 0,
    totalProgress = 100,
    currentPull = {},
    chests = {
        { percent = 0.4, text = "+3", color = {r=0, g=1, b=0} },       -- +3 Chest: 40% time remaining
        { percent = 0.2, text = "+2", color = {r=1, g=1, b=0} },       -- +2 Chest: 20% time remaining
        { percent = 0, text = "+1", color = {r=1, g=0.5, b=0} },       -- +1 Chest: Complete in time
        { percent = -99999, text = "+0", color = {r=1, g=0, b=0} }     -- +0 Chest: Out of time
    }
}

-- Constants
local OBJECTIVE_FRAME_HEIGHT = 20
local CHEST_INDICATOR_WIDTH = 2
local DEATH_TIME_PENALTY = 5 -- 5 seconds per death
local UPDATE_INTERVAL = 0.1

-- Utility functions
local function FormatTimeSeconds(seconds, showMs)
    if not seconds or seconds <= 0 then
        return "00:00"
    end
    
    local absSeconds = math.abs(seconds)
    local minutes = math.floor(absSeconds / 60)
    local secs = math.floor(absSeconds % 60)
    
    if showMs then
        local ms = math.floor((absSeconds - math.floor(absSeconds)) * 10)
        return string.format("%02d:%02d.%d", minutes, secs, ms)
    else
        return string.format("%02d:%02d", minutes, secs)
    end
end

-- Create the timer UI
local function CreateTimerFrame()
    -- Main timer frame
    timerFrame = CreateFrame("Frame", "PhoenixUI_MythicPlusTimer", UIParent)
    timerFrame:SetSize(250, 80)
    timerFrame:SetPoint("TOP", UIParent, "TOP", 0, -50)
    timerFrame:SetFrameStrata("MEDIUM")
    timerFrame:SetFrameLevel(5)
    timerFrame:EnableMouse(true)
    timerFrame:SetMovable(true)
    timerFrame:RegisterForDrag("LeftButton")
    timerFrame:SetScript("OnDragStart", function() 
        if MythicPlus.db.lockTimerFrame then return end
        timerFrame:StartMoving() 
    end)
    timerFrame:SetScript("OnDragStop", function() 
        timerFrame:StopMovingOrSizing() 
        -- Save position
        local point, _, relativePoint, xOfs, yOfs = timerFrame:GetPoint()
        MythicPlus.db.timerPosition = {point = point, relativePoint = relativePoint, x = xOfs, y = yOfs}
    end)
    
    -- Background
    local bg = timerFrame:CreateTexture(nil, "BACKGROUND")
    bg:SetAllPoints()
    bg:SetColorTexture(0, 0, 0, 0.7)
    
    -- Border
    local border = CreateFrame("Frame", nil, timerFrame)
    border:SetPoint("TOPLEFT", timerFrame, "TOPLEFT", -1, 1)
    border:SetPoint("BOTTOMRIGHT", timerFrame, "BOTTOMRIGHT", 1, -1)
    border:SetBackdrop({
        edgeFile = "Interface\\DialogFrame\\UI-DialogBox-Border",
        edgeSize = 16,
        insets = {left = 4, right = 4, top = 4, bottom = 4}
    })
    
    -- Title
    local title = timerFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    title:SetPoint("TOP", timerFrame, "TOP", 0, -10)
    title:SetText(L["Mythic+ Timer"])
    timerFrame.title = title
    
    -- Timer text
    local timerText = timerFrame:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
    timerText:SetPoint("CENTER", timerFrame, "CENTER", 0, 5)
    timerText:SetFont(timerText:GetFont(), 20, "OUTLINE")
    timerFrame.timerText = timerText
    
    -- Elapsed time text (for dual display)
    local elapsedText = timerFrame:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
    elapsedText:SetPoint("TOPLEFT", timerFrame, "TOPLEFT", 10, -30)
    elapsedText:SetFont(elapsedText:GetFont(), 14, "OUTLINE")
    elapsedText:SetText(L["Elapsed"] .. ": 00:00")
    elapsedText:Hide()
    timerFrame.elapsedText = elapsedText
    
    -- Remaining time text (for dual display)
    local remainingText = timerFrame:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
    remainingText:SetPoint("TOPRIGHT", timerFrame, "TOPRIGHT", -10, -30)
    remainingText:SetFont(remainingText:GetFont(), 14, "OUTLINE")
    remainingText:SetText(L["Remaining"] .. ": 00:00")
    remainingText:Hide()
    timerFrame.remainingText = remainingText
    
    -- Progress bar
    local progressBar = CreateFrame("StatusBar", nil, timerFrame)
    progressBar:SetPoint("BOTTOM", timerFrame, "BOTTOM", 0, 15)
    progressBar:SetSize(230, 15)
    progressBar:SetStatusBarTexture("Interface\\TargetingFrame\\UI-StatusBar")
    progressBar:SetStatusBarColor(0.2, 0.6, 1.0)
    progressBar:SetMinMaxValues(0, 100)
    progressBar:SetValue(0)
    
    -- Progress text
    local progressText = progressBar:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    progressText:SetPoint("CENTER", progressBar, "CENTER")
    progressText:SetTextColor(1, 1, 1)
    progressBar.text = progressText
    
    -- Progress background
    local progressBg = progressBar:CreateTexture(nil, "BACKGROUND")
    progressBg:SetAllPoints()
    progressBg:SetColorTexture(0.1, 0.1, 0.1, 0.8)
    
    -- Chest indicators (timer markers)
    local chestMarkers = {}
    for i, chestData in ipairs(timerData.chests) do
        local marker = timerFrame:CreateTexture(nil, "OVERLAY")
        marker:SetSize(CHEST_INDICATOR_WIDTH, 15)
        marker:SetColorTexture(chestData.color.r, chestData.color.g, chestData.color.b, 0.8)
        marker:Hide()
        
        local markerText = timerFrame:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
        markerText:SetPoint("BOTTOM", marker, "TOP", 0, 1)
        markerText:SetText(chestData.text)
        markerText:SetTextColor(chestData.color.r, chestData.color.g, chestData.color.b)
        markerText:Hide()
        
        chestMarkers[i] = {marker = marker, text = markerText}
    end
    timerFrame.chestMarkers = chestMarkers
    
    -- Death counter
    deathCounter = CreateFrame("Frame", nil, timerFrame)
    deathCounter:SetSize(40, 20)
    deathCounter:SetPoint("TOPRIGHT", timerFrame, "TOPRIGHT", -5, -5)
    
    local deathIcon = deathCounter:CreateTexture(nil, "OVERLAY")
    deathIcon:SetSize(16, 16)
    deathIcon:SetPoint("LEFT", deathCounter, "LEFT")
    deathIcon:SetTexture("Interface\\TargetingFrame\\UI-TargetingFrame-Skull")
    
    local deathText = deathCounter:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
    deathText:SetPoint("LEFT", deathIcon, "RIGHT", 2, 0)
    deathText:SetText("0")
    deathCounter.text = deathText
    
    -- Store references
    timerFrame.progressBar = progressBar
    
    return timerFrame
end

-- Create the objective tracker frame
local function CreateObjectiveFrame()
    objectiveFrame = CreateFrame("Frame", "PhoenixUI_MythicPlusObjective", UIParent)
    objectiveFrame:SetSize(250, 200)
    objectiveFrame:SetPoint("TOPRIGHT", UIParent, "TOPRIGHT", -100, -200)
    objectiveFrame:SetFrameStrata("MEDIUM")
    objectiveFrame:SetFrameLevel(5)
    objectiveFrame:EnableMouse(true)
    objectiveFrame:SetMovable(true)
    objectiveFrame:RegisterForDrag("LeftButton")
    objectiveFrame:SetScript("OnDragStart", function() 
        if MythicPlus.db.lockObjectiveFrame then return end
        objectiveFrame:StartMoving() 
    end)
    objectiveFrame:SetScript("OnDragStop", function() 
        objectiveFrame:StopMovingOrSizing() 
        -- Save position
        local point, _, relativePoint, xOfs, yOfs = objectiveFrame:GetPoint()
        MythicPlus.db.objectivePosition = {point = point, relativePoint = relativePoint, x = xOfs, y = yOfs}
    end)
    
    -- Background
    local bg = objectiveFrame:CreateTexture(nil, "BACKGROUND")
    bg:SetAllPoints()
    bg:SetColorTexture(0, 0, 0, 0.5)
    
    -- Title
    local title = objectiveFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    title:SetPoint("TOPLEFT", objectiveFrame, "TOPLEFT", 10, -10)
    title:SetText(L["Objectives"])
    objectiveFrame.title = title
    
    -- Objective lines container
    local container = CreateFrame("Frame", nil, objectiveFrame)
    container:SetPoint("TOPLEFT", title, "BOTTOMLEFT", 0, -5)
    container:SetPoint("BOTTOMRIGHT", objectiveFrame, "BOTTOMRIGHT", -5, 5)
    objectiveFrame.container = container
    
    -- Initially hide the frame until we have objectives
    objectiveFrame:Hide()
    
    return objectiveFrame
end

-- Update the chest marker positions
local function UpdateChestMarkers()
    if not timerFrame or not timerFrame.chestMarkers or not timerData.timeLimit then return end
    
    local progressBar = timerFrame.progressBar
    local barWidth = progressBar:GetWidth()
    
    for i, chestData in ipairs(timerData.chests) do
        local marker = timerFrame.chestMarkers[i].marker
        local text = timerFrame.chestMarkers[i].text
        
        -- Calculate position based on percentage through timer
        local timePosition = timerData.timeLimit * (1 + chestData.percent)
        local positionPercent = timePosition / timerData.timeLimit
        
        if positionPercent >= 0 and positionPercent <= 1 then
            local xPos = progressBar:GetLeft() + (barWidth * positionPercent)
            marker:ClearAllPoints()
            marker:SetPoint("BOTTOM", progressBar, "BOTTOM", (barWidth * positionPercent) - (barWidth/2), 0)
            marker:Show()
            
            text:ClearAllPoints()
            text:SetPoint("BOTTOM", marker, "TOP", 0, 1)
            text:Show()
        else
            marker:Hide()
            text:Hide()
        end
    end
end

-- Update the progress bar based on dungeon completion
local function UpdateProgressBar()
    if not timerFrame or not timerFrame.progressBar then return end
    
    local progressBar = timerFrame.progressBar
    local currentProgress = timerData.currentProgress or 0
    local totalProgress = timerData.totalProgress or 100
    
    -- Update the progress bar
    progressBar:SetMinMaxValues(0, totalProgress)
    progressBar:SetValue(currentProgress)
    
    -- Update the text
    local progressPercent = math.floor((currentProgress / totalProgress) * 100)
    progressBar.text:SetText(string.format("%d / %d (%d%%)", currentProgress, totalProgress, progressPercent))
    
    -- Color the bar based on progress
    if progressPercent >= 100 then
        progressBar:SetStatusBarColor(0, 1, 0)  -- Green for complete
    elseif progressPercent >= 60 then
        progressBar:SetStatusBarColor(1, 0.6, 0)  -- Orange-ish for getting close
    else
        progressBar:SetStatusBarColor(0.2, 0.6, 1.0)  -- Blue for normal progress
    end
end

-- Format the timer display
local function FormatTimerDisplay(timeRemaining, timeLimit)
    if not timerFrame or not timerData.inProgress then return end
    
    local currentTime = GetTime()
    local elapsedTime = currentTime - timerData.startTime
    local timerFormat = MythicPlus.db.timerFormat or "REMAINING"
    
    -- Handle different display formats
    if timerFormat == "DUAL" then
        -- Dual display mode - show both elapsed and remaining time
        if not timerFrame.elapsedText:IsShown() then
            timerFrame.elapsedText:Show()
            timerFrame.remainingText:Show()
            timerFrame.timerText:Hide()
        end
        
        -- Update elapsed time
        timerFrame.elapsedText:SetText(L["Elapsed"] .. ": " .. FormatTimeSeconds(elapsedTime))
        
        -- Update remaining time with coloring
        local remainingText = L["Remaining"] .. ": "
        
        if timeRemaining >= 0 then
            -- Set color based on time remaining
            local percent = timeRemaining / timeLimit
            if percent > 0.6 then
                timerFrame.remainingText:SetTextColor(0, 1, 0)  -- Green
            elseif percent > 0.3 then
                timerFrame.remainingText:SetTextColor(1, 1, 0)  -- Yellow
            elseif percent > 0.1 then
                timerFrame.remainingText:SetTextColor(1, 0.5, 0)  -- Orange
            else
                timerFrame.remainingText:SetTextColor(1, 0, 0)  -- Red
            end
            
            timerFrame.remainingText:SetText(remainingText .. FormatTimeSeconds(timeRemaining))
        else
            timerFrame.remainingText:SetTextColor(1, 0, 0)  -- Red for overtime
            timerFrame.remainingText:SetText(remainingText .. "-" .. FormatTimeSeconds(-timeRemaining))
        end
    else
        -- Single display mode - show either remaining or elapsed time
        if timerFrame.elapsedText:IsShown() then
            timerFrame.elapsedText:Hide()
            timerFrame.remainingText:Hide()
            timerFrame.timerText:Show()
        end
        
        local timeString
        
        if timerFormat == "ELAPSED" then
            -- Elapsed time display
            timeString = FormatTimeSeconds(elapsedTime)
            timerFrame.timerText:SetTextColor(1, 1, 1)  -- White
        else
            -- Remaining time display (default)
            if timeRemaining >= 0 then
                timeString = "+" .. FormatTimeSeconds(timeRemaining)
                -- Set color based on time remaining
                local percent = timeRemaining / timeLimit
                if percent > 0.6 then
                    timerFrame.timerText:SetTextColor(0, 1, 0)  -- Green
                elseif percent > 0.3 then
                    timerFrame.timerText:SetTextColor(1, 1, 0)  -- Yellow
                elseif percent > 0.1 then
                    timerFrame.timerText:SetTextColor(1, 0.5, 0)  -- Orange
                else
                    timerFrame.timerText:SetTextColor(1, 0, 0)  -- Red
                end
            else
                timeString = "-" .. FormatTimeSeconds(-timeRemaining)
                timerFrame.timerText:SetTextColor(1, 0, 0)  -- Red for overtime
            end
        end
        
        timerFrame.timerText:SetText(timeString)
    end
end

-- Update the objective tracking
local function UpdateObjectives()
    if not objectiveFrame or not objectiveFrame.container then return end
    
    local container = objectiveFrame.container
    
    -- Clear existing objectives
    for _, child in pairs({container:GetChildren()}) do
        child:Hide()
        child:SetParent(nil)
    end
    
    -- Get current objectives
    local numObjectives = 0
    local criteriaString, criteriaType, criteriaCompleted, quantity, totalQuantity, flags, assetID, quantityString
    
    -- Get information about the current scenario
    local scenarioName, currentStage, numStages, flags, _, _, _, xp, money = C_Scenario.GetInfo()
    if not scenarioName then return end
    
    local stageName, stageDescription, numCriteria = C_Scenario.GetStepInfo()
    
    -- Track if we have any objectives to show
    local hasObjectives = false
    
    -- Process each objective
    for i = 1, numCriteria do
        local criteriaString, criteriaType, completed, quantity, totalQuantity, flags, assetID, quantityString = C_Scenario.GetCriteriaInfo(i)
        
        if criteriaString and criteriaString ~= "" then
            hasObjectives = true
            
            -- Create the objective line
            local line = CreateFrame("Frame", nil, container)
            line:SetSize(container:GetWidth(), OBJECTIVE_FRAME_HEIGHT)
            line:SetPoint("TOPLEFT", container, "TOPLEFT", 0, -((i-1) * OBJECTIVE_FRAME_HEIGHT))
            
            -- Status icon
            local statusIcon = line:CreateTexture(nil, "OVERLAY")
            statusIcon:SetSize(16, 16)
            statusIcon:SetPoint("LEFT", line, "LEFT", 5, 0)
            
            if completed then
                statusIcon:SetTexture("Interface\\RAIDFRAME\\ReadyCheck-Ready")
            else
                statusIcon:SetTexture("Interface\\RAIDFRAME\\ReadyCheck-NotReady")
            end
            
            -- Text
            local text = line:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
            text:SetPoint("LEFT", statusIcon, "RIGHT", 5, 0)
            
            -- Format the text based on objective type
            if totalQuantity and totalQuantity > 0 then
                text:SetText(string.format("%s: %d/%d", criteriaString, quantity, totalQuantity))
            else
                text:SetText(criteriaString)
            end
            
            if completed then
                text:SetTextColor(0.6, 0.8, 0.6)
            else
                text:SetTextColor(1, 1, 1)
            end
            
            numObjectives = numObjectives + 1
        end
    end
    
    -- Resize the frame based on number of objectives
    if numObjectives > 0 then
        objectiveFrame:SetHeight(numObjectives * OBJECTIVE_FRAME_HEIGHT + 50)
        objectiveFrame:Show()
    else
        objectiveFrame:Hide()
    end
end

-- Get current progress from the UI
local function GetCurrentProgress()
    -- This uses the Blizzard progress bar tracker to get the current progress
    -- Fallback to our tracked value if unable to get from UI
    
    local defeatEnemyForces = false
    local currentForces, totalForces = 0, 100
    
    -- Find the scenario block in the objective tracker
    for i = 1, C_Scenario.GetNumStages() do
        local stageName = C_Scenario.GetStepInfo(i)
        if stageName and (stageName:match(L["Enemies"]) or stageName:match("Enemy Forces")) then
            defeatEnemyForces = true
            break
        end
    end
    
    if defeatEnemyForces then
        -- Find the progress from the current scenario
        for i = 1, C_Scenario.GetNumCriteria() do
            local name, _, _, currValue, maxValue = C_Scenario.GetCriteriaInfo(i)
            if name and currValue and maxValue and maxValue > 0 then
                -- If we find a criteria with the right name pattern (Enemy Forces)
                if name:match(L["Enemies"]) or name:match("Enemy Forces") then
                    currentForces = currValue
                    totalForces = maxValue
                    break
                end
            end
        end
    end
    
    return currentForces, totalForces
end

-- Update the timer with current time
local function OnUpdate(self, elapsed)
    self.elapsed = (self.elapsed or 0) + elapsed
    if self.elapsed < UPDATE_INTERVAL then return end
    self.elapsed = 0
    
    if not timerData.inProgress then return end
    
    -- Get current time and calculate time remaining
    local currentTime = GetTime()
    local elapsedTime = currentTime - timerData.startTime
    local timeRemaining = timerData.timeLimit - elapsedTime - timerData.timeLost
    
    -- Update the timer display
    FormatTimerDisplay(timeRemaining, timerData.timeLimit)
    
    -- Check for objective updates
    if MythicPlus.db.showObjectives then
        UpdateObjectives()
    end
    
    -- Update progress bar if tracking
    if MythicPlus.db.trackProgress then
        local currentProgress, totalProgress = GetCurrentProgress()
        if currentProgress and totalProgress and totalProgress > 0 then
            timerData.currentProgress = currentProgress
            timerData.totalProgress = totalProgress
            UpdateProgressBar()
        end
    end
end

-- Update the death counter
local function UpdateDeathCounter(numDeaths)
    if not deathCounter or not deathCounter.text then return end
    
    timerData.deaths = numDeaths or timerData.deaths
    deathCounter.text:SetText(timerData.deaths)
    
    -- Update time lost if death penalties are enabled
    if MythicPlus.db.deathPenalty then
        timerData.timeLost = timerData.deaths * DEATH_TIME_PENALTY
    end
end

-- Start the timer with the given parameters
function Timer:StartTimer(timeLimit, startImmediately)
    -- Initialize timer data
    timerData.timeLimit = timeLimit or 0
    timerData.startTime = startImmediately and GetTime() or 0
    timerData.endTime = timerData.startTime + timerData.timeLimit
    timerData.inProgress = startImmediately or false
    timerData.deaths = 0
    timerData.timeLost = 0
    timerData.currentProgress = 0
    timerData.totalProgress = 100
    timerData.currentPull = {}
    
    -- Create frames if they don't exist
    if not timerFrame then
        timerFrame = CreateTimerFrame()
    end
    
    if MythicPlus.db.showObjectives and not objectiveFrame then
        objectiveFrame = CreateObjectiveFrame()
    end
    
    -- Show timer
    timerFrame:Show()
    
    -- Update UI elements
    UpdateChestMarkers()
    UpdateProgressBar()
    UpdateDeathCounter(0)
    
    -- Start the update timer
    timerFrame:SetScript("OnUpdate", OnUpdate)
    
    -- Dispatch event
    MythicPlus:SendMessage("PHOENIX_MYTHICPLUS_TIMER_START", timeLimit)
end

-- Resume the timer (after a zone in, etc.)
function Timer:ResumeTimer()
    if not timerData.startTime or timerData.startTime == 0 then return end
    
    timerData.inProgress = true
    
    -- Update UI elements
    UpdateChestMarkers()
    UpdateProgressBar()
    UpdateDeathCounter(timerData.deaths)
    
    -- Dispatch event
    MythicPlus:SendMessage("PHOENIX_MYTHICPLUS_TIMER_RESUME")
end

-- Pause the timer
function Timer:PauseTimer()
    timerData.inProgress = false
    
    -- Dispatch event
    MythicPlus:SendMessage("PHOENIX_MYTHICPLUS_TIMER_PAUSE")
end

-- Stop the timer
function Timer:StopTimer(success)
    timerData.inProgress = false
    
    -- Calculate final time
    local finalTime = GetTime() - timerData.startTime
    
    -- Final update of UI
    if timerFrame and timerFrame.timerText then
        timerFrame.timerText:SetText(FormatTimeSeconds(finalTime))
        
        if success then
            timerFrame.timerText:SetTextColor(0, 1, 0)  -- Green for success
        else
            timerFrame.timerText:SetTextColor(1, 0, 0)  -- Red for failure
        end
        
        -- Stop updates
        timerFrame:SetScript("OnUpdate", nil)
    end
    
    -- Hide objective frame
    if objectiveFrame then
        objectiveFrame:Hide()
    end
    
    -- Dispatch event
    MythicPlus:SendMessage("PHOENIX_MYTHICPLUS_TIMER_STOP", finalTime, success)
end

-- Reset the timer
function Timer:ResetTimer()
    timerData.inProgress = false
    timerData.startTime = 0
    timerData.endTime = 0
    timerData.deaths = 0
    timerData.timeLost = 0
    timerData.currentProgress = 0
    
    -- Hide frames
    if timerFrame then
        timerFrame:Hide()
    end
    
    if objectiveFrame then
        objectiveFrame:Hide()
    end
    
    -- Dispatch event
    MythicPlus:SendMessage("PHOENIX_MYTHICPLUS_TIMER_RESET")
end

-- Track a player death
function Timer:TrackDeath()
    if not timerData.inProgress then return end
    
    timerData.deaths = timerData.deaths + 1
    
    -- Add time penalty if enabled
    if MythicPlus.db.deathPenalty then
        timerData.timeLost = timerData.timeLost + DEATH_TIME_PENALTY
    end
    
    -- Update the counter
    UpdateDeathCounter(timerData.deaths)
    
    -- Dispatch event
    MythicPlus:SendMessage("PHOENIX_MYTHICPLUS_DEATH", timerData.deaths)
end

-- Initialize the module
function Timer:OnInitialize()
    -- Initialize frames if not already created
    if not timerFrame and MythicPlus.db.showTimer then
        timerFrame = CreateTimerFrame()
        timerFrame:Hide()
    end
    
    if not objectiveFrame and MythicPlus.db.showObjectives then
        objectiveFrame = CreateObjectiveFrame()
        objectiveFrame:Hide()
    end
    
    -- Register events
    MythicPlus:RegisterMessage("PHOENIX_MYTHICPLUS_START", function(event, timeLimit)
        Timer:StartTimer(timeLimit, true)
    end)
    
    MythicPlus:RegisterMessage("PHOENIX_MYTHICPLUS_COMPLETE", function(event, success)
        Timer:StopTimer(success)
    end)
    
    MythicPlus:RegisterMessage("PHOENIX_MYTHICPLUS_RESET", function()
        Timer:ResetTimer()
    end)
    
    -- Hook challenge mode events
    self:RegisterEvent("PLAYER_ENTERING_WORLD", function()
        -- Check if we're in a M+ and need to resume the timer
        local inChallenge = C_ChallengeMode.IsChallengeModeActive()
        if inChallenge and timerData.startTime > 0 then
            Timer:ResumeTimer()
        end
    end)
    
    self:RegisterEvent("CHALLENGE_MODE_DEATH_COUNT_UPDATED", function(event, deathCount)
        UpdateDeathCounter(deathCount)
    end)
end

-- Update settings
function Timer:UpdateSettings()
    -- Apply saved position if available
    if timerFrame and MythicPlus.db.timerPosition then
        local pos = MythicPlus.db.timerPosition
        timerFrame:ClearAllPoints()
        timerFrame:SetPoint(pos.point, UIParent, pos.relativePoint, pos.x, pos.y)
    end
    
    if objectiveFrame and MythicPlus.db.objectivePosition then
        local pos = MythicPlus.db.objectivePosition
        objectiveFrame:ClearAllPoints()
        objectiveFrame:SetPoint(pos.point, UIParent, pos.relativePoint, pos.x, pos.y)
    end
    
    -- Show/hide based on settings
    if timerFrame then
        if MythicPlus.db.showTimer then
            if timerData.inProgress then
                timerFrame:Show()
                
                -- Update the timer display format if needed
                if timerData.inProgress then
                    local currentTime = GetTime()
                    local elapsedTime = currentTime - timerData.startTime
                    local timeRemaining = timerData.timeLimit - elapsedTime - timerData.timeLost
                    FormatTimerDisplay(timeRemaining, timerData.timeLimit)
                end
                
                -- Update chest markers
                if MythicPlus.db.showChestTimers then
                    UpdateChestMarkers()
                else
                    -- Hide the markers
                    for _, marker in ipairs(timerFrame.chestMarkers or {}) do
                        marker.marker:Hide()
                        marker.text:Hide()
                    end
                end
            end
        else
            timerFrame:Hide()
        end
    end
    
    if objectiveFrame then
        if MythicPlus.db.showObjectives and timerData.inProgress then
            objectiveFrame:Show()
            UpdateObjectives()
        else
            objectiveFrame:Hide()
        end
    end
end

-- Enable the module
function Timer:OnEnable()
    if MythicPlus.db.showTimer and timerFrame then
        timerFrame:Show()
    end
    
    if MythicPlus.db.showObjectives and objectiveFrame then
        objectiveFrame:Show()
        UpdateObjectives()
    end
end

-- Disable the module
function Timer:OnDisable()
    if timerFrame then
        timerFrame:Hide()
    end
    
    if objectiveFrame then
        objectiveFrame:Hide()
    end
end 