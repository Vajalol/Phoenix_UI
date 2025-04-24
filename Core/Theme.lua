local Phoenix_UI = LibStub("AceAddon-3.0"):GetAddon("Phoenix_UI")
local LSM = LibStub("LibSharedMedia-3.0")

-- Initialize themes table
Phoenix_UI.themes = Phoenix_UI.themes or {
    Default = {
        name = "Default",
        description = "Default Phoenix UI theme",
        colors = {
            primary = {r = 0.9, g = 0.4, b = 0.13},  -- Fiery orange
            secondary = {r = 0.7, g = 0.3, b = 0.1}, -- Dark orange
            background = {r = 0.15, g = 0.15, b = 0.15},
            border = {r = 0.3, g = 0.3, b = 0.3},
            text = {r = 1, g = 1, b = 1},
            highlight = {r = 1, g = 0.6, b = 0.2}
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
    },
    PhoenixFlame = {
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
            title = "Interface\\AddOns\\Phoenix_UI\\Media\\Fonts\\PTSansNarrow.ttf",
            normal = "Interface\\AddOns\\Phoenix_UI\\Media\\Fonts\\PTSansNarrow.ttf",
            header = "Interface\\AddOns\\Phoenix_UI\\Media\\Fonts\\PTSansNarrow.ttf",
        },
        textures = {
            -- Use the custom textures from phoenix_flame_theme
            button = "Interface\\AddOns\\Phoenix_UI\\Core\\phoenix_flame_theme\\textures\\button.tga",
            buttonHighlight = "Interface\\AddOns\\Phoenix_UI\\Core\\phoenix_flame_theme\\textures\\hover.tga",
            buttonPressed = "Interface\\AddOns\\Phoenix_UI\\Core\\phoenix_flame_theme\\textures\\pressed.tga",
            buttonDisabled = "Interface\\AddOns\\Phoenix_UI\\Core\\phoenix_flame_theme\\textures\\disabled.tga",
            
            -- Backgrounds
            background = "Interface\\AddOns\\Phoenix_UI\\Core\\phoenix_flame_theme\\textures\\background.tga",
            backgroundAlt = "Interface\\AddOns\\Phoenix_UI\\Core\\phoenix_flame_theme\\textures\\background-light.tga",
            backgroundDark = "Interface\\AddOns\\Phoenix_UI\\Core\\phoenix_flame_theme\\textures\\background-dark.tga",
            
            -- Borders and effects
            border = "Interface\\AddOns\\Phoenix_UI\\Core\\phoenix_flame_theme\\textures\\border.tga",
            glow = "Interface\\AddOns\\Phoenix_UI\\Core\\phoenix_flame_theme\\textures\\glow.tga",
            
            -- Tabs
            tabSelected = "Interface\\AddOns\\Phoenix_UI\\Core\\phoenix_flame_theme\\textures\\tab.tga", 
            tabDeselected = "Interface\\AddOns\\Phoenix_UI\\Core\\phoenix_flame_theme\\textures\\tab.tga",
            
            -- Effects
            flame = "Interface\\AddOns\\Phoenix_UI\\Core\\phoenix_flame_theme\\textures\\flame.tga",
            ember = "Interface\\AddOns\\Phoenix_UI\\Core\\phoenix_flame_theme\\textures\\embers.tga",
            ash = "Interface\\AddOns\\Phoenix_UI\\Core\\phoenix_flame_theme\\textures\\ash.tga",
            smoke = "Interface\\AddOns\\Phoenix_UI\\Core\\phoenix_flame_theme\\textures\\smoke.tga",
            
            -- Specialized UI elements
            tooltip = "Interface\\AddOns\\Phoenix_UI\\Core\\phoenix_flame_theme\\textures\\tooltip.tga",
            chatframe = "Interface\\AddOns\\Phoenix_UI\\Core\\phoenix_flame_theme\\textures\\chatframe.tga",
            slider = "Interface\\AddOns\\Phoenix_UI\\Core\\phoenix_flame_theme\\textures\\slider.tga",
            dropdown = "Interface\\AddOns\\Phoenix_UI\\Core\\phoenix_flame_theme\\textures\\dropdown.tga",
            statusbar = "Interface\\AddOns\\Phoenix_UI\\Core\\phoenix_flame_theme\\textures\\statusbar.tga",
            
            -- Animation frames for flame effect
            flameAnim = {
                "Interface\\AddOns\\Phoenix_UI\\Core\\phoenix_flame_theme\\textures\\animation\\flame1.tga",
                "Interface\\AddOns\\Phoenix_UI\\Core\\phoenix_flame_theme\\textures\\animation\\flame2.tga",
                "Interface\\AddOns\\Phoenix_UI\\Core\\phoenix_flame_theme\\textures\\animation\\flame3.tga",
                "Interface\\AddOns\\Phoenix_UI\\Core\\phoenix_flame_theme\\textures\\animation\\flame4.tga"
            }
        },
        effects = {
            enableGlow = true,         -- Enable glow effects
            enableAnimations = true,   -- Enable subtle animations
            useGradients = true,       -- Use color gradients 
            borderGlowStrength = 0.7,  -- Strength of border glow (0-1)
            buttonGlowStrength = 0.5,  -- Strength of button glow (0-1)
            animationSpeed = 1.0,      -- Animation speed multiplier
            useCustomEffects = true    -- Use the custom phoenix flame textures
        }
    }
}

-- Register a theme
function Phoenix_UI:RegisterTheme(name, themeData)
    if not name or type(name) ~= "string" then
        Phoenix_UI:Debug("Theme registration failed: Theme name must be a string")
        return false
    end
    
    if not themeData or type(themeData) ~= "table" then
        Phoenix_UI:Debug("Theme registration failed: Theme data must be a table")
        return false
    end
    
    -- Ensure required theme properties
    themeData.name = themeData.name or name
    themeData.description = themeData.description or (name .. " theme")
    
    -- Ensure color tables exist
    themeData.colors = themeData.colors or {}
    themeData.colors.primary = themeData.colors.primary or {r = 0.9, g = 0.4, b = 0.13}
    themeData.colors.secondary = themeData.colors.secondary or {r = 0.7, g = 0.3, b = 0.1}
    themeData.colors.background = themeData.colors.background or {r = 0.15, g = 0.15, b = 0.15}
    themeData.colors.border = themeData.colors.border or {r = 0.3, g = 0.3, b = 0.3}
    themeData.colors.text = themeData.colors.text or {r = 1, g = 1, b = 1}
    themeData.colors.highlight = themeData.colors.highlight or {r = 1, g = 0.6, b = 0.2}

    -- Ensure fonts exist
    themeData.fonts = themeData.fonts or {}
    themeData.fonts.title = themeData.fonts.title or "Friz Quadrata TT"
    themeData.fonts.normal = themeData.fonts.normal or "Friz Quadrata TT"
    themeData.fonts.header = themeData.fonts.header or "Friz Quadrata TT"
    
    -- Ensure textures exist
    themeData.textures = themeData.textures or {}
    themeData.textures.button = themeData.textures.button or "Interface\\Buttons\\UI-Panel-Button-Up"
    themeData.textures.buttonHighlight = themeData.textures.buttonHighlight or "Interface\\Buttons\\UI-Panel-Button-Highlight"
    themeData.textures.background = themeData.textures.background or "Interface\\DialogFrame\\UI-DialogBox-Background"
    themeData.textures.border = themeData.textures.border or "Interface\\DialogFrame\\UI-DialogBox-Border"
    themeData.textures.tabSelected = themeData.textures.tabSelected or "Interface\\OptionsFrame\\UI-OptionsFrame-ActiveTab"
    themeData.textures.tabDeselected = themeData.textures.tabDeselected or "Interface\\OptionsFrame\\UI-OptionsFrame-InActiveTab"
    
    -- Add theme to themes table
    Phoenix_UI.themes[name] = themeData
    Phoenix_UI:Debug("Theme registered: " .. name)
    
    return true
end

-- Register default theme
function Phoenix_UI:RegisterDefaultTheme()
    -- The Default theme is already initialized above, no need to register it again
    -- But we might register other built-in themes here in the future
    
    -- Ensure theme setting exists in database
    if not Phoenix_UI.db.profile.General then
        Phoenix_UI.db.profile.General = {}
    end
    
    if not Phoenix_UI.db.profile.General.theme then
        Phoenix_UI.db.profile.General.theme = "PhoenixFlame"
    end
    
    Phoenix_UI:Debug("Default theme registered")
    return true
end

-- Apply a theme to UI elements
function Phoenix_UI:ApplyTheme(themeName)
    themeName = themeName or (Phoenix_UI.db.profile.General and Phoenix_UI.db.profile.General.theme) or "Default"
    
    local theme = Phoenix_UI.themes[themeName]
    if not theme then
        if Phoenix_UI.Debug then
            Phoenix_UI:Debug("Theme not found: " .. themeName .. ", falling back to Default")
        end
        theme = Phoenix_UI.themes["Default"]
        themeName = "Default"
    end
    
    if Phoenix_UI.Debug then
        Phoenix_UI:Debug("Applying theme: " .. themeName)
    end
    
    -- Store current theme
    Phoenix_UI.currentTheme = themeName
    
    -- Save theme selection to profile
    if Phoenix_UI.db and Phoenix_UI.db.profile then
        if not Phoenix_UI.db.profile.General then
            Phoenix_UI.db.profile.General = {}
        end
        Phoenix_UI.db.profile.General.theme = themeName
        
        -- Make sure to save the setting to the database
        if Phoenix_UI.SaveDB then
            Phoenix_UI:SaveDB()
        end
    end
    
    -- Apply theme to UI elements
    
    -- First, apply to config UI
    if Phoenix_UI.UI then
        if Phoenix_UI.ApplyThemeToConfigUI then
            Phoenix_UI:ApplyThemeToConfigUI(theme)
        else
            -- Direct application if the helper function isn't available
            local config = Phoenix_UI.UI
            
            -- Apply theme to main panel
            if config.backdrop then
                config:SetBackdropColor(theme.colors.background.r, theme.colors.background.g, theme.colors.background.b, 0.9)
                config:SetBackdropBorderColor(theme.colors.border.r, theme.colors.border.g, theme.colors.border.b)
            end
            
            -- Apply to title panel if it exists
            if config.titlePanel then
                if config.titlePanel.SetBackdropColor then
                    config.titlePanel:SetBackdropColor(theme.colors.secondary.r, theme.colors.secondary.g, theme.colors.secondary.b, 0.8)
                    config.titlePanel:SetBackdropBorderColor(theme.colors.border.r, theme.colors.border.g, theme.colors.border.b)
                end
            end
            
            -- Apply to tabs if they exist
            if config.tabs and config.tabs.buttons and type(config.tabs.buttons) == "table" then
                for _, button in ipairs(config.tabs.buttons) do
                    if button and not button.isHeader then
                        -- Apply theme to regular tab buttons
                        if button.selected then
                            -- Selected tab - make it stand out
                            if button.highlight then
                                button.highlight:SetColorTexture(
                                    theme.colors.primary.r, 
                                    theme.colors.primary.g, 
                                    theme.colors.primary.b, 
                                    0.6
                                )
                                button.highlight:SetAlpha(0.6)
                            end
                            
                            -- Update text color 
                            if button.text then
                                button.text:SetTextColor(
                                    theme.colors.highlight.r,
                                    theme.colors.highlight.g,
                                    theme.colors.highlight.b
                                )
                            end
                            
                            -- Update icon color
                            if button.icon then
                                button.icon:SetVertexColor(
                                    theme.colors.highlight.r,
                                    theme.colors.highlight.g,
                                    theme.colors.highlight.b
                                )
                            end
                            
                            -- Update selection indicator
                            if button.selectionIndicator then
                                button.selectionIndicator:SetColorTexture(
                                    theme.colors.primary.r,
                                    theme.colors.primary.g,
                                    theme.colors.primary.b
                                )
                            end
                        else
                            -- Unselected tab - more subtle appearance
                            if button.highlight then
                                button.highlight:SetAlpha(0)
                            end
                            
                            if button.text then
                                button.text:SetTextColor(
                                    theme.colors.text.r,
                                    theme.colors.text.g,
                                    theme.colors.text.b
                                )
                            end
                            
                            if button.icon then
                                button.icon:SetVertexColor(
                                    theme.colors.text.r,
                                    theme.colors.text.g,
                                    theme.colors.text.b
                                )
                            end
                        end
                    else if button and button.isHeader and button.text then
                        -- Apply theme to header
                        button.text:SetTextColor(
                            theme.colors.primary.r,
                            theme.colors.primary.g,
                            theme.colors.primary.b
                        )
                    end
                    end
                end
            end
            
            -- Apply theme to content if it exists
            if config.tabs and config.tabs.container then
                if config.tabs.container.SetBackdropColor then
                    config.tabs.container:SetBackdropColor(
                        theme.colors.background.r, 
                        theme.colors.background.g, 
                        theme.colors.background.b, 
                        0.7
                    )
                    config.tabs.container:SetBackdropBorderColor(
                        theme.colors.border.r, 
                        theme.colors.border.g, 
                        theme.colors.border.b
                    )
                end
            end
        end
    end
    
    -- Apply theme to tab buttons if they exist (legacy config format)
    if Phoenix_UI.config and Phoenix_UI.config.tabs then
        for _, tab in pairs(Phoenix_UI.config.tabs) do
            if tab and tab.button then
                -- Update tab button appearance
                if tab.selected then
                    -- Selected tab
                    if tab.button.SetBackdropColor then
                        tab.button:SetBackdropColor(theme.colors.primary.r, theme.colors.primary.g, theme.colors.primary.b, 0.7)
                    end
                    
                    if tab.button.text then
                        tab.button.text:SetTextColor(theme.colors.text.r, theme.colors.text.g, theme.colors.text.b)
                    end
                    
                    if tab.button.texture then
                        tab.button.texture:SetTexture(theme.textures.tabSelected)
                    end
                else
                    -- Unselected tab
                    if tab.button.SetBackdropColor then
                        tab.button:SetBackdropColor(theme.colors.background.r, theme.colors.background.g, theme.colors.background.b, 0.7)
                    end
                    
                    if tab.button.text then
                        tab.button.text:SetTextColor(theme.colors.text.r * 0.8, theme.colors.text.g * 0.8, theme.colors.text.b * 0.8)
                    end
                    
                    if tab.button.texture then
                        tab.button.texture:SetTexture(theme.textures.tabDeselected)
                    end
                end
                
                -- Set border color
                if tab.button.SetBackdropBorderColor then
                    tab.button:SetBackdropBorderColor(theme.colors.border.r, theme.colors.border.g, theme.colors.border.b)
                end
            end
        end
    end
    
    -- Apply to config frame if it exists (legacy config format)
    if Phoenix_UI.config and Phoenix_UI.config.frame then
        local frame = Phoenix_UI.config.frame
        if frame.SetBackdropColor then
            frame:SetBackdropColor(theme.colors.background.r, theme.colors.background.g, theme.colors.background.b, 0.9)
            frame:SetBackdropBorderColor(theme.colors.border.r, theme.colors.border.g, theme.colors.border.b)
        end
        
        if frame.title then
            frame.title:SetTextColor(theme.colors.primary.r, theme.colors.primary.g, theme.colors.primary.b)
            if LSM then
                local fontPath = LSM:Fetch("font", theme.fonts.title) or theme.fonts.title
                frame.title:SetFont(fontPath, 16, "OUTLINE")
            else
                frame.title:SetFont(theme.fonts.title, 16, "OUTLINE")
            end
        end
    end
    
    -- Apply to content frame if it exists (legacy config format)
    if Phoenix_UI.config and Phoenix_UI.config.contentFrame then
        local contentFrame = Phoenix_UI.config.contentFrame
        if contentFrame.SetBackdropColor then
            contentFrame:SetBackdropColor(theme.colors.background.r, theme.colors.background.g, theme.colors.background.b, 0.7)
            contentFrame:SetBackdropBorderColor(theme.colors.border.r, theme.colors.border.g, theme.colors.border.b)
        end
    end
    
    -- Apply theme to modules that support it
    if Phoenix_UI.ApplyThemeToModules then
        Phoenix_UI:ApplyThemeToModules(theme)
    else
        -- Manual module theme application if helper function isn't available
        for name, module in Phoenix_UI:IterateModules() do
            if module.ApplyTheme and type(module.ApplyTheme) == "function" then
                module:ApplyTheme(theme)
            end
        end
    end
    
    -- Let modules know the theme changed
    Phoenix_UI:SendMessage("PHOENIX_UI_THEME_CHANGED", themeName, theme)
    
    return true
end

-- Enhanced function to apply themes to the config UI
function Phoenix_UI:ApplyThemeToConfigUI(theme)
    if not Phoenix_UI.UI then return false end
    
    local config = Phoenix_UI.UI
    local isPhoenixFlame = theme.name == "Phoenix Flame"
    
    -- Apply theme to main panel
    if config.SetBackdrop then
        -- Special handling for Phoenix Flame theme
        if isPhoenixFlame then
            config:SetBackdrop({
                bgFile = "Interface\\Buttons\\WHITE8X8", 
                edgeFile = theme.textures.border or "Interface\\AddOns\\Phoenix_UI\\Media\\Textures\\Border\\EmberBorder", 
                tile = true, tileSize = 16, edgeSize = 16, 
                insets = { left = 4, right = 4, top = 4, bottom = 4 }
            })
        end
        
        -- Apply colors
        config:SetBackdropColor(theme.colors.background.r, theme.colors.background.g, theme.colors.background.b, 0.9)
        config:SetBackdropBorderColor(theme.colors.border.r, theme.colors.border.g, theme.colors.border.b, 0.8)
    end
    
    -- Apply to title panel
    if config.titlePanel then
        -- Set the title panel backdrop for Phoenix Flame
        if isPhoenixFlame and config.titlePanel.SetBackdrop then
            config.titlePanel:SetBackdrop({
                bgFile = "Interface\\Buttons\\WHITE8X8", 
                edgeFile = theme.textures.border or "Interface\\AddOns\\Phoenix_UI\\Media\\Textures\\Border\\EmberBorder", 
                tile = true, tileSize = 16, edgeSize = 16, 
                insets = { left = 2, right = 2, top = 2, bottom = 2 }
            })
            
            -- Create a gradient for the title panel if it doesn't exist
            if not config.titlePanel.bg then
                config.titlePanel.bg = config.titlePanel:CreateTexture(nil, "BACKGROUND")
                config.titlePanel.bg:SetAllPoints()
                
                config.titlePanel.gradient = config.titlePanel:CreateTexture(nil, "BACKGROUND", nil, 1)
                config.titlePanel.gradient:SetAllPoints()
            end
            
            -- Set colors
            local r1, g1, b1 = theme.colors.secondary.r, theme.colors.secondary.g, theme.colors.secondary.b
            local r2, g2, b2 = theme.colors.darkShade.r, theme.colors.darkShade.g, theme.colors.darkShade.b
            
            config.titlePanel.bg:SetColorTexture(r1, g1, b1, 0.7)
            config.titlePanel.gradient:SetColorTexture(r2, g2, b2, 0.8)
            config.titlePanel.gradient:SetGradient("HORIZONTAL", 
                CreateColor(1, 1, 1, 0.1), 
                CreateColor(r2/r1, g2/g1, b2/b1, 0.9))
        else
            -- Standard theme application
            if config.titlePanel.SetBackdropColor then
                config.titlePanel:SetBackdropColor(
                    theme.colors.secondary.r, 
                    theme.colors.secondary.g, 
                    theme.colors.secondary.b, 
                    0.8
                )
                config.titlePanel:SetBackdropBorderColor(
                    theme.colors.border.r, 
                    theme.colors.border.g, 
                    theme.colors.border.b
                )
            end
        end
    end
    
    -- Apply to version text if it exists
    if config.version then
        config.version:SetTextColor(
            theme.colors.textHeader and theme.colors.textHeader.r or theme.colors.highlight.r,
            theme.colors.textHeader and theme.colors.textHeader.g or theme.colors.highlight.g,
            theme.colors.textHeader and theme.colors.textHeader.b or theme.colors.highlight.b
        )
        
        -- Apply text shadow effect for Phoenix Flame
        if isPhoenixFlame and not config.version.shadow then
            config.version.shadow = config.titlePanel:CreateFontString(nil, "BACKGROUND")
            config.version.shadow:SetPoint("LEFT", config.version, "LEFT", 1, -1)
            config.version.shadow:SetFont(config.version:GetFont())
            config.version.shadow:SetText(config.version:GetText())
        end
        
        if config.version.shadow then
            config.version.shadow:SetTextColor(0.2, 0.1, 0.05, 0.7)
        end
    end
    
    -- Apply to flame decorations for Phoenix Flame theme
    if isPhoenixFlame then
        -- Create ember particles if they don't exist
        if not config.emberTextures then
            local numEmbers = 3
            config.emberTextures = {}
            
            for i = 1, numEmbers do
                local ember = config:CreateTexture(nil, "ARTWORK", nil, 1)
                ember:SetSize(24, 24)
                ember:SetPoint("TOPLEFT", config, "TOPLEFT", 50 + (i * 120), -12)
                ember:SetTexture(theme.textures.ember or "Interface\\AddOns\\Phoenix_UI\\Media\\Textures\\Effects\\Ember")
                ember:SetBlendMode("ADD")
                ember:SetAlpha(0.6)
                
                -- Create animation
                local emberAnim = ember:CreateAnimationGroup()
                emberAnim:SetLooping("REPEAT")
                
                local scale1 = emberAnim:CreateAnimation("Scale")
                scale1:SetScale(1.1, 1.1)
                scale1:SetDuration(1.0 + (i * 0.2))
                scale1:SetSmoothing("IN_OUT")
                scale1:SetOrder(1)
                
                local scale2 = emberAnim:CreateAnimation("Scale")
                scale2:SetScale(1/1.1, 1/1.1)
                scale2:SetDuration(1.0 + (i * 0.2))
                scale2:SetSmoothing("IN_OUT")
                scale2:SetOrder(2)
                
                local alpha1 = emberAnim:CreateAnimation("Alpha")
                alpha1:SetFromAlpha(0.6)
                alpha1:SetToAlpha(0.3)
                alpha1:SetDuration(1.0 + (i * 0.2))
                alpha1:SetSmoothing("IN_OUT")
                alpha1:SetOrder(1)
                
                local alpha2 = emberAnim:CreateAnimation("Alpha")
                alpha2:SetFromAlpha(0.3)
                alpha2:SetToAlpha(0.6)
                alpha2:SetDuration(1.0 + (i * 0.2))
                alpha2:SetSmoothing("IN_OUT")
                alpha2:SetOrder(2)
                
                emberAnim:Play()
                
                config.emberTextures[i] = ember
            end
        end
        
        -- Add main flame decoration if it doesn't exist
        if not config.mainFlame then
            config.mainFlame = config.titlePanel:CreateTexture(nil, "ARTWORK")
            config.mainFlame:SetSize(42, 42)
            config.mainFlame:SetPoint("RIGHT", config.titlePanel, "RIGHT", -20, 0)
            config.mainFlame:SetTexture(theme.textures.flame or "Interface\\AddOns\\Phoenix_UI\\Media\\Textures\\Effects\\Flame")
            config.mainFlame:SetBlendMode("ADD")
            
            -- Create animation
            local flameAnimGroup = config.mainFlame:CreateAnimationGroup()
            flameAnimGroup:SetLooping("REPEAT")
            
            -- Complex animation sequence
            local flameScale1 = flameAnimGroup:CreateAnimation("Scale")
            flameScale1:SetScale(1.2, 1.2)
            flameScale1:SetDuration(0.7)
            flameScale1:SetSmoothing("IN")
            flameScale1:SetOrder(1)
            
            local flameScale2 = flameAnimGroup:CreateAnimation("Scale")
            flameScale2:SetScale(0.9, 0.9)
            flameScale2:SetDuration(0.5)
            flameScale2:SetSmoothing("OUT")
            flameScale2:SetOrder(2)
            
            local flameScale3 = flameAnimGroup:CreateAnimation("Scale")
            flameScale3:SetScale(1.1, 1.0)
            flameScale3:SetDuration(0.8)
            flameScale3:SetSmoothing("IN_OUT")
            flameScale3:SetOrder(3)
            
            local flameAlpha1 = flameAnimGroup:CreateAnimation("Alpha")
            flameAlpha1:SetFromAlpha(0.8)
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
            flameAlpha3:SetToAlpha(0.8)
            flameAlpha3:SetDuration(0.8)
            flameAlpha3:SetSmoothing("IN_OUT")
            flameAlpha3:SetOrder(3)
            
            flameAnimGroup:Play()
        end
        
        -- Update flame colors
        if config.mainFlame then
            config.mainFlame:SetVertexColor(theme.colors.primary.r, theme.colors.primary.g*0.5, theme.colors.primary.b*0.2, 0.8)
        end
    end
    
    -- Apply to tabs if they exist
    if config.tabs and config.tabs.buttons and type(config.tabs.buttons) == "table" then
        for _, button in ipairs(config.tabs.buttons) do
            if button and not button.isHeader then
                -- Apply theme to regular tab buttons
                if button.selected then
                    -- Selected tab - make it stand out
                    if button.highlight then
                        button.highlight:SetColorTexture(
                            theme.colors.primary.r, 
                            theme.colors.primary.g, 
                            theme.colors.primary.b, 
                            0.6
                        )
                        button.highlight:SetAlpha(0.6)
                    end
                    
                    -- Update text color 
                    if button.text then
                        button.text:SetTextColor(
                            theme.colors.highlight.r,
                            theme.colors.highlight.g,
                            theme.colors.highlight.b
                        )
                    end
                    
                    -- Update icon color
                    if button.icon then
                        button.icon:SetVertexColor(
                            theme.colors.highlight.r,
                            theme.colors.highlight.g,
                            theme.colors.highlight.b
                        )
                    end
                    
                    -- Update selection indicator
                    if button.selectionIndicator then
                        button.selectionIndicator:SetColorTexture(
                            theme.colors.primary.r,
                            theme.colors.primary.g,
                            theme.colors.primary.b
                        )
                    end
                    
                    -- Add glow effect for Phoenix Flame
                    if isPhoenixFlame and theme.effects and theme.effects.enableGlow then
                        -- Create glow if it doesn't exist
                        if not button.glowTexture then
                            button.glowTexture = button:CreateTexture(nil, "BACKGROUND", nil, -1)
                            button.glowTexture:SetSize(button:GetWidth() * 1.2, button:GetHeight() * 1.2)
                            button.glowTexture:SetPoint("CENTER", button, "CENTER", 0, 0)
                            button.glowTexture:SetTexture(theme.textures.glow or "Interface\\AddOns\\Phoenix_UI\\Media\\Textures\\Effects\\FireGlow")
                            button.glowTexture:SetBlendMode("ADD")
                            button.glowTexture:SetAlpha(0)
                            
                            -- Create animation
                            local glowAnim = button.glowTexture:CreateAnimationGroup()
                            glowAnim:SetLooping("REPEAT")
                            
                            local fadeIn = glowAnim:CreateAnimation("Alpha")
                            fadeIn:SetFromAlpha(0)
                            fadeIn:SetToAlpha(0.3)
                            fadeIn:SetDuration(1.0)
                            fadeIn:SetSmoothing("IN")
                            fadeIn:SetOrder(1)
                            
                            local fadeOut = glowAnim:CreateAnimation("Alpha")
                            fadeOut:SetFromAlpha(0.3)
                            fadeOut:SetToAlpha(0)
                            fadeOut:SetDuration(1.0)
                            fadeOut:SetSmoothing("OUT")
                            fadeOut:SetOrder(2)
                            
                            glowAnim:Play()
                        end
                        
                        -- Show glow for selected tab
                        button.glowTexture:SetVertexColor(
                            theme.colors.primary.r,
                            theme.colors.primary.g * 0.8,
                            theme.colors.primary.b * 0.3
                        )
                        button.glowTexture:Show()
                    end
                else
                    -- Unselected tab - more subtle appearance
                    if button.highlight then
                        button.highlight:SetAlpha(0)
                    end
                    
                    if button.text then
                        button.text:SetTextColor(
                            theme.colors.text.r,
                            theme.colors.text.g,
                            theme.colors.text.b
                        )
                    end
                    
                    if button.icon then
                        button.icon:SetVertexColor(
                            theme.colors.text.r,
                            theme.colors.text.g,
                            theme.colors.text.b
                        )
                    end
                    
                    -- Hide glow for unselected tab
                    if button.glowTexture then
                        button.glowTexture:Hide()
                    end
                end
            elseif button and button.isHeader and button.text then
                -- Apply theme to header
                if isPhoenixFlame then
                    button.text:SetTextColor(
                        theme.colors.textHeader.r,
                        theme.colors.textHeader.g,
                        theme.colors.textHeader.b
                    )
                    
                    -- Add glow to headers
                    if not button.headerGlow then
                        button.headerGlow = button:CreateTexture(nil, "ARTWORK", nil, -1)
                        button.headerGlow:SetSize(button.text:GetStringWidth() * 1.2, button:GetHeight() * 0.8)
                        button.headerGlow:SetPoint("CENTER", button.text, "CENTER", 0, 0)
                        button.headerGlow:SetTexture(theme.textures.glow or "Interface\\AddOns\\Phoenix_UI\\Media\\Textures\\Effects\\FireGlow")
                        button.headerGlow:SetBlendMode("ADD")
                        button.headerGlow:SetAlpha(0.2)
                        
                        -- Create subtle animation
                        local headerGlowAnim = button.headerGlow:CreateAnimationGroup()
                        headerGlowAnim:SetLooping("REPEAT")
                        
                        local fadeIn = headerGlowAnim:CreateAnimation("Alpha")
                        fadeIn:SetFromAlpha(0.2)
                        fadeIn:SetToAlpha(0.3)
                        fadeIn:SetDuration(1.5)
                        fadeIn:SetSmoothing("IN_OUT")
                        fadeIn:SetOrder(1)
                        
                        local fadeOut = headerGlowAnim:CreateAnimation("Alpha")
                        fadeOut:SetFromAlpha(0.3)
                        fadeOut:SetToAlpha(0.2)
                        fadeOut:SetDuration(1.5)
                        fadeOut:SetSmoothing("IN_OUT")
                        fadeOut:SetOrder(2)
                        
                        headerGlowAnim:Play()
                    end
                else
                    button.text:SetTextColor(
                        theme.colors.primary.r,
                        theme.colors.primary.g,
                        theme.colors.primary.b
                    )
                    
                    -- Hide glow for non-Phoenix Flame theme
                    if button.headerGlow then
                        button.headerGlow:Hide()
                    end
                end
            end
        end
    end
    
    -- Apply theme to content if it exists
    if config.tabs and config.tabs.container then
        if config.tabs.container.SetBackdropColor then
            config.tabs.container:SetBackdropColor(
                theme.colors.background.r, 
                theme.colors.background.g, 
                theme.colors.background.b, 
                0.7
            )
            config.tabs.container:SetBackdropBorderColor(
                theme.colors.border.r, 
                theme.colors.border.g, 
                theme.colors.border.b
            )
        end
    end
    
    return true
end

-- Create a helper function to convert color table to string
function Phoenix_UI:ColorToString(color)
    if not color then return "|cFFFFFFFF" end
    
    local r = math.floor((color.r or 1) * 255)
    local g = math.floor((color.g or 1) * 255)
    local b = math.floor((color.b or 1) * 255)
    
    return string.format("|cFF%02x%02x%02x", r, g, b)
end

-- Function to get theme color values
-- @param alpha Optional alpha value to apply (0.0-1.0)
-- @param force Optional boolean to force returning a value even if no theme color exists
-- @return If color exists: r, g, b, a values that can be unpacked directly, or nil if no theme color
function Phoenix_UI:Color(alpha, force)
    -- Get current theme
    local themeName = self.currentTheme or (self.db and self.db.profile and self.db.profile.general and self.db.profile.general.theme) or "Default"
    local theme = self.themes and self.themes[themeName]
    
    -- If no theme found, try to use default theme
    if not theme then
        theme = self.themes and self.themes["Default"]
    end
    
    -- If still no theme or no colors
    if not theme or not theme.colors or not theme.colors.primary then
        -- Return default color or nil
        if force then
            return 0.9, 0.4, 0.13, alpha or 1.0
        else
            return nil
        end
    end
    
    -- Get primary color from theme
    local color = theme.colors.primary
    return color.r, color.g, color.b, alpha or color.a or 1.0
end

-- Create helper function to get theme color
function Phoenix_UI:GetThemeColor(colorName)
    local themeName = Phoenix_UI.currentTheme or (Phoenix_UI.db.profile.General and Phoenix_UI.db.profile.General.theme) or "Default"
    local theme = Phoenix_UI.themes[themeName] or Phoenix_UI.themes["Default"]
    
    if not theme.colors[colorName] then
        return theme.colors.primary
    end
    
    return theme.colors[colorName]
end

-- Create helper function to get theme texture
function Phoenix_UI:GetThemeTexture(textureName)
    local themeName = Phoenix_UI.currentTheme or (Phoenix_UI.db.profile.General and Phoenix_UI.db.profile.General.theme) or "Default"
    local theme = Phoenix_UI.themes[themeName] or Phoenix_UI.themes["Default"]
    
    if not theme.textures[textureName] then
        -- Return a sensible default
        if textureName == "tabSelected" then
            return "Interface\\OptionsFrame\\UI-OptionsFrame-ActiveTab"
        elseif textureName == "tabDeselected" then
            return "Interface\\OptionsFrame\\UI-OptionsFrame-InActiveTab"
        else
            return theme.textures.background
        end
    end
    
    return theme.textures[textureName]
end

-- Create helper function to get theme font
function Phoenix_UI:GetThemeFont(fontName)
    local themeName = Phoenix_UI.currentTheme or (Phoenix_UI.db.profile.General and Phoenix_UI.db.profile.General.theme) or "Default"
    local theme = Phoenix_UI.themes[themeName] or Phoenix_UI.themes["Default"]
    
    if not theme.fonts[fontName] then
        return theme.fonts.normal
    end
    
    return theme.fonts[fontName]
end

-- Add a skinning function to apply themes to UI elements
-- @param frame The frame to skin
-- @param noBackdrop Optional boolean to skip backdrop skinning
-- @return The skinned frame or nil if skinning failed
function Phoenix_UI:Skin(frame, noBackdrop)
    if not frame then return nil end
    
    -- Handle with pcall to avoid errors
    local success = pcall(function()
        -- Get theme colors
        local r, g, b, a = self:Color(0.15, true)
        
        -- Apply vertex color if possible
        if frame.SetVertexColor and not noBackdrop then
            frame:SetVertexColor(r, g, b, a)
        end
        
        -- Apply backdrop if it has one and noBackdrop is not true
        if not noBackdrop and frame.SetBackdropColor then
            frame:SetBackdropColor(r, g, b, a)
            
            -- Also set border color if available
            if frame.SetBackdropBorderColor then
                frame:SetBackdropBorderColor(r, g, b, a * 1.5)
            end
        end
        
        -- Apply to children textures if they exist
        if frame.GetRegions then
            local regions = {frame:GetRegions()}
            for _, region in ipairs(regions) do
                if region.IsObjectType and region:IsObjectType("Texture") and not region:GetName() then
                    region:SetVertexColor(r, g, b, a)
                end
            end
        end
    end)
    
    if success then
        return frame
    else
        return nil
    end
end

-- Helper function to safely apply colors to UI elements
-- @param frame The frame to color
-- @param alpha Optional alpha value (0.0-1.0)
-- @param ignoreErrors Optional boolean to ignore errors
-- @return The colored frame
function Phoenix_UI:ApplyColor(frame, alpha, ignoreErrors)
    if not frame then return nil end
    
    local function doApply()
        -- Get color values directly to avoid unpack issues
        local r, g, b, a = self:Color(alpha or 0.15, true)
        
        if frame.SetVertexColor then
            frame:SetVertexColor(r, g, b, a)
        elseif frame.SetBackdropBorderColor then
            frame:SetBackdropBorderColor(r, g, b, a)
        end
    end
    
    if ignoreErrors then
        pcall(doApply)
    else
        doApply()
    end
    
    return frame
end 