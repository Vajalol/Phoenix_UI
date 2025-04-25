---@class PhoenixUI_ChatEmojiModule : AceModule
local Module = Phoenix_UI:NewModule("Chat.Emoji");

-- Path to emoji files - updated to match the new ElvUI emoji location
local EMOJI_PATH = "Interface\\AddOns\\Phoenix_UI\\Modules\\Chat\\ChatEmojis\\"
local LOGOS_PATH = "Interface\\AddOns\\Phoenix_UI\\Modules\\Chat\\ChatLogos\\"

-- Emoji mapping table - updated to match ElvUI emojis
local emojiMap = {
    -- Standard Smileys
    [":%)"] = "Smile",
    ["=%)"] = "Smile",
    [":D"] = "Grin",
    ["=D"] = "Grin",
    ["XD"] = "Joy",
    ["xD"] = "Joy",
    [":-D"] = "Grin",
    [":%("] = "SlightFrown",
    ["=%("] = "SlightFrown",
    [":<"] = "SlightFrown",
    [":o"] = "OpenMouth",
    [":O"] = "OpenMouth",
    [":S"] = "Thinking",
    [":s"] = "Thinking",
    [";%)"] = "Wink",
    ["<3"] = "Heart",
    ["B)"] = "Sunglasses",
    ["8)"] = "Sunglasses",
    [":P"] = "StuckOutTongue",
    [":p"] = "StuckOutTongue",
    ["=P"] = "StuckOutTongue",
    ["=p"] = "StuckOutTongue",
    [";P"] = "StuckOutTongueClosedEyes",
    ["T_T"] = "Sob",
    [":'%("] = "Cry",
    [":/"] = "SlightFrown",
    [":\\"] = "SlightFrown",
    [":|"] = "SemiColon",
    [":-o"] = "OpenMouth",
    ["8O"] = "OpenMouth",
    ["O_o"] = "ScreamCat",
    ["o_O"] = "ScreamCat",
    [":@"] = "Angry",
    ["D:"] = "Scream",
    [">_<"] = "Rage",
    ["^_^"] = "SlightSmile",
    [":*"] = "Blush",
    [";*"] = "Blush",
    [":heart:"] = "Heart",
    [":hearteyes:"] = "HeartEyes",
    
    -- Custom codes
    [":love:"] = "Heart",
    [":smile:"] = "Smile",
    [":sad:"] = "SlightFrown",
    [":angry:"] = "Angry",
    [":cool:"] = "Sunglasses",
    [":cry:"] = "Cry",
    [":wink:"] = "Wink",
    [":tongue:"] = "StuckOutTongue",
    [":grin:"] = "Grin",
    [":confused:"] = "Thinking",
    [":surprise:"] = "OpenMouth",
    [":happy:"] = "Smile",
    [":smirk:"] = "Smirk",
    [":thumbsup:"] = "ThumbsUp",
    [":zzz:"] = "ZZZ",
    [":blush:"] = "Blush",
    [":facepalm:"] = "Facepalm",
    [":meaw:"] = "Meaw",
    [":poop:"] = "Poop",
    [":okhand:"] = "OkHand",
    [":callme:"] = "CallMe",
    [":murloc:"] = "Murloc",
    [":kappa:"] = "Kappa",
    [":sadkitty:"] = "SadKitty",
    [":middlefinger:"] = "MiddleFinger",
    
    -- Logo codes (from ElvUI)
    [":elvb:"] = { path = LOGOS_PATH, file = "ElvBlue" },
    [":elvg:"] = { path = LOGOS_PATH, file = "ElvGreen" },
    [":elvo:"] = { path = LOGOS_PATH, file = "ElvOrange" },
    [":elvp:"] = { path = LOGOS_PATH, file = "ElvPink" },
    [":elvpu:"] = { path = LOGOS_PATH, file = "ElvPurple" },
    [":elvr:"] = { path = LOGOS_PATH, file = "ElvRed" },
    [":elvs:"] = { path = LOGOS_PATH, file = "ElvSimpy" },
    [":elvy:"] = { path = LOGOS_PATH, file = "ElvYellow" },
    [":beer:"] = { path = LOGOS_PATH, file = "Beer" },
    [":bathrobe:"] = { path = LOGOS_PATH, file = "Bathrobe" },
    [":clover:"] = { path = LOGOS_PATH, file = "Clover" },
    [":gem:"] = { path = LOGOS_PATH, file = "Gem" },
    [":hibiscus:"] = { path = LOGOS_PATH, file = "Hibiscus" },
    [":palmtree:"] = { path = LOGOS_PATH, file = "PalmTree" },
    [":rainbow:"] = { path = LOGOS_PATH, file = "Rainbow" },
    [":superbear:"] = { path = LOGOS_PATH, file = "SuperBear" },
    [":tyrone:"] = { path = LOGOS_PATH, file = "TyroneBiggums" }
}

-- Store processed emoji textures for reuse
local emojiTextures = {}

-- Chat message cache to avoid reprocessing
local processedMessageCache = {}
local cacheCount = 0
local MAX_CACHE_SIZE = 100

-- Function to clear the emoji cache 
function Module:ClearCache()
    wipe(processedMessageCache)
    cacheCount = 0
end

-- Improved function to get proper texture path
local function GetEmojiTexture(name, size)
    size = size or 16
    
    -- Handle custom path emojis (logos)
    if type(name) == "table" then
        local texturePath = name.path .. name.file
        return format("|T%s:%d:%d:0:0|t", texturePath, size, size)
    end
    
    -- Standard emoji
    local texturePath = EMOJI_PATH .. name
    return format("|T%s:%d:%d:0:0|t", texturePath, size, size)
end

-- ElvUI-style emoji replacement function - Carefully handles special characters
local function ReplaceEmojis(text)
    -- Skip processing if text is missing or empty
    if not text or text == "" then return text end
    
    -- Skip processing if text is not a string
    if type(text) ~= "string" then return text end
    
    -- Skip special messages like scripts
    if text:find('/run') or text:find('/dump') or text:find('/script') then 
        return text 
    end
    
    -- Get emoji size from settings
    local size = 16
    if Phoenix_UI.db and Phoenix_UI.db.profile and 
       Phoenix_UI.db.profile.chat and Phoenix_UI.db.profile.chat.emoji then
        size = Phoenix_UI.db.profile.chat.emoji.size or 16
    end
    
    -- Process emoji codes using a safer two-pass approach
    local result = text
    
    -- First pass: Identify all hyperlinks in the text and protect them
    local protectedText = ""
    local lastPos = 1
    local inLink = false
    local linkStart, linkEnd
    
    -- Find all hyperlinks and mark them as protected
    while true do
        linkStart, linkEnd = result:find("|H.-|h.-|h", lastPos)
        if not linkStart then break end
        
        -- Add text before the link with emoji processing
        if linkStart > lastPos then
            local beforeLink = result:sub(lastPos, linkStart - 1)
            for code, name in pairs(emojiMap) do
                -- Use plain string.find to avoid pattern matching issues
                local startPos = 1
                while true do
                    local s, e = beforeLink:find(code, startPos, true)
                    if not s then break end
                    
                    -- Replace only this instance
                    local prefix = beforeLink:sub(1, s-1)
                    local suffix = beforeLink:sub(e+1)
                    beforeLink = prefix .. GetEmojiTexture(name, size) .. suffix
                    
                    -- Move past this replacement
                    startPos = s + 1
                end
            end
            protectedText = protectedText .. beforeLink
        end
        
        -- Add the hyperlink unchanged
        protectedText = protectedText .. result:sub(linkStart, linkEnd)
        
        -- Move past this link
        lastPos = linkEnd + 1
    end
    
    -- Process any remaining text after the last link
    if lastPos <= #result then
        local afterLinks = result:sub(lastPos)
        for code, name in pairs(emojiMap) do
            -- Use plain string.find to avoid pattern matching issues
            local startPos = 1
            while true do
                local s, e = afterLinks:find(code, startPos, true)
                if not s then break end
                
                -- Replace only this instance
                local prefix = afterLinks:sub(1, s-1)
                local suffix = afterLinks:sub(e+1)
                afterLinks = prefix .. GetEmojiTexture(name, size) .. suffix
                
                -- Move past this replacement
                startPos = s + 1
            end
        end
        protectedText = protectedText .. afterLinks
    end
    
    -- Return the processed text
    return protectedText
end

-- The main emoji filter function - registered with ElvUI-style approach
function _G.EmojiFilter(_, _, message, ...)
    -- Skip if emoji feature is disabled in settings
    if Phoenix_UI.db and Phoenix_UI.db.profile and 
       Phoenix_UI.db.profile.chat and Phoenix_UI.db.profile.chat.emoji and 
       Phoenix_UI.db.profile.chat.emoji.enabled == false then
        return false
    end
    
    -- Skip if message is nil
    if not message then return false end
    
    -- Check cache for previously processed messages
    local cacheKey = message
    if processedMessageCache[cacheKey] then
        return false, processedMessageCache[cacheKey], ...
    end
    
    -- Process the message with our safer emoji replacement
    local processedMessage = ReplaceEmojis(message)
    
    -- Only continue if the message was actually changed
    if processedMessage ~= message then
        -- Cache the result
        if cacheCount >= MAX_CACHE_SIZE then
            Module:ClearCache()
        end
        processedMessageCache[cacheKey] = processedMessage
        cacheCount = cacheCount + 1
        
        -- Show debug message if enabled
        if Phoenix_UI.debug then
            print("Processed emoji message: " .. processedMessage:gsub("|", "||"))
        end
        
        return false, processedMessage, ...
    end
    
    -- Message wasn't changed, just pass it through
    return false
end

function Module:OnEnable()
    -- Initialize settings if they don't exist
    if not Phoenix_UI.db.profile.chat.emoji then
        Phoenix_UI.db.profile.chat.emoji = {
            enabled = true,
            size = 16
        }
    end
    
    -- Register for all chat message types using ElvUI's approach
    local chatEvents = {
        "CHAT_MSG_SAY", "CHAT_MSG_YELL", "CHAT_MSG_WHISPER", "CHAT_MSG_WHISPER_INFORM",
        "CHAT_MSG_GUILD", "CHAT_MSG_OFFICER", "CHAT_MSG_PARTY", "CHAT_MSG_PARTY_LEADER", 
        "CHAT_MSG_RAID", "CHAT_MSG_RAID_LEADER", "CHAT_MSG_RAID_WARNING",
        "CHAT_MSG_INSTANCE_CHAT", "CHAT_MSG_INSTANCE_CHAT_LEADER", 
        "CHAT_MSG_CHANNEL", "CHAT_MSG_BN_WHISPER", "CHAT_MSG_BN_WHISPER_INFORM",
        "CHAT_MSG_BN_CONVERSATION"
    }
    
    -- Register our emoji filter for chat events (must register last to ensure it's the last filter applied)
    for _, event in pairs(chatEvents) do
        ChatFrame_AddMessageEventFilter(event, _G.EmojiFilter)
    end
    
    -- Debug code removed to prevent login messages
end

function Module:OnDisable()
    -- Could add unregistering here if needed
end

-- Add slash command for viewing all available emojis
SLASH_EMOJIS1 = "/emojis"
SlashCmdList["EMOJIS"] = function(msg)
    print("|cffFF7D0APhoenix UI:|r Available emoji codes:")
    
    -- Group emojis by type for better organization
    local standardEmojis = {}
    local customEmojis = {}
    local logoEmojis = {}
    
    for code, info in pairs(emojiMap) do
        local emojiTexture = GetEmojiTexture(info)
        if type(info) == "table" and info.path == LOGOS_PATH then
            table.insert(logoEmojis, code .. " " .. emojiTexture)
        elseif code:find(":.*:") then
            table.insert(customEmojis, code .. " " .. emojiTexture)
        else
            table.insert(standardEmojis, code .. " " .. emojiTexture)
        end
    end
    
    -- Display standard emojis
    print("|cff00FF00Standard Emojis:|r")
    local line = ""
    for i, text in ipairs(standardEmojis) do
        line = line .. text .. "  "
        if i % 5 == 0 then
            print(line)
            line = ""
        end
    end
    if line ~= "" then print(line) end
    
    -- Display custom emojis
    print("|cff00FF00Custom Emojis:|r")
    line = ""
    for i, text in ipairs(customEmojis) do
        line = line .. text .. "  "
        if i % 4 == 0 then
            print(line)
            line = ""
        end
    end
    if line ~= "" then print(line) end
    
    -- Display logo emojis
    print("|cff00FF00Logo Emojis:|r")
    line = ""
    for i, text in ipairs(logoEmojis) do
        line = line .. text .. "  "
        if i % 4 == 0 then
            print(line)
            line = ""
        end
    end
    if line ~= "" then print(line) end
end