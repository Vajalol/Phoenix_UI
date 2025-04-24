local Module = Phoenix_UI:NewModule("Chat.Copy");

function Module:OnEnable()
    local db = Phoenix_UI.db.profile.chat
    if not db.copy then return end

    -- Create one reusable copy frame for the entire addon
    local Phoenix_ChatCopyFrame
    
    -- Function to get chat messages from a chat frame
    local function GetChatText(chatFrame)
        if not chatFrame or not chatFrame.GetNumMessages then return "" end
        
        local chatLines = {}
        local numMessages = chatFrame:GetNumMessages()
        
        for i = 1, numMessages do
            local text = chatFrame:GetMessageInfo(i)
            if text and text ~= "" then
                table.insert(chatLines, text)
            end
        end
        
        return table.concat(chatLines, "\n")
    end
    
    -- Function to create the copy frame once
    local function CreateCopyFrame()
        if Phoenix_ChatCopyFrame then return Phoenix_ChatCopyFrame end
        
        -- Main frame
        local frame = CreateFrame("Frame", "Phoenix_ChatCopyFrame", UIParent, "BackdropTemplate")
        frame:SetSize(700, 500)
        frame:SetPoint("CENTER")
        frame:SetFrameStrata("DIALOG")
        frame:SetBackdrop({
            bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background",
            edgeFile = "Interface\\DialogFrame\\UI-DialogBox-Border",
            edgeSize = 16,
            tile = true, tileSize = 16,
            insets = { left = 4, right = 4, top = 4, bottom = 4 }
        })
        frame:SetBackdropColor(0, 0, 0, 0.9)
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
        title:SetText("Chat History")
        frame.title = title
        
        -- Close button
        local closeButton = CreateFrame("Button", nil, frame, "UIPanelCloseButton")
        closeButton:SetPoint("TOPRIGHT", -5, -5)
        
        -- Create scroll frame
        local scrollFrame = CreateFrame("ScrollFrame", nil, frame, "UIPanelScrollFrameTemplate")
        scrollFrame:SetPoint("TOPLEFT", 12, -32)
        scrollFrame:SetPoint("BOTTOMRIGHT", -30, 40)
        frame.scrollFrame = scrollFrame
        
        -- Create edit box
        local editBox = CreateFrame("EditBox", nil, scrollFrame)
        editBox:SetMultiLine(true)
        editBox:SetFontObject(ChatFontNormal)
        editBox:SetWidth(scrollFrame:GetWidth())
        editBox:SetHeight(500)  -- Will be resized by scroll frame
        editBox:SetAutoFocus(false)
        editBox:SetScript("OnEscapePressed", function() frame:Hide() end)
        scrollFrame:SetScrollChild(editBox)
        frame.editBox = editBox
        
        -- Select All button
        local selectAllButton = CreateFrame("Button", nil, frame, "UIPanelButtonTemplate")
        selectAllButton:SetText("Select All")
        selectAllButton:SetSize(100, 22)
        selectAllButton:SetPoint("BOTTOMLEFT", 12, 12)
        selectAllButton:SetScript("OnClick", function()
            editBox:SetFocus()
            editBox:HighlightText()
        end)
        
        -- Help text
        local helpText = frame:CreateFontString(nil, "OVERLAY")
        helpText:SetPoint("BOTTOM", 0, 12)
        helpText:SetFont(STANDARD_TEXT_FONT, 11)
        helpText:SetTextColor(1, 1, 1, 0.8)
        helpText:SetText("Press Ctrl+C to copy selected text")
        
        return frame
    end
    
    -- Function to display the chat copy frame with chat text
    local function ShowChatCopy(chatFrame)
        -- Create or get the copy frame
        local copyFrame = CreateCopyFrame()
        
        -- Set chat frame name as title if available
        if chatFrame and chatFrame.name then
            copyFrame.title:SetText(chatFrame.name)
        else
            copyFrame.title:SetText("Chat Copy")
        end
        
        -- Get messages from the source chat frame
        local text = GetChatText(chatFrame)
        
        -- If text is empty, show a message
        if text == "" then
            text = "No messages found in this chat window."
        end
        
        -- Set the text in the edit box
        copyFrame.editBox:SetText(text)
        
        -- Update the scroll frame
        copyFrame.scrollFrame:UpdateScrollChildRect()
        copyFrame.scrollFrame:SetVerticalScroll(0)
        
        -- Show the frame
        copyFrame:Show()
    end
    
    -- Function to create the copy button for each chat frame
    local function CreateCopyButton(chatFrame)
        if not chatFrame or chatFrame.copyButton then return end
        
        local button = CreateFrame("Button", nil, chatFrame)
        button:SetSize(24, 24)
        
        -- Position in a more visible location
        button:SetPoint("TOPRIGHT", chatFrame, "TOPRIGHT", -5, -2)
        
        -- Set textures
        local normalTexture = "Interface\\Phoenix_UI\\Media\\Textures\\Chat\\copynormal"
        local highlightTexture = "Interface\\Phoenix_UI\\Media\\Textures\\Chat\\copyhighlight"
        
        -- Check if custom textures exist
        local normalTextureExists = GetFileIDFromPath(normalTexture) ~= nil
        local highlightTextureExists = GetFileIDFromPath(highlightTexture) ~= nil
        
        -- Apply normal texture with fallback
        if normalTextureExists then
            button:SetNormalTexture(normalTexture)
            button:GetNormalTexture():SetAllPoints()
        else
            button:SetNormalTexture("Interface\\Buttons\\UI-SpellbookIcon-NextPage-Up")
            button:GetNormalTexture():SetTexCoord(0.1, 0.9, 0.1, 0.9) -- Remove border
            button:GetNormalTexture():SetAllPoints()
        end
        
        -- Apply highlight texture with fallback
        if highlightTextureExists then
            button:SetHighlightTexture(highlightTexture)
            button:GetHighlightTexture():SetAllPoints()
        else
            button:SetHighlightTexture("Interface\\Buttons\\ButtonHilight-Square", "ADD")
            button:GetHighlightTexture():SetAllPoints()
        end
        
        -- Match tab alpha but keep more visible
        local tab = _G[chatFrame:GetName() .. "Tab"]
        if tab then
            hooksecurefunc(tab, "SetAlpha", function()
                button:SetAlpha(math.max(0.7, tab:GetAlpha()))
            end)
        end
        
        -- Button click animation
        button:SetScript("OnMouseDown", function(self)
            if self:GetNormalTexture() then
                self:GetNormalTexture():ClearAllPoints()
                self:GetNormalTexture():SetPoint("CENTER", 1, -1)
            end
        end)
        
        button:SetScript("OnMouseUp", function(self)
            if self:GetNormalTexture() then
                self:GetNormalTexture():ClearAllPoints()
                self:GetNormalTexture():SetPoint("CENTER")
            end
            
            if self:IsMouseOver() then
                ShowChatCopy(chatFrame)
            end
        end)
        
        -- Set tooltip
        button:SetScript("OnEnter", function(self)
            GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
            GameTooltip:SetText("Copy Chat")
            GameTooltip:Show()
        end)
        
        button:SetScript("OnLeave", function()
            GameTooltip:Hide()
        end)
        
        -- Store in the chat frame
        chatFrame.copyButton = button
    end
    
    -- Add copy buttons to all chat frames
    local function SetupChatCopy()
        for i = 1, NUM_CHAT_WINDOWS do
            local chatFrame = _G["ChatFrame" .. i]
            if chatFrame then
                CreateCopyButton(chatFrame)
            end
        end
    end
    
    -- Register slash commands for direct access to the feature
    SLASH_PHOENIXCOPY1 = "/phxcopy"
    SLASH_PHOENIXCOPY2 = "/phoenixcopy"
    SLASH_PHOENIXCOPY3 = "/chatcopy"
    SlashCmdList["PHOENIXCOPY"] = function(msg)
        local chatFrame = DEFAULT_CHAT_FRAME -- Default to the first chat frame
        
        -- Check if a number was specified
        local frameNum = tonumber(msg)
        if frameNum and frameNum > 0 and frameNum <= NUM_CHAT_WINDOWS then
            chatFrame = _G["ChatFrame" .. frameNum]
        end
        
        -- Show the copy frame for the selected chat
        if chatFrame then
            ShowChatCopy(chatFrame)
        end
    end
    
    -- Hook into temporary windows
    hooksecurefunc("FCF_OpenTemporaryWindow", function()
        -- Use a small delay to ensure the window is fully created
        C_Timer.After(0.2, SetupChatCopy)
    end)
    
    -- Initial setup
    SetupChatCopy()
end



