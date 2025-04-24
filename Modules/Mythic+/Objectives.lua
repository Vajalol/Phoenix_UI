-- Phoenix_UI: Objectives Submodule for Mythic+
-- Enhances the objectives tracking during Mythic+ dungeons

local addonName, Phoenix = ...
local MythicPlus = Phoenix.Modules.MythicPlus
local Objectives = MythicPlus:NewModule("Objectives", "AceEvent-3.0", "AceHook-3.0")
local L = MythicPlus.L

-- Constants
local UPDATE_INTERVAL = 0.5
local PHOENIX_ICON = "Interface\\Icons\\Ability_Mount_FireHawk" -- Phoenix-themed icon
local ENEMY_FORCES_STRING = "Enemy Forces"
local ENEMY_FORCES_TOOLTIP_PATTERN = "(%d+)/(%d+)"

-- Local variables
local isRunning = false
local lastUpdate = 0
local trackerFrame = nil
local currentProgress = 0
local totalProgress = 100
local progressFormat = "PERCENTAGE_AND_VALUE"
local enemyForcesLine = nil
local tooltipHooked = false

-- Debug function
function Objectives:Debug(message)
    if Phoenix_UI and Phoenix_UI.Debug then
        Phoenix_UI:Debug("Objectives", message)
    end
end

-- Format progress based on settings
local function FormatProgress(current, total)
    if not current or not total or total == 0 then
        return "0%"
    end
    
    local percent = math.floor((current / total) * 100 + 0.5)
    
    if progressFormat == "PERCENTAGE_ONLY" then
        return percent .. "%"
    elseif progressFormat == "VALUE_ONLY" then
        return current .. "/" .. total
    else -- PERCENTAGE_AND_VALUE
        return current .. "/" .. total .. " (" .. percent .. "%)"
    end
end

-- Check and get objective tracker frame
local function GetObjectiveTrackerFrame()
    return ObjectiveTrackerFrame
end

-- Find the enemy forces objective line in the tracker
local function FindEnemyForcesLine()
    local frame = GetObjectiveTrackerFrame()
    if not frame then return nil end
    
    -- Look through all the blocks in the objective tracker
    for i = 1, C_Scenario.GetNumStages() do
        local stepName, _, numCriteria = C_Scenario.GetStepInfo(i)
        
        -- Check each criteria in this step
        for j = 1, numCriteria do
            local criteriaString, criteriaType, completed, quantity, totalQuantity = C_Scenario.GetCriteriaInfo(j)
            
            -- If this is the enemy forces line
            if criteriaString and (criteriaString:find(ENEMY_FORCES_STRING) or criteriaString:find(L["ENEMY_FORCES"])) then
                enemyForcesLine = {
                    criteriaIndex = j,
                    stepIndex = i,
                    text = criteriaString,
                    current = quantity,
                    total = totalQuantity,
                    completed = completed
                }
                
                currentProgress = quantity
                totalProgress = totalQuantity
                
                return enemyForcesLine
            end
        end
    end
    
    return nil
end

-- Hook game tooltip to show enemy forces info
local function HookGameTooltip()
    if tooltipHooked then return end
    
    -- Hook the tooltip
    Objectives:SecureHook("GameTooltip_OnShow", function(tooltip)
        if not MythicPlus.db.showEnemyTooltip or not isRunning then return end
        
        -- Only add to enemy tooltips
        if tooltip:GetUnit() and not UnitIsPlayer(tooltip:GetUnit()) and UnitCanAttack("player", tooltip:GetUnit()) then
            -- Get NPC ID
            local guid = UnitGUID(tooltip:GetUnit())
            if not guid then return end
            
            local _, _, _, _, _, npcID = strsplit("-", guid)
            if not npcID then return end
            npcID = tonumber(npcID)
            
            -- Get forces contribution if available
            local forcesValue = Objectives:GetEnemyForces(npcID)
            if forcesValue and forcesValue > 0 then
                local percentValue = totalProgress > 0 and (forcesValue / totalProgress * 100) or 0
                tooltip:AddLine(" ")
                tooltip:AddLine(L["ENEMY_FORCES"] .. ": +" .. forcesValue .. " (" .. string.format("%.2f", percentValue) .. "%)", 1, 0.82, 0)
            end
        end
    end)
    
    tooltipHooked = true
    Objectives:Debug("GameTooltip hooked for enemy forces info")
end

-- Get enemy forces contribution for an NPC ID
function Objectives:GetEnemyForces(npcID)
    -- This would normally come from a database of NPC values
    -- For now, return a placeholder
    return 1
    
    -- In a real implementation, you'd have a table of NPC IDs to forces values
    -- return npcForcesDB[npcID] or 0
end

-- Update the enemy forces progress
function Objectives:UpdateEnemyForcesProgress()
    -- Find the enemy forces line
    if not enemyForcesLine then
        FindEnemyForcesLine()
    end
    
    -- Get current progress
    local forcesCriteria = enemyForcesLine and enemyForcesLine.criteriaIndex
    local forcesStep = enemyForcesLine and enemyForcesLine.stepIndex
    
    if forcesCriteria and forcesStep then
        local criteriaString, criteriaType, completed, quantity, totalQuantity = C_Scenario.GetCriteriaInfo(forcesCriteria)
        
        if quantity and totalQuantity then
            -- Update progress values
            currentProgress = quantity
            totalProgress = totalQuantity
            enemyForcesLine.current = quantity
            enemyForcesLine.total = totalQuantity
            enemyForcesLine.completed = completed
            
            -- Fire update event
            MythicPlus:SendMessage("PHOENIX_MYTHICPLUS_PROGRESS_UPDATED", currentProgress, totalProgress)
        end
    end
end

-- Enhance the objective tracker with additional enemy forces info
function Objectives:EnhanceObjectiveTracker()
    local frame = GetObjectiveTrackerFrame()
    if not frame then return end
    
    -- Register for enemy forces updates
    self:RegisterEvent("SCENARIO_CRITERIA_UPDATE", function()
        self:UpdateEnemyForcesProgress()
    end)
    
    -- Register for scenario updates
    self:RegisterEvent("SCENARIO_UPDATE", function()
        FindEnemyForcesLine()
        self:UpdateEnemyForcesProgress()
    end)
    
    -- Hook objective tracker for recoloring and formatting
    if not self:IsHooked("ObjectiveTracker_Update") then
        self:SecureHook("ObjectiveTracker_Update", function()
            -- Find and enhance enemy forces line if needed
            FindEnemyForcesLine()
            self:UpdateEnemyForcesProgress()
        end)
    end
    
    -- Hook tooltip
    HookGameTooltip()
    
    -- Modify the objective tracker appearance
    for i = 1, C_Scenario.GetNumStages() do
        local blocks = frame.BlocksFrame.blocks
        if blocks then
            for _, block in pairs(blocks) do
                if block.lines then
                    for _, line in pairs(block.lines) do
                        if line.Text and line.Text:GetText() and 
                           (line.Text:GetText():find(ENEMY_FORCES_STRING) or line.Text:GetText():find(L["ENEMY_FORCES"])) then
                            -- Enhance this line
                            local text = line.Text:GetText()
                            local current, total = text:match(ENEMY_FORCES_TOOLTIP_PATTERN)
                            
                            if current and total then
                                current = tonumber(current)
                                total = tonumber(total)
                                
                                -- Replace text with our formatted version
                                local formattedText = ENEMY_FORCES_STRING .. ": " .. FormatProgress(current, total)
                                line.Text:SetText(formattedText)
                                
                                -- Color based on progress
                                local percent = (current / total) * 100
                                if percent >= 100 then
                                    line.Text:SetTextColor(0, 1, 0) -- Green
                                elseif percent >= 90 then
                                    line.Text:SetTextColor(1, 0.82, 0) -- Gold
                                else
                                    line.Text:SetTextColor(1, 1, 1) -- White
                                end
                            end
                        end
                    end
                end
            end
        end
    end
end

-- Initialize the module
function Objectives:OnInitialize()
    -- Get progress format from settings
    if MythicPlus.db.progressFormat then
        progressFormat = MythicPlus.db.progressFormat
    end
    
    -- Register messages from MythicPlus module
    MythicPlus:RegisterMessage("PHOENIX_MYTHICPLUS_START", function()
        isRunning = true
        FindEnemyForcesLine()
        self:EnhanceObjectiveTracker()
        self:Debug("Mythic+ started, objectives enhancement active")
    end)
    
    MythicPlus:RegisterMessage("PHOENIX_MYTHICPLUS_COMPLETE", function()
        isRunning = false
        enemyForcesLine = nil
        self:Debug("Mythic+ completed, objectives enhancement deactivated")
    end)
    
    -- Check if we're already in a Mythic+ dungeon
    isRunning = C_ChallengeMode.IsChallengeModeActive()
    if isRunning then
        FindEnemyForcesLine()
        self:EnhanceObjectiveTracker()
    end
    
    self:Debug("Objectives module initialized")
end

-- Update settings
function Objectives:UpdateSettings()
    -- Update progress format
    if MythicPlus.db.progressFormat then
        progressFormat = MythicPlus.db.progressFormat
    end
    
    -- Re-enhance if running
    if isRunning then
        self:EnhanceObjectiveTracker()
    end
end

-- Enable the module
function Objectives:OnEnable()
    -- Check if we're in a Mythic+ dungeon
    isRunning = C_ChallengeMode.IsChallengeModeActive()
    
    if isRunning then
        FindEnemyForcesLine()
        self:EnhanceObjectiveTracker()
    end
    
    self:Debug("Objectives module enabled")
end

-- Disable the module
function Objectives:OnDisable()
    -- We don't completely undo changes to avoid disrupting the UI
    -- Just stop active monitoring
    isRunning = false
    self:Debug("Objectives module disabled")
end 