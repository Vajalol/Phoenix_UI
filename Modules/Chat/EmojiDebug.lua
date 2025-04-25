-- Simple Debug Module for Emoji Rendering
-- This standalone module will test emoji rendering in isolation

-- Create a slash command to test emoji rendering
SLASH_EMOJIDEBUG1 = "/emojidebug"
SlashCmdList["EMOJIDEBUG"] = function(msg)
    -- Create a direct emoji texture to test rendering
    local emojiPath = "Interface\\AddOns\\Phoenix_UI\\Modules\\Chat\\Emojis\\"
    local emojiSize = 16
    
    -- Create test textures with different formats
    local textureFormat1 = "|T" .. emojiPath .. "Smile.tga:" .. emojiSize .. ":" .. emojiSize .. "|t"
    local textureFormat2 = "|T" .. emojiPath .. "Angry.tga:" .. emojiSize .. ":" .. emojiSize .. ":0:0:0:0:0:0:0:0|t"
    local textureFormat3 = "|cffFF7D0A|T" .. emojiPath .. "Thinking.tga:" .. emojiSize .. ":" .. emojiSize .. "|t|r"
    
    -- Get first chat frame
    local chatFrame = DEFAULT_CHAT_FRAME
    
    -- Print test messages
    chatFrame:AddMessage("=== EMOJI DEBUG ===")
    chatFrame:AddMessage("Basic format: " .. textureFormat1)
    chatFrame:AddMessage("Extended format: " .. textureFormat2)
    chatFrame:AddMessage("Colored format: " .. textureFormat3)
    chatFrame:AddMessage("Custom test: |TInterface\\TargetingFrame\\UI-RaidTargetingIcon_1:14:14|t")
    chatFrame:AddMessage("=== END DEBUG ===")
    
    -- Print debug info about chat module status
    chatFrame:AddMessage("Debug info:")
    chatFrame:AddMessage("- Emoji processing: " .. (Phoenix_UI.db.profile.chat.emoji.enabled and "Enabled" or "Disabled"))
    chatFrame:AddMessage("- Social module: " .. (Phoenix_UI.db.profile.chat.social and Phoenix_UI.db.profile.chat.social.enabled and "Enabled" or "Disabled"))
    chatFrame:AddMessage("- Role icons: " .. (Phoenix_UI.db.profile.chat.roleIcons and Phoenix_UI.db.profile.chat.roleIcons.enabled and "Enabled" or "Disabled"))
    
    print("Emoji debug test complete. Check your chat window for results.")
end

-- Print a message when addon loads to notify user about the debug command
local frame = CreateFrame("Frame")
frame:RegisterEvent("PLAYER_LOGIN")
frame:SetScript("OnEvent", function()
    print("|cffFF7D0APhoenix UI:|r Emoji debug available. Type |cffFFFF00/emojidebug|r to test emoji rendering.")
end)
