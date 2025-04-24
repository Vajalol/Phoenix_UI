local Module = Phoenix_UI:NewModule("Chat.RoleIcons");

function Module:OnEnable()
    local db = Phoenix_UI.db.profile.chat
    -- Default to enabled if not explicitly set
    if db.roleicons == nil then db.roleicons = true end
    
    -- Initialize class icons settings if not present
    if not db.classIcons then
        db.classIcons = {
            enabled = true,
            position = "before" -- Can be "before" or "after"
        }
    end
    
    -- Cache role icons for faster lookup
    local roleIconTextures = {
        TANK = "|TInterface\\LFGFrame\\UI-LFG-ICON-PORTRAITROLES:14:14:0:0:64:64:0:19:22:41|t",
        HEALER = "|TInterface\\LFGFrame\\UI-LFG-ICON-PORTRAITROLES:14:14:0:0:64:64:20:39:1:20|t",
        DAMAGER = "|TInterface\\LFGFrame\\UI-LFG-ICON-PORTRAITROLES:14:14:0:0:64:64:20:39:22:41|t",
        NONE = ""
    }
    
    -- Cache class icons
    local classIconSize = 14
    local classIcons = {
        WARRIOR = "|TInterface\\ICONS\\ClassIcon_Warrior:"..classIconSize..":"..classIconSize..":0:0|t",
        PALADIN = "|TInterface\\ICONS\\ClassIcon_Paladin:"..classIconSize..":"..classIconSize..":0:0|t",
        HUNTER = "|TInterface\\ICONS\\ClassIcon_Hunter:"..classIconSize..":"..classIconSize..":0:0|t",
        ROGUE = "|TInterface\\ICONS\\ClassIcon_Rogue:"..classIconSize..":"..classIconSize..":0:0|t",
        PRIEST = "|TInterface\\ICONS\\ClassIcon_Priest:"..classIconSize..":"..classIconSize..":0:0|t",
        DEATHKNIGHT = "|TInterface\\ICONS\\ClassIcon_DeathKnight:"..classIconSize..":"..classIconSize..":0:0|t",
        SHAMAN = "|TInterface\\ICONS\\ClassIcon_Shaman:"..classIconSize..":"..classIconSize..":0:0|t",
        MAGE = "|TInterface\\ICONS\\ClassIcon_Mage:"..classIconSize..":"..classIconSize..":0:0|t",
        WARLOCK = "|TInterface\\ICONS\\ClassIcon_Warlock:"..classIconSize..":"..classIconSize..":0:0|t",
        MONK = "|TInterface\\ICONS\\ClassIcon_Monk:"..classIconSize..":"..classIconSize..":0:0|t",
        DRUID = "|TInterface\\ICONS\\ClassIcon_Druid:"..classIconSize..":"..classIconSize..":0:0|t",
        DEMONHUNTER = "|TInterface\\ICONS\\ClassIcon_DemonHunter:"..classIconSize..":"..classIconSize..":0:0|t",
        EVOKER = "|TInterface\\ICONS\\ClassIcon_Evoker:"..classIconSize..":"..classIconSize..":0:0|t"
    }
    
    -- Add spec icons if enabled
    if db.classSpec and db.classSpec.enabled then
        -- Cache to store player spec information
        local playerSpecCache = {}
        
        -- Get the texture path for a class specialization icon
        local function GetSpecIconTextureByID(specID)
            if not specID or specID == 0 then return nil end
            
            local _, _, _, icon = GetSpecializationInfoByID(specID)
            if icon then
                return string.format("|T%s:14:14:0:0:64:64:5:59:5:59|t", icon)
            end
            return nil
        end
        
        -- Map class name to class color
        local classColors = {}
        for className, color in pairs(RAID_CLASS_COLORS) do
            classColors[className] = string.format("|cff%02x%02x%02x", color.r * 255, color.g * 255, color.b * 255)
        end
        
        -- Function to update player spec information from inspection
        local inspectFrame = CreateFrame("Frame")
        inspectFrame:RegisterEvent("INSPECT_READY")
        inspectFrame:SetScript("OnEvent", function(self, event, guid)
            if event == "INSPECT_READY" and guid then
                local currentSpec = GetInspectSpecialization(guid)
                if currentSpec and currentSpec > 0 then
                    -- Store the spec in our cache
                    playerSpecCache[guid] = currentSpec
                    
                    -- Clear inspect frame
                    ClearInspectPlayer()
                end
            end
        end)
        
        -- Function to get a player's spec icon
        local function GetPlayerSpecIcon(name, realm)
            if not name then return nil end
            
            local fullName = realm and realm ~= "" and name.."-"..realm or name
            local playerUnit = nil
            
            -- Try to find the player in group
            if UnitExists("player") and UnitName("player") == name then
                playerUnit = "player"
            elseif IsInGroup() then
                local groupSize = IsInRaid() and GetNumGroupMembers() or GetNumSubgroupMembers()
                local groupPrefix = IsInRaid() and "raid" or "party"
                
                for i = 1, groupSize do
                    local unit = groupPrefix..i
                    if UnitExists(unit) and UnitName(unit) == name then
                        playerUnit = unit
                        break
                    end
                end
            end
            
            -- If we found the unit, try to get their spec
            if playerUnit then
                local guid = UnitGUID(playerUnit)
                if guid then
                    -- Check if we have cached spec info
                    if playerSpecCache[guid] then
                        return GetSpecIconTextureByID(playerSpecCache[guid])
                    else
                        -- Try to get current spec from unit
                        local currentSpec = GetInspectSpecialization(playerUnit)
                        if currentSpec and currentSpec > 0 then
                            playerSpecCache[guid] = currentSpec
                            return GetSpecIconTextureByID(currentSpec)
                        else
                            -- Not available, queue an inspection
                            NotifyInspect(playerUnit)
                        end
                    end
                end
            end
            
            return nil
        end
        
        -- Function to get class color and icon for a name
        local function GetClassInfo(name, realm)
            if not name then return nil, nil end
            
            local fullName = realm and realm ~= "" and name.."-"..realm or name
            local _, unitClass = nil, nil
            
            -- Try to find the player's class
            if UnitExists("player") and UnitName("player") == name then
                _, unitClass = UnitClass("player")
            elseif IsInGroup() then
                local groupSize = IsInRaid() and GetNumGroupMembers() or GetNumSubgroupMembers()
                local groupPrefix = IsInRaid() and "raid" or "party"
                
                for i = 1, groupSize do
                    local unit = groupPrefix..i
                    if UnitExists(unit) and UnitName(unit) == name then
                        _, unitClass = UnitClass(unit)
                        break
                    end
                end
            end
            
            -- Return class color and icon if found
            if unitClass then
                return classColors[unitClass] or nil, classIcons[unitClass] or nil
            end
            
            return nil, nil
        end
        
        -- Function to colorize and add class/spec icons to player names
        local function AddClassSpecInfo(_, _, message, ...)
            if not message or type(message) ~= "string" then
                return false, message, ...
            end
            
            local ChatUtils = Phoenix_UI:GetModule("Chat.Utils")
            
            -- Use the centralized message processor to check for complex messages
            if ChatUtils then
                local shouldSkip, processedMessage = ChatUtils:ProcessChatMessage(_, _, message, ...)
                if shouldSkip then
                    return shouldSkip, processedMessage, ...
                end
            else
                -- Fallback to direct check if module not available
                -- Skip processing for certain messages that might break with our modifications
                if message:find("Professions%-ChatlIcon%-Quality%-Tier") or
                   message:find("|c%x+|Hitem:") or 
                   message:find("|T.*:.*|t") or 
                   message:find("%[.*%]") then
                    return false, message, ...
                end
            end
            
            -- Process messages with player links that don't already have icons
            message = message:gsub("|Hplayer:(.-)|h%[([^%|].-)]|h", function(playerLink, playerName)
                -- Don't modify if it already has a texture
                if playerName:find("|T") then
                    return "|Hplayer:" .. playerLink .. "|h[" .. playerName .. "]|h"
                end
                
                local name, realm = strsplit("-", playerLink)
                if name then
                    local modifiedName = playerName
                    local classColor, classIcon = GetClassInfo(name, realm)
                    local specIcon = db.classSpec.showIcons and GetPlayerSpecIcon(name, realm) or ""
                    
                    -- Apply class coloring if available
                    if classColor then
                        modifiedName = string.format("%s%s|r", classColor, playerName)
                    end
                    
                    -- Combine icons based on settings
                    local iconPrefix = ""
                    local iconSuffix = ""
                    
                    -- Add class icon if enabled
                    if db.classIcons and db.classIcons.enabled and classIcon then
                        if db.classIcons.position == "before" then
                            iconPrefix = classIcon .. iconPrefix
                        else
                            iconSuffix = iconSuffix .. classIcon
                        end
                    end
                    
                    -- Add spec icon if available
                    if specIcon and specIcon ~= "" then
                        iconPrefix = iconPrefix .. specIcon
                    end
                    
                    -- Return the modified player link
                    return string.format("|Hplayer:%s|h[%s%s%s]|h", 
                        playerLink, 
                        iconPrefix, 
                        modifiedName,
                        iconSuffix)
                end
                return "|Hplayer:" .. playerLink .. "|h[" .. playerName .. "]|h"
            end)
            
            return false, message, ...
        end
        
        -- Add the filter to chat messages with player names
        for _, event in pairs({
            "CHAT_MSG_SAY", "CHAT_MSG_YELL", "CHAT_MSG_WHISPER", "CHAT_MSG_WHISPER_INFORM",
            "CHAT_MSG_GUILD", "CHAT_MSG_OFFICER", "CHAT_MSG_PARTY", "CHAT_MSG_PARTY_LEADER",
            "CHAT_MSG_RAID", "CHAT_MSG_RAID_LEADER", "CHAT_MSG_RAID_WARNING", 
            "CHAT_MSG_INSTANCE_CHAT", "CHAT_MSG_INSTANCE_CHAT_LEADER", "CHAT_MSG_BN_WHISPER",
            "CHAT_MSG_BN_WHISPER_INFORM", "CHAT_MSG_CHANNEL", "CHAT_MSG_BN_CONVERSATION"
        }) do
            ChatFrame_AddMessageEventFilter(event, AddClassSpecInfo)
        end
    end
    
    -- Add role icons if enabled
    if db.roleicons then
        -- Function to get role from player cache or group info
        local roleCache = {}
        local function GetPlayerRole(name, realm)
            local fullName = realm and realm ~= "" and name.."-"..realm or name
            
            -- Check cache first
            if roleCache[fullName] then
                return roleCache[fullName]
            end
            
            -- Try to get role from raid/party
            local role = "NONE"
            local isInGroup = IsInGroup() or IsInRaid()
            
            if isInGroup then
                -- Check if player is in our group
                local groupSize = IsInRaid() and GetNumGroupMembers() or GetNumSubgroupMembers()
                for i = 1, groupSize do
                    local groupType = IsInRaid() and "raid" or "party"
                    if i == 1 and groupType == "party" then
                        -- Check player role if we're checking party unit 1
                        if UnitName("player") == name then
                            role = UnitGroupRolesAssigned("player")
                            break
                        end
                    else
                        local unit = groupType..i
                        local unitName, unitRealm = UnitName(unit)
                        if unitName and (unitName == name) and (not realm or not unitRealm or unitRealm == realm) then
                            role = UnitGroupRolesAssigned(unit)
                            break
                        end
                    end
                end
            end
            
            -- Cache the result
            roleCache[fullName] = role
            return role
        end
        
        -- Clear role cache when group composition changes
        local eventFrame = CreateFrame("Frame")
        eventFrame:RegisterEvent("GROUP_ROSTER_UPDATE")
        eventFrame:RegisterEvent("PLAYER_ENTERING_WORLD")
        eventFrame:SetScript("OnEvent", function()
            wipe(roleCache)
        end)
        
        -- We need to work with the existing AddMessage hook in _Core.lua
        -- Instead of adding our own hook, we'll use a chat filter to add role icons
        local function AddRoleIcons(_, _, message, ...)
            if not message or type(message) ~= "string" then
                return false, message, ...
            end
            
            local ChatUtils = Phoenix_UI:GetModule("Chat.Utils")
            
            -- Use the centralized message processor to check for complex messages
            if ChatUtils then
                local shouldSkip, processedMessage = ChatUtils:ProcessChatMessage(_, _, message, ...)
                if shouldSkip then
                    return shouldSkip, processedMessage, ...
                end
            end
            
            -- This only processes messages with player links that don't already have role icons
            message = message:gsub("|Hplayer:(.-)|h%[([^%|].-)]|h", function(playerLink, playerName)
                -- Don't modify if it already has a texture
                if playerName:find("|T") then
                    return "|Hplayer:" .. playerLink .. "|h[" .. playerName .. "]|h"
                end
                
                local name, realm = strsplit("-", playerLink)
                if name then
                    local role = GetPlayerRole(name, realm)
                    local roleIcon = roleIconTextures[role] or ""
                    
                    -- Only add the role icon if there is one
                    if roleIcon ~= "" then
                        return string.format("|Hplayer:%s|h[%s%s%s]|h", 
                            playerLink, 
                            roleIcon, 
                            playerName,
                            "")
                    end
                end
                return "|Hplayer:" .. playerLink .. "|h[" .. playerName .. "]|h"
            end)
            
            return false, message, ...
        end
        
        -- Add a message filter for all chat types
        for _, event in pairs({
            "CHAT_MSG_SAY", "CHAT_MSG_YELL", "CHAT_MSG_WHISPER", "CHAT_MSG_WHISPER_INFORM",
            "CHAT_MSG_GUILD", "CHAT_MSG_OFFICER", "CHAT_MSG_PARTY", "CHAT_MSG_PARTY_LEADER",
            "CHAT_MSG_RAID", "CHAT_MSG_RAID_LEADER", "CHAT_MSG_RAID_WARNING",
            "CHAT_MSG_INSTANCE_CHAT", "CHAT_MSG_INSTANCE_CHAT_LEADER", "CHAT_MSG_BN_WHISPER",
            "CHAT_MSG_BN_WHISPER_INFORM", "CHAT_MSG_CHANNEL", "CHAT_MSG_BN_CONVERSATION"
        }) do
            ChatFrame_AddMessageEventFilter(event, AddRoleIcons)
        end
    end
end 