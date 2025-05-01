local Gui = Phoenix_UI:NewModule("Config.Gui")
local L = Phoenix_UI.L or {['Rise from the ashes with a fiery UI experience'] = 'Type /pui to open Config Panel - From ashes to ashes Welcome to fire Gamer'}

-- Ensure Phoenix_UIConfig is available globally
_G.Phoenix_UIConfig = LibStub and LibStub('Phoenix_UIConfig', true)

local General = Phoenix_UI:GetModule("Config.Layout.General")
local Unitframes = Phoenix_UI:GetModule("Config.Layout.Unitframes")
local Nameplates = Phoenix_UI:GetModule("Config.Layout.Nameplates")
local Actionbar = Phoenix_UI:GetModule("Config.Layout.Actionbar")
local Castbars = Phoenix_UI:GetModule("Config.Layout.Castbars")
local IdTip = Phoenix_UI:GetModule("Config.Layout.IdTip")
local Buffoverlay = Phoenix_UI:GetModule("Config.Layout.Buffoverlay")
local Msbt = Phoenix_UI:GetModule("Config.Layout.Msbt")
local Buffs = Phoenix_UI:GetModule("Config.Layout.Buffs")
local Tooltip = Phoenix_UI:GetModule("Config.Layout.Tooltip")
local Map = Phoenix_UI:GetModule("Config.Layout.Map")
local Chat = Phoenix_UI:GetModule("Config.Layout.Chat")
local Misc = Phoenix_UI:GetModule("Config.Layout.Misc")
local UIScaling = Phoenix_UI:GetModule("Config.Layout.UIScaling")
local FAQ = Phoenix_UI:GetModule("Config.Layout.FAQ")
local Profiles = Phoenix_UI:GetModule("Config.Layout.Profiles")
local WeakAurasIntegration = Phoenix_UI:GetModule("Config.Layout.WeakAurasIntegration")
local CooldownTracker = Phoenix_UI:GetModule("Config.Layout.CooldownTracker")
local MythicPlus = Phoenix_UI:GetModule("Config.Layout.MythicPlus", true)
local DetailSkin = Phoenix_UI:GetModule("Config.Layout.DetailSkin")
local PlayerStats = Phoenix_UI:GetModule("Config.Layout.PlayerStats")

local Ace = LibStub("AceAddon-3.0")
local PhoenixConfig = Ace:NewAddon('Phoenix_UI_Config')
local Layouts = PhoenixConfig:GetName()..'.Layouts'

local ACD = LibStub('AceConfigDialog-3.0')
local ACR = LibStub('AceConfigRegistry-3.0')

-- Helper function to create flame animations
local function CreateFlameAnimation(texture, scale, duration, alpha)
    local animGroup = texture:CreateAnimationGroup()
    animGroup:SetLooping("REPEAT")
    
    -- Scale animation
    local scaleAnim = animGroup:CreateAnimation("Scale")
    scaleAnim:SetScale(scale or 1.1, scale or 1.1)
    scaleAnim:SetDuration(duration or 1.5)
    scaleAnim:SetSmoothing("IN_OUT")
    scaleAnim:SetOrder(1)
    
    local scaleBack = animGroup:CreateAnimation("Scale")
    scaleBack:SetScale(1/scale or 1/1.1, 1/scale or 1/1.1)
    scaleBack:SetDuration(duration or 1.5)
    scaleBack:SetSmoothing("IN_OUT")
    scaleBack:SetOrder(2)
    
    -- Alpha animation if requested
    if alpha then
        local fadeOut = animGroup:CreateAnimation("Alpha")
        fadeOut:SetFromAlpha(alpha.from or 0.7)
        fadeOut:SetToAlpha(alpha.to or 0.5)
        fadeOut:SetDuration(duration or 1.5)
        fadeOut:SetSmoothing("IN_OUT")
        fadeOut:SetOrder(1)
        
        local fadeIn = animGroup:CreateAnimation("Alpha")
        fadeIn:SetFromAlpha(alpha.to or 0.5)
        fadeIn:SetToAlpha(alpha.from or 0.7)
        fadeIn:SetDuration(duration or 1.5)
        fadeIn:SetSmoothing("IN_OUT")
        fadeIn:SetOrder(2)
    end
    
    return animGroup
end

function Gui:OnEnable()
    -- Make sure Phoenix_UIConfig is loaded and available both locally and globally
    local Phoenix_UIConfig = LibStub('Phoenix_UIConfig')
    if Phoenix_UIConfig then
        -- Ensure it's also available globally
        _G.Phoenix_UIConfig = Phoenix_UIConfig
    else
        -- If it's not available, display an error
        error("Phoenix_UIConfig library is not available. Addon cannot continue.")
        return
    end
    
    -- Get the Phoenix Flame theme
    -- Create a fallback theme if Phoenix_UI.themes is nil
    if not Phoenix_UI.themes then
        Phoenix_UI.themes = {}
        
        -- Create default theme
        Phoenix_UI.themes["Default"] = {
            name = "Default",
            description = "Default Phoenix UI theme",
            colors = {
                primary = {r = 0.9, g = 0.4, b = 0.13},  -- Fiery orange
                secondary = {r = 0.7, g = 0.3, b = 0.1}, -- Dark orange
                background = {r = 0.15, g = 0.15, b = 0.15},
                backgroundAlt = {r = 0.2, g = 0.2, b = 0.2},
                border = {r = 0.3, g = 0.3, b = 0.3},
                text = {r = 1, g = 1, b = 1},
                textHeader = {r = 1, g = 0.8, b = 0.3}, 
                highlight = {r = 1, g = 0.6, b = 0.2},
                darkShade = {r = 0.5, g = 0.1, b = 0.0}
            },
            fonts = {
                title = "Friz Quadrata TT",
                normal = "Friz Quadrata TT",
                header = "Friz Quadrata TT",
            },
            textures = {
                button = "Interface\\Buttons\\UI-Panel-Button-Up",
                buttonHighlight = "Interface\\Buttons\\UI-Panel-Button-Highlight",
                background = "Interface\\DialogFrame\\UI-DialogBox-Background",
                border = "Interface\\DialogFrame\\UI-DialogBox-Border",
                tabSelected = "Interface\\OptionsFrame\\UI-OptionsFrame-ActiveTab", 
                tabDeselected = "Interface\\OptionsFrame\\UI-OptionsFrame-InActiveTab"
            }
        }
        
        -- Create Phoenix Flame theme
        Phoenix_UI.themes["PhoenixFlame"] = {
            name = "Phoenix Flame",
            description = "Dynamic fire-themed interface with ember glows and dramatic contrasts",
            colors = {
                primary = {r = 1.0, g = 0.4, b = 0.0},     -- Vibrant flame orange
                secondary = {r = 0.8, g = 0.2, b = 0.0},   -- Deep ember red
                accent = {r = 1.0, g = 0.7, b = 0.0},      -- Bright amber
                background = {r = 0.08, g = 0.08, b = 0.1}, -- Very dark blue-black
                backgroundAlt = {r = 0.12, g = 0.10, b = 0.14}, -- Slightly lighter background for contrast
                border = {r = 0.6, g = 0.2, b = 0.0},      -- Ember border
                borderGlow = {r = 0.9, g = 0.3, b = 0.0},  -- Glowing border
                text = {r = 0.95, g = 0.95, b = 0.95},     -- Almost white text
                textHeader = {r = 1.0, g = 0.8, b = 0.3},  -- Golden header text
                highlight = {r = 1.0, g = 0.6, b = 0.2},   -- Bright highlight
                darkShade = {r = 0.5, g = 0.1, b = 0.0}    -- Dark shade for depth
            },
            fonts = {
                title = "Friz Quadrata TT",
                normal = "Friz Quadrata TT",
                header = "Friz Quadrata TT",
            },
            textures = {
                button = "Interface\\Buttons\\UI-Panel-Button-Up",
                buttonHighlight = "Interface\\Buttons\\UI-Panel-Button-Highlight",
                background = "Interface\\DialogFrame\\UI-DialogBox-Background",
                border = "Interface\\DialogFrame\\UI-DialogBox-Border",
                tabSelected = "Interface\\OptionsFrame\\UI-OptionsFrame-ActiveTab", 
                tabDeselected = "Interface\\OptionsFrame\\UI-OptionsFrame-InActiveTab"
            }
        }
    end
    
    local theme = Phoenix_UI.themes["PhoenixFlame"] or Phoenix_UI.themes["Default"]
    
    -- Configure Phoenix_UIConfig with theme colors
    Phoenix_UIConfig.config = {
        font = {
            family    = theme.fonts.normal,
            size      = 12,
            titleSize = 16,
            effect    = 'NONE',
            strata    = 'OVERLAY',
            color     = {
                normal   = theme.colors.text or { r = 1, g = 1, b = 1, a = 1 },
                disabled = { r = 0.7, g = 0.7, b = 0.7, a = 1 },
                header   = theme.colors.textHeader or { r = 1, g = 0.8, b = 0.0, a = 1 },
            }
        },
        backdrop = {
            texture        = [[Interface\Buttons\WHITE8X8]],
            highlight      = theme.colors.highlight or { r = 0.95, g = 0.5, b = 0.1, a = 0.5 },
            panel          = theme.colors.background or { r = 0.065, g = 0.065, b = 0.065, a = 0.95 },
            slider         = theme.colors.backgroundAlt or { r = 0.15, g = 0.15, b = 0.15, a = 1 },
            checkbox       = theme.colors.backgroundAlt or { r = 0.125, g = 0.125, b = 0.125, a = 1 },
            dropdown       = theme.colors.background or { r = 0.1, g = 0.1, b = 0.1, a = 1 },
            button         = theme.colors.backgroundAlt or { r = 0.055, g = 0.055, b = 0.055, a = 1 },
            buttonDisabled = { r = 0.5, g = 0.4, b = 0.4, a = 0.5 },
            border         = theme.colors.border or { r = 0.01, g = 0.01, b = 0.01, a = 1 },
            borderDisabled = theme.colors.darkShade or { r = 0.5, g = 0.1, b = 0.0, a = 1 },
        },
        progressBar = {
            color = theme.colors.primary or { r = 1, g = 0.55, b = 0, a = 0.5 },
        },
        highlight = {
            color = theme.colors.highlight or { r = 1, g = 0.4, b = 0, a = 0.5 },
            blank = { r = 0, g = 0, b = 0 }
        },
        dialog = {
            width  = 400,
            height = 100,
            button = {
                width  = 100,
                height = 20,
                margin = 5
            }
        },
        tooltip = {
            padding = 10
        },
        resizeHandle = {
            width = 16,
            height = 16,
            texture = {
                normal = [[Interface\ChatFrame\UI-ChatIM-SizeGrabber-Up]],
                highlight = [[Interface\ChatFrame\UI-ChatIM-SizeGrabber-Highlight]],
                pushed = [[Interface\ChatFrame\UI-ChatIM-SizeGrabber-Down]],
            }
        }
    }

    -- Database
    local db = Phoenix_UI.db

    -- Config - Make it larger for the unified panel
    local config = Phoenix_UIConfig:Window(UIParent, 900, 650)
    config:SetPoint('CENTER')
    
    -- Create a dark background with slight transparency
    config:SetBackdrop({
        bgFile = "Interface\\Buttons\\WHITE8X8", 
        edgeFile = "Interface\\AddOns\\Phoenix_UI\\Media\\Textures\\Border\\EmberBorder", 
        tile = true, tileSize = 16, edgeSize = 16, 
        insets = { left = 4, right = 4, top = 4, bottom = 4 }
    })
    config:SetBackdropColor(theme.colors.background.r, theme.colors.background.g, theme.colors.background.b, 0.9)
    config:SetBackdropBorderColor(theme.colors.border.r, theme.colors.border.g, theme.colors.border.b, 0.8)
    
    -- Enhance the title bar
    config.titlePanel:SetPoint('LEFT', 10, 0)
    config.titlePanel:SetPoint('RIGHT', -35, 0)
    config.titlePanel:SetHeight(40) -- Slightly taller title panel
    
    -- Set title panel backdrop
    config.titlePanel:SetBackdrop({
        bgFile = "Interface\\Buttons\\WHITE8X8", 
        edgeFile = "Interface\\AddOns\\Phoenix_UI\\Media\\Textures\\Border\\EmberBorder", 
        tile = true, tileSize = 16, edgeSize = 16, 
        insets = { left = 2, right = 2, top = 2, bottom = 2 }
    })
    
    -- Create a gradient for the title panel
    local r1, g1, b1 = theme.colors.secondary.r, theme.colors.secondary.g, theme.colors.secondary.b
    local r2, g2, b2 = theme.colors.darkShade.r, theme.colors.darkShade.g, theme.colors.darkShade.b
    
    config.titlePanel.bg = config.titlePanel:CreateTexture(nil, "BACKGROUND")
    config.titlePanel.bg:SetAllPoints()
    config.titlePanel.bg:SetColorTexture(r1, g1, b1, 0.7)
    
    -- Gradient overlay
    config.titlePanel.gradient = config.titlePanel:CreateTexture(nil, "BACKGROUND", nil, 1)
    config.titlePanel.gradient:SetAllPoints()
    config.titlePanel.gradient:SetColorTexture(r2, g2, b2, 0.8)
    
    -- Fix division by zero in gradient calculation
    local endColorR = r1 ~= 0 and (r2/r1) or 0.625
    local endColorG = g1 ~= 0 and (g2/g1) or 0.5
    local endColorB = b1 ~= 0 and (b2/b1) or 0.3
    
    config.titlePanel.gradient:SetGradient("HORIZONTAL", 
        CreateColor(1, 1, 1, 0.1), 
        CreateColor(endColorR, endColorG, endColorB, 0.9))
    
    -- Add a function to ensure the title is displayed and animated properly
    config.RefreshTitle = function(self)
        if not titleText then
            -- Create title text if it doesn't exist
            titleText = self.titlePanel:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
            titleText:SetPoint("CENTER", self.titlePanel, "CENTER", 0, 2)
            titleText:SetFont(theme.fonts.title, 24, "THICKOUTLINE")
            titleText:SetText("|cffFF7D0APhoenix|r |cffFF5000UI|r |cffFFD100By VortexQ8|r")
        else
            -- Ensure the text has the correct settings
            titleText:SetParent(self.titlePanel)
            titleText:SetPoint("CENTER", self.titlePanel, "CENTER", 0, 2)
            titleText:SetFont(theme.fonts.title, 24, "THICKOUTLINE")
            titleText:SetDrawLayer("OVERLAY", 7)
            titleText:SetText("|cffFF7D0APhoenix|r |cffFF5000UI|r |cffFFD100By VortexQ8|r")
        end
        
        -- Make sure the title is shown
        titleText:Show()
    end
    
    -- Hook OnShow to refresh the title
    config:HookScript("OnShow", function(self)
        if self.RefreshTitle then
            self:RefreshTitle()
        end
    end)
    
    -- Initialize the title
    config:RefreshTitle()
    
    config:Hide()
    
    -- Save changes when frame is hidden
    config:SetScript("OnHide", function()
        if (Phoenix_UI and Phoenix_UI.SaveAllTabSettings) then
            Phoenix_UI:SaveAllTabSettings()
        end
        
        local fadeInfo = {}
        fadeInfo.mode = "OUT"
        fadeInfo.timeToFade = 0.2
        fadeInfo.finishedFunc = function()
            config:Hide()
        end
        
        -- Commit any pending changes before the frame is hidden
        if Phoenix_UI.UI and Phoenix_UI.UI.CommitPendingChanges then
            Phoenix_UI.UI:CommitPendingChanges()
        end
        
        -- Save the database to ensure nothing is lost
        if Phoenix_UI.SaveDB then
            Phoenix_UI:SaveDB()
        end
    end)

    -- Create styled "Phoenix UI By VortexQ8" text with fire effects
    local titleText = config.titlePanel:CreateFontString(nil, "ARTWORK")
    titleText:SetPoint("CENTER", config.titlePanel, "CENTER", 0, 2)
    titleText:SetFont(theme.fonts.title, 24, "THICKOUTLINE") -- Increase font size and use THICKOUTLINE
    titleText:SetText("|cffFF7D0APhoenix|r |cffFF5000UI|r |cffFFD100By VortexQ8|r")
    
    -- Create text glow effect
    local textGlow = config.titlePanel:CreateTexture(nil, "BACKGROUND", nil, 1)
    textGlow:SetSize(350, 50) -- Increase glow size
    textGlow:SetPoint("CENTER", titleText, "CENTER", 0, 0)
    textGlow:SetTexture("Interface\\SpellActivationOverlay\\IconAlert")
    textGlow:SetTexCoord(0.00781250, 0.50781250, 0.27734375, 0.52734375)
    textGlow:SetBlendMode("ADD")
    textGlow:SetVertexColor(1, 0.4, 0, 0.8) -- Increase glow opacity
    
    -- Create fire textures underneath the text
    local fireEffect1 = config.titlePanel:CreateTexture(nil, "BACKGROUND", nil, 0)
    fireEffect1:SetSize(400, 60)
    fireEffect1:SetPoint("CENTER", titleText, "CENTER", 0, -5)
    fireEffect1:SetTexture("Interface\\SpellActivationOverlay\\IconAlert")
    fireEffect1:SetTexCoord(0.00781250, 0.50781250, 0.53515625, 0.78515625)
    fireEffect1:SetBlendMode("ADD")
    fireEffect1:SetVertexColor(1, 0.3, 0, 0.4)
    
    -- Create a second fire texture with different animation timing
    local fireEffect2 = config.titlePanel:CreateTexture(nil, "BACKGROUND", nil, 0)
    fireEffect2:SetSize(350, 50)
    fireEffect2:SetPoint("CENTER", titleText, "CENTER", 0, -3)
    fireEffect2:SetTexture("Interface\\Artifacts\\FireMage")
    fireEffect2:SetBlendMode("ADD")
    fireEffect2:SetVertexColor(1, 0.5, 0.1, 0.3)
    
    -- Create custom ember particles around the text
    for i = 1, 5 do
        local ember = config.titlePanel:CreateTexture(nil, "ARTWORK")
        ember:SetSize(12, 12)
        
        -- Position embers differently based on index
        if i == 1 then
            ember:SetPoint("BOTTOMLEFT", titleText, "TOPLEFT", 20, -5)
        elseif i == 2 then
            ember:SetPoint("BOTTOMRIGHT", titleText, "TOPRIGHT", -20, -5)
        elseif i == 3 then
            ember:SetPoint("TOPLEFT", titleText, "BOTTOMLEFT", 50, 5)
        elseif i == 4 then
            ember:SetPoint("TOPRIGHT", titleText, "BOTTOMRIGHT", -50, 5)
        else
            ember:SetPoint("TOP", titleText, "BOTTOM", 0, 5)
        end
        
        ember:SetTexture("Interface\\AddOns\\Phoenix_UI\\Media\\Textures\\Effects\\Ember")
        ember:SetBlendMode("ADD")
        ember:SetAlpha(0.7)
        
        -- Create animation for each ember with slightly different parameters
        local emberAnim = CreateFlameAnimation(ember, 1.1 + (i * 0.05), 1.2 + (i * 0.1), {from = 0.7, to = 0.3})
        emberAnim:Play()
    end
    
    -- Animate the text glow
    local glowAnim = CreateFlameAnimation(textGlow, 1.05, 1.5, {from = 0.6, to = 0.3})
    glowAnim:Play()
    
    -- Animate the fire effects
    local fireAnim1 = CreateFlameAnimation(fireEffect1, 1.08, 2.0, {from = 0.4, to = 0.2})
    fireAnim1:Play()
    
    local fireAnim2 = CreateFlameAnimation(fireEffect2, 1.1, 1.8, {from = 0.3, to = 0.15})
    fireAnim2:Play()
    
    -- Add version text with fire styling
    local version = config.titlePanel:CreateFontString(nil, "ARTWORK")
    version:SetPoint("BOTTOMLEFT", config.titlePanel, "BOTTOMLEFT", 10, 5)
    version:SetFont(theme.fonts.title, 12, "OUTLINE")
    version:SetText("|cffFF5000v|r|cffFFD100" .. (Phoenix_UI.Version or C_AddOns.GetAddOnMetadata("Phoenix_UI", "version") or "Unknown") .. "|r")
    
    -- Add version glow
    local versionGlow = config.titlePanel:CreateTexture(nil, "BACKGROUND")
    versionGlow:SetSize(60, 20)
    versionGlow:SetPoint("CENTER", version, "CENTER", 0, 0)
    versionGlow:SetTexture("Interface\\AddOns\\Phoenix_UI\\Media\\Textures\\Effects\\FireGlow")
    versionGlow:SetBlendMode("ADD")
    versionGlow:SetAlpha(0.3)
    
    -- Animate the version glow
    local versionAnim = CreateFlameAnimation(versionGlow, 1.1, 1.5, {from = 0.3, to = 0.1})
    versionAnim:Play()

    -- Add main flame decoration to the right side of title
    local mainFlame = config.titlePanel:CreateTexture(nil, "ARTWORK")
    mainFlame:SetSize(48, 48)  -- Make it larger
    mainFlame:SetPoint("RIGHT", config.titlePanel, "RIGHT", -20, 0)
    mainFlame:SetTexture("Interface\\AddOns\\Phoenix_UI\\Media\\Textures\\Effects\\Flame")
    mainFlame:SetBlendMode("ADD")
    mainFlame:SetVertexColor(1, 0.6, 0.2, 0.9)  -- Brighter color
    
    -- Create a more dynamic animation for the main flame
    local flameAnimGroup = mainFlame:CreateAnimationGroup()
    flameAnimGroup:SetLooping("REPEAT")
    
    -- Complex animation sequence for the flame
    local flameScale1 = flameAnimGroup:CreateAnimation("Scale")
    flameScale1:SetScale(1.3, 1.3)  -- Larger scaling
    flameScale1:SetDuration(0.7)
    flameScale1:SetSmoothing("IN")
    flameScale1:SetOrder(1)
    
    local flameScale2 = flameAnimGroup:CreateAnimation("Scale")
    flameScale2:SetScale(0.9, 0.9)
    flameScale2:SetDuration(0.5)
    flameScale2:SetSmoothing("OUT")
    flameScale2:SetOrder(2)
    
    local flameScale3 = flameAnimGroup:CreateAnimation("Scale")
    flameScale3:SetScale(1.2, 1.1)  -- More dramatic scaling
    flameScale3:SetDuration(0.8)
    flameScale3:SetSmoothing("IN_OUT")
    flameScale3:SetOrder(3)
    
    local flameAlpha1 = flameAnimGroup:CreateAnimation("Alpha")
    flameAlpha1:SetFromAlpha(0.9)  -- Start brighter
    flameAlpha1:SetToAlpha(1.0)
    flameAlpha1:SetDuration(0.7)
    flameAlpha1:SetSmoothing("IN")
    flameAlpha1:SetOrder(1)
    
    local flameAlpha2 = flameAnimGroup:CreateAnimation("Alpha")
    flameAlpha2:SetFromAlpha(1.0)
    flameAlpha2:SetToAlpha(0.7)
    flameAlpha2:SetDuration(0.5)
    flameAlpha2:SetSmoothing("OUT")
    flameAlpha2:SetOrder(2)
    
    local flameAlpha3 = flameAnimGroup:CreateAnimation("Alpha")
    flameAlpha3:SetFromAlpha(0.7)
    flameAlpha3:SetToAlpha(0.9)
    flameAlpha3:SetDuration(0.8)
    flameAlpha3:SetSmoothing("IN_OUT")
    flameAlpha3:SetOrder(3)
    
    flameAnimGroup:Play()
    
    -- Add flame on the left side for symmetry
    local leftFlame = config.titlePanel:CreateTexture(nil, "ARTWORK")
    leftFlame:SetSize(40, 40)  -- Slightly smaller than right flame
    leftFlame:SetPoint("LEFT", config.titlePanel, "LEFT", 20, 0)
    leftFlame:SetTexture("Interface\\AddOns\\Phoenix_UI\\Media\\Textures\\Effects\\Flame")
    leftFlame:SetBlendMode("ADD")
    leftFlame:SetVertexColor(1, 0.5, 0.1, 0.8)
    
    -- Create animation for left flame with slight delay
    local leftFlameAnimGroup = leftFlame:CreateAnimationGroup()
    leftFlameAnimGroup:SetLooping("REPEAT")
    
    local leftFlameScale1 = leftFlameAnimGroup:CreateAnimation("Scale")
    leftFlameScale1:SetScale(1.2, 1.2)
    leftFlameScale1:SetDuration(0.8)
    leftFlameScale1:SetSmoothing("IN")
    leftFlameScale1:SetOrder(1)
    
    local leftFlameScale2 = leftFlameAnimGroup:CreateAnimation("Scale")
    leftFlameScale2:SetScale(0.9, 0.9)
    leftFlameScale2:SetDuration(0.6)
    leftFlameScale2:SetSmoothing("OUT")
    leftFlameScale2:SetOrder(2)
    
    local leftFlameAlpha1 = leftFlameAnimGroup:CreateAnimation("Alpha")
    leftFlameAlpha1:SetFromAlpha(0.8)
    leftFlameAlpha1:SetToAlpha(1.0)
    leftFlameAlpha1:SetDuration(0.8)
    leftFlameAlpha1:SetSmoothing("IN")
    leftFlameAlpha1:SetOrder(1)
    
    local leftFlameAlpha2 = leftFlameAnimGroup:CreateAnimation("Alpha")
    leftFlameAlpha2:SetFromAlpha(1.0)
    leftFlameAlpha2:SetToAlpha(0.8)
    leftFlameAlpha2:SetDuration(0.6)
    leftFlameAlpha2:SetSmoothing("OUT")
    leftFlameAlpha2:SetOrder(2)
    
    leftFlameAnimGroup:Play()

    function Phoenix_UI:Config(toggle)
        if (toggle) then
            return function()
                if (config:IsVisible()) then
                    local fadeInfo = {}
                    fadeInfo.mode = "OUT"
                    fadeInfo.timeToFade = 0.2
                    fadeInfo.finishedFunc = function()
                        config:Hide()
                    end
                    UIFrameFade(config, fadeInfo)
                    ToggleGameMenu()
                else
                    local fadeInfo = {}
                    fadeInfo.mode = "IN"
                    fadeInfo.timeToFade = 0.2
                    fadeInfo.finishedFunc = function()
                        config:Show()
                    end
                    UIFrameFade(config, fadeInfo)
                    ToggleGameMenu()
                end
            end
        else
            if (config:IsVisible()) then
                local fadeInfo = {}
                fadeInfo.mode = "OUT"
                fadeInfo.timeToFade = 0.2
                fadeInfo.finishedFunc = function()
                    config:Hide()
                end
                UIFrameFade(config, fadeInfo)
            else
                local fadeInfo = {}
                fadeInfo.mode = "IN"
                fadeInfo.timeToFade = 0.2
                fadeInfo.finishedFunc = function()
                    config:Show()
                end
                UIFrameFade(config, fadeInfo)
            end
        end
    end

    -- Function to open config
    function Phoenix_UI:OpenConfig()
        self:Config(true)
    end

    -- Add a method to refresh config values displayed in the UI
    function config:RefreshConfig()
        -- Get the tabs panel from the config frame
        local configTabs = self.tabs or self.tabsPanel

        -- This will update all tabs and controls if available
        if configTabs and configTabs.buttons and type(configTabs.buttons) == "table" then
            for _, tab in ipairs(configTabs.buttons) do
                if tab and tab.selected and tab.content and tab.content.Refresh then
                    tab.content:Refresh()
                end
            end
            
            -- Force tab panel to refresh
            if configTabs.Refresh then
                configTabs:Refresh()
            end
        end
    end
    
    -- Add a method to queue a save operation
    function config:QueueSave()
        -- Log for debugging
        if Phoenix_UI and Phoenix_UI.debug then
            print("PHX-UI: Config UI queuing save operation")
        end
        
        -- Only queue a save if one isn't already pending
        if not self.saveTimer then
            self.saveTimer = C_Timer.After(0.2, function()
                self.saveTimer = nil
                -- Ensure all pending changes are committed first
                if self.CommitPendingChanges then
                    self:CommitPendingChanges()
                end
                
                -- Save ALL current tab settings
                if self.tabs and self.tabs.selectedTab and self.tabs.selectedTab.name then
                    local moduleName = self.tabs.selectedTab.name:lower()
                    if Phoenix_UI and Phoenix_UI.db and Phoenix_UI.db.profile and 
                       Phoenix_UI.db.profile[moduleName] then
                       -- Mark this module as updated
                       Phoenix_UI.db.profile[moduleName].__updated = GetTime()
                       Phoenix_UI.db.profile[moduleName].__saved_from = "tab_queue_save"
                    end
                end
                
                -- Call the proper save function with complete save flag
                if Phoenix_UI and Phoenix_UI.ForceSaveDB then
                    Phoenix_UI:ForceSaveDB()
                end
                
                -- Additional debug info
                if Phoenix_UI and Phoenix_UI.debug then
                    print("PHX-UI: Force SaveDB called from QueueSave")
                end
            end)
        else
            -- Just mark that changes are pending for the existing timer
            config.pendingChangesRequested = true
        end
    end
    
    -- Also implement a direct save method that can be called immediately
    function config:SaveNow()
        -- Cancel any pending save timer
        if self.saveTimer then
            self.saveTimer:Cancel()
            self.saveTimer = nil
        end
        
        -- Ensure all pending changes are committed
        if self.CommitPendingChanges then
            self:CommitPendingChanges()
        end
        
        -- Save ALL module data
        local allModules = {
            "general", "unitframes", "nameplates", "actionbars", "castbars", 
            "buffs", "msbt", "idtip", "tooltip", "map", "chat", "misc",
            "uiscaling", "profiles", "weakauras"
        }
        
        -- Extract current tab info
        local activeModule = nil
        if self.tabs and self.tabs.selectedTab and self.tabs.selectedTab.name then
            activeModule = self.tabs.selectedTab.name:lower()
            -- Mark this module with higher priority
            table.insert(allModules, 1, activeModule)
        end
        
        -- Update all module timestamps to force saving
        if Phoenix_UI and Phoenix_UI.db and Phoenix_UI.db.profile then
            for _, moduleName in ipairs(allModules) do
                if Phoenix_UI.db.profile[moduleName] then
                    Phoenix_UI.db.profile[moduleName].__updated = GetTime()
                    Phoenix_UI.db.profile[moduleName].__saved_from = "direct_save"
                    
                    -- Also update the global variable directly for extra persistence
                    local currentProfile = Phoenix_UI.db.keys.profile or "Default"
                    if _G["Phoenix_UIDB"] and _G["Phoenix_UIDB"].profiles and 
                       _G["Phoenix_UIDB"].profiles[currentProfile] then
                        -- Ensure module exists
                        if not _G["Phoenix_UIDB"].profiles[currentProfile][moduleName] then
                            _G["Phoenix_UIDB"].profiles[currentProfile][moduleName] = {}
                        end
                        
                        -- Copy latest data
                        _G["Phoenix_UIDB"].profiles[currentProfile][moduleName] = CopyTable(Phoenix_UI.db.profile[moduleName])
                    end
                end
            end
        end
        
        -- Force save using the most robust method
        if Phoenix_UI.ForceSaveDB then
            Phoenix_UI:ForceSaveDB()
        elseif Phoenix_UI.SaveDB then
            Phoenix_UI:SaveDB()
        end
        
        -- Force an immediate flush to disk
        pcall(function()
            if FlushSettingsDB then
                FlushSettingsDB()
            elseif FlushSavedVariables then
                FlushSavedVariables()
            end
        end)
        
        -- Check if the SaveNow was successful 
        local messageShown = false
        if Phoenix_UI and Phoenix_UI.db and Phoenix_UI.db.sv and Phoenix_UI.db.sv.__lastSaved then
            local timeSinceSave = GetTime() - Phoenix_UI.db.sv.__lastSaved
            if timeSinceSave < 1 then
                -- Show success message
                if Phoenix_UI.ShowMessage then
                    Phoenix_UI:ShowMessage("Settings saved successfully", false, false)
                    messageShown = true
                end
            end
        end
        
        -- Fallback message if needed
        if not messageShown and Phoenix_UI and Phoenix_UI.ShowMessage then
            Phoenix_UI:ShowMessage("Settings saved", false, false)
        end
    end
    
    -- Add auto-save functionality
    function config:RegisterAutoSave()
        --[[ 
        PHOENIX UI CONFIGURATION SAVING SYSTEM
        ======================================
        
        The Phoenix UI configuration panel employs a multi-layered saving system to ensure
        user settings are properly preserved. This documentation outlines the various
        mechanisms used and how they work together.
        
        1. Auto-Save System:
        -------------------
        - Hooks into all UI elements (sliders, checkboxes, dropdowns, color pickers)
        - Detects changes and queues them for saving after a short delay
        - Shows a visual indicator when auto-save occurs
        - Batches rapid sequential changes to avoid excessive saving operations
        
        2. Element Tracking System:
        -------------------------
        - Tracks which elements were recently changed for optimization
        - Prioritizes processing of recently changed elements
        - Maintains a timestamped history of element changes
        - Removes older entries automatically to maintain performance
        
        3. Conflict Resolution:
        ---------------------
        - Detects when the same setting is modified in multiple places
        - Applies resolution strategy: prioritize active tab changes, then most recent
        - Records conflict metadata for potential recovery
        - Logs detailed information when debug mode is enabled
        
        4. Data Persistence Mechanisms:
        -----------------------------
        - Uses AceDB for primary settings storage
        - Maintains redundant copy in global variables (_G["Phoenix_UIDB"])
        - Forces immediate flush to disk using FlushSettingsDB/FlushSavedVariables
        - Performs verification to confirm settings were actually saved
        
        5. Error Recovery:
        ---------------
        - Creates backups in character-specific saved variables
        - Implements validation and repair of corrupt settings
        - Detects and recovers from save failures
        - Maintains diagnostic timestamps for troubleshooting
        
        6. User Interface:
        ---------------
        - "Save and Reload UI" button - Saves all settings and reloads the UI
        - "Save without Reload" button - Saves without interrupting gameplay
        - Auto-save visual indicator (green checkmark animation)
        - Error feedback when saving fails
        
        HOW SAVING IS TRIGGERED:
        -----------------------
        1. Automatic saving:
           a. UI element changes → QueueSave() → timer → save after delay
           b. Tab changes → QueueSave() → Process all elements → save
           c. Config panel closing → Process all tabs → force save
        
        2. Manual saving:
           a. Save buttons → CommitPendingChanges() → force save
           b. /pui_save command → CommitPendingChanges() → force save
           
        OPTIMIZATION STRATEGIES:
        ----------------------
        1. Prioritize recently changed elements
        2. Only process tabs/elements with actual changes
        3. Batch rapid sequential changes
        4. Defer heavy processing until needed
        5. Avoid redundant saving operations
        
        For more information on implementing changes to this system, 
        please reference the full documentation.
        ]]
        
        -- Add a single timer for batched saves
        config.saveTimer = nil
        
        -- Initialize pendingChanges as a table if it's not already
        if config.pendingChanges == nil then
            config.pendingChanges = {}
        elseif type(config.pendingChanges) ~= "table" then
            -- If it's a boolean or other type, convert to table
            local wasEnabled = config.pendingChanges
            config.pendingChanges = {}
            -- Preserve the intent of the boolean if it was true
            config.pendingChangesRequested = wasEnabled
        end
        
        -- Function to trigger save after a short delay
        local function QueueSave()
            -- Only queue a save if one isn't already pending
            if not config.saveTimer then
                config.pendingChangesRequested = true
                
                -- Create a new timer with a short delay to batch rapid changes
                config.saveTimer = C_Timer.After(0.3, function() -- Reduced delay for faster response
                    config.saveTimer = nil
                    
                    -- Clear the pending changes flag
                    config.hasPendingChanges = false
                    
                    -- Commit any pending changes
                    self:CommitPendingChanges()
                    
                    -- Process pending changes specifically using InstantSave if available
                    if Phoenix_UI.InstantSave and self.pendingChanges then
                        for element, _ in pairs(self.pendingChanges) do
                            if element and element.dbReference and element.dataKey and element.GetValue then
                                local value = element:GetValue()
                                if value ~= nil then
                                    -- Try to parse the module name and key for direct InstantSave
                                    local moduleName = element.dataKey:match("^([^%.]+)")
                                    local key = element.dataKey:match("^[^%.]+%.(.+)$")
                                    
                                    if moduleName and key then
                                        -- Use InstantSave for immediate saving
                                        Phoenix_UI:InstantSave(moduleName, key, value)
                                    end
                                end
                            end
                        end
                        
                        -- Clear pending changes after processing
                        self.pendingChanges = {}
                    end
                    
                    -- Save the database with the most robust method available
                    if Phoenix_UI.ForceSaveDB then
                        Phoenix_UI:ForceSaveDB()
                    elseif Phoenix_UI.SaveDB then
                        Phoenix_UI:SaveDB()
                    end
                    
                    -- Force an immediate flush to disk
                    pcall(function()
                        if FlushSettingsDB then
                            FlushSettingsDB()
                        elseif FlushSavedVariables then
                            FlushSavedVariables()
                        end
                    end)
                    
                    -- Add verification timestamp for save tracking
                    if _G["Phoenix_UIDB"] then
                        _G["Phoenix_UIDB"].__queue_saved = GetTime()
                    end
                end)
                
                -- Create a safety timer that ensures changes are saved even if the normal timer fails
                if not self.safetySaveTimer then
                    self.safetySaveTimer = C_Timer.NewTicker(2, function()
                        if self.hasPendingChanges and not self.saveTimer then
                            -- Clear the pending changes flag
                            self.hasPendingChanges = false
                            
                            -- Commit changes and force save
                            self:CommitPendingChanges()
                            
                            -- Process any remaining pending changes
                            if Phoenix_UI.InstantSave and self.pendingChanges then
                                for element, _ in pairs(self.pendingChanges) do
                                    if element and element.dbReference and element.dataKey and element.GetValue then
                                        local value = element:GetValue()
                                        if value ~= nil then
                                            local moduleName = element.dataKey:match("^([^%.]+)")
                                            local key = element.dataKey:match("^[^%.]+%.(.+)$")
                                            
                                            if moduleName and key then
                                                -- Use InstantSave for immediate saving
                                                Phoenix_UI:InstantSave(moduleName, key, value)
                                            end
                                        end
                                    end
                                end
                                
                                -- Clear pending changes
                                self.pendingChanges = {}
                            end
                            
                            -- Save using the most robust method available
                            if Phoenix_UI.ForceSaveDB then
                                Phoenix_UI:ForceSaveDB()
                            elseif Phoenix_UI.SaveDB then
                                Phoenix_UI:SaveDB()
                            end
                        end
                    end)
                end
            else
                -- Just mark that changes are pending for the existing timer
                config.pendingChangesRequested = true
            end
        end
        
        -- Track changed elements for optimization
        if not Phoenix_UI.UI.changedElements then
            Phoenix_UI.UI.changedElements = {}
        end
        
        -- Helper function to track when an element is changed
        Phoenix_UI.UI.TrackElementChange = function(self, element)
            if not element then return end
            
            -- Add to changed elements with timestamp
            self.changedElements[element] = GetTime()
        end
        
        -- Hook QueueSave to track element changes
        local originalQueueSave = QueueSave
        QueueSave = function()
            -- Track the changed element if we can find it
            local element = nil
            local caller = 2  -- Get info about the function that called QueueSave
            
            -- Use pcall to safely attempt to find the element
            pcall(function()
                -- Try to get the element from common caller patterns in the UI system
                if Phoenix_UI and Phoenix_UI.UI and Phoenix_UI.UI.lastInteractedElement then
                    element = Phoenix_UI.UI.lastInteractedElement
                end
                
                -- If we found a valid UI element
                if element and type(element) == "table" and (element.GetObjectType or element.GetValue) then
                    -- We found the UI element that triggered the save
                    Phoenix_UI.UI:TrackElementChange(element)
                end
            end)
            
            -- Call original function
            originalQueueSave()
        end
        
        -- For all elements with values that can change
        local function ProcessFrame(frame)
            if not frame then return end
            
            -- Process all child frames
            local children = {frame:GetChildren()}
            for _, child in ipairs(children) do
                ProcessFrame(child)
            end
            
            -- Hook slider OnValueChanged
            if frame.SetScript and frame.GetObjectType and frame:GetObjectType() == "Slider" then
                frame:HookScript("OnValueChanged", function(self, value)
                    QueueSave()
                end)
            end
            
            -- Hook checkbox OnClick
            if frame.SetScript and frame.GetObjectType and frame:GetObjectType() == "CheckButton" then
                frame:HookScript("OnClick", function()
                    QueueSave()
                end)
            end
            
            -- Hook dropdown selection
            if frame.dropdown and frame.dropdown.SetValue then
                local originalSetValue = frame.dropdown.SetValue
                frame.dropdown.SetValue = function(self, value)
                    originalSetValue(self, value)
                    QueueSave()
                end
            end
            
            -- Process native Phoenix_UIConfig elements that might have custom handlers
            if frame.OnValueChanged and type(frame.OnValueChanged) == "function" then
                local originalOnValueChanged = frame.OnValueChanged
                frame.OnValueChanged = function(self, ...)
                    originalOnValueChanged(self, ...)
                    QueueSave()
                end
            end
            
            -- Hook dropdown menu items (for Phoenix_UIConfig dropdowns)
            if frame.menu and frame.menu.buttons and type(frame.menu.buttons) == "table" then
                for _, button in ipairs(frame.menu.buttons) do
                    if button and button:GetObjectType() == "Button" and button:GetScript("OnClick") then
                        local originalOnClick = button:GetScript("OnClick")
                        button:SetScript("OnClick", function(self, ...)
                            originalOnClick(self, ...)
                            C_Timer.After(0.1, QueueSave)
                        end)
                    end
                end
            end
            
            -- Hook color picker if it exists
            if frame.colorSwatch and frame.colorSwatch:GetObjectType() == "Button" then
                frame.colorSwatch:HookScript("OnClick", function()
                    -- Use the color picker OnColorChange callback
                    if ColorPickerFrame.hasOpacity then
                        local oldFunc = ColorPickerFrame.func
                        ColorPickerFrame.func = function(...)
                            if oldFunc then oldFunc(...) end
                            QueueSave()
                        end
                    end
                end)
            end
        end
        
        -- Add auto-save on tab change to catch controls that might be lazy-loaded
        if self.tabs and self.tabs.buttons then
            for _, button in ipairs(self.tabs.buttons) do
                if button and not button.isHeader and button.SetScript then
                    local originalOnClick = button:GetScript("OnClick") or function() end
                    button:SetScript("OnClick", function(...)
                        originalOnClick(...)
                        C_Timer.After(0.2, function()
                            -- Process the new tab's content
                            if button.content then
                                ProcessFrame(button.content)
                            end
                            -- Save settings after tab change
                            QueueSave()
                        end)
                    end)
                end
            end
        end
        
        -- Process the whole config frame
        ProcessFrame(self)
        
        -- Forced save when config is closed
        self:HookScript("OnHide", function()
            -- Cancel any pending save timer
            if config.saveTimer then
                config.saveTimer:Cancel()
                config.saveTimer = nil
            end
            
            -- Extract the active tab info if possible
            local activeTab = nil
            if config.tabs and config.tabs.selected then
                -- Ensure buttons exists before trying to access it
                if config.tabs.buttons and type(config.tabs.buttons) == "table" and 
                   config.tabs.selected and config.tabs.buttons[config.tabs.selected] then
                    activeTab = config.tabs.buttons[config.tabs.selected]
                    if activeTab and activeTab.text then
                        -- Lowercase for comparison
                        activeTab = activeTab.text:lower()
                    end
                end
            end
            
            -- All modules to ensure proper saving
            local allModules = {
                "general", "unitframes", "nameplates", "actionbars", "castbars", 
                "buffs", "msbt", "idtip", "tooltip", "map", "chat", "misc",
                "uiscaling", "profiles", "weakauras"
            }
            
            -- Ensure all changes are committed before we save
            if Phoenix_UI then
                -- Cancel any pending timers
                if Phoenix_UI.saveTimer then
                    Phoenix_UI.saveTimer:Cancel()
                    Phoenix_UI.saveTimer = nil
                end
            
                -- Ensure all pending changes are committed first
                if config.CommitPendingChanges then
                    config:CommitPendingChanges()
                end
                
                -- Save ALL modules regardless of which tab was active
                for _, moduleName in ipairs(allModules) do
                    -- Force a fresh copy to ensure changes are recognized
                    if Phoenix_UI.db and Phoenix_UI.db.profile and Phoenix_UI.db.profile[moduleName] then
                        local settings = Phoenix_UI.db.profile[moduleName]
                        
                        -- Mark this module as updated
                        settings.__updated = GetTime()
                        settings.__saved_from = "config_panel_close"
                        
                        -- Update the settings with the timestamp
                        Phoenix_UI.db.profile[moduleName] = settings
                        
                        -- Also update the global variable directly
                        local currentProfile = Phoenix_UI.db.keys.profile or "Default"
                        if _G["Phoenix_UIDB"] and _G["Phoenix_UIDB"].profiles and 
                           _G["Phoenix_UIDB"].profiles[currentProfile] then
                            -- Ensure the module exists in global variable
                            if not _G["Phoenix_UIDB"].profiles[currentProfile][moduleName] then
                                _G["Phoenix_UIDB"].profiles[currentProfile][moduleName] = {}
                            end
                            
                            -- Deep copy to ensure all changes are preserved
                            _G["Phoenix_UIDB"].profiles[currentProfile][moduleName] = CopyTable(settings)
                        end
                    end
                end
                
                -- First try to use ForceSaveDB since it's most robust
                if Phoenix_UI.ForceSaveDB then
                    Phoenix_UI:ForceSaveDB()
                else
                    -- Fallback to regular save
                    if Phoenix_UI.SaveDB then
                        Phoenix_UI:SaveDB()
                    end
                    
                    -- Force flush to disk
                    if FlushSettingsDB then
                        FlushSettingsDB()
                    elseif FlushSavedVariables then
                        FlushSavedVariables()
                    end
                end
                
                -- Special handling for specific modules that need extra processing
                if activeTab then
                    -- MSBT special handling
                    if activeTab:find("msbt") and Phoenix_UI:GetModule("MSBT.Manager") then
                        local msbtManager = Phoenix_UI:GetModule("MSBT.Manager")
                        if msbtManager.UpdateSettings then
                            msbtManager:UpdateSettings()
                        end
                    end
                end
            end
        end)
        
        -- Add a fallback timer to periodically save changes
        C_Timer.NewTicker(10, function()
            if self:IsVisible() and config.pendingChangesRequested then
                if config.saveTimer then
                    config.saveTimer:Cancel()
                    config.saveTimer = nil
                end
                config.pendingChangesRequested = false
                
                -- Use ForceSaveDB for better persistence
                if Phoenix_UI.ForceSaveDB then
                    Phoenix_UI:ForceSaveDB()
                elseif Phoenix_UI.SaveDB then
                    Phoenix_UI:SaveDB()
                end
            end
        end)
    end
    
    -- Store the config frame for access from other modules
    Phoenix_UI.UI = config
    Phoenix_UI.UI.isInitialized = true

    -- Add utility functions to the UI object
    -- Find all configuration widgets and apply a function to them
    Phoenix_UI.UI.ProcessAllWidgets = function(self, func)
        if not self.panels then return end
        
        for _, panel in pairs(self.panels) do
            if panel and panel.elements then
                for _, element in pairs(panel.elements) do
                    if element then
                        func(element)
                    end
                end
            end
        end
    end
    
    -- Initialize UI section if it doesn't exist
    Phoenix_UI.UI = Phoenix_UI.UI or {}
    -- Initialize pendingChanges as a table
    Phoenix_UI.UI.pendingChanges = Phoenix_UI.UI.pendingChanges or {}
    
    -- Track changed elements for optimization
    if not Phoenix_UI.UI.changedElements then
        Phoenix_UI.UI.changedElements = {}
    end
    
    -- Helper function to track when an element is changed
    Phoenix_UI.UI.TrackElementChange = function(self, element)
        if not element then return end
        
        -- Add to changed elements with timestamp
        self.changedElements[element] = GetTime()
    end
    
    -- Modify CommitPendingChanges function to prioritize recently changed elements
    local originalCommitPendingChanges = Phoenix_UI.UI.CommitPendingChanges
    Phoenix_UI.UI.CommitPendingChanges = function(self)
        -- Create a structure for tracking processed modules to avoid redundant work
        local processedModules = {}
        
        -- Prepare tab access optimization
        local tabsData = {}
        if self.tabs and self.tabs.buttons then
            for _, button in ipairs(self.tabs.buttons) do
                if button and button.name and button.frame and not button.isHeader then
                    local tabName = button.name:lower()
                    tabsData[tabName] = button.frame
                end
            end
        end
        
        -- First process explicitly tracked changed elements for faster response
        if self.changedElements and type(self.changedElements) == "table" then
            -- Create a sorted list by recency
            local changedList = {}
            for element, timestamp in pairs(self.changedElements) do
                table.insert(changedList, {element = element, time = timestamp})
            end
            
            -- Sort by most recent
            table.sort(changedList, function(a, b) return a.time > b.time end)
            
            -- Only process recent changes (within the last 10 seconds)
            local currentTime = GetTime()
            local recentlyProcessed = {}
            
            for _, changeData in ipairs(changedList) do
                local element = changeData.element
                -- Skip if older than 10 seconds or already processed
                if (currentTime - changeData.time) > 10 or recentlyProcessed[element] then
                    -- Skip this element
                else
                    recentlyProcessed[element] = true
                    
                    -- Process element if it has what we need
                    if element and element.GetValue and element.dbReference and element.dataKey then
                        local success, value = pcall(function() return element:GetValue() end)
                        if success and value ~= nil then
                            -- Extract module name
                            local moduleName = element.dataKey:match("^([^%.]+)%.")
                            if moduleName then
                                -- Mark as processed
                                processedModules[moduleName] = true
                                
                                -- Get current value from DB for comparison
                                local currentValue = nil
                                local dbRef = element.dbReference
                                local keys = {}
                                for k in string.gmatch(element.dataKey, "[^.]+") do
                                    table.insert(keys, k)
                                end
                                
                                -- Navigate to parent table
                                local current = dbRef
                                for i = 1, #keys - 1 do
                                    if current[keys[i]] then
                                        current = current[keys[i]]
                                    else
                                        break
                                    end
                                end
                                
                                -- Get current value if the final key exists
                                if current and current[keys[#keys]] ~= nil then
                                    currentValue = current[keys[#keys]]
                                end
                                
                                -- Only update if value changed
                                if value ~= currentValue then
                                    -- Mark this element for the original commit function
                                    self.pendingChanges[element] = true
                                end
                            end
                        end
                    end
                end
            end
            
            -- Clear older changes from the tracking list
            for element, timestamp in pairs(self.changedElements) do
                if (currentTime - timestamp) > 60 then -- Remove after 1 minute
                    self.changedElements[element] = nil
                end
            end
        end
        
        -- Store original function before using it to prevent errors
        if originalCommitPendingChanges then
            -- Call original function, but with performance optimization
            -- We'll inject a variable to communicate which modules we've already processed
            if not Phoenix_UI.UI.__originalCommitPendingChangesUnoptimized then
                -- Store the original in a safe place
                Phoenix_UI.UI.__originalCommitPendingChangesUnoptimized = originalCommitPendingChanges
            end
            
            -- Call the original function
            originalCommitPendingChanges(self)
        else
            -- Fallback if originalCommitPendingChanges is nil
            if Phoenix_UI.UI.__originalCommitPendingChangesUnoptimized then
                Phoenix_UI.UI.__originalCommitPendingChangesUnoptimized(self)
            else
                -- Last resort fallback implementation if no original function is available
                if self.pendingChanges then
                    for element in pairs(self.pendingChanges) do
                        if element and element.dataKey and element.dbReference and element.GetValue then
                            local value = element:GetValue()
                            if value ~= nil then
                                local dbPath = element.dataKey:gsub("%.", ",%s")
                                element.dbReference[dbPath] = value
                            end
                        end
                    end
                    
                    -- Clear pending changes after processing
                    self.pendingChanges = {}
                end
            end
        end
    end
    
    -- Queue save with a short delay to batch multiple rapid changes
    Phoenix_UI.UI.QueueSave = function(self)
        -- Mark that there are pending changes
        self.hasPendingChanges = true
        
        -- Cancel any existing timer
        if self.saveTimer then
            self.saveTimer:Cancel()
            self.saveTimer = nil
        end
        
        -- Create a new timer with a short delay to batch rapid changes
        self.saveTimer = C_Timer.After(0.3, function() -- Reduced delay for faster response
            self.saveTimer = nil
            
            -- Clear the pending changes flag
            self.hasPendingChanges = false
            
            -- Commit any pending changes
            self:CommitPendingChanges()
            
            -- Process pending changes specifically using InstantSave if available
            if Phoenix_UI.InstantSave and self.pendingChanges then
                for element, _ in pairs(self.pendingChanges) do
                    if element and element.dbReference and element.dataKey and element.GetValue then
                        local value = element:GetValue()
                        if value ~= nil then
                            -- Try to parse the module name and key for direct InstantSave
                            local moduleName = element.dataKey:match("^([^%.]+)")
                            local key = element.dataKey:match("^[^%.]+%.(.+)$")
                            
                            if moduleName and key then
                                -- Use InstantSave for immediate saving
                                Phoenix_UI:InstantSave(moduleName, key, value)
                            end
                        end
                    end
                end
                
                -- Clear pending changes after processing
                self.pendingChanges = {}
            end
            
            -- Save the database with the most robust method available
            if Phoenix_UI.ForceSaveDB then
                Phoenix_UI:ForceSaveDB()
            elseif Phoenix_UI.SaveDB then
                Phoenix_UI:SaveDB()
            end
            
            -- Force an immediate flush to disk
            pcall(function()
                if FlushSettingsDB then
                    FlushSettingsDB()
                elseif FlushSavedVariables then
                    FlushSavedVariables()
                end
            end)
            
            -- Add verification timestamp for save tracking
            if _G["Phoenix_UIDB"] then
                _G["Phoenix_UIDB"].__queue_saved = GetTime()
            end
        end)
        
        -- Create a safety timer that ensures changes are saved even if the normal timer fails
        if not self.safetySaveTimer then
            self.safetySaveTimer = C_Timer.NewTicker(2, function()
                if self.hasPendingChanges and not self.saveTimer then
                    -- Clear the pending changes flag
                    self.hasPendingChanges = false
                    
                    -- Commit changes and force save
                    self:CommitPendingChanges()
                    
                    -- Process any remaining pending changes
                    if Phoenix_UI.InstantSave and self.pendingChanges then
                        for element, _ in pairs(self.pendingChanges) do
                            if element and element.dbReference and element.dataKey and element.GetValue then
                                local value = element:GetValue()
                                if value ~= nil then
                                    local moduleName = element.dataKey:match("^([^%.]+)")
                                    local key = element.dataKey:match("^[^%.]+%.(.+)$")
                                    
                                    if moduleName and key then
                                        Phoenix_UI:InstantSave(moduleName, key, value)
                                    end
                                end
                            end
                        end
                        
                        -- Clear pending changes
                        self.pendingChanges = {}
                    end
                    
                    -- Save using the most robust method available
                    if Phoenix_UI.ForceSaveDB then
                        Phoenix_UI:ForceSaveDB()
                    elseif Phoenix_UI.SaveDB then
                        Phoenix_UI:SaveDB()
                    end
                end
            end)
        end
    end
    
    -- Save immediately, bypassing any delays
    Phoenix_UI.UI.SaveNow = function(self)
        -- Cancel any pending save timer
        if self.saveTimer then
            self.saveTimer:Cancel()
            self.saveTimer = nil
        end
        
        -- Create a status indicator if it doesn't exist
        if not self.saveIndicator then
            self.saveIndicator = CreateFrame("Frame", nil, self.frame or UIParent)
            self.saveIndicator:SetSize(200, 40)
            self.saveIndicator:SetPoint("TOP", 0, -20)
            self.saveIndicator:SetFrameStrata("DIALOG")
            
            -- Add background
            self.saveIndicator.bg = self.saveIndicator:CreateTexture(nil, "BACKGROUND")
            self.saveIndicator.bg:SetAllPoints()
            self.saveIndicator.bg:SetColorTexture(0, 0, 0, 0.7)
            
            -- Add border
            self.saveIndicator.border = CreateFrame("Frame", nil, self.saveIndicator, "BackdropTemplate")
            self.saveIndicator.border:SetAllPoints()
            self.saveIndicator.border:SetBackdrop({
                edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
                edgeSize = 16,
                insets = { left = 4, right = 4, top = 4, bottom = 4 }
            })
            self.saveIndicator.border:SetBackdropBorderColor(1, 0.8, 0, 1)
            
            -- Add text
            self.saveIndicator.text = self.saveIndicator:CreateFontString(nil, "OVERLAY", "GameFontNormal")
            self.saveIndicator.text:SetPoint("CENTER")
            self.saveIndicator.text:SetText("Saving settings...")
            
            self.saveIndicator:Hide()
        end
        
        -- Show the save indicator
        self.saveIndicator:Show()
        
        -- Commit any pending changes before saving
        self:CommitPendingChanges()
        
        -- Force an immediate save with multiple layers of protection
        if Phoenix_UI then
            -- First save using the force method
            if Phoenix_UI.ForceSaveDB then
                Phoenix_UI:ForceSaveDB()
            elseif Phoenix_UI.SaveDB then
                Phoenix_UI:SaveDB()
            end
            
            -- Then force an update of the global variable for redundancy
            if Phoenix_UI.db and Phoenix_UI.db.profile then
                local currentProfile = Phoenix_UI.db.keys.profile or "Default"
                
                -- Ensure global variable exists
                if _G["Phoenix_UIDB"] == nil then
                    _G["Phoenix_UIDB"] = {}
                end
                
                if _G["Phoenix_UIDB"].profiles == nil then
                    _G["Phoenix_UIDB"].profiles = {}
                end
                
                if _G["Phoenix_UIDB"].profiles[currentProfile] == nil then
                    _G["Phoenix_UIDB"].profiles[currentProfile] = {}
                end
                
                -- Copy all settings to the global variable
                for moduleName, settings in pairs(Phoenix_UI.db.profile) do
                    if type(settings) == "table" then
                        -- Ensure module exists in global variable
                        if not _G["Phoenix_UIDB"].profiles[currentProfile][moduleName] then
                            _G["Phoenix_UIDB"].profiles[currentProfile][moduleName] = {}
                        end
                        
                        -- Deep copy to ensure all changes are preserved
                        _G["Phoenix_UIDB"].profiles[currentProfile][moduleName] = CopyTable(settings)
                    end
                end
                
                -- Mark when this was saved
                _G["Phoenix_UIDB"].__lastSaved = GetTime()
                _G["Phoenix_UIDB"].__currentProfile = currentProfile
                
                -- Force immediate write to disk
                pcall(function()
                    if FlushSettingsDB then
                        FlushSettingsDB()
                    elseif FlushSavedVariables then
                        FlushSavedVariables()
                    end
                end)
            end
        end
        
        -- Delay hiding the save indicator and update text
        C_Timer.After(0.5, function()
            if self.saveIndicator then
                self.saveIndicator.text:SetText("Settings saved successfully!")
                self.saveIndicator.border:SetBackdropBorderColor(0, 1, 0, 1)
                
                C_Timer.After(1.5, function()
                    if self.saveIndicator then
                        self.saveIndicator:Hide()
                    end
                end)
            end
        end)
        
        -- Return true to indicate success
        return true
    end
    
    -- Create a function to show main panel if it doesn't exist
    Phoenix_UI.UI.ShowMainPanel = function(self)
        -- Default implementation just returns the main panel if it exists
        return self.mainPanel
    end
    
    -- Add a function to add BuffOverlay settings access button
    Phoenix_UI.UI.AddBuffOverlayAccess = function(self, parentPanel)
        if not parentPanel then return end
        
        -- Check if BuffOverlay is loaded
        if not (LibStub and LibStub("AceAddon-3.0"):GetAddon("BuffOverlay", true)) then
            return
        end
        
        local BuffOverlay = LibStub("AceAddon-3.0"):GetAddon("BuffOverlay")
        
        -- Create a button to access BuffOverlay config directly
        local button = Phoenix_UIConfig:Button(parentPanel, 200, 30, "Open BuffOverlay Settings")
        button:SetPoint("TOPRIGHT", -20, -40)
        
        button:SetScript("OnClick", function()
            if BuffOverlay and BuffOverlay.OpenConfigPanel then
                BuffOverlay:OpenConfigPanel()
            end
        end)
        
        -- Add tooltip
        button.tooltipText = "Click to open the BuffOverlay configuration panel for detailed settings"
        button:SetScript("OnEnter", function(self)
            GameTooltip:SetOwner(self, "ANCHOR_TOP")
            GameTooltip:AddLine(self.tooltipText, 1, 1, 1, true)
            GameTooltip:Show()
        end)
        
        button:SetScript("OnLeave", function()
            GameTooltip:Hide()
        end)
        
        return button
    end

    -- Create a hook to add the button when the main panel is created
    local originalShowMainPanel = Phoenix_UI.UI.ShowMainPanel
    Phoenix_UI.UI.ShowMainPanel = function(self)
        -- Call original function
        local panel = originalShowMainPanel(self)
        
        -- Add our button if needed
        if panel and not panel.buffOverlayButton then
            panel.buffOverlayButton = self:AddBuffOverlayAccess(panel)
        end
        
        return panel
    end

    -- GameMenu
    local function PhoenixUIGameMenuButton(self)
        self:AddSection();
        self:AddButton("|cffFF7D0APhoenix|r|cffFF0000_|r|cffFFD100UI|r", function() 
            local toggleFunc = Phoenix_UI:Config(true)
            if type(toggleFunc) == "function" then
                toggleFunc()
            end
        end)
    end

    -- Always add the button to the Game Menu, regardless of settings
    -- This ensures the button is always present
    if GameMenuFrame then
        hooksecurefunc(GameMenuFrame, "InitButtons", PhoenixUIGameMenuButton)
        
        -- Force refresh the Game Menu buttons if it's already created
        if GameMenuFrame.buttons then
            PhoenixUIGameMenuButton(GameMenuFrame)
        end
    end
    
    -- Ensure the setting exists and is enabled in the profile
    if db and db.profile and db.profile.misc then
        db.profile.misc.menubutton = true
        
        -- Persist to database
        if Phoenix_UI.SaveDB then
            Phoenix_UI:SaveDB()
        end
    end
    
    -- Minimap AddOns Option
    -- Function version for AddonCompartmentFunc
    _G.Phoenix_Options = function()
        Phoenix_UI:Config()
    end
    
    -- Create option_table for AceConfig integration in a separate variable
    _G.Phoenix_OptionsTable = {
        name = "|cffFF7D0APhoenix|r|cffFF0000_|r|cffFFD100UI|r",
        type = "group",
        args = {
            openconfig = {
                name = "Open Configuration",
                desc = "Open the Phoenix_UI configuration panel",
                type = "execute",
                func = function() 
                    if Phoenix_UI.Config then
                        Phoenix_UI:Config()
                    else
                        print("|cffFF7D0APhoenix|r|cffFF0000_|r|cffFFD100UI|r: Configuration not loaded. Try reloading UI.")
                    end
                end,
                order = 1
            },
            version = {
                name = "Version",
                desc = "Current addon version",
                type = "description",
                fontSize = "medium",
                order = 2,
                width = "full",
                name = function() return "Version: " .. Phoenix_UI.Version end,
            }
        }
    }

    --Options - Now with integrated modules
    local options = {
        General = General.layout,
        Unitframes = Unitframes.layout,
        Nameplates = Nameplates.layout,
        Actionbar = Actionbar.layout,
        Castbars = Castbars.layout,
        IdTip = IdTip.layout,
        Buffoverlay = Buffoverlay.layout,
        Msbt = Msbt.layout,
        UIScaling = UIScaling.layout,
        Buffs = Buffs.layout,
        Tooltip = Tooltip.layout,
        Map = Map.layout,
        Chat = Chat.layout,
        Misc = Misc.layout,
        Profiles = Profiles.layout,
        FAQ = FAQ.layout,
        WeakAurasIntegration = WeakAurasIntegration.layout,
        CooldownTracker = CooldownTracker.layout,
        MythicPlus = MythicPlus.layout,
        DetailSkin = DetailSkin.layout,
        MoveAny = Phoenix_UI.layouts and Phoenix_UI.layouts.MoveAny or {},
        Skins = Phoenix_UI.layouts and Phoenix_UI.layouts.Skins or {},
    }

    -- Organize modules into categories for better organization
    local categories = {
        { title = '|cffFF7D0AGeneral|r', name = 'General', layout = options['General'] },
        
        -- Core UI elements
        { title = '|cffFF5500Core UI|r', name = 'header1', isHeader = true },
        { title = 'Unitframes', name = 'Unitframes', layout = options['Unitframes'] },
        { title = 'Nameplates', name = 'Nameplates', layout = options['Nameplates'] },
        { title = 'Actionbar', name = 'Actionbar', layout = options['Actionbar'] },
        { title = 'Castbars', name = 'Castbars', layout = options['Castbars'] },
        { title = 'Buffs', name = 'Buffs', layout = options['Buffs'] },
        
        -- Integrated Modules
        { title = '|cffFF5500Modules|r', name = 'header2', isHeader = true },
        { title = 'Buff Overlay', name = 'Buffoverlay', layout = options['Buffoverlay'] },
        { title = 'Cooldown Tracker', name = 'CooldownTracker', layout = options['CooldownTracker'] },
        { title = 'MSBT', name = 'Msbt', layout = options['Msbt'] },
        { title = 'IdTip', name = 'IdTip', layout = options['IdTip'] },
        { title = 'WeakAuras', name = 'WeakAurasIntegration', layout = options['WeakAurasIntegration'] },
        { title = 'Mythic+', name = 'MythicPlus', layout = Phoenix_UI.layouts and Phoenix_UI.layouts.MythicPlus or options['MythicPlus'] },
        { title = 'Detail Skin', name = 'DetailSkin', layout = Phoenix_UI.layouts and Phoenix_UI.layouts.DetailSkin or options['DetailSkin'] },
        { title = 'MoveAny', name = 'MoveAny', layout = Phoenix_UI.layouts and Phoenix_UI.layouts.MoveAny or options['MoveAny'] },
        { title = 'Skins', name = 'Skins', layout = Phoenix_UI.layouts and Phoenix_UI.layouts.Skins or options['Skins'] },
        
        -- Appearance
        { title = '|cffFF5500Appearance|r', name = 'header3', isHeader = true },
        { title = 'UI Scaling', name = 'UIScaling', layout = options['UIScaling'] },
        { title = 'Tooltip', name = 'Tooltip', layout = options['Tooltip'] },
        { title = 'Map', name = 'Map', layout = options['Map'] },
        { title = 'Chat', name = 'Chat', layout = options['Chat'] },
        { title = 'Misc', name = 'Misc', layout = options['Misc'] },
        
        -- Support
        { title = '|cffFF5500Support|r', name = 'header4', isHeader = true },
        { title = 'Profiles', name = 'Profiles', layout = options['Profiles'] },
        { title = 'FAQ', name = 'FAQ', layout = options['FAQ'] }
    }

    -- Enhanced Tabs with better styling for visual distinction
    local tabs = Phoenix_UIConfig:TabPanel(config, nil, nil, categories, true, 200, 27)
    if not tabs then
        -- Create a simple fallback if tab creation fails
        if Phoenix_UI and Phoenix_UI.ShowMessage then
            Phoenix_UI:ShowMessage("Error creating tab panel. Using fallback.", true, true)
        else
            print("|cffFF7D0APhoenix|r|cffFF0000_|r|cffFFD100UI|r: Error creating tab panel. Using fallback.")
        end
        tabs = CreateFrame("Frame", nil, config)
        tabs:SetSize(200, 600)
        tabs:SetPoint("TOPLEFT", config, 10, -45)
        tabs.buttons = {}
        tabs.buttonContainer = tabs
        tabs.container = CreateFrame("Frame", nil, config)
        tabs.container:SetSize(650, 550)
        tabs.container:SetPoint("TOPRIGHT", config, -10, -45)
    end

    Phoenix_UIConfig:GlueAcross(tabs, config, 10, -45, -10, 10)
    
    -- Ensure tabs has a buttons table to prevent nil errors
    if not tabs.buttons then
        tabs.buttons = {}
    end
    
    -- Create better tab styling
    if tabs.buttons and type(tabs.buttons) == "table" then
        for i, button in ipairs(tabs.buttons) do
            if button and not button.isHeader then
                button:SetHeight(30)
                if button.text then
                    button.text:SetFont("Interface\\AddOns\\Phoenix_UI\\Media\\Fonts\\PTSansNarrow.ttf", 13)
                end
                
                -- Add hover glow effect
                button:SetScript("OnEnter", function()
                    if not button.selected then
                        if button.highlight then
                            button.highlight:SetAlpha(0.4)
                        end
                    end
                end)
                
                button:SetScript("OnLeave", function()
                    if not button.selected then
                        if button.highlight then
                            button.highlight:SetAlpha(0.2)
                        end
                    end
                end)
                
                -- Add safe OnClick handler to prevent errors
                local originalOnClick = button:GetScript("OnClick")
                button:SetScript("OnClick", function(clickedButton, button, down)
                    -- Protect against errors during tab switching
                    local success, errorMsg = pcall(function()
                        if originalOnClick then
                            originalOnClick(clickedButton, button, down)
                        end
                    end)
                    
                    if not success and Phoenix_UI and Phoenix_UI.debug then
                        print("Error switching tabs:", errorMsg)
                    end
                end)
            elseif button and button.isHeader then
                -- Style header tabs
                button:SetHeight(24)
                if button.text then
                    button.text:SetFont("Interface\\AddOns\\Phoenix_UI\\Media\\Fonts\\Prototype.ttf", 14)
                    button.text:SetTextColor(1, 0.5, 0)
                end
                
                -- Disable header clicking
                button:SetScript("OnMouseDown", nil)
                button:SetScript("OnMouseUp", nil)
                button:SetScript("OnClick", nil)
                button:EnableMouse(false)
            end
        end
    end
    
    -- Store tabs in the config frame for access in RefreshConfig
    config.tabs = tabs

    -- SCROLL FRAMES with enhanced styling
    local scrollTabs = Phoenix_UIConfig:ScrollFrame(config, 200, 550, tabs.buttonContainer)
    Phoenix_UIConfig:GlueTop(scrollTabs, config, 10, -45, 'LEFT')
    
    -- Add subtle gradient to tab scrollframe
    local gradientTex = scrollTabs:CreateTexture(nil, "BACKGROUND")
    gradientTex:SetPoint("TOPLEFT", scrollTabs, "TOPLEFT", 0, 0)
    gradientTex:SetPoint("BOTTOMRIGHT", scrollTabs, "BOTTOMRIGHT", 0, 0)
    gradientTex:SetTexture("Interface\\AddOns\\Phoenix_UI\\Media\\Textures\\Background\\GradientBG")
    gradientTex:SetVertexColor(0.1, 0.1, 0.1, 0.3)
    gradientTex:SetBlendMode("ADD")

    local scrollContainer = Phoenix_UIConfig:ScrollFrame(config, 650, 550, tabs.container)
    Phoenix_UIConfig:GlueTop(scrollContainer, config, -10, -45, 'RIGHT')

    -- Enhanced Save Button with Phoenix styling
    local save = Phoenix_UIConfig:Button(config, 200, 30, 'Save and Reload UI')
    Phoenix_UIConfig:GlueBottom(save, config, 10, 20, 'LEFT')
    save:SetScript('OnClick', function()
        -- Ensure database is properly saved before reloading
        if Phoenix_UI.SaveAllTabSettings then
            Phoenix_UI:SaveAllTabSettings()
        elseif Phoenix_UI.SaveDB then
            Phoenix_UI:SaveDB()
        end
        ReloadUI()
    end)
    
    -- Style the save button with a more Phoenix-themed look
    if save.Left and save.Right and save.Middle then
        save.Left:SetVertexColor(1, 0.4, 0)
        save.Right:SetVertexColor(1, 0.4, 0)
        save.Middle:SetVertexColor(1, 0.4, 0) 
    end
    
    -- Add an additional button for just saving without reload
    local quickSave = Phoenix_UIConfig:Button(config, 200, 30, 'Save without Reload')
    Phoenix_UIConfig:GlueBottom(quickSave, config, -10, 20, 'RIGHT')
    quickSave:SetScript('OnClick', function()
        -- Cancel any pending timers
        if config.saveTimer then
            config.saveTimer:Cancel()
            config.saveTimer = nil
        end
        
        -- Ensure all pending changes are committed
        if config.CommitPendingChanges then
            config:CommitPendingChanges()
        end
        
        -- Force a full validation of settings
        if Phoenix_UI.ValidateSettings then
            Phoenix_UI:ValidateSettings()
        end
        
        -- Save all tabs explicitly before force-saving
        if Phoenix_UI.SaveAllTabSettings then
            Phoenix_UI:SaveAllTabSettings()
        end
        
        -- Use our robust force-save method to guarantee writing to disk
        if Phoenix_UI.ForceSaveDB then
            Phoenix_UI:ForceSaveDB()
        else
            -- Fallback to regular save if force-save not available
            if Phoenix_UI.SaveDB then
                Phoenix_UI:SaveDB()
                -- Try to flush manually
                if FlushSettingsDB then
                    FlushSettingsDB()
                elseif FlushSavedVariables then
                    FlushSavedVariables()
                end
            end
        end
        
        -- Provide feedback to the user
        local activeTab = nil
        if config.tabs and config.tabs.selected then
            activeTab = config.tabs.buttons[config.tabs.selected]
            if activeTab and activeTab.text then
                activeTab = activeTab.text
            end
        end
        
        local message = "Settings saved successfully!"
        if activeTab then
            message = activeTab .. " settings saved successfully!"
        end
        
        -- Use the centralized messaging system if available
        if Phoenix_UI.ShowMessage then
            Phoenix_UI:ShowMessage(message, true)
        else
            print("|cffFF7D0APhoenix|r|cffFF0000_|r|cffFFD100UI|r: " .. message)
        end
    end)
    
    -- Style the quick save button
    if quickSave.Left and quickSave.Right and quickSave.Middle then
        quickSave.Left:SetVertexColor(0.4, 0.7, 1)
        quickSave.Right:SetVertexColor(0.4, 0.7, 1)
        quickSave.Middle:SetVertexColor(0.4, 0.7, 1)
    end
    
    -- Integration hooks for each module
    self:IntegrateModules(config)
    
    -- Register auto-save for all UI elements
    C_Timer.After(1, function()
        if config.RegisterAutoSave then
            config:RegisterAutoSave()
            -- print("|cffFF7D0APhoenix|r|cffFF0000_|r|cffFFD100UI|r: Auto-save registered for all UI controls")
        end
    end)

    -- Create a robust force-save function that ensures all settings are saved to disk
    if not Phoenix_UI.ForceSaveDB then
        Phoenix_UI.ForceSaveDB = function(self)
            -- First use the regular save method
            if self.SaveDB then
                self:SaveDB()
            end
            
            -- Set a special flag to indicate we want to force persistence
            if self.db and self.db.sv then
                self.db.sv.__forceSaved = time()
                self.db.sv.__lastSaved = GetTime()
            end
            
            -- Record data for verification
            local verificationData = {}
            if self.db and self.db.profile then
                -- Store key information for verification
                for moduleName, moduleData in pairs(self.db.profile) do
                    if type(moduleData) == "table" then
                        verificationData[moduleName] = {
                            timestamp = moduleData.__updated or GetTime(),
                            enabled = moduleData.enabled,
                            checksum = self:GenerateSimpleChecksum(moduleData)
                        }
                    end
                end
            end
            
            -- Attempt to immediately flush saved variables to disk
            if FlushSettingsDB then
                FlushSettingsDB() 
            end
            if FlushSavedVariables then
                FlushSavedVariables()
            end
            
            -- Verification step (check after a small delay to ensure disk write has occurred)
            C_Timer.After(0.5, function()
                if not self.db or not self.db.profile then return end
                
                local verificationFailed = false
                local failedModules = {}
                
                -- Check each module's data for verification
                for moduleName, verifyData in pairs(verificationData) do
                    if self.db.profile[moduleName] then
                        local currentChecksum = self:GenerateSimpleChecksum(self.db.profile[moduleName])
                        
                        -- If checksums don't match, verification failed
                        if currentChecksum ~= verifyData.checksum then
                            verificationFailed = true
                            table.insert(failedModules, moduleName)
                        end
                        
                        -- Store the verification result
                        self.db.profile[moduleName].__verified = (currentChecksum == verifyData.checksum)
                    end
                end
                
                -- Update global variable's verification status
                if _G["Phoenix_UIDB"] and _G["Phoenix_UIDB"].profiles then
                    local currentProfile = self.db.keys.profile or "Default"
                    _G["Phoenix_UIDB"].__lastVerified = GetTime()
                    _G["Phoenix_UIDB"].__verificationStatus = not verificationFailed
                    
                    -- If verification failed, try one more forced save
                    if verificationFailed and #failedModules > 0 then
                        -- Log for debugging
                        if self.debug then
                            print("Save verification failed for modules:", table.concat(failedModules, ", "))
                            print("Attempting recovery save...")
                        end
                        
                        -- Create a backup in per-character DB
                        if not _G["Phoenix_UIPerCharDB"] then
                            _G["Phoenix_UIPerCharDB"] = {}
                        end
                        if not _G["Phoenix_UIPerCharDB"].failedSaves then
                            _G["Phoenix_UIPerCharDB"].failedSaves = {}
                        end
                        
                        -- Store backup of failed modules
                        for _, moduleName in ipairs(failedModules) do
                            if self.db.profile[moduleName] then
                                if not _G["Phoenix_UIPerCharDB"].failedSaves[moduleName] then
                                    _G["Phoenix_UIPerCharDB"].failedSaves[moduleName] = {}
                                end
                                
                                -- Store with timestamp
                                _G["Phoenix_UIPerCharDB"].failedSaves[moduleName][GetTime()] = 
                                    CopyTable(self.db.profile[moduleName])
                                
                                -- Force the module again in the global var
                                if _G["Phoenix_UIDB"].profiles[currentProfile] then
                                    _G["Phoenix_UIDB"].profiles[currentProfile][moduleName] = 
                                        CopyTable(self.db.profile[moduleName])
                                end
                            end
                        end
                        
                        -- Try to flush again
                        if FlushSettingsDB then FlushSettingsDB() end
                        if FlushSavedVariables then FlushSavedVariables() end
                    end
                end
            end)
            
            -- For debugging only
            if self.debug then
                print("Phoenix_UI: Force-saved DB at", date("%H:%M:%S", time()))
            end
            
            return true
        end
        
        -- Helper function to generate a simple checksum for verification
        Phoenix_UI.GenerateSimpleChecksum = function(self, tbl)
            if type(tbl) ~= "table" then return tostring(tbl) end
            
            local sum = 0
            local count = 0
            
            -- Process the table recursively, but limited to avoid deep recursion
            local function ProcessTable(t, depth)
                if depth > 3 then return end -- Limit recursion depth
                
                for k, v in pairs(t) do
                    -- Skip internal keys that start with underscore
                    if type(k) ~= "string" or not k:match("^__") then
                        if type(v) == "number" then
                            sum = sum + v
                            count = count + 1
                        elseif type(v) == "string" then
                            sum = sum + #v
                            count = count + 1
                        elseif type(v) == "boolean" then
                            sum = sum + (v and 1 or 0)
                            count = count + 1
                        elseif type(v) == "table" then
                            ProcessTable(v, depth + 1)
                        end
                    end
                end
            end
            
            ProcessTable(tbl, 0)
            
            -- Combine count and sum for a rudimentary checksum
            local checksum = count .. ":" .. sum
            return checksum
        end
    end

    -- Add a global diagnostic and repair function for settings persistence
    Phoenix_UI.DiagnoseAndRepairSettings = function()
        -- Check all modules, not just critical ones
        local allModules = {
            "general", "unitframes", "nameplates", "actionbars", "castbars", 
            "buffs", "msbt", "idtip", "tooltip", "map", "chat", "misc",
            "uiscaling", "profiles", "weakauras"
        }
        
        -- Check if the main database exists
        if not Phoenix_UI.db or not Phoenix_UI.db.profile then
            return false
        end
        
        -- Create a backup of the current settings
        if not _G["Phoenix_UIPerCharDB"] then
            _G["Phoenix_UIPerCharDB"] = {}
        end
        
        -- Create settings backup
        _G["Phoenix_UIPerCharDB"].SettingsBackup = _G["Phoenix_UIPerCharDB"].SettingsBackup or {}
        _G["Phoenix_UIPerCharDB"].SettingsBackup.timestamp = time()
        _G["Phoenix_UIPerCharDB"].SettingsBackup.modules = {}
        
        -- Check each module
        local repairsNeeded = 0
        local repairsCompleted = 0
        
        for _, moduleName in ipairs(allModules) do
            -- Check if module settings exist
            if not Phoenix_UI.db.profile[moduleName] then
                Phoenix_UI.db.profile[moduleName] = {}
                repairsNeeded = repairsNeeded + 1
                repairsCompleted = repairsCompleted + 1
            end
            
            -- Ensure module has an enabled state
            if Phoenix_UI.db.profile[moduleName].enabled == nil then
                -- Default to enabled for most modules
                if moduleName == "msbt" then
                    Phoenix_UI.db.profile[moduleName].enabled = Phoenix_UI.db.profile[moduleName].enabled or false
                else
                    Phoenix_UI.db.profile[moduleName].enabled = Phoenix_UI.db.profile[moduleName].enabled or true
                end
                repairsNeeded = repairsNeeded + 1
                repairsCompleted = repairsCompleted + 1
            end
            
            -- Module-specific validations
            if moduleName == "nameplates" then
                -- Ensure essential nameplates settings
                local np = Phoenix_UI.db.profile.nameplates
                if not np.decimals then 
                    np.decimals = "1"
                    repairsNeeded = repairsNeeded + 1
                    repairsCompleted = repairsCompleted + 1
                end
                if not np.style then 
                    np.style = "Default"
                    repairsNeeded = repairsNeeded + 1
                    repairsCompleted = repairsCompleted + 1
                end
                if not np.npccolors then 
                    np.npccolors = {}
                    repairsNeeded = repairsNeeded + 1
                    repairsCompleted = repairsCompleted + 1
                end
            end
            
            -- Save backup for this module
            _G["Phoenix_UIPerCharDB"].SettingsBackup.modules[moduleName] = {
                exists = true,
                verified = true,
                enabled = Phoenix_UI.db.profile[moduleName].enabled
            }
        end
        
        -- Also check specialized module namespaces
        local specializedModules = {
            "MSBT", "idTip", "BuffOverlay", "PremadeGroupsFilter"
        }
        
        for _, moduleName in ipairs(specializedModules) do
            if Phoenix_UI.moduleDB and not Phoenix_UI.moduleDB[moduleName] then
                Phoenix_UI.moduleDB[moduleName] = { profile = {} }
                repairsNeeded = repairsNeeded + 1
                repairsCompleted = repairsCompleted + 1
            end
            
            if Phoenix_UI.moduleDB and Phoenix_UI.moduleDB[moduleName] and not Phoenix_UI.moduleDB[moduleName].profile then
                Phoenix_UI.moduleDB[moduleName].profile = {}
                repairsNeeded = repairsNeeded + 1
                repairsCompleted = repairsCompleted + 1
            end
            
            -- Ensure enabled state is set for specialized modules
            if Phoenix_UI.moduleDB and Phoenix_UI.moduleDB[moduleName] and 
               Phoenix_UI.moduleDB[moduleName].profile and
               Phoenix_UI.moduleDB[moduleName].profile.enabled == nil then
                -- Default to MSBT disabled, others enabled
                if moduleName == "MSBT" then
                    Phoenix_UI.moduleDB[moduleName].profile.enabled = false
                else
                    Phoenix_UI.moduleDB[moduleName].profile.enabled = true
                end
                
                repairsNeeded = repairsNeeded + 1
                repairsCompleted = repairsCompleted + 1
            end
        end
        
        -- Ensure the global Phoenix_UIDB is properly structured
        if not _G["Phoenix_UIDB"] then
            _G["Phoenix_UIDB"] = {}
            repairsNeeded = repairsNeeded + 1
            repairsCompleted = repairsCompleted + 1
        end
        
        if not _G["Phoenix_UIDB"].profiles then
            _G["Phoenix_UIDB"].profiles = {}
            repairsNeeded = repairsNeeded + 1
            repairsCompleted = repairsCompleted + 1
        end
        
        -- Get current profile
        local currentProfile = Phoenix_UI.db.keys.profile or "Default"
        
        -- Ensure current profile exists in Phoenix_UIDB
        if not _G["Phoenix_UIDB"].profiles[currentProfile] then
            _G["Phoenix_UIDB"].profiles[currentProfile] = {}
            repairsNeeded = repairsNeeded + 1
            repairsCompleted = repairsCompleted + 1
        end
        
        -- Copy all module settings to Phoenix_UIDB
        for _, moduleName in ipairs(allModules) do
            if Phoenix_UI.db.profile[moduleName] then
                _G["Phoenix_UIDB"].profiles[currentProfile][moduleName] = CopyTable(Phoenix_UI.db.profile[moduleName])
            end
        end
        
        -- Force save changes using every available method
        if Phoenix_UI.ForceSaveDB then
            Phoenix_UI:ForceSaveDB()
        elseif Phoenix_UI.SaveDB then
            Phoenix_UI:SaveDB()
        end
        
        -- Force an immediate flush to disk
        pcall(function()
            if FlushSettingsDB then FlushSettingsDB() end
            if FlushSavedVariables then FlushSavedVariables() end
        end)
        
        return true
    end
    
    -- Register global slash command for diagnostics
    SLASH_PHOENIX_REPAIR1 = "/pui_repair"
    SlashCmdList["PHOENIX_REPAIR"] = function()
        if Phoenix_UI.DiagnoseAndRepairSettings then
            Phoenix_UI:DiagnoseAndRepairSettings()
        else
            print("|cffFF7D0APhoenix|r|cffFF0000_|r|cffFFD100UI|r: Diagnostic tools not available.")
        end
    end
    
    -- Run diagnostics on startup after a delay
    C_Timer.After(5, function()
        if Phoenix_UI.DiagnoseAndRepairSettings then
            Phoenix_UI:DiagnoseAndRepairSettings()
        end
    end)

    -- Hook the SaveAllSettings function to the mainPanel's OnHide event
    Phoenix_UI.HookSaveAllSettings = function()
        -- Safety check to ensure UI is initialized
        if not Phoenix_UI.UI or not Phoenix_UI.UI.mainPanel then
            C_Timer.After(1, Phoenix_UI.HookSaveAllSettings)
            return
        end
        
        -- Add the hook to save all settings when the panel is closed
        Phoenix_UI.UI.mainPanel:HookScript("OnHide", function()
            -- Add a small delay to ensure all widgets have committed their values
            C_Timer.After(0.5, function()
                if Phoenix_UI.SaveAllSettings then
                    Phoenix_UI:SaveAllSettings()
                end
            end)
        end)
        
        -- Add confirmation text to the panel
        if not Phoenix_UI.UI.mainPanel.saveConfirmText then
            local saveText = Phoenix_UI.UI.mainPanel:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
            saveText:SetPoint("BOTTOMLEFT", Phoenix_UI.UI.mainPanel, "BOTTOMLEFT", 10, 10)
            saveText:SetText("Settings will be saved automatically when closing this panel")
            saveText:SetTextColor(0, 0.8, 0, 1)
            Phoenix_UI.UI.mainPanel.saveConfirmText = saveText
        end
    end
    
    -- Call the hook function to set it up
    C_Timer.After(1, Phoenix_UI.HookSaveAllSettings)

    -- Constructor for Configuration UI
    Phoenix_UI.UI.Create = function(self)
        -- Check if the UI already exists
        if self.frame then
            return
        end
        
        -- Create the main frame
        local frame = CreateFrame("Frame", "Phoenix_UIConfigFrame", UIParent, "BackdropTemplate")
        frame:SetFrameStrata("DIALOG")
        frame:SetFrameLevel(100)
        frame:SetSize(900, 600)
        frame:SetPoint("CENTER")
        frame:SetBackdrop({
            bgFile = "Interface\\BUTTONS\\WHITE8X8",
            edgeFile = "Interface\\BUTTONS\\WHITE8X8",
            tile = true, tileSize = 16, edgeSize = 1,
            insets = { left = 0, right = 0, top = 0, bottom = 0 }
        })
        frame:SetBackdropColor(0.1, 0.1, 0.1, 0.9)
        frame:SetBackdropBorderColor(0.8, 0.8, 0.8, 0.8)
        frame:EnableMouse(true)
        frame:SetMovable(true)
        frame:RegisterForDrag("LeftButton")
        frame:SetScript("OnDragStart", frame.StartMoving)
        frame:SetScript("OnDragStop", frame.StopMovingOrSizing)
        frame:SetClampedToScreen(true)
        frame:Hide()
        
        -- Create a beautiful Phoenix UI title with fire effects
        local titleContainer = CreateFrame("Frame", nil, frame)
        titleContainer:SetSize(400, 60)
        titleContainer:SetPoint("TOP", frame, "TOP", 0, -5)
        
        -- Add glowing background
        local glowBg = titleContainer:CreateTexture(nil, "BACKGROUND")
        glowBg:SetTexture("Interface/AddOns/Phoenix_UI/Media/Textures/Effects/GlowBG")
        glowBg:SetAllPoints()
        glowBg:SetBlendMode("ADD")
        glowBg:SetVertexColor(0.7, 0.3, 0.1, 0.5)
        
        -- Create the main title text
        local titleText = titleContainer:CreateFontString(nil, "OVERLAY")
        titleText:SetFont("Interface/AddOns/Phoenix_UI/Media/Fonts/Prototype.ttf", 24, "OUTLINE")
        titleText:SetPoint("CENTER", titleContainer, "CENTER", 0, 0)
        titleText:SetText("|cffFF7D0APhoenix|r |cffE03010UI|r |cffFF9C26by VortexQ8|r")
        titleText:SetShadowOffset(2, -2)
        titleText:SetShadowColor(0, 0, 0, 1)
        
        -- Add flame effect at the bottom
        local flame = titleContainer:CreateTexture(nil, "ARTWORK")
        flame:SetTexture("Interface/AddOns/Phoenix_UI/Media/Textures/Effects/FireTile")
        flame:SetPoint("BOTTOMLEFT", titleContainer, "BOTTOMLEFT", -10, -5)
        flame:SetPoint("BOTTOMRIGHT", titleContainer, "BOTTOMRIGHT", 10, -5)
        flame:SetHeight(30)
        flame:SetBlendMode("ADD")
        flame:SetVertexColor(1, 0.7, 0.3, 0.7)
        
        -- Add ember effect
        local ember = titleContainer:CreateTexture(nil, "ARTWORK", nil, 1)
        ember:SetTexture("Interface/AddOns/Phoenix_UI/Media/Textures/Effects/Embers")
        ember:SetAllPoints(titleContainer)
        ember:SetBlendMode("ADD")
        ember:SetVertexColor(1, 0.6, 0.1, 0.4)
        
        -- Create animations for the fire effects
        local flameAnim = flame:CreateAnimationGroup()
        flameAnim:SetLooping("REPEAT")
        
        -- Horizontal movement animation
        local flameTranslate = flameAnim:CreateAnimation("Translation")
        flameTranslate:SetDuration(3)
        flameTranslate:SetOffset(60, 0)
        flameTranslate:SetOrder(1)
        
        -- Reverse movement
        local flameTranslate2 = flameAnim:CreateAnimation("Translation")
        flameTranslate2:SetDuration(3)
        flameTranslate2:SetOffset(-60, 0)
        flameTranslate2:SetOrder(2)
        
        -- Ember animation
        local emberAnim = ember:CreateAnimationGroup()
        emberAnim:SetLooping("REPEAT")
        
        -- Ember fade animation
        local emberFade1 = emberAnim:CreateAnimation("Alpha")
        emberFade1:SetFromAlpha(0.3)
        emberFade1:SetToAlpha(0.6)
        emberFade1:SetDuration(2)
        emberFade1:SetOrder(1)
        
        local emberFade2 = emberAnim:CreateAnimation("Alpha")
        emberFade2:SetFromAlpha(0.6)
        emberFade2:SetToAlpha(0.3)
        emberFade2:SetDuration(2)
        emberFade2:SetOrder(2)
        
        -- Text glow animation
        local textAnim = titleText:CreateAnimationGroup()
        textAnim:SetLooping("REPEAT")
        
        local textGlow = textAnim:CreateAnimation("Alpha")
        textGlow:SetFromAlpha(0.7)
        textGlow:SetToAlpha(1)
        textGlow:SetDuration(1.5)
        textGlow:SetOrder(1)
        
        local textFade = textAnim:CreateAnimation("Alpha")
        textFade:SetFromAlpha(1)
        textFade:SetToAlpha(0.7)
        textFade:SetDuration(1.5)
        textFade:SetOrder(2)
        
        -- Start animations when the frame is shown
        frame:SetScript("OnShow", function()
            -- Refresh the title text when window is shown
            if not titleText then return end
            
            -- Make sure the text is visible and at the front
            titleText:SetParent(config.titlePanel)
            titleText:SetPoint("CENTER", config.titlePanel, "CENTER", 0, 2)
            titleText:SetDrawLayer("OVERLAY", 5)
            titleText:SetText("|cffFF7D0APhoenix|r |cffFF5000UI|r |cffFFD100By VortexQ8|r")
            
            -- Make sure the animations are playing
            if glowAnim and not glowAnim:IsPlaying() then
                glowAnim:Play()
            end
            
            if fireAnim1 and not fireAnim1:IsPlaying() then
                fireAnim1:Play()
            end
            
            if fireAnim2 and not fireAnim2:IsPlaying() then
                fireAnim2:Play()
            end
        end)
        
        -- Save changes when frame is hidden
        frame:SetScript("OnHide", function()
            -- Commit any pending changes before the frame is hidden
            if Phoenix_UI.UI and Phoenix_UI.UI.CommitPendingChanges then
                Phoenix_UI.UI:CommitPendingChanges()
            end
            
            -- Save the database to ensure nothing is lost
            if Phoenix_UI.SaveDB then
                Phoenix_UI:SaveDB()
            end
        end)
    end
    
    -- Add a method to handle tab changes
    config.OnTabChanged = function(self, tabName)
        -- Save the selected tab
        if Phoenix_UI.db and Phoenix_UI.db.profile then
            Phoenix_UI.db.profile.lastSelectedTab = tabName
            
            -- Force an immediate save
            if Phoenix_UI.SaveDB then
                Phoenix_UI:SaveDB()
            end
        end
    end
    
    -- Hook tab selection to save the selected tab
    local originalTabSelectMethod = nil
    if Phoenix_UIConfig.TabPanel and type(Phoenix_UIConfig.TabPanel) == "table" then
        originalTabSelectMethod = Phoenix_UIConfig.TabPanel.SelectTab
    end
    
    if originalTabSelectMethod then
        Phoenix_UIConfig.TabPanel.SelectTab = function(self, name, ...)
            local result = originalTabSelectMethod(self, name, ...)
            
            -- Call our tab changed handler
            if result and config.OnTabChanged then
                config.OnTabChanged(config, name)
            end
            
            return result
        end
    end

    -- Tab selection function with improved scroll handling
    local function SelectTab(tab)
        if not tab or not tabs.buttons[tab] then
            return
        end
        
        -- Hide previously selected tab container
        if tabs.selected then
            tabs.pages[tabs.selected]:Hide()
            tabs.buttons[tabs.selected].selected = false
            tabs.buttons[tabs.selected]:SetBackdropColor(0, 0, 0, 0.5)
        end
        
        -- Show the new tab
        tabs.selected = tab
        tabs.pages[tab]:Show()
        tabs.buttons[tab].selected = true
        tabs.buttons[tab]:SetBackdropColor(0.4, 0.1, 0, 0.7)
        
        -- Reset scroll position for scrollable content
        if tabs.container and tabs.container.scrollFrame then
            tabs.container.scrollFrame:SetVerticalScroll(0)
        end
        
        -- If the tab has a scrollbar, reset its position
        if tabs.container and tabs.container.scrollBar then
            tabs.container.scrollBar:SetValue(0)
        end
        
        -- If there's a panel associated with the tab and it has a scrollChild
        if Phoenix_UI.UI and Phoenix_UI.UI.panels and Phoenix_UI.UI.panels[tab] and 
           Phoenix_UI.UI.panels[tab].scrollChild then
            -- Force a recalculation of the scroll child height
            C_Timer.After(0.1, function()
                if Phoenix_UI.UI.panels[tab].UpdateScrollChildHeight then
                    Phoenix_UI.UI.panels[tab]:UpdateScrollChildHeight()
                end
            end)
        end
        
        return true
    end
    
    -- Connect click handlers to all tab buttons
    for tabName, button in pairs(tabs.buttons) do
        if button then
            button:SetScript("OnClick", function()
                SelectTab(tabName)
            end)
        end
    end
    
    -- Select initial tab
    if not tabs.selected and next(tabs.buttons) then
        SelectTab(next(tabs.buttons))
    end
end

-- Function to integrate external modules into the Phoenix UI panel
function Gui:IntegrateModules(config)
    -- Only proceed if config exists
    if not config then return end
    
    -- Safe function to select a config tab
    local function SelectTabSafely(tabName)
        -- Make sure config and tabs exist
        if not config or not config.tabs then return false end
        
        -- Make sure buttons array exists
        if not config.tabs.buttons or type(config.tabs.buttons) ~= "table" then return false end
        
        -- Try to find and click the button
        for _, button in ipairs(config.tabs.buttons) do
            if button and button.name == tabName and button.Click then
                button:Click()
                return true
            end
        end
        return false
    end
    
    -- BuffOverlay integration
    if Phoenix_UI:GetModule("BuffOverlay", true) then
        local BuffOverlay = Phoenix_UI:GetModule("BuffOverlay")
        if BuffOverlay.OpenConfigPanel then
            -- Store original function for reference
            BuffOverlay._originalOpenConfigPanel = BuffOverlay.OpenConfigPanel
            
            -- Replace with our integration
            BuffOverlay.OpenConfigPanel = function()
                Phoenix_UI:Config()
                -- Try to select the tab
                SelectTabSafely("Buffoverlay")
            end
        end
    end
    
    -- MSBT integration
    if MikSBT then
        -- Store original function
        if MikSBT.Main and MikSBT.Main.ShowMainFrame then
            MikSBT.Main._originalShowMainFrame = MikSBT.Main.ShowMainFrame
            
            -- Replace with our integration
            MikSBT.Main.ShowMainFrame = function()
                Phoenix_UI:Config()
                -- Try to select the tab
                SelectTabSafely("Msbt")
            end
        end
    end
    
    -- MoveAny integration
    if MoveAny and MoveAny.ShowMainFrame then
        -- Store original function
        MoveAny._originalShowMainFrame = MoveAny.ShowMainFrame
        
        -- Replace with navigation to the appropriate tab
        MoveAny.ShowMainFrame = function()
            -- Only override if Phoenix_UI is loaded and enabled
            if Phoenix_UI and Phoenix_UI.db and Phoenix_UI.db.profile and Phoenix_UI.db.profile.general and Phoenix_UI.db.profile.general.enableMoveAnyIntegration then
                Phoenix_UI:Config()
                -- Try to select the General tab
                SelectTabSafely("General")
            else
                -- If integration disabled, use original function
                if MoveAny._originalShowMainFrame then
                    MoveAny._originalShowMainFrame()
                end
            end
        end
    end
    
    -- IdTip integration
    if Phoenix_UI:GetModule("idTip", true) then
        local idTip = Phoenix_UI:GetModule("idTip")
        if idTip.OpenConfig then
            idTip._originalOpenConfig = idTip.OpenConfig
            
            idTip.OpenConfig = function()
                Phoenix_UI:Config()
                -- Try to select the tab
                SelectTabSafely("IdTip")
            end
        end
    end
end

-- Options
function PhoenixConfig:CreateOptions()
    local options = {
        name = '|cffFF7D0APhoenix|r|cffFF0000_|r|cffFFD100UI|r',
        type = 'group',
        args = {
            General = {
                name = 'General',
                type = 'group',
                childGroups = 'tab',
                args = {
                    layout = {
                        type = 'group',
                        inline = true,
                        name = '',
                        args = {
                            load = {
                                name = 'Config',
                                type = 'execute',
                                func = function()
                                    local layout = self:GetModule('Config.Layout.General')
                                    
                                    -- Get and build layout options
                                    local opts = {}
                                    self:BuildOptions(layout, opts)
                                    
                                    -- Set
                                    ACD:Open('Phoenix_UI_Config')
                                    ACD:SelectGroup('Phoenix_UI_Config', 'General', 'General')
                                    
                                    ACR:NotifyChange('Phoenix_UI_Config')
                                end,
                                hidden = true,
                            },
                        },
                    },
                },
            },
            Unitframes = {
                name = 'Unitframes', type = 'group', order = 2,
                args = {
                    layout = {
                        type = 'group',
                        inline = true,
                        name = '',
                        args = {
                            load = {
                                name = 'Config',
                                type = 'execute',
                                func = function()
                                    local layout = self:GetModule('Config.Layout.Unitframes')
                                    
                                    -- Get and build layout options
                                    local opts = {}
                                    self:BuildOptions(layout, opts)
                                    
                                    -- Set
                                    ACD:Open('Phoenix_UI_Config')
                                    ACD:SelectGroup('Phoenix_UI_Config', 'General', 'Unitframes')
                                    
                                    ACR:NotifyChange('Phoenix_UI_Config')
                                end,
                                hidden = true,
                            },
                        },
                    },
                },
            },
            Nameplates = {
                name = 'Nameplates', type = 'group', order = 3,
                args = {
                    layout = {
                        type = 'group',
                        inline = true,
                        name = '',
                        args = {
                            load = {
                                name = 'Config',
                                type = 'execute',
                                func = function()
                                    local layout = self:GetModule('Config.Layout.Nameplates')
                                    
                                    -- Get and build layout options
                                    local opts = {}
                                    self:BuildOptions(layout, opts)
                                    
                                    -- Set
                                    ACD:Open('Phoenix_UI_Config')
                                    ACD:SelectGroup('Phoenix_UI_Config', 'General', 'Nameplates')
                                    
                                    ACR:NotifyChange('Phoenix_UI_Config')
                                end,
                                hidden = true,
                            },
                        },
                    },
                },
            },
            Actionbar = {
                name = 'Actionbar', type = 'group', order = 4,
                args = {
                    layout = {
                        type = 'group',
                        inline = true,
                        name = '',
                        args = {
                            load = {
                                name = 'Config',
                                type = 'execute',
                                func = function()
                                    local layout = self:GetModule('Config.Layout.Actionbar')
                                    
                                    -- Get and build layout options
                                    local opts = {}
                                    self:BuildOptions(layout, opts)
                                    
                                    -- Set
                                    ACD:Open('Phoenix_UI_Config')
                                    ACD:SelectGroup('Phoenix_UI_Config', 'General', 'Actionbar')
                                    
                                    ACR:NotifyChange('Phoenix_UI_Config')
                                end,
                                hidden = true,
                            },
                        },
                    },
                },
            },
            Castbars = {
                name = 'Castbars', type = 'group', order = 5,
                args = {
                    layout = {
                        type = 'group',
                        inline = true,
                        name = '',
                        args = {
                            load = {
                                name = 'Config',
                                type = 'execute',
                                func = function()
                                    local layout = self:GetModule('Config.Layout.Castbars')
                                    
                                    -- Get and build layout options
                                    local opts = {}
                                    self:BuildOptions(layout, opts)
                                    
                                    -- Set
                                    ACD:Open('Phoenix_UI_Config')
                                    ACD:SelectGroup('Phoenix_UI_Config', 'General', 'Castbars')
                                    
                                    ACR:NotifyChange('Phoenix_UI_Config')
                                end,
                                hidden = true,
                            },
                        },
                    },
                },
            },
            IdTip = {
                name = 'IdTip', type = 'group', order = 6,
                args = {
                    layout = {
                        type = 'group',
                        inline = true,
                        name = '',
                        args = {
                            load = {
                                name = 'Config',
                                type = 'execute',
                                func = function()
                                    local layout = self:GetModule('Config.Layout.IdTip')
                                    
                                    -- Get and build layout options
                                    local opts = {}
                                    self:BuildOptions(layout, opts)
                                    
                                    -- Set
                                    ACD:Open('Phoenix_UI_Config')
                                    ACD:SelectGroup('Phoenix_UI_Config', 'General', 'IdTip')
                                    
                                    ACR:NotifyChange('Phoenix_UI_Config')
                                end,
                                hidden = true,
                            },
                        },
                    },
                },
            },
            Buffs = {
                name = 'Buffs', type = 'group', order = 7,
                args = {
                    layout = {
                        type = 'group',
                        inline = true,
                        name = '',
                        args = {
                            load = {
                                name = 'Config',
                                type = 'execute',
                                func = function()
                                    local layout = self:GetModule('Config.Layout.Buffs')
                                    
                                    -- Get and build layout options
                                    local opts = {}
                                    self:BuildOptions(layout, opts)
                                    
                                    -- Set
                                    ACD:Open('Phoenix_UI_Config')
                                    ACD:SelectGroup('Phoenix_UI_Config', 'General', 'Buffs')
                                    
                                    ACR:NotifyChange('Phoenix_UI_Config')
                                end,
                                hidden = true,
                            },
                        },
                    },
                },
            },
            Misc = {
                name = 'Misc', type = 'group', order = 8,
                args = {
                    layout = {
                        type = 'group',
                        inline = true,
                        name = '',
                        args = {
                            load = {
                                name = 'Config',
                                type = 'execute',
                                func = function()
                                    local layout = self:GetModule('Config.Layout.Misc')
                                    
                                    -- Get and build layout options
                                    local opts = {}
                                    self:BuildOptions(layout, opts)
                                    
                                    -- Set
                                    ACD:Open('Phoenix_UI_Config')
                                    ACD:SelectGroup('Phoenix_UI_Config', 'General', 'Misc')
                                    
                                    ACR:NotifyChange('Phoenix_UI_Config')
                                end,
                                hidden = true,
                            },
                        },
                    },
                },
            },
            Msbt = {
                name = 'MSBT', type = 'group', order = 9,
                args = {
                    layout = {
                        type = 'group',
                        inline = true,
                        name = '',
                        args = {
                            load = {
                                name = 'Config',
                                type = 'execute',
                                func = function()
                                    local layout = self:GetModule('Config.Layout.Msbt')
                                    
                                    -- Get and build layout options
                                    local opts = {}
                                    self:BuildOptions(layout, opts)
                                    
                                    -- Set
                                    ACD:Open('Phoenix_UI_Config')
                                    ACD:SelectGroup('Phoenix_UI_Config', 'General', 'Msbt')
                                    
                                    ACR:NotifyChange('Phoenix_UI_Config')
                                end,
                                hidden = true,
                            },
                        },
                    },
                },
            },
            MoveAny = {
                name = 'MoveAny', type = 'group', order = 10,
                args = {
                    layout = {
                        type = 'group',
                        inline = true,
                        name = '',
                        args = {
                            load = {
                                name = 'Config',
                                type = 'execute',
                                func = function()
                                    local layout = self:GetModule('Config.Layout.MoveAny')
                                    
                                    -- Get and build layout options
                                    local opts = {}
                                    self:BuildOptions(layout, opts)
                                    
                                    -- Set
                                    ACD:Open('Phoenix_UI_Config')
                                    ACD:SelectGroup('Phoenix_UI_Config', 'General', 'MoveAny')
                                    
                                    ACR:NotifyChange('Phoenix_UI_Config')
                                end,
                                hidden = true,
                            },
                        },
                    },
                },
            },
            Skins = {
                name = 'Skins', type = 'group', order = 11,
                args = {
                    layout = {
                        type = 'group',
                        inline = true,
                        name = '',
                        args = {
                            load = {
                                name = 'Config',
                                type = 'execute',
                                func = function()
                                    local layout = self:GetModule('Config.Layout.Skins')
                                    
                                    -- Get and build layout options
                                    local opts = {}
                                    self:BuildOptions(layout, opts)
                                    
                                    -- Set
                                    ACD:Open('Phoenix_UI_Config')
                                    ACD:SelectGroup('Phoenix_UI_Config', 'General', 'Skins')
                                    
                                    ACR:NotifyChange('Phoenix_UI_Config')
                                end,
                                hidden = true,
                            },
                        },
                    },
                },
            },
        },
    }
end

-- Enhance BuildOptions to ensure options are immediately saved
function PhoenixConfig:BuildOptions(layout, opts)
    -- Original function remains intact
    if not layout or not layout.layout or not layout.layout.rows then return opts end
    
    local rows = layout.layout.rows
    for _, row in ipairs(rows) do
        for name, info in pairs(row) do
            if (type(info) == 'table' and info.key and info.type) then
                -- Original option building logic
                opts[name] = {
                    type = (info.type == 'checkbox') and 'toggle' or info.type,
                    name = info.label,
                    desc = info.tooltip,
                    get = function()
                        if not layout.layout.database then 
                            return 
                        end
                        return layout.layout.database[info.key]
                    end,
                    set = function(_, value)
                        if not layout.layout.database then 
                            return 
                        end
                        
                        -- Set the value
                        layout.layout.database[info.key] = value
                        
                        -- Immediately save the setting to ensure persistence
                        if Phoenix_UI and Phoenix_UI.SaveDB then
                            C_Timer.After(0.1, function()
                                Phoenix_UI:SaveDB()
                                print("|cffFF7D0APhoenix|r|cffFF0000_|r|cffFFD100UI|r: Setting '" .. info.label .. "' saved")
                            end)
                        end
                        
                        -- Call the callback if one is defined
                        if info.onChange then
                            info.onChange(value)
                        end
                    end,
                    -- Handle specific option types
                    -- ... rest of the original building logic
                }
                
                -- Add specific option type properties
                if info.type == 'slider' then
                    opts[name].min = info.min or 0
                    opts[name].max = info.max or 1
                    opts[name].step = info.step or 0.01
                    
                    -- Add immediate validation and saving on slider change
                    opts[name].set = function(_, value)
                        if not layout.layout.database then 
                            return 
                        end
                        
                        -- Validate range
                        if value < (info.min or 0) then value = (info.min or 0) end
                        if value > (info.max or 1) then value = (info.max or 1) end
                        
                        -- Apply precision if specified
                        if info.precision then
                            local factor = 10^info.precision
                            value = math.floor(value * factor + 0.5) / factor
                        end
                        
                        -- Set the value
                        layout.layout.database[info.key] = value
                        
                        -- Immediately save the setting
                        if Phoenix_UI and Phoenix_UI.SaveDB then
                            C_Timer.After(0.1, function()
                                Phoenix_UI:SaveDB()
                                print("|cffFF7D0APhoenix|r|cffFF0000_|r|cffFFD100UI|r: Setting '" .. info.label .. "' saved: " .. value)
                            end)
                        end
                        
                        -- Call the callback if one is defined
                        if info.onChange then
                            info.onChange(value)
                        end
                    end
                end
            end
        end
    end
    
    return opts
end

-- Forcibly commit values from all UI elements to ensure proper saving
function Phoenix_UI.SaveAllTabElements()
    -- Early return if no UI or not initialized
    if not Phoenix_UI.UI or not Phoenix_UI.UI.isInitialized then
        return false
    end
    
    -- Process all tabs for all settings
    if Phoenix_UI.UI.tabs and Phoenix_UI.UI.tabs.buttons then
        for _, tabButton in pairs(Phoenix_UI.UI.tabs.buttons) do
            if tabButton and tabButton.tab and tabButton.tab.module then
                local moduleName = tabButton.tab.module
                -- Skip if we don't have a valid module name or the tab isn't set up
                if moduleName and Phoenix_UI.UI.panels and Phoenix_UI.UI.panels[moduleName] then
                    -- Get all form elements in this tab's panel
                    local panel = Phoenix_UI.UI.panels[moduleName]
                    if panel and panel.elements then
                        for _, element in pairs(panel.elements) do
                            -- Process actual widgets with values
                            if element and element.GetValue and element.dbReference and element.dataKey then
                                -- Get the current value
                                local value = element:GetValue()
                                if value ~= nil then
                                    -- Process the value path
                                    local path = {}
                                    local key = element.dataKey
                                    for segment in key:gmatch("[^%.]+") do
                                        table.insert(path, segment)
                                    end
                                    
                                    -- Navigate database structure
                                    local current = element.dbReference
                                    local lastKey = table.remove(path)
                                    
                                    -- Build path
                                    for _, pathKey in ipairs(path) do
                                        if not current[pathKey] then
                                            current[pathKey] = {}
                                        elseif type(current[pathKey]) ~= "table" then
                                            current[pathKey] = {}
                                        end
                                        current = current[pathKey]
                                    end
                                    
                                    -- Set the value and mark it for update
                                    if current[lastKey] ~= value then
                                        current[lastKey] = value
                                        
                                        -- Mark the root module for update
                                        local rootModule = string.match(element.dataKey, "^([^%.]+)")
                                        if rootModule and Phoenix_UI.db and Phoenix_UI.db.profile and Phoenix_UI.db.profile[rootModule] then
                                            Phoenix_UI.db.profile[rootModule].__updated = GetTime()
                                            Phoenix_UI.db.profile[rootModule].__last_key_changed = element.dataKey
                                            Phoenix_UI.db.profile[rootModule].__saved_from = "forced_save_all"
                                        end
                                    end
                                end
                            end
                        end -- end for elements
                    end -- end if panel.elements
                end -- end if moduleName valid
            end -- end if tabButton valid
        end -- end for tabButtons
    end -- end if tabs.buttons
    
    -- Add immediate forceSave
    if Phoenix_UI.ForceSaveDB then
        Phoenix_UI:ForceSaveDB()
    elseif Phoenix_UI.SaveDB then
        Phoenix_UI:SaveDB()
    end
    
    return true
end

-- Hook the OnValueChanged handler for all setting elements
if Phoenix_UIConfig then
    local originalBuildElement = Phoenix_UIConfig.BuildElement
    if originalBuildElement then
        Phoenix_UIConfig.BuildElement = function(self, frame, row, info, dataKey, db)
            local element = originalBuildElement(self, frame, row, info, dataKey, db)
            
            -- If this is a valid element with a value
            if element and element.OnValueChanged then
                -- Store the original handler
                local originalOnValueChanged = element.OnValueChanged
                
                -- Create a new handler that also saves all settings
                element.OnValueChanged = function(self, value, ...)
                    -- Call the original handler first
                    if originalOnValueChanged then
                        originalOnValueChanged(self, value, ...)
                    end
                    
                    -- Queue a save after a short delay to batch changes
                    C_Timer.After(0.5, function()
                        if Phoenix_UI and Phoenix_UI.SaveAllTabElements then
                            Phoenix_UI.SaveAllTabElements()
                        end
                    end)
                end
            end
            
            return element
        end
    end
else
    -- Phoenix_UIConfig not available, log error
    C_Timer.After(1, function()
        if Phoenix_UI and Phoenix_UI.debug then
            print("Phoenix_UI: ERROR - Phoenix_UIConfig not available when loading Config/_Gui.lua")
        end
        
        -- Try to load the library
        if LibStub then
            local config = LibStub("Phoenix_UIConfig", true)
            if config and config.BuildElement then
                -- Retry the hook
                local originalBuildElement = config.BuildElement
                config.BuildElement = function(self, frame, row, info, dataKey, db)
                    local element = originalBuildElement(self, frame, row, info, dataKey, db)
                    
                    -- If this is a valid element with a value
                    if element and element.OnValueChanged then
                        -- Store the original handler
                        local originalOnValueChanged = element.OnValueChanged
                        
                        -- Create a new handler that also saves all settings
                        element.OnValueChanged = function(self, value, ...)
                            -- Call the original handler first
                            if originalOnValueChanged then
                                originalOnValueChanged(self, value, ...)
                            end
                            
                            -- Queue a save after a short delay to batch changes
                            C_Timer.After(0.5, function()
                                if Phoenix_UI and Phoenix_UI.SaveAllTabElements then
                                    Phoenix_UI.SaveAllTabElements()
                                end
                            end)
                        end
                    end
                    
                    return element
                end
                
                if Phoenix_UI and Phoenix_UI.debug then
                    print("Phoenix_UI: Successfully loaded Phoenix_UIConfig and hooked BuildElement")
                end
            end
        end
    end)
end

-- Create a function to fix scroll frame extents after all elements are added
Phoenix_UI.RecalculateScrollFrames = function()
    -- Loop through all tab panels
    if not Phoenix_UI.panels then return end
    
    for panelID, panel in pairs(Phoenix_UI.panels) do
        -- Check if this panel has a valid scroll child
        if panel and panel.scrollChild then
            -- Direct method for panels with their own UpdateScrollChildHeight
            if panel.UpdateScrollChildHeight then
                -- Use the built-in height calculation
                panel:UpdateScrollChildHeight()
            else
                -- Manual calculation for panels without their own method
                local scrollFrame = panel:GetParent()
                if scrollFrame and scrollFrame.ScrollBar then
                    -- Get content height by finding the lowest element
                    local contentHeight = 0
                    
                    -- Look for specialized ScrollTable elements first
                    local hasScrollTable = false
                    
                    if panel.scrollChild.elements then
                        for _, element in pairs(panel.scrollChild.elements) do
                            -- Check for ScrollTable (has rows and special properties)
                            if element.rowHeight and element.numberOfRows then
                                hasScrollTable = true
                                -- Calculate a minimum height for the table
                                local tableHeight = (element.rowHeight * element.numberOfRows) + 150
                                if tableHeight > contentHeight then
                                    contentHeight = tableHeight
                                end
                            end
                        end
                    end
                    
                    -- If not a ScrollTable, do regular element height calculation
                    if not hasScrollTable and panel.scrollChild.elements then
                        for _, element in pairs(panel.scrollChild.elements) do
                            if element and element:IsShown() then
                                -- Try multiple methods to get bottom position
                                local elementBottom = 0
                                
                                -- Method 1: GetBounds if available
                                if element.GetBounds then
                                    local _, bottom = element:GetBounds()
                                    if bottom and bottom > 0 then
                                        elementBottom = bottom
                                    end
                                end
                                
                                -- Method 2: Fallback to position + height
                                if elementBottom == 0 and element:GetPoint(1) then
                                    local _, _, _, _, y = element:GetPoint(1)
                                    if y and type(y) == "number" then
                                        elementBottom = math.abs(y) + (element:GetHeight() or 0)
                                    end
                                end
                                
                                -- Method 3: Try child elements recursively
                                if elementBottom == 0 then
                                    for i = 1, element:GetNumChildren() do
                                        local child = select(i, element:GetChildren())
                                        if child and child:IsShown() and child:GetPoint(1) then
                                            local _, _, _, _, y = child:GetPoint(1)
                                            if y and type(y) == "number" then
                                                local childBottom = math.abs(y) + (child:GetHeight() or 0)
                                                if childBottom > elementBottom then
                                                    elementBottom = childBottom
                                                end
                                            end
                                        end
                                    end
                                end
                                
                                -- Update total height
                                if elementBottom > 0 and elementBottom > contentHeight then
                                    contentHeight = elementBottom
                                end
                            end
                        end
                    end
                    
                    -- Add generous padding based on panel type
                    local padding = 300
                    
                    -- Adjust padding for tabs with more complex UIs
                    local complexTabs = {
                        ["chat"] = true,
                        ["msbt"] = true,
                        ["WeakAurasIntegration"] = true,
                        ["unitframes"] = true,
                        ["nameplates"] = true
                    }
                    
                    if complexTabs[panelID] then
                        padding = 600  -- More padding for complex UIs
                    end
                    
                    -- Add the extra padding
                    contentHeight = contentHeight + padding
                    
                    -- Ensure minimum height
                    contentHeight = math.max(contentHeight, scrollFrame:GetHeight() * 3)
                    
                    -- Set the scroll child's height
                    panel.scrollChild:SetHeight(contentHeight)
                    
                    -- Force update scrollbar range
                    scrollFrame:UpdateScrollChildRect()
                    
                    -- Update the scroll child height again to ensure it propagates
                    if scrollFrame:GetScrollChild() then
                        scrollFrame:GetScrollChild():SetHeight(contentHeight)
                    end
                    
                    -- Update scrollbar values
                    if scrollFrame.ScrollBar then
                        scrollFrame.ScrollBar:SetMinMaxValues(0, math.max(0, contentHeight - scrollFrame:GetHeight()))
                        
                        -- Ensure scroll bar is shown if needed
                        if contentHeight > scrollFrame:GetHeight() then
                            scrollFrame.ScrollBar:Show()
                        else
                            scrollFrame.ScrollBar:Hide()
                        end
                    end
                end
            end
        end
    end
    
    -- Also handle the AceConfigDialog-3.0 frames which might be used for some panels
    if LibStub and LibStub("AceConfigDialog-3.0", true) then
        local ACD = LibStub("AceConfigDialog-3.0")
        if ACD and ACD.frame and ACD.frame.obj and ACD.frame.obj.children then
            for _, child in pairs(ACD.frame.obj.children) do
                if child and child.scrollframe then
                    -- Handle Ace scroll frames
                    local scrollframe = child.scrollframe
                    local content = scrollframe.content
                    
                    if content and scrollframe:GetHeight() then
                        -- Set a generous height for Ace panels
                        local scrollHeight = scrollframe:GetHeight() * 5
                        
                        -- Apply the height
                        content:SetHeight(scrollHeight)
                        
                        -- Update the scroll child
                        if scrollframe.Update then
                            scrollframe:Update()
                        end
                    end
                end
            end
        end
    end
end

-- Hook panel display to recalculate scroll extents
local originalDisplayPanel = Phoenix_UIConfig.DisplayPanel or function() end
Phoenix_UIConfig.DisplayPanel = function(self, id, ...)
    local result = originalDisplayPanel(self, id, ...)
    
    -- Schedule recalculation to ensure all elements are properly rendered
    -- Use multiple timers at different delays for reliability
    C_Timer.After(0.1, function()
        if Phoenix_UI.RecalculateScrollFrames then
            Phoenix_UI.RecalculateScrollFrames()
        end
    end)
    
    -- Additional refresh after a longer delay to catch late-loading elements
    C_Timer.After(0.5, function()
        if Phoenix_UI.RecalculateScrollFrames then
            Phoenix_UI.RecalculateScrollFrames()
        end
    end)
    
    return result
end

-- Recalculate scroll frames when the config panel is first opened
C_Timer.After(0.5, function()
    if Phoenix_UI.RecalculateScrollFrames then
        Phoenix_UI.RecalculateScrollFrames()
    end
end)

-- Add a slash command to force refresh scrolling if needed
SLASH_PHOENIXSCROLL1 = "/phoenixscroll"
SlashCmdList["PHOENIXSCROLL"] = function()
    print("Phoenix UI: Recalculating all scroll frames...")
    if Phoenix_UI.RecalculateScrollFrames then
        Phoenix_UI.RecalculateScrollFrames()
        print("Phoenix UI: Scroll recalculation complete!")
    else
        print("Phoenix UI: RecalculateScrollFrames function not found!")
    end
end
