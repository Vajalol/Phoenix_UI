-- Phoenix UI - Player Stats Visual Enhancement Module
local VisualEnhance = Phoenix_UI:NewModule("General.StatsVisuals", "AceHook-3.0")

function VisualEnhance:OnEnable()
    -- Only run once after the main stats module loads
    self:SecureHook(Phoenix_UI:GetModule("General.Stats"), "OnEnable", "EnhancePlayerStats")
end

-- WoW built-in spell effects for enhancement visuals
local WOW_TEXTURES = {
    SPELL_ALERT = "Interface/SpellActivationOverlay/IconAlert",
    SPELL_GLOW = "Interface/AchievementFrame/UI-Achievement-Reward-Glow",  
    TALENT_GLOW = "Interface/Artifacts/ArtifactPower-QuestBorder",
    DRAGONFLIGHT_GLOW = "Interface/PVPFrame/PVPPrestige",
    COVENANT_BORDER = "Interface/Covenant/CovenantCallings/CallingObjectiveFillNight",
    EMBER = "Interface/Buttons/CheckButtonHilight",
    RARE_BORDER = "Interface/Collections/CollectionsBackgroundRareBorder",
    MYTHIC_PLUS = "Interface/Challenges/ChallengeMode_Medal",
    ITEM_QUALITY = "Interface/GuildBank/ItemQuality", -- Rare/Epic quality glow
    GOLD_TRIM = "Interface/Calendar/EventNotificationGlow"
}

-- Check if visual effects are enabled in settings
function VisualEnhance:AreVisualsEnabled()
    -- Default to enabled
    if not Phoenix_UI.db or not Phoenix_UI.db.profile or not Phoenix_UI.db.profile.general then
        return true
    end
    
    return Phoenix_UI.db.profile.general.playerStats and 
           Phoenix_UI.db.profile.general.playerStats.visualEffects ~= false
end

-- Get the configured effect level (1=low, 2=medium, 3=high)
function VisualEnhance:GetEffectLevel()
    if not Phoenix_UI.db or not Phoenix_UI.db.profile or 
       not Phoenix_UI.db.profile.general or not Phoenix_UI.db.profile.general.playerStats then
        return 2 -- Default to medium
    end
    
    return Phoenix_UI.db.profile.general.playerStats.effectLevel or 2
end

-- Function to create and attach visual enhancements to the player stats panel
function VisualEnhance:EnhancePlayerStats()
    -- Get the player stats frame
    local statsFrame = _G.Phoenix_PlayerStatsFrame
    if not statsFrame then
        -- Schedule a retry if the frame isn't created yet
        C_Timer.After(1, function() self:EnhancePlayerStats() end)
        return
    end
    
    -- If visual effects are disabled in settings, don't apply them
    if not self:AreVisualsEnabled() then
        return
    end
    
    -- Create a fire-themed background
    self:CreateFlameBackground(statsFrame)
    
    -- Enhance the stat display with glowing effects
    self:EnhanceStatText(statsFrame)
    
    -- Add animated border
    self:CreateAnimatedBorder(statsFrame)
    
    -- Add particle effects based on effect level
    self:AddParticleEffects(statsFrame)
    
    -- Add stat pulse animations on value changes
    self:AddStatPulseEffects()
    
    -- Hook update to refresh visual effects
    self:ApplyThemeBasedEnhancements(statsFrame)
    
    -- Apply current particle level from settings
    self:SetParticleEffectLevel(self:GetEffectLevel())
end

-- Create a dynamic flame-themed background using only WoW resources
function VisualEnhance:CreateFlameBackground(frame)
    -- Add a darkened background texture
    local darkBg = frame:CreateTexture("PhoenixStats_DarkBg", "BACKGROUND")
    darkBg:SetTexture("Interface/EncounterJournal/UI-EJ-Header")
    darkBg:SetAllPoints()
    darkBg:SetTexCoord(0, 1, 0, 0.5)
    darkBg:SetVertexColor(0.1, 0.05, 0.05, 0.95)
    
    -- Add glowing ember effect
    local emberGlow = frame:CreateTexture("PhoenixStats_EmberGlow", "BACKGROUND", nil, 1)
    emberGlow:SetTexture(WOW_TEXTURES.EMBER)
    emberGlow:SetSize(frame:GetWidth() * 1.5, frame:GetHeight() * 1.5)
    emberGlow:SetPoint("CENTER")
    emberGlow:SetBlendMode("ADD")
    emberGlow:SetVertexColor(0.7, 0.3, 0.1, 0.3)
    
    -- Create ember glow animation
    local emberAnim = emberGlow:CreateAnimationGroup()
    emberAnim:SetLooping("REPEAT")
    
    -- Scale animation
    local scale1 = emberAnim:CreateAnimation("Scale")
    scale1:SetScale(1.05, 1.05)
    scale1:SetDuration(3)
    scale1:SetSmoothing("IN_OUT")
    scale1:SetOrder(1)
    
    local scale2 = emberAnim:CreateAnimation("Scale")
    scale2:SetScale(0.95, 0.95)
    scale2:SetDuration(3)
    scale2:SetSmoothing("IN_OUT")
    scale2:SetOrder(2)
    
    -- Alpha pulsing animation
    local fade1 = emberAnim:CreateAnimation("Alpha")
    fade1:SetFromAlpha(0.3)
    fade1:SetToAlpha(0.5)
    fade1:SetDuration(2.5)
    fade1:SetSmoothing("IN_OUT")
    fade1:SetOrder(1)
    
    local fade2 = emberAnim:CreateAnimation("Alpha")
    fade2:SetFromAlpha(0.5)
    fade2:SetToAlpha(0.3)
    fade2:SetDuration(2.5)
    fade2:SetSmoothing("IN_OUT")
    fade2:SetOrder(2)
    
    emberAnim:Play()
    
    -- Add flame effect overlay
    local flameOverlay = frame:CreateTexture("PhoenixStats_FlameOverlay", "BACKGROUND", nil, 2)
    flameOverlay:SetTexture(WOW_TEXTURES.COVENANT_BORDER)
    flameOverlay:SetPoint("TOPLEFT", 0, 0)
    flameOverlay:SetPoint("BOTTOMRIGHT", 0, 0)
    flameOverlay:SetVertexColor(1, 0.4, 0.1, 0.2)
    flameOverlay:SetBlendMode("ADD")
    
    -- Create flame animation
    local flameAnim = flameOverlay:CreateAnimationGroup()
    flameAnim:SetLooping("REPEAT")
    
    -- Add subtle movement to flame effect
    local translation = flameAnim:CreateAnimation("Translation")
    translation:SetOffset(0, 5)
    translation:SetDuration(4)
    translation:SetSmoothing("IN_OUT")
    translation:SetOrder(1)
    
    local translation2 = flameAnim:CreateAnimation("Translation")
    translation2:SetOffset(0, -5)
    translation2:SetDuration(4)
    translation2:SetSmoothing("IN_OUT")
    translation2:SetOrder(2)
    
    -- Alpha animation
    local flameAlpha1 = flameAnim:CreateAnimation("Alpha")
    flameAlpha1:SetFromAlpha(0.2)
    flameAlpha1:SetToAlpha(0.3)
    flameAlpha1:SetDuration(3)
    flameAlpha1:SetOrder(1)
    
    local flameAlpha2 = flameAnim:CreateAnimation("Alpha")
    flameAlpha2:SetFromAlpha(0.3)
    flameAlpha2:SetToAlpha(0.2)
    flameAlpha2:SetDuration(3)
    flameAlpha2:SetOrder(2)
    
    flameAnim:Play()
    
    -- Store references for later updates
    frame.visualElements = {
        darkBg = darkBg,
        emberGlow = emberGlow,
        emberAnim = emberAnim,
        flameOverlay = flameOverlay,
        flameAnim = flameAnim
    }
end

-- Enhance stat text with glowing effects and animations
function VisualEnhance:EnhanceStatText(frame)
    local stats = Phoenix_UI:GetModule("General.Stats")
    if not stats or not stats.contentFrame then return end
    
    local contentFrame = stats.contentFrame
    
    -- Create a 'heat' overlay for stats that changes based on stat values
    for _, statDisplay in ipairs(stats.primaryStats or {}) do
        self:AddStatGlow(statDisplay)
    end
    
    for _, statDisplay in ipairs(stats.secondaryStats or {}) do
        self:AddStatGlow(statDisplay)
    end
end

-- Add glow effect to individual stat lines
function VisualEnhance:AddStatGlow(statDisplay)
    if not statDisplay then return end
    
    -- Create highlight effect
    local highlight = statDisplay:CreateTexture(nil, "BACKGROUND")
    highlight:SetTexture(WOW_TEXTURES.ITEM_QUALITY)
    highlight:SetPoint("TOPLEFT", -5, 5)
    highlight:SetPoint("BOTTOMRIGHT", 5, -5)
    highlight:SetAlpha(0)
    highlight:SetBlendMode("ADD")
    
    -- Store original Update function
    local originalUpdate = statDisplay.Update
    
    -- Override with enhanced update that adjusts visuals based on value
    statDisplay.Update = function()
        -- Call original update
        originalUpdate()
        
        -- Only apply visual effect if enabled in settings
        if not VisualEnhance:AreVisualsEnabled() then
            highlight:SetAlpha(0)
            return
        end
        
        -- Get raw value from display if possible
        local rawValue = statDisplay.previousValue or 0
        
        -- Adjust highlight based on value
        local alphaValue = math.min(rawValue / 20000, 1) * 0.5 -- Scale to max 0.5 alpha
        local r, g, b = 1, 0.3, 0
        
        -- Different colors for different stat types
        if statDisplay.valueText:GetText():match("Crit") then
            r, g, b = 1, 0.3, 0.1
        elseif statDisplay.valueText:GetText():match("Haste") then
            r, g, b = 1, 0.9, 0.1
        elseif statDisplay.valueText:GetText():match("Mastery") then
            r, g, b = 0.1, 0.5, 1
        elseif statDisplay.valueText:GetText():match("Versatility") then
            r, g, b = 0.1, 1, 0.3
        end
        
        highlight:SetVertexColor(r, g, b)
        highlight:SetAlpha(alphaValue)
        
        -- Store the adjusted glow data
        statDisplay.statHighlight = highlight
    end
    
    -- Create a mouseover highlight effect
    statDisplay:HookScript("OnEnter", function()
        if not VisualEnhance:AreVisualsEnabled() then return end
        
        if statDisplay.statHighlight then
            statDisplay.statHighlight:SetAlpha(math.min((statDisplay.statHighlight:GetAlpha() + 0.3), 0.8))
        end
    end)
    
    statDisplay:HookScript("OnLeave", function()
        if not VisualEnhance:AreVisualsEnabled() then return end
        
        if statDisplay.statHighlight then
            -- Restore to the calculated value based on stat
            local rawValue = statDisplay.previousValue or 0
            local alphaValue = math.min(rawValue / 20000, 1) * 0.5
            statDisplay.statHighlight:SetAlpha(alphaValue)
        end
    end)
end

-- Create animated border for the stats frame
function VisualEnhance:CreateAnimatedBorder(frame)
    -- Create frame for animated border
    local border = CreateFrame("Frame", nil, frame)
    border:SetPoint("TOPLEFT", -3, 3)
    border:SetPoint("BOTTOMRIGHT", 3, -3)
    border:SetFrameLevel(frame:GetFrameLevel() + 1)
    
    -- Use a high quality border texture
    local borderTexture = border:CreateTexture(nil, "OVERLAY")
    borderTexture:SetTexture(WOW_TEXTURES.RARE_BORDER)
    borderTexture:SetAllPoints()
    borderTexture:SetVertexColor(0.8, 0.4, 0.1, 0.7)
    
    -- Animated glow overlay
    local glowTexture = border:CreateTexture(nil, "OVERLAY", nil, 1)
    glowTexture:SetTexture(WOW_TEXTURES.GOLD_TRIM)
    glowTexture:SetAllPoints()
    glowTexture:SetBlendMode("ADD")
    glowTexture:SetVertexColor(1, 0.6, 0.1, 0.3)
    
    -- Create animation for the glow
    local glowAnim = glowTexture:CreateAnimationGroup()
    glowAnim:SetLooping("REPEAT")
    
    -- Rotation animation
    local rotation = glowAnim:CreateAnimation("Rotation")
    rotation:SetDegrees(360)
    rotation:SetDuration(12)
    rotation:SetOrder(1)
    
    -- Alpha animation
    local glowAlpha1 = glowAnim:CreateAnimation("Alpha")
    glowAlpha1:SetFromAlpha(0.3)
    glowAlpha1:SetToAlpha(0.5)
    glowAlpha1:SetDuration(6)
    glowAlpha1:SetOrder(1)
    
    local glowAlpha2 = glowAnim:CreateAnimation("Alpha")
    glowAlpha2:SetFromAlpha(0.5)
    glowAlpha2:SetToAlpha(0.3)
    glowAlpha2:SetDuration(6)
    glowAlpha2:SetOrder(2)
    
    glowAnim:Play()
    
    -- Store reference
    frame.animatedBorder = {
        border = border,
        borderTexture = borderTexture,
        glowTexture = glowTexture,
        glowAnim = glowAnim
    }
end

-- Add particle effects that simulate embers or small flames
function VisualEnhance:AddParticleEffects(frame)
    -- Create container for particles
    local particleContainer = CreateFrame("Frame", nil, frame)
    particleContainer:SetAllPoints()
    particleContainer:SetFrameLevel(frame:GetFrameLevel() + 2)
    
    -- Determine number of particles based on effect level
    local particleCount = 3 -- Default medium
    local effectLevel = self:GetEffectLevel()
    
    if effectLevel == 1 then -- Low
        particleCount = 2
    elseif effectLevel == 3 then -- High
        particleCount = 5
    end
    
    -- Create particles
    local particles = {}
    for i = 1, particleCount do
        local particle = particleContainer:CreateTexture(nil, "OVERLAY")
        particle:SetTexture(WOW_TEXTURES.EMBER)
        particle:SetSize(10, 10)
        particle:SetBlendMode("ADD")
        particle:SetVertexColor(1, 0.6, 0.1, 0.7)
        particle:SetPoint("BOTTOMLEFT", math.random(20, frame:GetWidth() - 40), math.random(10, 30))
        
        -- Create unique animation for each particle
        local particleAnim = particle:CreateAnimationGroup()
        particleAnim:SetLooping("REPEAT")
        
        -- Path animation
        local path = particleAnim:CreateAnimation("Path")
        path:SetDuration(math.random(4, 8))
        
        -- Add control points for the path (rising flame path)
        local maxHeight = math.random(frame:GetHeight() * 0.5, frame:GetHeight() * 0.8)
        
        path:SetCurve("SMOOTH")
        
        -- Add control points to create a rising, swaying motion
        local controls = {}
        path:SetMaxPoints(3)
        
        path:SetPoint(1, 0, 0) -- Start at origin
        path:SetPoint(2, math.random(-20, 20), maxHeight * 0.5) -- Middle control point with horizontal sway
        path:SetPoint(3, math.random(-30, 30), maxHeight) -- End point, higher with more sway
        
        -- Alpha transition
        local fadeIn = particleAnim:CreateAnimation("Alpha")
        fadeIn:SetFromAlpha(0)
        fadeIn:SetToAlpha(0.7)
        fadeIn:SetDuration(math.random(1, 2))
        fadeIn:SetOrder(1)
        
        local fadeOut = particleAnim:CreateAnimation("Alpha")
        fadeOut:SetFromAlpha(0.7)
        fadeOut:SetToAlpha(0)
        fadeOut:SetStartDelay(path:GetDuration() - 2)
        fadeOut:SetDuration(2)
        fadeOut:SetOrder(2)
        
        -- Size change
        local sizeFactor = math.random(80, 120) / 100 -- Random scale 0.8-1.2
        local scale = particleAnim:CreateAnimation("Scale")
        scale:SetScale(sizeFactor, sizeFactor)
        scale:SetDuration(path:GetDuration())
        scale:SetOrder(1)
        
        -- Store reference and start animation
        particles[i] = {
            texture = particle,
            anim = particleAnim
        }
        
        -- Offset start time for variety
        C_Timer.After(math.random() * 2, function() 
            if VisualEnhance:AreVisualsEnabled() then
                particleAnim:Play() 
            end
        end)
    end
    
    -- Enable or disable particle system
    particleContainer.EnableParticles = function(enable)
        for _, particle in ipairs(particles) do
            if enable then
                particle.anim:Play()
            else
                particle.anim:Stop()
                particle.texture:SetAlpha(0)
            end
        end
    end
    
    frame.particleSystem = particleContainer
end

-- Add pulse effects for stat value changes
function VisualEnhance:AddStatPulseEffects()
    local stats = Phoenix_UI:GetModule("General.Stats")
    if not stats then return end
    
    -- Process both primary and secondary stats
    local allStats = {}
    for _, stat in ipairs(stats.primaryStats or {}) do
        table.insert(allStats, stat)
    end
    for _, stat in ipairs(stats.secondaryStats or {}) do
        table.insert(allStats, stat)
    end
    
    -- Add pulse animation to each stat
    for _, statDisplay in ipairs(allStats) do
        -- Only proceed if we haven't already enhanced this stat
        if not statDisplay.pulseEffect then
            -- Save original Update function
            local originalUpdate = statDisplay.Update
            
            -- Override with enhanced version
            statDisplay.Update = function()
                -- Get previous value for comparison
                local oldValue = statDisplay.previousValue or 0
                
                -- Call original update (which will update previousValue)
                originalUpdate()
                
                -- Only continue if visuals are enabled
                if not VisualEnhance:AreVisualsEnabled() then return end
                
                -- If value changed significantly (more than 1%), trigger pulse
                if oldValue > 0 and statDisplay.previousValue > 0 and 
                   math.abs((statDisplay.previousValue - oldValue) / oldValue) > 0.01 then
                    -- Determine if it's an increase or decrease
                    local isIncrease = statDisplay.previousValue > oldValue
                    
                    -- Create pulse effect if it doesn't exist
                    if not statDisplay.pulseEffect then
                        local pulse = statDisplay:CreateTexture(nil, "OVERLAY")
                        pulse:SetTexture(WOW_TEXTURES.SPELL_ALERT)
                        pulse:SetTexCoord(0.00781250, 0.50781250, 0.27734375, 0.52734375)
                        pulse:SetPoint("TOPLEFT", -15, 5)
                        pulse:SetPoint("BOTTOMRIGHT", 15, -5)
                        pulse:SetBlendMode("ADD")
                        pulse:SetAlpha(0)
                        statDisplay.pulseEffect = pulse
                    end
                    
                    -- Set color based on increase/decrease
                    if isIncrease then
                        statDisplay.pulseEffect:SetVertexColor(0.1, 0.9, 0.1)
                    else
                        statDisplay.pulseEffect:SetVertexColor(0.9, 0.1, 0.1)
                    end
                    
                    -- Create and play a one-shot animation
                    local anim = statDisplay.pulseEffect:CreateAnimationGroup()
                    anim:SetToFinalAlpha(true)
                    
                    -- Alpha animation (fade in then out)
                    local fadeIn = anim:CreateAnimation("Alpha")
                    fadeIn:SetFromAlpha(0)
                    fadeIn:SetToAlpha(0.7)
                    fadeIn:SetDuration(0.3)
                    fadeIn:SetOrder(1)
                    
                    local hold = anim:CreateAnimation("Alpha")
                    hold:SetFromAlpha(0.7)
                    hold:SetToAlpha(0.7)
                    hold:SetDuration(0.2)
                    hold:SetOrder(2)
                    
                    local fadeOut = anim:CreateAnimation("Alpha")
                    fadeOut:SetFromAlpha(0.7)
                    fadeOut:SetToAlpha(0)
                    fadeOut:SetDuration(0.5)
                    fadeOut:SetOrder(3)
                    
                    anim:Play()
                end
            end
        end
    end
end

-- Apply theme-based enhancements
function VisualEnhance:ApplyThemeBasedEnhancements(frame)
    -- Revamp the title bar with a more dramatic look
    local titleBar = frame:GetChildren() and select(1, frame:GetChildren())
    if titleBar and titleBar:GetChildren() then
        -- Find title text
        for i = 1, titleBar:GetNumRegions() do
            local region = select(i, titleBar:GetRegions())
            if region and region:GetObjectType() == "FontString" then
                local titleText = region
                
                -- Enhance the title with a flame effect
                local titleGlow = titleBar:CreateTexture(nil, "OVERLAY")
                titleGlow:SetTexture(WOW_TEXTURES.SPELL_ALERT)
                titleGlow:SetTexCoord(0.00781250, 0.50781250, 0.27734375, 0.52734375)
                titleGlow:SetPoint("TOPLEFT", titleText, "TOPLEFT", -15, 5)
                titleGlow:SetPoint("BOTTOMRIGHT", titleText, "BOTTOMRIGHT", 15, -5)
                titleGlow:SetBlendMode("ADD")
                titleGlow:SetAlpha(0.5)
                titleGlow:SetVertexColor(1, 0.6, 0.1)
                
                -- Add animation
                local titleAnim = titleGlow:CreateAnimationGroup()
                titleAnim:SetLooping("REPEAT")
                
                local pulse1 = titleAnim:CreateAnimation("Alpha")
                pulse1:SetFromAlpha(0.5)
                pulse1:SetToAlpha(0.8)
                pulse1:SetDuration(1.5)
                pulse1:SetOrder(1)
                
                local pulse2 = titleAnim:CreateAnimation("Alpha")
                pulse2:SetFromAlpha(0.8)
                pulse2:SetToAlpha(0.5)
                pulse2:SetDuration(1.5)
                pulse2:SetOrder(2)
                
                if self:AreVisualsEnabled() then
                    titleAnim:Play()
                end
                
                -- Store reference
                frame.titleEnhancement = {
                    glow = titleGlow,
                    anim = titleAnim
                }
                
                break
            end
        end
    end
    
    -- Add CD tracker visual enhancements
    self:EnhanceCooldownTrackers(frame)
end

-- Enhance cooldown trackers with visual effects
function VisualEnhance:EnhanceCooldownTrackers(frame)
    local stats = Phoenix_UI:GetModule("General.Stats")
    if not stats or not stats.cooldownRow then return end
    
    -- Add pulsing glow to ready cooldowns
    for _, icon in ipairs(stats.cooldownRow or {}) do
        if icon.cooldown and icon.ready then
            -- Create glow effect for ready cooldowns
            local readyGlow = icon:CreateTexture(nil, "OVERLAY")
            readyGlow:SetTexture(WOW_TEXTURES.SPELL_GLOW)
            readyGlow:SetPoint("CENTER")
            readyGlow:SetSize(icon:GetWidth() * 2, icon:GetHeight() * 2)
            readyGlow:SetBlendMode("ADD")
            readyGlow:SetVertexColor(1, 0.8, 0.2, 0)
            
            -- Create pulsing animation
            local readyAnim = readyGlow:CreateAnimationGroup()
            readyAnim:SetLooping("REPEAT")
            
            local pulse1 = readyAnim:CreateAnimation("Alpha")
            pulse1:SetFromAlpha(0.0)
            pulse1:SetToAlpha(0.7)
            pulse1:SetDuration(1)
            pulse1:SetOrder(1)
            
            local pulse2 = readyAnim:CreateAnimation("Alpha")
            pulse2:SetFromAlpha(0.7)
            pulse2:SetToAlpha(0.0)
            pulse2:SetDuration(1)
            pulse2:SetOrder(2)
            
            -- Hook cooldown finish to show glow
            if icon.cooldown then
                icon.cooldown:HookScript("OnCooldownDone", function()
                    if VisualEnhance:AreVisualsEnabled() then
                        readyGlow:SetAlpha(0.7)
                        readyAnim:Play()
                    else
                        readyGlow:SetAlpha(0)
                        readyAnim:Stop()
                    end
                end)
            end
            
            -- Start animation if already ready and visuals enabled
            if icon.ready:GetText() == "Ready" and self:AreVisualsEnabled() then
                readyAnim:Play()
            end
        end
    end
end

-- Function to toggle particle effects based on performance settings
function VisualEnhance:SetParticleEffectLevel(level)
    local statsFrame = _G.Phoenix_PlayerStatsFrame
    if not statsFrame or not statsFrame.particleSystem then return end
    
    -- If visuals are disabled globally, turn everything off
    if not self:AreVisualsEnabled() then
        statsFrame.particleSystem.EnableParticles(false)
        return
    end
    
    -- level can be 0 (off), 1 (low), 2 (medium), 3 (high)
    if level <= 0 then
        -- Turn off particle effects
        statsFrame.particleSystem.EnableParticles(false)
    else
        -- Turn on particle effects
        statsFrame.particleSystem.EnableParticles(true)
    end
end

-- The module will be initialized by the addon system automatically
-- Removing direct call to OnEnable here 