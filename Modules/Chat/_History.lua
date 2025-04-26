---@class PhoenixUI_ChatHistoryModule : AceModule
local Module = Phoenix_UI:NewModule("Chat.History");

function Module:OnEnable()
    local db = Phoenix_UI.db.profile.chat
    
    -- Initialize history settings if not present
    if not db.history then
        db.history = {
            enabled = true,
            lines = 500,
            advancedSearch = true,
            maxSearchResults = 100
        }
    elseif db.history.advancedSearch == nil then
        db.history.advancedSearch = true
    end
    
    -- Add default search result limit if missing
    if not db.history.maxSearchResults then
        db.history.maxSearchResults = 100
    end
    
    -- Exit if chat history is disabled
    if not db.history.enabled then return end
    
    -- Search frame reference
    local searchFrame
    
    -- Add a cache for frequently accessed message history
    local historyCache = {}
    local function GetCachedHistory(chatID)
        if not historyCache[chatID] then
            -- Only cache if Phoenix_UI.chatHistory exists
            if Phoenix_UI.chatHistory and Phoenix_UI.chatHistory[chatID] then
                -- Create a filtered copy that contains only non-nil messages
                historyCache[chatID] = {}
                for i, msg in ipairs(Phoenix_UI.chatHistory[chatID]) do
                    if msg and msg.text then
                        table.insert(historyCache[chatID], msg)
                    end
                end
            else
                -- Return empty table if history doesn't exist
                return {}
            end
        end
        return historyCache[chatID]
    end
    
    -- Function to invalidate cache when history changes
    local function InvalidateHistoryCache(chatID)
        if chatID then
            historyCache[chatID] = nil
        else
            historyCache = {}
        end
    end
    
    -- Get timestamp text format
    local function GetTimeStampText(timestamp)
        if not timestamp then return "" end
        
        local date = date("*t", timestamp)
        if not date then return "" end
        
        return string.format("%02d/%02d %02d:%02d", 
            date.month, date.day, 
            date.hour, date.min)
    end
    
    -- Function to apply backdrop with proper API compatibility
    local function ApplyBackdrop(frame, r, g, b, a)
        -- Check for modern UI setting
        local useModernUI = db.performance and db.performance.useModernUI
        
        -- Ensure proper backdrop handling for Shadowlands+ compatibility
        if WOW_PROJECT_ID == WOW_PROJECT_MAINLINE and not frame.SetBackdrop then
            Mixin(frame, BackdropTemplateMixin)
        end
        
        -- Apply backdrop
        frame:SetBackdrop({
            bgFile = useModernUI and "Interface\\Buttons\\WHITE8X8" or "Interface\\DialogFrame\\UI-DialogBox-Background",
            edgeFile = useModernUI and "Interface\\Tooltips\\UI-Tooltip-Border" or "Interface\\DialogFrame\\UI-DialogBox-Border",
            edgeSize = 16,
            tile = true, 
            tileSize = 16,
            insets = { left = 4, right = 4, top = 4, bottom = 4 }
        })
        
        -- Apply colors
        if useModernUI then
            -- More modern, semi-transparent look
            frame:SetBackdropColor(r or 0.05, g or 0.05, b or 0.05, a or 0.85)
            frame:SetBackdropBorderColor(0.3, 0.3, 0.3, 0.8)
        else
            -- Classic look
            frame:SetBackdropColor(r or 0, g or 0, b or 0, a or 0.9)
            frame:SetBackdropBorderColor(0.5, 0.5, 0.5, 1)
        end
    end
    
    -- Create search UI
    local function CreateSearchFrame()
        if searchFrame then return searchFrame end
        
        -- Main frame
        local frame = CreateFrame("Frame", "Phoenix_ChatSearchFrame", UIParent, "BackdropTemplate")
        frame:SetSize(600, 400)
        frame:SetPoint("CENTER")
        frame:SetFrameStrata("DIALOG")
        
        -- Apply backdrop with compatibility handling
        ApplyBackdrop(frame)
        
        frame:EnableMouse(true)
        frame:SetMovable(true)
        frame:RegisterForDrag("LeftButton")
        frame:SetScript("OnDragStart", frame.StartMoving)
        frame:SetScript("OnDragStop", frame.StopMovingOrSizing)
        frame:Hide()
        
        -- Title
        local title = frame:CreateFontString(nil, "OVERLAY")
        title:SetPoint("TOPLEFT", 12, -12)
        title:SetFont(STANDARD_TEXT_FONT, 16)
        title:SetTextColor(1, 0.8, 0)
        title:SetText("Chat History Search")
        frame.title = title
        
        -- Close button
        local closeButton = CreateFrame("Button", nil, frame, "UIPanelCloseButton")
        closeButton:SetPoint("TOPRIGHT", -5, -5)
        
        -- Search box
        local searchBox = CreateFrame("EditBox", nil, frame, "SearchBoxTemplate")
        searchBox:SetSize(200, 20)
        searchBox:SetPoint("TOPLEFT", title, "BOTTOMLEFT", 0, -10)
        searchBox:SetAutoFocus(false)
        searchBox:SetMaxLetters(50)
        searchBox.Instructions:SetText("Search chat history...")
        frame.searchBox = searchBox
        
        -- Filter dropdown
        local filterDropdown = CreateFrame("Frame", nil, frame, "UIDropDownMenuTemplate")
        filterDropdown:SetPoint("TOPLEFT", searchBox, "TOPRIGHT", 0, -2)
        UIDropDownMenu_SetWidth(filterDropdown, 100)
        UIDropDownMenu_SetText(filterDropdown, "All Chats")
        
        -- Filter options
        UIDropDownMenu_Initialize(filterDropdown, function(self, level)
            local info = UIDropDownMenu_CreateInfo()
            
            info.text = "All Chats"
            info.value = "all"
            info.func = function()
                frame.filter = "all"
                UIDropDownMenu_SetText(filterDropdown, info.text)
            end
            info.checked = frame.filter == "all" or not frame.filter
            UIDropDownMenu_AddButton(info, level)
            
            for i = 1, NUM_CHAT_WINDOWS do
                local chatFrame = _G["ChatFrame" .. i]
                if chatFrame and chatFrame.name then
                    info.text = chatFrame.name
                    info.value = i
                    info.func = function()
                        frame.filter = i
                        UIDropDownMenu_SetText(filterDropdown, info.text)
                    end
                    info.checked = frame.filter == i
                    UIDropDownMenu_AddButton(info, level)
                end
            end
        end)
        frame.filterDropdown = filterDropdown
        
        -- Search button
        local searchButton = CreateFrame("Button", nil, frame, "UIPanelButtonTemplate")
        searchButton:SetSize(80, 22)
        searchButton:SetPoint("LEFT", filterDropdown, "RIGHT", 10, 0)
        searchButton:SetText("Search")
        searchButton:SetScript("OnClick", function()
            frame:PerformSearch()
        end)
        frame.searchButton = searchButton
        
        -- Results scroll frame
        local scrollFrame = CreateFrame("ScrollFrame", nil, frame, "UIPanelScrollFrameTemplate")
        scrollFrame:SetPoint("TOPLEFT", searchBox, "BOTTOMLEFT", 0, -10)
        scrollFrame:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT", -30, 10)
        frame.scrollFrame = scrollFrame
        
        -- Results content frame
        local content = CreateFrame("Frame", nil, scrollFrame)
        content:SetSize(scrollFrame:GetWidth(), 1000) -- Will be resized as needed
        scrollFrame:SetScrollChild(content)
        frame.content = content
        
        -- Method to perform search
        function frame:PerformSearch()
            -- Wrap search in pcall for error protection
            local success, result = pcall(function()
                local searchText = self.searchBox:GetText()
                if not searchText or searchText == "" then return end
                
                -- Clear previous results
                self:ClearResults()
                
                -- Get chat history
                local selectedFilter = self.filter or "all"
                local results = {}
                local totalFound = 0
                local maxResults = db.history.maxSearchResults or 100
                
                -- Process each chat frame's history
                for chatID = 1, NUM_CHAT_WINDOWS do
                    -- Skip if we're filtering to a specific chat and this isn't it
                    if selectedFilter == "all" or selectedFilter == chatID then
                        -- Get cached history for this chat ID for better performance
                        local history = GetCachedHistory(chatID)
                        
                        -- Skip empty history
                        if history and #history > 0 then
                            -- Convert search text to lowercase for case-insensitive matching
                            local searchTextLower = searchText:lower()
                            
                            -- Optimize search by using string.find with plain text search first
                            for i = #history, 1, -1 do -- Search from newest to oldest
                                local message = history[i]
                                
                                -- Skip nil entries (shouldn't happen with cache, but for safety)
                                if message and message.text then
                                    -- Remove color codes for matching
                                    local plainText = message.text:gsub("|c%x%x%x%x%x%x%x%x", ""):gsub("|r", "")
                                    
                                    -- Fast plain text search
                                    if plainText:lower():find(searchTextLower, 1, true) then
                                        table.insert(results, {
                                            chatID = chatID,
                                            text = message.text,
                                            timestamp = message.timestamp or 0,
                                            chatType = message.chatType or "SYSTEM"
                                        })
                                        totalFound = totalFound + 1
                                    end
                                end
                            end
                        end
                    end
                    
                    -- Early exit if we've hit the limit
                    if totalFound >= maxResults then 
                        -- Add a note that results were limited
                        if totalFound >= maxResults then
                            table.insert(results, {
                                chatID = 1,
                                text = "|cffFF7D0APhoenix UI:|r Search results limited to " .. maxResults .. " matches. Try a more specific search.",
                                timestamp = time(),
                                chatType = "SYSTEM"
                            })
                        end
                        break 
                    end
                end
                
                -- Display results
                self:DisplayResults(results)
            end)
            
            -- Error handling
            if not success and result then
                -- Show error in chat
                DEFAULT_CHAT_FRAME:AddMessage("|cffFF7D0APhoenix UI:|r Error in chat history search: " .. tostring(result))
            end
        end
        
        -- Method to clear results
        function frame:ClearResults()
            for i = 1, #self.content.results or {} do
                self.content.results[i]:Hide()
                self.content.results[i] = nil
            end
            self.content.results = {}
        end
        
        -- Method to display results
        function frame:DisplayResults(results)
            -- Initialize results array
            self.content.results = self.content.results or {}
            
            -- Update title with result count
            local resultCount = #results
            if resultCount == 0 then
                self.title:SetText("Chat History Search - No results found")
            elseif resultCount == 1 then
                self.title:SetText("Chat History Search - 1 result")
            else
                self.title:SetText("Chat History Search - " .. resultCount .. " results")
            end
            
            -- Sort by timestamp (newest first)
            table.sort(results, function(a, b) return a.timestamp > b.timestamp end)
            
            -- Create result frames
            local previousFrame
            for i, result in ipairs(results) do
                local resultFrame = CreateFrame("Frame", nil, self.content, "BackdropTemplate")
                resultFrame:SetSize(self.content:GetWidth() - 20, 60) -- Fixed height for now
                
                if i == 1 then
                    resultFrame:SetPoint("TOPLEFT", self.content, "TOPLEFT", 10, -10)
                else
                    resultFrame:SetPoint("TOPLEFT", previousFrame, "BOTTOMLEFT", 0, -5)
                end
                
                -- Apply backdrop with modern UI if enabled
                ApplyBackdrop(resultFrame, 0.1, 0.1, 0.1, 0.7)
                
                -- Chat name
                local chatName = _G["ChatFrame" .. result.chatID] and _G["ChatFrame" .. result.chatID].name or "Chat " .. result.chatID
                local header = resultFrame:CreateFontString(nil, "OVERLAY")
                header:SetFont(STANDARD_TEXT_FONT, 10)
                header:SetTextColor(0.7, 0.7, 1)
                header:SetPoint("TOPLEFT", resultFrame, "TOPLEFT", 8, -8)
                header:SetText(chatName .. " - " .. GetTimeStampText(result.timestamp))
                
                -- Message text
                local messageText = resultFrame:CreateFontString(nil, "OVERLAY")
                messageText:SetFont(STANDARD_TEXT_FONT, 11)
                messageText:SetTextColor(1, 1, 1)
                messageText:SetPoint("TOPLEFT", header, "BOTTOMLEFT", 0, -4)
                messageText:SetPoint("BOTTOMRIGHT", resultFrame, "BOTTOMRIGHT", -8, 8)
                messageText:SetJustifyH("LEFT")
                messageText:SetJustifyV("TOP")
                messageText:SetText(result.text)
                messageText:SetWordWrap(true)
                
                -- Copy button
                local copyButton = CreateFrame("Button", nil, resultFrame)
                copyButton:SetSize(16, 16)
                copyButton:SetPoint("TOPRIGHT", resultFrame, "TOPRIGHT", -8, -8)
                copyButton:SetNormalTexture("Interface\\Buttons\\UI-GuildButton-PublicNote-Up")
                copyButton:SetHighlightTexture("Interface\\Buttons\\UI-GuildButton-PublicNote-Highlight")
                
                copyButton:SetScript("OnClick", function()
                    -- Create editbox for copying
                    local editBox = ChatEdit_ChooseBoxForSend()
                    ChatEdit_ActivateChat(editBox)
                    editBox:SetText(result.text:gsub("|c%x%x%x%x%x%x%x%x", ""):gsub("|r", ""))
                    editBox:HighlightText()
                end)
                
                copyButton:SetScript("OnEnter", function(self)
                    GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
                    GameTooltip:SetText("Copy message")
                    GameTooltip:Show()
                end)
                
                copyButton:SetScript("OnLeave", function()
                    GameTooltip:Hide()
                end)
                
                -- Store reference
                table.insert(self.content.results, resultFrame)
                previousFrame = resultFrame
            end
            
            -- Update content height
            if previousFrame then
                self.content:SetHeight(previousFrame:GetBottom() * -1 + 20)
            end
        end
        
        -- Set up search box enter press
        searchBox:SetScript("OnEnterPressed", function()
            frame:PerformSearch()
        end)
        
        -- Set default filter
        frame.filter = "all"
        
        -- Return the created frame
        return frame
    end
    
    -- Add button to chat frame edit box
    local function AddSearchButton(chatFrame)
        if not chatFrame or chatFrame.searchButton then return end
        
        local editbox = chatFrame.editBox
        if not editbox then return end
        
        local button = CreateFrame("Button", nil, editbox)
        button:SetSize(20, 20)
        button:SetPoint("RIGHT", editbox, "LEFT", -5, 0)
        
        -- Create button texture
        local texture = button:CreateTexture(nil, "ARTWORK")
        texture:SetAllPoints()
        texture:SetTexture("Interface\\Buttons\\UI-SpellbookIcon-PrevPage-Up")
        
        -- Set button scripts
        button:SetScript("OnEnter", function(self)
            GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
            GameTooltip:SetText("Search Chat History")
            GameTooltip:Show()
        end)
        
        button:SetScript("OnLeave", function()
            GameTooltip:Hide()
        end)
        
        button:SetScript("OnClick", function()
            -- Create and show search frame
            local frame = CreateSearchFrame()
            frame.filter = chatFrame:GetID()
            UIDropDownMenu_SetText(frame.filterDropdown, chatFrame.name or "Chat " .. chatFrame:GetID())
            frame:Show()
        end)
        
        -- Store button reference
        chatFrame.searchButton = button
    end
    
    -- Add search buttons to all chat frames
    for i = 1, NUM_CHAT_WINDOWS do
        local chatFrame = _G["ChatFrame" .. i]
        if chatFrame then
            AddSearchButton(chatFrame)
        end
    end
    
    -- Hook temporary chat frames
    hooksecurefunc("FCF_OpenTemporaryWindow", function()
        C_Timer.After(0.1, function()
            for i = 1, NUM_CHAT_WINDOWS do
                local chatFrame = _G["ChatFrame" .. i]
                if chatFrame and not chatFrame.searchButton then
                    AddSearchButton(chatFrame)
                end
            end
        end)
    end)
    
    -- Add slash commands
    SLASH_PHOENIXCHATSEARCH1 = "/chatsearch"
    SLASH_PHOENIXCHATSEARCH2 = "/phxsearch"
    SlashCmdList["PHOENIXCHATSEARCH"] = function(msg)
        -- Create and show search frame
        local frame = CreateSearchFrame()
        
        -- Set search text if provided
        if msg and msg ~= "" then
            frame.searchBox:SetText(msg)
            C_Timer.After(0.1, function()
                frame:PerformSearch()
            end)
        end
        
        frame:Show()
    end
    
    -- Create date separators for chat history
    local function AddDateSeparators()
        if not Phoenix_UI.chatHistory then return end
        
        for chatID, messages in pairs(Phoenix_UI.chatHistory) do
            local chatFrame = _G["ChatFrame" .. chatID]
            if chatFrame and #messages > 0 then
                -- Group messages by day
                local lastDay = nil
                local lastTimestamp = 0
                
                -- Add separators when loading history
                hooksecurefunc(chatFrame, "AddMessage", function(self, text, ...)
                    -- Only process restored messages
                    if text and text:find("Restored Chat History") then
                        C_Timer.After(0.1, function()
                            -- Get the oldest message
                            local oldestMsg = nil
                            local oldestTime = nil
                            
                            for _, msgData in ipairs(messages) do
                                if msgData.timestamp and (not oldestTime or msgData.timestamp < oldestTime) then
                                    oldestTime = msgData.timestamp
                                    oldestMsg = msgData
                                end
                            end
                            
                            -- Add day separator at the beginning of restored history
                            if oldestMsg and oldestMsg.timestamp then
                                local date = date("*t", oldestMsg.timestamp)
                                local dateText = string.format("%s, %s %d, %d", 
                                    CALENDAR_WEEKDAY_NAMES[date.wday],
                                    CALENDAR_FULLDATE_MONTH_NAMES[date.month],
                                    date.day, date.year)
                                    
                                local separator = "|cFF999999----- " .. dateText .. " -----|r"
                                chatFrame:AddMessage(separator)
                            end
                        end)
                    end
                end)
            end
        end
    end
    
    -- Initialize date separators
    AddDateSeparators()
end 