-- Register the main Chat module
local MainChatModule = Phoenix_UI:NewModule("Chat")

-- Initialize the main Chat module
function MainChatModule:OnInitialize()
    -- Initialize chat settings if they don't exist
    if Phoenix_UI.db and Phoenix_UI.db.profile then
        if not Phoenix_UI.db.profile.chat then
            Phoenix_UI.db.profile.chat = {}
        end
    end
end

-- Enable functionality when the module is enabled
function MainChatModule:OnEnable()
    -- Register this module as active
    if Phoenix_UI.moduleInitializationStatus then
        Phoenix_UI.moduleInitializationStatus["Chat"] = "initialized"
    end
end

local Module = Phoenix_UI:NewModule("Chat.Utils")

-- Initialize the module
function Module:OnInitialize()
    -- Initialize global ChatEmojiHandlers table
    Phoenix_UI.ChatEmojiHandlers = {}
    
    -- Make sure default chat settings exist
    if Phoenix_UI.db and Phoenix_UI.db.profile then
        -- Initialize chat settings if they don't exist
        if not Phoenix_UI.db.profile.chat then
            Phoenix_UI.db.profile.chat = {}
        end
        
        local chat = Phoenix_UI.db.profile.chat
        
        -- Initialize emoji settings if not present
        if not chat.emoji then
            chat.emoji = {
                enabled = true,
                size = 16
            }
            
            -- Save changes to database
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
                        _G["Phoenix_UIDB"].profiles[currentProfile].chat.emoji = CopyTable(chat.emoji)
                    end
                end
            end
        end
    end
end

-- Process chat messages - exported as a module function for use by other modules
function Module:ProcessChatMessage(frame, event, message, ...)
    local varargs = {...}
    
    -- Check emoji settings in the database instead of using a global flag
    local db = Phoenix_UI.db and Phoenix_UI.db.profile and Phoenix_UI.db.profile.chat
    local emojisDisabled = not (db and db.emoji and db.emoji.enabled)
    
    -- Skip when emojis are disabled
    if emojisDisabled then
        return false
    end
    
    -- Don't skip formatted messages anymore
    -- This allows emoji processing in messages with links, colors, etc.
    
    -- Process chat message with various emoji handlers
    -- This is called by other modules through the ChatFrame filter
    local success, result = pcall(function()
        -- Apply emoji replacements from modules
        if message then
            -- Preserve trade formatting
            if event == "CHAT_MSG_CHANNEL" and select(9, unpack(varargs)) == 2 then
                -- Don't modify trade messages that have complex formatting
                if message:find("|") then
                    return false
                end
            end
            
            -- Process message through registered emoji handlers
            local processed = false
            local processedMessage = message
            
            for _, handler in pairs(Phoenix_UI.ChatEmojiHandlers or {}) do
                if type(handler) == "function" then
                    local status, newMessage = pcall(handler, processedMessage)
                    if status and newMessage then
                        processedMessage = newMessage
                        processed = true
                    end
                end
            end
            
            -- Only return modified message if something changed
            if processed then
                return false, processedMessage, unpack(varargs)
            end
        end
        
        return false
    end)
    
    if not success then
        if Phoenix_UI.debug then
            Phoenix_UI:Print("Error processing chat message: " .. tostring(result))
        end
        return false
    end
    
    return result
end

-- Register slash command for debugging
SLASH_PHOENIXCHATDEBUG1 = "/phoenixchatdebug"
SlashCmdList["PHOENIXCHATDEBUG"] = function(msg)
    print("|cffFF7D0APhoenix UI Chat Debug:|r Starting chat texture debugging...")
    
    -- Test different texture string formats
    local emojiPath = "Interface\\AddOns\\Phoenix_UI\\Modules\\Chat\\Emojis\\Smile.tga"
    
    print("Testing format 1: |T" .. emojiPath .. ":16:16|t")
    print("Testing format 2: |T" .. emojiPath .. ":16:16:0:0|t")
    print("Testing format 3: |T" .. emojiPath .. ":16:16:0:0:64:64:5:59:5:59|t")
    
    -- Check path detection
    local testMsg = "This has a texture |T" .. emojiPath .. ":16:16|t in it"
    print("Path detection test: ", testMsg:find("Phoenix_UI\\Modules\\Chat\\Emojis") and "FOUND" or "NOT FOUND")
    
    -- Verify emoji file existence
    print("Does the file exist? Verify in game with /script print(GetFileIDFromPath(\"" .. emojiPath .. "\"))")
end

function Module:OnEnable()
    -- Register only a basic filter to avoid conflicts with emoji processing
    for _, event in pairs({
        "CHAT_MSG_SAY", "CHAT_MSG_YELL", "CHAT_MSG_WHISPER", "CHAT_MSG_WHISPER_INFORM",
        "CHAT_MSG_GUILD", "CHAT_MSG_OFFICER", "CHAT_MSG_PARTY", "CHAT_MSG_PARTY_LEADER",
        "CHAT_MSG_RAID", "CHAT_MSG_RAID_LEADER", "CHAT_MSG_RAID_WARNING", 
        "CHAT_MSG_INSTANCE_CHAT", "CHAT_MSG_INSTANCE_CHAT_LEADER", "CHAT_MSG_BN_WHISPER",
        "CHAT_MSG_BN_WHISPER_INFORM", "CHAT_MSG_CHANNEL", "CHAT_MSG_BN_CONVERSATION"
    }) do
        -- Use our ProcessChatMessage function directly in the filter
        ChatFrame_AddMessageEventFilter(event, function(f, e, msg, ...)
            -- Skip processing if message contains emoji textures
            if msg and msg:find("|T.-AddOns\\Phoenix_UI\\Modules\\Chat\\Emojis") then
                return false, msg, ...
            end
            
            -- Otherwise process normally
            return self:ProcessChatMessage(f, e, msg, ...)
        end)
    end
    
    -- Announce loaded status
    if Phoenix_UI.debug then
        print("|cffFF7D0APhoenix UI:|r Chat utils enabled. Type /phoenixchatdebug for diagnostics.")
    end
end 