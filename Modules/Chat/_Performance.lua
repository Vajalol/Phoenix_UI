local Module = Phoenix_UI:NewModule("Chat.Performance");

function Module:OnEnable()
    local db = Phoenix_UI.db.profile.chat
    
    -- Initialize performance settings if not present
    if not db.performance then
        db.performance = {
            enabled = true,
            trimOldMessages = true,
            maxDaysToKeep = 7,
            compressHistory = true,
            virtualScrolling = true,
            throttleUpdates = true
        }
    end
    
    -- Exit if performance optimization is disabled
    if not db.performance.enabled then return end
    
    -- Add compression library
    local LibDeflate = LibStub:GetLibrary("LibDeflate") or {
        CompressDeflate = function(_, data) return data end,
        DecompressDeflate = function(_, data) return data end
    }
    
    -- Message compression system
    local compressionSystem = {
        -- Compresses a text message
        Compress = function(text)
            if not text or not db.performance.compressHistory then return text end
            
            -- Skip already compressed data
            if type(text) == "string" and text:sub(1, 2) == "\002\001" then
                return text
            end
            
            -- Compress with LibDeflate
            local compressed = LibDeflate:CompressDeflate(text)
            if compressed then
                -- Add compressed marker
                return "\002\001" .. compressed
            end
            
            return text
        end,
        
        -- Decompresses a text message
        Decompress = function(text)
            if not text then return text end
            
            -- Check if this is a compressed string
            if type(text) == "string" and text:sub(1, 2) == "\002\001" then
                -- Remove marker and decompress
                local compressed = text:sub(3)
                local decompressed = LibDeflate:DecompressDeflate(compressed)
                if decompressed then
                    return decompressed
                end
            end
            
            return text
        end
    }
    
    -- Add decompression method to module
    function Module:DecompressText(text)
        return compressionSystem.Decompress(text)
    end
    
    -- Also add compression method for symmetry
    function Module:CompressText(text)
        return compressionSystem.Compress(text)
    end
    
    -- Function to trim old messages based on timestamp
    local function TrimOldMessages()
        if not db.performance.trimOldMessages or not Phoenix_UI.chatHistory then return end
        
        -- Calculate cutoff timestamp (7 days old by default)
        local daysToKeep = db.performance.maxDaysToKeep or 7
        local cutoffTime = time() - (daysToKeep * 24 * 60 * 60)
        local messagesTrimmed = 0
        
        -- Process each chat frame's history
        for chatID, messages in pairs(Phoenix_UI.chatHistory) do
            local i = 1
            while i <= #messages do
                local msgData = messages[i]
                
                -- Remove messages older than cutoff
                if msgData and msgData.timestamp and msgData.timestamp < cutoffTime then
                    table.remove(messages, i)
                    messagesTrimmed = messagesTrimmed + 1
                else
                    i = i + 1
                end
            end
        end
        
        -- Log the cleanup if in debug mode
        if Phoenix_UI.debug and messagesTrimmed > 0 then
            print("|cffFF7D0APhoenix UI:|r Trimmed " .. messagesTrimmed .. " old chat messages.")
        end
    end
    
    -- Compress existing chat history
    local function CompressExistingHistory()
        if not db.performance.compressHistory or not Phoenix_UI.chatHistory then return end
        
        local messagesCompressed = 0
        
        -- Process each chat frame's history
        for chatID, messages in pairs(Phoenix_UI.chatHistory) do
            for i, msgData in ipairs(messages) do
                if msgData and msgData.text and type(msgData.text) == "string" and msgData.text:sub(1, 2) ~= "\002\001" then
                    -- Compress the message text
                    msgData.text = compressionSystem.Compress(msgData.text)
                    messagesCompressed = messagesCompressed + 1
                end
            end
        end
        
        -- Log the compression if in debug mode
        if Phoenix_UI.debug and messagesCompressed > 0 then
            print("|cffFF7D0APhoenix UI:|r Compressed " .. messagesCompressed .. " chat messages.")
        end
    end
    
    -- Apply compression to new messages when storing in history
    local function HookChatStorage()
        -- Get access to the original storage functionality
        -- We need to carefully integrate with _Core.lua's history feature
        if not Phoenix_UI.chatHistory then 
            Phoenix_UI.chatHistory = {}
            return
        end
        
        -- Hook the storage of new messages
        for i = 1, NUM_CHAT_WINDOWS do
            local chat = _G[format("ChatFrame%s", i)]
            if chat then
                -- Find and hook into the existing message storage
                hooksecurefunc(chat, "AddMessage", function(self, text, ...)
                    if not text or not Phoenix_UI.chatHistory then return end
                    
                    -- Skip system separators and already processed messages
                    if text:find("---- Chat History ----") or 
                       text:find("---- End of History ----") or
                       text:sub(1, 2) == "\002\001" then
                        return
                    end
                    
                    -- Find this message in history to compress it
                    local chatID = self:GetID()
                    if Phoenix_UI.chatHistory[chatID] then
                        for j = #Phoenix_UI.chatHistory[chatID], 1, -1 do
                            local msgData = Phoenix_UI.chatHistory[chatID][j]
                            
                            -- Match the uncompressed text
                            if msgData and msgData.text == text then
                                -- Compress it
                                msgData.text = compressionSystem.Compress(text)
                                break
                            end
                        end
                    end
                end)
                
                -- If the chat has a virtual scrolling frame, we need to handle decompression
                if db.performance.virtualScrolling then
                    -- When getting chat message info, decompress if needed
                    local originalGetMessageInfo = chat.GetMessageInfo
                    if originalGetMessageInfo then
                        chat.GetMessageInfo = function(self, index)
                            local text, accessID, lineID, extraData = originalGetMessageInfo(self, index)
                            
                            -- Decompress if needed
                            if text and text:sub(1, 2) == "\002\001" then
                                text = compressionSystem.Decompress(text)
                            end
                            
                            return text, accessID, lineID, extraData
                        end
                    end
                end
            end
        end
    end
    
    -- Function to throttle rapid chat updates
    local function SetupUpdateThrottling()
        if not db.performance.throttleUpdates then return end
        
        -- Create a frame for throttling
        local throttleFrame = CreateFrame("Frame")
        local updateQueued = false
        local lastUpdateTime = 0
        local THROTTLE_INTERVAL = 0.1 -- seconds
        
        -- Function to process queued updates
        local function ProcessUpdates()
            updateQueued = false
            for i = 1, NUM_CHAT_WINDOWS do
                local chatFrame = _G["ChatFrame" .. i]
                if chatFrame and chatFrame.ScrollToBottom then
                    -- Avoid locking up with too many messages
                    if chatFrame:AtBottom() then
                        chatFrame:ScrollToBottom()
                    end
                end
            end
        end
        
        -- Throttle chat frame updates
        for i = 1, NUM_CHAT_WINDOWS do
            local chatFrame = _G["ChatFrame" .. i]
            if chatFrame then
                -- Hook the scroll-to-bottom functionality
                local originalScrollToBottom = chatFrame.ScrollToBottom
                if originalScrollToBottom then
                    chatFrame.ScrollToBottom = function(self)
                        -- If we're not already queued and throttling is active
                        if not updateQueued and GetTime() - lastUpdateTime > THROTTLE_INTERVAL then
                            -- Do immediate update
                            lastUpdateTime = GetTime()
                            return originalScrollToBottom(self)
                        else
                            -- Queue update
                            if not updateQueued then
                                updateQueued = true
                                C_Timer.After(THROTTLE_INTERVAL, ProcessUpdates)
                            end
                        end
                    end
                end
            end
        end
    end
    
    -- Function to improve chat frame performance with virtual scrolling
    local function SetupVirtualScrolling()
        if not db.performance.virtualScrolling then return end
        
        -- Already well-optimized in modern WoW, but we can further improve by:
        -- 1. Limiting displayed messages when not at the bottom
        -- 2. Progressively loading history when scrolling up
        
        for i = 1, NUM_CHAT_WINDOWS do
            local chatFrame = _G["ChatFrame" .. i]
            if chatFrame then
                -- Adjust max history lines to improve performance
                local maxDisplayed = chatFrame:GetMaxLines()
                
                -- Store original GetNumMessages function
                local originalGetNumMessages = chatFrame.GetNumMessages
                
                -- Cached values to avoid constant recalculation
                local isAtBottom = true
                local cachedNumMessages = originalGetNumMessages(chatFrame)
                local displayedLines = math.min(maxDisplayed, cachedNumMessages)
                
                -- Hook GetNumMessages to limit results when not at bottom
                chatFrame.GetNumMessages = function(self)
                    -- Always return actual message count when scrolled to bottom
                    if isAtBottom then
                        cachedNumMessages = originalGetNumMessages(self)
                        return cachedNumMessages
                    end
                    
                    -- When scrolled up, only return visible messages plus a small buffer
                    return math.min(displayedLines, originalGetNumMessages(self))
                end
                
                -- Track scroll position changes
                if chatFrame.UpdateScrollingExtents then
                    hooksecurefunc(chatFrame, "UpdateScrollingExtents", function(self)
                        -- Update our at-bottom tracking
                        isAtBottom = self:AtBottom()
                        
                        -- When scrolled to bottom, update displayed count
                        if isAtBottom then
                            cachedNumMessages = originalGetNumMessages(self)
                            displayedLines = cachedNumMessages
                        end
                    end)
                else
                    -- Alternative implementation for chat frames without UpdateScrollingExtents
                    local scrollFrame = chatFrame.ScrollBar or chatFrame:GetParent().ScrollBar
                    if scrollFrame then
                        -- Add scroll event handling with proper type checking
                        if scrollFrame.GetValue and scrollFrame.SetScript and scrollFrame:GetObjectType() == "Slider" then
                            -- This is a proper slider with OnValueChanged
                            scrollFrame:HookScript("OnValueChanged", function(_, value)
                                -- Update at-bottom state
                                isAtBottom = (value <= 0.01)
                                
                                -- When scrolled to bottom, update displayed count
                                if isAtBottom then
                                    cachedNumMessages = originalGetNumMessages(chatFrame)
                                    displayedLines = cachedNumMessages
                                end
                            end)
                        elseif scrollFrame.GetVerticalScroll and scrollFrame.SetScript then
                            -- This is a ScrollFrame, hook OnScrollChanged instead
                            scrollFrame:HookScript("OnScrollChanged", function()
                                local scrollValue = scrollFrame:GetVerticalScroll()
                                local maxScroll = scrollFrame:GetVerticalScrollRange()
                                
                                -- Update at-bottom state
                                isAtBottom = (maxScroll <= 0 or scrollValue >= maxScroll - 2)
                                
                                -- When scrolled to bottom, update displayed count
                                if isAtBottom then
                                    cachedNumMessages = originalGetNumMessages(chatFrame)
                                    displayedLines = cachedNumMessages
                                end
                            end)
                        elseif scrollFrame.scrollBar and scrollFrame.scrollBar.GetValue then
                            -- Some chat frames have a nested structure
                            scrollFrame.scrollBar:HookScript("OnValueChanged", function(_, value)
                                -- Update at-bottom state
                                isAtBottom = (value <= 0.01)
                                
                                -- When scrolled to bottom, update displayed count
                                if isAtBottom then
                                    cachedNumMessages = originalGetNumMessages(chatFrame)
                                    displayedLines = cachedNumMessages
                                end
                            end)
                        end
                        
                        -- Fallback - track scrolling via frame update
                        chatFrame:HookScript("OnUpdate", function()
                            -- Only check occasionally for performance
                            if not chatFrame.lastScrollCheck or GetTime() - chatFrame.lastScrollCheck > 0.2 then
                                chatFrame.lastScrollCheck = GetTime()
                                
                                -- Detect being at bottom via various means
                                local atBottom = chatFrame:AtBottom()
                                if atBottom ~= isAtBottom then
                                    isAtBottom = atBottom
                                    
                                    -- When scrolled to bottom, update displayed count
                                    if isAtBottom then
                                        cachedNumMessages = originalGetNumMessages(chatFrame)
                                        displayedLines = cachedNumMessages
                                    end
                                end
                            end
                        end)
                    end
                    
                    -- Additional hook to update isAtBottom when messages are added
                    hooksecurefunc(chatFrame, "AddMessage", function()
                        -- Get scroll position to determine if at bottom
                        local scrollBar = chatFrame.ScrollBar or chatFrame:GetParent().ScrollBar
                        if scrollBar then
                            -- Different scroll types have different ways to check if at bottom
                            local atBottom = false
                            
                            -- Check if frame has built-in AtBottom method first
                            if chatFrame.AtBottom and type(chatFrame.AtBottom) == "function" then
                                atBottom = chatFrame:AtBottom()
                            -- Try ScrollBar with GetValue method
                            elseif scrollBar.GetValue and type(scrollBar.GetValue) == "function" then
                                atBottom = (scrollBar:GetValue() <= 0.01)
                            -- Try ScrollBar with CalculateScrollExtent method
                            elseif scrollBar.CalculateScrollExtent and type(scrollBar.CalculateScrollExtent) == "function" then
                                local currentValue, maxScrollRange = scrollBar:CalculateScrollExtent()
                                atBottom = (currentValue <= 0.01)
                            -- Try GetVerticalScroll if it's a ScrollFrame
                            elseif scrollBar.GetVerticalScroll and type(scrollBar.GetVerticalScroll) == "function" then
                                local currentScroll = scrollBar:GetVerticalScroll()
                                local maxScroll = scrollBar:GetVerticalScrollRange() or 0
                                atBottom = (maxScroll <= 0 or currentScroll >= maxScroll - 2)
                            -- Default to true as a fallback
                            else
                                atBottom = true
                            end
                            
                            -- Update state if changed
                            if atBottom ~= isAtBottom then
                                isAtBottom = atBottom
                                
                                -- When scrolled to bottom, update displayed count
                                if isAtBottom then
                                    cachedNumMessages = originalGetNumMessages(chatFrame)
                                    displayedLines = cachedNumMessages
                                end
                            end
                        end
                    end)
                end
                
                -- Hook scroll up to progressively load messages
                local originalScrollUp = chatFrame.ScrollUp
                chatFrame.ScrollUp = function(self, count)
                    -- Increase visible message count when scrolling up
                    displayedLines = math.min(displayedLines + (count or 1) * 5, originalGetNumMessages(self))
                    return originalScrollUp(self, count)
                end
            end
        end
    end
    
    -- Schedule regular maintenance
    local function ScheduleMaintenance()
        -- Create maintenance frame
        local maintenanceFrame = CreateFrame("Frame")
        local MAINTENANCE_INTERVAL = 3600 -- 1 hour in seconds
        
        -- Initialize timer
        local elapsed = 0
        
        -- Setup update function
        maintenanceFrame:SetScript("OnUpdate", function(self, delta)
            elapsed = elapsed + delta
            
            -- Run maintenance once per hour
            if elapsed >= MAINTENANCE_INTERVAL then
                elapsed = 0
                
                -- Run memory optimizations
                TrimOldMessages()
                CompressExistingHistory()
                
                -- Force garbage collection
                collectgarbage("collect")
            end
        end)
    end
    
    -- Initialize performance optimizations
    TrimOldMessages()
    CompressExistingHistory()
    HookChatStorage()
    SetupUpdateThrottling()
    SetupVirtualScrolling()
    ScheduleMaintenance()
    
    -- Announce in debug mode
    if Phoenix_UI.debug then
        print("|cffFF7D0APhoenix UI:|r Chat performance optimizations enabled.")
    end
end 