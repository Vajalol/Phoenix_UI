-- Phoenix_UI: Mythic+ Module
-- Provides enhanced features for Mythic+ dungeons

local addonName, Phoenix = ...
local L = Phoenix.L

-- Create the module
local MythicPlus = Phoenix:NewModule("MythicPlus", "AceEvent-3.0", "AceHook-3.0", "AceConsole-3.0")
MythicPlus.L = L

-- Default settings
local defaults = {
    profile = {
        enabled = true,
        showTimer = true,
        showObjectives = true,
        trackProgress = true,
        deathPenalty = true,
        enhanceKeystones = true,
        lockTimerFrame = false,
        lockObjectiveFrame = false,
        timerPosition = nil,
        objectivePosition = nil,
    }
}

-- Local variables
local inMythicPlus = false
local currentKeystone = {
    level = 0,
    mapID = 0,
    name = "",
    affixes = {},
}

-- Event handlers
local function OnChallengeStart()
    inMythicPlus = true
    
    -- Get timer information
    local _, _, timeLimit = C_ChallengeMode.GetActiveKeystoneInfo()
    timeLimit = timeLimit or 1800 -- Default to 30 minutes if not available
    
    -- Fire event for submodules
    MythicPlus:SendMessage("PHOENIX_MYTHICPLUS_START", timeLimit)
end

local function OnChallengeEnd(success)
    inMythicPlus = false
    
    -- Fire event for submodules
    MythicPlus:SendMessage("PHOENIX_MYTHICPLUS_COMPLETE", success)
end

local function OnPlayerEnteringWorld()
    -- Check if we're in a M+ dungeon
    local inChallenge = C_ChallengeMode.IsChallengeModeActive()
    
    if inChallenge and not inMythicPlus then
        -- We joined a M+ in progress
        OnChallengeStart()
    elseif not inChallenge and inMythicPlus then
        -- We left a M+ without completing
        OnChallengeEnd(false)
    end
end

-- Detect the current keystone
local function UpdateCurrentKeystone()
    -- Check the backpack for a keystone
    for bag = 0, NUM_BAG_SLOTS do
        for slot = 1, C_Container.GetContainerNumSlots(bag) do
            local itemID = C_Container.GetContainerItemID(bag, slot)
            if itemID and itemID == 180653 then  -- Keystone item ID
                local itemLink = C_Container.GetContainerItemLink(bag, slot)
                if itemLink then
                    -- Parse the link to get keystone details
                    local mapID, level, affix1, affix2, affix3, affix4 = string.match(itemLink, "|Hkeystone:(%d+):(%d+):(%d+):(%d+):(%d+):(%d+)|h")
                    
                    if mapID then
                        mapID = tonumber(mapID)
                        level = tonumber(level)
                        
                        -- Get dungeon name
                        local name = C_ChallengeMode.GetMapUIInfo(mapID) or ""
                        
                        -- Get affix info
                        local affixes = {}
                        local affixIDs = {affix1, affix2, affix3, affix4}
                        
                        for _, affixID in ipairs(affixIDs) do
                            if affixID and tonumber(affixID) > 0 then
                                local affixName, affixDesc, affixFileid = C_ChallengeMode.GetAffixInfo(tonumber(affixID))
                                if affixName then
                                    table.insert(affixes, {
                                        id = tonumber(affixID),
                                        name = affixName,
                                        description = affixDesc,
                                        icon = affixFileid
                                    })
                                end
                            end
                        end
                        
                        -- Update current keystone data
                        currentKeystone.level = level
                        currentKeystone.mapID = mapID
                        currentKeystone.name = name
                        currentKeystone.affixes = affixes
                        
                        -- Notify submodules
                        MythicPlus:SendMessage("PHOENIX_MYTHICPLUS_KEYSTONE_UPDATED", currentKeystone)
                        return
                    end
                end
            end
        end
    end
    
    -- No keystone found
    currentKeystone.level = 0
    currentKeystone.mapID = 0
    currentKeystone.name = ""
    currentKeystone.affixes = {}
    
    -- Notify submodules
    MythicPlus:SendMessage("PHOENIX_MYTHICPLUS_KEYSTONE_UPDATED", currentKeystone)
end

-- Module initialization
function MythicPlus:OnInitialize()
    -- Register database
    self.db = Phoenix.db:RegisterNamespace("MythicPlus", defaults)
    
    -- Register chat commands
    self:RegisterChatCommand("keystoneinfo", function() self:ShowKeystoneInfo() end)
    self:RegisterChatCommand("resetmplus", function() self:ResetMythicPlus() end)
    
    -- Set up initial state
    inMythicPlus = C_ChallengeMode.IsChallengeModeActive()
end

function MythicPlus:OnEnable()
    -- Register events
    self:RegisterEvent("CHALLENGE_MODE_START", OnChallengeStart)
    self:RegisterEvent("CHALLENGE_MODE_COMPLETED", function() OnChallengeEnd(true) end)
    self:RegisterEvent("CHALLENGE_MODE_RESET", function() OnChallengeEnd(false) end)
    self:RegisterEvent("PLAYER_ENTERING_WORLD", OnPlayerEnteringWorld)
    self:RegisterEvent("BAG_UPDATE", UpdateCurrentKeystone)
    
    -- Update current keystone on enable
    UpdateCurrentKeystone()
    
    -- Notify submodules
    self:SendMessage("PHOENIX_MYTHICPLUS_ENABLED")
end

function MythicPlus:OnDisable()
    -- Unregister events
    self:UnregisterEvent("CHALLENGE_MODE_START")
    self:UnregisterEvent("CHALLENGE_MODE_COMPLETED")
    self:UnregisterEvent("CHALLENGE_MODE_RESET")
    self:UnregisterEvent("PLAYER_ENTERING_WORLD")
    self:UnregisterEvent("BAG_UPDATE")
    
    -- Reset the state
    inMythicPlus = false
    
    -- Notify submodules
    self:SendMessage("PHOENIX_MYTHICPLUS_DISABLED")
end

-- Reset Mythic+ data and UI
function MythicPlus:ResetMythicPlus()
    if inMythicPlus then
        self:Print(L["Cannot reset while in Mythic+"])
        return
    end
    
    -- Send reset message
    self:SendMessage("PHOENIX_MYTHICPLUS_RESET")
    self:Print(L["Mythic+ data reset"])
end

-- Display current keystone info
function MythicPlus:ShowKeystoneInfo()
    if currentKeystone.level > 0 then
        self:Print(string.format(L["Current Keystone: %s (%d)"], currentKeystone.name, currentKeystone.level))
        
        if #currentKeystone.affixes > 0 then
            local affixText = ""
            for i, affix in ipairs(currentKeystone.affixes) do
                if i > 1 then
                    affixText = affixText .. ", "
                end
                affixText = affixText .. affix.name
            end
            self:Print(L["Affixes: "] .. affixText)
        end
    else
        self:Print(L["No keystone found"])
    end
end

-- Provide API for other modules
function MythicPlus:GetCurrentKeystone()
    return currentKeystone
end

function MythicPlus:IsInMythicPlus()
    return inMythicPlus
end

Phoenix.Modules.MythicPlus = MythicPlus 