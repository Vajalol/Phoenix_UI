-- SpellNotifications Module for Phoenix_UI
-- Adapted from jobackman/SpellNotifications
-- Original author: Veev

-- Create the addon namespace
local SpellNotifications = {}
_G.SpellNotifications = SpellNotifications

-- Define local variables
local frame = CreateFrame("Frame")
local MissTypes = {
    ABSORB = true,
    BLOCK = true,
    DEFLECT = true,
    DODGE = true,
    EVADE = true,
    IMMUNE = true,
    MISS = true,
    PARRY = true,
    REFLECT = true,
    RESIST = true
}

-- Main initialization function
function SpellNotifications:Initialize()
    -- Only initialize if enabled
    if not Phoenix_UI or not Phoenix_UI.db or not Phoenix_UI.db.profile or not Phoenix_UI.db.profile.general or not Phoenix_UI.db.profile.general.spellNotifications then
        return
    end
    
    -- Set up event handling
    frame:SetScript("OnEvent", function(self, event, ...)
        if event == "COMBAT_LOG_EVENT_UNFILTERED" then
            SpellNotifications:ProcessCombatLog(CombatLogGetCurrentEventInfo())
        elseif event == "UNIT_DIED" or event == "UNIT_DESTROYED" or event == "UNIT_DISSIPATES" then
            SpellNotifications:CheckPetDeath(...)
        end
    end)
    
    -- Register events
    frame:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
    frame:RegisterEvent("UNIT_DIED")
    frame:RegisterEvent("UNIT_DESTROYED")
    frame:RegisterEvent("UNIT_DISSIPATES")
    
    -- Register error events
    self:RegisterErrorEvents()
    
    -- Print initialization message if debug is enabled
    if Phoenix_UI.debug then
        print("|cFFFFD100SpellNotifications:|r Initialized")
    end
end

-- Print formatted message to the chat frame
function SpellNotifications:print(msg)
    -- Only print if SpellNotifications is enabled
    if not Phoenix_UI or not Phoenix_UI.db or not Phoenix_UI.db.profile or not Phoenix_UI.db.profile.general or not Phoenix_UI.db.profile.general.spellNotifications then
        return
    end
    
    if msg then
        DEFAULT_CHAT_FRAME:AddMessage("|cFFFF7D0ASpellNotifications:|r " .. msg)
    end
end

-- Process combat log events
function SpellNotifications:ProcessCombatLog(...)
    local timestamp, event, _, sourceGUID, sourceName, sourceFlags, sourceRaidFlags, destGUID, destName, destFlags, destRaidFlags = ...
    
    -- Skip if disabled
    if not Phoenix_UI or not Phoenix_UI.db or not Phoenix_UI.db.profile or not Phoenix_UI.db.profile.general or not Phoenix_UI.db.profile.general.spellNotifications then
        return
    end
    
    if event == "SPELL_DISPEL" then
        self:HandleDispel(sourceGUID, sourceName, destGUID, destName, select(13, ...))
    elseif event == "SPELL_STOLEN" then
        self:HandleStolen(sourceGUID, sourceName, destGUID, destName, select(13, ...))
    elseif event == "SPELL_INTERRUPT" then
        self:HandleInterrupt(sourceGUID, sourceName, destGUID, destName, select(13, ...))
    elseif event == "SPELL_MISSED" then
        self:HandleMissed(sourceGUID, sourceName, destGUID, destName, select(12, ...), select(15, ...))
    end
end

-- Handle dispel events
function SpellNotifications:HandleDispel(sourceGUID, sourceName, destGUID, destName, spellID, spellName, spellSchool, extraSpellID, extraSpellName, extraSchool, auraType)
    -- Skip if we should ignore this event
    if self:ShouldIgnoreEvent(sourceGUID, destGUID) then return end
    
    local color = self.colors.DISPELLED
    local msg = format("|c%s%s|r %s from %s", color, extraSpellName, auraType, destName)
    self:print(msg)
end

-- Handle stolen events (e.g. Spellsteal)
function SpellNotifications:HandleStolen(sourceGUID, sourceName, destGUID, destName, spellID, spellName, spellSchool, extraSpellID, extraSpellName, extraSchool, auraType)
    -- Skip if we should ignore this event
    if self:ShouldIgnoreEvent(sourceGUID, destGUID) then return end
    
    local color = self.colors.STOLEN
    local msg = format("|c%s%s|r %s from %s", color, extraSpellName, auraType, destName)
    self:print(msg)
end

-- Handle interrupt events
function SpellNotifications:HandleInterrupt(sourceGUID, sourceName, destGUID, destName, spellID, spellName, spellSchool, extraSpellID, extraSpellName, extraSchool)
    -- Skip if we should ignore this event
    if self:ShouldIgnoreEvent(sourceGUID, destGUID) then return end
    
    -- Get the spell school text
    local schoolText = self.spellSchools[extraSchool] or "Unknown"
    
    local color = self.colors.INTERRUPTED
    local msg = format("|c%s%s|r (%s) interrupted on %s", color, extraSpellName, schoolText, destName)
    self:print(msg)
end

-- Handle missed spell events
function SpellNotifications:HandleMissed(sourceGUID, sourceName, destGUID, destName, spellID, missType)
    -- If the destination is the player, ignore it
    local playerGUID = UnitGUID("player")
    if destGUID == playerGUID then return end
    
    -- Only process events that originate from the player
    if sourceGUID ~= playerGUID then return end
    
    -- Check if the missType is one we care about
    if not MissTypes[missType] then return end
    
    -- Reflect is handled separately
    if missType == "REFLECT" then
        local msg = format("|cFFFF2020REFLECTED|r %s", destName)
        self:print(msg)
    end
end

-- Check if the pet has died
function SpellNotifications:CheckPetDeath(...)
    -- Skip if disabled
    if not Phoenix_UI or not Phoenix_UI.db or not Phoenix_UI.db.profile or not Phoenix_UI.db.profile.general or not Phoenix_UI.db.profile.general.spellNotifications then
        return
    end
    
    local unitToken = ...
    if not unitToken then return end
    
    local unitGUID = select(6, strsplit("-", UnitGUID(unitToken)))
    
    -- If it's the player's pet that died
    if unitToken == "pet" then
        local msg = self:GetLocalizedString("PETDIED")
        self:print("|cFFFF2020" .. msg .. "|r")
        SpellNotifications_PlayPetDeathSound()
    end
end

-- Initialize the addon when Phoenix_UI is ready
function SpellNotifications:OnEnable()
    -- Delay initialization until Phoenix_UI is fully loaded
    C_Timer.After(1, function()
        SpellNotifications:Initialize()
    end)
end

-- Return the module
local _, addon = ...
addon.SpellNotifications = SpellNotifications 