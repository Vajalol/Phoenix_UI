local Module = Phoenix_UI:NewModule("Chat.Organize");

function Module:OnEnable()
    local db = Phoenix_UI.db.profile.chat
    
    -- Initialize organization settings if not present
    if not db.organize then
        db.organize = {
            enabled = true,
            collapseLoot = true,
            collapseRepeat = true,
            categories = true
        }
    end
    
    -- Exit if organization is disabled
    if not db.organize.enabled then return end
    
    -- Track repeat messages for collapsing
    local prevMessages = {}
    local repeatCounts = {}
    
    -- Message categories with colors
    local categories = {
        loot = {
            color = "FFE49B51", -- Orange
            patterns = {
                "You receive loot", 
                "You create", 
                "You receive", 
                "You won"
            }
        },
        combat = {
            color = "FFFF5151", -- Red
            patterns = {
                "Your .+ hits", 
                "Your .+ crits", 
                "You hit", 
                "You crit",
                "You gain %d+ "
            }
        },
        system = {
            color = "FF77A7E1", -- Blue
            patterns = {
                "You are now", 
                "You have joined", 
                "You leave", 
                "Discovered",
                "You earned"
            }
        },
        achievement = {
            color = "FFFFD200", -- Gold
            patterns = {
                "has earned the achievement"
            }
        }
    }
    
    -- Pattern for item links
    local itemLinkPattern = "|c%x+|Hitem:[^|]+|h%[[^%]]+%]|h|r"
    
    -- Function to get message category
    local function GetMessageCategory(text)
        if not text then return nil end
        
        -- Check each category's patterns
        for categoryName, categoryData in pairs(categories) do
            for _, pattern in ipairs(categoryData.patterns) do
                if text:match(pattern) then
                    return categoryName, categoryData.color
                end
            end
        end
        
        return nil
    end
    
    -- Function to create a tag for the message
    local function CreateCategoryTag(category, color)
        if not category or not color then return "" end
        
        local categoryText = category:sub(1, 1):upper() .. category:sub(2)
        return string.format("|cFF%s[%s]|r ", color, categoryText)
    end
    
    -- Function to collapse similar loot items
    local function CollapseLootMessages(text)
        if not db.organize.collapseLoot then return text end
        
        -- Match loot notifications with item links
        if text:find("You receive loot") or text:find("You received") then
            -- Extract item link from the message
            local itemLink = text:match(itemLinkPattern)
            if itemLink then
                -- Check for recently seen identical items
                for i = 1, #prevMessages do
                    local prevMsg = prevMessages[i]
                    -- Match if message has the same item link
                    if prevMsg and prevMsg:find(itemLink, 1, true) and 
                       (prevMsg:find("You receive loot", 1, true) or 
                        prevMsg:find("You received", 1, true)) then
                        
                        -- Increment count for this type of item
                        repeatCounts[itemLink] = (repeatCounts[itemLink] or 1) + 1
                        
                        -- Replace with a condensed version
                        return string.format("%s (x%d)", text, repeatCounts[itemLink])
                    end
                end
                
                -- First occurrence of this item
                repeatCounts[itemLink] = 1
            end
        end
        
        return text
    end
    
    -- Function to collapse repeated identical messages
    local function CollapseRepeatedMessage(newMessage, frameID)
        if not db.organize.collapseRepeat then return newMessage end
        
        -- Get the 5 most recent messages for this frame
        local recentMessages = prevMessages[frameID] or {}
        
        -- Check if this message is identical to one of the recent ones
        for i = 1, #recentMessages do
            local text, count = unpack(recentMessages[i])
            
            -- Compare with stripping colors and counts
            local strippedNew = newMessage:gsub("|c%x%x%x%x%x%x%x%x", ""):gsub("|r", ""):gsub(" %(x%d+%)", "")
            local strippedOld = text:gsub("|c%x%x%x%x%x%x%x%x", ""):gsub("|r", ""):gsub(" %(x%d+%)", "")
            
            if strippedNew == strippedOld then
                -- Update the count
                count = count + 1
                recentMessages[i][2] = count
                
                -- Add count to message display
                if not newMessage:find(" %(x%d+%)") then
                    newMessage = newMessage .. string.format(" (x%d)", count)
                else
                    newMessage = newMessage:gsub(" %(x%d+%)", string.format(" (x%d)", count))
                end
                
                -- Replace original message's display directly in the frame
                return newMessage, true -- Return true to indicate a repeated message
            end
        end
        
        -- New message, add to tracking
        if not prevMessages[frameID] then
            prevMessages[frameID] = {}
        end
        
        -- Add to front, limiting to 10 messages per frame
        table.insert(prevMessages[frameID], 1, {newMessage, 1})
        if #prevMessages[frameID] > 10 then
            table.remove(prevMessages[frameID])
        end
        
        return newMessage, false
    end
    
    -- Organize messages in chat frames
    for i = 1, NUM_CHAT_WINDOWS do
        local chatFrame = _G["ChatFrame" .. i]
        if chatFrame then
            -- Store original AddMessage function
            local originalAddMessage = chatFrame.AddMessage
            
            -- Hook AddMessage to organize messages
            chatFrame.AddMessage = function(self, text, ...)
                if not text then return originalAddMessage(self, text, ...) end
                
                -- Skip messages with profession quality info to prevent conflicts
                if text:find("Professions%-ChatlIcon%-Quality%-Tier") then
                    return originalAddMessage(self, text, ...)
                end
                
                -- Skip class color messages and other UI messages
                if text:find("|c%x%x%x%x%x%x%x%x", 1, false) and text:find("|r", 1, true) then
                    -- Check if it's a system message or player message
                    local skipProcessing = text:find("|Hplayer:", 1, true) or
                                           text:find("says:", 1, true) or
                                           text:find("yells:", 1, true) or
                                           text:find("whispers:", 1, true) or
                                           text:find("|Hitem:", 1, true)
                    
                    if skipProcessing then
                        return originalAddMessage(self, text, ...)
                    end
                end
                
                -- Apply category tagging if enabled
                if db.organize.categories then
                    local category, color = GetMessageCategory(text)
                    if category then
                        text = CreateCategoryTag(category, color) .. text
                    end
                end
                
                -- Collapse loot messages
                text = CollapseLootMessages(text)
                
                -- Check for repeated messages
                local modifiedText, isRepeat = CollapseRepeatedMessage(text, self:GetID())
                
                -- If it's a repeat and already visible in the window, don't add again
                if isRepeat then
                    -- Attempt to update the existing message in the visible chat frames
                    -- This is a bit of a hack since we can't easily modify existing messages
                    -- Instead, we'll add a new one but with a flag for the UI to handle it
                    return originalAddMessage(self, modifiedText, ...)
                end
                
                -- Pass the modified message to the original function
                return originalAddMessage(self, modifiedText, ...)
            end
        end
    end
    
    -- Add special handling for achievement announcements
    local achievementFrame = CreateFrame("Frame")
    achievementFrame:RegisterEvent("ACHIEVEMENT_EARNED")
    achievementFrame:SetScript("OnEvent", function(self, event, achievementID, ...)
        if not db.organize.categories then return end
        
        C_Timer.After(0.1, function()
            -- Find the achievement message in recent chat history
            for i = 1, NUM_CHAT_WINDOWS do
                local chatFrame = _G["ChatFrame" .. i]
                if chatFrame then
                    -- We can't modify messages already added, but we can
                    -- help future ones be properly tagged
                    local achievementInfo = GetAchievementInfo(achievementID)
                    if achievementInfo then
                        local achievementName = achievementInfo
                        -- Add this achievement to the special tracking for future tagging
                        categories.achievement.patterns[#categories.achievement.patterns + 1] = 
                            "has earned the achievement " .. achievementName
                    end
                end
            end
        end)
    end)
    
    -- Initialize and announce
    -- Debug messages removed to prevent login spam
end 