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

-- Function to replace emoji codes with textures in a message
local function ReplaceEmojis(text, forSendChat)
    if not text or text == "" then return text end
    
    -- Skip complex messages that would break with texture replacement
    -- More thorough check for any potential special formatting
    if text:find("|H") or           -- Hyperlinks
       text:find("|c%x%x%x%x%x%x%x%x") or -- Color codes
       text:find("|r") or           -- Color resets
       text:find("|T.-|t") or       -- Existing textures
       text:find("Professions") or  -- Profession links
       text:find("ChatlIcon") or    -- Chat icons
       text:find("||") then         -- Escaped pipes
        return text
    end
    
    local result = text
    for code, textures in pairs(emojiTextures) do
        -- Escape pattern characters
        local escapedCode = code:gsub("([%(%)%.%%%+%-%*%?%[%]%^%$])", "%%%1")
        
        -- Use the escaped version for SendChatMessage, display version otherwise
        local replacement = forSendChat and textures.escaped or textures.display
        result = result:gsub(escapedCode, replacement)
    end
    
    -- Safety check - if we ended up with malformed formatting after replacement, return original
    if result:find("||") or 
       (not forSendChat and result:find("|[^cHhTr]")) or -- Detect broken formatting codes
       (not forSendChat and result:find("|$")) then -- Detect trailing pipe
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
            local processedText = ReplaceEmojis(text, true)
            -- Verify the processed text isn't corrupted
            if processedText and not processedText:find("||") then
                return originalSendChatMessage(processedText, chatType, ...)
            end
        end
    end
    
    -- Default: use original function with unmodified text
    return originalSendChatMessage(text, chatType, ...)
end

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
            size = 16
        }
        
        -- Make sure to save the settings
        if Phoenix_UI.SaveDB then
            Phoenix_UI:SaveDB()
        else
            -- Direct fallback - ensure global DB is updated
            if _G["Phoenix_UIDB"] and _G["Phoenix_UIDB"].profiles then
                local currentProfile = Phoenix_UI.db.keys and Phoenix_UI.db.keys.profile or "Default"
                if _G["Phoenix_UIDB"].profiles[currentProfile] then
                    if not _G["Phoenix_UIDB"].profiles[currentProfile].chat then
                        _G["Phoenix_UIDB"].profiles[currentProfile].chat = {}
                    end
                    _G["Phoenix_UIDB"].profiles[currentProfile].chat.emoji = CopyTable(db.emoji)
                end
            end
            
            -- Force save to disk if possible
            if FlushSavedVariables then
                FlushSavedVariables()
            end
        end
    end
    
    -- Exit if emojis are disabled
    if not db.emoji.enabled then 
        return 
    end
    
    -- Initialize emoji textures
    InitializeEmojis()
    
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
                local frames = emojiTextures[":flame:"].frames
                
                -- Show animation frames
                for i, framePath in ipairs(frames) do
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
        
        -- Test direct SendChatMessage
        print("Attempting direct SendChatMessage with escaped texture...")
        SendChatMessage("Test with escaped emoji: " .. escapedTexture, "EMOTE")
    end
    
    -- Announce emoji system is enabled with debug status
    if Phoenix_UI.debug then
        print("|cffFF7D0APhoenix UI:|r Emoji system enabled using SendChatMessage hook approach")
    end
end 