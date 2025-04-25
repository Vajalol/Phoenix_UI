local LibDBIcon = LibStub("LibDBIcon-1.0")
local Module = Phoenix_UI:NewModule("Maps.Minimap");

-- Enhanced ButtonManager for minimap button fade animations with performance optimizations
local ButtonManager = {
    buttons = {},
    isShowing = false,
    isFading = false,
    fadeTime = 0.3,
    showDelay = 0.1,
    hideDelay = 0.5,
    showTimer = nil,
    hideTimer = nil,
    processedButtons = {}, -- Cache to prevent duplicate processing
    scanFrequency = 1.5,   -- Reduced scan frequency for better performance
    initialized = false    -- Flag to track initialization
}

-- Improved FadeButton function with animation and combat lockdown handling
local function FadeButton(button, fadeOut, duration)
    if not button or not button:GetName() then return end
    
    -- Handle combat lockdown for protected buttons
    if InCombatLockdown() and button:GetName() == "MiniMapWorldMapButton" then 
        return 
    end
    
    -- Get target alpha
    local targetAlpha = fadeOut and 0 or 1
    local currentAlpha = button:GetAlpha()
    
    -- Skip if already at target alpha
    if math.abs(currentAlpha - targetAlpha) < 0.05 then
        button:SetAlpha(targetAlpha)
        return
    end
    
    -- If duration is 0, do instant fade
    if duration == 0 then
        button:SetAlpha(targetAlpha)
        return
    end
    
    -- Use default fade time if not specified
    duration = duration or ButtonManager.fadeTime
    
    -- Setup animation if needed
    if not button.fadeAnim then
        button.fadeAnim = button:CreateAnimationGroup()
        button.fadeAnim.alpha = button.fadeAnim:CreateAnimation("Alpha")
        button.fadeAnim.alpha:SetSmoothing("IN_OUT")
        button.fadeAnim:SetScript("OnFinished", function()
            button:SetAlpha(targetAlpha)
        end)
    end
    
    -- Stop any in-progress animations
    if button.fadeAnim:IsPlaying() then
        button.fadeAnim:Stop()
    end
    
    -- Setup the animation
    button.fadeAnim.alpha:SetFromAlpha(currentAlpha)
    button.fadeAnim.alpha:SetToAlpha(targetAlpha)
    button.fadeAnim.alpha:SetDuration(duration)
    
    -- Play the animation
    button.fadeAnim:Play()
end

-- Register a button with the button manager
function ButtonManager:RegisterButton(button)
    if not button or not button:GetName() then return end
    
    local name = button:GetName()
    
    -- Skip if already registered
    if self.processedButtons[name] then
        return
    end
    
    -- Add to our list
    table.insert(self.buttons, button)
    self.processedButtons[name] = true
    
    -- Save initial visibility state
    button.wasHidden = not button:IsShown()
    
    -- Initial state - hide if fadeButtons is enabled
    if Phoenix_UI.db.profile.maps.fadeButtons then
        FadeButton(button, true, 0) -- Instant fade
    end
    
    return true
end

-- Show all registered buttons
function ButtonManager:ShowAllButtons()
    -- Cancel any pending hide
    if self.hideTimer then
        self.hideTimer:Cancel()
        self.hideTimer = nil
    end
    
    -- Don't stack show delays
    if self.showTimer then return end
    
    -- Add a small delay before showing to avoid flickering during quick mouse movements
    self.showTimer = C_Timer.NewTimer(self.showDelay, function()
        self.showTimer = nil
        self.isShowing = true
        
        -- Show all buttons
        for _, button in ipairs(self.buttons) do
            if button:IsShown() and button.wasHidden ~= true then -- Only show buttons that weren't explicitly hidden
                FadeButton(button, false)
            end
        end
    end)
end

-- Hide all registered buttons
function ButtonManager:HideAllButtons()
    -- Cancel any pending show
    if self.showTimer then
        self.showTimer:Cancel()
        self.showTimer = nil
    end
    
    -- Don't stack hide delays
    if self.hideTimer then return end
    
    -- Add a delay before hiding to prevent flickering
    self.hideTimer = C_Timer.NewTimer(self.hideDelay, function()
        self.hideTimer = nil
        self.isShowing = false
        
        -- Only hide if configured to do so
        if Phoenix_UI.db.profile.maps.fadeButtons then
            -- Hide all buttons
            for _, button in ipairs(self.buttons) do
                if button:IsShown() then
                    FadeButton(button, true)
                end
            end
        end
    end)
end

-- Process minimap button for fade management with improved performance
function ProcessMinimapButton(button)
    if not button or InCombatLockdown() then return end
    
    local name = button:GetName()
    if not name then return end
    
    -- Skip frames we don't want to process
    if string.find(name, "LibDBIcon") or 
       name == "MiniMapWorldMapButton" or 
       name == "MinimapBackdrop" or 
       name == "MinimapCluster" or 
       name == "TimeManagerClockButton" or
       string.find(name, "Phoenix_UI") then  -- Skip our own frames
        return
    end
    
    -- Skip already processed buttons
    if ButtonManager.processedButtons[name] then
        return
    end
    
    -- Handle the Expansion Landing Page button specially due to taint issues
    if name == "ExpansionLandingPageMinimapButton" then
        -- Setting mouse interaction won't cause taint, but hooking scripts might
        if not ButtonManager.processedButtons[name] then
            -- Register with button manager without hooking scripts
            if ButtonManager:RegisterButton(button) then
                -- We don't hook scripts for this button to avoid taint
                -- Instead we detect mouse interactions on the minimap itself
            end
        end
        return
    end
    
    -- Process standard buttons
    if ButtonManager:RegisterButton(button) then
        -- Override OnEnter to show all buttons
        if button:GetScript("OnEnter") then
            button:HookScript("OnEnter", function() 
                ButtonManager:ShowAllButtons()
            end)
        else
            button:SetScript("OnEnter", function()
                ButtonManager:ShowAllButtons() 
            end)
        end
        
        -- Override OnLeave to hide all buttons
        if button:GetScript("OnLeave") then
            button:HookScript("OnLeave", function() 
                ButtonManager:HideAllButtons()
            end)
        else
            button:SetScript("OnLeave", function()
                ButtonManager:HideAllButtons()
            end)
        end
    end
end

-- Scan and process existing minimap buttons with enhanced detection
function ProcessExistingButtons()
    if InCombatLockdown() then return end
    
    -- Process any children of the Minimap
    local children = {Minimap:GetChildren()}
    for _, child in ipairs(children) do
        if child:IsVisible() and child:GetName() then
            ProcessMinimapButton(child)
        end
    end
    
    -- Process buttons from LibDBIcon more reliably
    if LibStub and LibStub:GetLibrary("LibDBIcon-1.0", true) then
        local LibDBIcon = LibStub:GetLibrary("LibDBIcon-1.0")
        if LibDBIcon and LibDBIcon.objects then
            for _, button in pairs(LibDBIcon.objects) do
                ProcessMinimapButton(button)
            end
        end
    end
    
    -- More comprehensive detection of addon buttons
    -- Check common addon button parent frames
    local addonButtonContainers = {
        "MinimapButtonFrame", -- Used by some button collection addons
        "MinimapButtonCollection", -- Used by some button collection addons
        "MinimapBackdrop",
        "MBB_MinimapButtonFrame", -- MinimapButtonBag
        "MMHolder", -- ElvUI
        "SquaredMap" -- SquaredMinimapButtons
    }
    
    for _, containerName in ipairs(addonButtonContainers) do
        local container = _G[containerName]
        if container then
            local containerChildren = {container:GetChildren()}
            for _, child in ipairs(containerChildren) do
                if child:IsVisible() and child:GetName() then
                    ProcessMinimapButton(child)
                end
            end
        end
    end
    
    -- Check for special minimap button objects from various addons
    local knownButtons = {
        MiniMapTrackingButton,
        MiniMapMailFrame,
        MiniMapBattlefieldFrame,
        QueueStatusMinimapButton,
        GarrisonLandingPageMinimapButton,
        MiniMapWorldMapButton,
        MiniMapVoiceChatFrame,
        GameTimeFrame,
        ExpansionLandingPageMinimapButton,
        AddonCompartmentFrame,
        AddonCompartmentFrameDropDown
    }
    
    for _, button in pairs(knownButtons) do
        if button and button:IsShown() then
            ProcessMinimapButton(button)
        end
    end
    
    ButtonManager.initialized = true
end

-- Initialize the minimap button fading system with better reliability
local function InitializeMinimapButtonFading()
    local db = Phoenix_UI.db.profile.maps
    if not db.fadeButtons then return end
    
    -- Process existing buttons
    ProcessExistingButtons()
    
    -- Setup Minimap hover detection for showing/hiding buttons
    Minimap:HookScript("OnEnter", function()
        ButtonManager:ShowAllButtons()
    end)
    
    Minimap:HookScript("OnLeave", function()
        ButtonManager:HideAllButtons()
    end)
    
    -- Monitor for new buttons with improved scheduling
    local minimapButtonScanner = CreateFrame("Frame")
    minimapButtonScanner.elapsed = 0
    minimapButtonScanner:SetScript("OnUpdate", function(self, elapsed)
        self.elapsed = self.elapsed + elapsed
        if self.elapsed < ButtonManager.scanFrequency then return end
        self.elapsed = 0
        
        -- Dynamic scan frequency based on initialization state
        if ButtonManager.initialized then
            -- Increase scan interval once we've established the initial state
            ButtonManager.scanFrequency = 3 -- Less frequent checks after initialization
        end
        
        ProcessExistingButtons()
    end)
    
    -- Additional event-based button detection
    minimapButtonScanner:RegisterEvent("ADDON_LOADED")
    minimapButtonScanner:RegisterEvent("PLAYER_ENTERING_WORLD")
    minimapButtonScanner:RegisterEvent("ZONE_CHANGED_NEW_AREA")
    minimapButtonScanner:SetScript("OnEvent", function(self, event)
        -- Delay processing to allow the addon to fully set up its UI
        C_Timer.After(1, ProcessExistingButtons)
    end)
    
    -- Initial hide after a short delay
    C_Timer.After(1, function()
        if db.fadeButtons then
            ButtonManager:HideAllButtons()
        end
    end)
end

-- Update StyleMinimap function to use the ButtonManager
function Module:StyleMinimap()
    if InCombatLockdown() then 
        Module:RegisterEvent("PLAYER_REGEN_ENABLED", function(self)
            self:StyleMinimap()
            self:UnregisterEvent("PLAYER_REGEN_ENABLED")
        end)
        return 
    end
    
    local db = Phoenix_UI.db.profile.maps
    
    -- Apply styling to Minimap
    local function SafeCall(func, ...)
        if not func then return end
        
        local success, errorMsg = pcall(func, ...)
        if not success then
            print("Phoenix UI Minimap Error:", errorMsg or "Unknown")
        end
        return success
    end
    
    SafeCall(function()
        -- Create backdrop if needed
        if not Backdrop then
            Backdrop = CreateFrame("Frame", "Phoenix_UI_MinimapBackdrop", UIParent)
            Backdrop:SetFrameStrata("BACKGROUND")
            Backdrop:SetBackdrop({
                bgFile = "Interface\\ChatFrame\\ChatFrameBackground",
                edgeFile = "Interface\\ChatFrame\\ChatFrameBackground",
                edgeSize = 1,
                insets = {left = 0, right = 0, top = 0, bottom = 0}
            })
            Backdrop:SetBackdropColor(0, 0, 0, 0.8)
            Backdrop:SetBackdropBorderColor(0, 0, 0, 1)
        end
        
        -- Apply backdrop
        Backdrop:SetParent(Minimap)
        Backdrop:ClearAllPoints()
        Backdrop:SetPoint("TOPLEFT", Minimap, "TOPLEFT", -2, 2)
        Backdrop:SetPoint("BOTTOMRIGHT", Minimap, "BOTTOMRIGHT", 2, -2)
        Backdrop:SetFrameStrata("BACKGROUND")
        
        -- Set shape based on user preference
        if db.style == "Square" then
            Minimap:SetMaskTexture("Interface\\BUTTONS\\WHITE8X8")
        else
            Minimap:SetMaskTexture("Interface\\AddOns\\Phoenix_UI\\Media\\Shapes\\circle.tga")
        end
        
        -- Make movable
        Minimap:SetMovable(true)
        Minimap:EnableMouse(true)
        Minimap:RegisterForDrag("LeftButton")
        Minimap:SetScript("OnDragStart", function(self)
            if IsShiftKeyDown() and not InCombatLockdown() then
                Minimap:StartMoving()
            end
        end)
        Minimap:SetScript("OnDragStop", function(self)
            Minimap:StopMovingOrSizing()
        end)
        
        -- Apply scale and zoom
        Minimap:SetScale(db.scale or 1)
        Minimap:SetZoom(db.zoom or 0)
    end)
    
    -- Initialize button fading system
    SafeCall(function()
        InitializeMinimapButtonFading()
    end)

    -- Make minimap movable if enabled
    if db.maps.moveableminimap then
        Minimap:SetMovable(true)
        Minimap:EnableMouse(true)
        
        -- Function to save minimap position to db
        local function SaveMinimapPosition()
            if not db.maps then db.maps = {} end
            if not db.maps.position then db.maps.position = {} end
            
            local point, _, relativePoint, xOffset, yOffset = Minimap:GetPoint()
            if point and relativePoint then
                db.maps.position.point = point
                db.maps.position.relativePoint = relativePoint
                db.maps.position.xOffset = math.floor(xOffset + 0.5)
                db.maps.position.yOffset = math.floor(yOffset + 0.5)
                
                -- Persist changes to DB
                if Phoenix_UI and Phoenix_UI.SaveDB then
                    Phoenix_UI:SaveDB()
                end
            end
        end
        
        -- Function to restore minimap position from db
        local function RestoreMinimapPosition()
            if db.maps and db.maps.position and 
               db.maps.position.point and db.maps.position.relativePoint and
               db.maps.position.xOffset and db.maps.position.yOffset then
                
                -- Clear previous points
                Minimap:ClearAllPoints()
                
                -- Apply saved position
                Minimap:SetPoint(
                    db.maps.position.point,
                    UIParent,
                    db.maps.position.relativePoint,
                    db.maps.position.xOffset,
                    db.maps.position.yOffset
                )
                
                return true
            end
            
            return false
        end
        
        -- Add lock/unlock functionality
        local isLocked = true
        
        -- Restore position on load if we have saved data
        local positionRestored = RestoreMinimapPosition()
        
        Minimap:RegisterForDrag("LeftButton")
        Minimap:SetScript("OnDragStart", function(self)
            -- Allow dragging if shift is held down or if manually unlocked
            if (IsShiftKeyDown() or not isLocked) and not InCombatLockdown() then
                self:StartMoving()
                -- Visual feedback when moving
                if Backdrop then
                    Backdrop:SetBackdropBorderColor(1, 0.8, 0, 0.8) -- Highlight border while moving
                end
            end
        end)
        
        Minimap:SetScript("OnDragStop", function(self)
            self:StopMovingOrSizing()
            -- Reset visual feedback
            if Backdrop then
                Backdrop:SetBackdropBorderColor(0, 0, 0, 1)
            end
            -- Save the new position
            SaveMinimapPosition()
        end)
        
        -- Create lock/unlock button for better UX
        local lockButton = CreateFrame("Button", "Phoenix_UI_MinimapLockButton", Minimap)
        lockButton:SetSize(16, 16)
        lockButton:SetPoint("TOPRIGHT", Minimap, "TOPRIGHT", -2, -2)
        lockButton:SetFrameLevel(Minimap:GetFrameLevel() + 5)
        
        -- Set up button textures
        lockButton.icon = lockButton:CreateTexture(nil, "ARTWORK")
        lockButton.icon:SetAllPoints()
        lockButton.icon:SetTexture(isLocked and 
            "Interface\\RAIDFRAME\\ReadyCheck-Ready" or 
            "Interface\\RAIDFRAME\\ReadyCheck-NotReady")
        lockButton.icon:SetScale(0.7)
        
        -- Make the button look nice
        lockButton.bg = lockButton:CreateTexture(nil, "BACKGROUND")
        lockButton.bg:SetAllPoints()
        lockButton.bg:SetColorTexture(0, 0, 0, 0.5)
        
        -- Add border
        lockButton.border = lockButton:CreateTexture(nil, "BORDER")
        lockButton.border:SetPoint("TOPLEFT", lockButton, "TOPLEFT", -1, 1)
        lockButton.border:SetPoint("BOTTOMRIGHT", lockButton, "BOTTOMRIGHT", 1, -1)
        lockButton.border:SetColorTexture(0.3, 0.3, 0.3, 0.8)
        
        -- Functionality
        lockButton:SetScript("OnEnter", function(self)
            GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
            GameTooltip:AddLine(isLocked and "Unlock Minimap" or "Lock Minimap")
            GameTooltip:AddLine(isLocked and "Click to allow free movement" or "Click to lock position", 0.8, 0.8, 0.8)
            GameTooltip:Show()
            
            -- Highlight effect
            self.border:SetColorTexture(0.5, 0.5, 0.5, 1)
        end)
        
        lockButton:SetScript("OnLeave", function(self)
            GameTooltip:Hide()
            -- Remove highlight
            self.border:SetColorTexture(0.3, 0.3, 0.3, 0.8)
        end)
        
        lockButton:SetScript("OnClick", function(self)
            isLocked = not isLocked
            
            -- Update icon to match state
            self.icon:SetTexture(isLocked and 
                "Interface\\RAIDFRAME\\ReadyCheck-Ready" or 
                "Interface\\RAIDFRAME\\ReadyCheck-NotReady")
            
            -- Visual feedback
            if not isLocked then
                -- Show tooltip hint about movement
                if Backdrop then
                    -- Flash the backdrop to indicate it's movable
                    UIFrameFlash(Backdrop, 0.2, 0.2, 0.5, false, 0.5)
                end
            end
            
            -- Save the lock state if supported
            if db.maps then
                db.maps.minimapLocked = isLocked
                -- Persist changes
                if Phoenix_UI and Phoenix_UI.SaveDB then
                    Phoenix_UI:SaveDB()
                end
            end
        end)
        
        -- Initialize lock state from DB if available
        if db.maps and db.maps.minimapLocked ~= nil then
            isLocked = db.maps.minimapLocked
            lockButton.icon:SetTexture(isLocked and 
                "Interface\\RAIDFRAME\\ReadyCheck-Ready" or 
                "Interface\\RAIDFRAME\\ReadyCheck-NotReady")
        end
        
        -- Show a hint the first time the minimap is moved
        if not positionRestored and not db.maps.positionHintShown then
            C_Timer.After(5, function()
                if Minimap and Minimap:IsShown() then
                    -- Show tooltip with hint
                    local tooltipFrame = CreateFrame("Frame", "Phoenix_UI_MinimapMoveHint", UIParent)
                    tooltipFrame:SetFrameStrata("TOOLTIP")
                    tooltipFrame:SetPoint("BOTTOM", Minimap, "TOP", 0, 5)
                    tooltipFrame:SetSize(180, 40)
                    
                    tooltipFrame.bg = tooltipFrame:CreateTexture(nil, "BACKGROUND")
                    tooltipFrame.bg:SetAllPoints()
                    tooltipFrame.bg:SetColorTexture(0, 0, 0, 0.8)
                    
                    tooltipFrame.text = tooltipFrame:CreateFontString(nil, "OVERLAY")
                    tooltipFrame.text:SetFontObject(GameFontNormal)
                    tooltipFrame.text:SetPoint("CENTER")
                    tooltipFrame.text:SetText("Hold Shift to move the minimap")
                    
                    -- Border
                    tooltipFrame.border = CreateFrame("Frame", nil, tooltipFrame, BackdropTemplateMixin and "BackdropTemplate")
                    tooltipFrame.border:SetPoint("TOPLEFT", -1, 1)
                    tooltipFrame.border:SetPoint("BOTTOMRIGHT", 1, -1)
                    tooltipFrame.border:SetBackdrop({
                        edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
                        edgeSize = 16,
                        insets = { left = 4, right = 4, top = 4, bottom = 4 }
                    })
                    tooltipFrame.border:SetBackdropBorderColor(1, 0.8, 0, 1)
                    
                    -- Fade in
                    tooltipFrame:SetAlpha(0)
                    tooltipFrame.fadeIn = tooltipFrame:CreateAnimationGroup()
                    local fadeIn = tooltipFrame.fadeIn:CreateAnimation("Alpha")
                    fadeIn:SetFromAlpha(0)
                    fadeIn:SetToAlpha(1)
                    fadeIn:SetDuration(0.5)
                    fadeIn:SetSmoothing("OUT")
                    tooltipFrame.fadeIn:Play()
                    
                    -- Auto-hide after 5 seconds
                    C_Timer.After(5, function()
                        tooltipFrame.fadeOut = tooltipFrame:CreateAnimationGroup()
                        local fadeOut = tooltipFrame.fadeOut:CreateAnimation("Alpha")
                        fadeOut:SetFromAlpha(1)
                        fadeOut:SetToAlpha(0)
                        fadeOut:SetDuration(1)
                        fadeOut:SetSmoothing("OUT")
                        tooltipFrame.fadeOut:SetScript("OnFinished", function()
                            tooltipFrame:Hide()
                        end)
                        tooltipFrame.fadeOut:Play()
                    end)
                    
                    -- Mark hint as shown
                    db.maps.positionHintShown = true
                    if Phoenix_UI and Phoenix_UI.SaveDB then
                        Phoenix_UI:SaveDB()
                    end
                end
            end)
        end
    end
end

function Module:OnEnable()
    local db = {
        maps = Phoenix_UI.db.profile.maps,
        queueicon = Phoenix_UI.db.profile.edit.queueicon
    }

    if db then
        -- Improved minimap buttons management with animation
        if not (C_AddOns.IsAddOnLoaded("SexyMap")) then
            if db.maps.buttons then
                -- Create a frame for button management
                local ButtonManager = CreateFrame("Frame", "Phoenix_UI_MinimapButtonManager")
                ButtonManager.buttons = {}
                ButtonManager.hovered = false
                ButtonManager.updateInterval = 0.05 -- Check every 0.05 seconds for performance
                ButtonManager.fadeTime = db.maps.fadeSpeed or 0.3 -- Use configured fade speed or default
                
                -- Improved button fade functionality
                local function FadeButton(button, out)
                    if not button then return end
                    if InCombatLockdown() and button:GetName() == "MiniMapWorldMapButton" then return end
                    
                    -- Early return if smooth fade disabled
                    if not db.maps.smoothfade then
                        button:SetAlpha(out and 0 or 1)
                        return
                    end
                    
                    -- Check if button already has our animation group
                    if not button.fadeAnimGroup then
                        -- Create animation group for this button
                        button.fadeAnimGroup = button:CreateAnimationGroup()
                        button.fadeAnimGroup:SetScript("OnFinished", function() 
                            if button.fadeAnimGroup.direction == "out" then
                                button:SetAlpha(0)
                            else
                                button:SetAlpha(1)
                            end
                        end)
                        
                        -- Create the fade animation
                        local fade = button.fadeAnimGroup:CreateAnimation("Alpha")
                        fade:SetDuration(0.2)
                        fade:SetSmoothing("IN_OUT")
                        button.fadeAnimGroup.fade = fade
                    end
                    
                    -- Stop any in-progress animations
                    if button.fadeAnimGroup:IsPlaying() then
                        button.fadeAnimGroup:Stop()
                    end
                    
                    -- Set up the animation direction and properties
                    button.fadeAnimGroup.direction = out and "out" or "in"
                    local fade = button.fadeAnimGroup.fade
                    
                    if out then
                        button:SetAlpha(1)
                        fade:SetFromAlpha(1)
                        fade:SetToAlpha(0)
                    else
                        button:SetAlpha(0)
                        fade:SetFromAlpha(0)
                        fade:SetToAlpha(1)
                    end
                    
                    -- Start the animation
                    button.fadeAnimGroup:Play()
                end
                
                -- Process all tracked buttons
                ButtonManager.ProcessButtons = function(self, forceState)
                    local isHovered = self.hovered
                    
                    -- Process each tracked button
                    for button, info in pairs(self.buttons) do
                        if button and button:IsShown() and info.enabled then
                            if forceState ~= nil then
                                -- Force a specific state (for initialization)
                                self:FadeButton(button, forceState and 1 or info.hideAlpha or 0)
                            else
                                -- Normal processing
                                if isHovered then
                                    self:FadeButton(button, 1)
                                else
                                    self:FadeButton(button, info.hideAlpha or 0)
                                end
                            end
                        end
                    end
                end
                
                -- Update fade settings when configuration changes
                Phoenix_UI.RegisterCallback(Module, "PHOENIX_UI_DB_UPDATED", function()
                    db = {
                        maps = Phoenix_UI.db.profile.maps,
                        queueicon = Phoenix_UI.db.profile.edit.queueicon
                    }
                    ButtonManager.fadeTime = db.maps.fadeSpeed or 0.3
                end)
                
                -- Register a button for management
                ButtonManager.RegisterButton = function(self, button, options)
                    if not button then return end
                    
                    options = options or {}
                    self.buttons[button] = {
                        enabled = options.enabled == nil and true or options.enabled,
                        hideAlpha = options.hideAlpha or 0,
                    }
                    
                    -- Set initial state
                    if options.initialState ~= nil then
                        button:SetAlpha(options.initialState and 1 or options.hideAlpha or 0)
                    end
                    
                    -- Add hover tracking to the button
                    button:HookScript("OnEnter", function()
                        self.hovered = true
                        self:ProcessButtons()
                    end)
                    
                    button:HookScript("OnLeave", function()
                        self.hovered = false
                        -- Delay to prevent flickering when moving between buttons
                        C_Timer.After(0.1, function() 
                            if not self.hovered then
                                self:ProcessButtons()
                            end
                        end)
                    end)
                    
                    return true
                end
                
                -- Update tracking state
                ButtonManager:SetScript("OnUpdate", function(self, elapsed)
                    self.timeSinceLastUpdate = (self.timeSinceLastUpdate or 0) + elapsed
                    if self.timeSinceLastUpdate >= self.updateInterval then
                        -- Check if mouse is over the minimap
                        if Minimap:IsMouseOver() and not self.hovered then
                            self.hovered = true
                            self:ProcessButtons()
                        end
                        
                        self.timeSinceLastUpdate = 0
                    end
                end)
                
                -- Process wheel events for showing buttons
                Minimap:HookScript("OnMouseWheel", function()
                    ButtonManager.hovered = true
                    ButtonManager:ProcessButtons()
                    
                    -- Reset after delay
                    C_Timer.After(1.5, function()
                        if not Minimap:IsMouseOver() then
                            ButtonManager.hovered = false
                            ButtonManager:ProcessButtons()
                        end
                    end)
                end)
            end
        end

        -- Enhanced queue status button with smooth transitions
        local function QueueStatusButton_Reposition()
            if not QueueStatusButton then return end
            
            if db.queueicon.enable and db.queueicon.position then
                QueueStatusButton:ClearAllPoints()
                
                if db.queueicon.position == "CENTER" then
                    QueueStatusButton:SetPoint("CENTER", Minimap, "CENTER", 0, 0)
                elseif db.queueicon.position == "BOTTOM" then
                    QueueStatusButton:SetPoint("BOTTOM", Minimap, "BOTTOM", 0, db.queueicon.offsetY or 0)
                elseif db.queueicon.position == "BOTTOMLEFT" then
                    QueueStatusButton:SetPoint("BOTTOMLEFT", Minimap, "BOTTOMLEFT", db.queueicon.offsetX or 0, db.queueicon.offsetY or 0)
                elseif db.queueicon.position == "BOTTOMRIGHT" then
                    QueueStatusButton:SetPoint("BOTTOMRIGHT", Minimap, "BOTTOMRIGHT", -(db.queueicon.offsetX or 0), db.queueicon.offsetY or 0)
                elseif db.queueicon.position == "TOP" then
                    QueueStatusButton:SetPoint("TOP", Minimap, "TOP", 0, -(db.queueicon.offsetY or 0))
                elseif db.queueicon.position == "TOPLEFT" then
                    QueueStatusButton:SetPoint("TOPLEFT", Minimap, "TOPLEFT", db.queueicon.offsetX or 0, -(db.queueicon.offsetY or 0))
                elseif db.queueicon.position == "TOPRIGHT" then
                    QueueStatusButton:SetPoint("TOPRIGHT", Minimap, "TOPRIGHT", -(db.queueicon.offsetX or 0), -(db.queueicon.offsetY or 0))
                elseif db.queueicon.position == "LEFT" then
                    QueueStatusButton:SetPoint("LEFT", Minimap, "LEFT", db.queueicon.offsetX or 0, 0)
                elseif db.queueicon.position == "RIGHT" then
                    QueueStatusButton:SetPoint("RIGHT", Minimap, "RIGHT", -(db.queueicon.offsetX or 0), 0)
                end
                
                -- Handle animation improvements
                local borderAG = QueueStatusButton.Eye.BorderAG
                if borderAG and not borderAG.isOptimized then
                    -- Optimize the eye animation
                    local eyePulse = borderAG:GetAnimations()
                    if eyePulse then
                        eyePulse:SetDuration(1.5) -- Slightly faster animation
                        eyePulse:SetSmoothing("IN_OUT") -- Smoother transition
                    end
                    borderAG.isOptimized = true
                end
                
                -- Adjust size if needed
                if db.queueicon.scale and db.queueicon.scale ~= 1 then
                    QueueStatusButton:SetScale(db.queueicon.scale)
                end
            end
        end
        
        -- Apply on position updates, but only when Edit Mode is not active
        hooksecurefunc(QueueStatusButton, "UpdatePosition", function()
            if not (EditModeManagerFrame and EditModeManagerFrame:IsShown()) then
                QueueStatusButton_Reposition()
            end
        end)
        
        -- Improved Edit Mode detection with optimization
        local lastEditModeState = false
        local editModeChecker = CreateFrame("Frame")
        editModeChecker.elapsed = 0
        editModeChecker.checkFrequency = 0.5 -- Check every half second, optimized
        
        editModeChecker:SetScript("OnUpdate", function(self, elapsed)
            -- Only check periodically to save resources
            self.elapsed = self.elapsed + elapsed
            if self.elapsed < self.checkFrequency then return end
            self.elapsed = 0
            
            -- Check if Edit Mode status changed from shown to hidden
            local currentEditModeState = EditModeManagerFrame and EditModeManagerFrame:IsShown()
            if lastEditModeState == true and currentEditModeState == false then
                -- Edit Mode was just closed, reapply our position after short delay
                C_Timer.After(0.5, QueueStatusButton_Reposition)
            end
            lastEditModeState = currentEditModeState
        end)
        
        -- Also try to position on initial load and when entering world
        C_Timer.After(1, QueueStatusButton_Reposition)

        local worldFrame = CreateFrame("Frame")
        worldFrame:RegisterEvent("PLAYER_ENTERING_WORLD")
        worldFrame:SetScript("OnEvent", function()
            C_Timer.After(1, QueueStatusButton_Reposition)
        end)

        -- Add error handling for button manager operations
        local function SafeCall(func, ...)
            if not func then return end
            local success, errorMsg = pcall(func, ...)
            if not success and EL then
                EL:Print("Minimap Error: " .. (errorMsg or "Unknown error"))
            end
            return success
        end

        -- Update ProcessMinimapButton to use the ButtonManager
        function ProcessMinimapButton(button)
            if not button or InCombatLockdown() then return end
            
            local name = button:GetName()
            if not name then return end
            
            -- Skip frames we don't want to process
            if string.find(name, "LibDBIcon") or 
               name == "MiniMapWorldMapButton" or 
               name == "MinimapBackdrop" or 
               name == "MinimapCluster" or 
               name == "TimeManagerClockButton" then
                return
            end
            
            -- Handle the Expansion Landing Page button specially due to taint issues
            if name == "ExpansionLandingPageMinimapButton" then
                -- Setting mouse interaction won't cause taint, but hooking scripts might
                if not button.phoenixUIProcessed then
                    button.phoenixUIProcessed = true
                    
                    -- Register with button manager without hooking scripts
                    ButtonManager:RegisterButton(button)
                    
                    -- We don't hook scripts for this button to avoid taint
                    -- Instead we'll detect mouse interactions on the minimap itself
                end
                return
            end
            
            -- Process standard buttons
            if not button.phoenixUIProcessed then
                button.phoenixUIProcessed = true
                
                -- Register with button manager
                ButtonManager:RegisterButton(button)
                
                -- Override OnEnter to show all buttons
                if button:GetScript("OnEnter") then
                    button:HookScript("OnEnter", function() 
                        ButtonManager:ShowAllButtons()
                    end)
                else
                    button:SetScript("OnEnter", function()
                        ButtonManager:ShowAllButtons() 
                    end)
                end
                
                -- Override OnLeave to hide all buttons
                if button:GetScript("OnLeave") then
                    button:HookScript("OnLeave", function() 
                        ButtonManager:HideAllButtons()
                    end)
                else
                    button:SetScript("OnLeave", function()
                        ButtonManager:HideAllButtons()
                    end)
                end
            end
        end

        -- Update InitializeMinimapButtonFading to use the ButtonManager
        local function InitializeMinimapButtonFading()
            if not db.maps.fadeButtons then return end
            
            -- Process existing buttons
            ProcessExistingButtons()
            
            -- Setup Minimap hover detection for showing/hiding buttons
            Minimap:HookScript("OnEnter", function()
                ButtonManager:ShowAllButtons()
            end)
            
            Minimap:HookScript("OnLeave", function()
                ButtonManager:HideAllButtons()
            end)
            
            -- Monitor for new buttons
            local minimapButtonScanner = CreateFrame("Frame")
            minimapButtonScanner:SetScript("OnUpdate", function(self, elapsed)
                self.elapsed = (self.elapsed or 0) + elapsed
                if self.elapsed < 1 then return end
                self.elapsed = 0
                
                ProcessExistingButtons()
            end)
            
            -- Initial hide after a short delay
            C_Timer.After(1, function()
                if db.maps.fadeButtons then
                    ButtonManager:HideAllButtons()
                end
            end)
        end

        -- Update StyleMinimap to initialize the ButtonManager
        function Module:StyleMinimap()
            if InCombatLockdown() then 
                Module:RegisterEvent("PLAYER_REGEN_ENABLED", function(self)
                    self:StyleMinimap()
                    self:UnregisterEvent("PLAYER_REGEN_ENABLED")
                end)
                return 
            end
            
            -- Apply styling to Minimap
            SafeCall(function()
                -- Apply backdrop
                Backdrop:SetParent(Minimap)
                Backdrop:ClearAllPoints()
                Backdrop:SetPoint("TOPLEFT", Minimap, "TOPLEFT", -2, 2)
                Backdrop:SetPoint("BOTTOMRIGHT", Minimap, "BOTTOMRIGHT", 2, -2)
                Backdrop:SetFrameStrata("BACKGROUND")
                
                -- Set shape based on user preference
                if db.maps.style == "Square" then
                    Minimap:SetMaskTexture("Interface\\BUTTONS\\WHITE8X8")
                else
                    Minimap:SetMaskTexture("Interface\\AddOns\\Phoenix_UI\\Media\\Shapes\\circle.tga")
                end
                
                -- Make movable
                Minimap:SetMovable(true)
                Minimap:EnableMouse(true)
                Minimap:RegisterForDrag("LeftButton")
                Minimap:SetScript("OnDragStart", function(self)
                    if IsShiftKeyDown() and not InCombatLockdown() then
                        Minimap:StartMoving()
                    end
                end)
                Minimap:SetScript("OnDragStop", function(self)
                    Minimap:StopMovingOrSizing()
                end)
                
                -- Apply scale and zoom
                Minimap:SetScale(db.maps.scale or 1)
                Minimap:SetZoom(db.maps.zoom or 0)
            end)
            
            -- Initialize button fading system
            SafeCall(function()
                InitializeMinimapButtonFading()
            end)
        end

        -- Initialize standard minimap functionality
        if db.enable then
            -- Apply styling
            Module:StyleMinimap()
            
            -- Watch for settings changes and update
            Phoenix_UI.RegisterCallback(Module, "PHOENIX_UI_DB_UPDATED", function()
                db = {
                    maps = Phoenix_UI.db.profile.maps,
                    queueicon = Phoenix_UI.db.profile.edit.queueicon
                }
                Module:StyleMinimap()
            end)
            
            -- Rescaling functions and minimap mover setup
            local function ApplyMinimapScale()
                if not db.maps or not db.maps.scale then return end
                
                -- Apply scale to minimap
                Minimap:SetScale(db.maps.scale)
                
                -- Also scale the cluster if needed
                if MinimapCluster then
                    MinimapCluster:SetScale(db.maps.scale)
                end
            end
            
            -- Apply scale on load
            ApplyMinimapScale()
            
            -- Update scale when settings change
            Phoenix_UI.RegisterCallback(Module, "PHOENIX_UI_DB_UPDATED", function()
                ApplyMinimapScale()
            end)
            
            -- Make minimap movable if enabled
            if db.maps.moveableminimap then
                Minimap:SetMovable(true)
                Minimap:EnableMouse(true)
                
                Minimap:RegisterForDrag("LeftButton")
                Minimap:SetScript("OnDragStart", function(self)
                    if IsShiftKeyDown() then
                        self:StartMoving()
                    end
                end)
                Minimap:SetScript("OnDragStop", function(self)
                    self:StopMovingOrSizing()
                    -- Store position if required
                    -- Implementation would go here
                end)
            end
            
            -- Handle expansion button mouseover
            if db.maps.buttons and ExpansionLandingPageMinimapButton then
                local ButtonManager = _G["Phoenix_UI_MinimapButtonManager"]
                if ButtonManager then
                    -- Register the expansion button to the button manager
                    ButtonManager:RegisterButton(ExpansionLandingPageMinimapButton, {
                        enabled = true,
                        hideAlpha = 0,
                        initialState = false
                    })
                    
                    -- Initial processing
                    C_Timer.After(0.5, function()
                        if ButtonManager and ButtonManager.ProcessButtons then
                            ButtonManager:ProcessButtons(false)
                        end
                    end)
                    
                    -- Try to detect new minimap buttons
                    local buttonDetector = CreateFrame("Frame")
                    buttonDetector:RegisterEvent("ADDON_LOADED")
                    buttonDetector:SetScript("OnEvent", function(self, event, addonName)
                        -- Short delay to let addon initialize its UI
                        C_Timer.After(1, function()
                            if ButtonManager and ButtonManager.ProcessButtons then
                                ButtonManager:ProcessButtons(Minimap:IsMouseOver())
                            end
                        end)
                    end)
                end
            end
        end
    end
end



