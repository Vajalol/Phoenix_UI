local addonName, addon = ...
local LSM = LibStub("LibSharedMedia-3.0")

Phoenix_UI.config = Phoenix_UI.config or {}
Phoenix_UI.config.uiscaling = Phoenix_UI.config.uiscaling or {}

-- Debug function that only prints in debug mode
local function DebugPrint(message)
    -- Debug mode is disabled by default
    local debugMode = false
    if debugMode then
        print("|cffFF7D0APhoenix|r|cffFF0000_|r|cffFFD100UI|r: " .. message)
    end
end

-- Add configuration for UI scaling
local module = {
    name = "UI Scaling",
    enabled = true,
    -- Initialize function is called when the module is loaded
    init = function(self)
        -- Ensure the UI scaling structure exists
        Phoenix_UI.config.uiscaling = Phoenix_UI.config.uiscaling or {}
        
        -- Initialize scale on load
        C_Timer.After(2, function()
            -- Get the saved scale value
            local currentScale = self.getCurrentScale()
            DebugPrint("UI Scaling module initialized with scale: " .. currentScale)
            
            -- Verify that scale is correctly set in all places
            if Phoenix_UI.db and Phoenix_UI.db.profile then
                Phoenix_UI.db.profile.uiscaling = Phoenix_UI.db.profile.uiscaling or {}
                if Phoenix_UI.db.profile.uiscaling.scale ~= currentScale then
                    Phoenix_UI.db.profile.uiscaling.scale = currentScale
                    DebugPrint("Updated Phoenix_UI.db.profile.uiscaling.scale to: " .. currentScale)
                end
            end
            
            -- Apply scale to ensure UI is correctly scaled
            if Phoenix_UI_Scale and Phoenix_UI_Scale.Scale then
                Phoenix_UI_Scale.Scale(currentScale)
            else
                -- Fallback if Phoenix_UI_Scale.Scale isn't available
                SetCVar("uiScale", tostring(currentScale))
                UIParent:SetScale(currentScale)
            end
            
            -- Force save the settings to ensure persistence
            if Phoenix_UI and Phoenix_UI.SaveDB then
                Phoenix_UI:SaveDB()
            end
        end)
    end,
    
    -- Apply scale function
    applyScale = function(value)
        -- Ensure value is valid
        value = tonumber(value)
        if not value or value < 0.5 or value > 1.5 then
            -- Silently handle invalid values without printing warnings
            DebugPrint("Invalid scale value, using 1.0 instead")
            value = 1.0
        end

        -- Set the scale CVar
        SetCVar("uiScale", value)
        
        -- Apply scale to UIParent
        UIParent:SetScale(value)
        
        -- Save scale to Phoenix_UI database
        if Phoenix_UI and Phoenix_UI.db and Phoenix_UI.db.profile then
            Phoenix_UI.db.profile.uiscaling = Phoenix_UI.db.profile.uiscaling or {}
            Phoenix_UI.db.profile.uiscaling.scale = value
        end
        
        -- Direct save to Phoenix_UIDB global variable for redundancy
        if _G["Phoenix_UIDB"] and _G["Phoenix_UIDB"].profiles then
            local currentProfile = Phoenix_UI.db.keys.profile or "Default"
            if not _G["Phoenix_UIDB"].profiles[currentProfile] then
                _G["Phoenix_UIDB"].profiles[currentProfile] = {}
            end
            if not _G["Phoenix_UIDB"].profiles[currentProfile].uiscaling then
                _G["Phoenix_UIDB"].profiles[currentProfile].uiscaling = {}
            end
            _G["Phoenix_UIDB"].profiles[currentProfile].uiscaling.scale = value
            
            -- Also save to Default profile for safety
            if not _G["Phoenix_UIDB"].profiles.Default then
                _G["Phoenix_UIDB"].profiles.Default = {}
            end
            if not _G["Phoenix_UIDB"].profiles.Default.uiscaling then
                _G["Phoenix_UIDB"].profiles.Default.uiscaling = {}
            end
            _G["Phoenix_UIDB"].profiles.Default.uiscaling.scale = value
        end
        
        -- Use Phoenix_UI_Scale module if available
        if Phoenix_UI_Scale and Phoenix_UI_Scale.Scale then
            -- Use the dedicated UI scaling function without debug messages
            DebugPrint("Config - Using Phoenix_UI_Scale.Scale")
            Phoenix_UI_Scale.Scale(value)
        end
        
        -- Call SaveDB to persist if available
        if Phoenix_UI and Phoenix_UI.SaveDB then
            Phoenix_UI:SaveDB()
            DebugPrint("UI Scale " .. value .. " applied and saved")
        end
        
        return value
    end,
    
    -- Get current scale function
    getCurrentScale = function()
        local scale = Phoenix_UI.config.uiscaling and Phoenix_UI.config.uiscaling.scale
        if not scale or scale == 0 then
            -- Try to get from Phoenix_UIDB
            local currentProfile = Phoenix_UI.db.keys.profile or "Default"
            scale = _G["Phoenix_UIDB"] and 
                    _G["Phoenix_UIDB"].profiles and 
                    _G["Phoenix_UIDB"].profiles[currentProfile] and 
                    _G["Phoenix_UIDB"].profiles[currentProfile].uiscaling and 
                    _G["Phoenix_UIDB"].profiles[currentProfile].uiscaling.scale
            
            -- Fallback to Default profile
            if not scale then
                scale = _G["Phoenix_UIDB"] and 
                       _G["Phoenix_UIDB"].profiles and 
                       _G["Phoenix_UIDB"].profiles.Default and 
                       _G["Phoenix_UIDB"].profiles.Default.uiscaling and 
                       _G["Phoenix_UIDB"].profiles.Default.uiscaling.scale
            end
            
            -- Fallback to current UI scale
            if not scale then
                scale = UIParent:GetScale()
            end
        end
        return scale or 1.0
    end,
    
    -- Layout configuration for UI scaling
    layout = {
        -- Main header
        header = {
            type = 'header',
            text = 'UI Scaling',
            column = 1,
            order = 1
        },
        
        -- Description text
        desc = {
            type = 'text',
            text = 'Adjust the UI scale to fit your screen resolution.\nYou can use the Auto Scale button to automatically set the scale based on your screen resolution.\nChanges will take effect immediately, but you may need to reload your UI for some elements to update properly.',
            column = 1,
            width = 300,
            order = 2
        },
        
        -- Scale slider
        scale = {
            type = 'slider',
            name = 'Scale',
            desc = 'Adjust the UI scale',
            min = 0.5,
            max = 1.2,
            step = 0.01,
            width = 300,
            initialValue = 1.0,
            get = function() 
                return module.getCurrentScale()
            end,
            set = function(_, value)
                module.applyScale(value)
            end,
            column = 1,
            order = 3
        },
        
        -- Auto Scale button
        autoButton = {
            type = 'button',
            text = 'Auto Scale',
            desc = 'Set optimal scale based on screen resolution',
            width = 140,
            onClick = function()
                -- Calculate optimal scale based on screen resolution
                local screenHeight = select(2, GetPhysicalScreenSize())
                local newScale = 768 / screenHeight
                
                DebugPrint("Config - Auto Scale - Screen height: " .. screenHeight .. ", calculated scale: " .. newScale)
                
                -- Apply using our function
                module.applyScale(newScale)
            end,
            column = 1,
            order = 4
        },
        
        -- Default button
        defaultButton = {
            type = 'button',
            text = 'Default (1.0)',
            desc = 'Reset to default scale',
            width = 140,
            onClick = function()
                module.applyScale(1.0)
            end,
            column = 1,
            order = 5
        },
        
        -- Reload UI button
        reloadButton = {
            type = 'button',
            text = 'Reload UI',
            desc = 'Reload the UI to ensure all elements update properly',
            width = 140,
            onClick = function()
                ReloadUI()
            end,
            column = 1,
            order = 6
        },
    }
}

-- Register the module with Phoenix_UI
local Layout = Phoenix_UI:NewModule('Config.Layout.UIScaling')
Layout.name = module.name
Layout.enabled = module.enabled
Layout.init = module.init
Layout.applyScale = module.applyScale
Layout.getCurrentScale = module.getCurrentScale
Layout.layout = module.layout

function Layout:OnEnable()
    -- Initialize any required variables or settings
    Phoenix_UI.config = Phoenix_UI.config or {}
    Phoenix_UI.config.uiscaling = Phoenix_UI.config.uiscaling or {}
    
    -- Ensure the UI scaling structure exists
    C_Timer.After(2, function()
        -- Get the saved scale value
        local currentScale = self:GetCurrentScale()
        DebugPrint("UI Scaling module initialized with scale: " .. currentScale)
        
        -- Verify that scale is correctly set in all places
        if Phoenix_UI.db and Phoenix_UI.db.profile then
            Phoenix_UI.db.profile.uiscaling = Phoenix_UI.db.profile.uiscaling or {}
            if Phoenix_UI.db.profile.uiscaling.scale ~= currentScale then
                Phoenix_UI.db.profile.uiscaling.scale = currentScale
                DebugPrint("Updated Phoenix_UI.db.profile.uiscaling.scale to: " .. currentScale)
            end
        end
        
        -- Apply scale to ensure UI is correctly scaled
        if Phoenix_UI_Scale and Phoenix_UI_Scale.Scale then
            Phoenix_UI_Scale.Scale(currentScale)
        else
            -- Fallback if Phoenix_UI_Scale.Scale isn't available
            SetCVar("uiScale", tostring(currentScale))
            UIParent:SetScale(currentScale)
        end
        
        -- Force save the settings to ensure persistence
        if Phoenix_UI and Phoenix_UI.SaveDB then
            Phoenix_UI:SaveDB()
        end
    end)
    
    -- Define the layout structure
    Layout.layout = {
        layoutConfig = { padding = { top = 15 } },
        database = Phoenix_UI.db.profile.uiscaling,
        rows = {
            {
                header = {
                    type = 'header',
                    label = 'UI Scaling'
                }
            },
            {
                scaleSlider = {
                    key = 'scale',
                    type = 'slider',
                    label = 'UI Scale',
                    precision = 2,
                    min = 0.5,
                    max = 1.2,
                    initialValue = 1.0,
                    column = 8,
                    order = 1,
                    onChange = function(slider)
                        -- Immediately apply the scale
                        local value = slider.value
                        
                        -- Validate and apply immediately with all save mechanisms
                        self:ApplyScale(value, true)
                        
                        -- Also force an explicit save
                        if Phoenix_UI and Phoenix_UI.SaveDB then
                            C_Timer.After(0.2, function()
                                Phoenix_UI:SaveDB()
                                DebugPrint("UI Scale " .. value .. " applied and saved")
                            end)
                        end
                        
                        -- Force a UI refresh
                        if Phoenix_UI.UI and Phoenix_UI.UI.RefreshConfig then
                            C_Timer.After(0.3, function()
                                Phoenix_UI.UI:RefreshConfig()
                            end)
                        end
                    end
                }
            },
            {
                autoButton = {
                    type = 'button',
                    label = 'Auto Scale',
                    tooltip = 'Set optimal scale based on screen resolution',
                    column = 4,
                    order = 1,
                    onClick = function()
                        local screenHeight = select(2, GetPhysicalScreenSize())
                        local newScale = 768 / screenHeight
                        
                        DebugPrint("Config - Auto Scale - Screen height: " .. screenHeight .. ", calculated scale: " .. newScale)
                        
                        -- Apply using our function
                        self:ApplyScale(newScale)
                        
                        -- Update the UI to reflect the new scale
                        C_Timer.After(0.2, function()
                            if Phoenix_UI.UI and Phoenix_UI.UI.configPanel then
                                local slider = Phoenix_UI.UI.configPanel:GetSliderByName("scale")
                                if slider then
                                    DebugPrint("Config - Updating slider UI to: " .. newScale)
                                    slider:SetValue(newScale)
                                end
                            end
                        end)
                    end
                },
                resetButton = {
                    type = 'button',
                    label = 'Reset to Default',
                    tooltip = 'Reset to default UI scale (1.0)',
                    column = 4,
                    order = 2,
                    onClick = function()
                        self:ApplyScale(1.0)
                    end
                },
                reloadButton = {
                    type = 'button',
                    label = 'Reload UI',
                    tooltip = 'Reload the UI to apply changes',
                    column = 4,
                    order = 3,
                    onClick = function()
                        ReloadUI()
                    end
                }
            }
        }
    }
end

-- Enhance the ApplyScale function to be more robust
function Layout:ApplyScale(value, skipSave)
    -- Validate input
    if not value or tonumber(value) == nil then
        DebugPrint("Invalid scale value")
        return
    end
    
    -- Round to 2 decimal places for display clarity
    value = math.floor(value * 100 + 0.5) / 100
    
    -- Enforce min/max constraints
    if tonumber(value) > 1.2 then value = 1.2 end
    if tonumber(value) < 0.5 then value = 0.5 end
    
    -- Print debug info
    DebugPrint("Config - Applying UI Scale: " .. value)
    
    -- Set the CVar and apply to UIParent directly for immediate effect
    SetCVar("uiScale", tostring(value))
    UIParent:SetScale(value)
    
    -- Save to AceDB
    if Phoenix_UI.db and Phoenix_UI.db.profile then
        Phoenix_UI.db.profile.uiscaling = Phoenix_UI.db.profile.uiscaling or {}
        Phoenix_UI.db.profile.uiscaling.scale = value
    end
    
    -- Save to Phoenix_UI config
    if Phoenix_UI.config then
        Phoenix_UI.config.uiscaling = Phoenix_UI.config.uiscaling or {}
        Phoenix_UI.config.uiscaling.scale = value
    end
    
    -- Get current profile name
    local currentProfile = "Default"
    if Phoenix_UI.db and Phoenix_UI.db.keys and Phoenix_UI.db.keys.profile then
        currentProfile = Phoenix_UI.db.keys.profile
    end
    
    -- Direct save to Phoenix_UIDB for redundancy
    _G["Phoenix_UIDB"] = _G["Phoenix_UIDB"] or {}
    _G["Phoenix_UIDB"].profiles = _G["Phoenix_UIDB"].profiles or {}
    _G["Phoenix_UIDB"].profiles[currentProfile] = _G["Phoenix_UIDB"].profiles[currentProfile] or {}
    _G["Phoenix_UIDB"].profiles[currentProfile].uiscaling = _G["Phoenix_UIDB"].profiles[currentProfile].uiscaling or {}
    _G["Phoenix_UIDB"].profiles[currentProfile].uiscaling.scale = value
    
    -- Also save to Default profile for backward compatibility
    _G["Phoenix_UIDB"].profiles.Default = _G["Phoenix_UIDB"].profiles.Default or {}
    _G["Phoenix_UIDB"].profiles.Default.uiscaling = _G["Phoenix_UIDB"].profiles.Default.uiscaling or {}
    _G["Phoenix_UIDB"].profiles.Default.uiscaling.scale = value
    
    -- Apply the scale using dedicated function if available
    if Phoenix_UI_Scale and Phoenix_UI_Scale.Scale then
        -- Use the dedicated UI scaling function
        DebugPrint("Config - Using Phoenix_UI_Scale.Scale")
        Phoenix_UI_Scale.Scale(value)
    end
    
    -- Call SaveDB to persist if available and not skipped
    if not skipSave and Phoenix_UI and Phoenix_UI.SaveDB then
        Phoenix_UI:SaveDB()
        DebugPrint("Config - Called Phoenix_UI:SaveDB()")
    end
    
    -- Update any UI elements showing the scale value
    C_Timer.After(0.1, function()
        if Phoenix_UI.UI and Phoenix_UI.UI.configPanel then
            local slider = Phoenix_UI.UI.configPanel:GetSliderByName("scale")
            if slider then
                DebugPrint("Config - Updating UI")
                slider:SetValue(value)
            end
        end
    end)
    
    return value
end

-- Get current scale function
function Layout:GetCurrentScale()
    local scale
    
    -- Try to get from Phoenix_UI.db first
    if Phoenix_UI.db and Phoenix_UI.db.profile and Phoenix_UI.db.profile.uiscaling and Phoenix_UI.db.profile.uiscaling.scale then
        scale = Phoenix_UI.db.profile.uiscaling.scale
        return scale
    end
    
    -- Try to get from Phoenix_UI.config
    if Phoenix_UI.config and Phoenix_UI.config.uiscaling and Phoenix_UI.config.uiscaling.scale then
        scale = Phoenix_UI.config.uiscaling.scale
        return scale
    end
    
    -- Try to get from Phoenix_UIDB
    if _G["Phoenix_UIDB"] and _G["Phoenix_UIDB"].profiles then
        -- Get current profile
        local currentProfile = "Default"
        if Phoenix_UI.db and Phoenix_UI.db.keys and Phoenix_UI.db.keys.profile then
            currentProfile = Phoenix_UI.db.keys.profile
        end
        
        -- Try current profile first
        if _G["Phoenix_UIDB"].profiles[currentProfile] and 
           _G["Phoenix_UIDB"].profiles[currentProfile].uiscaling and 
           _G["Phoenix_UIDB"].profiles[currentProfile].uiscaling.scale then
            scale = _G["Phoenix_UIDB"].profiles[currentProfile].uiscaling.scale
            return scale
        end
        
        -- Try Default profile as fallback
        if _G["Phoenix_UIDB"].profiles.Default and 
           _G["Phoenix_UIDB"].profiles.Default.uiscaling and 
           _G["Phoenix_UIDB"].profiles.Default.uiscaling.scale then
            scale = _G["Phoenix_UIDB"].profiles.Default.uiscaling.scale
            return scale
        end
    end
    
    -- Fallback to current UI scale if nothing is saved
    scale = UIParent:GetScale()
    return scale
end

-- Clean up the old function that's no longer needed
Phoenix_UI.config.uiscaling.GetLayout = nil

-- Create a global reference for the scale function
_G["Phoenix_UI_ApplyScale"] = Layout.ApplyScale

-- Register for addon loaded event to initialize scaling
local scalingFrame = CreateFrame("Frame")
scalingFrame:RegisterEvent("PLAYER_ENTERING_WORLD")
scalingFrame:RegisterEvent("ADDON_LOADED")
scalingFrame:SetScript("OnEvent", function(self, event, addonName)
    if (event == "ADDON_LOADED" and addonName == "Phoenix_UI") or event == "PLAYER_ENTERING_WORLD" then
        C_Timer.After(1, function()
            -- Get saved scale from profile
            local scale = nil
            
            -- First try Phoenix_UI.db
            if Phoenix_UI and Phoenix_UI.db and Phoenix_UI.db.profile and 
               Phoenix_UI.db.profile.uiscaling and Phoenix_UI.db.profile.uiscaling.scale then
                scale = Phoenix_UI.db.profile.uiscaling.scale
            end
            
            -- If not found, try Phoenix_UIDB global
            if not scale and _G["Phoenix_UIDB"] and _G["Phoenix_UIDB"].profiles then
                local currentProfile = Phoenix_UI.db and Phoenix_UI.db.keys and Phoenix_UI.db.keys.profile or "Default"
                if _G["Phoenix_UIDB"].profiles[currentProfile] and 
                   _G["Phoenix_UIDB"].profiles[currentProfile].uiscaling then
                    scale = _G["Phoenix_UIDB"].profiles[currentProfile].uiscaling.scale
                end
                
                -- Try default profile as last resort
                if not scale and _G["Phoenix_UIDB"].profiles.Default and 
                   _G["Phoenix_UIDB"].profiles.Default.uiscaling then
                    scale = _G["Phoenix_UIDB"].profiles.Default.uiscaling.scale
                end
            end
            
            -- Apply found scale
            if scale then
                Layout.ApplyScale(scale)
            end
        end)
        
        self:UnregisterEvent("PLAYER_ENTERING_WORLD")
    end
end) 