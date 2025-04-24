SLASH_UISRESET1 = "/uis-reset"
SlashCmdList.UISRESET = function()
    SetCVar("uiScale", 1.0)
    UIParent:SetScale(1.0)
end
SLASH_UIS1 = "/uis"
SLASH_UIS2 = "/uiscale"

-- Phoenix UI Scaler
local addonName, addon = ...

-- Create a namespace for UI scale functions
Phoenix_UI_Scale = Phoenix_UI_Scale or {}

-- Debug function that only prints in debug mode
local function DebugPrint(message)
    -- Debug mode is disabled, so this function does nothing
    -- Set to true to enable debug messages during troubleshooting
    local debugMode = false
    if debugMode then
        print("|cffFF7D0APhoenix|r|cffFF0000_|r|cffFFD100UI|r: " .. message)
    end
end

-- Main function to scale the UI
function Phoenix_UI_Scale.Scale(scale)
    -- Validate input
    if not scale or tonumber(scale) == nil then
        -- Show error message for invalid input only when directly called by user
        DebugPrint("UI Scaler - Invalid scale value")
        return false
    end
    
    -- Round to 2 decimal places for display clarity
    scale = math.floor(scale * 100) / 100
    
    -- Enforce min/max constraints
    if tonumber(scale) > 1.2 then scale = 1.2 end
    if tonumber(scale) < 0.5 then scale = 0.5 end
    
    DebugPrint("UI Scaler - Setting scale to: " .. scale)
    
    -- Save to Phoenix_UI if it exists
    if _G["Phoenix_UI"] then
        -- Get current profile name
        local currentProfile = "Default"
        if Phoenix_UI.db and Phoenix_UI.db.keys and Phoenix_UI.db.keys.profile then
            currentProfile = Phoenix_UI.db.keys.profile
        end
        DebugPrint("UI Scaler - Using profile: " .. currentProfile)
        
        -- Save to Phoenix_UI config
        if Phoenix_UI.config then
            Phoenix_UI.config.uiscaling = Phoenix_UI.config.uiscaling or {}
            Phoenix_UI.config.uiscaling.scale = scale
            DebugPrint("UI Scaler - Saved to Phoenix_UI.config")
        end
        
        -- Save to Phoenix_UI AceDB
        if Phoenix_UI.db and Phoenix_UI.db.profile then
            Phoenix_UI.db.profile.uiscaling = Phoenix_UI.db.profile.uiscaling or {}
            Phoenix_UI.db.profile.uiscaling.scale = scale
            DebugPrint("UI Scaler - Saved to Phoenix_UI.db.profile")
        end
    else
        DebugPrint("UI Scaler - Phoenix_UI not found")
    end
    
    -- Save to Phoenix_UIDB global variable
    _G["Phoenix_UIDB"] = _G["Phoenix_UIDB"] or {}
    _G["Phoenix_UIDB"].profiles = _G["Phoenix_UIDB"].profiles or {}
    
    -- Get current profile name again (for safety)
    local currentProfile = "Default"
    if Phoenix_UI and Phoenix_UI.db and Phoenix_UI.db.keys and Phoenix_UI.db.keys.profile then
        currentProfile = Phoenix_UI.db.keys.profile
    end
    
    -- Save to current profile
    _G["Phoenix_UIDB"].profiles[currentProfile] = _G["Phoenix_UIDB"].profiles[currentProfile] or {}
    _G["Phoenix_UIDB"].profiles[currentProfile].uiscaling = _G["Phoenix_UIDB"].profiles[currentProfile].uiscaling or {}
    _G["Phoenix_UIDB"].profiles[currentProfile].uiscaling.scale = scale
    DebugPrint("UI Scaler - Saved to Phoenix_UIDB.profiles." .. currentProfile)
    
    -- Also save to Default profile for compatibility
    _G["Phoenix_UIDB"].profiles.Default = _G["Phoenix_UIDB"].profiles.Default or {}
    _G["Phoenix_UIDB"].profiles.Default.uiscaling = _G["Phoenix_UIDB"].profiles.Default.uiscaling or {}
    _G["Phoenix_UIDB"].profiles.Default.uiscaling.scale = scale
    DebugPrint("UI Scaler - Saved to Phoenix_UIDB.profiles.Default")
    
    -- Apply the scale change
    SetCVar("uiScale", tostring(scale))
    UIParent:SetScale(scale)
    
    -- Call SaveDB to persist if available
    if Phoenix_UI and Phoenix_UI.SaveDB then
        Phoenix_UI:SaveDB()
        DebugPrint("UI Scaler - Called Phoenix_UI:SaveDB()")
    end
    
    -- Verify saved values after a slight delay
    C_Timer.After(0.5, function()
        local configValue = Phoenix_UI and Phoenix_UI.config and Phoenix_UI.config.uiscaling and Phoenix_UI.config.uiscaling.scale
        local dbValue = Phoenix_UI and Phoenix_UI.db and Phoenix_UI.db.profile and Phoenix_UI.db.profile.uiscaling and Phoenix_UI.db.profile.uiscaling.scale
        local globalValue = _G["Phoenix_UIDB"] and _G["Phoenix_UIDB"].profiles and _G["Phoenix_UIDB"].profiles[currentProfile] and 
                           _G["Phoenix_UIDB"].profiles[currentProfile].uiscaling and _G["Phoenix_UIDB"].profiles[currentProfile].uiscaling.scale
                           
        DebugPrint("UI Scaler - Verification - Config: " .. 
              (configValue or "nil") .. ", DB: " .. (dbValue or "nil") .. ", Global: " .. (globalValue or "nil"))
              
        -- Save again if there's a mismatch
        if (Phoenix_UI and ((not configValue or configValue ~= scale) or (not dbValue or dbValue ~= scale))) or 
           (not globalValue or globalValue ~= scale) then
            DebugPrint("UI Scaler - Values didn't match, saving again")
            
            -- Retry saving
            if Phoenix_UI then
                if Phoenix_UI.config then
                    Phoenix_UI.config.uiscaling = Phoenix_UI.config.uiscaling or {}
                    Phoenix_UI.config.uiscaling.scale = scale
                end
                
                if Phoenix_UI.db and Phoenix_UI.db.profile then
                    Phoenix_UI.db.profile.uiscaling = Phoenix_UI.db.profile.uiscaling or {}
                    Phoenix_UI.db.profile.uiscaling.scale = scale
                end
            end
            
            -- Save to Phoenix_UIDB again
            if _G["Phoenix_UIDB"] and _G["Phoenix_UIDB"].profiles then
                _G["Phoenix_UIDB"].profiles[currentProfile] = _G["Phoenix_UIDB"].profiles[currentProfile] or {}
                _G["Phoenix_UIDB"].profiles[currentProfile].uiscaling = _G["Phoenix_UIDB"].profiles[currentProfile].uiscaling or {}
                _G["Phoenix_UIDB"].profiles[currentProfile].uiscaling.scale = scale
                
                _G["Phoenix_UIDB"].profiles.Default = _G["Phoenix_UIDB"].profiles.Default or {}
                _G["Phoenix_UIDB"].profiles.Default.uiscaling = _G["Phoenix_UIDB"].profiles.Default.uiscaling or {}
                _G["Phoenix_UIDB"].profiles.Default.uiscaling.scale = scale
            end
            
            -- Call SaveDB again
            if Phoenix_UI and Phoenix_UI.SaveDB then
                Phoenix_UI:SaveDB()
            end
        end
    end)
    
    -- Only notify when manually changing the scale
    if SlashCmdList["UIS"] then
        print("|cffFF7D0APhoenix|r|cffFF0000_|r|cffFFD100UI|r: UI Scale set to " .. scale)
    end
    return true
end

-- Function to get the current scale from saved variables
function Phoenix_UI_Scale.GetSavedScale()
    local scale
    
    -- Try to get from Phoenix_UI first
    if Phoenix_UI then
        -- Try config first
        if Phoenix_UI.config and Phoenix_UI.config.uiscaling and Phoenix_UI.config.uiscaling.scale then
            scale = Phoenix_UI.config.uiscaling.scale
            DebugPrint("UI Scaler - Found scale in Phoenix_UI.config: " .. scale)
            return scale
        end
        
        -- Try AceDB next
        if Phoenix_UI.db and Phoenix_UI.db.profile and Phoenix_UI.db.profile.uiscaling and Phoenix_UI.db.profile.uiscaling.scale then
            scale = Phoenix_UI.db.profile.uiscaling.scale
            DebugPrint("UI Scaler - Found scale in Phoenix_UI.db.profile: " .. scale)
            return scale
        end
    end
    
    -- Try to get from Phoenix_UIDB if not found in Phoenix_UI
    if _G["Phoenix_UIDB"] and _G["Phoenix_UIDB"].profiles then
        -- Get current profile
        local currentProfile = "Default"
        if Phoenix_UI and Phoenix_UI.db and Phoenix_UI.db.keys and Phoenix_UI.db.keys.profile then
            currentProfile = Phoenix_UI.db.keys.profile
        end
        
        -- Try current profile first
        if _G["Phoenix_UIDB"].profiles[currentProfile] and 
           _G["Phoenix_UIDB"].profiles[currentProfile].uiscaling and 
           _G["Phoenix_UIDB"].profiles[currentProfile].uiscaling.scale then
            scale = _G["Phoenix_UIDB"].profiles[currentProfile].uiscaling.scale
            DebugPrint("UI Scaler - Found scale in Phoenix_UIDB.profiles." .. currentProfile .. ": " .. scale)
            return scale
        end
        
        -- Try Default profile as fallback
        if _G["Phoenix_UIDB"].profiles.Default and 
           _G["Phoenix_UIDB"].profiles.Default.uiscaling and 
           _G["Phoenix_UIDB"].profiles.Default.uiscaling.scale then
            scale = _G["Phoenix_UIDB"].profiles.Default.uiscaling.scale
            DebugPrint("UI Scaler - Found scale in Phoenix_UIDB.profiles.Default: " .. scale)
            return scale
        end
    end
    
    -- Fallback to current UI scale if nothing is saved
    scale = UIParent:GetScale()
    DebugPrint("UI Scaler - No saved scale found, using current scale: " .. scale)
    return scale
end

-- Function for auto-scaling based on screen resolution
function Phoenix_UI_Scale.AutoScale()
    local screenHeight = select(2, GetPhysicalScreenSize())
    local newScale = 768 / screenHeight
    
    DebugPrint("UI Scaler - Auto Scale - Screen height: " .. screenHeight .. ", calculated scale: " .. newScale)
    
    -- Apply using our function
    return Phoenix_UI_Scale.Scale(newScale)
end

-- Slash command handler for UI scaling
SlashCmdList["UIS"] = function(msg)
    -- Parse input scale
    local inputScale = tonumber(msg)
    
    -- Create UI frame if no input is provided
    if not inputScale then
        -- Create a basic UI for scaling
        local f = CreateFrame("Frame", "Phoenix_UIScaleFrame", UIParent, "BackdropTemplate")
        f:SetSize(300, 200)
        f:SetPoint("CENTER")
        f:SetBackdrop({
            bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background",
            edgeFile = "Interface\\DialogFrame\\UI-DialogBox-Border",
            tile = true, tileSize = 32, edgeSize = 32,
            insets = { left = 11, right = 12, top = 12, bottom = 11 }
        })
        f:SetMovable(true)
        f:EnableMouse(true)
        f:RegisterForDrag("LeftButton")
        f:SetScript("OnDragStart", f.StartMoving)
        f:SetScript("OnDragStop", f.StopMovingOrSizing)

    -- Title
        local title = f:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
        title:SetPoint("TOP", 0, -16)
        title:SetText("Phoenix UI - Scale Adjuster")
        
    -- Description
        local desc = f:CreateFontString(nil, "OVERLAY", "GameFontNormal")
        desc:SetPoint("TOP", title, "BOTTOM", 0, -8)
        desc:SetText("Adjust your UI scale")
        desc:SetTextColor(1, 0.82, 0)
        
        -- Current scale display
        local currentScale = Phoenix_UI_Scale.GetSavedScale()
        local currentText = f:CreateFontString(nil, "OVERLAY", "GameFontNormal")
        currentText:SetPoint("TOP", desc, "BOTTOM", 0, -8)
        currentText:SetText("Current scale: " .. currentScale)
        
        -- Input box for scale value
        local editBox = CreateFrame("EditBox", nil, f, "InputBoxTemplate")
        editBox:SetSize(100, 20)
        editBox:SetPoint("TOP", currentText, "BOTTOM", 0, -16)
        editBox:SetAutoFocus(false)
        editBox:SetText(tostring(currentScale))
        editBox:SetScript("OnEnterPressed", function(self)
            local value = tonumber(self:GetText())
            if Phoenix_UI_Scale.Scale(value) then
                currentText:SetText("Current scale: " .. value)
            end
            self:ClearFocus()
        end)
        
        -- Auto scale button (calculates scale based on resolution)
        local autoButton = CreateFrame("Button", nil, f, "UIPanelButtonTemplate")
        autoButton:SetSize(120, 22)
        autoButton:SetPoint("TOP", editBox, "BOTTOM", 0, -16)
        autoButton:SetText("Auto Scale")
        autoButton:SetScript("OnClick", function()
            if Phoenix_UI_Scale.AutoScale() then
                local newScale = Phoenix_UI_Scale.GetSavedScale()
                currentText:SetText("Current scale: " .. newScale)
                editBox:SetText(tostring(newScale))
            end
        end)
        
        -- Default button (sets scale to 1.0)
        local defaultButton = CreateFrame("Button", nil, f, "UIPanelButtonTemplate")
        defaultButton:SetSize(120, 22)
        defaultButton:SetPoint("TOP", autoButton, "BOTTOM", 0, -8)
        defaultButton:SetText("Default (1.0)")
        defaultButton:SetScript("OnClick", function()
            if Phoenix_UI_Scale.Scale(1.0) then
                currentText:SetText("Current scale: 1.0")
                editBox:SetText("1.0")
            end
        end)
        
        -- Save button
        local saveButton = CreateFrame("Button", nil, f, "UIPanelButtonTemplate")
        saveButton:SetSize(120, 22)
        saveButton:SetPoint("TOP", defaultButton, "BOTTOM", 0, -8)
        saveButton:SetText("Save")
        saveButton:SetScript("OnClick", function()
            local value = tonumber(editBox:GetText())
            if Phoenix_UI_Scale.Scale(value) then
                currentText:SetText("Current scale: " .. value)
                DebugPrint("UI Scaler - Scale saved: " .. value)
            end
        end)
        
        -- Reload UI button
        local reloadButton = CreateFrame("Button", nil, f, "UIPanelButtonTemplate")
        reloadButton:SetSize(120, 22)
        reloadButton:SetPoint("TOP", saveButton, "BOTTOM", 0, -8)
        reloadButton:SetText("Reload UI")
        reloadButton:SetScript("OnClick", function()
            ReloadUI()
        end)
        
        -- Close button
        local closeButton = CreateFrame("Button", nil, f, "UIPanelCloseButton")
        closeButton:SetPoint("TOPRIGHT", f, "TOPRIGHT", -3, -3)
        
        -- Frame methods
        f.UpdateScale = function(self, scale)
            currentText:SetText("Current scale: " .. scale)
            editBox:SetText(tostring(scale))
        end
        
        f:Show()
        return
    end
    
    -- Apply scale directly if a value was provided
    Phoenix_UI_Scale.Scale(inputScale)
end

-- Event frame for loading saved scale
local frame = CreateFrame("Frame")
frame:RegisterEvent("PLAYER_ENTERING_WORLD")
frame:SetScript("OnEvent", function(self, event)
    if event == "PLAYER_ENTERING_WORLD" then
        C_Timer.After(1, function()
            local scale = Phoenix_UI_Scale.GetSavedScale()
            if scale then
                DebugPrint("UI Scaler - Loading saved scale: " .. scale)
                Phoenix_UI_Scale.Scale(scale)
            else
                DebugPrint("UI Scaler - No saved scale found")
            end
        end)
    end
end)