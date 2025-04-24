-- Phoenix_UI CooldownTracker - Styling Module
local addonName, Phoenix = ...

-- Get the main module
local CT = Phoenix_UI:GetModule("CooldownTracker")
if not CT then return end

-- Create the styling submodule
local Styling = CT:NewModule("Styling")

-- Localization
local L = Phoenix.L or {}

-- Debug function
local function DebugLog(msg)
    if Phoenix_UI and Phoenix_UI.Debug then
        Phoenix_UI:Debug("Styling", msg)
    end
end

-- Log initialization
DebugLog("Styling module loaded")

-- Font presets
Styling.fontPresets = {
    {
        name = "Default",
        font = "Friz Quadrata TT",
        flags = "OUTLINE"
    },
    {
        name = "Clean",
        font = "Arial Narrow",
        flags = "OUTLINE"
    },
    {
        name = "Bold",
        font = "FRIZQT___",
        flags = "THICKOUTLINE"
    },
    {
        name = "Digital",
        font = "Expressway",
        flags = "OUTLINE"
    }
}

-- Color presets
Styling.colorPresets = {
    {
        name = "Default",
        normal = {r = 1, g = 1, b = 1, a = 1},
        expiring = {r = 1, g = 0, b = 0, a = 1}
    },
    {
        name = "Subtle",
        normal = {r = 0.8, g = 0.8, b = 0.8, a = 0.9},
        expiring = {r = 1, g = 0.3, b = 0.3, a = 1}
    },
    {
        name = "WoW Style",
        normal = {r = 1, g = 0.82, b = 0, a = 1},
        expiring = {r = 1, g = 0.1, b = 0.1, a = 1}
    },
    {
        name = "Gradient",
        normal = {r = 0.4, g = 0.9, b = 1, a = 1},
        expiring = {r = 1, g = 0.2, b = 0.2, a = 1}
    },
    {
        name = "Phoenix Flame",
        normal = {r = 1, g = 0.7, b = 0.3, a = 1},
        expiring = {r = 1, g = 0.3, b = 0, a = 1}
    }
}

-- Enhanced effect presets with multiple animation types
Styling.effectPresets = {
    {
        name = "None",
        flashEnabled = false
    },
    {
        name = "Default Flash",
        flashEnabled = true,
        flashColor = {r = 1, g = 1, b = 1, a = 0.7},
        flashDuration = 0.8
    },
    {
        name = "Pulse",
        effectType = "PULSE",
        flashEnabled = true,
        flashColor = {r = 0.8, g = 0.8, b = 0.8, a = 0.5},
        flashDuration = 1.2,
        pulseScale = 1.5,
        pulseDuration = 0.6
    },
    {
        name = "Bounce",
        effectType = "BOUNCE",
        flashEnabled = true,
        flashColor = {r = 1, g = 0.7, b = 0, a = 0.8},
        flashDuration = 0.5,
        bounceHeight = 8,
        bounceDuration = 0.4
    },
    {
        name = "Shine",
        effectType = "SHINE",
        flashEnabled = true,
        flashColor = {r = 1, g = 1, b = 1, a = 0.8},
        flashDuration = 0.7,
        shineDuration = 0.5
    },
    {
        name = "Phoenix Flame",
        effectType = "FLAME",
        flashEnabled = true,
        flashColor = {r = 1, g = 0.5, b = 0, a = 0.7},
        flashDuration = 0.8,
        flameHeight = 20,
        flameDuration = 1.0
    }
}

-- Extended text position presets with offsets
Styling.positionPresets = {
    {
        name = "Center",
        position = "CENTER",
        xOffset = 0,
        yOffset = 0
    },
    {
        name = "Top",
        position = "TOP",
        xOffset = 0,
        yOffset = 0
    },
    {
        name = "Bottom",
        position = "BOTTOM",
        xOffset = 0,
        yOffset = 0
    },
    {
        name = "Top Right",
        position = "TOPRIGHT",
        xOffset = -2,
        yOffset = -2
    },
    {
        name = "Bottom Left",
        position = "BOTTOMLEFT",
        xOffset = 2,
        yOffset = 2
    },
    {
        name = "Outside Top",
        position = "TOP",
        xOffset = 0,
        yOffset = 5
    },
    {
        name = "Outside Bottom",
        position = "BOTTOM",
        xOffset = 0,
        yOffset = -5
    },
    {
        name = "Inside Center",
        position = "CENTER",
        xOffset = 0,
        yOffset = 0,
        textSizeModifier = 0.9
    }
}

-- Text style presets combining font, color, and outline
Styling.textStylePresets = {
    {
        name = "Clean",
        font = "Arial Narrow",
        outline = "OUTLINE",
        shadow = false,
        sizeMod = 1.0
    },
    {
        name = "Bold Shadowed",
        font = "FRIZQT___",
        outline = "THICKOUTLINE",
        shadow = true,
        shadowColor = {r = 0, g = 0, b = 0, a = 1},
        shadowOffset = {x = 1, y = -1},
        sizeMod = 0.9
    },
    {
        name = "Digital",
        font = "Expressway",
        outline = "OUTLINE",
        shadow = false,
        sizeMod = 1.0
    },
    {
        name = "Phoenix",
        font = "Expressway",
        outline = "OUTLINE",
        shadow = true,
        shadowColor = {r = 0.3, g = 0.1, b = 0, a = 0.8},
        shadowOffset = {x = 1, y = -1},
        sizeMod = 1.0,
        glowEnabled = true,
        glowColor = {r = 1, g = 0.5, b = 0, a = 0.5}
    }
}

-- Apply a font preset to the settings
function Styling:ApplyFontPreset(presetIndex)
    local db = CT:GetDB()
    if not db or not db.cooldownText then return end
    
    local preset = self.fontPresets[presetIndex]
    if not preset then return end
    
    db.cooldownText.textFont = preset.font
    db.cooldownText.textFlags = preset.flags
    
    -- Update all active cooldowns
    CT:UpdateAllCooldowns(true)
    
    -- Save settings
    Phoenix_UI:SaveDB()
end

-- Apply a color preset to the settings
function Styling:ApplyColorPreset(presetIndex)
    local db = CT:GetDB()
    if not db or not db.cooldownText then return end
    
    local preset = self.colorPresets[presetIndex]
    if not preset then return end
    
    db.cooldownText.normalColor = CopyTable(preset.normal)
    db.cooldownText.expiringColor = CopyTable(preset.expiring)
    
    -- Update all active cooldowns
    CT:UpdateAllCooldowns(true)
    
    -- Save settings
    Phoenix_UI:SaveDB()
end

-- Apply an effect preset to the settings
function Styling:ApplyEffectPreset(presetIndex)
    local db = CT:GetDB()
    if not db or not db.cooldownText then return end
    
    local preset = self.effectPresets[presetIndex]
    if not preset then return end
    
    -- Create finishEffects table if it doesn't exist
    if not db.cooldownText.finishEffects then
        db.cooldownText.finishEffects = {}
    end
    
    db.cooldownText.finishEffects.enableFlash = preset.flashEnabled
    
    if preset.flashEnabled then
        db.cooldownText.finishEffects.flashColor = CopyTable(preset.flashColor)
        db.cooldownText.finishEffects.flashDuration = preset.flashDuration
    end
    
    -- Set effect type
    db.cooldownText.finishEffects.effectType = preset.effectType or "FLASH"
    
    -- Add specific effect parameters based on type
    if preset.effectType == "PULSE" then
        db.cooldownText.finishEffects.pulseScale = preset.pulseScale
        db.cooldownText.finishEffects.pulseDuration = preset.pulseDuration
    elseif preset.effectType == "BOUNCE" then
        db.cooldownText.finishEffects.bounceHeight = preset.bounceHeight
        db.cooldownText.finishEffects.bounceDuration = preset.bounceDuration
    elseif preset.effectType == "SHINE" then
        db.cooldownText.finishEffects.shineDuration = preset.shineDuration
    elseif preset.effectType == "FLAME" then
        db.cooldownText.finishEffects.flameHeight = preset.flameHeight
        db.cooldownText.finishEffects.flameDuration = preset.flameDuration
    end
    
    -- Update all active cooldowns
    CT:UpdateAllCooldowns(true)
    
    -- Save settings
    Phoenix_UI:SaveDB()
end

-- Apply a position preset to the settings
function Styling:ApplyPositionPreset(presetIndex)
    local db = CT:GetDB()
    if not db or not db.cooldownText then return end
    
    local preset = self.positionPresets[presetIndex]
    if not preset then return end
    
    db.cooldownText.textPosition = preset.position
    db.cooldownText.xOffset = preset.xOffset
    db.cooldownText.yOffset = preset.yOffset
    
    -- Apply text size modifier if included
    if preset.textSizeModifier then
        local baseSize = db.cooldownText.textSize or 14
        db.cooldownText.textSize = baseSize * preset.textSizeModifier
    end
    
    -- Update all active cooldowns
    CT:UpdateAllCooldowns(true)
    
    -- Save settings
    Phoenix_UI:SaveDB()
end

-- Apply a text style preset (font, outline, shadow)
function Styling:ApplyTextStylePreset(presetIndex)
    local db = CT:GetDB()
    if not db or not db.cooldownText then return end
    
    local preset = self.textStylePresets[presetIndex]
    if not preset then return end
    
    -- Apply font settings
    db.cooldownText.textFont = preset.font
    db.cooldownText.textOutline = preset.outline
    
    -- Apply shadow settings
    db.cooldownText.textShadow = preset.shadow
    if preset.shadow and preset.shadowColor then
        db.cooldownText.shadowColor = CopyTable(preset.shadowColor)
    end
    if preset.shadow and preset.shadowOffset then
        db.cooldownText.shadowOffset = CopyTable(preset.shadowOffset)
    end
    
    -- Apply glow settings
    db.cooldownText.textGlow = preset.glowEnabled
    if preset.glowEnabled and preset.glowColor then
        db.cooldownText.glowColor = CopyTable(preset.glowColor)
    end
    
    -- Apply size modifier
    if preset.sizeMod then
        local baseSize = db.cooldownText.baseTextSize or db.cooldownText.textSize or 14
        db.cooldownText.textSize = baseSize * preset.sizeMod
    end
    
    -- Update all active cooldowns
    CT:UpdateAllCooldowns(true)
    
    -- Save settings
    Phoenix_UI:SaveDB()
end

-- Get theme information from Phoenix_UI
function Styling:GetCurrentTheme()
    local theme = {
        name = "Default",
        colors = {
            primary = {r = 1, g = 1, b = 1},
            secondary = {r = 0.8, g = 0.8, b = 0.8},
            accent = {r = 1, g = 0.8, b = 0},
            text = {r = 1, g = 1, b = 1},
            background = {r = 0.1, g = 0.1, b = 0.1}
        }
    }
    
    -- Get theme from Phoenix_UI
    if type(Phoenix_UI) == "table" and Phoenix_UI.currentTheme then
        theme.name = Phoenix_UI.currentTheme
        
        if type(Phoenix_UI.themes) == "table" and 
           type(Phoenix_UI.themes[theme.name]) == "table" then
            local uiTheme = Phoenix_UI.themes[theme.name]
            
            if type(uiTheme.colors) == "table" then
                if type(uiTheme.colors.primary) == "table" then
                    theme.colors.primary = uiTheme.colors.primary
                end
                if type(uiTheme.colors.secondary) == "table" then
                    theme.colors.secondary = uiTheme.colors.secondary
                end
                if type(uiTheme.colors.accent) == "table" then
                    theme.colors.accent = uiTheme.colors.accent
                end
                if type(uiTheme.colors.text) == "table" then
                    theme.colors.text = uiTheme.colors.text
                end
                if type(uiTheme.colors.background) == "table" then
                    theme.colors.background = uiTheme.colors.background
                end
            end
        end
    end
    
    return theme
end

-- Apply theme colors to cooldown text
function Styling:ApplyThemeColors()
    local db = CT:GetDB()
    if not db or not db.cooldownText then return end
    
    local theme = self:GetCurrentTheme()
    if not theme or not theme.name then return end
    
    local isPhoenixFlame = (theme.name == "PhoenixFlame")
    
    -- Apply theme-specific colors
    if isPhoenixFlame then
        -- Special handling for Phoenix Flame theme
        db.cooldownText.normalColor = {
            r = theme.colors and theme.colors.accent and theme.colors.accent.r or 1,
            g = theme.colors and theme.colors.accent and theme.colors.accent.g or 0.7,
            b = theme.colors and theme.colors.accent and theme.colors.accent.b or 0.3,
            a = 1
        }
        
        db.cooldownText.expiringColor = {
            r = theme.colors and theme.colors.primary and theme.colors.primary.r or 1,
            g = theme.colors and theme.colors.primary and theme.colors.primary.g or 0.3,
            b = theme.colors and theme.colors.primary and theme.colors.primary.b or 0,
            a = 1
        }
        
        -- Apply flame finish effects
        db.cooldownText.finishEffects = {
            enableFlash = true,
            effectType = "FLAME",
            flashColor = {
                r = theme.colors and theme.colors.primary and theme.colors.primary.r or 1,
                g = theme.colors and theme.colors.primary and theme.colors.primary.g or 0.5,
                b = theme.colors and theme.colors.primary and theme.colors.primary.b or 0,
                a = 0.7
            },
            flashDuration = 0.8,
            flameHeight = 20,
            flameDuration = 1.0
        }
    else
        -- Default theme
        db.cooldownText.normalColor = {
            r = theme.colors and theme.colors.text and theme.colors.text.r or 1,
            g = theme.colors and theme.colors.text and theme.colors.text.g or 1,
            b = theme.colors and theme.colors.text and theme.colors.text.b or 1,
            a = 1
        }
        
        db.cooldownText.expiringColor = {
            r = theme.colors and theme.colors.accent and theme.colors.accent.r or 1,
            g = 0.2,
            b = 0.2,
            a = 1
        }
        
        -- Default effects
        db.cooldownText.finishEffects = {
            enableFlash = true,
            effectType = "FLASH",
            flashColor = {
                r = theme.colors and theme.colors.accent and theme.colors.accent.r or 1,
                g = theme.colors and theme.colors.accent and theme.colors.accent.g or 0.8,
                b = theme.colors and theme.colors.accent and theme.colors.accent.b or 0,
                a = 0.7
            },
            flashDuration = 0.8
        }
    end
    
    -- Update all active cooldowns
    CT:UpdateAllCooldowns(true)
    
    -- Save settings
    Phoenix_UI:SaveDB()
end

-- Create finish effect animations for a frame
function Styling:CreateFinishEffectAnimations(frame)
    if not frame then return end
    
    -- Flash animation
    if not frame.flashAnim then
        frame.flash = frame:CreateTexture(nil, "OVERLAY")
        frame.flash:SetAllPoints()
        frame.flash:SetTexture("Interface\\AddOns\\Phoenix_UI\\Media\\Textures\\Flash")
        frame.flash:SetBlendMode("ADD")
        frame.flash:SetAlpha(0)
        
        frame.flashAnim = frame:CreateAnimationGroup()
        local fadeIn = frame.flashAnim:CreateAnimation("Alpha")
        fadeIn:SetFromAlpha(0)
        fadeIn:SetToAlpha(0.7)
        fadeIn:SetDuration(0.3)
        fadeIn:SetOrder(1)
        
        local fadeOut = frame.flashAnim:CreateAnimation("Alpha")
        fadeOut:SetFromAlpha(0.7)
        fadeOut:SetToAlpha(0)
        fadeOut:SetDuration(0.5)
        fadeOut:SetOrder(2)
        
        frame.flashAnim:SetScript("OnPlay", function() 
            frame.flash:SetAlpha(1)
            frame.flash:Show()
        end)
        
        frame.flashAnim:SetScript("OnFinished", function()
            frame.flash:SetAlpha(0)
            frame.flash:Hide()
        end)
    end
    
    -- Pulse animation
    if not frame.pulseAnim then
        frame.pulseAnim = frame:CreateAnimationGroup()
        
        local grow = frame.pulseAnim:CreateAnimation("Scale")
        grow:SetOrigin("CENTER", 0, 0)
        grow:SetScale(1.5, 1.5)
        grow:SetDuration(0.3)
        grow:SetOrder(1)
        
        local shrink = frame.pulseAnim:CreateAnimation("Scale")
        shrink:SetOrigin("CENTER", 0, 0)
        shrink:SetScale(0.67, 0.67) -- 1/1.5 to return to original size
        shrink:SetDuration(0.3)
        shrink:SetOrder(2)
        
        frame.pulseAnim:SetScript("OnFinished", function()
            -- Reset scale to avoid cumulative effects
            frame:SetScale(1)
        end)
    end
    
    -- Bounce animation
    if not frame.bounceAnim then
        frame.bounceAnim = frame:CreateAnimationGroup()
        
        local up = frame.bounceAnim:CreateAnimation("Translation")
        up:SetOffset(0, 8) -- 8 pixels up
        up:SetDuration(0.2)
        up:SetOrder(1)
        
        local down = frame.bounceAnim:CreateAnimation("Translation")
        down:SetOffset(0, -8) -- 8 pixels down
        down:SetDuration(0.2)
        down:SetOrder(2)
        
        frame.bounceAnim:SetScript("OnFinished", function()
            -- Reset position to avoid cumulative effects
            frame:ClearAllPoints()
            frame:SetPoint(frame.originalPoint, frame.originalParent, frame.originalRelPoint, frame.originalX, frame.originalY)
        end)
    end
    
    -- Shine animation
    if not frame.shineAnim then
        -- Create shine texture
        frame.shine = frame:CreateTexture(nil, "OVERLAY")
        frame.shine:SetSize(frame:GetWidth() * 2, frame:GetHeight() * 2)
        frame.shine:SetPoint("CENTER")
        frame.shine:SetTexture("Interface\\AddOns\\Phoenix_UI\\Media\\Textures\\Effects\\Shine")
        frame.shine:SetBlendMode("ADD")
        frame.shine:SetAlpha(0)
        
        frame.shineAnim = frame:CreateAnimationGroup()
        
        local appear = frame.shineAnim:CreateAnimation("Alpha")
        appear:SetFromAlpha(0)
        appear:SetToAlpha(0.7)
        appear:SetDuration(0.2)
        appear:SetOrder(1)
        
        local rotate = frame.shineAnim:CreateAnimation("Rotation")
        rotate:SetDegrees(45) -- 45 degree rotation
        rotate:SetDuration(0.3)
        rotate:SetOrder(2)
        
        local fade = frame.shineAnim:CreateAnimation("Alpha")
        fade:SetFromAlpha(0.7)
        fade:SetToAlpha(0)
        fade:SetDuration(0.2)
        fade:SetOrder(3)
        
        frame.shineAnim:SetScript("OnPlay", function()
            frame.shine:Show()
        end)
        
        frame.shineAnim:SetScript("OnFinished", function()
            frame.shine:Hide()
        end)
    end
    
    -- Flame animation (Phoenix Flame theme)
    if not frame.flameAnim then
        frame.flame = frame:CreateTexture(nil, "OVERLAY")
        frame.flame:SetSize(frame:GetWidth(), frame:GetHeight() * 1.5)
        frame.flame:SetPoint("BOTTOM", frame, "TOP", 0, -frame:GetHeight()/2)
        frame.flame:SetTexture("Interface\\AddOns\\Phoenix_UI\\Media\\Textures\\Effects\\Flame")
        frame.flame:SetBlendMode("ADD")
        frame.flame:SetVertexColor(1, 0.5, 0, 0.7)
        frame.flame:SetAlpha(0)
        
        frame.flameAnim = frame:CreateAnimationGroup()
        
        local appear = frame.flameAnim:CreateAnimation("Alpha")
        appear:SetFromAlpha(0)
        appear:SetToAlpha(0.7)
        appear:SetDuration(0.2)
        appear:SetOrder(1)
        
        local grow = frame.flameAnim:CreateAnimation("Scale")
        grow:SetOrigin("BOTTOM", 0, 0)
        grow:SetScale(1, 1.5)
        grow:SetDuration(0.4)
        grow:SetOrder(1)
        
        local fade = frame.flameAnim:CreateAnimation("Alpha")
        fade:SetFromAlpha(0.7)
        fade:SetToAlpha(0)
        fade:SetDuration(0.4)
        fade:SetOrder(2)
        
        frame.flameAnim:SetScript("OnPlay", function()
            frame.flame:Show()
        end)
        
        frame.flameAnim:SetScript("OnFinished", function()
            frame.flame:Hide()
        end)
    end
end

-- Play a finish effect on a frame
function Styling:PlayFinishEffect(frame, effectType, options)
    if not frame then return end
    
    -- Create animations if they don't exist
    self:CreateFinishEffectAnimations(frame)
    
    -- Set default options
    options = options or {}
    
    -- Apply effect based on type
    if effectType == "FLASH" or not effectType then
        -- Apply color if provided
        if options.flashColor then
            frame.flash:SetVertexColor(
                options.flashColor.r or 1,
                options.flashColor.g or 1,
                options.flashColor.b or 1,
                options.flashColor.a or 0.7
            )
        end
        
        -- Set duration if provided
        if options.flashDuration then
            local animations = {frame.flashAnim:GetAnimations()}
            animations[1]:SetDuration(options.flashDuration * 0.4)
            animations[2]:SetDuration(options.flashDuration * 0.6)
        end
        
        -- Play animation
        if frame.flashAnim then
            frame.flashAnim:Play()
        end
    elseif effectType == "PULSE" then
        -- Set scale if provided
        if options.pulseScale then
            local animations = {frame.pulseAnim:GetAnimations()}
            animations[1]:SetScale(options.pulseScale, options.pulseScale)
            animations[2]:SetScale(1/options.pulseScale, 1/options.pulseScale)
        end
        
        -- Set duration if provided
        if options.pulseDuration then
            local animations = {frame.pulseAnim:GetAnimations()}
            animations[1]:SetDuration(options.pulseDuration * 0.5)
            animations[2]:SetDuration(options.pulseDuration * 0.5)
        end
        
        -- Play animation
        if frame.pulseAnim then
            frame.pulseAnim:Play()
        end
    elseif effectType == "BOUNCE" then
        -- Store original position
        local point, parent, relPoint, x, y = frame:GetPoint()
        frame.originalPoint = point
        frame.originalParent = parent
        frame.originalRelPoint = relPoint
        frame.originalX = x
        frame.originalY = y
        
        -- Set height if provided
        if options.bounceHeight then
            local animations = {frame.bounceAnim:GetAnimations()}
            animations[1]:SetOffset(0, options.bounceHeight)
            animations[2]:SetOffset(0, -options.bounceHeight)
        end
        
        -- Set duration if provided
        if options.bounceDuration then
            local animations = {frame.bounceAnim:GetAnimations()}
            animations[1]:SetDuration(options.bounceDuration * 0.5)
            animations[2]:SetDuration(options.bounceDuration * 0.5)
        end
        
        -- Play animation
        if frame.bounceAnim then
            frame.bounceAnim:Play()
        end
    elseif effectType == "SHINE" then
        -- Apply color if provided
        if options.shineColor then
            frame.shine:SetVertexColor(
                options.shineColor.r or 1,
                options.shineColor.g or 1,
                options.shineColor.b or 1,
                options.shineColor.a or 0.7
            )
        end
        
        -- Set duration if provided
        if options.shineDuration then
            local animations = {frame.shineAnim:GetAnimations()}
            animations[1]:SetDuration(options.shineDuration * 0.3)
            animations[2]:SetDuration(options.shineDuration * 0.4)
            animations[3]:SetDuration(options.shineDuration * 0.3)
        end
        
        -- Play animation
        if frame.shineAnim then
            frame.shineAnim:Play()
        end
    elseif effectType == "FLAME" then
        -- Apply color if provided
        if options.flameColor then
            frame.flame:SetVertexColor(
                options.flameColor.r or 1,
                options.flameColor.g or 0.5,
                options.flameColor.b or 0,
                options.flameColor.a or 0.7
            )
        end
        
        -- Set height if provided
        if options.flameHeight then
            frame.flame:SetHeight(options.flameHeight)
        end
        
        -- Set duration if provided
        if options.flameDuration then
            local animations = {frame.flameAnim:GetAnimations()}
            animations[1]:SetDuration(options.flameDuration * 0.3)
            animations[2]:SetDuration(options.flameDuration * 0.4)
            animations[3]:SetDuration(options.flameDuration * 0.3)
        end
        
        -- Play animation
        if frame.flameAnim then
            frame.flameAnim:Play()
        end
    end
end

-- Initialize styling module
function Styling:OnInitialize()
    DebugLog("Initializing Styling module")
    
    -- Register for theme changes if Phoenix_UI is available
    if type(Phoenix_UI) == "table" and type(Phoenix_UI.RegisterMessage) == "function" then
        Phoenix_UI:RegisterMessage("PHOENIX_UI_THEME_CHANGED", function()
            DebugLog("Theme changed event received")
            if type(self.ApplyThemeColors) == "function" then
                self:ApplyThemeColors()
            end
        end)
    end
    
    -- Apply theme colors on initial load with a delay to ensure all components are loaded
    if type(C_Timer) == "table" and type(C_Timer.After) == "function" then
        C_Timer.After(1, function()
            DebugLog("Applying theme colors after delay")
            if type(self.ApplyThemeColors) == "function" then
                self:ApplyThemeColors()
            end
        end)
    end
    
    DebugLog("Styling module initialization complete")
end

-- Register a new cooldown frame for styling
function Styling:RegisterCooldownFrame(frame)
    if not frame then return end
    
    -- Create finish effect animations
    self:CreateFinishEffectAnimations(frame)
    
    -- Apply current theme settings
    local db = CT:GetDB()
    if db and db.cooldownText then
        -- Apply text style
        if db.cooldownText.textFont then
            frame.text:SetFont(
                db.cooldownText.textFont, 
                db.cooldownText.textSize or 14, 
                db.cooldownText.textOutline or "OUTLINE"
            )
        end
        
        -- Apply text shadow if enabled
        if db.cooldownText.textShadow then
            frame.text:SetShadowOffset(
                db.cooldownText.shadowOffset and db.cooldownText.shadowOffset.x or 1,
                db.cooldownText.shadowOffset and db.cooldownText.shadowOffset.y or -1
            )
            
            if db.cooldownText.shadowColor then
                frame.text:SetShadowColor(
                    db.cooldownText.shadowColor.r or 0,
                    db.cooldownText.shadowColor.g or 0,
                    db.cooldownText.shadowColor.b or 0,
                    db.cooldownText.shadowColor.a or 1
                )
            end
        else
            frame.text:SetShadowOffset(0, 0)
        end
    end
    
    return frame
end

-- Create a method to preview a style
function Styling:PreviewStyle(fontInfo, colorInfo, effectInfo, positionInfo)
    -- Create a preview frame if it doesn't exist
    if not self.previewFrame then
        local frame = CreateFrame("Frame", "Phoenix_CDT_Preview", UIParent)
        frame:SetSize(300, 200)
        frame:SetPoint("CENTER")
        frame:SetFrameStrata("DIALOG")
        
        -- Add background and border
        frame.bg = frame:CreateTexture(nil, "BACKGROUND")
        frame.bg:SetAllPoints()
        frame.bg:SetColorTexture(0.1, 0.1, 0.1, 0.9)
        
        frame.border = CreateFrame("Frame", nil, frame)
        frame.border:SetAllPoints()
        frame.border:SetBackdrop({
            edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
            edgeSize = 16,
        })
        frame.border:SetBackdropBorderColor(0.6, 0.6, 0.6, 1)
        
        -- Title text
        frame.title = frame:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
        frame.title:SetPoint("TOP", 0, -10)
        frame.title:SetText("Cooldown Preview")
        
        -- Create multiple preview examples to show various states
        -- Long cooldown example
        frame.longCD = self:CreateCooldownPreview(frame, "Interface\\Icons\\spell_nature_thunderclap", 55, 55)
        frame.longCD:SetPoint("TOPLEFT", 30, -50)
        frame.longCD.label = frame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
        frame.longCD.label:SetPoint("BOTTOM", frame.longCD, "BOTTOM", 0, -15)
        frame.longCD.label:SetText("Long Cooldown")
        
        -- Medium cooldown example
        frame.mediumCD = self:CreateCooldownPreview(frame, "Interface\\Icons\\ability_warrior_shieldwall", 55, 55)
        frame.mediumCD:SetPoint("TOP", 0, -50)
        frame.mediumCD.label = frame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
        frame.mediumCD.label:SetPoint("BOTTOM", frame.mediumCD, "BOTTOM", 0, -15)
        frame.mediumCD.label:SetText("Medium")
        
        -- Expiring cooldown example
        frame.expiringCD = self:CreateCooldownPreview(frame, "Interface\\Icons\\spell_holy_sealofsacrifice", 55, 55)
        frame.expiringCD:SetPoint("TOPRIGHT", -30, -50)
        frame.expiringCD.label = frame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
        frame.expiringCD.label:SetPoint("BOTTOM", frame.expiringCD, "BOTTOM", 0, -15)
        frame.expiringCD.label:SetText("Expiring")
        
        -- Expiring flash example
        frame.flashCD = self:CreateCooldownPreview(frame, "Interface\\Icons\\ability_rogue_deviouspoisons", 55, 55)
        frame.flashCD:SetPoint("BOTTOMLEFT", 30, 60)
        frame.flashCD.label = frame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
        frame.flashCD.label:SetPoint("BOTTOM", frame.flashCD, "BOTTOM", 0, -15)
        frame.flashCD.label:SetText("Flash Effect")
        
        -- Small cooldown example
        frame.smallCD = self:CreateCooldownPreview(frame, "Interface\\Icons\\spell_nature_healingtouch", 32, 32)
        frame.smallCD:SetPoint("BOTTOM", 0, 60)
        frame.smallCD.label = frame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
        frame.smallCD.label:SetPoint("BOTTOM", frame.smallCD, "BOTTOM", 0, -15)
        frame.smallCD.label:SetText("Small")
        
        -- Close button
        frame.close = CreateFrame("Button", nil, frame, "UIPanelCloseButton")
        frame.close:SetPoint("TOPRIGHT", frame, "TOPRIGHT", 0, 0)
        frame.close:SetScript("OnClick", function() frame:Hide() end)
        
        -- Apply button
        frame.apply = CreateFrame("Button", nil, frame, "UIPanelButtonTemplate")
        frame.apply:SetSize(100, 25)
        frame.apply:SetPoint("BOTTOM", 0, 20)
        frame.apply:SetText("Apply Style")
        frame.apply:SetScript("OnClick", function() 
            self:ApplyCurrentPreviewStyle()
            frame:Hide()
        end)
        
        -- Store the frame
        self.previewFrame = frame
    end
    
    local frame = self.previewFrame
    
    -- Save current style settings for apply button
    frame.currentStyle = {
        fontInfo = fontInfo,
        colorInfo = colorInfo,
        effectInfo = effectInfo,
        positionInfo = positionInfo
    }
    
    -- Set up the cooldown previews
    self:UpdateCooldownPreview(frame.longCD, 45, fontInfo, colorInfo, positionInfo) -- 45 sec remaining
    self:UpdateCooldownPreview(frame.mediumCD, 12, fontInfo, colorInfo, positionInfo) -- 12 sec remaining
    self:UpdateCooldownPreview(frame.expiringCD, 2.5, fontInfo, colorInfo, positionInfo, true) -- 2.5 sec remaining (expiring)
    self:UpdateCooldownPreview(frame.smallCD, 5, fontInfo, colorInfo, positionInfo) -- 5 sec on small icon
    
    -- Set up flash effect preview
    self:UpdateCooldownPreview(frame.flashCD, 0.1, fontInfo, colorInfo, positionInfo)
    if effectInfo and effectInfo.flashEnabled then
        C_Timer.After(0.5, function()
            if frame:IsShown() then
                frame.flashCD:PlayFlash(
                    effectInfo.flashColor.r or 1,
                    effectInfo.flashColor.g or 1,
                    effectInfo.flashColor.b or 1,
                    effectInfo.flashColor.a or 0.7,
                    effectInfo.flashDuration or 0.8
                )
            end
        end)
    end
    
    -- Show the frame
    frame:Show()
    
    -- Auto-hide after 15 seconds if not closed
    if frame.hideTimer then
        frame.hideTimer:Cancel()
    end
    frame.hideTimer = C_Timer.NewTimer(15, function()
        if frame:IsShown() then
            frame:Hide()
        end
    end)
end

-- Helper method to create a cooldown preview
function Styling:CreateCooldownPreview(parent, iconTexture, width, height)
    local frame = CreateFrame("Frame", nil, parent)
    frame:SetSize(width or 36, height or 36)
    
    -- Icon texture
    frame.icon = frame:CreateTexture(nil, "ARTWORK")
    frame.icon:SetAllPoints()
    frame.icon:SetTexture(iconTexture)
    
    -- Cooldown overlay
    frame.cooldown = CreateFrame("Cooldown", nil, frame, "CooldownFrameTemplate")
    frame.cooldown:SetAllPoints()
    frame.cooldown:SetCooldown(GetTime(), 3600) -- Very long cooldown
    
    -- Text for cooldown
    frame.text = frame:CreateFontString(nil, "OVERLAY")
    frame.text:SetPoint("CENTER", frame, "CENTER")
    
    -- Flash animation for finish effect
    frame.flash = frame:CreateTexture(nil, "OVERLAY")
    frame.flash:SetAllPoints()
    frame.flash:SetTexture("Interface\\SpellActivationOverlay\\IconAlert")
    frame.flash:SetBlendMode("ADD")
    frame.flash:SetAlpha(0)
    
    -- Flash animation group
    frame.flashAnim = frame:CreateAnimationGroup()
    frame.flashAnim:SetLooping("NONE")
    
    local fadeIn = frame.flashAnim:CreateAnimation("Alpha")
    fadeIn:SetFromAlpha(0)
    fadeIn:SetToAlpha(1)
    fadeIn:SetDuration(0.3)
    fadeIn:SetOrder(1)
    
    local fadeOut = frame.flashAnim:CreateAnimation("Alpha")
    fadeOut:SetFromAlpha(1)
    fadeOut:SetToAlpha(0)
    fadeOut:SetDuration(0.5)
    fadeOut:SetOrder(2)
    
    -- Animation callbacks
    frame.flashAnim:SetScript("OnPlay", function()
        frame.flash:Show()
    end)
    
    frame.flashAnim:SetScript("OnFinished", function()
        frame.flash:Hide()
    end)
    
    -- Method to play flash animation
    frame.PlayFlash = function(self, r, g, b, a, duration)
        -- Set color if provided
        if r and g and b then
            self.flash:SetVertexColor(r, g, b, a or 1)
        end
        
        -- Set duration if provided
        if duration then
            local fadeIn = self.flashAnim:GetAnimations()
            local fadeOut = select(2, self.flashAnim:GetAnimations())
            
            fadeIn:SetDuration(duration * 0.3)
            fadeOut:SetDuration(duration * 0.7)
        end
        
        -- Play the animation
        self.flashAnim:Play()
    end
    
    return frame
end

-- Update a cooldown preview with specified settings
function Styling:UpdateCooldownPreview(frame, timeLeft, fontInfo, colorInfo, positionInfo, isExpiring)
    -- Apply font settings
    if fontInfo then
        frame.text:SetFont(fontInfo.font or "Friz Quadrata TT", 
                           fontInfo.size or 14, 
                           fontInfo.flags or "OUTLINE")
    end
    
    -- Set the text
    frame.text:SetText(timeLeft < 10 and string.format("%.1f", timeLeft) or string.format("%d", floor(timeLeft)))
    
    -- Apply color settings
    if colorInfo then
        if isExpiring and colorInfo.expiring then
            frame.text:SetTextColor(
                colorInfo.expiring.r or 1, 
                colorInfo.expiring.g or 0, 
                colorInfo.expiring.b or 0, 
                colorInfo.expiring.a or 1
            )
        else
            frame.text:SetTextColor(
                colorInfo.r or 1, 
                colorInfo.g or 1, 
                colorInfo.b or 1, 
                colorInfo.a or 1
            )
        end
    end
    
    -- Apply position settings
    if positionInfo then
        frame.text:ClearAllPoints()
        frame.text:SetPoint(positionInfo.position or "CENTER", 
                          frame, 
                          positionInfo.position or "CENTER", 
                          positionInfo.xOffset or 0, 
                          positionInfo.yOffset or 0)
    end
end

-- Apply the currently previewed style to the addon settings
function Styling:ApplyCurrentPreviewStyle()
    local frame = self.previewFrame
    if not frame or not frame.currentStyle then return end
    
    local style = frame.currentStyle
    
    -- Get the database
    local db = CT:GetDB()
    if not db or not db.cooldownText then return end
    
    -- Apply font settings
    if style.fontInfo then
        db.cooldownText.textFont = style.fontInfo.font or db.cooldownText.textFont
        db.cooldownText.textSize = style.fontInfo.size or db.cooldownText.textSize
        db.cooldownText.textFlags = style.fontInfo.flags or db.cooldownText.textFlags
    end
    
    -- Apply color settings
    if style.colorInfo then
        -- Normal color
        db.cooldownText.normalColor = db.cooldownText.normalColor or {}
        db.cooldownText.normalColor.r = style.colorInfo.r or db.cooldownText.normalColor.r
        db.cooldownText.normalColor.g = style.colorInfo.g or db.cooldownText.normalColor.g
        db.cooldownText.normalColor.b = style.colorInfo.b or db.cooldownText.normalColor.b
        db.cooldownText.normalColor.a = style.colorInfo.a or db.cooldownText.normalColor.a
        
        -- Expiring color
        if style.colorInfo.expiring then
            db.cooldownText.expiringColor = db.cooldownText.expiringColor or {}
            db.cooldownText.expiringColor.r = style.colorInfo.expiring.r or db.cooldownText.expiringColor.r
            db.cooldownText.expiringColor.g = style.colorInfo.expiring.g or db.cooldownText.expiringColor.g
            db.cooldownText.expiringColor.b = style.colorInfo.expiring.b or db.cooldownText.expiringColor.b
            db.cooldownText.expiringColor.a = style.colorInfo.expiring.a or db.cooldownText.expiringColor.a
        end
    end
    
    -- Apply effect settings
    if style.effectInfo then
        db.cooldownText.finishEffects = db.cooldownText.finishEffects or {}
        db.cooldownText.finishEffects.enableFlash = style.effectInfo.flashEnabled
        
        if style.effectInfo.flashEnabled and style.effectInfo.flashColor then
            db.cooldownText.finishEffects.flashColor = db.cooldownText.finishEffects.flashColor or {}
            db.cooldownText.finishEffects.flashColor.r = style.effectInfo.flashColor.r
            db.cooldownText.finishEffects.flashColor.g = style.effectInfo.flashColor.g
            db.cooldownText.finishEffects.flashColor.b = style.effectInfo.flashColor.b
            db.cooldownText.finishEffects.flashColor.a = style.effectInfo.flashColor.a
        end
        
        if style.effectInfo.flashDuration then
            db.cooldownText.finishEffects.flashDuration = style.effectInfo.flashDuration
        end
    end
    
    -- Apply position settings
    if style.positionInfo then
        db.cooldownText.textPosition = style.positionInfo.position or db.cooldownText.textPosition
        db.cooldownText.xOffset = style.positionInfo.xOffset or db.cooldownText.xOffset
        db.cooldownText.yOffset = style.positionInfo.yOffset or db.cooldownText.yOffset
    end
    
    -- Update all active cooldowns
    CT:UpdateAllCooldowns(true)
    
    -- Save settings
    Phoenix_UI:SaveDB()
end

-- Register the module with the main CooldownTracker
function Styling:OnEnable()
    DebugLog("Styling module enabled")
    
    -- Apply theme colors on initial load
    if type(self.ApplyThemeColors) == "function" then
        self:ApplyThemeColors()
    end
    
    -- Register for theme changes if Phoenix_UI is available
    if type(Phoenix_UI) == "table" and type(Phoenix_UI.RegisterMessage) == "function" then
        Phoenix_UI:RegisterMessage("PHOENIX_UI_THEME_CHANGED", function()
            DebugLog("Theme changed event received")
            if type(self.ApplyThemeColors) == "function" then
                self:ApplyThemeColors()
            end
        end)
    end
    
    -- Register callbacks with main module
    if CT and type(CT.RegisterCallback) == "function" then
        CT:RegisterCallback("CooldownCreated", function(_, frame)
            self:RegisterCooldownFrame(frame)
        end)
        
        CT:RegisterCallback("StylesUpdated", function()
            self:UpdateAllStyles()
        end)
    end
    
    DebugLog("Styling module fully initialized")
end

-- Add method to update all styles
function Styling:UpdateAllStyles()
    local frames = CT:GetAllCooldownFrames()
    if not frames then return end
    
    for _, frame in pairs(frames) do
        self:RegisterCooldownFrame(frame)
    end
    
    DebugLog("Updated styles for all cooldown frames")
end

-- Make the module accessible to the main CooldownTracker
CT.Styling = Styling

-- Don't modify CT.OnEnable, use proper module initialization 