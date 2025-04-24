-- Phoenix_UI: AutoGossip Submodule for Mythic+
-- Automatically handles gossip options in Mythic+ dungeons and Court of Stars clues

local addonName, Phoenix = ...
local MythicPlus = Phoenix.Modules.MythicPlus
local AutoGossip = MythicPlus:NewModule("AutoGossip", "AceEvent-3.0", "AceHook-3.0")
local L = MythicPlus.L

-- Court of Stars NPC and clue data
local CoS_NPCS = {
    [107486] = true, -- Chatty Rumormonger
    [107468] = true, -- Suspicious Noble
    [107965] = true, -- Watchful Inquisitor
    [108406] = true, -- Arcanist Malrodi
    [107435] = true, -- Guardian Sentry
    [107697] = true  -- Duskwatch Guard
}

-- Court of Stars clue mapping
local CoS_CLUES = {
    -- Clue text to suspect feature mappings
    ["no battle wounds"] = L["no battle wounds"],
    ["scar across eye"] = L["scar across eye"],
    ["a ring bearing"] = L["a ring bearing"],
    ["elaborate rings"] = L["elaborate rings"],
    ["colorful gems"] = L["colorful gems"],
    ["pocket watch"] = L["pocket watch"],
    ["silver medallion"] = L["silver medallion"],
    ["weapon concealed"] = L["weapon concealed"],
    ["carries a walking cane"] = L["carries a walking cane"],
    ["dagger concealed"] = L["dagger concealed"],
    ["metallic staff"] = L["metallic staff"],
    ["deadly blades"] = L["deadly blades"]
}

-- Commonly skipped gossip options during M+
local SKIP_GOSSIP = {
    -- NPC ID to gossip ID mappings for auto-selection
    -- Tirathon Saltheril (Black Rook Hold)
    [94960] = 1,
    
    -- Reanimation Totem (Black Rook Hold)
    [98542] = 1,
    
    -- The Tarragrue (Torghast)
    [152253] = 1,
    
    -- Millificent Manastorm (De Other Side)
    [164556] = 1,
    
    -- Zo'phex (Tazavesh)
    [175646] = 1,
    
    -- So'azmi (Tazavesh)
    [177269] = 1,
    
    -- Mueh'zala (De Other Side)
    [166608] = 1,
    
    -- Odyn (Halls of Valor)
    [95676] = 1,
    
    -- Harlan Sweete (Freehold)
    [126983] = 1
}

-- Auto-completion gossip options for specific NPCs
local COMPLETION_GOSSIP = {
    -- These are standard NPCs that appear at the end of dungeons
    -- Chieftain Hatuun (Seat of the Triumvirate)
    [126213] = 1,
    
    -- Mythrax (Uldir)
    [134546] = 1,
    
    -- Dazar (Kings' Rest)
    [136160] = 1
}

-- Icons for clue display
local CLUE_ICON = "Interface\\Icons\\Spell_Fire_FelFireNova" -- Phoenix-themed icon
local PHOENIX_ICON = "Interface\\Icons\\Ability_Mount_FireHawk" -- Phoenix-themed icon for general messages

-- Local variables
local lastClue = nil
local isInCoS = false
local isRunning = false

-- Check if we're in Court of Stars
local function CheckForCoS()
    if C_Map.GetBestMapForUnit("player") == 1571 then -- Court of Stars map ID
        if not isInCoS then
            isInCoS = true
            AutoGossip:Debug("Entered Court of Stars")
        end
        return true
    else
        if isInCoS then
            isInCoS = false
            AutoGossip:Debug("Left Court of Stars")
        end
        return false
    end
end

-- Debug function
function AutoGossip:Debug(message)
    if Phoenix_UI and Phoenix_UI.Debug then
        Phoenix_UI:Debug("AutoGossip", message)
    end
end

-- Process gossip text for Court of Stars clues
local function ProcessGossipText(text)
    if not text or not isInCoS or not MythicPlus.db.showClues then return end
    
    text = text:lower()
    local foundClue = nil
    
    -- Check for clues in the text
    for clueText, localizedClue in pairs(CoS_CLUES) do
        if text:find(clueText) then
            foundClue = localizedClue
            break
        end
    end
    
    -- If we found a clue and it's different from the last one
    if foundClue and foundClue ~= lastClue then
        lastClue = foundClue
        
        -- Announce the clue to the party
        if IsInGroup() then
            SendChatMessage("|TInterface\\Icons\\Spell_Fire_FelFireNova:14:14:0:0|t " .. L["COURT_CLUE"] .. ": " .. foundClue, "PARTY")
        end
        
        -- Show it to the player
        if Phoenix_UI and Phoenix_UI.ShowNotification then
            Phoenix_UI:ShowNotification(L["COURT_CLUE"], foundClue, CLUE_ICON, 5)
        else
            print("|T" .. CLUE_ICON .. ":14:14:0:0|t " .. L["COURT_CLUE"] .. ": " .. foundClue)
        end
        
        AutoGossip:Debug("Found clue: " .. foundClue)
        return true
    end
    
    return false
end

-- Auto-select gossip options when enabled
local function AutoSelectGossip(skipGossip)
    if not MythicPlus.db.autoGossip or not C_ChallengeMode.IsChallengeModeActive() then return end
    
    local npcID = AutoGossip:GetNPCID()
    
    -- Check for specific gossip options to select automatically
    if skipGossip and npcID and SKIP_GOSSIP[npcID] then
        local optionID = SKIP_GOSSIP[npcID]
        if optionID and C_GossipInfo.GetNumOptions() >= optionID then
            C_GossipInfo.SelectOption(optionID)
            AutoGossip:Debug("Auto-selected gossip option " .. optionID .. " for NPC " .. npcID)
            return true
        end
    end
    
    -- Check for completion gossip (end of dungeon)
    if npcID and COMPLETION_GOSSIP[npcID] then
        local optionID = COMPLETION_GOSSIP[npcID]
        if optionID and C_GossipInfo.GetNumOptions() >= optionID then
            C_GossipInfo.SelectOption(optionID)
            AutoGossip:Debug("Auto-selected completion gossip option " .. optionID .. " for NPC " .. npcID)
            return true
        end
    end
    
    return false
end

-- Get the current NPC's ID
function AutoGossip:GetNPCID()
    local guid = UnitGUID("target") or UnitGUID("npc")
    if not guid then return nil end
    
    local type, _, _, _, _, npcID = strsplit("-", guid)
    if type == "Creature" then
        return tonumber(npcID)
    end
    
    return nil
end

-- Hook into gossip functions
function AutoGossip:HookGossipFunctions()
    -- Hook into gossip show event
    self:RegisterEvent("GOSSIP_SHOW", function()
        -- Check if we're in Court of Stars
        CheckForCoS()
        
        -- Process gossip text for clues
        local npcID = self:GetNPCID()
        if isInCoS and npcID and CoS_NPCS[npcID] then
            local gossipText = C_GossipInfo.GetText()
            ProcessGossipText(gossipText)
        end
        
        -- Auto-select gossip if enabled
        AutoSelectGossip(true)
    end)
    
    -- Hook into gossip closed event
    self:RegisterEvent("GOSSIP_CLOSED", function()
        -- Nothing special needed here yet
    end)
    
    -- Hook for NPC with quest indicator but actually gossip
    self:RegisterEvent("QUEST_GREETING", function()
        -- Auto-select first option if appropriate
        AutoSelectGossip(false)
    end)
    
    self:Debug("Gossip functions hooked")
end

-- Initialize the module
function AutoGossip:OnInitialize()
    -- Check current location
    CheckForCoS()
    
    -- Hook gossip functions
    self:HookGossipFunctions()
    
    -- Register messages from MythicPlus module
    MythicPlus:RegisterMessage("PHOENIX_MYTHICPLUS_START", function()
        isRunning = true
        self:Debug("Mythic+ started, auto-gossip active")
    end)
    
    MythicPlus:RegisterMessage("PHOENIX_MYTHICPLUS_COMPLETE", function()
        isRunning = false
        self:Debug("Mythic+ completed, auto-gossip deactivated")
    end)
    
    -- Reset when entering a new zone
    self:RegisterEvent("ZONE_CHANGED_NEW_AREA", function()
        CheckForCoS()
        lastClue = nil
    end)
    
    self:Debug("AutoGossip module initialized")
end

-- Update settings
function AutoGossip:UpdateSettings()
    if MythicPlus.db.autoGossip then
        self:Enable()
    else
        self:Disable()
    end
end

-- Enable the module
function AutoGossip:OnEnable()
    self:Debug("AutoGossip module enabled")
    
    -- Re-hook functions to ensure they're active
    self:HookGossipFunctions()
    
    -- Check current location
    CheckForCoS()
end

-- Disable the module
function AutoGossip:OnDisable()
    self:Debug("AutoGossip module disabled")
    
    -- We don't unhook events, just ignore them based on the module's enabled state
    isRunning = false
end 