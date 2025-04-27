-- Phoenix_UI: Details! Skin Module
-- Adds a phoenix/fire themed skin to Details! damage meter

local addonName, Phoenix = ...
local DetailsSkin = Phoenix_UI:NewModule("DetailSkin", "AceEvent-3.0", "AceHook-3.0", "AceConsole-3.0")
local L = Phoenix_UI.L

-- Add the skin profile
local skinProfile = {}

-- Localization
L["DETAILS_SKIN"] = "Details! Skin"
L["DETAILS_SKIN_DESC"] = "Apply the Phoenix UI skin to Details! damage meter"
L["DETAILS_SKIN_APPLY"] = "Apply Skin to Details!"
L["DETAILS_SKIN_APPLIED"] = "Phoenix skin has been applied to Details!"
L["DETAILS_SKIN_ERROR"] = "Details! addon is not loaded or not found"
L["DETAILS_SKIN_MISSING"] = "Details! addon is required for this feature"
L["DETAILS_SKIN_TWW"] = "The War Within skin has been applied to Details!"
L["DETAILS_PROFILE_TWW"] = "The War Within profile has been imported to Details!"
L["DETAILS_RESET"] = "Details! has been reset to default settings"

-- Skin colors
local colors = {
    frame = {0.1, 0.1, 0.1, 0.9},         -- Dark background
    title = {1, 0.5, 0, 1},                -- Phoenix orange for title
    titleText = {1, 0.7, 0.3, 1},          -- Light orange for title text
    border = {0.7, 0.2, 0, 0.8},           -- Darker orange for border
    barFill = {1, 0.5, 0, 1},              -- Phoenix orange for bar fill
    barBackground = {0.1, 0.1, 0.1, 0.8},  -- Dark bar background
    highlight = {1, 0.8, 0.2, 0.7},        -- Golden highlight
    shadow = {0, 0, 0, 0.5},               -- Shadow effect
    statusbar = {0.9, 0.4, 0, 1}           -- Status bar color
}

-- Skin texture paths
local textures = {
    background = [[Interface\AddOns\Phoenix_UI\Media\Textures\Background\DarkPanel.blp]],
    barTexture = [[Interface\AddOns\Phoenix_UI\Media\Textures\Status\Gradient.blp]],
    border = [[Interface\AddOns\Phoenix_UI\Media\Textures\Border\Phoenix.blp]],
    icon = [[Interface\AddOns\Phoenix_UI\Media\Icons\Phoenix.blp]],
    statusbar = [[Interface\AddOns\Phoenix_UI\Media\Textures\Status\Glossy.blp]],
    closeButton = [[Interface\AddOns\Phoenix_UI\Media\Textures\Buttons\CloseButton.blp]],
    maximizeButton = [[Interface\AddOns\Phoenix_UI\Media\Textures\Buttons\MaximizeButton.blp]],
    minimizeButton = [[Interface\AddOns\Phoenix_UI\Media\Textures\Buttons\MinimizeButton.blp]]
}

-- Create textures for the skin if they don't exist in Phoenix_UI
local function EnsureTextures()
    -- Ensure the textures directory exists
    local texturesPath = "Interface\\AddOns\\Phoenix_UI\\Modules\\Detail-Skin\\Textures\\"
    
    -- Copy texture files if they don't exist (placeholder - real implementation would check and create)
    DetailsSkin:Debug("Ensuring textures for Details! skin exist")
    
    -- Fallback to built-in textures if Phoenix_UI textures don't exist
    if not textures.background:find("^Interface\\AddOns\\Phoenix_UI") then
        textures.background = "Interface\\DialogFrame\\UI-DialogBox-Background"
        textures.barTexture = "Interface\\TargetingFrame\\UI-StatusBar"
        textures.border = "Interface\\DialogFrame\\UI-DialogBox-Border"
        textures.statusbar = "Interface\\TargetingFrame\\UI-StatusBar"
        textures.closeButton = "Interface\\Buttons\\UI-Panel-MinimizeButton-Up"
        textures.maximizeButton = "Interface\\Buttons\\UI-Panel-SmallerButton-Up"
        textures.minimizeButton = "Interface\\Buttons\\UI-Panel-MinimizeButton-Up"
    end
end

-- Debug function
function DetailsSkin:Debug(message)
    if Phoenix_UI and Phoenix_UI.Debug then
        Phoenix_UI:Debug("DetailsSkin", message)
    end
end

-- Check if Details! is loaded and available
function DetailsSkin:IsDetailsLoaded()
    return _G._detalhes ~= nil
end

-- Handler for when Details! is loaded
function DetailsSkin:OnDetailsLoaded()
    self:Debug("Details! addon has been loaded")
    
    -- Delay to ensure Details! is fully initialized
    C_Timer.After(1, function()
        -- Check if we should auto-apply
        if Phoenix_UI.db and Phoenix_UI.db.profile and 
           Phoenix_UI.db.profile.detailskin and 
           Phoenix_UI.db.profile.detailskin.enabled then
            self:ApplySkin()
            self:Debug("Auto-applying Phoenix skin to Details!")
        end
        
        -- Notify the config panel if it's open
        if Phoenix_UIConfig and Phoenix_UIConfig.RefreshPanel then
            Phoenix_UIConfig:RefreshPanel("DetailSkin")
        end
    end)
end

-- Check if Details! is loaded, but never prevent UI display
function DetailsSkin:ShouldEnableOptions()
    return self:IsDetailsLoaded()
end

-- Apply the Phoenix UI skin to Details! 
function DetailsSkin:ApplySkin()
    -- Check if Details exists
    if not self:IsDetailsLoaded() then
        Phoenix_UI:Print(L["DETAILS_SKIN_ERROR"])
        return false
    end
    
    local Details = _G._detalhes
    
    -- Check if Details is fully initialized
    if not Details or not Details.GetAllInstances then
        Phoenix_UI:Print("Details! is not fully initialized yet. Try again later.")
        return false
    end
    
    Phoenix_UI:Print("Applying Phoenix UI skin to Details...")
    
    -- Apply settings to all Details windows directly instead of using the skin system
    local instances = Details:GetAllInstances()
    if not instances or #instances == 0 then
        Phoenix_UI:Print("No Details windows found. Create a window first.")
        return false
    end
    
    -- Safe method call helper function
    local function safeCall(instance, methodName, ...)
        if instance and type(instance[methodName]) == "function" then
            local success, result = pcall(instance[methodName], instance, ...)
            if not success then
                Phoenix_UI:Print("Warning: Failed to call " .. methodName .. " - " .. (result or "unknown error"))
            end
            return success
        end
        return false
    end
    
    for i, instance in ipairs(instances) do
        if instance then
            Phoenix_UI:Print("Styling Details window " .. i)
            
            -- Setting appearance options that should be available in most versions
            safeCall(instance, "InstanceWallpaper", false)
            safeCall(instance, "DesaturateMenu", false)
            
            -- Try different methods for setting backdrop color - Details has changed these over time
            if not safeCall(instance, "SetBackdropColor", 0.1, 0.1, 0.1, 0.9) then
                -- Alternative method that might exist
                safeCall(instance, "SetWindowColor", 0.1, 0.1, 0.1, 0.9)
            end
            
            -- Try to show the status bar
            safeCall(instance, "ShowStatusBar", true)
            
            -- Try to hide side bars
            safeCall(instance, "ShowSideBars", false)
            
            -- Try different methods of setting textures
            if not safeCall(instance, "SetBackdropTexture", "Interface\\AddOns\\Phoenix_UI\\Media\\Textures\\Background\\DarkPanel.blp") then
                -- Alternative method that might exist
                safeCall(instance, "SetWindowBackground", 0, "Interface\\AddOns\\Phoenix_UI\\Media\\Textures\\Background\\DarkPanel.blp")
            end
            
            -- Set bar text settings if method exists
            safeCall(instance, "SetBarTextSettings", 10, "Friz Quadrata TT")
            
            -- Set bar height if method exists
            safeCall(instance, "SetBarHeight", 20)
            
            -- Try to set bar texture
            safeCall(instance, "SetBarTexture", "Interface\\AddOns\\Phoenix_UI\\Media\\Textures\\Status\\Gradient.blp")
            
            -- Try status bar color - multiple possible method names
            if not safeCall(instance, "StatusBarColor", 0.9, 0.4, 0, 1) then
                safeCall(instance, "SetStatusBarColor", 0.9, 0.4, 0, 1)
            end
            
            -- Force updates using safe calls
            safeCall(instance, "InstanceRefreshRows")
            safeCall(instance, "RefreshBars")
            safeCall(instance, "RefreshMainWindowPosition")
            safeCall(instance, "RefreshSideBars")
        end
    end
    
    Phoenix_UI:Print(L["DETAILS_SKIN_APPLIED"])
    return true
end

-- Import The War Within profile into Details!
function DetailsSkin:ImportProfile()
    -- Check if Details exists
    if not self:IsDetailsLoaded() then
        Phoenix_UI:Print(L["DETAILS_SKIN_ERROR"])
        return false
    end
    
    -- Check if we have the profile data
    if not self.defaultProfile then
        Phoenix_UI:Print("Error: Default profile data not found!")
        return false
    end
    
    local Details = _G._detalhes
    
    -- Import the profile
    if Details.ImportProfile then
        local success = Details:ImportProfile(self.defaultProfile, "The War Within")
        if success then
            Phoenix_UI:Print(L["DETAILS_PROFILE_TWW"])
            return true
        else
            Phoenix_UI:Print("Error: Failed to import profile!")
            return false
        end
    else
        Phoenix_UI:Print("Error: Details! ImportProfile function not found.")
        return false
    end
end

-- Reset Details! to default settings
function DetailsSkin:ResetDetails()
    -- Check if Details exists
    if not self:IsDetailsLoaded() then
        Phoenix_UI:Print(L["DETAILS_SKIN_ERROR"])
        return false
    end
    
    local Details = _G._detalhes
    
    -- Reset to default settings
    if Details.ResetProfile then
        Details:ResetProfile()
        Phoenix_UI:Print(L["DETAILS_RESET"])
        return true
    else
        Phoenix_UI:Print("Error: Details! ResetProfile function not found.")
        return false
    end
end

-- Create GetLayout function that returns the configuration options for the Detail Skin module
function DetailsSkin:GetLayout()
    -- Instead of creating our own layout, reference the one defined in Config/Layouts/_DetailSkin.lua
    if Phoenix_UI and Phoenix_UI.layouts and Phoenix_UI.layouts.DetailSkin then
        return Phoenix_UI.layouts.DetailSkin
    end
    
    -- Fallback simple layout if the layout file isn't loaded
    local L = Phoenix_UI.L
    local options = {
        type = "group",
        name = L["DETAILS_SKIN"] or "Details Skin",
        desc = L["DETAILS_SKIN_DESC"] or "Configure the Details! damage meter skin.",
        handler = DetailsSkin,
        args = {
            infoText = {
                type = "description",
                name = "Details! addon is required for this feature. Please install Details! from your addon manager.",
                order = 1,
                fontSize = "medium",
            },
            applySkin = {
                type = "execute",
                name = L["DETAILS_SKIN_APPLY"] or "Apply Skin",
                desc = L["DETAILS_SKIN_DESC"] or "Apply the Phoenix UI skin to Details! damage meter.",
                order = 20,
                func = function() 
                    DetailsSkin:ApplySkin()
                    Phoenix_UI:Print(L["DETAILS_SKIN_APPLIED"] or "Phoenix skin has been applied to Details!")
                end
            },
            resetButton = {
                type = "execute",
                name = L["RESET_SKIN"] or "Reset Skin",
                desc = L["RESET_SKIN_DESC"] or "Reset the Details! skin to default settings.",
                order = 30,
                func = function() 
                    DetailsSkin:ResetDetails()
                    Phoenix_UI:Print(L["RESET_SKIN_COMPLETE"] or "Details! skin has been reset to default.")
                end
            }
        }
    }
    
    return options
end

-- Add event handler for PLAYER_ENTERING_WORLD
function DetailsSkin:PLAYER_ENTERING_WORLD()
    -- When player enters world, check if Details! is loaded
    if not self:IsDetailsLoaded() then
        return
    end
    
    -- If Details! is loaded but we haven't applied the skin yet, do it now
    self:ApplySkin()
end

function DetailsSkin:OnEnable()
    -- Skip if Details! is not loaded - but still register the config
    if not self:IsDetailsLoaded() then
        Phoenix_UI:Print(L["DETAILS_SKIN_ERROR"])
    else
        -- Setup our hooks/callbacks if Details! is loaded
        self:ApplySkin()
    end
    
    -- Ensure Phoenix_UI.configOptions exists before using it
    if not Phoenix_UI.configOptions then
        Phoenix_UI.configOptions = {}
    end
    
    -- Register the layout with Phoenix_UI config system
    Phoenix_UI.configOptions["DetailSkin"] = self:GetLayout()
    
    -- If the ConfigSystem is available, register with it too
    if Phoenix_UI.ConfigSystem and Phoenix_UI.ConfigSystem.RegisterLayout then
        Phoenix_UI.ConfigSystem:RegisterLayout("DetailSkin", self:GetLayout())
    end
    
    -- Connect our module to the layout defined in Config/Layouts/_DetailSkin.lua
    if Phoenix_UI and Phoenix_UI.layouts and Phoenix_UI.layouts.DetailSkin then
        self.layout = Phoenix_UI.layouts.DetailSkin
    end
    
    -- Setup event handlers - using proper Ace3 event registration
    if self.RegisterEvent then
        self:RegisterEvent("PLAYER_ENTERING_WORLD", "PLAYER_ENTERING_WORLD")
    end
end