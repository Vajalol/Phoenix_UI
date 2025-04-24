-- Phoenix_UI: KeystoneInfo Submodule
-- Enhances keystone links in chat and provides better information display

local addonName, Phoenix = ...
local MythicPlus = Phoenix.Modules.MythicPlus
local KeystoneInfo = MythicPlus:NewModule("KeystoneInfo", "AceHook-3.0")
local L = MythicPlus.L

-- Constants
local CHALLENGE_MODE_ITEM_BONUS_ID = 7 -- Used to identify keystones in item links
local KEYSTONE_PATTERN = "keystone:(%d+):(%d+):([^:|]+)" -- Pattern to extract info from keystone links
local KEYSTONE_CHAT_ICON = "|TInterface\\Icons\\INV_Relics_Hourglass:14:14:0:0|t"

-- Cache for dungeon information to avoid repeated API calls
local dungeonInfoCache = {}

-- Get information about a dungeon from a keystone link
local function GetDungeonInfo(itemLink)
    if not itemLink or not itemLink:find("keystone") then
        return nil
    end
    
    -- Extract dungeon ID, key level, and affixes from the item link
    local dungeonID, keyLevel = itemLink:match(KEYSTONE_PATTERN)
    
    if not dungeonID or not keyLevel then
        return nil
    end
    
    dungeonID = tonumber(dungeonID)
    keyLevel = tonumber(keyLevel)
    
    -- Check cache first
    local cacheKey = dungeonID .. ":" .. keyLevel
    if dungeonInfoCache[cacheKey] then
        return dungeonInfoCache[cacheKey]
    end
    
    -- Get dungeon name
    local dungeonName = C_ChallengeMode.GetMapUIInfo(dungeonID)
    if not dungeonName then
        return nil
    end
    
    -- Get affix information for this key level
    local affixIDs = C_MythicPlus.GetCurrentAffixes() or {}
    local affixNames = {}
    
    -- Key level 2-9 has first affix
    -- Key level 7+ has second affix
    -- Key level 10+ has third affix
    -- Key level 14+ has fourth (seasonal) affix
    
    for i, affixInfo in ipairs(affixIDs) do
        if (i == 1 and keyLevel >= 2) or
           (i == 2 and keyLevel >= 7) or
           (i == 3 and keyLevel >= 10) or
           (i == 4 and keyLevel >= 14) then
            local name = C_ChallengeMode.GetAffixInfo(affixInfo.id)
            if name then
                table.insert(affixNames, name)
            end
        end
    end
    
    -- Create and cache the dungeon info
    local info = {
        dungeonID = dungeonID,
        dungeonName = dungeonName,
        keyLevel = keyLevel,
        affixNames = affixNames
    }
    
    dungeonInfoCache[cacheKey] = info
    return info
end

-- Format a keystone link for display in chat
local function FormatKeystoneLink(itemLink)
    local info = GetDungeonInfo(itemLink)
    if not info then
        return itemLink
    end
    
    -- Color the key level based on its difficulty
    local levelColor
    if info.keyLevel >= 20 then
        levelColor = "ff8000" -- Orange
    elseif info.keyLevel >= 15 then
        levelColor = "a335ee" -- Epic
    elseif info.keyLevel >= 10 then
        levelColor = "0070dd" -- Rare
    elseif info.keyLevel >= 5 then
        levelColor = "1eff00" -- Uncommon
    else
        levelColor = "ffffff" -- Common
    end
    
    -- Format the affix information
    local affixString = ""
    if #info.affixNames > 0 then
        affixString = " (" .. table.concat(info.affixNames, ", ") .. ")"
    end
    
    -- Create the formatted link
    local formattedLink = KEYSTONE_CHAT_ICON .. " " .. 
                          info.dungeonName .. " +" .. 
                          "|cff" .. levelColor .. info.keyLevel .. "|r" .. 
                          affixString
    
    return formattedLink
end

-- Process chat messages to enhance keystone links
local function ProcessChatMessage(self, event, message, ...)
    if not message or message == "" then
        return false
    end
    
    -- Check if the message contains a keystone link
    if not message:find("keystone:") then
        return false
    end
    
    -- Replace keystone links with formatted versions
    local modified = false
    message = message:gsub("(|c%x+|Hkeystone:[^|]+|h.-|h|r)", function(link)
        modified = true
        return FormatKeystoneLink(link)
    end)
    
    if modified then
        return false, message, ...
    else
        return false
    end
end

-- Hook into chat message display functions
local function HookChatFunctions()
    -- Hook into the chat frame message events
    for i = 1, NUM_CHAT_WINDOWS do
        local frame = _G["ChatFrame" .. i]
        if frame then
            KeystoneInfo:RawHook(frame, "AddMessage", function(self, message, ...)
                if message and type(message) == "string" and message:find("keystone:") then
                    message = message:gsub("(|c%x+|Hkeystone:[^|]+|h.-|h|r)", FormatKeystoneLink)
                end
                return KeystoneInfo.hooks[self].AddMessage(self, message, ...)
            end, true)
        end
    end
    
    -- Hook item tooltips to show enhanced keystone information
    KeystoneInfo:HookTooltip()
end

-- Hook tooltip to show enhanced keystone information
function KeystoneInfo:HookTooltip()
    self:SecureHook("GameTooltip_OnTooltipSetItem", function(tooltip)
        local name, link = tooltip:GetItem()
        if not link or not link:find("keystone:") then
            return
        end
        
        local info = GetDungeonInfo(link)
        if not info then
            return
        end
        
        -- Add time limit information if available
        local timeLimit = C_ChallengeMode.GetMapTimeLimit(info.dungeonID) or 0
        if timeLimit > 0 then
            tooltip:AddLine(" ")
            tooltip:AddLine("|cffFFD100" .. L["Time Limit"] .. ":|r " .. MythicPlus:FormatTime(timeLimit / 1000))
        end
        
        -- Add affix information
        if #info.affixNames > 0 then
            tooltip:AddLine(" ")
            tooltip:AddLine("|cffFFD100" .. L["Affixes"] .. ":|r")
            for i, affixName in ipairs(info.affixNames) do
                tooltip:AddLine("  • " .. affixName)
            end
        end
        
        tooltip:Show()
    end)
end

-- Initialize the submodule
function KeystoneInfo:OnInitialize()
    -- Initialize the cache
    dungeonInfoCache = {}
    
    -- Cache all dungeon maps
    local maps = C_ChallengeMode.GetMapTable()
    for _, mapID in ipairs(maps) do
        C_ChallengeMode.GetMapUIInfo(mapID)
    end
    
    -- Hook chat functions
    HookChatFunctions()
    
    -- Register events
    MythicPlus:RegisterMessage("PHOENIX_MYTHICPLUS_START", function()
        -- Clear the cache when a new Mythic+ run starts
        dungeonInfoCache = {}
    end)
end

-- Update settings
function KeystoneInfo:UpdateSettings()
    if MythicPlus.db.keystoneLink then
        self:Enable()
    else
        self:Disable()
    end
end

-- When enabled
function KeystoneInfo:OnEnable()
    -- Hook chat functions if not already hooked
    HookChatFunctions()
end

-- When disabled
function KeystoneInfo:OnDisable()
    -- Unhook chat functions
    self:UnhookAll()
end 