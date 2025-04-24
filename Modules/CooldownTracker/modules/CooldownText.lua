-- Phoenix_UI: CooldownText Module
-- Provides OmniCC-like functionality for cooldown text
-- Complete feature implementation to match original addon

local Module = Phoenix_UI:NewModule("CooldownTracker.CooldownText");
local LSM = LibStub("LibSharedMedia-3.0", true)
local LibCustomGlow = LibStub("LibCustomGlow-1.0", true)

-- Constants for time units
local SECOND = 1
local MINUTE = 60
local HOUR = 3600
local DAY = 86400

-- Optimization: Create locals for frequently used functions
local pairs, ipairs = pairs, ipairs
local floor, ceil, format = math.floor, math.ceil, string.format
local min, max = math.min, math.max
local GetTime = GetTime
local tostring, tonumber = tostring, tonumber
local wipe, tinsert = wipe, table.insert

-- Local storage
local settings = {}                -- Settings for the module
local activeCooldowns = {}         -- Track active cooldowns
local blacklistedCooldowns = {}    -- Track blacklisted cooldowns
local soundCache = {}              -- Cache sound files
local hookedCooldown = false       -- Track if we've hooked the cooldown system
local effectsEnabled = true        -- Track if effects are enabled

-- Performance optimization
local inCombat = false
local performanceMode = false
local nextUpdate = 0
local updateThrottle = 0.05
local heavyLoad = false

-- Color references for cooldown text
local dayColorHex
local hourColorHex
local minuteColorHex
local secondsColorHex
local expiringColorHex

-- Lookup tables for cooldown formatting
local dayText, hourText, minuteText, secondsText = "d", "h", "m", "s"

-- Track all managed cooldowns
local frameRules = {}

-- Frame type detection patterns
local frameTypePatterns = {
    actionBar = {
        "ActionButton", "MultiBarButton", "BT4Button", "ElvUI_Bar", "DominosActionButton", "ButtonForge",
        "LibActionButton", "bartender4", "Button4", "BongosActionButton"
    },
    aura = {
        "DebuffFrame", "BuffFrame", "AuraFrame", "TemporaryEnchantFrame", "ElvUIAura",
        "SUFAura", "Aura"
    },
    unitFrame = {
        "CompactRaidFrame", "RaidFrame", "PartyFrame", "PlayerFrame", "TargetFrame", "FocusFrame",
        "ElvUF_", "SUF", "PitBull4", "RUF", "oUF", "Grid2"
    },
    nameplate = {
        "NamePlate", "ElvNamePlate", "Plater", "NPlate", "nameplate"
    }
}

-- Function to detect frame type
local function GetFrameType(frame)
    if not frame or not frame:GetName() then return "unknown" end
    local name = frame:GetName()
    
    for frameType, patterns in pairs(frameTypePatterns) do
        for _, pattern in ipairs(patterns) do
            if name:find(pattern) then
                return frameType
            end
        end
    end
    
    return "unknown"
end

-- Get rule settings for frame with enhanced rule detection
local function GetRuleSettings(frame)
    if not frame then return nil end
    
    local frameType = GetFrameType(frame)
    local size = min(frame:GetWidth(), frame:GetHeight())
    
    -- Check if the frame is too small to show text
    if settings.rules.minSize and size < settings.rules.minSize then
        return { enabled = false }
    end
    
    local rule = {}
    
    if frameType == "actionBar" and settings.rules.actionBar then
        rule = settings.rules.actionBar
    elseif frameType == "aura" and settings.rules.auras then
        rule = settings.rules.auras
    elseif frameType == "unitFrame" and settings.rules.unitFrames then
        rule = settings.rules.unitFrames
    elseif frameType == "nameplate" and settings.rules.nameplates then
        rule = settings.rules.nameplates
    elseif frameType == "bags" and settings.rules.bags then
        rule = settings.rules.bags
    else
        -- Default settings
        rule = {
            enabled = true,
            scale = 1.0
        }
    end
    
    -- Apply minimum scale for very small cooldowns
    if settings.rules.minScale and size < 25 then
        rule.scale = settings.rules.minScale
    end
    
    return rule
end

-- Format the cooldown time with color and appropriate units based on remaining time
local function FormatCooldownTime(timeLeft, rule)
    if not timeLeft or type(timeLeft) ~= "number" then return "" end
    
    -- Get rule-specific settings (with fallback to global)
    local ruleSettings = rule or {}
    
    -- Check for expiring status - apply expiring color if needed
    if timeLeft <= (settings.expiringDuration or 3) then
        -- Format for expiring cooldowns (<3s) with tenths precision
        if timeLeft <= (settings.tenthsDuration or 5) and timeLeft > 0 then
            -- Format with one decimal place for very short cooldowns
            return expiringColorHex .. string.format("%.1f", timeLeft) .. "|r"
        end
        return expiringColorHex .. math.floor(timeLeft + 0.5) .. "|r"
    end
    
    -- Format based on time range with appropriate colors and formats
    if timeLeft >= DAY then
        -- Days format (>1 day)
        local days = math.floor(timeLeft / DAY)
        return dayColorHex .. string.format(settings.formatSettings and settings.formatSettings.day or "%dd", days) .. "|r"
    
    elseif timeLeft >= HOUR then
        -- Hours format (>1 hour)
        local hours = math.floor(timeLeft / HOUR)
        return hourColorHex .. string.format(settings.formatSettings and settings.formatSettings.hour or "%dh", hours) .. "|r"
    
    elseif timeLeft >= MINUTE then
        -- Minutes format (>1 minute)
        if timeLeft >= MINUTE * 10 or timeLeft <= settings.mmSSDuration then
            -- For >10 minutes, just show the minutes
            local minutes = math.floor(timeLeft / MINUTE)
            return minuteColorHex .. string.format(settings.formatSettings and settings.formatSettings.minute or "%dm", minutes) .. "|r"
        else
            -- For <10 minutes, show minutes:seconds
            local minutes = math.floor(timeLeft / MINUTE)
            local seconds = math.floor(timeLeft % MINUTE)
            local formatStr = settings.formatSettings and settings.formatSettings.shortMinute or "%d:%02d"
            return minuteColorHex .. string.format(formatStr, minutes, seconds) .. "|r"
        end
    
    elseif timeLeft >= settings.tenthsDuration then
        -- Just seconds, no decimal
        return secondsColorHex .. math.floor(timeLeft + 0.5) .. "|r"
    
    elseif timeLeft > 0 then
        -- Tenths of seconds for very short cooldowns
        return secondsColorHex .. string.format("%.1f", timeLeft) .. "|r"
    else
        -- Fallback for zero or negative time
        return ""
    end
end

-- Utility function to convert RGB to hex code
function RGBToHex(r, g, b)
    return string.format("%02x%02x%02x", r*255, g*255, b*255)
end

-- Get font path with multiple fallbacks to ensure a valid font is always used
local function GetFontPath()
    -- First, try to get font from settings
    if settings and settings.fontFace and settings.fontFace ~= "" then
        return settings.fontFace
    end
    
    -- Next, try to get font from LSM if available
    if LSM then
        local fontPath = LSM:Fetch("font", "Expressway")
        if fontPath and fontPath ~= "" then
            return fontPath
        end
    end
    
    -- Try Phoenix_UI's global fonts
    if Phoenix_UI and Phoenix_UI.Media and Phoenix_UI.Media.Fonts then
        if Phoenix_UI.Media.Fonts.Normal and Phoenix_UI.Media.Fonts.Normal ~= "" then
            return Phoenix_UI.Media.Fonts.Normal
        end
    end
    
    -- Ultimate fallback - use a direct path that's guaranteed to exist
    local defaultFont = "Interface\\AddOns\\Phoenix_UI\\Media\\Fonts\\Expressway.ttf"
    
    -- Final safety check - if that failed, use WoW's standard font
    if not defaultFont or defaultFont == "" then
        return STANDARD_TEXT_FONT
    end
    
    return defaultFont
end

-- Set font for a text element safely with enhanced error handling
local function SetFontSafely(fontString, size, outline)
    if not fontString then return false end
    
    local fontPath = GetFontPath()
    local success = false
    
    -- Try to set the font with pcall to handle errors gracefully
    success = pcall(function()
        fontString:SetFont(fontPath, size, outline or "OUTLINE")
    end)
    
    -- If font setting failed, try with different outline options
    if not success or not fontString:GetFont() then
        success = pcall(function()
            fontString:SetFont(fontPath, size, "OUTLINE")
        end)
    end
    
    -- If still failed, try with a guaranteed font
    if not success or not fontString:GetFont() then
        success = pcall(function()
            fontString:SetFont(STANDARD_TEXT_FONT, size, outline or "OUTLINE")
        end)
    end
    
    -- Last resort - try with no outline
    if not success or not fontString:GetFont() then
        success = pcall(function()
            fontString:SetFont(STANDARD_TEXT_FONT, size, "")
        end)
    end
    
    return success
end

-- Calculate appropriate font size based on cooldown frame size
local function CalculateFontSize(cooldown, baseSize)
    if not settings.scaleText then return baseSize end
    
    local size = min(cooldown:GetWidth(), cooldown:GetHeight())
    
    -- Ensure textScale exists with defaults
    if not settings.textScale then
        settings.textScale = {
            small = 0.7,
            medium = 1.0,
            large = 1.3
        }
    end
    
    if size < 25 then
        return baseSize * (settings.textScale.small or 0.7)
    elseif size > 40 then
        return baseSize * (settings.textScale.large or 1.3)
    else
        return baseSize * (settings.textScale.medium or 1.0)
    end
end

-- Play a finish sound
local function PlayFinishSound()
    if not settings.finishEffects.enabled or not settings.finishEffects.sound then return end
    
    local soundFile = soundCache[settings.finishEffects.sound] or settings.finishEffects.sound
    if soundFile then
        PlaySoundFile(soundFile, "Master")
    end
end

-- Create a finish effect with enhanced animations
local function CreateFinishEffect(cooldown)
    if not settings.finishEffects then return end
    
    -- Create container group for animations if not existing
    if not cooldown.pxFinishGroup then
        cooldown.pxFinishGroup = cooldown:CreateAnimationGroup()
    end
    
    -- Setup animations based on enabled effects
    
    -- Flash effect
    if settings.finishEffects.enableFlash then
        if not cooldown.pxFlashTexture then
            cooldown.pxFlashTexture = cooldown:CreateTexture(nil, "OVERLAY")
            cooldown.pxFlashTexture:SetAllPoints()
            cooldown.pxFlashTexture:SetColorTexture(
                settings.finishEffects.flashColor[1] or 1, 
                settings.finishEffects.flashColor[2] or 1, 
                settings.finishEffects.flashColor[3] or 1, 
                settings.finishEffects.flashColor[4] or 0.7
            )
            cooldown.pxFlashTexture:SetBlendMode("ADD")
            cooldown.pxFlashTexture:Hide()
        end
        
        -- Flash in
        if not cooldown.pxFlashFadeIn then
            cooldown.pxFlashFadeIn = cooldown.pxFinishGroup:CreateAnimation("Alpha")
            cooldown.pxFlashFadeIn:SetTarget(cooldown.pxFlashTexture)
            cooldown.pxFlashFadeIn:SetFromAlpha(0)
            cooldown.pxFlashFadeIn:SetToAlpha(0.7)
            cooldown.pxFlashFadeIn:SetOrder(1)
            cooldown.pxFlashFadeIn:SetDuration(0.2)
        end
        
        -- Flash out
        if not cooldown.pxFlashFadeOut then
            cooldown.pxFlashFadeOut = cooldown.pxFinishGroup:CreateAnimation("Alpha")
            cooldown.pxFlashFadeOut:SetTarget(cooldown.pxFlashTexture)
            cooldown.pxFlashFadeOut:SetFromAlpha(0.7)
            cooldown.pxFlashFadeOut:SetToAlpha(0)
            cooldown.pxFlashFadeOut:SetOrder(2)
            cooldown.pxFlashFadeOut:SetDuration(0.3)
        end
    end
    
    -- Pulse effect
    if settings.finishEffects.enablePulse then
        -- Scale up
        if not cooldown.pxPulseScaleUp then
            cooldown.pxPulseScaleUp = cooldown.pxFinishGroup:CreateAnimation("Scale")
            cooldown.pxPulseScaleUp:SetOrder(1)
            cooldown.pxPulseScaleUp:SetDuration(0.3)
            cooldown.pxPulseScaleUp:SetScale(
                settings.finishEffects.pulseScale or 1.5, 
                settings.finishEffects.pulseScale or 1.5
            )
        end
        
        -- Scale down
        if not cooldown.pxPulseScaleDown then
            cooldown.pxPulseScaleDown = cooldown.pxFinishGroup:CreateAnimation("Scale")
            cooldown.pxPulseScaleDown:SetOrder(2)
            cooldown.pxPulseScaleDown:SetDuration(0.2)
            cooldown.pxPulseScaleDown:SetScale(
                1/(settings.finishEffects.pulseScale or 1.5), 
                1/(settings.finishEffects.pulseScale or 1.5)
            )
        end
    end
    
    -- Shine effect
    if settings.finishEffects.enableShine then
        if not cooldown.pxShineTexture then
            cooldown.pxShineTexture = cooldown:CreateTexture(nil, "OVERLAY")
            cooldown.pxShineTexture:SetSize(cooldown:GetWidth() * 1.5, cooldown:GetHeight() * 1.5)
            cooldown.pxShineTexture:SetPoint("CENTER")
            cooldown.pxShineTexture:SetTexture([[Interface\SpellActivationOverlay\IconAlert]])
            cooldown.pxShineTexture:SetTexCoord(0.00781250, 0.50781250, 0.27734375, 0.52734375)
            cooldown.pxShineTexture:SetBlendMode("ADD")
            cooldown.pxShineTexture:SetVertexColor(
                settings.finishEffects.shineColor[1] or 1, 
                settings.finishEffects.shineColor[2] or 1, 
                settings.finishEffects.shineColor[3] or 1, 
                settings.finishEffects.shineColor[4] or 0.7
            )
            cooldown.pxShineTexture:Hide()
        end
        
        -- Shine fade in
        if not cooldown.pxShineFadeIn then
            cooldown.pxShineFadeIn = cooldown.pxFinishGroup:CreateAnimation("Alpha")
            cooldown.pxShineFadeIn:SetTarget(cooldown.pxShineTexture)
            cooldown.pxShineFadeIn:SetFromAlpha(0)
            cooldown.pxShineFadeIn:SetToAlpha(1)
            cooldown.pxShineFadeIn:SetOrder(1)
            cooldown.pxShineFadeIn:SetDuration(0.2)
        end
        
        -- Shine rotate
        if not cooldown.pxShineRotate then
            cooldown.pxShineRotate = cooldown.pxFinishGroup:CreateAnimation("Rotation")
            cooldown.pxShineRotate:SetTarget(cooldown.pxShineTexture)
            cooldown.pxShineRotate:SetDegrees(90)
            cooldown.pxShineRotate:SetOrder(2)
            cooldown.pxShineRotate:SetDuration(0.7)
        end
        
        -- Shine fade out
        if not cooldown.pxShineFadeOut then
            cooldown.pxShineFadeOut = cooldown.pxFinishGroup:CreateAnimation("Alpha")
            cooldown.pxShineFadeOut:SetTarget(cooldown.pxShineTexture)
            cooldown.pxShineFadeOut:SetFromAlpha(1)
            cooldown.pxShineFadeOut:SetToAlpha(0)
            cooldown.pxShineFadeOut:SetOrder(2)
            cooldown.pxShineFadeOut:SetDuration(0.4)
            cooldown.pxShineFadeOut:SetStartDelay(0.3)
        end
    end
    
    -- Set up animation callbacks
    cooldown.pxFinishGroup:SetScript("OnPlay", function()
        -- Show textures
        if settings.finishEffects.enableFlash and cooldown.pxFlashTexture then
            cooldown.pxFlashTexture:Show()
        end
        
        if settings.finishEffects.enableShine and cooldown.pxShineTexture then
            cooldown.pxShineTexture:Show()
        end
        
        -- Play sound if enabled
        PlayFinishSound()
    end)
    
    cooldown.pxFinishGroup:SetScript("OnFinished", function()
        -- Hide textures
        if cooldown.pxFlashTexture then
            cooldown.pxFlashTexture:Hide()
        end
        
        if cooldown.pxShineTexture then
            cooldown.pxShineTexture:Hide()
        end
    end)
    
    -- Play the finish effect
    cooldown.pxFinishGroup:Play()
end

-- Hide Blizzard cooldown text if needed
local function HideBlizzardCooldownCount(cooldown)
    if not settings.hideBlizzardCount then return end
    
    -- Look for the count text
    local count = cooldown:GetRegions()
    if count and count:GetObjectType() == "FontString" then
        count:Hide()
        return
    end
    
    -- Check for Blizzard's cooldown count frame by name pattern
    local parent = cooldown:GetParent()
    if parent then
        local name = parent:GetName()
        if name then
            local countFrame = _G[name .. "Count"]
            if countFrame and countFrame:GetObjectType() == "FontString" then
                countFrame:Hide()
            end
        end
    end
end

-- Check if this is a blacklisted cooldown
local function IsBlacklisted(cooldown)
    -- Check if in blacklist
    if blacklistedCooldowns[cooldown] then
        return true
    end
    
    -- Check parent frame name patterns for cooldowns we should ignore
    local parent = cooldown:GetParent()
    if parent then
        local name = parent:GetName()
        if name then
            -- Common patterns to ignore
            local ignorePatterns = {
                "WeakAuras", -- Skip WeakAuras cooldowns as they usually handle their own text
                "DBM", -- Skip Deadly Boss Mods cooldowns
                "BigWigs", -- Skip BigWigs cooldowns
                "Blizzard_Collections", -- Skip toy/mount collection UI
                "Currency", -- Skip currency frames
                "TellMeWhen", -- Skip TellMeWhen addon frames
                "TimerBar" -- Skip generic timer bars
            }
            
            for _, pattern in ipairs(ignorePatterns) do
                if name:find(pattern) then
                    blacklistedCooldowns[cooldown] = true
                    return true
                end
            end
        end
    end
    
    return false
end

-- Function to setup cooldown text with enhanced error handling
local function SetupCooldownText(cooldown)
    -- Skip if this cooldown already has text
    if not cooldown or cooldown.pxCooldownTextInitialized then return end
    
    -- Skip forbidden cooldowns
    if cooldown:IsForbidden() then return end
    
    -- Check for blacklisted cooldowns
    if IsBlacklisted(cooldown) then return end
    
    -- Get the rule for this frame type
    local rule = GetRuleSettings(cooldown)
    if not rule or not rule.enabled then return end
    
    -- Hide Blizzard's cooldown count if needed
    HideBlizzardCooldownCount(cooldown)
    
    -- Create the text object if it doesn't exist
    if not cooldown.text then
        cooldown.text = cooldown:CreateFontString(nil, "OVERLAY")
        
        -- Position based on text position setting
        local anchor = settings.textPosition or "CENTER"
        cooldown.text:SetPoint(anchor, cooldown, anchor, 0, 0)
        
        -- Set font size based on rule and cooldown size
        local fontSize = CalculateFontSize(cooldown, settings.textSize or 15)
        SetFontSafely(cooldown.text, fontSize, settings.textOutline)
        
        -- Set default color
        if settings.textColor then
            cooldown.text:SetTextColor(settings.textColor[1], settings.textColor[2], settings.textColor[3])
        else
            cooldown.text:SetTextColor(1, 1, 1)
        end
        
        -- Store rule info for updates
        cooldown.pxRule = rule
        cooldown.pxFontSize = fontSize
    end
    
    -- Store data for finish effects
    cooldown.pxFinishPlayed = false
    
    -- Hook into the cooldown mechanism with optimized OnUpdate
    cooldown:SetScript("OnUpdate", function(self, elapsed)
        -- Skip if not ready to update
        if performanceMode then
            nextUpdate = nextUpdate - elapsed
            if nextUpdate > 0 then return end
            nextUpdate = updateThrottle
        end
        
        -- Check if we have valid cooldown info
        if not self.start or not self.duration then return end
        
        local remaining = self.duration - (GetTime() - self.start)
        
        -- Handle cooldown finish effect
        if remaining <= 0 then
            if self.text then self.text:Hide() end
            
            -- Play finish effect once when cooldown completes
            if self.duration > settings.minDuration and not self.pxFinishPlayed and settings.finishEffects then
                CreateFinishEffect(self)
                self.pxFinishPlayed = true
            end
            
            return
        end
        
        -- Reset finish played flag when cooldown is active
        if remaining > 0 and self.pxFinishPlayed then
            self.pxFinishPlayed = false
        end
        
        -- Show text for long enough cooldowns
        if remaining > 0 and self.duration > settings.minDuration then
            self.text:SetText(FormatCooldownTime(remaining, self.pxRule))
            self.text:Show()
            
            -- Color is handled in the FormatCooldownTime function with inline coloring
        else
            if self.text then self.text:Hide() end
        end
    end)
    
    -- Mark as initialized
    cooldown.pxCooldownTextInitialized = true
end

-- Function to hook into the cooldown system with improved safety checks
local function HookCooldown()
    -- Keep track of whether we've already hooked
    if hookedCooldown then return end
    
    -- Use protected call to prevent errors during hooking
    local success = pcall(function()
        -- Hook into the default cooldown system using hooksecurefunc for safety
        hooksecurefunc(getmetatable(CreateFrame("Cooldown", nil, nil, "CooldownFrameTemplate")).__index, "SetCooldown", 
            function(self, start, duration)
                -- Skip processing if module is disabled or cooldown is forbidden
                if not settings or not settings.enabled or self:IsForbidden() then return end
                
                -- Don't process cooldowns that are too short
                if not start or not duration or duration <= (settings.minDuration or 2.5) then
                    if self.text then self.text:Hide() end
                    return
                end
                
                -- Save data for the OnUpdate handler
                self.start = start
                self.duration = duration
                
                -- Initialize cooldown text if needed
                if not self.pxCooldownTextInitialized then
                    SetupCooldownText(self)
                end
                
                -- Register for tracking
                activeCooldowns[self] = true
                
                -- Reset finish played state
                if self.pxFinishPlayed then
                    self.pxFinishPlayed = false
                end
            end
        )
        
        -- Mark as successfully hooked
        hookedCooldown = true
    end)
    
    -- If hooking failed, try a fallback approach
    if not success then
        pcall(function()
            -- Alternative approach using a metatable for Cooldown
            local cooldownMT = getmetatable(CreateFrame("Cooldown", nil, nil, "CooldownFrameTemplate")).__index
            local originalSetCooldown = cooldownMT.SetCooldown
            
            cooldownMT.SetCooldown = function(self, start, duration)
                -- Call original function
                originalSetCooldown(self, start, duration)
                
                -- Skip processing if module is disabled or cooldown is forbidden
                if not settings or not settings.enabled or self:IsForbidden() then return end
                
                -- Don't process cooldowns that are too short
                if not start or not duration or duration <= (settings.minDuration or 2.5) then
                    if self.text then self.text:Hide() end
                    return
                end
                
                -- Save data for the OnUpdate handler
                self.start = start
                self.duration = duration
                
                -- Initialize cooldown text if needed
                if not self.pxCooldownTextInitialized then
                    SetupCooldownText(self)
                end
                
                -- Register for tracking
                activeCooldowns[self] = true
                
                -- Reset finish played state
                if self.pxFinishPlayed then
                    self.pxFinishPlayed = false
                end
            end
            
            -- Mark as successfully hooked using alternative method
            hookedCooldown = true
        end)
    end
    
    -- Return whether hooking was successful
    return hookedCooldown
end

-- Clean up invalid cooldowns to prevent memory leaks
local function CleanupCooldowns()
    for cooldown in pairs(activeCooldowns) do
        -- Check if cooldown is still valid
        if not cooldown or not cooldown:IsVisible() or not cooldown:GetParent() or 
           (cooldown:GetParent() and cooldown:GetParent():IsForbidden()) then
            -- Remove from tracking
            activeCooldowns[cooldown] = nil
        end
    end
end

-- Enable/disable finish effects globally
local function UpdateFinishEffects()
    effectsEnabled = settings.finishEffects.enabled
    
    -- Cache finish sound
    if effectsEnabled and settings.finishEffects.sound then
        if LSM and not soundCache[settings.finishEffects.sound] then
            soundCache[settings.finishEffects.sound] = LSM:Fetch("sound", settings.finishEffects.sound)
        end
    end
end

-- Update all active cooldowns
local function UpdateActiveCooldowns()
    for cooldown in pairs(activeCooldowns) do
        local rule = GetRuleSettings(cooldown)
        
        if cooldown:IsVisible() and rule.enabled then
            if cooldown.text then
                -- Update font size
                local fontSize = CalculateFontSize(cooldown, rule.fontSize or settings.textSize)
                if fontSize ~= cooldown.pxFontSize then
                    SetFontSafely(cooldown.text, fontSize, settings.textOutline)
                    cooldown.pxFontSize = fontSize
                end
                
                -- Update position
                local anchor = rule.anchor or "CENTER"
                local xOffset = settings.textOffsetX or 0
                local yOffset = settings.textOffsetY or 0
                
                cooldown.text:ClearAllPoints()
                cooldown.text:SetPoint(anchor, cooldown, anchor, xOffset, yOffset)
                
                -- Store updated rule info
                cooldown.pxRule = rule
            end
        end
    end
end

-- Initialize the module with settings
function Module:Initialize(options)
    if not options then
        -- Handle missing options without print
        return false
    end
    
    -- Store settings
    settings = options
    
    -- Validate settings structure
    if type(settings) ~= "table" then
        settings = {}
        return false
    end
    
    -- Ensure default color settings exist with safety checks
    settings.hourColor = settings.hourColor or {0.4, 0.4, 1}
    settings.minuteColor = settings.minuteColor or {0.6, 0.6, 1}
    settings.secondsColor = settings.secondsColor or {1, 1, 1}
    settings.textColor = settings.textColor or {1, 1, 1}
    settings.expiringColor = settings.expiringColor or {1, 0.3, 0.3}
    
    -- Ensure timing thresholds exist
    settings.mmSSDuration = settings.mmSSDuration or 10
    settings.tenthsDuration = settings.tenthsDuration or 5
    settings.expiringDuration = settings.expiringDuration or 3
    settings.minDuration = settings.minDuration or 2.5
    
    -- Initialize font settings if missing
    if not settings.fontFace then
        settings.fontFace = Phoenix_UI.Media and Phoenix_UI.Media.Fonts and Phoenix_UI.Media.Fonts.Normal or 
                         "Interface\\AddOns\\Phoenix_UI\\Media\\Fonts\\Expressway.ttf"
    end
    
    settings.textSize = settings.textSize or 15
    settings.textOutline = settings.textOutline or "OUTLINE"
    
    -- Set performance mode based on general settings (with safety checks)
    if Phoenix_UI and Phoenix_UI.db and Phoenix_UI.db.profile and 
       Phoenix_UI.db.profile.cooldownTracker and 
       Phoenix_UI.db.profile.cooldownTracker.general then
        performanceMode = Phoenix_UI.db.profile.cooldownTracker.general.performanceMode
    end
    
    -- Ensure rules structure exists
    if not settings.rules then
        settings.rules = {
            actionBar = { scale = 1, enabled = true },
            bags = { scale = 0.75, enabled = true },
            nameplates = { scale = 0.8, enabled = true },
            unitFrames = { scale = 0.9, enabled = true },
            minScale = 0.5,
            minSize = 15
        }
    end
    
    -- Set up color hex codes for formatting safely
    local function ColorToHex(color)
        if type(color) ~= "table" or #color < 3 then
            return "|cFFFFFFFF" -- Default to white if color is invalid
        end
        return string.format("|cFF%02x%02x%02x", 
            math.floor(color[1] * 255), 
            math.floor(color[2] * 255), 
            math.floor(color[3] * 255))
    end
    
    -- Safely apply color settings
    dayColorHex = ColorToHex(settings.hourColor)
    hourColorHex = ColorToHex(settings.hourColor)
    minuteColorHex = ColorToHex(settings.minuteColor)
    secondsColorHex = ColorToHex(settings.secondsColor)
    expiringColorHex = ColorToHex(settings.expiringColor)
    
    -- Ensure finish effects exist
    if not settings.finishEffects then
        settings.finishEffects = {
            enabled = true,
            enableFlash = true,
            flashColor = {1, 1, 1, 0.7},
            enablePulse = true,
            pulseScale = 1.5,
            enableShine = false,
            shineColor = {1, 1, 1, 0.7},
            sound = nil
        }
    end
    
    -- Set up finish effects
    local success, err = pcall(UpdateFinishEffects)
    if not success then
        -- Create empty finish effects to prevent errors
        settings.finishEffects = settings.finishEffects or {
            enabled = false,
            enableFlash = false,
            enablePulse = false,
            enableShine = false,
        }
    end
    
    -- Create and register event frame for combat events
    if not self.eventFrame then
        self.eventFrame = CreateFrame("Frame")
    end
    
    -- Handle cases where event registration may fail
    pcall(function()
        self.eventFrame:RegisterEvent("PLAYER_REGEN_DISABLED")
        self.eventFrame:RegisterEvent("PLAYER_REGEN_ENABLED")
        
        self.eventFrame:SetScript("OnEvent", function(_, event)
            self:OnCombatChange(event)
        end)
    end)
    
    -- Hook into the cooldown system with error handling
    pcall(HookCooldown)
    
    -- Process any existing cooldowns (for reload UI)
    if Phoenix_UI.CooldownTracker and Phoenix_UI.CooldownTracker.cooldownFrames then
        for cooldown in pairs(Phoenix_UI.CooldownTracker.cooldownFrames) do
            -- Safely process existing cooldown
            pcall(function()
                if cooldown and not cooldown:IsForbidden() then
                    SetupCooldownText(cooldown)
                end
            end)
        end
    end
    
    -- Set up periodic cleanup to prevent memory leaks
    self.cleanupTimer = C_Timer.NewTicker(30, CleanupCooldowns)
    
    -- Record that we're initialized
    self.initialized = true
    
    -- Return success
    return true
end

-- Combat state changes
function Module:OnCombatChange(event)
    inCombat = (event == "PLAYER_REGEN_DISABLED")
    
    -- Adjust update throttle based on combat state
    if inCombat and performanceMode then
        updateThrottle = 0.1 -- Less frequent updates in combat
    else
        updateThrottle = 0.05 -- More responsive out of combat
    end
end

-- Update settings if they change
function Module:UpdateSettings(options)
    if not options then
        -- Try to get settings from parent module
        if Phoenix_UI and Phoenix_UI.db and Phoenix_UI.db.profile and 
           Phoenix_UI.db.profile.cooldownTracker and
           Phoenix_UI.db.profile.cooldownTracker.cooldownText then
            options = Phoenix_UI.db.profile.cooldownTracker.cooldownText
        else
            return false
        end
    end

    -- Store new settings
    settings = options
    
    -- Ensure default color settings exist with proper validation
    settings.hourColor = settings.hourColor or {0.4, 0.4, 1}
    settings.minuteColor = settings.minuteColor or {0.6, 0.6, 1}
    settings.secondsColor = settings.secondsColor or {1, 1, 1}
    settings.textColor = settings.textColor or {1, 1, 1}
    settings.expiringColor = settings.expiringColor or {1, 0.3, 0.3}
    
    -- Ensure timing thresholds exist
    settings.mmSSDuration = settings.mmSSDuration or 10
    settings.tenthsDuration = settings.tenthsDuration or 5
    settings.expiringDuration = settings.expiringDuration or 3
    settings.minDuration = settings.minDuration or 2.5
    
    -- Update performance mode with safety checks
    if Phoenix_UI and Phoenix_UI.db and Phoenix_UI.db.profile and 
       Phoenix_UI.db.profile.cooldownTracker and 
       Phoenix_UI.db.profile.cooldownTracker.general then
        performanceMode = Phoenix_UI.db.profile.cooldownTracker.general.performanceMode
    end
    
    -- Safely regenerate color hex codes
    local function ColorToHex(color)
        if type(color) ~= "table" or #color < 3 then
            return "|cFFFFFFFF" -- Default to white if color is invalid
        end
        return string.format("|cFF%02x%02x%02x", 
            math.floor(color[1] * 255), 
            math.floor(color[2] * 255), 
            math.floor(color[3] * 255))
    end
    
    -- Update color codes
    dayColorHex = ColorToHex(settings.hourColor)
    hourColorHex = ColorToHex(settings.hourColor)
    minuteColorHex = ColorToHex(settings.minuteColor)
    secondsColorHex = ColorToHex(settings.secondsColor)
    expiringColorHex = ColorToHex(settings.expiringColor)
    
    -- Update finish effects
    pcall(UpdateFinishEffects)
    
    -- Update all active cooldown texts
    pcall(UpdateActiveCooldowns)
    
    return true
end

-- Clear blacklisted cooldowns
function Module:ClearBlacklist()
    wipe(blacklistedCooldowns)
end

-- Add to blacklist
function Module:AddToBlacklist(cooldown)
    if cooldown then
        blacklistedCooldowns[cooldown] = true
    end
end

-- Disable the module with proper cleanup
function Module:Disable()
    -- Hide all cooldown text and stop tracking
    for cooldown in pairs(activeCooldowns) do
        if cooldown and cooldown.text then
            cooldown.text:Hide()
        end
    end
    
    -- Clear the tracking table
    wipe(activeCooldowns)
    
    -- Unregister events
    if self.eventFrame then
        self.eventFrame:UnregisterAllEvents()
        self.eventFrame:SetScript("OnEvent", nil)
    end
    
    -- Cancel any timers
    if self.cleanupTimer then
        self.cleanupTimer:Cancel()
        self.cleanupTimer = nil
    end
end

-- Add timer API for other modules to use
function Module:CreateTimer(parent, start, duration)
    if not parent or not start or not duration then return nil end
    
    -- Create a cooldown frame
    local timer = CreateFrame("Cooldown", nil, parent, "CooldownFrameTemplate")
    timer:SetAllPoints()
    timer:SetCooldown(start, duration)
    
    -- Our hook will take care of the rest
    return timer
end

-- API to manually add cooldown text to a frame
function Module:AddCooldownText(frame, fontSize, anchor)
    if not frame then return end
    
    -- Create cooldown text if needed
    if not frame.pxCooldownText then
        frame.pxCooldownText = frame:CreateFontString(nil, "OVERLAY")
        frame.pxCooldownText:SetPoint(anchor or "CENTER")
        
        local size = fontSize or settings.textSize
        SetFontSafely(frame.pxCooldownText, size, settings.textOutline)
        frame.pxCooldownText:SetTextColor(unpack(settings.textColor))
    end
    
    return frame.pxCooldownText
end

-- API to set cooldown text
function Module:SetCooldownText(frame, timeLeft)
    if not frame or not frame.pxCooldownText or not timeLeft then return end
    
    frame.pxCooldownText:SetText(FormatCooldownTime(timeLeft))
    
    -- Handle expiring cooldowns
    if timeLeft <= settings.expiringDuration then
        frame.pxCooldownText:SetTextColor(settings.expiringColor[1], settings.expiringColor[2], settings.expiringColor[3])
    else
        -- Use appropriate color based on time scale
        if timeLeft >= DAY then
            frame.pxCooldownText:SetTextColor(settings.textColor[1], settings.textColor[2], settings.textColor[3])
        elseif timeLeft >= HOUR then
            frame.pxCooldownText:SetTextColor(settings.hourColor[1], settings.hourColor[2], settings.hourColor[3])
        elseif timeLeft >= MINUTE then
            frame.pxCooldownText:SetTextColor(settings.minuteColor[1], settings.minuteColor[2], settings.minuteColor[3])
        else
            frame.pxCooldownText:SetTextColor(settings.secondsColor[1], settings.secondsColor[2], settings.secondsColor[3])
        end
    end
    
    return frame.pxCooldownText
end 