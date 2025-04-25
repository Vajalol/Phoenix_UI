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
        showEnemyTooltip = true,
        progressFormat = "PERCENTAGE_AND_VALUE",
        showSeasonNotification = true,
        integrateWithPhoenix = true, -- Add Mythic+ tab to Phoenix UI main panel
        timerFormat = "REMAINING", -- Format for the timer display (REMAINING, ELAPSED, or DUAL)
        enhancedTimer = true,
        timerStyle = "PHOENIX",
        showChestTimers = true,
        dungeons = {
            -- The War Within Season 2 dungeons
            [2516] = true, -- Operation: Floodgate
            [2451] = true, -- Cinderbrew Meadery
            [2579] = true, -- Darkflame Cleft
            [2520] = true, -- The Rookery
            [2337] = true, -- Priory of the Sacred Flame
            [1683] = true, -- Theater of Pain
            [2097] = true, -- Operation: Mechagon - Workshop
            [1594] = true, -- The MOTHERLODE!!
        }
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

-- Update settings for all submodules
function MythicPlus:UpdateSettings()
    -- Notify all submodules about settings changes
    self:SendMessage("PHOENIX_MYTHICPLUS_SETTINGS_UPDATED")
    
    -- Update enemy forces database and settings
    if self:GetModule("Objectives") then
        self:GetModule("Objectives"):ReloadEnemyForcesDB()
    end
end

-- Export enemy forces database to clipboard
function MythicPlus:ExportEnemyForces()
    local Objectives = self:GetModule("Objectives")
    if not Objectives then return end

    local forcesData = Objectives:GetEnemyForcesData()
    local exportString = LibStub("LibSerialize"):Serialize(forcesData)
    local compressed = LibStub("LibCompress"):CompressHuffman(exportString)
    local encoded = LibStub("LibBase64-1.0"):Encode(compressed)
    
    -- Create a frame for copying
    local f = CreateFrame("Frame", "PhoenixUIExportFrame", UIParent, "BackdropTemplate")
    f:SetSize(500, 300)
    f:SetPoint("CENTER")
    f:SetBackdrop({
        bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background",
        edgeFile = "Interface\\DialogFrame\\UI-DialogBox-Border",
        tile = true, tileSize = 32, edgeSize = 32,
        insets = { left = 11, right = 12, top = 12, bottom = 11 }
    })
    f:SetBackdropColor(0, 0, 0, 1)
    
    local header = f:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    header:SetPoint("TOP", 0, -20)
    header:SetText(L["TWW_EXPORT_ENEMY_FORCES"] or "Export Enemy Forces")
    
    local instructions = f:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
    instructions:SetPoint("TOP", header, "BOTTOM", 0, -10)
    instructions:SetText(L["TWW_EXPORT_INSTRUCTIONS"] or "Copy the text below to share your enemy forces data:")
    
    local editBox = CreateFrame("EditBox", nil, f, "InputBoxTemplate")
    editBox:SetSize(450, 200)
    editBox:SetPoint("TOP", instructions, "BOTTOM", 0, -10)
    editBox:SetAutoFocus(true)
    editBox:SetMultiLine(true)
    editBox:SetText(encoded)
    editBox:HighlightText()
    
    local closeButton = CreateFrame("Button", nil, f, "UIPanelButtonTemplate")
    closeButton:SetSize(80, 22)
    closeButton:SetPoint("BOTTOM", 0, 15)
    closeButton:SetText(CLOSE)
    closeButton:SetScript("OnClick", function() f:Hide() end)
    
    f:Show()
    
    self:Print(L["TWW_EXPORT_SUCCESS"])
end

-- Import enemy forces database from clipboard
function MythicPlus:ImportEnemyForces()
    local Objectives = self:GetModule("Objectives")
    if not Objectives then return end

    -- Create a frame for pasting
    local f = CreateFrame("Frame", "PhoenixUIImportFrame", UIParent, "BackdropTemplate")
    f:SetSize(500, 300)
    f:SetPoint("CENTER")
    f:SetBackdrop({
        bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background",
        edgeFile = "Interface\\DialogFrame\\UI-DialogBox-Border",
        tile = true, tileSize = 32, edgeSize = 32,
        insets = { left = 11, right = 12, top = 12, bottom = 11 }
    })
    f:SetBackdropColor(0, 0, 0, 1)
    
    local header = f:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    header:SetPoint("TOP", 0, -20)
    header:SetText(L["TWW_IMPORT_ENEMY_FORCES"] or "Import Enemy Forces")
    
    local instructions = f:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
    instructions:SetPoint("TOP", header, "BOTTOM", 0, -10)
    instructions:SetText(L["TWW_IMPORT_INSTRUCTIONS"] or "Paste exported enemy forces data below:")
    
    local editBox = CreateFrame("EditBox", nil, f, "InputBoxTemplate")
    editBox:SetSize(450, 200)
    editBox:SetPoint("TOP", instructions, "BOTTOM", 0, -10)
    editBox:SetAutoFocus(true)
    editBox:SetMultiLine(true)
    
    local importButton = CreateFrame("Button", nil, f, "UIPanelButtonTemplate")
    importButton:SetSize(80, 22)
    importButton:SetPoint("BOTTOMLEFT", 100, 15)
    importButton:SetText(L["TWW_IMPORT"])
    importButton:SetScript("OnClick", function()
        local encoded = editBox:GetText()
        if encoded and encoded ~= "" then
            local decoded = LibStub("LibBase64-1.0"):Decode(encoded)
            local decompressed = LibStub("LibCompress"):DecompressHuffman(decoded)
            local success, forcesData = LibStub("LibSerialize"):Deserialize(decompressed)
            
            if success and forcesData then
                Objectives:SetEnemyForcesData(forcesData)
                self:Print(L["TWW_IMPORT_SUCCESS"])
                f:Hide()
            else
                self:Print(L["TWW_IMPORT_FAILED"])
            end
        end
    end)
    
    local cancelButton = CreateFrame("Button", nil, f, "UIPanelButtonTemplate")
    cancelButton:SetSize(80, 22)
    cancelButton:SetPoint("BOTTOMRIGHT", -100, 15)
    cancelButton:SetText(CANCEL)
    cancelButton:SetScript("OnClick", function() f:Hide() end)
    
    f:Show()
end

-- Reset enemy forces database to default values
function MythicPlus:ResetEnemyForces()
    local Objectives = self:GetModule("Objectives")
    if not Objectives then return end
    
    Objectives:ResetEnemyForcesData()
    self:Print(L["TWW_RESET_SUCCESS"])
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

function MythicPlus:ShouldEnableOptions()
    -- This will be used to determine if options should be enabled (true) or disabled (false)
    -- But we'll always show the options regardless of this return value
    return inMythicPlus or (currentKeystone and currentKeystone.level > 0)
end

Phoenix.Modules.MythicPlus = MythicPlus 