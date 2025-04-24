-- Phoenix_UI: SpellTracker Module
-- Provides TrufiGCD-like functionality to show recently used abilities
-- Complete feature implementation to match original addon

local Module = Phoenix_UI:NewModule("CooldownTracker.SpellTracker");
local LSM = LibStub("LibSharedMedia-3.0", true)
local LibCustomGlow = LibStub("LibCustomGlow-1.0", true)
local LibSpec = LibStub("LibSpecialization", true)

-- Local variables for optimization
local pairs, ipairs = pairs, ipairs
local tinsert, tremove, wipe = table.insert, table.remove, wipe
local GetTime = GetTime
local GetSpellInfo, GetSpellTexture = GetSpellInfo, GetSpellTexture
local UnitClass, UnitExists = UnitClass, UnitExists
local IsAltKeyDown = IsAltKeyDown
local C_Timer = C_Timer
local UIParent = UIParent
local format, floor = string.format, math.floor
local min, max = math.min, math.max

-- Module variables
local settings
local spellHistory = {}
local activeIcons = {}
local activeBars = {} -- For BAR mode
local iconPool = {}
local barPool = {} -- For BAR mode
local mainFrame
local textFrame -- For TEXT mode
local localizedClass
local currentSpec
local eventFrame

-- Spell school colors
local spellSchoolColors = {
    -- [0] = {0.9, 0.9, 0.9}, -- Physical (white)
    [1] = {1.0, 0.9, 0.5}, -- Holy (gold)
    [2] = {1.0, 0.5, 0.0}, -- Fire (orange)
    [4] = {0.5, 1.0, 0.5}, -- Nature (green)
    [8] = {0.3, 0.3, 1.0}, -- Frost (blue) 
    [16] = {0.6, 0.0, 1.0}, -- Shadow (purple)
    [32] = {0.7, 1.0, 1.0}, -- Arcane (cyan)
    [64] = {0.9, 0.9, 0.9}, -- Physical (white)
}

-- Spell type info
local spellTypeInfo = {
    damage = {
        icon = 132294, -- Impact icon
        color = {1.0, 0.1, 0.1}
    },
    healing = {
        icon = 136042, -- Heal icon
        color = {0.1, 1.0, 0.1}
    },
    utility = {
        icon = 136056, -- Utility icon
        color = {0.7, 0.7, 1.0}
    },
    interrupt = {
        icon = 132219, -- Interrupt icon
        color = {1.0, 0.7, 0}
    },
    dispel = {
        icon = 135894, -- Dispel icon
        color = {0.8, 0.8, 0.2}
    }
}

-- Important spells by class (for highlighting)
local importantSpellsByClass = {
    WARRIOR = {1719, 871, 12975}, -- Recklessness, Shield Wall, Last Stand
    PALADIN = {31884, 642, 633}, -- Wings, Bubble, Lay on Hands
    HUNTER = {19574, 186265, 187650}, -- Bestial Wrath, Turtle, FD
    ROGUE = {13750, 31224, 5277}, -- Adrenaline Rush, Cloak, Evasion
    PRIEST = {10060, 33206, 47788}, -- Power Infusion, Pain Suppression, Guardian Spirit
    DEATHKNIGHT = {49028, 55233, 48792}, -- Dancing Rune Weapon, Vampiric Blood, Icebound Fortitude
    SHAMAN = {114050, 108271, 198103}, -- Ascendance, Astral Shift, Earth Elemental
    MAGE = {12042, 45438, 55342}, -- Arcane Power, Ice Block, Mirror Image
    WARLOCK = {1122, 104773, 108416}, -- Infernal, Unending Resolve, Dark Pact
    MONK = {137639, 115203, 115176}, -- Storm, Earth & Fire, Fortifying Brew, Zen Meditation
    DRUID = {194223, 22812, 61336}, -- Celestial Alignment, Barkskin, Survival Instincts
    DEMONHUNTER = {191427, 196718, 187827}, -- Metamorphosis, Darkness, Vengeance
    EVOKER = {375087, 374348, 370537}, -- Dragon Rage, Preservation, Source of Magic
}

-- Cache for spell info
local spellInfoCache = {}
local spellSchoolCache = {}

-- Safe wrapper for GetSpellInfo to handle errors
local function SafeGetSpellInfo(spellID)
    if not spellID then return nil end
    
    -- Use pcall to catch any errors
    local success, result = pcall(GetSpellInfo, spellID)
    if success and result then
        return result, select(2, GetSpellInfo(spellID)), select(3, GetSpellInfo(spellID))
    else
        -- Return nil values if GetSpellInfo fails
        return nil, nil, nil
    end
end

-- Get spell info with caching
local function GetCachedSpellInfo(spellID)
    if spellInfoCache[spellID] then
        return unpack(spellInfoCache[spellID])
    end
    
    local name, _, icon, castTime, minRange, maxRange, spellID = SafeGetSpellInfo(spellID)
    if name then
        spellInfoCache[spellID] = {name, nil, icon, castTime, minRange, maxRange, spellID}
        return name, nil, icon, castTime, minRange, maxRange, spellID
    end
    return nil
end

-- Check if a spell is blacklisted
local function IsBlacklisted(spellID)
    return settings.blacklist[spellID]
end

-- Check if a spell is in the whitelist
local function IsWhitelisted(spellID)
    return settings.whitelist and settings.whitelist[spellID]
end

-- Check if a spell is important for the player's class
local function IsImportantSpell(spellID)
    if not settings.highlightImportant then return false end
    if not localizedClass or not importantSpellsByClass[localizedClass] then return false end
    
    for _, importantID in ipairs(importantSpellsByClass[localizedClass]) do
        if importantID == spellID then
            return true
        end
    end
    
    return false
end

-- Determine the type of spell (damage, healing, utility, etc.)
local function GetSpellType(spellID)
    -- To be implemented with comprehensive spell categorization
    -- For now, just a simplistic approach based on name patterns
    local name = GetCachedSpellInfo(spellID)
    if not name then return "utility" end
    
    name = name:lower()
    
    -- Check for healing spells
    if name:find("heal") or name:find("renew") or name:find("rejuvenat") or name:find("mendng") or 
       name:find("binding") or name:find("lifebloom") or name:find("tranquil") then
        return "healing"
    end
    
    -- Check for interrupts
    if name:find("interrupt") or name:find("silence") or name:find("counterspell") or
       name:find("kick") or name:find("pummel") or name:find("rebuke") then
        return "interrupt"
    end
    
    -- Check for dispels
    if name:find("dispel") or name:find("purge") or name:find("cleanse") or
       name:find("abolish") or name:find("remove") or name:find("detox") then
        return "dispel"
    end
    
    -- Default to damage for most abilities
    return "damage"
end

-- Get or create an icon from the pool
local function GetIcon()
    local icon
    if #iconPool > 0 then
        icon = tremove(iconPool)
    else
        icon = CreateFrame("Button", nil, mainFrame, "ActionButtonTemplate")
        icon:SetSize(settings.size, settings.size)
        icon:EnableMouse(settings.showTooltip)
        icon:RegisterForClicks()
        
        -- Create cooldown frame
        icon.cooldown = CreateFrame("Cooldown", nil, icon, "CooldownFrameTemplate")
        icon.cooldown:SetPoint("TOPLEFT", 1, -1)
        icon.cooldown:SetPoint("BOTTOMRIGHT", -1, 1)
        icon.cooldown:SetDrawEdge(false)
        icon.cooldown:SetSwipeColor(0, 0, 0, 0.8)
        
        -- Create shine animation
        icon.shine = icon:CreateTexture(nil, "OVERLAY")
        icon.shine:SetPoint("CENTER")
        icon.shine:SetSize(settings.size * 1.5, settings.size * 1.5)
        icon.shine:SetTexture([[Interface\SpellActivationOverlay\IconAlert]])
        icon.shine:SetTexCoord(0.00781250, 0.50781250, 0.27734375, 0.52734375)
        icon.shine:SetAlpha(0)
        
        -- Animation group for shine effect
        icon.animGroup = icon.shine:CreateAnimationGroup()
        local alphaIn = icon.animGroup:CreateAnimation("Alpha")
        alphaIn:SetFromAlpha(0)
        alphaIn:SetToAlpha(1)
        alphaIn:SetDuration(0.2)
        alphaIn:SetOrder(1)
        
        local rotateOut = icon.animGroup:CreateAnimation("Rotation")
        rotateOut:SetDegrees(90)
        rotateOut:SetDuration(0.8)
        rotateOut:SetOrder(2)
        
        local alphaOut = icon.animGroup:CreateAnimation("Alpha")
        alphaOut:SetFromAlpha(1)
        alphaOut:SetToAlpha(0)
        alphaOut:SetDuration(0.3)
        alphaOut:SetStartDelay(0.5)
        alphaOut:SetOrder(2)
        
        -- Create spell name text
        icon.spellName = icon:CreateFontString(nil, "OVERLAY")
        icon.spellName:SetFont(STANDARD_TEXT_FONT, max(floor(settings.size/3), 8), "OUTLINE")
        icon.spellName:SetPoint("BOTTOM", icon, "BOTTOM", 0, -10)
        icon.spellName:Hide()
        
        -- Tooltip handlers
        icon:SetScript("OnEnter", function(self)
            if settings.showTooltip and self.spellID then
                GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
                GameTooltip:SetSpellByID(self.spellID)
                GameTooltip:Show()
            end
        end)
        
        icon:SetScript("OnLeave", function()
            GameTooltip:Hide()
        end)
    end
    
    -- Reset icon state
    icon:ClearAllPoints()
    icon:SetAlpha(settings.opacity)
    icon.spellID = nil
    icon.fadeTime = nil
    icon.shine:SetAlpha(0)
    icon.animGroup:Stop()
    if LibCustomGlow then
        pcall(function() LibCustomGlow.ButtonGlow_Stop(icon) end)
    end
    
    -- Show/hide spell name based on settings
    if settings.showSpellName then
        icon.spellName:Show()
    else
        icon.spellName:Hide()
    end
    
    return icon
end

-- Get or create a bar from the pool (for BAR mode)
local function GetBar()
    local bar
    if #barPool > 0 then
        bar = tremove(barPool)
    else
        bar = CreateFrame("Frame", nil, mainFrame)
        bar:SetSize(settings.barWidth, settings.barHeight)
        
        -- Background texture
        bar.bg = bar:CreateTexture(nil, "BACKGROUND")
        bar.bg:SetAllPoints()
        bar.bg:SetColorTexture(0.1, 0.1, 0.1, 0.7)
        
        -- Status bar texture
        bar.statusbar = bar:CreateTexture(nil, "ARTWORK")
        bar.statusbar:SetPoint("TOPLEFT", 1, -1)
        bar.statusbar:SetPoint("BOTTOMLEFT", 1, 1)
        bar.statusbar:SetWidth(settings.barWidth - 2)
        
        -- Try to get the texture from LSM
        local barTexture = "Interface\\TARGETINGFRAME\\UI-StatusBar"
        if LSM then
            barTexture = LSM:Fetch("statusbar", settings.barTexture) or barTexture
        end
        bar.statusbar:SetTexture(barTexture)
        
        -- Icon texture
        bar.icon = bar:CreateTexture(nil, "ARTWORK")
        bar.icon:SetSize(settings.barHeight - 2, settings.barHeight - 2)
        
        -- Text for spell name
        bar.text = bar:CreateFontString(nil, "OVERLAY")
        bar.text:SetFont(STANDARD_TEXT_FONT, settings.barTextSize, "OUTLINE")
        bar.text:SetPoint("LEFT", bar.statusbar, "LEFT", 2, 0)
        bar.text:SetJustifyH("LEFT")
        
        -- Tooltip handlers
        bar:SetScript("OnEnter", function(self)
            if settings.showTooltip and self.spellID then
                GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
                GameTooltip:SetSpellByID(self.spellID)
                GameTooltip:Show()
            end
        end)
        
        bar:SetScript("OnLeave", function()
            GameTooltip:Hide()
        end)
        
        -- Make mouseover functional
        bar:EnableMouse(settings.showTooltip)
    end
    
    -- Reset bar state
    bar:ClearAllPoints()
    bar:SetAlpha(settings.opacity)
    bar.spellID = nil
    bar.fadeTime = nil
    bar.statusbar:SetWidth(settings.barWidth - 2)
    
    -- Position icon based on settings
    if settings.barIconPosition == "LEFT" then
        bar.icon:ClearAllPoints()
        bar.icon:SetPoint("RIGHT", bar, "LEFT", -1, 0)
        bar.text:SetPoint("LEFT", bar.statusbar, "LEFT", 2, 0)
    else
        bar.icon:ClearAllPoints()
        bar.icon:SetPoint("LEFT", bar, "RIGHT", 1, 0)
        bar.text:SetPoint("RIGHT", bar.statusbar, "RIGHT", -2, 0)
        bar.text:SetJustifyH("RIGHT")
    end
    
    return bar
end

-- Release an icon back to the pool
local function ReleaseIcon(icon)
    icon:Hide()
    icon:ClearAllPoints()
    icon.spellID = nil
    icon.fadeTime = nil
    icon.animGroup:Stop()
    icon.shine:SetAlpha(0)
    icon.cooldown:Hide()
    icon.spellName:Hide()
    if LibCustomGlow then
        pcall(function() LibCustomGlow.ButtonGlow_Stop(icon) end)
    end
    tinsert(iconPool, icon)
end

-- Release a bar back to the pool (for BAR mode)
local function ReleaseBar(bar)
    bar:Hide()
    bar:ClearAllPoints()
    bar.spellID = nil
    bar.fadeTime = nil
    bar.statusbar:SetWidth(0)
    tinsert(barPool, bar)
end

-- Update the position of all active icons
local function UpdateIconPositions()
    local previousIcon
    local direction = settings.direction
    
    for i, icon in ipairs(activeIcons) do
        icon:ClearAllPoints()
        if i == 1 then
            icon:SetPoint("CENTER", mainFrame, "CENTER")
            previousIcon = icon
        else
            if direction == "RIGHT" then
                icon:SetPoint("LEFT", previousIcon, "RIGHT", 2, 0)
            elseif direction == "LEFT" then
                icon:SetPoint("RIGHT", previousIcon, "LEFT", -2, 0)
            elseif direction == "UP" then
                icon:SetPoint("BOTTOM", previousIcon, "TOP", 0, 2)
            elseif direction == "DOWN" then
                icon:SetPoint("TOP", previousIcon, "BOTTOM", 0, -2)
            end
            previousIcon = icon
        end
        
        -- Scale important spells if needed
        if settings.highlightImportant and IsImportantSpell(icon.spellID) then
            icon:SetScale(settings.importantScale or 1.3)
        else
            icon:SetScale(1.0)
        end
    end
end

-- Update the position of all active bars (for BAR mode)
local function UpdateBarPositions()
    local previousBar
    local direction = settings.direction
    
    for i, bar in ipairs(activeBars) do
        bar:ClearAllPoints()
        if i == 1 then
            bar:SetPoint("CENTER", mainFrame, "CENTER")
            previousBar = bar
        else
            if direction == "DOWN" then
                bar:SetPoint("BOTTOM", previousBar, "TOP", 0, 2)
            else -- Default to UP
                bar:SetPoint("TOP", previousBar, "BOTTOM", 0, -2)
            end
            previousBar = bar
        end
        
        -- Scale important spells if needed
        if settings.highlightImportant and IsImportantSpell(bar.spellID) then
            bar:SetScale(settings.importantScale or 1.3)
        else
            bar:SetScale(1.0)
        end
    end
end

-- Update text display (for TEXT mode)
local function UpdateSpellText()
    if not textFrame or not settings.enabled or settings.displayMode ~= "TEXT" then return end
    
    local text = ""
    local count = min(#spellHistory, settings.maxIcons)
    
    for i = 1, count do
        local spellID = spellHistory[i]
        local name = GetCachedSpellInfo(spellID)
        if name then
            local color = "FFFFFF" -- Default white
            local spellType = GetSpellType(spellID)
            
            if spellTypeInfo[spellType] then
                local typeColor = spellTypeInfo[spellType].color
                color = string.format("%02x%02x%02x", typeColor[1]*255, typeColor[2]*255, typeColor[3]*255)
            end
            
            if i == 1 then
                text = "|cFF" .. color .. name .. "|r"
            else
                text = text .. " > |cFF" .. color .. name .. "|r"
            end
        end
    end
    
    textFrame.text:SetText(text)
end

-- Check if a spell passes the category filter
local function PassesCategoryFilter(spellID)
    local spellType = GetSpellType(spellID)
    
    if spellType == "damage" and not settings.showDamageSpells then return false end
    if spellType == "healing" and not settings.showHealingSpells then return false end
    if spellType == "utility" and not settings.showUtilitySpells then return false end
    if spellType == "interrupt" and not settings.showInterrupts then return false end
    if spellType == "dispel" and not settings.showDispels then return false end
    
    return true
end

-- Check if a spell passes the school filter
-- Note: Full implementation would need GetSpellSchool information from combat log
local function PassesSchoolFilter(spellID)
    -- For now a simple implementation that passes most spells
    -- A full implementation would check against specific spell schools
    return true
end

-- Add a new spell to the history
local function AddSpellToHistory(spellID)
    -- Get spell information
    local name, _, texture = GetCachedSpellInfo(spellID)
    if not name or not texture then return end
    
    -- Skip blacklisted spells
    if IsBlacklisted(spellID) then return end
    
    -- Check if this is whitelisted (if using whitelist)
    if next(settings.whitelist) and not IsWhitelisted(spellID) then return end
    
    -- Apply filters
    if not PassesCategoryFilter(spellID) or not PassesSchoolFilter(spellID) then return end
    
    -- Add to history regardless of display mode
    tinsert(spellHistory, 1, spellID)
    while #spellHistory > settings.maxIcons * 2 do
        tremove(spellHistory)
    end
    
    -- Handle different display modes
    if settings.displayMode == "ICON" then
        -- Check if this is a duplicate of the most recent spell
        if #activeIcons > 0 and activeIcons[1].spellID == spellID then
            -- Refresh the existing icon
            activeIcons[1].fadeTime = GetTime() + settings.fadeTime
            
            -- Trigger effect again
            if settings.showGlow and LibCustomGlow then
                pcall(function()
                    LibCustomGlow.ButtonGlow_Stop(activeIcons[1])
                    LibCustomGlow.ButtonGlow_Start(activeIcons[1])
                end)
            end
            
            activeIcons[1].animGroup:Stop()
            activeIcons[1].shine:SetAlpha(0)
            activeIcons[1].animGroup:Play()
            
            return
        end
        
        -- Create a new icon
        local icon = GetIcon()
        icon:Show()
        icon.icon:SetTexture(texture)
        icon.spellID = spellID
        icon.fadeTime = GetTime() + settings.fadeTime
        
        -- Set spell name if enabled
        if settings.showSpellName then
            icon.spellName:SetText(name)
            icon.spellName:Show()
        end
        
        -- Add visual effects
        if settings.showGlow and LibCustomGlow then
            pcall(function() LibCustomGlow.ButtonGlow_Start(icon) end)
        end
        icon.animGroup:Play()
        
        -- Add to active icons
        tinsert(activeIcons, 1)
        activeIcons[1] = icon
        
        -- Remove excess icons
        while #activeIcons > settings.maxIcons do
            local oldIcon = tremove(activeIcons)
            ReleaseIcon(oldIcon)
        end
        
        -- Update icon positions
        UpdateIconPositions()
    elseif settings.displayMode == "BAR" then
        -- Check if this is a duplicate of the most recent bar
        if #activeBars > 0 and activeBars[1].spellID == spellID then
            -- Refresh the existing bar
            activeBars[1].fadeTime = GetTime() + settings.fadeTime
            return
        end
        
        -- Create a new bar
        local bar = GetBar()
        bar:Show()
        bar.icon:SetTexture(texture)
        bar.text:SetText(name)
        bar.spellID = spellID
        bar.fadeTime = GetTime() + settings.fadeTime
        
        -- Set bar color based on spell type
        local spellType = GetSpellType(spellID)
        if spellTypeInfo[spellType] then
            bar.statusbar:SetColorTexture(
                spellTypeInfo[spellType].color[1],
                spellTypeInfo[spellType].color[2],
                spellTypeInfo[spellType].color[3],
                0.8
            )
        else
            bar.statusbar:SetColorTexture(settings.barColor[1], settings.barColor[2], settings.barColor[3], 0.8)
        end
        
        -- Add to active bars
        tinsert(activeBars, 1)
        activeBars[1] = bar
        
        -- Remove excess bars
        while #activeBars > settings.maxIcons do
            local oldBar = tremove(activeBars)
            ReleaseBar(oldBar)
        end
        
        -- Update bar positions
        UpdateBarPositions()
    elseif settings.displayMode == "TEXT" then
        -- Text mode just updates the text display
        UpdateSpellText()
    end
end

-- Update function to check for expired icons/bars
local function UpdateDisplay()
    local currentTime = GetTime()
    local needPositionUpdate = false
    
    -- Update based on display mode
    if settings.displayMode == "ICON" then
        for i = #activeIcons, 1, -1 do
            local icon = activeIcons[i]
            
            -- Check if this icon should fade out
            if icon.fadeTime and currentTime > icon.fadeTime then
                tremove(activeIcons, i)
                ReleaseIcon(icon)
                needPositionUpdate = true
            end
        end
        
        if needPositionUpdate then
            UpdateIconPositions()
        end
    elseif settings.displayMode == "BAR" then
        for i = #activeBars, 1, -1 do
            local bar = activeBars[i]
            
            -- Check if this bar should fade out
            if bar.fadeTime and currentTime > bar.fadeTime then
                tremove(activeBars, i)
                ReleaseBar(bar)
                needPositionUpdate = true
            end
        end
        
        if needPositionUpdate then
            UpdateBarPositions()
        end
    end
    
    -- Always update text mode, it's lightweight
    if settings.displayMode == "TEXT" then
        UpdateSpellText()
    end
end

-- Create the main frame
local function CreateMainFrame()
    -- Clean up existing frames first
    if mainFrame then
        mainFrame:Hide()
        mainFrame = nil
    end
    
    if textFrame then
        textFrame:Hide()
        textFrame = nil
    end
    
    -- Create the appropriate frame based on display mode
    if settings.displayMode == "ICON" or settings.displayMode == "BAR" then
        mainFrame = CreateFrame("Frame", "Phoenix_UI_SpellTracker", UIParent)
        
        if settings.displayMode == "ICON" then
            -- Size for icon mode
            if settings.direction == "LEFT" or settings.direction == "RIGHT" then
                mainFrame:SetSize(settings.size * settings.maxIcons * 1.5, settings.size * 1.5)
            else
                mainFrame:SetSize(settings.size * 1.5, settings.size * settings.maxIcons * 1.5)
            end
        else -- BAR mode
            -- Size for bar mode
            mainFrame:SetSize(settings.barWidth, settings.barHeight * settings.maxIcons * 1.2)
        end
        
        mainFrame:SetPoint(unpack(settings.position))
        mainFrame:SetMovable(true)
        mainFrame:SetClampedToScreen(true)
        
        -- Background for easier positioning (only when Alt is held)
        local bg = mainFrame:CreateTexture(nil, "BACKGROUND")
        bg:SetAllPoints()
        bg:SetColorTexture(0.1, 0.1, 0.1, 0.3)
        bg:Hide()
        mainFrame.bg = bg
        
        -- Make the frame movable when holding Alt
        mainFrame:SetScript("OnMouseDown", function(self, button)
            if IsAltKeyDown() and button == "LeftButton" then
                self.bg:Show()
                self:StartMoving()
            end
        end)
        
        mainFrame:SetScript("OnMouseUp", function(self, button)
            self:StopMovingOrSizing()
            self.bg:Hide()
            -- Save position
            local point, relativeTo, relativePoint, xOfs, yOfs = self:GetPoint()
            if relativeTo then
                settings.position = {point, (relativeTo:GetName() or "UIParent"), relativePoint, xOfs, yOfs}
            end
        end)
        
        return mainFrame
    elseif settings.displayMode == "TEXT" then
        -- Create text frame
        textFrame = CreateFrame("Frame", "Phoenix_UI_SpellTrackerText", UIParent)
        textFrame:SetSize(300, 30)
        textFrame:SetPoint(unpack(settings.position))
        textFrame:SetMovable(true)
        textFrame:SetClampedToScreen(true)
        
        -- Text element
        textFrame.text = textFrame:CreateFontString(nil, "OVERLAY")
        textFrame.text:SetFont(STANDARD_TEXT_FONT, settings.barTextSize or 12, "OUTLINE")
        textFrame.text:SetPoint("CENTER")
        textFrame.text:SetJustifyH("CENTER")
        textFrame.text:SetText("")
        
        -- Background for easier positioning (only when Alt is held)
        local bg = textFrame:CreateTexture(nil, "BACKGROUND")
        bg:SetAllPoints()
        bg:SetColorTexture(0.1, 0.1, 0.1, 0.3)
        bg:Hide()
        textFrame.bg = bg
        
        -- Make the frame movable when holding Alt
        textFrame:SetScript("OnMouseDown", function(self, button)
            if IsAltKeyDown() and button == "LeftButton" then
                self.bg:Show()
                self:StartMoving()
            end
        end)
        
        textFrame:SetScript("OnMouseUp", function(self, button)
            self:StopMovingOrSizing()
            self.bg:Hide()
            -- Save position
            local point, relativeTo, relativePoint, xOfs, yOfs = self:GetPoint()
            if relativeTo then
                settings.position = {point, (relativeTo:GetName() or "UIParent"), relativePoint, xOfs, yOfs}
            end
        end)
        
        mainFrame = textFrame -- Use the same reference for consistency
        return textFrame
    end
end

-- Clean up all display elements
local function CleanupDisplay()
    -- Clean up icons
    for i = #activeIcons, 1, -1 do
        ReleaseIcon(activeIcons[i])
        tremove(activeIcons, i)
    end
    
    -- Clean up bars
    for i = #activeBars, 1, -1 do
        ReleaseBar(activeBars[i])
        tremove(activeBars, i)
    end
    
    -- Clear text if present
    if textFrame and textFrame.text then
        textFrame.text:SetText("")
    end
end

-- Register events to track spell casts
local function RegisterEvents()
    -- Create event frame if it doesn't exist
    if not eventFrame then
        eventFrame = CreateFrame("Frame")
    else
        -- Unregister all existing events
        eventFrame:UnregisterAllEvents()
    end
    
    -- Register for spell cast events
    eventFrame:RegisterEvent("UNIT_SPELLCAST_SUCCEEDED")
    
    -- Add combat log event for more detailed spell information
    eventFrame:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
    
    -- Register for spec changes
    eventFrame:RegisterEvent("PLAYER_SPECIALIZATION_CHANGED")
    
    -- Process spell casts
    eventFrame:SetScript("OnEvent", function(self, event, ...)
        if not settings.enabled then return end
        
        if event == "UNIT_SPELLCAST_SUCCEEDED" then
            local unit, _, spellID = ...
            if unit == "player" then
                AddSpellToHistory(spellID)
            end
        elseif event == "COMBAT_LOG_EVENT_UNFILTERED" then
            local timestamp, eventType, hideCaster, sourceGUID, sourceName, sourceFlags, sourceRaidFlags, 
                  destGUID, destName, destFlags, destRaidFlags, spellID, spellName, spellSchool = CombatLogGetCurrentEventInfo()
            
            -- Only process player spell events
            if sourceGUID == UnitGUID("player") then
                if eventType == "SPELL_CAST_SUCCESS" or eventType == "SPELL_CAST_START" then
                    -- Cache the spell school for filtering
                    if spellID and spellSchool then
                        spellSchoolCache[spellID] = spellSchool
                    end
                    
                    -- Don't add the spell here, it's already added in UNIT_SPELLCAST_SUCCEEDED
                elseif eventType == "SPELL_INTERRUPT" or eventType == "SPELL_DISPEL" then
                    -- Special handling for interrupts and dispels
                    AddSpellToHistory(spellID)
                end
            end
        elseif event == "PLAYER_SPECIALIZATION_CHANGED" then
            local unit = ...
            if unit == "player" then
                -- Update current spec
                currentSpec = GetSpecialization()
                
                -- Apply any spec-specific settings if they exist
                if currentSpec and settings.perSpec and settings.perSpec[currentSpec] then
                    for key, value in pairs(settings.perSpec[currentSpec]) do
                        settings[key] = value
                    end
                    
                    -- Recreate the display for the updated settings
                    CleanupDisplay()
                    CreateMainFrame()
                end
            end
        end
    end)
    
    -- Set up the update timer
    C_Timer.NewTicker(0.1, UpdateDisplay)
end

-- Initialize the module with settings
function Module:Initialize(options)
    settings = options
    
    -- Get player class for class-specific customizations
    local _, playerClass = UnitClass("player")
    localizedClass = playerClass
    
    -- Get current specialization
    currentSpec = GetSpecialization()
    
    -- Apply any spec-specific settings if they exist
    if currentSpec and settings.perSpec and settings.perSpec[currentSpec] then
        for key, value in pairs(settings.perSpec[currentSpec]) do
            settings[key] = value
        end
    end
    
    -- Create the main frame
    mainFrame = CreateMainFrame()
    
    -- Register for events
    RegisterEvents()
end

-- Update settings
function Module:UpdateSettings(options)
    local oldEnabled = settings.enabled
    local oldDisplayMode = settings.displayMode
    settings = options
    
    -- Apply any spec-specific settings if they exist
    if currentSpec and settings.perSpec and settings.perSpec[currentSpec] then
        for key, value in pairs(settings.perSpec[currentSpec]) do
            settings[key] = value
        end
    end
    
    -- Check if display mode changed
    if oldDisplayMode ~= settings.displayMode then
        -- Clean up existing display
        CleanupDisplay()
        
        -- Create new frame for the current display mode
        mainFrame = CreateMainFrame()
    else
        -- Update existing display
        if settings.displayMode == "ICON" then
            -- Update icon size and positions
            for i, icon in ipairs(activeIcons) do
                icon:SetSize(settings.size, settings.size)
                -- Update shine size
                icon.shine:SetSize(settings.size * 1.5, settings.size * 1.5)
                
                -- Update spell name visibility
                if settings.showSpellName then
                    icon.spellName:Show()
                else
                    icon.spellName:Hide()
                end
            end
            
            -- Update frame position
            mainFrame:ClearAllPoints()
            mainFrame:SetPoint(unpack(settings.position))
            
            -- Update tooltips
            for i, icon in ipairs(activeIcons) do
                icon:EnableMouse(settings.showTooltip)
            end
            
            -- Update icon positions
            UpdateIconPositions()
        elseif settings.displayMode == "BAR" then
            -- Update bar size and positions
            for i, bar in ipairs(activeBars) do
                bar:SetSize(settings.barWidth, settings.barHeight)
                
                -- Update text size
                bar.text:SetFont(STANDARD_TEXT_FONT, settings.barTextSize, "OUTLINE")
                
                -- Update icon position
                if settings.barIconPosition == "LEFT" then
                    bar.icon:ClearAllPoints()
                    bar.icon:SetPoint("RIGHT", bar, "LEFT", -1, 0)
                    bar.text:SetPoint("LEFT", bar.statusbar, "LEFT", 2, 0)
                    bar.text:SetJustifyH("LEFT")
                else
                    bar.icon:ClearAllPoints()
                    bar.icon:SetPoint("LEFT", bar, "RIGHT", 1, 0)
                    bar.text:SetPoint("RIGHT", bar.statusbar, "RIGHT", -2, 0)
                    bar.text:SetJustifyH("RIGHT")
                end
            end
            
            -- Update frame position
            mainFrame:ClearAllPoints()
            mainFrame:SetPoint(unpack(settings.position))
            
            -- Update tooltips
            for i, bar in ipairs(activeBars) do
                bar:EnableMouse(settings.showTooltip)
            end
            
            -- Update bar positions
            UpdateBarPositions()
        elseif settings.displayMode == "TEXT" then
            -- Update text size
            if textFrame and textFrame.text then
                textFrame.text:SetFont(STANDARD_TEXT_FONT, settings.barTextSize or 12, "OUTLINE")
            end
            
            -- Update frame position
            if textFrame then
                textFrame:ClearAllPoints()
                textFrame:SetPoint(unpack(settings.position))
            end
            
            -- Update text display
            UpdateSpellText()
        end
    end
    
    -- Toggle frame visibility based on enabled setting
    if settings.enabled then
        if mainFrame then mainFrame:Show() end
        if textFrame then textFrame:Show() end
    else
        if mainFrame then mainFrame:Hide() end
        if textFrame then textFrame:Hide() end
    end
end

-- Whitelist/Blacklist management
function Module:AddToBlacklist(spellID)
    settings.blacklist[spellID] = true
end

function Module:RemoveFromBlacklist(spellID)
    settings.blacklist[spellID] = nil
end

function Module:AddToWhitelist(spellID)
    settings.whitelist[spellID] = true
end

function Module:RemoveFromWhitelist(spellID)
    settings.whitelist[spellID] = nil
end

-- Clear all spell data
function Module:ClearSpellHistory()
    wipe(spellHistory)
    CleanupDisplay()
end

-- Add spell for testing
function Module:TestAddSpell(spellID)
    if not spellID then
        -- Use a default test spell if none provided
        spellID = 1459 -- Arcane Intellect
    end
    
    AddSpellToHistory(spellID)
end

-- Disable the module
function Module:Disable()
    -- Hide frames
    if mainFrame then mainFrame:Hide() end
    if textFrame then textFrame:Hide() end
    
    -- Clear all displays
    CleanupDisplay()
    
    -- Unregister events
    if eventFrame then
        eventFrame:UnregisterAllEvents()
        eventFrame:SetScript("OnEvent", nil)
    end
end 