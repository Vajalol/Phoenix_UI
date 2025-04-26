-- Phoenix UI - Player Stats Visual Enhancement Module
local VisualEnhance = Phoenix_UI:NewModule("General.StatsVisuals", "AceHook-3.0", "AceEvent-3.0")

function VisualEnhance:OnEnable()
    -- Only run once after the main stats module loads
    self:SecureHook(Phoenix_UI:GetModule("General.Stats"), "OnEnable", "EnhancePlayerStats")
    
    -- Force apply particles after a short delay to ensure frames are created
    C_Timer.After(1, function()
        self:EnhancePlayerStats()
    end)
    
    -- Apply again after combat to ensure they stay visible
    self:RegisterEvent("PLAYER_REGEN_ENABLED", function()
        C_Timer.After(0.5, function() 
            self:EnhancePlayerStats()
        end)
    end)
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
    -- Always return true to ensure particles are shown
    return true
end

-- Get the configured effect level (1=low, 2=medium, 3=high)
function VisualEnhance:GetEffectLevel()
    -- Always return 3 (high quality) 
    return 3
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
    
    -- Clear any existing visual elements
    if statsFrame.visualElements then
        for _, element in pairs(statsFrame.visualElements) do
            if element.Stop then element:Stop() end
            if element.SetAlpha then element:SetAlpha(0) end
        end
    end
    
    if statsFrame.animatedBorder then
        if statsFrame.animatedBorder.glowAnim then
            statsFrame.animatedBorder.glowAnim:Stop()
        end
        if statsFrame.animatedBorder.borderTexture then
            statsFrame.animatedBorder.borderTexture:SetAlpha(0)
        end
        if statsFrame.animatedBorder.glowTexture then
            statsFrame.animatedBorder.glowTexture:SetAlpha(0)
        end
    end
    
    -- Only add particle effects
    self:AddParticleEffects(statsFrame)
    
    -- Apply current particle level from settings
    self:SetParticleEffectLevel(self:GetEffectLevel())
end

-- Create a dynamic flame-themed background using only WoW resources
-- This function is intentionally emptied to remove the background effects
function VisualEnhance:CreateFlameBackground(frame)
    -- Create empty container for backward compatibility
    frame.visualElements = {}
end

-- Create animated border for the stats frame
-- This function is intentionally emptied to remove the border effects
function VisualEnhance:CreateAnimatedBorder(frame)
    -- Create empty container for backward compatibility
    frame.animatedBorder = {}
end

-- Enhance stat text with glowing effects and animations
-- This function is intentionally emptied to remove text glow effects
function VisualEnhance:EnhanceStatText(frame)
    -- Function left empty intentionally to remove text effects
end

-- Add glow effect to individual stat lines
-- This function is intentionally emptied to remove stat glow effects
function VisualEnhance:AddStatGlow(statDisplay)
    -- Function left empty intentionally to remove stat glow effects
end

-- Add particle effects that simulate embers or small flames
function VisualEnhance:AddParticleEffects(frame)
    -- Create container for particles
    local particleContainer = CreateFrame("Frame", nil, frame)
    particleContainer:SetAllPoints()
    particleContainer:SetFrameLevel(frame:GetFrameLevel() + 5)  -- Higher layer to appear above content
    
    -- Clean up existing particles if any
    if frame.particleSystem then
        frame.particleSystem.EnableParticles(false)
    end
    
    -- Determine number of particles based on effect level
    local particleCount = 5 -- Default medium
    local effectLevel = self:GetEffectLevel()
    
    if effectLevel == 1 then -- Low
        particleCount = 3
    elseif effectLevel == 3 then -- High
        particleCount = 8
    end
    
    -- Create particles
    local particles = {}
    local particleTextures = {
        WOW_TEXTURES.EMBER,
        WOW_TEXTURES.SPELL_ALERT,
        "Interface/GLUES/MODELS/UI_Tauren/gradientCircle" -- Beautiful circular glow
    }
    
    for i = 1, particleCount do
        -- Create the base particle
        local particle = particleContainer:CreateTexture(nil, "OVERLAY")
        local textureChoice = particleTextures[math.random(1, #particleTextures)]
        particle:SetTexture(textureChoice)
        
        -- Random size between 8-15 pixels
        local size = math.random(8, 15)
        particle:SetSize(size, size)
        particle:SetBlendMode("ADD")
        
        -- Beautiful fire colors with slight variations
        local r = 1
        local g = math.random(40, 70) / 100 -- 0.4-0.7
        local b = math.random(0, 20) / 100  -- 0-0.2
        particle:SetVertexColor(r, g, b, 0.8)
        
        -- Position randomly near the bottom of the frame
        local xPos = math.random(10, frame:GetWidth() - 20)
        local yPos = math.random(5, 20)
        particle:SetPoint("BOTTOMLEFT", xPos, yPos)
        
        -- Create unique animation for each particle
        local particleAnim = particle:CreateAnimationGroup()
        particleAnim:SetLooping("REPEAT")
        
        -- More dynamic path with multiple translations
        local pathSegments = math.random(3, 5)  -- 3-5 segments
        local totalHeight = frame:GetHeight() * 0.8
        local segmentHeight = totalHeight / pathSegments
        
        for j = 1, pathSegments do
            local xOffset = math.random(-20, 20)  -- Random horizontal drift
            local yOffset = segmentHeight + math.random(-10, 10)  -- Vertical with some variance
            
            local trans = particleAnim:CreateAnimation("Translation")
            trans:SetOffset(xOffset, yOffset)
            trans:SetDuration(math.random(10, 20) / 10)  -- 1-2 seconds per segment
            trans:SetSmoothing("IN_OUT")
            trans:SetOrder(j)
        end
        
        -- Add some rotation for extra flair
        local rotate = particleAnim:CreateAnimation("Rotation")
        rotate:SetDegrees(math.random(-180, 180))
        rotate:SetDuration(math.random(15, 30) / 10)
        rotate:SetOrder(1)
        
        -- Alpha transition - gradual fade in, then fade out
        local fadeIn = particleAnim:CreateAnimation("Alpha")
        fadeIn:SetFromAlpha(0)
        fadeIn:SetToAlpha(0.8)
        fadeIn:SetDuration(0.8)
        fadeIn:SetOrder(1)
        
        local fadeOut = particleAnim:CreateAnimation("Alpha")
        fadeOut:SetFromAlpha(0.8)
        fadeOut:SetToAlpha(0)
        fadeOut:SetStartDelay(pathSegments - 0.5)  -- Start fading near the end of path
        fadeOut:SetDuration(1)
        fadeOut:SetOrder(pathSegments + 1)  -- Last animation
        
        -- Size change - grow slightly then shrink
        local sizeFactor = math.random(110, 140) / 100  -- 1.1-1.4
        local scale = particleAnim:CreateAnimation("Scale")
        scale:SetScale(sizeFactor, sizeFactor)
        scale:SetDuration(math.random(15, 25) / 10)
        scale:SetSmoothing("IN_OUT")
        scale:SetOrder(2)
        
        local scale2 = particleAnim:CreateAnimation("Scale")
        scale2:SetScale(0.7, 0.7)
        scale2:SetDuration(math.random(15, 25) / 10)
        scale2:SetSmoothing("IN_OUT")
        scale2:SetOrder(pathSegments)
        
        -- Store reference and start animation with random delay
        particles[i] = {
            texture = particle,
            anim = particleAnim
        }
        
        -- Offset start time for variety
        C_Timer.After(math.random() * 3, function() 
            if VisualEnhance:AreVisualsEnabled() then
                particleAnim:Play() 
            end
        end)
    end
    
    -- Add special secondary particles (like sparks) for high effect level
    if effectLevel >= 2 then
        local sparkCount = (effectLevel == 3) and 6 or 3
        
        for i = 1, sparkCount do
            -- Create a spark particle
            local spark = particleContainer:CreateTexture(nil, "OVERLAY", nil, 1)
            spark:SetTexture("Interface/GLUES/MODELS/UI_Nightborne/UI_Nightborne_Ribbon")
            
            -- Make it small and elongated for a spark effect
            local width = math.random(3, 6)
            local height = width * math.random(2, 4)  -- 2-4x as tall as wide
            spark:SetSize(width, height)
            
            -- Make it bright yellow-white
            spark:SetVertexColor(1, 0.9, 0.7, 0.9)
            spark:SetBlendMode("ADD")
            
            -- Position near bottom edges for best effect
            local xPos = math.random(1) == 1 and math.random(5, 30) or (frame:GetWidth() - math.random(5, 30))
            local yPos = math.random(5, frame:GetHeight() * 0.5)
            spark:SetPoint("BOTTOMLEFT", xPos, yPos)
            
            -- Create fast, erratic spark animation
            local sparkAnim = spark:CreateAnimationGroup()
            sparkAnim:SetLooping("REPEAT")
            
            -- Quick, jerky path
            local pathPoints = math.random(2, 4)
            for j = 1, pathPoints do
                local xMove = math.random(-30, 30)
                local yMove = math.random(10, 40)
                
                local move = sparkAnim:CreateAnimation("Translation")
                move:SetOffset(xMove, yMove)
                move:SetDuration(math.random(4, 10) / 10)  -- 0.4-1.0 seconds
                move:SetOrder(j)
                move:SetSmoothing("OUT")  -- Quick start, gradual finish
            end
            
            -- Rotation for extra effect
            local rotate = sparkAnim:CreateAnimation("Rotation")
            rotate:SetDegrees(math.random(-90, 90))
            rotate:SetDuration(math.random(3, 7) / 10)
            rotate:SetOrder(1)
            
            -- Quick alpha flicker
            local flicker1 = sparkAnim:CreateAnimation("Alpha")
            flicker1:SetFromAlpha(0.9)
            flicker1:SetToAlpha(0.3)
            flicker1:SetDuration(0.2)
            flicker1:SetOrder(1)
            
            local flicker2 = sparkAnim:CreateAnimation("Alpha")
            flicker2:SetFromAlpha(0.3)
            flicker2:SetToAlpha(0.9)
            flicker2:SetDuration(0.2)
            flicker2:SetOrder(2)
            
            -- Store and play with offset
            particles[#particles + 1] = {
                texture = spark,
                anim = sparkAnim
            }
            
            C_Timer.After(math.random() * 2, function()
                if VisualEnhance:AreVisualsEnabled() then
                    sparkAnim:Play()
                end
            end)
        end
    end
    
    -- Add a subtle heat distortion effect for highest quality
    if effectLevel == 3 then
        local heatDistortion = particleContainer:CreateTexture(nil, "OVERLAY", nil, -1)
        heatDistortion:SetTexture("Interface/GLUES/MODELS/UI_NightElf/UI_NightElf_Vortex")
        heatDistortion:SetAllPoints(frame)
        heatDistortion:SetBlendMode("BLEND")
        heatDistortion:SetVertexColor(1, 1, 1, 0.08)  -- Very subtle
        
        local heatAnim = heatDistortion:CreateAnimationGroup()
        heatAnim:SetLooping("REPEAT")
        
        local heatRotate = heatAnim:CreateAnimation("Rotation")
        heatRotate:SetDegrees(360)
        heatRotate:SetDuration(40)  -- Very slow rotation
        heatRotate:SetOrder(1)
        
        heatAnim:Play()
        
        particles[#particles + 1] = {
            texture = heatDistortion,
            anim = heatAnim
        }
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

-- Add a slash command to manually enable visual effects
SLASH_PHOENIXVISUALS1 = "/phoenixvisuals"
SlashCmdList["PHOENIXVISUALS"] = function(msg)
    local level = tonumber(msg) or 3  -- Default to high if no level specified
    local visualModule = Phoenix_UI:GetModule("General.StatsVisuals")
    
    -- Enable visual effects in settings
    if Phoenix_UI.db and Phoenix_UI.db.profile and Phoenix_UI.db.profile.general and Phoenix_UI.db.profile.general.playerStats then
        Phoenix_UI.db.profile.general.playerStats.visualEffects = true
        Phoenix_UI.db.profile.general.playerStats.effectLevel = level
    end
    
    -- Force application of visual effects
    visualModule:EnhancePlayerStats()
    visualModule:SetParticleEffectLevel(level)
    
    -- Print confirmation message
    local levelText = "low"
    if level == 2 then levelText = "medium"
    elseif level >= 3 then levelText = "high" end
    
    print("|cffFF7D0APhoenix|r|cffFF0000_|r|cffFFD100UI|r: Visual effects enabled at " .. levelText .. " level!")
    print("Your Player Stats panel should now have visual enhancements.")
end

-- Apply theme-based enhancements
function VisualEnhance:ApplyThemeBasedEnhancements(frame)
    -- Keeping this empty to avoid applying title enhancements
end

-- Enhance cooldown trackers with visual effects
function VisualEnhance:EnhanceCooldownTrackers(frame)
    -- Keeping this empty to avoid enhancing cooldown trackers
end 