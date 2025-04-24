local addonName, ns = ...
local CT = ns.CT

local TIMELINE_HEIGHT = 20
local LEGEND_HEIGHT = 15
local COOLDOWN_HEIGHT = 15
local COOLDOWN_SPACING = 2

local OFFENSIVE_COLOR = {r = 0.9, g = 0.3, b = 0.3, a = 1}
local DEFENSIVE_COLOR = {r = 0.3, g = 0.7, b = 0.9, a = 1}
local UTILITY_COLOR = {r = 0.9, g = 0.7, b = 0.3, a = 1}

local timeline = {
    frame = nil,
    cooldowns = {},
    players = {},
    startTime = 0,
    endTime = 0,
}

local function CreateTimelineFrame()
    local frame = CreateFrame("Frame", "PhoenixUIRaidTimeline", UIParent, "BackdropTemplate")
    frame:SetSize(CT.db.profile.timeline.width, CT.db.profile.timeline.height)
    frame:SetPoint("CENTER", UIParent, "CENTER", 0, 0)
    frame:SetScale(CT.db.profile.timeline.scale)
    frame:SetMovable(true)
    frame:EnableMouse(true)
    frame:SetClampedToScreen(true)
    frame:RegisterForDrag("LeftButton")
    frame:SetScript("OnDragStart", frame.StartMoving)
    frame:SetScript("OnDragStop", frame.StopMovingOrSizing)
    
    frame:SetBackdrop({
        bgFile = "Interface\\Tooltips\\UI-Tooltip-Background",
        edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
        tile = true, tileSize = 16, edgeSize = 16,
        insets = {left = 4, right = 4, top = 4, bottom = 4}
    })
    frame:SetBackdropColor(0.1, 0.1, 0.1, 0.8)
    frame:SetBackdropBorderColor(0.3, 0.3, 0.3, 1)
    
    -- Create timeline axis
    local timeAxis = frame:CreateTexture(nil, "ARTWORK")
    timeAxis:SetHeight(2)
    timeAxis:SetPoint("BOTTOMLEFT", frame, "BOTTOMLEFT", 5, 10)
    timeAxis:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT", -5, 10)
    timeAxis:SetColorTexture(0.7, 0.7, 0.7, 0.7)
    frame.timeAxis = timeAxis
    
    -- Create legend if enabled
    if CT.db.profile.timeline.showLegend then
        local legend = CreateFrame("Frame", nil, frame)
        legend:SetHeight(LEGEND_HEIGHT)
        legend:SetPoint("TOPLEFT", frame, "TOPLEFT", 5, -5)
        legend:SetPoint("TOPRIGHT", frame, "TOPRIGHT", -5, -5)
        
        -- Offensive legend
        local offensiveIcon = legend:CreateTexture(nil, "ARTWORK")
        offensiveIcon:SetSize(10, 10)
        offensiveIcon:SetPoint("LEFT", legend, "LEFT", 5, 0)
        offensiveIcon:SetColorTexture(OFFENSIVE_COLOR.r, OFFENSIVE_COLOR.g, OFFENSIVE_COLOR.b, OFFENSIVE_COLOR.a)
        
        local offensiveText = legend:CreateFontString(nil, "ARTWORK", "GameFontNormalSmall")
        offensiveText:SetPoint("LEFT", offensiveIcon, "RIGHT", 2, 0)
        offensiveText:SetText("Offensive")
        
        -- Defensive legend
        local defensiveIcon = legend:CreateTexture(nil, "ARTWORK")
        defensiveIcon:SetSize(10, 10)
        defensiveIcon:SetPoint("LEFT", offensiveText, "RIGHT", 10, 0)
        defensiveIcon:SetColorTexture(DEFENSIVE_COLOR.r, DEFENSIVE_COLOR.g, DEFENSIVE_COLOR.b, DEFENSIVE_COLOR.a)
        
        local defensiveText = legend:CreateFontString(nil, "ARTWORK", "GameFontNormalSmall")
        defensiveText:SetPoint("LEFT", defensiveIcon, "RIGHT", 2, 0)
        defensiveText:SetText("Defensive")
        
        -- Utility legend
        local utilityIcon = legend:CreateTexture(nil, "ARTWORK")
        utilityIcon:SetSize(10, 10)
        utilityIcon:SetPoint("LEFT", defensiveText, "RIGHT", 10, 0)
        utilityIcon:SetColorTexture(UTILITY_COLOR.r, UTILITY_COLOR.g, UTILITY_COLOR.b, UTILITY_COLOR.a)
        
        local utilityText = legend:CreateFontString(nil, "ARTWORK", "GameFontNormalSmall")
        utilityText:SetPoint("LEFT", utilityIcon, "RIGHT", 2, 0)
        utilityText:SetText("Utility")
        
        frame.legend = legend
    end
    
    -- Content frame for cooldowns
    local content = CreateFrame("Frame", nil, frame)
    content:SetPoint("TOPLEFT", frame, "TOPLEFT", 5, CT.db.profile.timeline.showLegend and -25 or -5)
    content:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT", -5, 15)
    frame.content = content
    
    -- Time markers
    for i = 0, CT.db.profile.timeline.timelineLength, 30 do
        local marker = frame:CreateFontString(nil, "ARTWORK", "GameFontNormalSmall")
        marker:SetPoint("BOTTOM", timeAxis, "BOTTOM", (i / CT.db.profile.timeline.timelineLength) * (frame:GetWidth() - 10) - 5, -15)
        marker:SetText(i)
        
        local tick = frame:CreateTexture(nil, "ARTWORK")
        tick:SetSize(1, 5)
        tick:SetPoint("BOTTOM", timeAxis, "BOTTOM", (i / CT.db.profile.timeline.timelineLength) * (frame:GetWidth() - 10) - 5, 0)
        tick:SetColorTexture(0.7, 0.7, 0.7, 0.7)
    end
    
    -- Close button
    local closeButton = CreateFrame("Button", nil, frame, "UIPanelCloseButton")
    closeButton:SetPoint("TOPRIGHT", frame, "TOPRIGHT", 0, 0)
    closeButton:SetScript("OnClick", function() frame:Hide() end)
    
    frame:Hide()
    return frame
end

function CT:InitializeRaidTimeline()
    if not CT.db.profile.timeline.enabled then
        return
    end
    
    timeline.frame = CreateTimelineFrame()
    
    -- Register events for tracking cooldowns
    self:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED", "OnCombatLogEvent")
    self:RegisterEvent("ENCOUNTER_START", "OnEncounterStart")
    self:RegisterEvent("ENCOUNTER_END", "OnEncounterEnd")
    
    -- Add slash command
    self:RegisterChatCommand("cttimeline", "ToggleRaidTimeline")
end

function CT:ToggleRaidTimeline()
    if not timeline.frame then
        return
    end
    
    if timeline.frame:IsShown() then
        timeline.frame:Hide()
    else
        timeline.frame:Show()
    end
end

function CT:OnEncounterStart(_, encounterID, encounterName)
    if not CT.db.profile.timeline.enabled or not timeline.frame then
        return
    end
    
    timeline.startTime = GetTime()
    timeline.endTime = timeline.startTime + CT.db.profile.timeline.timelineLength
    timeline.cooldowns = {}
    timeline.players = {}
    
    -- Reset the timeline display
    for _, child in ipairs({timeline.frame.content:GetChildren()}) do
        child:Hide()
        child:SetParent(nil)
    end
    
    timeline.frame:Show()
end

function CT:OnEncounterEnd()
    if not CT.db.profile.timeline.enabled or not timeline.frame then
        return
    end
    
    -- Keep the timeline visible after encounter ends
end

function CT:OnCombatLogEvent(_, event)
    if not CT.db.profile.timeline.enabled or not timeline.frame then
        return
    end
    
    local timestamp, eventType, _, sourceGUID, sourceName, sourceFlags, _, destGUID, destName, destFlags, _, spellID, spellName = CombatLogGetCurrentEventInfo()
    
    -- Only track player events (not NPCs)
    if bit.band(sourceFlags, COMBATLOG_OBJECT_TYPE_PLAYER) == 0 then
        return
    end
    
    -- Check if it's a spell cast event
    if eventType == "SPELL_CAST_SUCCESS" then
        local spellInfo = CT.spellDB[spellID]
        if not spellInfo then return end
        
        -- Check if we should show this type of cooldown
        local shouldShow = false
        if spellInfo.type == "offensive" and CT.db.profile.timeline.showOffensive then
            shouldShow = true
        elseif spellInfo.type == "defensive" and CT.db.profile.timeline.showDefensive then
            shouldShow = true
        elseif spellInfo.type == "utility" and CT.db.profile.timeline.showUtility then
            shouldShow = true
        end
        
        if not shouldShow then return end
        
        -- Add the cooldown to our tracking
        local cooldown = {
            spellID = spellID,
            spellName = spellName,
            sourceName = sourceName,
            sourceGUID = sourceGUID,
            timestamp = timestamp,
            type = spellInfo.type
        }
        
        table.insert(timeline.cooldowns, cooldown)
        
        -- Track unique players
        if not timeline.players[sourceGUID] then
            timeline.players[sourceGUID] = {
                name = sourceName,
                row = #timeline.players + 1
            }
        end
        
        -- Create the cooldown marker on the timeline
        self:AddCooldownToTimeline(cooldown)
    end
end

function CT:AddCooldownToTimeline(cooldown)
    if not timeline.frame or not timeline.frame.content then
        return
    end
    
    local player = timeline.players[cooldown.sourceGUID]
    if not player then return end
    
    local relativeTime = cooldown.timestamp - timeline.startTime
    local position = relativeTime / CT.db.profile.timeline.timelineLength
    
    -- Don't show cooldowns outside our timeline range
    if position < 0 or position > 1 then
        return
    end
    
    local width = timeline.frame.content:GetWidth()
    local contentHeight = timeline.frame.content:GetHeight()
    local rowHeight = math.min(COOLDOWN_HEIGHT, contentHeight / math.max(1, table.getn(timeline.players)))
    
    -- Create cooldown marker
    local marker = CreateFrame("Frame", nil, timeline.frame.content)
    marker:SetSize(6, rowHeight - COOLDOWN_SPACING)
    marker:SetPoint("TOPLEFT", timeline.frame.content, "TOPLEFT", position * width, -(player.row - 1) * rowHeight)
    
    -- Determine color based on cooldown type
    local color = UTILITY_COLOR
    if cooldown.type == "offensive" then
        color = OFFENSIVE_COLOR
    elseif cooldown.type == "defensive" then
        color = DEFENSIVE_COLOR
    end
    
    local bg = marker:CreateTexture(nil, "BACKGROUND")
    bg:SetAllPoints()
    bg:SetColorTexture(color.r, color.g, color.b, color.a)
    
    -- Tooltip
    marker:SetScript("OnEnter", function(self)
        GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
        GameTooltip:SetSpellByID(cooldown.spellID)
        GameTooltip:AddLine(cooldown.sourceName, 1, 1, 1)
        GameTooltip:AddLine(string.format("Time: %.1f", relativeTime), 0.7, 0.7, 0.7)
        GameTooltip:Show()
    end)
    marker:SetScript("OnLeave", function()
        GameTooltip:Hide()
    end)
    
    -- Add player name if it's the first cooldown from this player
    if not player.label then
        local nameLabel = timeline.frame.content:CreateFontString(nil, "ARTWORK", "GameFontNormalSmall")
        nameLabel:SetPoint("TOPLEFT", timeline.frame.content, "TOPLEFT", 2, -(player.row - 1) * rowHeight)
        nameLabel:SetText(cooldown.sourceName:match("([^-]+)"))
        nameLabel:SetTextColor(1, 1, 1, 0.7)
        player.label = nameLabel
    end
end

-- Add the module to the addon
CT.RaidTimeline = timeline 