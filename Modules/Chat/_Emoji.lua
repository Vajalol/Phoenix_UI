---@class PhoenixUI_ChatEmojiModule : AceModule
local Module = Phoenix_UI:NewModule("Chat.Emoji");

-- Path to emoji files - using the absolute, direct game path format
local EMOJI_PATH = "Interface\\AddOns\\Phoenix_UI\\Modules\\Chat\\Emojis\\"

-- Emoji mapping table
local emojiMap = {
    -- Smileys
    [":%)"] = "Smile",
    ["=%)"] = "Smile",
    [":D"] = "Smile",
    ["=D"] = "Smile",
    ["XD"] = "StuckOutTongueClosedEyes",
    ["xD"] = "StuckOutTongueClosedEyes",
    [":-D"] = "Smile",
    [":%("] = "Scream",
    ["=%("] = "Scream",
    [":<"] = "Scream",
    [":o"] = "Scream",
    [":O"] = "Scream",
    [":S"] = "Thinking",
    [":s"] = "Thinking",
    [";%)"] = "Wink",
    ["<3"] = "BrokenHeart",
    ["B)"] = "Sunglasses",
    ["8)"] = "Sunglasses",
    [":P"] = "StuckOutTongue",
    [":p"] = "StuckOutTongue",
    ["=P"] = "StuckOutTongue",
    ["=p"] = "StuckOutTongue",
    [";P"] = "StuckOutTongueClosedEyes",
    ["T_T"] = "Sob",
    [":'%("] = "Sob",
    [":/"] = "Thinking",
    [":\\"] = "Thinking",
    [":|"] = "Thinking",
    [":-o"] = "Scream",
    ["8O"] = "Scream",
    ["O_o"] = "ScreamCat",
    ["o_O"] = "ScreamCat",
    [":@"] = "Angry",
    ["D:"] = "Angry",
    [">_<"] = "Angry",
    ["^_^"] = "Smile",
    [":*"] = "Blush",
    [";*"] = "Blush",
    
    -- Custom codes
    [":love:"] = "BrokenHeart",
    [":smile:"] = "Smile",
    [":sad:"] = "Scream",
    [":angry:"] = "Angry",
    [":cool:"] = "Sunglasses",
    [":cry:"] = "Sob",
    [":wink:"] = "Wink",
    [":tongue:"] = "StuckOutTongue",
    [":grin:"] = "Smile",
    [":confused:"] = "Thinking",
    [":surprise:"] = "Scream",
    [":happy:"] = "Smile",
    [":smirk:"] = "Smirk",
    [":thumbsup:"] = "ThumbsUp",
    [":zzz:"] = "ZZZ",
    [":blush:"] = "Blush",
}

-- Reverse emoji mapping table
local reverseEmojiMap = {}
for code, name in pairs(emojiMap) do
    -- If multiple codes map to the same emoji, keep the shortest one for reverse lookup
    if not reverseEmojiMap[name] or #code < #reverseEmojiMap[name] then
        reverseEmojiMap[name] = code
    end
end

-- -------------------------
-- SIMPLIFIED EMOJI SYSTEM
-- -------------------------

-- Store the original SendChatMessage function
local originalSendChatMessage = SendChatMessage

-- Create texture strings for each emoji
local emojiTextures = {}
-- Add a cache for processed messages to improve performance
local processedMessageCache = setmetatable({}, {
    __mode = "k",  -- weak keys to allow garbage collection
    __index = function(t, k) return nil end
})
local MAX_CACHE_SIZE = 100
local cacheCount = 0

-- Make the cache accessible globally for debugging and admin tools
Phoenix_UI.ChatEmojiCache = processedMessageCache

-- Function to replace emoji codes with textures in a message
local function ReplaceEmojis(text, forSendChat)
    -- Skip processing if text is missing or empty
    if not text or text == "" then return text end
    
    -- Skip processing if text is not a string (this can happen with some addons)
    if type(text) ~= "string" then return text end
    
    -- Skip processing for SendChat if disabled in settings
    if forSendChat then
        if Phoenix_UI.db and Phoenix_UI.db.profile and 
           Phoenix_UI.db.profile.chat and Phoenix_UI.db.profile.chat.emoji and 
           Phoenix_UI.db.profile.chat.emoji.enabled == false then
            return text
        end
    end
    
    -- Check cache first for improved performance
    local cacheKey = text .. (forSendChat and "_send" or "_display")
    if processedMessageCache[cacheKey] then
        return processedMessageCache[cacheKey]
    end
    
    -- New approach: Handle formatting tags by processing text segments
    
    -- First check if the message has any formatting. If not, process the whole thing
    if not text:find("|") then
        local modified = false
        local result = text
        
        -- Process with simple emojis first
        for code, name in pairs(emojiMap) do
            -- Use plain text find to avoid pattern matching issues
            if text:find(code, 1, true) then
                local size = Phoenix_UI.db.profile.chat.emoji.size or 16
                local textureString = emojiTextures[code] and emojiTextures[code].display or
                    ("|T" .. EMOJI_PATH .. name .. ".tga:" .. size .. ":" .. size .. "|t")
                
                -- Replace emojis with texture strings (use plain flag for literal string replacement)
                result = result:gsub(code, textureString, 1, true)
                modified = true
            end
        end
        
        -- Only add to cache if we actually modified something
        if modified then
            -- Manage cache size
            if cacheCount >= MAX_CACHE_SIZE then
                -- Clear cache when it gets too large
                processedMessageCache = setmetatable({}, {
                    __mode = "k",
                    __index = function(t, k) return nil end
                })
                cacheCount = 0
            end
            
            processedMessageCache[cacheKey] = result
            cacheCount = cacheCount + 1
        end
        
        return result
    else
        -- Split the message into formatted and unformatted segments
        local segments = {}
        local currentPos = 1
        local inFormat = false
        local formatStartPos = 0
        local formatCount = 0
        
        -- Find all formatting tags and extract segments between them
        for i = 1, #text do
            local char = text:sub(i, i)
            
            if char == "|" then
                -- Check if this is a formatting tag or escaped |
                local nextChar = text:sub(i+1, i+1)
                
                if nextChar == "|" then
                    -- This is an escaped |, skip the next character
                    i = i + 1
                else
                    if not inFormat then
                        -- Start of a format tag, add preceding text as a segment
                        if i > currentPos then
                            table.insert(segments, {
                                text = text:sub(currentPos, i-1),
                                isFormat = false
                            })
                        end
                        
                        inFormat = true
                        formatStartPos = i
                        
                        -- Look ahead to find the end of this format tag
                        if nextChar == "c" then
                            -- Color format |cAARRGGBB spans until |r
                            formatCount = formatCount + 1
                        elseif nextChar == "r" then
                            -- End of color format |r
                            formatCount = math.max(0, formatCount - 1)
                        elseif nextChar == "T" then
                            -- Texture format |T...|t
                            -- Need to find the matching |t
                        elseif nextChar == "H" then
                            -- Hyperlink format |H...|h[...]|h
                        end
                    elseif nextChar == "t" and text:sub(formatStartPos, formatStartPos+1) == "|T" then
                        -- End of texture tag
                        table.insert(segments, {
                            text = text:sub(formatStartPos, i+1),
                            isFormat = true
                        })
                        inFormat = false
                        currentPos = i + 2
                    elseif nextChar == "h" then
                        -- Could be the end of a hyperlink or part of the hyperlink text
                        local prevText = text:sub(i-2, i-1)
                        if prevText == "]|" then
                            -- This is the end of a hyperlink
                            table.insert(segments, {
                                text = text:sub(formatStartPos, i+1),
                                isFormat = true
                            })
                            inFormat = false
                            currentPos = i + 2
                        end
                    elseif nextChar == "r" and formatCount > 0 then
                        -- End of color format
                        table.insert(segments, {
                            text = text:sub(formatStartPos, i+1),
                            isFormat = true
                        })
                        formatCount = formatCount - 1
                        if formatCount == 0 then
                            inFormat = false
                            currentPos = i + 2
                        end
                    end
                end
            end
        end
        
        -- Add the final segment
        if currentPos <= #text then
            table.insert(segments, {
                text = text:sub(currentPos),
                isFormat = inFormat
            })
        end
        
        -- Process only the non-format segments
        local result = ""
        for _, segment in ipairs(segments) do
            if segment.isFormat then
                -- Keep format segments as they are
                result = result .. segment.text
            else
                -- Process non-format segments for emojis
                local processedText = segment.text
                local modified = false
                
                for code, name in pairs(emojiMap) do
                    -- Use plain text find to avoid pattern matching issues
                    if processedText:find(code, 1, true) then
                        local size = Phoenix_UI.db.profile.chat.emoji.size or 16
                        local textureString = emojiTextures[code] and emojiTextures[code].display or
                            ("|T" .. EMOJI_PATH .. name .. ".tga:" .. size .. ":" .. size .. "|t")
                        
                        -- Replace emojis with texture strings (use plain flag for literal string replacement)
                        processedText = processedText:gsub(code, textureString, 1, true)
                        modified = true
                    end
                end
                
                result = result .. processedText
            end
        end
        
        -- Cache the processed message if modified
        if result ~= text then
            -- Manage cache size
            if cacheCount >= MAX_CACHE_SIZE then
                -- Clear cache when it gets too large
                processedMessageCache = setmetatable({}, {
                    __mode = "k",
                    __index = function(t, k) return nil end
                })
                cacheCount = 0
            end
            
            processedMessageCache[cacheKey] = result
            cacheCount = cacheCount + 1
        end
        
        -- Skip messages with broken formatting that could result from emoji replacement
        if result:find("||") or result:find("|[^cHhTrt]") or result:find("|$") then
            return text
        end
        
        return result
    end
end

-- MESSAGE PREVIEW FUNCTION (only changes what you see in edit box, not what's sent)
local function AddEmojiPreview(editbox)
    if not editbox then return end
    
    -- Original OnTextChanged
    local originalOnTextChanged = editbox:GetScript("OnTextChanged")
    
    -- Override OnTextChanged to show emoji previews
    editbox:SetScript("OnTextChanged", function(self, ...)
        -- Call original handler first
        if originalOnTextChanged then
            originalOnTextChanged(self, ...)
        end
        
        -- Get current text and cursor position
        local text = self:GetText()
        local cursorPosition = self:GetCursorPosition()
        
        -- Check for emoji codes and add visual preview
        -- (Implementation would be more complex for true preview)
    end)
end

-- Hook the SendChatMessage function to ensure proper emoji handling in outgoing messages
local function HookSendChatMessage(text, chatType, language, channel)
    -- Only process player-typed messages, not system messages
    if not text or text == "" then 
        return originalSendChatMessage(text, chatType, language, channel)
    end
    
    -- Check if emoji replacement is enabled
    if not Phoenix_UI.db or not Phoenix_UI.db.profile or not Phoenix_UI.db.profile.chat or 
       not Phoenix_UI.db.profile.chat.emoji or not Phoenix_UI.db.profile.chat.emoji.enabled then
        return originalSendChatMessage(text, chatType, language, channel)
    end
    
    local modified = false
    local result = text
    
    -- First: Handle any texture escape sequences in the message and convert them back to emoji codes
    -- This handles existing texture paths that have been processed already
    result = result:gsub("|T.-Interface\\AddOns\\Phoenix_UI\\Modules\\Chat\\Emojis\\([%w_]+)%.tga:[%d:]+|t", function(emojiName)
        modified = true
        -- Find the corresponding emoji code
        for code, name in pairs(emojiMap) do
            if name == emojiName then
                return code
            end
        end
        -- If no code is found, just return a placeholder
        return ":"..emojiName..":"
    end)
    
    -- Second: Handle any raw texture paths (without proper |T|t formatting)
    -- Handle paths with brackets
    result = result:gsub("%[Interface\\AddOns\\Phoenix_UI\\Modules\\Chat\\Emojis\\([%w_]+)%.tga%]", function(emojiName)
        modified = true
        -- Find the corresponding emoji code
        for code, name in pairs(emojiMap) do
            if name == emojiName then
                return code
            end
        end
        -- If no code is found, just return a placeholder
        return ":"..emojiName..":"
    end)
    
    -- Handle paths without brackets
    result = result:gsub("Interface\\AddOns\\Phoenix_UI\\Modules\\Chat\\Emojis\\([%w_]+)%.tga", function(emojiName)
        modified = true
        -- Find the corresponding emoji code
        for code, name in pairs(emojiMap) do
            if name == emojiName then
                return code
            end
        end
        -- If no code is found, just return a placeholder
        return ":"..emojiName..":"
    end)
    
    return originalSendChatMessage(result, chatType, language, channel)
end

---@diagnostic disable-next-line: duplicate-set-field
function Module:OnEnable()
    -- Ensure we have access to the database
    if not Phoenix_UI.db or not Phoenix_UI.db.profile then
        -- Delay initialization until database is available
        C_Timer.After(1, function() self:OnEnable() end)
        return
    end
    
    -- Initialize chat settings if they don't exist
    if not Phoenix_UI.db.profile.chat then
        Phoenix_UI.db.profile.chat = {}
    end
    
    local db = Phoenix_UI.db.profile.chat
    
    -- Initialize emoji settings if not present
    if not db.emoji then
        db.emoji = {
            enabled = true,
            size = 16,
            cacheSize = 100  -- Add cache size setting
        }
        
        -- Make sure to save the settings
        if Phoenix_UI.SaveDB then
            Phoenix_UI:SaveDB()
        else
            C_Timer.After(1, function()
                if Phoenix_UI.SaveDB then
                    Phoenix_UI:SaveDB()
                end
            end)
        end
    end
    
    -- Update the MAX_CACHE_SIZE from settings if available
    if db.emoji.cacheSize then
        MAX_CACHE_SIZE = db.emoji.cacheSize
    end
    
    -- Initialize emoji textures for this session
    local function InitializeEmojis()
        -- Get current theme information
        local currentTheme = "Default"
        local themeColors = {r = 1, g = 1, b = 1}
        
        if Phoenix_UI.currentTheme then
            currentTheme = Phoenix_UI.currentTheme
            -- Get theme colors for potential glow effects
            if Phoenix_UI.themes and Phoenix_UI.themes[currentTheme] and Phoenix_UI.themes[currentTheme].colors then
                -- Use primary color from theme
                themeColors = Phoenix_UI.themes[currentTheme].colors.primary or themeColors
            end
        end
        
        -- Get emoji size from settings
        local size = 16
        if Phoenix_UI.db and Phoenix_UI.db.profile and 
           Phoenix_UI.db.profile.chat and Phoenix_UI.db.profile.chat.emoji then
            size = Phoenix_UI.db.profile.chat.emoji.size or 16
        end
        
        -- Special handling for the Phoenix Flame theme
        local isPhoenixFlame = (currentTheme == "PhoenixFlame")
        local extraParams = ""
        
        -- For Phoenix Flame theme, add a slight color tint to emojis
        if isPhoenixFlame then
            -- Format: |T<path>:<height>:<width>:<offsetX>:<offsetY>:<fileWidth>:<fileHeight>:<r>:<g>:<b>|t
            local r, g, b = themeColors.r or 1.0, themeColors.g or 0.4, themeColors.b or 0.0
            -- Use a subtle tint (0.9-1.0) to preserve most of the original emoji colors
            extraParams = ":0:0:0:0:" .. (r * 0.9 + 0.1) .. ":" .. (g * 0.7 + 0.3) .. ":" .. (b * 0.5 + 0.5)
            
            -- Special animated emoji support for Phoenix Flame theme
            -- Check if animation frames are available
            if Phoenix_UI.themes and Phoenix_UI.themes[currentTheme] and 
               Phoenix_UI.themes[currentTheme].textures and 
               Phoenix_UI.themes[currentTheme].textures.flameAnim then
                
                -- Add special animated flame emoji
                emojiMap[":flame:"] = "FlameAnim"
                emojiMap[":fire:"] = "FlameAnim"
            end
        end
        
        for code, name in pairs(emojiMap) do
            -- Special case for animated flame emoji
            if name == "FlameAnim" and isPhoenixFlame and 
               Phoenix_UI.themes[currentTheme].textures.flameAnim then
                
                -- Use first frame of animation for display
                local flamePath = Phoenix_UI.themes[currentTheme].textures.flameAnim[1]
                emojiTextures[code] = {
                    display = "|T" .. flamePath .. ":" .. size .. ":" .. size .. extraParams .. "|t",
                    escaped = "\124T" .. flamePath .. ":" .. size .. ":" .. size .. extraParams .. "\124t",
                    isAnimated = true,
                    frames = Phoenix_UI.themes[currentTheme].textures.flameAnim
                }
            else
                -- Regular emoji
                emojiTextures[code] = {
                    display = "|T" .. EMOJI_PATH .. name .. ".tga:" .. size .. ":" .. size .. extraParams .. "|t",
                    escaped = "\124T" .. EMOJI_PATH .. name .. ".tga:" .. size .. ":" .. size .. extraParams .. "\124t"
                }
            end
        end
    end
    
    InitializeEmojis()
    
    -- Define the emoji filter function that will be used by chat frames
    function _G.EmojiFilter(_, _, message, ...)
        -- Skip if emoji feature is disabled in settings
        if Phoenix_UI.db and Phoenix_UI.db.profile and 
           Phoenix_UI.db.profile.chat and Phoenix_UI.db.profile.chat.emoji and 
           Phoenix_UI.db.profile.chat.emoji.enabled == false then
            return false
        end
        
        -- Process the message and replace emojis with textures
        local processedMessage = ReplaceEmojis(message, false)
        
        -- Only modify the message if emojis were actually replaced
        if processedMessage ~= message then
            return false, processedMessage, ...
        end
        
        -- Return false to allow other filters to process the message
        return false
    end
    
    -- Set up filters for chat messages to handle emoji codes and display them as textures
    local function SetupChatFilters()
        -- Only register once
        if Module.chatFiltersRegistered then return end
        
        -- Get the EmojiFilter function defined at the module level
        local EmojiFilter = _G.EmojiFilter
        
        -- Register for all chat types
        local chatTypes = {
            "CHAT_MSG_SAY", "CHAT_MSG_YELL", "CHAT_MSG_PARTY", "CHAT_MSG_PARTY_LEADER",
            "CHAT_MSG_RAID", "CHAT_MSG_RAID_LEADER", "CHAT_MSG_RAID_WARNING",
            "CHAT_MSG_GUILD", "CHAT_MSG_OFFICER", "CHAT_MSG_WHISPER", "CHAT_MSG_WHISPER_INFORM",
            "CHAT_MSG_CHANNEL", "CHAT_MSG_INSTANCE_CHAT", "CHAT_MSG_INSTANCE_CHAT_LEADER",
            "CHAT_MSG_BN_WHISPER", "CHAT_MSG_BN_WHISPER_INFORM", "CHAT_MSG_BN_CONVERSATION"
        }
        
        -- Register the filter for all chat types
        for _, event in ipairs(chatTypes) do
            ChatFrame_AddMessageEventFilter(event, EmojiFilter)
        end
        
        Module.chatFiltersRegistered = true
    end
    
    -- Set up chat filters after a brief delay to ensure UI is fully loaded
    C_Timer.After(1, function() SetupChatFilters() end)
    
    -- Register our emoji replacement function with the chat module
    if not Phoenix_UI.ChatEmojiHandlers then
        Phoenix_UI.ChatEmojiHandlers = {}
    end
    
    -- Add our emoji replacement function to the handlers
    Phoenix_UI.ChatEmojiHandlers["emoji"] = function(text)
        return ReplaceEmojis(text, false)
    end
    
    -- Listen for theme changes to refresh emoji appearance
    Phoenix_UI:RegisterMessage("PHOENIX_UI_THEME_CHANGED", function(_, themeName)
        -- Re-initialize emojis with the new theme's colors
        InitializeEmojis()
    end)
    
    -- Hook the SendChatMessage function
    originalSendChatMessage = _G.SendChatMessage
    _G.SendChatMessage = HookSendChatMessage
    
    -- Add emoji preview to edit boxes
    for i = 1, NUM_CHAT_WINDOWS do
        local editbox = _G["ChatFrame" .. i .. "EditBox"]
        if editbox then
            AddEmojiPreview(editbox)
        end
    end
    
    -- Add slash command for testing emojis
    SLASH_PHOENIXEMOJI1 = "/emojis"
    SlashCmdList["PHOENIXEMOJI"] = function(msg)
        if msg == "test" then
            -- Test each emoji
            print("|cffFF7D0APhoenix UI:|r Testing emoji rendering:")
            for code, textures in pairs(emojiTextures) do
                print(code .. " = " .. textures.display)
            end
        elseif msg == "flame" or msg == "fire" then
            -- Show the flame animation if available
            print("|cffFF7D0APhoenix UI:|r Flame animation emoji test:")
            
            -- Check if we have the flame emoji with animation frames
            if emojiTextures[":flame:"] and emojiTextures[":flame:"].isAnimated and emojiTextures[":flame:"].frames then
                
                -- Show animation frames
                for i, framePath in ipairs(emojiTextures[":flame:"].frames) do
                    print("Frame " .. i .. ": |T" .. framePath .. ":24:24|t")
                end
                
                -- Explain how to use it
                print("Usage: Type :flame: or :fire: in chat to use the animated flame emoji")
            else
                print("Flame animation not available")
            end
        elseif msg == "save" then
            -- Force save settings
            if Phoenix_UI.SaveDB then
                Phoenix_UI:SaveDB()
                print("|cffFF7D0APhoenix UI:|r Emoji settings saved!")
            end
        else
            -- Display available emojis
            print("|cffFF7D0APhoenix UI:|r Available emoji codes:")
            local line = ""
            local count = 0
            for code, textures in pairs(emojiTextures) do
                line = line .. code .. " " .. textures.display .. "  "
                count = count + 1
                if count % 5 == 0 then
                    print(line)
                    line = ""
                end
            end
            if line ~= "" then
                print(line)
            end
            print("Type /emojis save to force save emoji settings.")
            print("Type /emojis flame to test the flame animation emoji (Phoenix Flame theme only).")
        end
    end
    
    -- Simpler test command
    SLASH_EMOJITEST1 = "/emojitest"
    SlashCmdList["EMOJITEST"] = function(msg)
        if msg == "" then
            print("Testing emoji: :) = " .. emojiTextures[":%)"].display)
            print("Testing emoji: :D = " .. emojiTextures[":D"].display)
            print("Testing emoji: <3 = " .. emojiTextures["<3"].display)
        else
            print("Converted: " .. ReplaceEmojis(msg, false))
        end
    end
    
    -- Direct message command
    SLASH_PHOENIXSAY1 = "/psay"
    SlashCmdList["PHOENIXSAY"] = function(msg)
        if msg == "" then
            print("|cffFF7D0APhoenix UI:|r Usage: /psay message with :) emojis")
            return
        end
        
        -- Show what the message will look like with emojis
        local preview = ReplaceEmojis(msg, false)
        print("|cffFF7D0AMessage preview:|r " .. preview)
        
        -- Send to chat normally
        local chatType = IsInRaid() and "RAID" or IsInGroup() and "PARTY" or "SAY"
        SendChatMessage(msg, chatType)
    end
    
    -- Add a debug command to test texture escaping
    SLASH_EMOJIESCAPETEST1 = "/emojiescapetest"
    SlashCmdList["EMOJIESCAPETEST"] = function(msg)
        print("|cffFF7D0APhoenix UI:|r Testing emoji escape codes:")
        
        -- Test with a simple emoji
        local smileCode = ":)"
        local normalTexture = emojiTextures[":%)"].display
        local escapedTexture = emojiTextures[":%)"].escaped
        
        print("Original code: " .. smileCode)
        print("Display texture: " .. normalTexture)
        print("Escaped for SendChatMessage: " .. escapedTexture:gsub("\124", "\\124"))
        
        -- Test replacement function
        local testMessage = "Hello :) how are you?"
        local normalReplaced = ReplaceEmojis(testMessage, false)
        local escapedReplaced = ReplaceEmojis(testMessage, true)
        
        print("Normal message: " .. normalReplaced)
        print("Escaped message: " .. escapedReplaced:gsub("\124", "\\124"))
        
        -- Test the new chat filtering approach
        print("Testing the chat filtering approach...")
        print("The emoji in this message :) should be replaced when displayed in chat.")
        
        -- Explain the approach
        print("|cffFF7D0APhoenix UI:|r Emoji system now uses chat frame filtering instead of direct SendChatMessage replacement.")
        print("This avoids the 'Invalid escape code in chat message' error.")
    end
    
    -- Announce emoji system is enabled with debug status
    if Phoenix_UI.debug then
        print("|cffFF7D0APhoenix UI:|r Emoji system enabled using chat filter approach")
    end
    
    -- Listen for settings changes and update cache size accordingly
    Phoenix_UI:RegisterMessage("PHOENIX_UI_SETTINGS_CHANGED", function()
        if Phoenix_UI.db and Phoenix_UI.db.profile and 
           Phoenix_UI.db.profile.chat and Phoenix_UI.db.profile.chat.emoji and
           Phoenix_UI.db.profile.chat.emoji.cacheSize then
            
            local newSize = Phoenix_UI.db.profile.chat.emoji.cacheSize
            if newSize ~= MAX_CACHE_SIZE then
                MAX_CACHE_SIZE = newSize
                
                -- Clear cache if size reduced substantially
                if cacheCount > MAX_CACHE_SIZE * 0.8 then
                    Module:ClearCache()
                end
            end
        end
    end)
end

--- Clears the emoji message cache
--- @return boolean success Whether the cache was successfully cleared
function Module:ClearCache()
    -- Reset the cache
    processedMessageCache = setmetatable({}, {
        __mode = "k",  -- weak keys to allow garbage collection
        __index = function(t, k) return nil end
    })
    
    -- Update the global reference
    Phoenix_UI.ChatEmojiCache = processedMessageCache
    
    -- Reset counter
    cacheCount = 0
    
    -- Return success
    return true
end

-- Replace emojis in a message
local function ReplaceEmojisInMessage(message, emojiSize)
    if not message or message == "" then
        return message
    end
    
    -- Skip messages that already have formatting to avoid issues
    if message:find("|c") or message:find("|r") or message:find("|H") or message:find("|h") or message:find("|T") then
        return message
    end
    
    -- Set default emoji size if not provided
    emojiSize = emojiSize or (Phoenix_UI.db and Phoenix_UI.db.profile and 
                           Phoenix_UI.db.profile.chat and 
                           Phoenix_UI.db.profile.chat.emoji and 
                           Phoenix_UI.db.profile.chat.emoji.size) or 16
    
    local replacedMessage = message
    for code, name in pairs(emojiMap) do
        if replacedMessage:find(code, 1, true) then -- Use plain search
            local emojiPath = EMOJI_PATH .. name .. ".tga"
            local textureString = "|T" .. emojiPath .. ":" .. emojiSize .. ":" .. emojiSize .. "|t"
            -- Must use gsub with plain argument set to true to avoid pattern matching
            replacedMessage = replacedMessage:gsub(code, textureString, 1, true)
        end
    end
    
    return replacedMessage
end