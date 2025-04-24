-- Phoenix_UI CooldownTracker - Raid Timeline Module
local addonName, Phoenix = ...

-- Get the main module
local CT = Phoenix_UI:GetModule("CooldownTracker")
if not CT then return end

-- Create the Raid Timeline tracking submodule
local Timeline = CT:NewModule("RaidTimeline")

-- Localization
local L = Phoenix.L or {}

-- Constants
local UPDATE_INTERVAL = 1.0        -- How often to update timeline
local MAX_HISTORY_TIME = 600       -- 10 minutes of history
local DEFAULT_HEIGHT = 150         -- Default height of timeline
local DEFAULT_WIDTH = 300          -- Default width of timeline
local TIME_MARKERS_INTERVAL = 30   -- Time markers every 30 seconds
local TRACK_PLAYER_ONLY = false    -- When true, only tracks player cooldowns

-- Important spell categories
Timeline.SpellCategories = {
    ["OFFENSIVE"] = {
        color = {r = 0.8, g = 0.1, b = 0.1},
        spells = {
            -- Death Knight
            [47568] = true,  -- Empower Rune Weapon
            -- Demon Hunter 
            [191427] = true, -- Metamorphosis (Havoc)
            -- Druid
            [194223] = true, -- Celestial Alignment
            -- Hunter
            [193530] = true, -- Aspect of the Wild
            -- Mage
            [12472] = true,  -- Icy Veins
            [190319] = true, -- Combustion
            -- Monk
            [137639] = true, -- Storm, Earth, and Fire
            -- Paladin 
            [31884] = true,  -- Avenging Wrath
            -- Priest
            [10060] = true,  -- Power Infusion
            -- Rogue
            [13750] = true,  -- Adrenaline Rush
            -- Shaman
            [114051] = true, -- Ascendance
            -- Warlock
            [113858] = true, -- Dark Soul: Instability
            -- Warrior
            [107574] = true, -- Avatar
        }
    },
    ["DEFENSIVE"] = {
        color = {r = 0.1, g = 0.1, b = 0.8},
        spells = {
            -- Death Knight
            [48707] = true,  -- Anti-Magic Shell
            [48792] = true,  -- Icebound Fortitude
            -- Demon Hunter
            [198589] = true, -- Blur
            -- Druid
            [22812] = true,  -- Barkskin
            -- Hunter
            [186265] = true, -- Aspect of the Turtle
            -- Mage
            [45438] = true,  -- Ice Block
            -- Monk
            [115203] = true, -- Fortifying Brew
            -- Paladin
            [642] = true,    -- Divine Shield
            -- Priest
            [47585] = true,  -- Dispersion
            -- Rogue
            [31224] = true,  -- Cloak of Shadows
            -- Shaman
            [108271] = true, -- Astral Shift
            -- Warlock
            [104773] = true, -- Unending Resolve
            -- Warrior
            [871] = true,    -- Shield Wall
        }
    },
    ["HEALING"] = {
        color = {r = 0.1, g = 0.8, b = 0.1},
        spells = {
            -- Death Knight
            [51052] = true,  -- Anti-Magic Zone
            -- Demon Hunter
            [196718] = true, -- Darkness
            -- Druid
            [740] = true,    -- Tranquility
            [33891] = true,  -- Incarnation: Tree of Life
            -- Hunter
            [90361] = true,  -- Spirit Mend
            -- Mage
            [80353] = true,  -- Time Warp
            -- Monk
            [115310] = true, -- Revival
            -- Paladin
            [31821] = true,  -- Aura Mastery
            [633] = true,    -- Lay on Hands
            -- Priest
            [64843] = true,  -- Divine Hymn
            [47788] = true,  -- Guardian Spirit
            [62618] = true,  -- Power Word: Barrier
            -- Rogue
            -- None
            -- Shaman
            [98008] = true,  -- Spirit Link Totem
            [108280] = true, -- Healing Tide Totem
            -- Warlock
            -- None
            -- Warrior
            [97462] = true,  -- Rallying Cry
        }
    },
    ["UTILITY"] = {
        color = {r = 0.8, g = 0.8, b = 0.1},
        spells = {
            -- Death Knight
            -- None
            -- Demon Hunter
            [198589] = true, -- Blur
            -- Druid
            [29166] = true,  -- Innervate
            [106898] = true, -- Stampeding Roar
            -- Hunter
            [109248] = true, -- Binding Shot
            -- Mage
            [108839] = true, -- Ice Floes
            -- Monk
            [119381] = true, -- Leg Sweep
            -- Paladin
            [1022] = true,   -- Blessing of Protection
            [6940] = true,   -- Blessing of Sacrifice
            -- Priest
            [73325] = true,  -- Leap of Faith
            -- Rogue
            [1856] = true,   -- Vanish
            -- Shaman
            [2825] = true,   -- Bloodlust
            -- Warlock
            [20707] = true,  -- Soulstone
            -- Warrior
            [97462] = true,  -- Rallying Cry
        }
    },
}

-- Initialize
function Timeline:OnInitialize()
    -- Initialize variables
    self.combatActive = false
    self.combatStartTime = 0
    self.eventHistory = {}
    self.playerInCombat = false
    
    -- Register with main module
    CT.RaidTimeline = self
end

-- Enable module
function Timeline:OnEnable()
    -- Create timeline frame
    self:CreateTimelineFrame()
    
    -- Register events
    self:RegisterEvent("PLAYER_REGEN_DISABLED")
    self:RegisterEvent("PLAYER_REGEN_ENABLED")
    self:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
    self:RegisterEvent("GROUP_ROSTER_UPDATE")
    self:RegisterEvent("ENCOUNTER_START")
    self:RegisterEvent("ENCOUNTER_END")
    
    -- Set up update timer
    self.updateTimer = C_Timer.NewTicker(UPDATE_INTERVAL, function() 
        self:UpdateTimeline()
    end)
    
    -- Initial update
    self:UpdateDisplay()
end

-- Disable module
function Timeline:OnDisable()
    -- Cancel timers
    if self.updateTimer then
        self.updateTimer:Cancel()
        self.updateTimer = nil
    end
    
    -- Unregister events
    self:UnregisterAllEvents()
    
    -- Hide frame
    if self.frame then
        self.frame:Hide()
    end
end

-- Create the timeline frame
function Timeline:CreateTimelineFrame()
    if self.frame then return self.frame end
    
    -- Get settings
    local settings = self:GetSettings()
    local width = settings.width or DEFAULT_WIDTH
    local height = settings.height or DEFAULT_HEIGHT
    
    -- Create main frame
    local frame = CreateFrame("Frame", "Phoenix_RaidTimeline_Frame", UIParent)
    frame:SetSize(width, height)
    frame:SetPoint("CENTER", UIParent, "CENTER", 0, 0)
    frame:SetFrameStrata("MEDIUM")
    frame:SetFrameLevel(100)
    frame:EnableMouse(true)
    frame:SetMovable(true)
    frame:RegisterForDrag("LeftButton")
    frame:SetScript("OnDragStart", frame.StartMoving)
    frame:SetScript("OnDragStop", frame.StopMovingOrSizing)
    
    -- Add background
    frame.bg = frame:CreateTexture(nil, "BACKGROUND")
    frame.bg:SetAllPoints()
    frame.bg:SetColorTexture(0.1, 0.1, 0.1, 0.8)
    
    -- Add border
    frame.border = CreateFrame("Frame", nil, frame)
    frame.border:SetAllPoints()
    frame.border:SetBackdrop({
        edgeFile = "Interface\\DialogFrame\\UI-DialogBox-Border",
        edgeSize = 16,
        insets = { left = 4, right = 4, top = 4, bottom = 4 },
    })
    
    -- Add title
    frame.title = frame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    frame.title:SetPoint("TOP", 0, -10)
    frame.title:SetText("Raid Timeline")
    
    -- Add combat timer
    frame.timer = frame:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
    frame.timer:SetPoint("TOPRIGHT", -10, -10)
    frame.timer:SetText("00:00")
    
    -- Create the timeline area
    frame.timeline = CreateFrame("Frame", nil, frame)
    frame.timeline:SetPoint("TOPLEFT", 10, -30)
    frame.timeline:SetPoint("BOTTOMRIGHT", -10, 10)
    
    -- Time markers
    frame.markers = {}
    
    -- Container for events
    frame.events = {}
    
    -- Control buttons
    -- Reset button
    frame.resetButton = CreateFrame("Button", nil, frame, "UIPanelButtonTemplate")
    frame.resetButton:SetSize(60, 20)
    frame.resetButton:SetPoint("BOTTOMLEFT", 10, 10)
    frame.resetButton:SetText("Reset")
    frame.resetButton:SetScript("OnClick", function()
        self:ResetTimeline()
    end)
    
    -- Close button
    frame.closeButton = CreateFrame("Button", nil, frame, "UIPanelCloseButton")
    frame.closeButton:SetPoint("TOPRIGHT", 0, 0)
    
    -- Apply position from settings if available
    if settings.position then
        local pos = settings.position
        frame:ClearAllPoints()
        frame:SetPoint(pos.point or "CENTER", UIParent, pos.relativePoint or "CENTER", pos.xOffset or 0, pos.yOffset or 0)
    end
    
    -- Initially hide the frame
    frame:Hide()
    
    -- Store frame reference
    self.frame = frame
    
    return frame
end

-- Reset the timeline
function Timeline:ResetTimeline()
    wipe(self.eventHistory)
    self.combatStartTime = GetTime()
    self:UpdateDisplay()
end

-- Handle entering combat
function Timeline:PLAYER_REGEN_DISABLED()
    self.playerInCombat = true
    
    -- Check if we should start tracking
    if not self.combatActive then
        self.combatActive = true
        self.combatStartTime = GetTime()
        wipe(self.eventHistory)
        
        -- Show frame
        if self.frame then
            self.frame:Show()
        end
        
        -- Add combat start marker
        self:AddEvent("COMBAT_START", "SYSTEM", 0, "Combat Start")
    end
    
    self:UpdateDisplay()
end

-- Handle leaving combat
function Timeline:PLAYER_REGEN_ENABLED()
    self.playerInCombat = false
    
    -- Add combat end marker if we were in combat
    if self.combatActive then
        local duration = GetTime() - self.combatStartTime
        self:AddEvent("COMBAT_END", "SYSTEM", duration, "Combat End")
    end
    
    self:UpdateDisplay()
end

-- Handle combat log events
function Timeline:COMBAT_LOG_EVENT_UNFILTERED()
    if not self.combatActive then return end
    
    local timestamp, event, _, sourceGUID, sourceName, sourceFlags, _, _, targetName, _, _, spellID, spellName = CombatLogGetCurrentEventInfo()
    
    -- Check for ability usage
    if event == "SPELL_CAST_SUCCESS" then
        -- Determine if this source is in our group
        local isPlayer = (sourceGUID == UnitGUID("player"))
        local isPartyMember = false
        
        if not isPlayer and IsInGroup() then
            for i = 1, GetNumGroupMembers() do
                local unit = IsInRaid() and "raid"..i or "party"..i
                if UnitExists(unit) and UnitGUID(unit) == sourceGUID then
                    isPartyMember = true
                    break
                end
            end
        end
        
        -- Skip if not in our group (unless it's a relevant NPC)
        if not isPlayer and not isPartyMember and bit.band(sourceFlags, COMBATLOG_OBJECT_TYPE_NPC) == 0 then
            return
        end
        
        -- Check categories
        local category = self:GetSpellCategory(spellID)
        if category then
            local duration = GetTime() - self.combatStartTime
            self:AddEvent(spellID, sourceName, duration, spellName, category)
        end
    end
end

-- Handle encounter start
function Timeline:ENCOUNTER_START(event, encounterID, encounterName, difficultyID, groupSize)
    -- Start tracking if not already
    if not self.combatActive then
        self.combatActive = true
        self.combatStartTime = GetTime()
        wipe(self.eventHistory)
        
        -- Show frame
        if self.frame then
            self.frame:Show()
        end
    end
    
    -- Add encounter start marker
    self:AddEvent("ENCOUNTER_START", "SYSTEM", 0, encounterName)
    
    self:UpdateDisplay()
end

-- Handle encounter end
function Timeline:ENCOUNTER_END(event, encounterID, encounterName, difficultyID, groupSize, success)
    -- Add encounter end marker
    local duration = GetTime() - self.combatStartTime
    local result = success == 1 and "Victory" or "Wipe"
    self:AddEvent("ENCOUNTER_END", "SYSTEM", duration, encounterName .. " - " .. result)
    
    self:UpdateDisplay()
end

-- Add an event to the timeline
function Timeline:AddEvent(spellID, source, time, spellName, category)
    -- Create event entry
    local event = {
        id = spellID,
        source = source,
        time = time,
        name = spellName,
        category = category or "OTHER"
    }
    
    -- Add to history
    table.insert(self.eventHistory, event)
    
    -- Limit history size
    while #self.eventHistory > 100 do
        table.remove(self.eventHistory, 1)
    end
    
    -- Update display
    self:UpdateDisplay()
end

-- Update timeline display
function Timeline:UpdateDisplay()
    if not self.frame then return end
    
    local frame = self.frame
    local settings = self:GetSettings()
    
    -- Hide if disabled
    if not settings.enabled then
        frame:Hide()
        return
    end
    
    -- Show if in combat
    if self.combatActive then
        frame:Show()
    end
    
    -- Update size based on settings
    local width = settings.width or DEFAULT_WIDTH
    local height = settings.height or DEFAULT_HEIGHT
    
    -- Apply frame size from settings
    frame:SetSize(width, height)
    
    -- Clear existing events
    for _, eventFrame in ipairs(frame.events) do
        eventFrame:Hide()
    end
    
    -- Update combat timer
    local currentTime = GetTime()
    local elapsed = currentTime - self.combatStartTime
    local minutes = math.floor(elapsed / 60)
    local seconds = math.floor(elapsed % 60)
    frame.timer:SetText(string.format("%02d:%02d", minutes, seconds))
    
    -- Calculate timeline scale
    local timelineWidth = frame.timeline:GetWidth()
    local maxTime = math.max(elapsed, settings.minDisplayTime or 60)
    local pixelsPerSecond = timelineWidth / maxTime
    
    -- Update time markers
    self:UpdateTimeMarkers(maxTime, pixelsPerSecond)
    
    -- Display events
    self:DisplayEvents(pixelsPerSecond, maxTime)
end

-- Update time markers
function Timeline:UpdateTimeMarkers(maxTime, pixelsPerSecond)
    local frame = self.frame
    local timelineHeight = frame.timeline:GetHeight()
    
    -- Clear existing markers
    for _, marker in ipairs(frame.markers) do
        marker:Hide()
    end
    
    -- Create markers every TIME_MARKERS_INTERVAL seconds
    local interval = TIME_MARKERS_INTERVAL
    for i = 0, math.floor(maxTime / interval) do
        local time = i * interval
        local xPos = time * pixelsPerSecond
        
        -- Create or reuse marker
        local marker = frame.markers[i+1]
        if not marker then
            marker = frame.timeline:CreateTexture(nil, "ARTWORK")
            marker:SetColorTexture(0.5, 0.5, 0.5, 0.5)
            marker:SetWidth(1)
            frame.markers[i+1] = marker
            
            -- Add time text
            local text = frame.timeline:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
            text:SetPoint("BOTTOM", marker, "TOP", 0, 2)
            marker.text = text
        end
        
        -- Position marker
        marker:SetPoint("TOPLEFT", frame.timeline, "TOPLEFT", xPos, 0)
        marker:SetPoint("BOTTOMLEFT", frame.timeline, "BOTTOMLEFT", xPos, 0)
        marker:SetHeight(timelineHeight)
        marker:Show()
        
        -- Update time text
        local minutes = math.floor(time / 60)
        local seconds = math.floor(time % 60)
        marker.text:SetText(string.format("%d:%02d", minutes, seconds))
        marker.text:Show()
    end
end

-- Display events on timeline
function Timeline:DisplayEvents(pixelsPerSecond, maxTime)
    local frame = self.frame
    local timelineHeight = frame.timeline:GetHeight()
    local laneHeight = 20 -- Height of each "lane" for events
    local maxLanes = math.floor(timelineHeight / laneHeight)
    
    -- Sort events if needed (they should already be in chronological order)
    table.sort(self.eventHistory, function(a, b) return a.time < b.time end)
    
    -- Track used lanes
    local lanes = {}
    for i = 1, maxLanes do
        lanes[i] = 0 -- Time until this lane is free
    end
    
    -- Display each event
    for i, event in ipairs(self.eventHistory) do
        -- Skip events beyond our current view
        if event.time > maxTime then
            break
        end
        
        -- Calculate position
        local xPos = event.time * pixelsPerSecond
        
        -- Find an available lane
        local laneIndex = 1
        for j = 1, maxLanes do
            if lanes[j] <= event.time then
                laneIndex = j
                break
            end
        end
        
        -- Set a default occupation time
        lanes[laneIndex] = event.time + 10 -- Occupy lane for 10 seconds
        
        -- Create or reuse event marker
        local eventFrame = frame.events[i]
        if not eventFrame then
            eventFrame = CreateFrame("Frame", nil, frame.timeline)
            eventFrame:SetSize(20, laneHeight - 2)
            
            -- Icon
            eventFrame.icon = eventFrame:CreateTexture(nil, "ARTWORK")
            eventFrame.icon:SetAllPoints()
            
            -- Border based on category
            eventFrame.border = eventFrame:CreateTexture(nil, "OVERLAY")
            eventFrame.border:SetPoint("TOPLEFT", -1, 1)
            eventFrame.border:SetPoint("BOTTOMRIGHT", 1, -1)
            
            -- Tooltip
            eventFrame:SetScript("OnEnter", function(self)
                GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
                GameTooltip:SetText(self.eventName or "Unknown Event")
                GameTooltip:AddLine(self.sourceName or "Unknown Source", 1, 1, 1)
                local minutes = math.floor(self.eventTime / 60)
                local seconds = math.floor(self.eventTime % 60)
                GameTooltip:AddLine(string.format("Time: %d:%02d", minutes, seconds), 0.8, 0.8, 0.8)
                GameTooltip:Show()
            end)
            eventFrame:SetScript("OnLeave", function()
                GameTooltip:Hide()
            end)
            
            frame.events[i] = eventFrame
        end
        
        -- Calculate vertical position based on lane
        local yPos = -((laneIndex - 1) * laneHeight + 1)
        
        -- Set position
        eventFrame:ClearAllPoints()
        eventFrame:SetPoint("TOPLEFT", frame.timeline, "TOPLEFT", xPos, yPos)
        
        -- Set event data
        eventFrame.eventID = event.id
        eventFrame.eventName = event.name
        eventFrame.sourceName = event.source
        eventFrame.eventTime = event.time
        eventFrame.category = event.category
        
        -- Set icon
        if type(event.id) == "number" then
            -- Spell ID
            local _, _, icon = GetSpellInfo(event.id)
            eventFrame.icon:SetTexture(icon or "Interface\\Icons\\INV_Misc_QuestionMark")
        else
            -- System event
            if event.id == "COMBAT_START" or event.id == "ENCOUNTER_START" then
                eventFrame.icon:SetTexture("Interface\\Icons\\Ability_Warrior_OffensiveStance")
            elseif event.id == "COMBAT_END" or event.id == "ENCOUNTER_END" then
                eventFrame.icon:SetTexture("Interface\\Icons\\Ability_Rogue_Feint")
            else
                eventFrame.icon:SetTexture("Interface\\Icons\\INV_Misc_QuestionMark")
            end
        end
        
        -- Set border color based on category
        local categoryInfo = self.SpellCategories[event.category]
        if categoryInfo and categoryInfo.color then
            eventFrame.border:SetColorTexture(categoryInfo.color.r, categoryInfo.color.g, categoryInfo.color.b, 0.8)
        else
            eventFrame.border:SetColorTexture(0.5, 0.5, 0.5, 0.8)
        end
        
        eventFrame:Show()
    end
    
    -- Hide unused event frames
    for i = #self.eventHistory + 1, #frame.events do
        frame.events[i]:Hide()
    end
end

-- Update timeline data
function Timeline:UpdateTimeline()
    -- Only update when in combat
    if not self.combatActive then return end
    
    -- Update display
    self:UpdateDisplay()
    
    -- Check for combat timeout
    if not self.playerInCombat and GetTime() - self.combatStartTime > 60 then
        -- End combat tracking after 1 minute of no combat
        self.combatActive = false
    end
end

-- Get the category for a spell
function Timeline:GetSpellCategory(spellID)
    for category, info in pairs(self.SpellCategories) do
        if info.spells[spellID] then
            return category
        end
    end
    return nil
end

-- Get settings
function Timeline:GetSettings()
    -- Get the main module settings
    local options = CT:GetCurrentOptions()
    if not options then
        return {
            enabled = true,
            width = DEFAULT_WIDTH,
            height = DEFAULT_HEIGHT,
            minDisplayTime = 60,
            showLegend = true,
            trackPlayerOnly = TRACK_PLAYER_ONLY,
            initialValue = {
                width = DEFAULT_WIDTH,
                height = DEFAULT_HEIGHT,
                minDisplayTime = 60
            }
        }
    end
    
    -- If timeline settings don't exist, create them with defaults
    if not options.timeline then
        options.timeline = {
            enabled = true,
            width = DEFAULT_WIDTH,
            height = DEFAULT_HEIGHT,
            minDisplayTime = 60,
            showLegend = true,
            trackPlayerOnly = TRACK_PLAYER_ONLY,
            initialValue = {
                width = DEFAULT_WIDTH,
                height = DEFAULT_HEIGHT,
                minDisplayTime = 60
            }
        }
    end
    
    -- Ensure initial values are set
    if not options.timeline.initialValue then
        options.timeline.initialValue = {
            width = DEFAULT_WIDTH,
            height = DEFAULT_HEIGHT,
            minDisplayTime = 60
        }
    end
    
    -- Ensure required properties have values (use initial values if available)
    if not options.timeline.width then
        options.timeline.width = options.timeline.initialValue.width or DEFAULT_WIDTH
    end
    
    if not options.timeline.height then
        options.timeline.height = options.timeline.initialValue.height or DEFAULT_HEIGHT
    end
    
    if not options.timeline.minDisplayTime then
        options.timeline.minDisplayTime = options.timeline.initialValue.minDisplayTime or 60
    end
    
    -- Return timeline specific settings
    return options.timeline
end

-- Update settings
function Timeline:UpdateSettings()
    local settings = self:GetSettings()
    
    -- Toggle module based on settings
    if settings.enabled and not self:IsEnabled() then
        self:Enable()
    elseif not settings.enabled and self:IsEnabled() then
        self:Disable()
    end
    
    -- Update display
    if self:IsEnabled() then
        self:UpdateDisplay()
    end
end

-- Register with parent module
CT.RaidTimeline = Timeline

function CT:InitializeRaidTimeline()
    if not Timeline or not Timeline.IsEnabled or not CT.db.profile.timeline.enabled then return end
    
    Timeline:OnInitialize()
    Timeline:OnEnable()
end

-- Add command to toggle the timeline
CT:RegisterChatCommand("cdtimeline", function()
    if not Timeline or not Timeline.IsEnabled then
        CT:Print("RaidTimeline module is not loaded.")
        return
    end
    
    local db = CT.db.profile.timeline
    db.enabled = not db.enabled
    
    if db.enabled then
        CT:Print("RaidTimeline enabled.")
        Timeline:OnEnable()
    else
        CT:Print("RaidTimeline disabled.")
        Timeline:OnDisable()
    end
end)

-- Initialize the timeline when entering combat
CT:RegisterCallback("EnteringCombat", function()
    if not Timeline or not Timeline.IsEnabled or not CT.db.profile.timeline.enabled then return end
    
    Timeline:OnCombatStart()
end)

-- Clean up when leaving combat
CT:RegisterCallback("LeavingCombat", function()
    if not Timeline or not Timeline.IsEnabled or not CT.db.profile.timeline.enabled then return end
    
    Timeline:OnCombatEnd()
end)

-- Update when config changes
CT:RegisterCallback("ConfigChanged", function()
    if not Timeline or not Timeline.IsEnabled or not CT.db.profile.timeline.enabled then return end
    
    Timeline:UpdateFrameSize()
    Timeline:UpdatePosition()
    
    if CT.db.profile.timeline.showLegend and not Timeline.legend then
        Timeline:CreateLegend()
    elseif not CT.db.profile.timeline.showLegend and Timeline.legend then
        Timeline.legend:Hide()
    end
end) 