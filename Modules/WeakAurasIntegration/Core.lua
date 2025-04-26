local addonName, Phoenix = ...

-- Create the module
local Module = Phoenix_UI:NewModule("WeakAurasIntegration")

-- Check if WeakAuras is loaded
local function IsWeakAurasLoaded()
    -- Check using the appropriate API based on WoW version
    local isLoaded = false
    if C_AddOns and C_AddOns.IsAddOnLoaded then
        isLoaded = C_AddOns.IsAddOnLoaded("WeakAuras")
    elseif IsAddOnLoaded then
        isLoaded = IsAddOnLoaded("WeakAuras")
    else
        -- If neither API is available, check for the global
        return _G.WeakAuras ~= nil
    end
    
    return isLoaded and _G.WeakAuras ~= nil
end

-- Initialize the module
function Module:OnInitialize()
    -- Make sure WeakAuras is loaded
    if not IsWeakAurasLoaded() then
        return
    end
    
    -- Create database defaults if needed
    if not Phoenix_UI.db.profile.weakauras then
        Phoenix_UI.db.profile.weakauras = {
            enabled = true,
            applyTheme = true,
            themedBorders = true,
            themedBars = true,
            useFonts = true,
            performanceMode = true,
            combatUpdateRate = 0.1,
            throttleDuringFPSDrops = true,
            fpsThreshold = 20,
            shareAuraUpdates = true,
            syncWithPhoenixUI = true,
            groupAurasByType = true,
            showTemplates = true
        }
    end
end

-- Enable the module
function Module:OnEnable()
    -- Make sure WeakAuras is loaded
    if not IsWeakAurasLoaded() then
        return
    end
    
    local db = Phoenix_UI.db.profile.weakauras
    
    -- Do not run if disabled
    if db and db.enabled == false then
        return
    end
    
    -- Hook into WeakAuras
    self:HookWeakAuras()
    
    -- Register for Phoenix UI messages
    Phoenix_UI.RegisterMessage(self, "PHOENIX_UI_SETTING_CHANGED", "OnSettingChanged")
    Phoenix_UI.RegisterMessage(self, "PHOENIX_UI_PROFILE_CHANGED", "OnProfileChanged")
    
    -- Print a message that the integration is enabled
    if Phoenix_UI.debug then
        print("Phoenix UI: WeakAuras integration enabled")
    end
end

-- Hook into WeakAuras functions
function Module:HookWeakAuras()
    local WA = _G.WeakAuras
    if not WA then return end
    
    -- Store original functions to call later
    self.originalFunctions = {
        DisplayToRegion = WA.DisplayToRegion,
        Add = WA.Add,
        Delete = WA.Delete,
        OpenOptions = WA.OpenOptions
    }
    
    -- Hook DisplayToRegion to apply our theme
    WA.DisplayToRegion = function(...)
        local region = self.originalFunctions.DisplayToRegion(...)
        if region and Phoenix_UI.db.profile.weakauras.applyTheme then
            self:ApplyThemeToRegion(region)
        end
        return region
    end
    
    -- Hook Add function to monitor new auras
    WA.Add = function(...)
        local id = self.originalFunctions.Add(...)
        if id then
            self:OnAuraAdded(id)
        end
        return id
    end
    
    -- Hook Delete function to monitor deleted auras
    WA.Delete = function(...)
        local id = ...
        if id then
            self:OnAuraDeleted(id)
        end
        return self.originalFunctions.Delete(...)
    end
    
    -- Hook OpenOptions to potentially redirect to our UI
    WA.OpenOptions = function(...)
        if Phoenix_UI.db.profile.weakauras.usePhoenixPanel then
            self:OpenWeakAurasConfig(...)
        else
            return self.originalFunctions.OpenOptions(...)
        end
    end
    
    -- Apply performance optimizations if enabled
    if Phoenix_UI.db.profile.weakauras.performanceMode then
        self:ApplyPerformanceOptimizations()
    end
end

-- Apply theme to a WeakAuras region
function Module:ApplyThemeToRegion(region)
    if not region then return end
    
    local db = Phoenix_UI.db.profile.weakauras
    if not db or not db.applyTheme then return end
    
    -- Apply themed borders if enabled
    if db.themedBorders and region.type == "icon" then
        -- Apply themed borders to icons
        if region.icon then
            -- Apply border texture from Phoenix UI
            local borderTexture = Phoenix_UI.GetBorderTexture and Phoenix_UI:GetBorderTexture() or "Interface\\AddOns\\Phoenix_UI\\Media\\Textures\\Border"
            
            -- Create or get the border frame
            if not region.phoenixBorder then
                region.phoenixBorder = CreateFrame("Frame", nil, region)
                region.phoenixBorder:SetPoint("TOPLEFT", region, "TOPLEFT", -2, 2)
                region.phoenixBorder:SetPoint("BOTTOMRIGHT", region, "BOTTOMRIGHT", 2, -2)
                region.phoenixBorder:SetFrameLevel(region:GetFrameLevel() + 1)
                
                -- Create the border texture
                region.phoenixBorder.texture = region.phoenixBorder:CreateTexture(nil, "OVERLAY")
                region.phoenixBorder.texture:SetAllPoints()
                region.phoenixBorder.texture:SetTexture(borderTexture)
            end
            
            -- Update the border color based on Phoenix UI theme
            local themeColor = Phoenix_UI.GetThemeColor and Phoenix_UI:GetThemeColor() or {r=1, g=0.5, b=0, a=1}
            region.phoenixBorder.texture:SetVertexColor(themeColor.r, themeColor.g, themeColor.b, themeColor.a)
        end
    end
    
    -- Apply themed progress bars if enabled
    if db.themedBars and region.type == "aurabar" then
        -- Apply themed bar textures
        if region.bar then
            local barTexture = Phoenix_UI.GetBarTexture and Phoenix_UI:GetBarTexture() or "Interface\\AddOns\\Phoenix_UI\\Media\\Textures\\Smooth"
            region.bar:SetStatusBarTexture(barTexture)
            
            -- Apply theme colors
            if region.state and region.state.progressType == "timed" then
                local themeColor = Phoenix_UI.GetThemeColor and Phoenix_UI:GetThemeColor() or {r=1, g=0.5, b=0, a=1}
                region.bar:SetStatusBarColor(themeColor.r, themeColor.g, themeColor.b, themeColor.a)
            end
        end
    end
    
    -- Apply Phoenix UI fonts if enabled
    if db.useFonts and region.text then
        local fontFamily = Phoenix_UI.GetFontFamily and Phoenix_UI:GetFontFamily() or "Interface\\AddOns\\Phoenix_UI\\Media\\Fonts\\Expressway.ttf"
        local _, size, flags = region.text:GetFont()
        region.text:SetFont(fontFamily, size, flags)
    end
end

-- Apply performance optimizations
function Module:ApplyPerformanceOptimizations()
    local WA = _G.WeakAuras
    if not WA then return end
    
    local db = Phoenix_UI.db.profile.weakauras
    
    -- Create frame for FPS throttling if needed
    if not self.performanceFrame then
        self.performanceFrame = CreateFrame("Frame")
        self.performanceFrame.timeSinceLastUpdate = 0
        self.performanceFrame.inCombat = UnitAffectingCombat("player")
        self.performanceFrame.throttled = false
        
        -- Register combat events
        self.performanceFrame:RegisterEvent("PLAYER_REGEN_DISABLED")
        self.performanceFrame:RegisterEvent("PLAYER_REGEN_ENABLED")
        
        self.performanceFrame:SetScript("OnEvent", function(self, event)
            if event == "PLAYER_REGEN_DISABLED" then
                self.inCombat = true
            elseif event == "PLAYER_REGEN_ENABLED" then
                self.inCombat = false
                self.throttled = false
            end
        end)
        
        -- Set update script
        self.performanceFrame:SetScript("OnUpdate", function(self, elapsed)
            self.timeSinceLastUpdate = self.timeSinceLastUpdate + elapsed
            
            -- Check if we need to throttle WeakAuras updates
            if db.throttleDuringFPSDrops and not self.throttled then
                local fps = GetFramerate()
                if fps < db.fpsThreshold then
                    self.throttled = true
                    
                    -- Apply more aggressive throttling during low FPS
                    if Module.originalFunctions and Module.originalFunctions.DisplayToRegion then
                        local originalDisplayToRegion = Module.originalFunctions.DisplayToRegion
                        _G.WeakAuras.DisplayToRegion = function(...)
                            -- Only update every other frame during FPS drops
                            if self.updateFrame then
                                self.updateFrame = false
                                return originalDisplayToRegion(...)
                            end
                            self.updateFrame = true
                            return ...
                        end
                    end
                elseif self.throttled and fps > db.fpsThreshold + 5 then
                    -- Restore normal function when FPS recovers
                    self.throttled = false
                    if Module.originalFunctions and Module.originalFunctions.DisplayToRegion then
                        _G.WeakAuras.DisplayToRegion = Module.originalFunctions.DisplayToRegion
                    end
                end
            end
            
            -- Throttle updates in combat based on settings
            if self.inCombat and self.timeSinceLastUpdate > db.combatUpdateRate then
                self.timeSinceLastUpdate = 0
                
                -- Force a throttled update of all auras
                if WA.ScanEvents then
                    WA.ScanEvents("PHOENIX_UI_THROTTLED_UPDATE")
                end
            end
        end)
    end
end

-- Handle when an aura is added
function Module:OnAuraAdded(id)
    -- You can add custom logic here when a WeakAura is added
    if Phoenix_UI.debug then
        print("Phoenix UI: WeakAura added - " .. id)
    end
    
    -- Sync with other modules like BuffOverlay and CooldownTracker
    if Phoenix_UI.db.profile.weakauras.syncWithPhoenixUI then
        Phoenix_UI:SendMessage("PHOENIX_UI_WEAKAURA_ADDED", id)
    end
end

-- Handle when an aura is deleted
function Module:OnAuraDeleted(id)
    -- You can add custom logic here when a WeakAura is deleted
    if Phoenix_UI.debug then
        print("Phoenix UI: WeakAura deleted - " .. id)
    end
    
    -- Sync with other modules
    if Phoenix_UI.db.profile.weakauras.syncWithPhoenixUI then
        Phoenix_UI:SendMessage("PHOENIX_UI_WEAKAURA_DELETED", id)
    end
end

-- Open our custom WeakAuras config
function Module:OpenWeakAurasConfig(...)
    -- Open Phoenix UI config panel and navigate to WeakAuras tab
    if Phoenix_UI.OpenConfig then
        Phoenix_UI:OpenConfig("WeakAurasIntegration")
    end
end

-- Handle settings changes
function Module:OnSettingChanged(message, key, value)
    if key:match("^weakauras%.") then
        self:UpdateSettings()
    end
end

-- Handle profile changes
function Module:OnProfileChanged()
    self:UpdateSettings()
end

-- Update settings when they change
function Module:UpdateSettings()
    local db = Phoenix_UI.db.profile.weakauras
    
    -- Check if we need to enable/disable the module
    if db.enabled == false then
        self:Disable()
        return
    elseif not self:IsEnabled() then
        self:Enable()
    end
    
    -- Update performance settings
    if db.performanceMode then
        self:ApplyPerformanceOptimizations()
    end
    
    -- Re-hook WeakAuras if needed
    if not self.originalFunctions then
        self:HookWeakAuras()
    end
    
    -- Update all regions to apply theme changes
    if _G.WeakAuras and _G.WeakAuras.regions then
        for id, regions in pairs(_G.WeakAuras.regions) do
            for _, region in ipairs(regions) do
                self:ApplyThemeToRegion(region)
            end
        end
    end
    
    -- Update templates if settings changed
    if db.showTemplates then
        self:UpdateTemplates()
    end
end

-- Update WeakAuras templates
function Module:UpdateTemplates()
    local WA = _G.WeakAuras
    if not WA then return end
    
    local db = Phoenix_UI.db.profile.weakauras
    if not db.showTemplates then return end
    
    -- Create Phoenix UI template category if needed
    if not WA.templates then
        WA.templates = {}
    end
    
    -- Initialize our template category if it doesn't exist
    if not WA.templates["Phoenix UI"] then
        WA.templates["Phoenix UI"] = {
            title = "|cffFF7D0APhoenix|r|cffFF0000_|r|cffFFD100UI|r Templates",
            description = "Custom WeakAuras templates optimized for Phoenix UI",
            templates = {}
        }
    end
    
    -- Create our template collection
    local phoenixTemplates = {
        -- Class-specific templates
        ClassResources = {
            title = "Class Resources",
            description = "Enhanced display of class-specific resources with Phoenix UI theme",
            data = {
                -- Base template properties
                width = 64,
                height = 64,
                frameStrata = "HIGH",
                xOffset = 0,
                yOffset = 0,
                -- Phoenix UI specific styling will be applied via ApplyThemeToRegion
            }
        },
        
        -- Cooldown tracking templates
        CooldownTracker = {
            title = "Cooldown Tracker",
            description = "Track important spell cooldowns with Phoenix UI styling",
            data = {
                -- Base template properties
                width = 48,
                height = 48,
                frameStrata = "MEDIUM",
                cooldownTextEnabled = true,
                -- Phoenix UI specific styling will be applied via ApplyThemeToRegion
            }
        },
        
        -- Buff/Debuff tracking templates
        BuffTracker = {
            title = "Buff Tracker",
            description = "Track important buffs with Phoenix UI styling",
            data = {
                -- Base template properties
                width = 40,
                height = 40,
                frameStrata = "MEDIUM",
                -- Phoenix UI specific styling will be applied via ApplyThemeToRegion
            }
        },
        
        -- Combat notifications
        CombatAlerts = {
            title = "Combat Alerts",
            description = "Important combat notifications with Phoenix UI styling",
            data = {
                -- Base template properties
                width = 200,
                height = 80,
                frameStrata = "HIGH",
                -- Phoenix UI specific styling will be applied via ApplyThemeToRegion
            }
        }
    }
    
    -- Add templates to WeakAuras
    for id, template in pairs(phoenixTemplates) do
        -- Add Phoenix UI theme data to the template
        template.data.phoenixUIThemed = true
        
        -- Apply Phoenix UI color scheme
        local themeColor = Phoenix_UI.GetThemeColor and Phoenix_UI:GetThemeColor() or {r=1, g=0.5, b=0, a=1}
        template.data.color = {
            r = themeColor.r,
            g = themeColor.g,
            b = themeColor.b,
            a = themeColor.a
        }
        
        -- Set font to Phoenix UI font
        local fontFamily = Phoenix_UI.GetFontFamily and Phoenix_UI:GetFontFamily() or "Interface\\AddOns\\Phoenix_UI\\Media\\Fonts\\Expressway.ttf"
        template.data.font = fontFamily
        
        -- Add template to WeakAuras
        WA.templates["Phoenix UI"].templates[id] = template
    end
    
    -- Add template creation hook to ensure our theme is applied
    if not self.templateHooked and WA.CreateTemplateView then
        local originalCreateTemplateView = WA.CreateTemplateView
        WA.CreateTemplateView = function(...)
            local region = originalCreateTemplateView(...)
            if region and region.data and region.data.phoenixUIThemed then
                self:ApplyThemeToRegion(region)
            end
            return region
        end
        self.templateHooked = true
    end
    
    if Phoenix_UI.debug then
        print("Phoenix UI: WeakAuras templates updated successfully")
    end
end