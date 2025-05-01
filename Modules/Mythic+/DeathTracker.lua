-- Phoenix_UI: DeathTracker Submodule for Mythic+
-- Tracks deaths during Mythic+ runs and provides detailed information

local addonName, Phoenix = ...
local MythicPlus = Phoenix.Modules.MythicPlus
local DeathTracker = MythicPlus:NewModule("DeathTracker", "AceEvent-3.0", "AceTimer-3.0")
local L = MythicPlus.L

-- Constants
local DEATH_TIMER_PENALTY = 5 -- 5 seconds per death
local PHOENIX_ICON = "Interface\\Icons\\Spell_Fire_FelFireNova" -- Phoenix-themed icon

-- Local variables
local deathCounter = 0
local deathLog = {}
local deathTimestamp = 0
local isRunning = false
local deathFrame = nil
local deathTooltip = nil

-- Get current time formatted for the death log
local function GetFormattedTime()
    return date("%H:%M:%S")
end

-- Format time in seconds to MM:SS
local function FormatTimeSeconds(seconds)
    if not seconds or seconds <= 0 then
        return "00:00"
    end
    
    local minutes = math.floor(seconds / 60)
    local secs = math.floor(seconds % 60)
    
    return string.format("%02d:%02d", minutes, secs)
end

-- Debug function
function DeathTracker:Debug(message)
    if Phoenix_UI and Phoenix_UI.Debug then
        Phoenix_UI:Debug("DeathTracker", message)
    end
end

-- Create the death counter frame
local function CreateDeathFrame()
    if deathFrame then return deathFrame end
    
    -- Create the main frame
    deathFrame = CreateFrame("Frame", "PhoenixUI_MythicPlusDeathTracker", UIParent)
    deathFrame:SetSize(100, 30)
    deathFrame:SetPoint("CENTER", UIParent, "CENTER", 0, 0)
    deathFrame:SetFrameStrata("MEDIUM")
    deathFrame:EnableMouse(true)
    deathFrame:SetMovable(true)
    deathFrame:RegisterForDrag("LeftButton")
    deathFrame:SetScript("OnDragStart", function(self)
        if not MythicPlus.db.lockDeathFrame then
            self:StartMoving()
        end
    end)
    deathFrame:SetScript("OnDragStop", function(self)
        self:StopMovingOrSizing()
        -- Save position
        local point, _, relativePoint, xOfs, yOfs = self:GetPoint()
        MythicPlus.db.deathFramePosition = {point = point, relativePoint = relativePoint, x = xOfs, y = yOfs}
    end)
    
    -- Create background
    local bg = deathFrame:CreateTexture(nil, "BACKGROUND")
    bg:SetAllPoints()
    bg:SetColorTexture(0, 0, 0, 0.7)
    
    -- Create border using BackdropTemplate for modern WoW versions
    local border = CreateFrame("Frame", nil, deathFrame, BackdropTemplateMixin and "BackdropTemplate")
    border:SetPoint("TOPLEFT", deathFrame, "TOPLEFT", -1, 1)
    border:SetPoint("BOTTOMRIGHT", deathFrame, "BOTTOMRIGHT", 1, -1)
    
    -- Use SetBackdrop if it exists, otherwise manually set the backdrop elements
    local backdropInfo = {
        edgeFile = "Interface\\DialogFrame\\UI-DialogBox-Border",
        edgeSize = 16,
        insets = {left = 4, right = 4, top = 4, bottom = 4}
    }
    
    if border.SetBackdrop then
        border:SetBackdrop(backdropInfo)
    else
        -- For modern clients without SetBackdrop
        Mixin(border, BackdropTemplateMixin)
        border:OnBackdropLoaded()
        border:SetBackdrop(backdropInfo)
    end
    
    -- Create skull icon
    local icon = deathFrame:CreateTexture(nil, "OVERLAY")
    icon:SetSize(20, 20)
    icon:SetPoint("LEFT", deathFrame, "LEFT", 5, 0)
    icon:SetTexture("Interface\\TargetingFrame\\UI-TargetingFrame-Skull")
    deathFrame.icon = icon
    
    -- Create text
    local text = deathFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    text:SetPoint("LEFT", icon, "RIGHT", 5, 0)
    text:SetText("0")
    deathFrame.text = text
    
    -- Create tooltip
    deathTooltip = CreateFrame("GameTooltip", "PhoenixUI_DeathTrackerTooltip", deathFrame, "GameTooltipTemplate")
    
    -- Set up tooltip on mouseup
    deathFrame:SetScript("OnEnter", function(self)
        if #deathLog > 0 and MythicPlus.db.showDeathDetails then
            deathTooltip:SetOwner(self, "ANCHOR_TOPRIGHT")
            deathTooltip:AddLine(L["DEATH_TRACKER"], 1, 0.82, 0)
            deathTooltip:AddLine(" ")
            
            for i, death in ipairs(deathLog) do
                local timeString = FormatTimeSeconds(death.timeLost)
                local color = RAID_CLASS_COLORS[death.class] or {r = 1, g = 1, b = 1}
                deathTooltip:AddDoubleLine(
                    "|cff" .. string.format("%02x%02x%02x", color.r*255, color.g*255, color.b*255) .. death.name .. "|r",
                    "|cffFF5555-" .. timeString .. "|r"
                )
            end
            
            if deathCounter > 0 then
                deathTooltip:AddLine(" ")
                deathTooltip:AddLine(L["TIME_PENALTY"] .. ": " .. FormatTimeSeconds(deathCounter * DEATH_TIMER_PENALTY), 1, 0.5, 0)
            end
            
            deathTooltip:Show()
        end
    end)
    
    deathFrame:SetScript("OnLeave", function(self)
        deathTooltip:Hide()
    end)
    
    -- Hide initially
    deathFrame:Hide()
    
    return deathFrame
end

-- Track a player death
function DeathTracker:TrackDeath(player, timestamp)
    if not isRunning then return end
    
    -- If no player is specified, assume it's the player
    player = player or UnitName("player")
    timestamp = timestamp or GetTime()
    
    -- Increment counter
    deathCounter = deathCounter + 1
    
    -- Get player class
    local _, playerClass = UnitClass(player == UnitName("player") and "player" or player)
    
    -- Add to death log
    local death = {
        name = player,
        class = playerClass or "WARRIOR", -- Default if class can't be determined
        time = GetFormattedTime(),
        timestamp = timestamp,
        timeLost = DEATH_TIMER_PENALTY
    }
    
    tinsert(deathLog, death)
    
    -- Update display
    self:UpdateDisplay()
    
    -- Announce if configured
    if MythicPlus.db.announceDeaths and IsInGroup() then
        local message = string.format(L["DEATH_RECORD"], player, deathCounter)
        SendChatMessage("|T" .. PHOENIX_ICON .. ":14:14:0:0|t " .. message, "PARTY")
    end
    
    -- Fire message for other modules
    MythicPlus:SendMessage("PHOENIX_MYTHICPLUS_DEATH", deathCounter, death)
    
    self:Debug("Death tracked: " .. player .. " (Total: " .. deathCounter .. ")")
end

-- Update the death counter display
function DeathTracker:UpdateDisplay()
    if not deathFrame then
        deathFrame = CreateDeathFrame()
    end
    
    if deathFrame and deathFrame.text then
        deathFrame.text:SetText(deathCounter)
        
        -- Color text red if deaths are significant
        if deathCounter >= 10 then
            deathFrame.text:SetTextColor(1, 0, 0) -- Red
        elseif deathCounter >= 5 then
            deathFrame.text:SetTextColor(1, 0.5, 0) -- Orange
        else
            deathFrame.text:SetTextColor(1, 1, 1) -- White
        end
        
        -- Show or hide based on settings and state
        if MythicPlus.db.deathTracker and isRunning then
            deathFrame:Show()
        else
            deathFrame:Hide()
        end
    end
end

-- Reset the death tracker
function DeathTracker:ResetDeathTracker()
    deathCounter = 0
    deathLog = {}
    self:UpdateDisplay()
    self:Debug("Death tracker reset")
end

-- Get total death penalty time
function DeathTracker:GetTotalDeathPenalty()
    return deathCounter * DEATH_TIMER_PENALTY
end

-- Initialize the module
function DeathTracker:OnInitialize()
    -- Create the frame if needed
    if not deathFrame then
        deathFrame = CreateDeathFrame()
    end
    
    -- Register events
    self:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED", function()
        if not isRunning then return end
        
        local timestamp, event, _, sourceGUID, sourceName, sourceFlags, sourceRaidFlags, destGUID, destName, destFlags, destRaidFlags = CombatLogGetCurrentEventInfo()
        
        if event == "UNIT_DIED" then
            local isPlayer = bit.band(destFlags, COMBATLOG_OBJECT_TYPE_PLAYER) > 0
            local isInGroup = bit.band(destFlags, COMBATLOG_OBJECT_CONTROL_PLAYER) > 0 and bit.band(destFlags, COMBATLOG_OBJECT_AFFILIATION_PARTY) > 0
            
            if isPlayer and (isInGroup or destName == UnitName("player")) then
                self:TrackDeath(destName, GetTime())
            end
        end
    end)
    
    -- Register messages from MythicPlus module
    MythicPlus:RegisterMessage("PHOENIX_MYTHICPLUS_START", function()
        isRunning = true
        self:ResetDeathTracker()
        self:Debug("Mythic+ started, death tracking active")
    end)
    
    MythicPlus:RegisterMessage("PHOENIX_MYTHICPLUS_COMPLETE", function()
        isRunning = false
        self:Debug("Mythic+ completed, death tracking deactivated")
    end)
    
    MythicPlus:RegisterMessage("PHOENIX_MYTHICPLUS_RESET", function()
        self:ResetDeathTracker()
    end)
    
    -- Register with Blizzard's death count event
    self:RegisterEvent("CHALLENGE_MODE_DEATH_COUNT_UPDATED", function(event, count)
        -- This is a failsafe if our tracking misses anything
        if count > deathCounter then
            self:Debug("Synchronizing with Blizzard death count: " .. count)
            deathCounter = count
            self:UpdateDisplay()
        end
    end)
    
    self:Debug("DeathTracker module initialized")
end

-- Update settings
function DeathTracker:UpdateSettings()
    -- Apply saved position if available
    if deathFrame and MythicPlus.db.deathFramePosition then
        local pos = MythicPlus.db.deathFramePosition
        deathFrame:ClearAllPoints()
        deathFrame:SetPoint(pos.point, UIParent, pos.relativePoint, pos.x, pos.y)
    end
    
    -- Show/hide based on settings
    if MythicPlus.db.deathTracker then
        self:Enable()
    else
        self:Disable()
    end
    
    self:UpdateDisplay()
end

-- Enable the module
function DeathTracker:OnEnable()
    isRunning = C_ChallengeMode.IsChallengeModeActive()
    
    if isRunning then
        -- Get current death count from the API
        local count = C_ChallengeMode.GetDeathCount() or 0
        if count > 0 and count > deathCounter then
            deathCounter = count
        end
    end
    
    self:UpdateDisplay()
    self:Debug("DeathTracker module enabled")
end

-- Disable the module
function DeathTracker:OnDisable()
    if deathFrame then
        deathFrame:Hide()
    end
    
    self:Debug("DeathTracker module disabled")
end 