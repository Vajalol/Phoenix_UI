---@class BuffOverlay: AceModule
-- Check if the addon is already registered by Phoenix_UI before creating a new instance
if not BuffOverlay then
    BuffOverlay = LibStub("AceAddon-3.0"):NewAddon("BuffOverlay", "AceConsole-3.0")
end

-- Ensure we have a frame for events if not using AceEvent
if not BuffOverlay.frame then
    BuffOverlay.frame = BuffOverlay.frame or CreateFrame("Frame", "BuffOverlayFrame")
end

-- Localization Table
BuffOverlay.L = BuffOverlay.L or {}

-- Make missing translations available
setmetatable(BuffOverlay.L, {__index = function(t, k)
    local v = tostring(k)
    rawset(t, k, v)
    return v
end})

-- Definitions
BuffOverlay.GetSpellInfo = function(spellID)
    if not spellID then
        return nil
    end

    -- Classic flavors still use old GetSpellInfo
    if GetSpellInfo then
        return GetSpellInfo(spellID)
    end

    local spellInfo = C_Spell.GetSpellInfo(spellID)
    if spellInfo then
        return spellInfo.name, nil, spellInfo.iconID, spellInfo.castTime, spellInfo.minRange, spellInfo.maxRange, spellInfo.spellID, spellInfo.originalIconID
    end
end

-- Add PvE enhancement integration with Phoenix_UI
BuffOverlay.EnhancePvESupport = function(self)
    -- Immediately suppress welcome message if we're part of Phoenix_UI
    if _G.Phoenix_UI and self.db and self.db.profile then
        self.db.profile.welcomeMessage = false
        
        -- Also ensure we don't show initialization messages
        self.db.profile.showInitMessages = false
        self.db.profile.seenWelcomeMessage = true
        self.showedInitMessage = true
        self.seenWelcomeMessage = true
    end
    
    -- This will be called after full initialization
    if self.OptimizePerformance then
        -- Apply performance optimizations
        self:OptimizePerformance()
    end
    
    -- Check for healer role and apply optimizations
    if self.CheckPlayerRole then
        self:CheckPlayerRole()
    end
    
    -- Optimize frame detection for healing addons
    if self.OptimizeHealingAddonDetection then
        self:OptimizeHealingAddonDetection()
    end
    
    -- Force refresh with new settings
    if self.RefreshOverlays then
        self:RefreshOverlays(true)
    end
    
    -- Apply Phoenix UI styling to the BuffOverlay panel
    self:ApplyPhoenixUIStyling()
end

-- Apply Phoenix UI styling to the BuffOverlay panel
BuffOverlay.ApplyPhoenixUIStyling = function(self)
    -- Check if needed libraries are available
    if not LibStub then return end
    
    -- Phoenix UI colors (orange flame colors)
    local phoenixColors = {
        orange = {r = 1, g = 0.49, b = 0.04},   -- Main Phoenix orange (#FF7D0A)
        gold = {r = 1, g = 0.82, b = 0},        -- Phoenix gold (#FFD100) 
        red = {r = 1, g = 0, b = 0},            -- Phoenix red accent (#FF0000)
        dark = {r = 0.1, g = 0.1, b = 0.1},     -- Dark background
        border = {r = 0.4, g = 0.4, b = 0.4},   -- Border color
        highlight = {r = 0.6, g = 0.6, b = 0.6} -- Highlight color
    }
    
    -- Get AceConfig and AceGUI libraries
    local AceConfigDialog = LibStub("AceConfigDialog-3.0", true)
    local AceGUI = LibStub("AceGUI-3.0", true)
    
    if not AceConfigDialog or not AceGUI then return end
    
    -- Hook AceGUI widget constructors to apply Phoenix UI styling
    
    -- Style the Tab Group widget (main container)
    local oldTabGroupConstructor = AceGUI.GetWidgetConstructor("TabGroup")
    if oldTabGroupConstructor then
        AceGUI:RegisterWidgetType("TabGroup", function(...)
            local widget = oldTabGroupConstructor(...)
            
            -- Style the border with Phoenix UI colors
            if widget.border then
                widget.border:SetBackdropColor(phoenixColors.dark.r, phoenixColors.dark.g, phoenixColors.dark.b, 0.8)
                widget.border:SetBackdropBorderColor(phoenixColors.border.r, phoenixColors.border.g, phoenixColors.border.b, 1)
            end
            
            -- Style the title text with Phoenix UI colors
            if widget.titletext then
                widget.titletext:SetTextColor(phoenixColors.orange.r, phoenixColors.orange.g, phoenixColors.orange.b)
                widget.titletext:SetFont(widget.titletext:GetFont(), 14, "OUTLINE")
            end
            
            -- Style the tabs
            if widget.tabs then
                for _, tab in pairs(widget.tabs) do
                    if tab.text then
                        tab.text:SetTextColor(phoenixColors.gold.r, phoenixColors.gold.g, phoenixColors.gold.b)
                    end
                    
                    -- Highlight selected tab with Phoenix orange
                    local oldSetSelected = tab.SetSelected
                    if oldSetSelected then
                        tab.SetSelected = function(self, selected)
                            oldSetSelected(self, selected)
                            if selected then
                                self.text:SetTextColor(phoenixColors.orange.r, phoenixColors.orange.g, phoenixColors.orange.b)
                            else
                                self.text:SetTextColor(phoenixColors.gold.r, phoenixColors.gold.g, phoenixColors.gold.b)
                            end
                        end
                    end
                end
            end
            
            return widget
        end, AceGUI:GetWidgetVersion("TabGroup"))
    end
    
    -- Style the Heading widget
    local oldHeadingConstructor = AceGUI.GetWidgetConstructor("Heading")
    if oldHeadingConstructor then
        AceGUI:RegisterWidgetType("Heading", function(...)
            local widget = oldHeadingConstructor(...)
            
            -- Style the heading text with Phoenix UI colors
            if widget.label then
                widget.label:SetTextColor(phoenixColors.orange.r, phoenixColors.orange.g, phoenixColors.orange.b)
                widget.label:SetFont(widget.label:GetFont(), 14, "OUTLINE")
            end
            
            return widget
        end, AceGUI:GetWidgetVersion("Heading"))
    end
    
    -- Style the Button widget
    local oldButtonConstructor = AceGUI.GetWidgetConstructor("Button")
    if oldButtonConstructor then
        AceGUI:RegisterWidgetType("Button", function(...)
            local widget = oldButtonConstructor(...)
            
            -- Add hover effect to buttons
            if widget.frame then
                widget.frame:SetScript("OnEnter", function(self)
                    if widget.text then
                        widget.text:SetTextColor(phoenixColors.orange.r, phoenixColors.orange.g, phoenixColors.orange.b)
                    end
                end)
                
                widget.frame:SetScript("OnLeave", function(self)
                    if widget.text then
                        widget.text:SetTextColor(1, 1, 1)
                    end
                end)
            end
            
            return widget
        end, AceGUI:GetWidgetVersion("Button"))
    end
    
    -- Style the Slider widget
    local oldSliderConstructor = AceGUI.GetWidgetConstructor("Slider")
    if oldSliderConstructor then
        AceGUI:RegisterWidgetType("Slider", function(...)
            local widget = oldSliderConstructor(...)
            
            -- Style the slider with Phoenix UI colors
            if widget.slider then
                -- Color the thumb texture
                local thumbTexture = widget.slider:GetThumbTexture()
                if thumbTexture then
                    thumbTexture:SetVertexColor(phoenixColors.orange.r, phoenixColors.orange.g, phoenixColors.orange.b)
                end
                
                -- Change text colors
                if widget.label then
                    widget.label:SetTextColor(phoenixColors.gold.r, phoenixColors.gold.g, phoenixColors.gold.b)
                end
                
                if widget.lowtext then
                    widget.lowtext:SetTextColor(phoenixColors.gold.r, phoenixColors.gold.g, phoenixColors.gold.b)
                end
                
                if widget.hightext then
                    widget.hightext:SetTextColor(phoenixColors.gold.r, phoenixColors.gold.g, phoenixColors.gold.b)
                end
                
                if widget.editbox then
                    widget.editbox:SetTextColor(phoenixColors.gold.r, phoenixColors.gold.g, phoenixColors.gold.b)
                end
            end
            
            return widget
        end, AceGUI:GetWidgetVersion("Slider"))
    end
    
    -- Style the CheckBox widget
    local oldCheckBoxConstructor = AceGUI.GetWidgetConstructor("CheckBox")
    if oldCheckBoxConstructor then
        AceGUI:RegisterWidgetType("CheckBox", function(...)
            local widget = oldCheckBoxConstructor(...)
            
            -- Style checkbox with Phoenix UI colors
            if widget.check then
                -- Color the text
                if widget.text then
                    widget.text:SetTextColor(phoenixColors.gold.r, phoenixColors.gold.g, phoenixColors.gold.b)
                end
                
                -- Apply custom checked/unchecked state colors
                local oldSetChecked = widget.check.SetChecked
                if oldSetChecked then
                    widget.check.SetChecked = function(self, checked)
                        oldSetChecked(self, checked)
                        if checked then
                            self:SetVertexColor(phoenixColors.orange.r, phoenixColors.orange.g, phoenixColors.orange.b)
                        else
                            self:SetVertexColor(1, 1, 1, 1)
                        end
                    end
                    
                    -- Apply initial color based on current state
                    if widget.check:GetChecked() then
                        widget.check:SetVertexColor(phoenixColors.orange.r, phoenixColors.orange.g, phoenixColors.orange.b)
                    else
                        widget.check:SetVertexColor(1, 1, 1, 1)
                    end
                end
            end
            
            return widget
        end, AceGUI:GetWidgetVersion("CheckBox"))
    end
    
    -- Style the EditBox widget
    local oldEditBoxConstructor = AceGUI.GetWidgetConstructor("EditBox")
    if oldEditBoxConstructor then
        AceGUI:RegisterWidgetType("EditBox", function(...)
            local widget = oldEditBoxConstructor(...)
            
            -- Style the edit box with Phoenix UI colors
            if widget.editbox then
                -- Set text color
                widget.editbox:SetTextColor(phoenixColors.gold.r, phoenixColors.gold.g, phoenixColors.gold.b)
                
                -- Set label color
                if widget.label then
                    widget.label:SetTextColor(phoenixColors.gold.r, phoenixColors.gold.g, phoenixColors.gold.b)
                end
                
                -- Apply Phoenix UI colors on focus
                widget.editbox:HookScript("OnEditFocusGained", function(self)
                    if widget.frame then
                        widget.frame:SetBackdropBorderColor(phoenixColors.orange.r, phoenixColors.orange.g, phoenixColors.orange.b, 1)
                    end
                end)
                
                widget.editbox:HookScript("OnEditFocusLost", function(self)
                    if widget.frame then
                        widget.frame:SetBackdropBorderColor(phoenixColors.border.r, phoenixColors.border.g, phoenixColors.border.b, 1)
                    end
                end)
            end
            
            return widget
        end, AceGUI:GetWidgetVersion("EditBox"))
    end
    
    -- Style the Dropdown widget
    local oldDropdownConstructor = AceGUI.GetWidgetConstructor("Dropdown")
    if oldDropdownConstructor then
        AceGUI:RegisterWidgetType("Dropdown", function(...)
            local widget = oldDropdownConstructor(...)
            
            -- Style the dropdown with Phoenix UI colors
            if widget.label then
                widget.label:SetTextColor(phoenixColors.gold.r, phoenixColors.gold.g, phoenixColors.gold.b)
            end
            
            if widget.text then
                widget.text:SetTextColor(phoenixColors.gold.r, phoenixColors.gold.g, phoenixColors.gold.b)
            end
            
            -- Add hover effect to dropdown
            if widget.frame then
                widget.frame:HookScript("OnEnter", function(self)
                    if widget.text then
                        widget.text:SetTextColor(phoenixColors.orange.r, phoenixColors.orange.g, phoenixColors.orange.b)
                    end
                end)
                
                widget.frame:HookScript("OnLeave", function(self)
                    if widget.text then
                        widget.text:SetTextColor(phoenixColors.gold.r, phoenixColors.gold.g, phoenixColors.gold.b)
                    end
                end)
            end
            
            return widget
        end, AceGUI:GetWidgetVersion("Dropdown"))
    end
    
    -- Register our opening function to apply additional styling
    local originalOpen = AceConfigDialog.Open
    AceConfigDialog.Open = function(self, appName, ...)
        if appName == "BuffOverlay" then
            -- Apply extra styling to the BuffOverlay panel
            C_Timer.After(0.1, function()
                -- Find the BuffOverlay frame
                for _, frame in pairs({UIParent:GetChildren()}) do
                    if frame.title and frame.title:GetText() == "BuffOverlay" then
                        -- Main frame styling
                        frame:SetBackdropColor(phoenixColors.dark.r, phoenixColors.dark.g, phoenixColors.dark.b, 0.9)
                        frame:SetBackdropBorderColor(phoenixColors.border.r, phoenixColors.border.g, phoenixColors.border.b, 1)
                        
                        -- Title styling
                        frame.title:SetTextColor(phoenixColors.orange.r, phoenixColors.orange.g, phoenixColors.orange.b)
                        frame.title:SetFont(frame.title:GetFont(), 16, "OUTLINE")
                        
                        -- Store frame reference for later
                        self.styledFrame = frame
                        
                        -- Add Phoenix UI logo/branding
                        if not frame.phoenixLogo then
                            local logo = frame:CreateTexture(nil, "OVERLAY")
                            logo:SetSize(24, 24)
                            logo:SetPoint("TOPRIGHT", frame, "TOPRIGHT", -5, -5)
                            logo:SetTexture("Interface\\AddOns\\Phoenix_UI\\Media\\Textures\\logo")
                            logo:SetVertexColor(phoenixColors.orange.r, phoenixColors.orange.g, phoenixColors.orange.b)
                            frame.phoenixLogo = logo
                        end
                        
                        -- Add glowing border animation
                        if not frame.glowAnimation then
                            local glow = frame:CreateTexture(nil, "BACKGROUND")
                            glow:SetPoint("TOPLEFT", frame, "TOPLEFT", -5, 5)
                            glow:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT", 5, -5)
                            glow:SetTexture("Interface\\AchievementFrame\\UI-Achievement-Alert-Glow")
                            glow:SetTexCoord(0, 0.78125, 0, 0.66796875)
                            glow:SetBlendMode("ADD")
                            glow:SetAlpha(0)
                            frame.glow = glow
                            
                            -- Create animation group
                            local animGroup = glow:CreateAnimationGroup()
                            animGroup:SetLooping("BOUNCE")
                            
                            local anim = animGroup:CreateAnimation("Alpha")
                            anim:SetFromAlpha(0)
                            anim:SetToAlpha(0.3)
                            anim:SetDuration(1.5)
                            anim:SetSmoothing("IN_OUT")
                            
                            animGroup:Play()
                            frame.glowAnimation = animGroup
                        end
                        
                        -- Style the close button
                        if frame.closebutton then
                            -- Change the X color to Phoenix orange
                            frame.closebutton:GetNormalTexture():SetVertexColor(
                                phoenixColors.orange.r, 
                                phoenixColors.orange.g, 
                                phoenixColors.orange.b
                            )
                            
                            -- Add hover effect
                            frame.closebutton:HookScript("OnEnter", function(self)
                                self:GetNormalTexture():SetVertexColor(
                                    phoenixColors.red.r, 
                                    phoenixColors.red.g, 
                                    phoenixColors.red.b
                                )
                            end)
                            
                            frame.closebutton:HookScript("OnLeave", function(self)
                                self:GetNormalTexture():SetVertexColor(
                                    phoenixColors.orange.r, 
                                    phoenixColors.orange.g, 
                                    phoenixColors.orange.b
                                )
                            end)
                        end
                        
                        break
                    end
                end
            end)
        end
        return originalOpen(self, appName, ...)
    end
end

-- Add easy access to BuffOverlay settings directly from Phoenix_UI
BuffOverlay.OpenConfigPanel = function(self)
    if self.configFrame and self.configFrame:IsShown() then
        self.configFrame:Hide()
        return
    end
    
    if LibStub and LibStub("AceConfigDialog-3.0", true) then
        LibStub("AceConfigDialog-3.0"):Open("BuffOverlay")
    elseif self.ShowConfig then
        self:ShowConfig()
    end
end

-- Hook into OnInitialize to call our enhancement function
local originalOnInitialize = BuffOverlay.OnInitialize
BuffOverlay.OnInitialize = function(self)
    -- Attempt early configuration to prevent welcome message
    self:EnhancePvESupport()
    
    -- Call original initialization
    if originalOnInitialize then
        originalOnInitialize(self)
    end
    
    -- Schedule our PvE enhancements to run after full initialization
    C_Timer.After(1, function()
        self:EnhancePvESupport()
    end)
end



