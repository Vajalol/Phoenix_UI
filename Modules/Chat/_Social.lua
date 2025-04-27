local Module = Phoenix_UI:NewModule("Chat.Social");

-- Create a local reference to the database outside the OnEnable function
local db = {
    social = {
        enabled = false,
        enhancedStatuses = false,
        guildRanks = false,
        friendNotes = false,
        inlineTooltips = false
    }
}

function Module:OnEnable()
    -- Get the actual database from the profile
    db = Phoenix_UI.db.profile.chat
    
    -- Completely disable all social integration features
    if not db.social then
        db.social = {
            enabled = false,
            enhancedStatuses = false,
            guildRanks = false,
            friendNotes = false,
            inlineTooltips = false
        }
    else
        -- Explicitly disable all social features
        db.social.enabled = false
        db.social.enhancedStatuses = false
        db.social.guildRanks = false
        db.social.friendNotes = false
        db.social.inlineTooltips = false
    end
    
    -- Exit immediately - all functionality is disabled
    return
end  -- End of OnEnable function

-- Friend status cache for quick lookups
local friendCache = {}
local guildCache = {}

-- Status icons with colors
local statusIcons = {
    online = "|TInterface\\FriendsFrame\\StatusIcon-Online:14:14:0:0|t",
    offline = "|TInterface\\FriendsFrame\\StatusIcon-Offline:14:14:0:0|t",
    dnd = "|TInterface\\FriendsFrame\\StatusIcon-DND:14:14:0:0|t",
    away = "|TInterface\\FriendsFrame\\StatusIcon-Away:14:14:0:0|t"
}

-- Function to get clean player name without realm
local function GetCleanName(fullName)
    if not fullName then return nil end
    return string.gsub(fullName, "%-[^|]+", "")
end

-- Function to check if a player is a friend
local function IsFriend(name)
    if not name then return false end
    
    -- Clean name to handle realm issues
    local cleanName = GetCleanName(name)
    
    -- Check our cache first
    if friendCache[cleanName] ~= nil then
        return friendCache[cleanName].isFriend, friendCache[cleanName]
    end
    
    -- Check if they're on friends list
    local numFriends = C_FriendList.GetNumFriends()
    for i = 1, numFriends do
        local friendInfo = C_FriendList.GetFriendInfoByIndex(i)
        if friendInfo and GetCleanName(friendInfo.name) == cleanName then
            -- Cache the result
            friendCache[cleanName] = {
                isFriend = true,
                status = friendInfo.status,
                note = friendInfo.notes or "",
                level = friendInfo.level,
                class = friendInfo.className
            }
            return true, friendCache[cleanName]
        end
    end
    
    -- Check BNet friends
    local numBNetFriends = BNGetNumFriends()
    for i = 1, numBNetFriends do
        local accountInfo = C_BattleNet.GetFriendAccountInfo(i)
        if accountInfo and accountInfo.gameAccountInfo then
            -- Handle direct access to gameAccountInfo for newer API versions
            local gameInfo = accountInfo.gameAccountInfo
            if type(gameInfo) == "table" then
                if gameInfo.characterName == cleanName then
                    -- Cache the result
                    friendCache[cleanName] = {
                        isFriend = true,
                        isBNet = true,
                        status = gameInfo.isOnline and "online" or "offline",
                        note = accountInfo.note or "",
                        level = gameInfo.characterLevel,
                        class = gameInfo.className
                    }
                    return true, friendCache[cleanName]
                end
            end
            
            -- Handle older API versions where gameAccountInfo might be a table of tables
            if type(accountInfo.gameAccountInfo) == "table" then
                for k, gameAcctInfo in pairs(accountInfo.gameAccountInfo) do
                    -- Skip non-table values or wowProjectID field
                    if type(gameAcctInfo) == "table" and gameAcctInfo.characterName then
                        if gameAcctInfo.characterName == cleanName then
                            -- Cache the result
                            friendCache[cleanName] = {
                                isFriend = true,
                                isBNet = true,
                                status = gameAcctInfo.isOnline and "online" or "offline",
                                note = accountInfo.note or "",
                                level = gameAcctInfo.characterLevel,
                                class = gameAcctInfo.className
                            }
                            return true, friendCache[cleanName]
                        end
                    end
                end
            end
        end
    end
    
    -- Not a friend, cache the negative result too
    friendCache[cleanName] = { isFriend = false }
    return false, nil
end

-- Function to check if a player is in your guild
local function IsGuildMember(name)
    if not name then return false end
    
    -- Clean name to handle realm issues
    local cleanName = GetCleanName(name)
    
    -- Check our cache first
    if guildCache[cleanName] ~= nil then
        return guildCache[cleanName].inGuild, guildCache[cleanName]
    end
    
    -- Check guild roster
    local numGuildMembers = GetNumGuildMembers()
    for i = 1, numGuildMembers do
        local fullName, rank, rankIndex, level, _, _, _, _, online, _, class = GetGuildRosterInfo(i)
        if GetCleanName(fullName) == cleanName then
            -- Cache the result
            guildCache[cleanName] = {
                inGuild = true,
                rank = rank,
                rankIndex = rankIndex,
                level = level,
                class = class,
                online = online
            }
            return true, guildCache[cleanName]
        end
    end
    
    -- Not in guild, cache the negative result too
    guildCache[cleanName] = { inGuild = false }
    return false, nil
end

-- Function to get enhanced status info for players
local function GetEnhancedStatus(name)
    if not name or not db.social.enhancedStatuses then return nil end
    
    -- Check if player name already has guild/friend tags
    if name:find("%[G:") or name:find("%[Friend") then
        -- Already has tags, don't add more
        return nil
    end
    
    -- Clean the name to ensure consistent matching
    local cleanName = GetCleanName(name)
    
    -- Check if friend
    local isFriend, friendInfo = IsFriend(cleanName)
    if isFriend and friendInfo then
        local status = friendInfo.status or "online"
        if status == "" then status = "online" end
        
        -- Combine status icon with friend indicator
        local statusText = statusIcons[status] or ""
        if db.social.friendNotes and friendInfo.note and friendInfo.note ~= "" then
            statusText = statusText .. " |cFF17FFA8[F: " .. friendInfo.note .. "]|r"
        else
            statusText = statusText .. " |cFF17FFA8[Friend]|r"
        end
        
        return statusText
    end
    
    -- Check if guild member
    local inGuild, guildInfo = IsGuildMember(cleanName)
    if inGuild and guildInfo and db.social.guildRanks then
        local statusText = guildInfo.online and statusIcons.online or statusIcons.offline
        statusText = statusText .. " |cFF10CE87[G: " .. guildInfo.rank .. "]|r"
        return statusText
    end
    
    return nil
end

-- Function to create inline tooltips
local function CreateInlineTooltip(frame, link, text)
    if not db.social.inlineTooltips then return end
    
    -- Only process player links
    if not link or not link:find("player:") then return end
    
    -- Extract player name
    local name = link:match("player:([^:|]+)")
    if not name then return end
    
    -- Don't create tooltip for non-friends/guild
    if not IsFriend(name) and not IsGuildMember(name) then return end
    
    -- Create or get tooltip frame
    if not frame.inlineTooltip then
        local tooltip = CreateFrame("Frame", nil, frame, "BackdropTemplate")
        tooltip:SetFrameStrata("HIGH")
        tooltip:SetBackdrop({
            bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background",
            edgeFile = "Interface\\DialogFrame\\UI-DialogBox-Border",
            tile = true, tileSize = 16, edgeSize = 16,
            insets = { left = 4, right = 4, top = 4, bottom = 4 }
        })
        tooltip:SetBackdropColor(0, 0, 0, 0.9)
        
        -- Title text
        local title = tooltip:CreateFontString(nil, "OVERLAY")
        title:SetFont(STANDARD_TEXT_FONT, 12, "OUTLINE")
        title:SetPoint("TOPLEFT", tooltip, "TOPLEFT", 10, -10)
        title:SetTextColor(1, 0.8, 0)
        tooltip.title = title
        
        -- Status text
        local status = tooltip:CreateFontString(nil, "OVERLAY")
        status:SetFont(STANDARD_TEXT_FONT, 10)
        status:SetPoint("TOPLEFT", title, "BOTTOMLEFT", 0, -5)
        status:SetTextColor(1, 1, 1)
        tooltip.status = status
        
        -- Info text
        local info = tooltip:CreateFontString(nil, "OVERLAY")
        info:SetFont(STANDARD_TEXT_FONT, 10)
        info:SetPoint("TOPLEFT", status, "BOTTOMLEFT", 0, -5)
        info:SetTextColor(0.8, 0.8, 0.8)
        tooltip.info = info
        
        frame.inlineTooltip = tooltip
        tooltip:Hide()
    end
    
    -- Get friend or guild info
    local isFriend, friendInfo = IsFriend(name)
    local inGuild, guildInfo = IsGuildMember(name)
    
    local tooltip = frame.inlineTooltip
    
    -- Set tooltip contents
    tooltip.title:SetText(name)
    
    local statusText = ""
    local infoText = ""
    
    if isFriend and friendInfo then
        statusText = "Friend" .. (friendInfo.isBNet and " (Battle.net)" or "")
        statusText = statusText .. " - " .. (friendInfo.status or "Online")
        
        if friendInfo.note and friendInfo.note ~= "" then
            infoText = "Note: " .. friendInfo.note
        end
        
        if friendInfo.level and friendInfo.class then
            infoText = infoText .. "\nLevel " .. friendInfo.level .. " " .. friendInfo.class
        end
    elseif inGuild and guildInfo then
        statusText = "Guild Member - " .. guildInfo.rank
        if guildInfo.level and guildInfo.class then
            infoText = "Level " .. guildInfo.level .. " " .. guildInfo.class
        end
    end
    
    tooltip.status:SetText(statusText)
    tooltip.info:SetText(infoText)
    
    -- Size tooltip based on contents
    tooltip:SetWidth(math.max(
        tooltip.title:GetStringWidth() + 20,
        tooltip.status:GetStringWidth() + 20,
        tooltip.info:GetStringWidth() + 20,
        150
    ))
    tooltip:SetHeight(
        tooltip.title:GetStringHeight() +
        tooltip.status:GetStringHeight() +
        tooltip.info:GetStringHeight() +
        30
    )
    
    tooltip:ClearAllPoints()
    tooltip:SetPoint("BOTTOMLEFT", frame, "BOTTOMLEFT", 30, 30)
    tooltip:Show()
    
    -- Create close button if it doesn't exist yet
    if not tooltip.closeButton then
        local closeButton = CreateFrame("Button", nil, tooltip, "UIPanelCloseButton")
        closeButton:SetPoint("TOPRIGHT", tooltip, "TOPRIGHT", 2, 2)
        closeButton:SetSize(20, 20)
        tooltip.closeButton = closeButton
    end
    
    -- Auto-hide after a few seconds
    if tooltip.hideTimer then
        tooltip.hideTimer:Cancel()
    end
    
    tooltip.hideTimer = C_Timer.NewTimer(10, function()
        tooltip:Hide()
    end)
    
    -- Add escape key closing
    tooltip:SetScript("OnKeyDown", function(self, key)
        if key == "ESCAPE" then
            self:Hide()
        end
    end)
    tooltip:SetPropagateKeyboardInput(true)
    
    -- Make it clickable to dismiss
    tooltip:EnableMouse(true)
    tooltip:SetScript("OnMouseDown", function(self)
        self:Hide()
    end)
end

-- Enhanced player message formatting
local function EnhancePlayerMessage(self, event, message, author, ...)
    if not author then return false, message, author, ... end
    
    -- Don't modify BN whispers
    if event == "CHAT_MSG_BN_WHISPER" or event == "CHAT_MSG_BN_WHISPER_INFORM" then
        return false, message, author, ...
    end
    
    -- Extract the clean name for lookup
    local cleanName = GetCleanName(author)
    
    -- First check if the message is a system message about a player
    local isSystemMessage = event == "CHAT_MSG_SYSTEM"
    if isSystemMessage then
        -- We don't need to enhance system messages
        return false, message, author, ...
    end
    
    -- Check if friend
    local isFriend, friendInfo = IsFriend(cleanName)
    local inGuild, guildInfo = IsGuildMember(cleanName)
    
    -- Skip if not a friend or guild member
    if not isFriend and not inGuild then
        return false, message, author, ...
    end
    
    -- Add enhanced status directly to the message content
    -- This avoids the duplicate hyperlink issue
    if isFriend and friendInfo then
        local status = friendInfo.status or "online"
        if status == "" then status = "online" end
        local statusIcon = statusIcons[status] or ""
        
        if not message:find("%[Friend%]") then
            if db.social.friendNotes and friendInfo.note and friendInfo.note ~= "" then
                message = message:gsub("^(.-):", "%1 " .. statusIcon .. " |cFF17FFA8[F: " .. friendInfo.note .. "]|r:")
            else
                message = message:gsub("^(.-):", "%1 " .. statusIcon .. " |cFF17FFA8[Friend]|r:")
            end
        end
    elseif inGuild and guildInfo and db.social.guildRanks then
        local statusIcon = guildInfo.online and statusIcons.online or statusIcons.offline
        
        if not message:find("%[G:") then
            message = message:gsub("^(.-):", "%1 " .. statusIcon .. " |cFF10CE87[G: " .. guildInfo.rank .. "]|r:")
        end
    end
    
    return false, message, author, ...
end

-- Add enhanced player status to chat messages
for _, event in pairs({
    "CHAT_MSG_SAY", "CHAT_MSG_YELL", "CHAT_MSG_WHISPER", "CHAT_MSG_WHISPER_INFORM",
    "CHAT_MSG_GUILD", "CHAT_MSG_OFFICER", "CHAT_MSG_PARTY", "CHAT_MSG_PARTY_LEADER",
    "CHAT_MSG_RAID", "CHAT_MSG_RAID_LEADER", "CHAT_MSG_RAID_WARNING",
    "CHAT_MSG_INSTANCE_CHAT", "CHAT_MSG_INSTANCE_CHAT_LEADER", "CHAT_MSG_CHANNEL"
}) do
    ChatFrame_AddMessageEventFilter(event, EnhancePlayerMessage)
end

-- Add friend/guild cache refresh triggers
local refreshFrame = CreateFrame("Frame")
refreshFrame:RegisterEvent("FRIENDLIST_UPDATE")
refreshFrame:RegisterEvent("BN_FRIEND_INFO_CHANGED")
refreshFrame:RegisterEvent("GUILD_ROSTER_UPDATE")
refreshFrame:RegisterEvent("PLAYER_GUILD_UPDATE")
refreshFrame:SetScript("OnEvent", function(self, event, ...)
    if event == "FRIENDLIST_UPDATE" or event == "BN_FRIEND_INFO_CHANGED" then
        -- Clear friend cache
        table.wipe(friendCache)
    elseif event == "GUILD_ROSTER_UPDATE" or event == "PLAYER_GUILD_UPDATE" then
        -- Clear guild cache
        table.wipe(guildCache)
    end
end)

-- Force roster updates
if IsInGuild() then
    if Phoenix_UI.compat and Phoenix_UI.compat.GuildRoster then
        Phoenix_UI.compat.GuildRoster()
    elseif C_GuildInfo and C_GuildInfo.GuildRoster then
        C_GuildInfo.GuildRoster()
    elseif GuildRoster then
        GuildRoster()
    end
end

-- Hook chat frame hyperlink clicks for inline tooltip
if db.social.inlineTooltips then
    for i = 1, NUM_CHAT_WINDOWS do
        local chatFrame = _G["ChatFrame" .. i]
        if chatFrame then
            chatFrame:HookScript("OnHyperlinkClick", function(self, link, text, button)
                if button == "LeftButton" then
                    CreateInlineTooltip(self, link, text)
                end
            end)
        end
    end
end

-- Initialize and announce
-- Debug messages removed to prevent login spam