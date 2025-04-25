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
    
    -- Skip more complex messages that would break with texture replacement
    -- IMPORTANT: We need to be very careful with messages containing formatting
    
    -- Skip messages with item/spell links
    if text:find("|H") then return text end
    
    -- Skip messages with color codes 
    if text:find("|c") then return text end
    
    -- Skip messages with existing textures
    if text:find("|T") then return text end
    
    -- Skip messages with other formatting codes
    if text:find("|r") then return text end
    
    -- Safety check for invalid escape sequences
    if text:find("||") then return text end
    
    -- Only allow replacing emojis when displaying, not when sending
    -- This is crucial to avoid the "Invalid escape code in chat message" error
    if forSendChat then
        -- IMPORTANT: For sending, we should not try to add texture escape sequences
        -- We'll simply return the original text
        return text
    end
    
    -- For display in chat, we can safely replace emoji codes with textures
    local result = text
    -- Track if the message has been modified
    local modified = false
    
    -- Process each emoji code
    for code, emoji in pairs(emojiTextures) do
        if result:find(code, 1, true) then
            -- Text patterns are literal strings, need to escape special chars
            local pattern = code:gsub("([%^%$%(%)%%%.%[%]%*%+%-%?])", "%%%1")
            -- For display, we can safely use the display texture
            local replacement = emoji.display
            
            -- Only do string.gsub if we actually have a match
            local newResult, replacements = result:gsub(pattern, replacement)
            if replacements > 0 and newResult ~= result then
                result = newResult
                modified = true
            end
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
    
    -- Skip messages with broken formatting that could result from emoji replacement
    if result:find("||") or result:find("|[^cHhTr]") or result:find("|$") then
        return text
    end
    
    return result
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

-- Replace emojis in outgoing chat messages
local function HookSendChatMessage(text, chatType, ...)
    -- Skip processing for addon/system messages and non-player chat
    local safeTypes = {
        SAY = true, YELL = true, PARTY = true, RAID = true, 
        GUILD = true, OFFICER = true, WHISPER = true, 
        CHANNEL = true, INSTANCE_CHAT = true
    }
    
    -- Only process player chat messages that don't contain special formatting
    if text and safeTypes[chatType] and not text:find("|") and not text:find("\124") then
        -- Only process messages that potentially have emoji codes
        -- Check if the message has at least one emoji code before processing
        local hasEmoji = false
        for code, _ in pairs(emojiTextures) do
            if text:find(code) then
                hasEmoji = true
                break
            end
        end
        
        -- Only process if message actually contains emoji codes
        if hasEmoji then
            -- IMPORTANT: We CANNOT send texture escape sequences directly with SendChatMessage
            -- Instead, we need to add a special identifier that the chat filter will recognize
            
            -- Method 1: Use a simpler approach - just pass the original text
            -- The visual representation will be handled by the chat filters
            return originalSendChatMessage(text, chatType, ...)
            
            -- NOTE: The actual emoji replacement is now handled by the chat message display filter
            -- which converts emoji codes to textures when messages are displayed in chat
        end
    end
    
    -- Default: use original function with unmodified text
    return originalSendChatMessage(text, chatType, ...)
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
    
    -- Set up chat message display filtering
    local function SetupChatFilters()
        -- Store original AddMessage function for each chat frame
        local originalAddMessage = {}
        
        -- Function to filter and process chat messages for emojis
        local function FilterMessageForEmojis(self, text, ...)
            -- Skip non-text messages
            if not text or type(text) ~= "string" then
                return originalAddMessage[self](self, text, ...)
            end
            
            -- Process the text through emoji replacer
            local processedText = ReplaceEmojis(text, false)
            
            -- Call original handler with processed text
            return originalAddMessage[self](self, processedText, ...)
        end
        
        -- Hook all chat frames
        for i = 1, NUM_CHAT_WINDOWS do
            local chatFrame = _G["ChatFrame" .. i]
            if chatFrame and chatFrame.AddMessage then
                -- Store original function
                originalAddMessage[chatFrame] = chatFrame.AddMessage
                
                -- Replace with our filtered version
                chatFrame.AddMessage = function(self, text, ...)
                    return FilterMessageForEmojis(self, text, ...)
                end
            end
        end
    end
    
    -- Set up chat filters after a brief delay to ensure UI is fully loaded
    C_Timer.After(1, SetupChatFilters)
    
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
    SendChatMessage = HookSendChatMessage
    
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
        print("|cffFF7D0APhoenix UI:|r Emoji system enabled using SendChatMessage hook approach")
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