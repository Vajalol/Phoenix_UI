-- Phoenix_UI: Module Integration
-- Provides integration between various modules to enhance the overall user experience

local addonName, addon = ...
local Phoenix_UI = LibStub("AceAddon-3.0"):GetAddon("Phoenix_UI")
local Module = Phoenix_UI:NewModule("ModuleIntegration", "AceEvent-3.0", "AceTimer-3.0", "AceHook-3.0")

-- Default settings
local defaults = {
    profile = {
        enabled = true,
        notifyModuleUpdates = true,
        synchronizeBorderColors = true,
        synchronizeFonts = true,
        shareSettings = true,
        useUnifiedTheme = true,
        autoAdjustScale = true,
        moduleConnections = {
            -- Connect UnitFrames and NamePlates
            unitFramesToNameplates = true,
            -- Connect ActionBars and CooldownTracker
            actionBarsToCooldowns = true,
            -- Connect Buffs to WeakAuras and BuffOverlay
            buffsToWeakAuras = true,
            -- Connect Maps and MoveAny
            mapsToMoveAny = true,
            -- Connect RaidFrames to UnitFrames
            raidFramesToUnitFrames = true,
            -- Connect Mythic+ Timer to CastBars
            mythicPlusToCastBars = true,
        }
    }
}

-- Module references
local modules = {}

-- Local variables
local syncInProgress = false
local isInitializing = true
local moduleStatus = {}
local themeCache = {}

-- Initialize the module
function Module:OnInitialize()
    -- Get parent addon
    local Phoenix_UI = LibStub("AceAddon-3.0"):GetAddon("Phoenix_UI")
    
    -- Store reference to parent
    self.Phoenix_UI = Phoenix_UI
    
    -- DEBUG: Add logging to help diagnose the issue
    if Phoenix_UI.debug then
        print("Phoenix_UI: ModuleIntegration OnInitialize called")
    end
    
    -- AVOID NAMESPACE REGISTRATION ENTIRELY
    -- Instead of registering a namespace, just use the parent's DB
    if Phoenix_UI.db and Phoenix_UI.db.profile then
        -- Create moduleIntegration section if it doesn't exist
        if not Phoenix_UI.db.profile.moduleIntegration then
            Phoenix_UI.db.profile.moduleIntegration = defaults.profile
        end
        
        -- Point our .db.profile to the parent's db.profile.moduleIntegration
        self.db = {
            profile = Phoenix_UI.db.profile.moduleIntegration
        }
        
        if Phoenix_UI.debug then
            print("Phoenix_UI: ModuleIntegration using parent DB directly")
        end
    else
        if Phoenix_UI.debug then
            print("Phoenix_UI: ModuleIntegration - parent DB not available")
        end
    end
    
    -- Register events
    self:RegisterEvent("PLAYER_ENTERING_WORLD")
    self:RegisterEvent("ADDON_LOADED")
    
    -- Register messages
    self:RegisterMessage("PHOENIX_UI_SETTING_CHANGED")
    self:RegisterMessage("PHOENIX_UI_PROFILE_CHANGED")
    
    -- Initialize module status table
    self:InitializeModuleStatus()
end

-- Initialize module status table
function Module:InitializeModuleStatus()
    moduleStatus = {
        UnitFrames = { loaded = false, initialized = false },
        NamePlates = { loaded = false, initialized = false },
        ActionBars = { loaded = false, initialized = false },
        CooldownTracker = { loaded = false, initialized = false },
        Buffs = { loaded = false, initialized = false },
        WeakAurasIntegration = { loaded = false, initialized = false },
        BuffOverlay = { loaded = false, initialized = false },
        Maps = { loaded = false, initialized = false },
        MoveAny = { loaded = false, initialized = false },
        RaidFrames = { loaded = false, initialized = false },
        CastBars = { loaded = false, initialized = false },
        MythicPlus = { loaded = false, initialized = false },
        UIscaling = { loaded = false, initialized = false },
    }
end

-- Enable the module
function Module:OnEnable()
    -- Get parent addon
    local Phoenix_UI = LibStub("AceAddon-3.0"):GetAddon("Phoenix_UI")
    
    -- Check if this module is enabled in settings
    if Phoenix_UI.db and Phoenix_UI.db.profile and 
       Phoenix_UI.db.profile.moduleIntegration and 
       Phoenix_UI.db.profile.moduleIntegration.enabled == false then
        self:Disable()
        return
    end
    
    -- Check for required modules
    for moduleName, _ in pairs(moduleStatus) do
        self:CheckModule(moduleName)
    end
    
    -- Schedule module connection after a delay to ensure all modules are loaded
    self:ScheduleTimer("ConnectModules", 2)
    
    -- Hook theme functions
    self:HookThemeFunctions()
    
    isInitializing = false
end

-- Disable the module
function Module:OnDisable()
    self:UnhookAll()
end

-- Event handler for PLAYER_ENTERING_WORLD
function Module:PLAYER_ENTERING_WORLD()
    -- Update all module connections
    self:ConnectModules()
    
    -- Get parent addon's DB
    local parentDB = self.Phoenix_UI.db
    local moduleConfig = parentDB and parentDB.profile and parentDB.profile.moduleIntegration or {}
    
    -- Apply theme synchronization
    if moduleConfig.useUnifiedTheme then
        self:SynchronizeTheme()
    end
    
    -- Adjust UI scale if needed
    if moduleConfig.autoAdjustScale then
        self:AdjustUIScale()
    end
end

-- Event handler for ADDON_LOADED
function Module:ADDON_LOADED(event, addOnName)
    -- Check if this is our addon
    if addOnName:find("Phoenix_UI") then
        for moduleName, _ in pairs(moduleStatus) do
            self:CheckModule(moduleName)
        end
    end
end

-- Check if a module is loaded
function Module:CheckModule(moduleName)
    local module = Phoenix_UI:GetModule(moduleName, true)
    if module then
        moduleStatus[moduleName].loaded = true
        modules[moduleName] = module
        
        -- Debug output
        if Phoenix_UI.debug then
            print("Phoenix_UI Module Integration: Found module " .. moduleName)
        end
        
        return true
    end
    
    return false
end

-- Connect modules based on current settings
function Module:ConnectModules()
    if syncInProgress then return end
    
    syncInProgress = true
    
    -- Get parent addon's DB
    local parentDB = self.Phoenix_UI.db
    local moduleConfig = parentDB and parentDB.profile and parentDB.profile.moduleIntegration or {}
    local connections = moduleConfig.moduleConnections or {}
    
    -- Connect UnitFrames and NamePlates
    if connections.unitFramesToNameplates then
        self:ConnectUnitFramesAndNameplates()
    end
    
    -- Connect ActionBars and CooldownTracker
    if connections.actionBarsToCooldowns then
        self:ConnectActionBarsAndCooldowns()
    end
    
    -- Connect Buffs and WeakAuras
    if connections.buffsToWeakAuras then
        self:ConnectBuffsAndWeakAuras()
    end
    
    -- Connect Maps and MoveAny
    if connections.mapsToMoveAny then
        self:ConnectMapsAndMoveAny()
    end
    
    -- Connect RaidFrames and UnitFrames
    if connections.raidFramesToUnitFrames then
        self:ConnectRaidFramesAndUnitFrames()
    end
    
    -- Connect MythicPlus and CastBars
    if connections.mythicPlusToCastBars then
        self:ConnectMythicPlusAndCastBars()
    end
    
    -- Apply theme synchronization
    self:HookThemeFunctions()
    
    -- Apply UI scaling
    if moduleConfig.autoAdjustScale then
        self:AdjustUIScale()
    end
    
    syncInProgress = false
    
    -- Generate a status report
    if moduleConfig.notifyModuleUpdates and not isInitializing then
        self:PrintStatusReport()
    end
end

-- Print status report of module integrations
function Module:PrintStatusReport()
    local count = 0
    local message = "Phoenix UI Module Integration: "
    
    for moduleName, status in pairs(moduleStatus) do
        if status.loaded then
            count = count + 1
        end
    end
    
    if count > 0 then
        message = message .. count .. " modules connected successfully."
    else
        message = message .. "No modules connected."
    end
    
    print(message)
end

-- Connect UnitFrames and NamePlates
function Module:ConnectUnitFramesAndNameplates()
    local UnitFrames = modules.UnitFrames
    local NamePlates = modules.NamePlates
    
    if not UnitFrames or not NamePlates then
        return
    end
    
    -- Share border textures
    if self.db.profile.synchronizeBorderColors and UnitFrames.GetBorderTexture and NamePlates.SetBorderTexture then
        local borderTexture = UnitFrames:GetBorderTexture()
        if borderTexture then
            NamePlates:SetBorderTexture(borderTexture)
        end
    end
    
    -- Share health bar and resource bar textures
    if UnitFrames.GetStatusBarTexture and NamePlates.SetStatusBarTexture then
        local statusBarTexture = UnitFrames:GetStatusBarTexture()
        if statusBarTexture then
            NamePlates:SetStatusBarTexture(statusBarTexture)
        end
    end
    
    -- Share font settings
    if self.db.profile.synchronizeFonts and UnitFrames.GetFont and NamePlates.SetFont then
        local font, size, flags = UnitFrames:GetFont()
        if font then
            NamePlates:SetFont(font, size, flags)
        end
    end
    
    -- Store connection in status
    moduleStatus.UnitFrames.initialized = true
    moduleStatus.NamePlates.initialized = true
end

-- Connect ActionBars and CooldownTracker
function Module:ConnectActionBarsAndCooldowns()
    local ActionBars = modules.ActionBars
    local CooldownTracker = modules.CooldownTracker
    
    if not ActionBars or not CooldownTracker then
        return
    end
    
    -- Share cooldown settings
    if ActionBars.GetCooldownSettings and CooldownTracker.SetCooldownSettings then
        local cooldownSettings = ActionBars:GetCooldownSettings()
        if cooldownSettings then
            CooldownTracker:SetCooldownSettings(cooldownSettings)
        end
    end
    
    -- Share font and text style
    if self.db.profile.synchronizeFonts and ActionBars.GetFont and CooldownTracker.SetFont then
        local font, size, flags = ActionBars:GetFont()
        if font then
            CooldownTracker:SetFont(font, size, flags)
        end
    end
    
    -- Hook action bar button updates to refresh cooldowns
    if not self.ActionBarHooked and ActionBars.UpdateActionButtons and CooldownTracker.UpdateCooldowns then
        self:SecureHook(ActionBars, "UpdateActionButtons", function()
            CooldownTracker:UpdateCooldowns()
        end)
        self.ActionBarHooked = true
    end
    
    -- Store connection in status
    moduleStatus.ActionBars.initialized = true
    moduleStatus.CooldownTracker.initialized = true
end

-- Connect Buffs, WeakAuras, and BuffOverlay
function Module:ConnectBuffsAndWeakAuras()
    local Buffs = modules.Buffs
    local WeakAurasIntegration = modules.WeakAurasIntegration
    local BuffOverlay = modules.BuffOverlay
    
    -- Connect Buffs and WeakAuras
    if Buffs and WeakAurasIntegration then
        -- Share border and texture styles
        if self.db.profile.synchronizeBorderColors and Buffs.GetBorderTexture and WeakAurasIntegration.SetBorderTexture then
            local borderTexture = Buffs:GetBorderTexture()
            if borderTexture then
                WeakAurasIntegration:SetBorderTexture(borderTexture)
            end
        end
        
        -- Share font settings
        if self.db.profile.synchronizeFonts and Buffs.GetFont and WeakAurasIntegration.SetFont then
            local font, size, flags = Buffs:GetFont()
            if font then
                WeakAurasIntegration:SetFont(font, size, flags)
            end
        end
        
        -- Store connection in status
        moduleStatus.Buffs.initialized = true
        moduleStatus.WeakAurasIntegration.initialized = true
    end
    
    -- Connect Buffs and BuffOverlay
    if Buffs and BuffOverlay then
        -- Share settings
        if self.db.profile.shareSettings and Buffs.GetBuffSettings and BuffOverlay.SetBuffSettings then
            local buffSettings = Buffs:GetBuffSettings()
            if buffSettings then
                BuffOverlay:SetBuffSettings(buffSettings)
            end
        end
        
        -- Store connection in status
        moduleStatus.BuffOverlay.initialized = true
    end
end

-- Connect Maps and MoveAny
function Module:ConnectMapsAndMoveAny()
    local Maps = modules.Maps
    local MoveAny = modules.MoveAny
    
    if not Maps or not MoveAny then
        return
    end
    
    -- Register map frames with MoveAny
    if Maps.GetMapFrames and MoveAny.RegisterFrames then
        local mapFrames = Maps:GetMapFrames()
        if mapFrames then
            MoveAny:RegisterFrames(mapFrames)
        end
    end
    
    -- Store connection in status
    moduleStatus.Maps.initialized = true
    moduleStatus.MoveAny.initialized = true
end

-- Connect RaidFrames and UnitFrames
function Module:ConnectRaidFramesAndUnitFrames()
    local RaidFrames = modules.RaidFrames
    local UnitFrames = modules.UnitFrames
    
    if not RaidFrames or not UnitFrames then
        return
    end
    
    -- Share border textures
    if self.db.profile.synchronizeBorderColors and UnitFrames.GetBorderTexture and RaidFrames.SetBorderTexture then
        local borderTexture = UnitFrames:GetBorderTexture()
        if borderTexture then
            RaidFrames:SetBorderTexture(borderTexture)
        end
    end
    
    -- Share health bar textures
    if UnitFrames.GetStatusBarTexture and RaidFrames.SetStatusBarTexture then
        local statusBarTexture = UnitFrames:GetStatusBarTexture()
        if statusBarTexture then
            RaidFrames:SetStatusBarTexture(statusBarTexture)
        end
    end
    
    -- Share font settings
    if self.db.profile.synchronizeFonts and UnitFrames.GetFont and RaidFrames.SetFont then
        local font, size, flags = UnitFrames:GetFont()
        if font then
            RaidFrames:SetFont(font, size, flags)
        end
    end
    
    -- Store connection in status
    moduleStatus.RaidFrames.initialized = true
end

-- Connect Mythic+ and CastBars
function Module:ConnectMythicPlusAndCastBars()
    local MythicPlus = modules.MythicPlus
    local CastBars = modules.CastBars
    
    if not MythicPlus or not CastBars then
        return
    end
    
    -- Share timer textures
    if MythicPlus.GetTimerTexture and CastBars.SetCastBarTexture then
        local timerTexture = MythicPlus:GetTimerTexture()
        if timerTexture then
            CastBars:SetCastBarTexture(timerTexture)
        end
    end
    
    -- Store connection in status
    moduleStatus.MythicPlus.initialized = true
    moduleStatus.CastBars.initialized = true
end

-- Hook theme functions
function Module:HookThemeFunctions()
    -- Hook Phoenix_UI theme change functions
    if Phoenix_UI.SetTheme then
        self:SecureHook(Phoenix_UI, "SetTheme", function(_, theme)
            if self.db.profile.useUnifiedTheme then
                self:SynchronizeTheme(theme)
            end
        end)
    end
    
    if Phoenix_UI.SetColor then
        self:SecureHook(Phoenix_UI, "SetColor", function(_, r, g, b, a)
            if self.db.profile.useUnifiedTheme then
                self:SynchronizeColors(r, g, b, a)
            end
        end)
    end
end

-- Synchronize theme across all modules
function Module:SynchronizeTheme(theme)
    if syncInProgress then return end
    
    syncInProgress = true
    
    -- Get theme if not provided
    theme = theme or (Phoenix_UI.GetTheme and Phoenix_UI:GetTheme()) or "Default"
    
    -- Cache theme data
    themeCache.theme = theme
    themeCache.color = Phoenix_UI.GetThemeColor and Phoenix_UI:GetThemeColor() or {r=1, g=0.5, b=0, a=1}
    themeCache.font = Phoenix_UI.GetFontFamily and Phoenix_UI:GetFontFamily() or "Interface\\AddOns\\Phoenix_UI\\Media\\Fonts\\Expressway.ttf"
    themeCache.fontSize = Phoenix_UI.GetFontSize and Phoenix_UI:GetFontSize() or 12
    themeCache.fontFlags = Phoenix_UI.GetFontFlags and Phoenix_UI:GetFontFlags() or "OUTLINE"
    themeCache.borderTexture = Phoenix_UI.GetBorderTexture and Phoenix_UI:GetBorderTexture() or "Interface\\AddOns\\Phoenix_UI\\Media\\Textures\\Border"
    themeCache.barTexture = Phoenix_UI.GetBarTexture and Phoenix_UI:GetBarTexture() or "Interface\\AddOns\\Phoenix_UI\\Media\\Textures\\Smooth"
    
    -- Apply theme to each module
    for moduleName, module in pairs(modules) do
        -- Apply theme if the module has the SetTheme function
        if module.SetTheme then
            module:SetTheme(theme)
        end
        
        -- Apply colors if the module has the SetColor function
        if module.SetColor then
            module:SetColor(themeCache.color.r, themeCache.color.g, themeCache.color.b, themeCache.color.a)
        end
        
        -- Apply font if the module has the SetFont function
        if self.db.profile.synchronizeFonts and module.SetFont then
            module:SetFont(themeCache.font, themeCache.fontSize, themeCache.fontFlags)
        end
        
        -- Apply border texture if the module has the SetBorderTexture function
        if self.db.profile.synchronizeBorderColors and module.SetBorderTexture then
            module:SetBorderTexture(themeCache.borderTexture)
        end
        
        -- Apply bar texture if the module has the SetStatusBarTexture function
        if module.SetStatusBarTexture then
            module:SetStatusBarTexture(themeCache.barTexture)
        end
    end
    
    syncInProgress = false
end

-- Synchronize colors across all modules
function Module:SynchronizeColors(r, g, b, a)
    if syncInProgress then return end
    
    syncInProgress = true
    
    -- Apply colors to each module
    for moduleName, module in pairs(modules) do
        if module.SetColor then
            module:SetColor(r, g, b, a)
        end
    end
    
    syncInProgress = false
end

-- Adjust UI scaling
function Module:AdjustUIScale()
    -- Get modules
    local modules = self.Phoenix_UI.modules
    local UIscaling = modules.UIscaling
    
    if not UIscaling or not UIscaling.AutoScale then
        return
    end
    
    -- Only auto-scale if enabled
    -- First check if we have a valid DB
    local parentDB = self.Phoenix_UI.db
    if parentDB and parentDB.profile and parentDB.profile.moduleIntegration and 
       parentDB.profile.moduleIntegration.autoAdjustScale then
        UIscaling:AutoScale()
    end
    
    -- Store connection in status
    moduleStatus.UIscaling.initialized = true
end

-- Handle setting changes
function Module:PHOENIX_UI_SETTING_CHANGED(event, key, value)
    if key:match("^moduleIntegration%.") then
        -- Re-apply module connections
        self:ConnectModules()
    elseif key:match("^general%.theme") or key:match("^general%.color") then
        -- Re-apply theme synchronization
        local parentDB = self.Phoenix_UI.db
        local useUnifiedTheme = parentDB and parentDB.profile and 
                               parentDB.profile.moduleIntegration and 
                               parentDB.profile.moduleIntegration.useUnifiedTheme
        
        if useUnifiedTheme then
            self:SynchronizeTheme()
        end
    end
end

-- Handle profile changes
function Module:PHOENIX_UI_PROFILE_CHANGED()
    -- Re-initialize module connections
    self:ConnectModules()
    
    -- Re-apply theme
    local parentDB = self.Phoenix_UI.db
    local useUnifiedTheme = parentDB and parentDB.profile and 
                          parentDB.profile.moduleIntegration and 
                          parentDB.profile.moduleIntegration.useUnifiedTheme
    
    if useUnifiedTheme then
        self:SynchronizeTheme()
        self:SynchronizeColors()
    end
end

-- API Functions for other modules to use
function Module:GetModuleStatus(moduleName)
    return moduleStatus[moduleName]
end

function Module:GetAllModuleStatus()
    return moduleStatus
end

function Module:GetThemeCache()
    return themeCache
end

function Module:ForceModuleConnection(moduleName1, moduleName2)
    -- Check if both modules exist
    local module1 = modules[moduleName1]
    local module2 = modules[moduleName2]
    
    if not module1 or not module2 then
        return false
    end
    
    -- Connect the modules based on their types
    if moduleName1 == "UnitFrames" and moduleName2 == "NamePlates" then
        self:ConnectUnitFramesAndNameplates()
        return true
    elseif moduleName1 == "ActionBars" and moduleName2 == "CooldownTracker" then
        self:ConnectActionBarsAndCooldowns()
        return true
    elseif moduleName1 == "Buffs" and (moduleName2 == "WeakAurasIntegration" or moduleName2 == "BuffOverlay") then
        self:ConnectBuffsAndWeakAuras()
        return true
    elseif moduleName1 == "Maps" and moduleName2 == "MoveAny" then
        self:ConnectMapsAndMoveAny()
        return true
    elseif moduleName1 == "RaidFrames" and moduleName2 == "UnitFrames" then
        self:ConnectRaidFramesAndUnitFrames()
        return true
    elseif moduleName1 == "MythicPlus" and moduleName2 == "CastBars" then
        self:ConnectMythicPlusAndCastBars()
        return true
    end
    
    return false
end

-- Return the module, but check if it's already assigned first
if not Phoenix_UI.modules then
    Phoenix_UI.modules = {}
end

-- Only assign if not already assigned, to prevent double loading
if not Phoenix_UI.modules.ModuleIntegration then
    Phoenix_UI.modules.ModuleIntegration = Module
end
