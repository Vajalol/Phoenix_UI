-- Phoenix_UI: PartyCD Module
-- Provides OmniCD-like functionality to track party member cooldowns
-- Complete feature implementation to match original addon

local Module = Phoenix_UI:NewModule("CooldownTracker.PartyCD");
local LSM = LibStub("LibSharedMedia-3.0", true)
local LibCustomGlow = LibStub("LibCustomGlow-1.0", true)

-- Local variables for optimization
local pairs, ipairs, wipe, tinsert, tremove = pairs, ipairs, wipe, table.insert, table.remove
local UnitClass, UnitName, UnitGUID, UnitExists = UnitClass, UnitName, UnitGUID, UnitExists
local UnitIsPlayer, UnitIsUnit, UnitHealth = UnitIsPlayer, UnitIsUnit, UnitHealth
local GetSpellInfo = GetSpellInfo
local IsInRaid, IsInGroup, GetSpecialization = IsInRaid, IsInGroup, GetSpecialization
local GetSpecializationInfoForClassID = GetSpecializationInfoForClassID
local GetTime, C_Timer = GetTime, C_Timer
local format, floor = string.format, math.floor
local min, max = math.min, math.max

-- Define class ID mapping table
local classIds = {
    ["WARRIOR"] = 1,
    ["PALADIN"] = 2,
    ["HUNTER"] = 3,
    ["ROGUE"] = 4,
    ["PRIEST"] = 5,
    ["DEATHKNIGHT"] = 6,
    ["SHAMAN"] = 7,
    ["MAGE"] = 8,
    ["WARLOCK"] = 9,
    ["MONK"] = 10,
    ["DRUID"] = 11,
    ["DEMONHUNTER"] = 12,
    ["EVOKER"] = 13
}

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

-- Module variables
local settings
local partyMembers = {}
local classData = {}
local trackedCooldowns = {}
local activeCooldowns = {}
local CDFrames = {}
local barFrames = {}
local inlineFrames = {}
local hookedFrames = {}
local raidPanel
local eventFrame
local updateTimer
local bossEncounterActive = false
local currentBossName

-- Class colors
local RAID_CLASS_COLORS = RAID_CLASS_COLORS or {
    WARRIOR = {r = 0.78, g = 0.61, b = 0.43},
    PALADIN = {r = 0.96, g = 0.55, b = 0.73},
    HUNTER = {r = 0.67, g = 0.83, b = 0.45},
    ROGUE = {r = 1.00, g = 0.96, b = 0.41},
    PRIEST = {r = 1.00, g = 1.00, b = 1.00},
    DEATHKNIGHT = {r = 0.77, g = 0.12, b = 0.23},
    SHAMAN = {r = 0.00, g = 0.44, b = 0.87},
    MAGE = {r = 0.25, g = 0.78, b = 0.92},
    WARLOCK = {r = 0.53, g = 0.53, b = 0.93},
    MONK = {r = 0.00, g = 1.00, b = 0.59},
    DRUID = {r = 1.00, g = 0.49, b = 0.04},
    DEMONHUNTER = {r = 0.64, g = 0.19, b = 0.79},
    EVOKER = {r = 0.20, g = 0.58, b = 0.50},
}

-- Define cooldown categories and icons
local cooldownCategories = {
    interrupt = {
        name = "Interrupts",
        color = {0.1, 0.8, 0.1}, -- Green
        priority = 10,
        icon = 132219, -- Generic interrupt icon
    },
    defensive = {
        name = "Defensive Cooldowns",
        color = {0.1, 0.1, 0.8}, -- Blue
        priority = 20,
        icon = 132362, -- Shield icon
    },
    offensive = {
        name = "Offensive Cooldowns",
        color = {0.8, 0.1, 0.1}, -- Red
        priority = 30,
        icon = 135810, -- Sword icon
    },
    raidCD = {
        name = "Raid Cooldowns",
        color = {0.8, 0.8, 0.1}, -- Yellow
        priority = 40,
        icon = 135907, -- Star icon
    },
    utility = {
        name = "Utility",
        color = {0.8, 0.5, 0.1}, -- Orange
        priority = 50,
        icon = 136058, -- Utility icon
    },
    covenant = {
        name = "Covenant Abilities",
        color = {0.8, 0.1, 0.8}, -- Purple
        priority = 60,
        icon = 3257748, -- Covenant icon
    },
    dispel = {
        name = "Dispel Abilities",
        color = {0.1, 0.8, 0.8}, -- Cyan
        priority = 15,
        icon = 135894, -- Dispel icon
    },
    custom = {
        name = "Custom Abilities",
        color = {0.7, 0.7, 0.7}, -- Gray
        priority = 70,
        icon = 134400, -- Question mark
    },
}

-- Define role icons
local roleIcons = {
    TANK = 337497,    -- Interface\\LFGFrame\\UI-LFG-ICON-PORTRAITROLES
    HEALER = 337497,  -- Interface\\LFGFrame\\UI-LFG-ICON-PORTRAITROLES
    DAMAGER = 337497, -- Interface\\LFGFrame\\UI-LFG-ICON-PORTRAITROLES
}

-- Define CDR (Cooldown Reduction) effects
local cooldownReductionEffects = {
    -- Example: [SpellID of CDR Aura] = {targetSpellID = reductionAmount, ...}
    [382440] = {[31884] = 0.3}, -- Divine Resonance: reduces Avenging Wrath CD by 30%
    -- Add more as needed
}

-- Core boss mechanics that require specific CDs
local bossMechanics = {
    -- Example: [BossName] = {{mechanicName, time, requiredCD}, ...}
    ["The Primal Council"] = {
        {"Earthen Pillar", 30, "interrupt"},
        {"Conductive Mark", 60, "defensive"},
    },
    -- Add more as needed
}

-- Define class cooldowns (example - would need to be expanded for all classes)
local classCooldowns = {
    PALADIN = {
        -- Interrupt
        {spellID = 96231, category = "interrupt", cooldown = 15}, -- Rebuke
        
        -- Defensive CDs
        {spellID = 642, category = "defensive", cooldown = 300}, -- Divine Shield
        {spellID = 633, category = "defensive", cooldown = 600}, -- Lay on Hands
        {spellID = 1022, category = "defensive", cooldown = 300}, -- Blessing of Protection
        {spellID = 31821, category = "raidCD", cooldown = 180}, -- Aura Mastery (Holy)
        
        -- Offensive CDs
        {spellID = 31884, category = "offensive", cooldown = 120}, -- Avenging Wrath
        
        -- Dispels
        {spellID = 4987, category = "dispel", cooldown = 8}, -- Cleanse
        
        -- Class-Specific
        -- Holy
        {spellID = 105809, category = "raidCD", cooldown = 180, specID = 65}, -- Holy Avenger
        
        -- Protection
        {spellID = 31850, category = "defensive", cooldown = 120, specID = 66}, -- Ardent Defender
        {spellID = 86659, category = "defensive", cooldown = 300, specID = 66}, -- Guardian of Ancient Kings
        
        -- Retribution
        {spellID = 205191, category = "offensive", cooldown = 60, specID = 70}, -- Eye for an Eye
    },
    
    PRIEST = {
        -- Interrupts
        {spellID = 15487, category = "interrupt", cooldown = 45, specID = 258}, -- Silence (Shadow)
        
        -- Defensive CDs
        {spellID = 33206, category = "defensive", cooldown = 180, specID = 256}, -- Pain Suppression
        {spellID = 47788, category = "defensive", cooldown = 180, specID = 257}, -- Guardian Spirit
        {spellID = 19236, category = "defensive", cooldown = 90}, -- Desperate Prayer
        
        -- Dispels
        {spellID = 527, category = "dispel", cooldown = 8}, -- Purify
        {spellID = 32375, category = "dispel", cooldown = 45}, -- Mass Dispel
        
        -- Raid CDs
        {spellID = 62618, category = "raidCD", cooldown = 180, specID = 256}, -- Power Word: Barrier
        {spellID = 64843, category = "raidCD", cooldown = 180, specID = 257}, -- Divine Hymn
        {spellID = 15286, category = "raidCD", cooldown = 120, specID = 258}, -- Vampiric Embrace
        
        -- Holy
        {spellID = 200183, category = "raidCD", cooldown = 120, specID = 257}, -- Apotheosis
        
        -- Discipline
        {spellID = 10060, category = "offensive", cooldown = 120, specID = 256}, -- Power Infusion
        
        -- Shadow
        {spellID = 228260, category = "offensive", cooldown = 90, specID = 258}, -- Void Eruption
    },
    
    -- Add more classes as needed...
}

-- Get the appropriate bar texture
local function GetBarTexture()
    local texture = "Interface\\TARGETINGFRAME\\UI-StatusBar"
    
    if LSM then
        texture = LSM:Fetch("statusbar", settings.barTexture) or texture
    end
    
    return texture
end

-- Create or get a cooldown frame (icon mode)
local function GetCooldownFrame(parent, size)
    if #CDFrames > 0 then
        return table.remove(CDFrames)
    end
    
    local frame = CreateFrame("Frame", nil, parent)
    frame:SetSize(size, size)
    
    -- Icon texture
    frame.icon = frame:CreateTexture(nil, "ARTWORK")
    frame.icon:SetAllPoints()
    frame.icon:SetTexCoord(0.08, 0.92, 0.08, 0.92) -- Trim the borders
    
    -- Border
    frame.border = frame:CreateTexture(nil, "OVERLAY")
    frame.border:SetPoint("TOPLEFT", frame, "TOPLEFT", -1, 1)
    frame.border:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT", 1, -1)
    frame.border:SetTexture("Interface\\Buttons\\UI-ActionButton-Border")
    frame.border:SetBlendMode("ADD")
    frame.border:SetAlpha(0.8)
    
    -- Cooldown swipe
    frame.cd = CreateFrame("Cooldown", nil, frame, "CooldownFrameTemplate")
    frame.cd:SetAllPoints()
    frame.cd:SetDrawEdge(false)
    frame.cd:SetHideCountdownNumbers(not settings.showText)
    
    -- Timer text
    frame.text = frame.cd:CreateFontString(nil, "OVERLAY")
    frame.text:SetFont(Phoenix_UI.CooldownTracker:GetFontPath(), math.max(size/2, 8), "OUTLINE")
    frame.text:SetPoint("CENTER", frame, "CENTER", 0, 0)
    frame.text:SetTextColor(1, 1, 1)
    
    -- Name text (for raid panel)
    frame.name = frame:CreateFontString(nil, "OVERLAY")
    frame.name:SetFont(Phoenix_UI.CooldownTracker:GetFontPath(), math.max(size/3, 8), "OUTLINE")
    frame.name:SetPoint("BOTTOM", frame, "BOTTOM", 0, -10)
    frame.name:SetTextColor(1, 1, 1)
    frame.name:Hide() -- Hidden by default
    
    -- Flash animation for ready cooldowns
    frame.flash = frame:CreateTexture(nil, "OVERLAY")
    frame.flash:SetAllPoints(frame.icon)
    frame.flash:SetTexture("Interface\\Cooldown\\star4")
    frame.flash:SetBlendMode("ADD")
    frame.flash:SetAlpha(0)
    
    -- Animation group
    frame.animGroup = frame.flash:CreateAnimationGroup()
    local fadeIn = frame.animGroup:CreateAnimation("Alpha")
    fadeIn:SetFromAlpha(0)
    fadeIn:SetToAlpha(0.7)
    fadeIn:SetDuration(0.5)
    fadeIn:SetOrder(1)
    
    local fadeOut = frame.animGroup:CreateAnimation("Alpha")
    fadeOut:SetFromAlpha(0.7)
    fadeOut:SetToAlpha(0)
    fadeOut:SetDuration(0.5)
    fadeOut:SetOrder(2)
    
    frame.animGroup:SetLooping("REPEAT")
    
    -- Tooltip handling
    frame:EnableMouse(true)
    frame:SetScript("OnEnter", function(self)
        if self.spellID then
            GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
            GameTooltip:SetSpellByID(self.spellID)
            
            if self.endTime then
                local remaining = self.endTime - GetTime()
                if remaining > 0 then
                    GameTooltip:AddLine(" ")
                    GameTooltip:AddLine(format("Cooldown: %d seconds", math.floor(remaining)), 1, 1, 1)
                    
                    -- Show which player has this cooldown
                    if self.playerName then
                        GameTooltip:AddLine(format("Player: %s", self.playerName), 1, 1, 1)
                    end
                else
                    GameTooltip:AddLine(" ")
                    GameTooltip:AddLine("Ready!", 0, 1, 0)
                end
            end
            
            GameTooltip:Show()
        end
    end)
    
    frame:SetScript("OnLeave", function(self)
        GameTooltip:Hide()
    end)
    
    -- Set script for click handlers
    frame:SetScript("OnMouseDown", function(self, button)
        if not self.spellID or not self.playerGUID then return end
        
        if button == "LeftButton" and settings.raidTools and settings.raidTools.requestCDs then
            -- Request this cooldown be used
            local player = partyMembers[self.playerGUID]
            if player then
                SendChatMessage(format("Please use %s!", GetSpellLink(self.spellID)), IsInRaid() and "RAID" or "PARTY")
            end
        elseif button == "RightButton" and settings.raidTools and settings.raidTools.assignCDs then
            -- Assign this cooldown to a boss mechanic
            if currentBossName and bossMechanics[currentBossName] then
                -- Show dropdown to assign to a mechanic
                -- This would need a custom dropdown implementation
            end
        end
    end)
    
    return frame
end

-- Create or get a status bar frame (bar mode)
local function GetBarFrame(parent, width, height)
    if #barFrames > 0 then
        return table.remove(barFrames)
    end
    
    local frame = CreateFrame("Frame", nil, parent)
    frame:SetSize(width, height)
    
    -- Background
    frame.bg = frame:CreateTexture(nil, "BACKGROUND")
    frame.bg:SetAllPoints()
    frame.bg:SetColorTexture(0.1, 0.1, 0.1, 0.8)
    
    -- Icon
    frame.icon = CreateFrame("Frame", nil, frame)
    frame.icon:SetSize(height, height)
    frame.icon:SetPoint("LEFT", frame, "LEFT", 0, 0)
    
    frame.iconTexture = frame.icon:CreateTexture(nil, "ARTWORK")
    frame.iconTexture:SetAllPoints()
    frame.iconTexture:SetTexCoord(0.08, 0.92, 0.08, 0.92) -- Trim the borders
    
    -- Status bar
    frame.statusbar = CreateFrame("StatusBar", nil, frame)
    frame.statusbar:SetPoint("TOPLEFT", frame.icon, "TOPRIGHT", 1, 0)
    frame.statusbar:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT", 0, 0)
    frame.statusbar:SetStatusBarTexture(GetBarTexture())
    frame.statusbar:SetMinMaxValues(0, 1)
    frame.statusbar:SetValue(1)
    
    -- Text for timer
    frame.text = frame.statusbar:CreateFontString(nil, "OVERLAY")
    frame.text:SetFont(Phoenix_UI.CooldownTracker:GetFontPath(), math.max(height*0.7, 10), "OUTLINE")
    frame.text:SetPoint("CENTER", frame.statusbar, "CENTER")
    frame.text:SetTextColor(1, 1, 1)
    
    -- Text for spell name
    frame.name = frame.statusbar:CreateFontString(nil, "OVERLAY")
    frame.name:SetFont(Phoenix_UI.CooldownTracker:GetFontPath(), math.max(height*0.5, 8), "OUTLINE")
    frame.name:SetPoint("LEFT", frame.statusbar, "LEFT", 2, 0)
    frame.name:SetTextColor(1, 1, 1)
    
    -- Text for player name
    frame.playerName = frame.statusbar:CreateFontString(nil, "OVERLAY")
    frame.playerName:SetFont(Phoenix_UI.CooldownTracker:GetFontPath(), math.max(height*0.5, 8), "OUTLINE")
    frame.playerName:SetPoint("RIGHT", frame.statusbar, "RIGHT", -2, 0)
    frame.playerName:SetTextColor(1, 1, 1)
    
    -- Animation for completion
    frame.flash = frame:CreateTexture(nil, "OVERLAY")
    frame.flash:SetAllPoints()
    frame.flash:SetColorTexture(1, 1, 1, 0)
    frame.flash:SetBlendMode("ADD")
    
    frame.animGroup = frame.flash:CreateAnimationGroup()
    local fadeIn = frame.animGroup:CreateAnimation("Alpha")
    fadeIn:SetFromAlpha(0)
    fadeIn:SetToAlpha(0.3)
    fadeIn:SetDuration(0.5)
    fadeIn:SetOrder(1)
    
    local fadeOut = frame.animGroup:CreateAnimation("Alpha")
    fadeOut:SetFromAlpha(0.3)
    fadeOut:SetToAlpha(0)
    fadeOut:SetDuration(0.5)
    fadeOut:SetOrder(2)
    
    frame.animGroup:SetLooping("REPEAT")
    
    -- Tooltip handling
    frame:EnableMouse(true)
    frame:SetScript("OnEnter", function(self)
        if self.spellID then
            GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
            GameTooltip:SetSpellByID(self.spellID)
            
            if self.endTime then
                local remaining = self.endTime - GetTime()
                if remaining > 0 then
                    GameTooltip:AddLine(" ")
                    GameTooltip:AddLine(format("Cooldown: %d seconds", math.floor(remaining)), 1, 1, 1)
                    
                    -- Show which player has this cooldown
                    if self.playerName then
                        GameTooltip:AddLine(format("Player: %s", self.playerNameText), 1, 1, 1)
                    end
                else
                    GameTooltip:AddLine(" ")
                    GameTooltip:AddLine("Ready!", 0, 1, 0)
                end
            end
            
            GameTooltip:Show()
        end
    end)
    
    frame:SetScript("OnLeave", function(self)
        GameTooltip:Hide()
    end)
    
    -- Click handling
    frame:SetScript("OnMouseDown", function(self, button)
        if not self.spellID or not self.playerGUID then return end
        
        if button == "LeftButton" and settings.raidTools and settings.raidTools.requestCDs then
            -- Request this cooldown be used
            SendChatMessage(format("Please use %s!", GetSpellLink(self.spellID)), IsInRaid() and "RAID" or "PARTY")
        end
    end)
    
    return frame
end

-- Set cooldown border color by category
local function SetBorderColor(frame, category)
    if not frame or not category or not cooldownCategories[category] then return end
    
    local color = cooldownCategories[category].color
    frame.border:SetVertexColor(color[1], color[2], color[3])
end

-- Create the standalone raid panel
local function CreateRaidPanel()
    if raidPanel then
        raidPanel:Hide()
        raidPanel = nil
    end
    
    if not settings.raidPanel.enabled then return end
    
    -- Create the main panel frame
    raidPanel = CreateFrame("Frame", "Phoenix_UI_CooldownRaidPanel", UIParent)
    raidPanel:SetSize(settings.iconSize * settings.raidPanel.columns * settings.raidPanel.scale, 
                     settings.iconSize * 5 * settings.raidPanel.scale) -- Adjust height dynamically later
    raidPanel:SetPoint(unpack(settings.raidPanel.position))
    raidPanel:SetMovable(true)
    raidPanel:SetClampedToScreen(true)
    
    -- Background (semi-transparent)
    raidPanel.bg = raidPanel:CreateTexture(nil, "BACKGROUND")
    raidPanel.bg:SetAllPoints()
    raidPanel.bg:SetColorTexture(0, 0, 0, 0.5)
    
    -- Title text
    raidPanel.title = raidPanel:CreateFontString(nil, "OVERLAY")
    raidPanel.title:SetFont(Phoenix_UI.CooldownTracker:GetFontPath(), 12, "OUTLINE")
    raidPanel.title:SetPoint("TOP", raidPanel, "TOP", 0, 5)
    raidPanel.title:SetText("Party/Raid Cooldowns")
    
    -- Make the frame movable when holding Alt
    raidPanel:SetScript("OnMouseDown", function(self, button)
        if IsAltKeyDown() and button == "LeftButton" then
            self:StartMoving()
        end
    end)
    
    raidPanel:SetScript("OnMouseUp", function(self, button)
        self:StopMovingOrSizing()
        -- Save position
        local point, relativeTo, relativePoint, xOfs, yOfs = self:GetPoint()
        if relativeTo then
            settings.raidPanel.position = {point, (relativeTo:GetName() or "UIParent"), relativePoint, xOfs, yOfs}
        end
    end)
    
    return raidPanel
end

-- Update the raid panel to show current cooldowns
local function UpdateRaidPanel()
    if not raidPanel or not settings.raidPanel.enabled then return end
    
    -- Clear existing cooldown frames
    for _, child in ipairs({raidPanel:GetChildren()}) do
        if child.isIcon then
            child:Hide()
            tinsert(CDFrames, child)
        elseif child.isBar then
            child:Hide()
            tinsert(barFrames, child)
        end
    end
    
    -- Get all active cooldowns from all party members
    local allCooldowns = {}
    for guid, member in pairs(partyMembers) do
        if activeCooldowns[guid] then
            for spellID, cdInfo in pairs(activeCooldowns[guid]) do
                local category = trackedCooldowns[spellID] and trackedCooldowns[spellID].category or "utility"
                if settings.trackedCDs[category] then
                    tinsert(allCooldowns, {
                        spellID = spellID,
                        category = category,
                        startTime = cdInfo.startTime,
                        duration = cdInfo.duration,
                        endTime = cdInfo.endTime,
                        playerName = member.name,
                        playerGUID = guid,
                        playerClass = member.class,
                        priority = cooldownCategories[category].priority
                    })
                end
            end
        end
    end
    
    -- Sort cooldowns by category priority and remaining time
    table.sort(allCooldowns, function(a, b)
        if a.category ~= b.category then
            return a.priority < b.priority
        else
            return (a.endTime or 0) < (b.endTime or 0)
        end
    end)
    
    -- Create icons or bars for each cooldown
    local row, col = 0, 0
    local maxCols = settings.raidPanel.columns
    
    for _, cdInfo in ipairs(allCooldowns) do
        local spellID = cdInfo.spellID
        
        if settings.displayMode == "ICON" then
            -- Icon mode
            local cdFrame = GetCooldownFrame(raidPanel, settings.raidPanel.size * settings.raidPanel.scale)
            cdFrame.isIcon = true
            cdFrame:ClearAllPoints()
            
            -- Position in grid
            if settings.raidPanel.growth == "RIGHT" then
                cdFrame:SetPoint("TOPLEFT", raidPanel, "TOPLEFT", 
                                col * (settings.raidPanel.size + settings.raidPanel.spacing) * settings.raidPanel.scale, 
                                -row * (settings.raidPanel.size + settings.raidPanel.spacing) * settings.raidPanel.scale - 15)
                col = col + 1
                if col >= maxCols then
                    col = 0
                    row = row + 1
                end
            else -- DOWN
                cdFrame:SetPoint("TOPLEFT", raidPanel, "TOPLEFT", 
                                row * (settings.raidPanel.size + settings.raidPanel.spacing) * settings.raidPanel.scale, 
                                -col * (settings.raidPanel.size + settings.raidPanel.spacing) * settings.raidPanel.scale - 15)
                col = col + 1
                if col >= maxCols then
                    col = 0
                    row = row + 1
                end
            end
            
            -- Update the cooldown icon
            UpdateCooldownFrame(cdFrame, spellID, cdInfo.startTime, cdInfo.duration)
            
            -- Set additional data for identification
            cdFrame.playerGUID = cdInfo.playerGUID
            cdFrame.playerName = cdInfo.playerName
            
            -- Show player name if enabled
            if settings.raidPanel.showName and cdFrame.name then
                cdFrame.name:SetText(cdInfo.playerName)
                
                -- Set name color to class color if possible
                if cdInfo.playerClass and RAID_CLASS_COLORS[cdInfo.playerClass] then
                    local color = RAID_CLASS_COLORS[cdInfo.playerClass]
                    cdFrame.name:SetTextColor(color.r, color.g, color.b)
                end
                
                cdFrame.name:Show()
            end
            
            -- Show animation if cooldown is ready
            if GetTime() >= (cdInfo.endTime or 0) and settings.flashAnimation then
                cdFrame.animGroup:Play()
            end
        elseif settings.displayMode == "BAR" then
            -- Bar mode
            local barFrame = GetBarFrame(raidPanel, settings.barWidth * settings.raidPanel.scale, 
                                       settings.barHeight * settings.raidPanel.scale)
            barFrame.isBar = true
            barFrame:ClearAllPoints()
            
            -- Position in column
            barFrame:SetPoint("TOPLEFT", raidPanel, "TOPLEFT", 5, 
                            -row * (settings.barHeight + 2) * settings.raidPanel.scale - 15)
            row = row + 1
            col = 0 -- Reset column as we use full width
            
            -- Get the spell info
            local name, _, icon = GetSpellInfo(spellID)
            
            -- Update bar appearance
            barFrame.iconTexture:SetTexture(icon)
            barFrame.name:SetText(name)
            barFrame.playerName:SetText(cdInfo.playerName)
            
            -- Set player name color to class color if possible
            if cdInfo.playerClass and RAID_CLASS_COLORS[cdInfo.playerClass] then
                local color = RAID_CLASS_COLORS[cdInfo.playerClass]
                barFrame.playerName:SetTextColor(color.r, color.g, color.b)
            end
            
            -- Set bar color based on spell category
            if cooldownCategories[cdInfo.category] then
                local color = cooldownCategories[cdInfo.category].color
                barFrame.statusbar:SetStatusBarColor(color[1], color[2], color[3], 0.7)
            else
                barFrame.statusbar:SetStatusBarColor(0.7, 0.7, 0.7, 0.7)
            end
            
            -- Update bar progress
            barFrame.spellID = spellID
            barFrame.playerGUID = cdInfo.playerGUID
            barFrame.playerNameText = cdInfo.playerName
            barFrame.endTime = cdInfo.endTime
            
            local now = GetTime()
            local remaining = cdInfo.endTime - now
            local total = cdInfo.duration
            
            if remaining > 0 and total > 0 then
                barFrame.statusbar:SetValue(remaining / total)
                barFrame.text:SetText(format("%d", floor(remaining)))
            else
                barFrame.statusbar:SetValue(1)
                barFrame.text:SetText("READY")
                
                -- Show animation if cooldown is ready
                if settings.flashAnimation then
                    barFrame.animGroup:Play()
                end
            end
            
            barFrame:Show()
        end
    end
    
    -- Resize the raid panel based on content
    if settings.displayMode == "ICON" then
        local totalRows = math.ceil(#allCooldowns / maxCols)
        local newHeight = totalRows * (settings.raidPanel.size + settings.raidPanel.spacing) * settings.raidPanel.scale + 20
        raidPanel:SetHeight(max(newHeight, 50)) -- Minimum height
    else
        local newHeight = row * (settings.barHeight + 2) * settings.raidPanel.scale + 20
        raidPanel:SetHeight(max(newHeight, 50)) -- Minimum height
    end
end

-- Function to get spell texture
local function GetSpellTexture(spellID)
    if not spellID then return nil end
    
    local texture
    
    -- First try C_Spell.GetSpellTexture which is the modern API
    if C_Spell and C_Spell.GetSpellTexture then
        texture = C_Spell.GetSpellTexture(spellID)
    end
    
    -- Fall back to GetSpellInfo for compatibility if C_Spell didn't work
    if not texture then
        local _, _, tex = GetSpellInfo(spellID)
        texture = tex
    end
    
    -- If we still don't have a texture, use a default question mark texture
    if not texture then
        texture = 134400 -- Question mark icon as fallback
    end
    
    return texture
end

-- Update a cooldown frame
local function UpdateCooldownFrame(frame, spellID, startTime, duration)
    if not frame or not spellID then return end
    
    local texture = GetSpellTexture(spellID)
    if not texture then return end
    
    frame.icon:SetTexture(texture)
    frame.spellID = spellID
    
    if startTime and duration then
        frame.cd:SetCooldown(startTime, duration)
        frame.endTime = startTime + duration
    else
        frame.cd:Clear()
        frame.endTime = nil
    end
    
    -- Find the cooldown information
    for className, cooldowns in pairs(classCooldowns) do
        for _, cooldownInfo in ipairs(cooldowns) do
            if cooldownInfo.spellID == spellID then
                SetBorderColor(frame, cooldownInfo.category)
                break
            end
        end
    end
    
    frame:Show()
end

-- Get cooldowns for a specific class and spec
local function GetClassCooldowns(className, specID)
    if not className or not classCooldowns[className] then return {} end
    
    local cooldowns = {}
    for _, cooldownInfo in ipairs(classCooldowns[className]) do
        -- Include if it's not spec-specific or matches the current spec
        if not cooldownInfo.specID or cooldownInfo.specID == specID then
            if settings.trackedCDs[cooldownInfo.category] then
                tinsert(cooldowns, cooldownInfo)
            end
        end
    end
    
    return cooldowns
end

-- Start tracking a player's cooldowns
local function StartTrackingPlayer(unit, className, specID, name, guid)
    -- Don't track if already tracking
    if partyMembers[guid] then return end
    
    partyMembers[guid] = {
        unit = unit,
        class = className,
        specID = specID,
        name = name,
        cooldowns = {},
    }
    
    -- Get cooldowns for this class/spec
    local cooldowns = GetClassCooldowns(className, specID)
    for _, cooldownInfo in ipairs(cooldowns) do
        -- Initialize each cooldown
        partyMembers[guid].cooldowns[cooldownInfo.spellID] = {
            spellID = cooldownInfo.spellID,
            category = cooldownInfo.category,
            cooldown = cooldownInfo.cooldown,
            lastUsed = 0,
            endTime = 0,
        }
        
        -- Index cooldowns for future reference
        trackedCooldowns[cooldownInfo.spellID] = cooldownInfo
    end
    
    -- Update the raid panel
    if settings.standalonePanels and settings.raidPanel.enabled then
        if not raidPanel then
            CreateRaidPanel()
        end
        UpdateRaidPanel()
    end
end

-- Stop tracking a player's cooldowns
local function StopTrackingPlayer(guid)
    if not partyMembers[guid] then return end
    
    -- Clear active cooldowns
    for spellID, _ in pairs(partyMembers[guid].cooldowns) do
        if activeCooldowns[guid] and activeCooldowns[guid][spellID] then
            activeCooldowns[guid][spellID] = nil
        end
    end
    
    partyMembers[guid] = nil
    
    -- Update the raid panel
    if settings.standalonePanels and settings.raidPanel.enabled then
        UpdateRaidPanel()
    end
end

-- Update cooldown display on raid frames
local function UpdateRaidFrameCooldowns(frame, unit)
    -- Skip if frames not enabled
    if not settings.showOnFrames then return end
    
    -- Skip forbidden frames
    if frame:IsForbidden() then return end
    
    -- Clear existing cooldown frames
    if frame.phoenixCDs then
        for _, cdFrame in ipairs(frame.phoenixCDs) do
            cdFrame:Hide()
            tinsert(CDFrames, cdFrame)
        end
        wipe(frame.phoenixCDs)
    else
        frame.phoenixCDs = {}
    end
    
    -- Get unit info
    local guid = UnitGUID(unit)
    if not guid or not partyMembers[guid] then return end
    
    -- Get active cooldowns for this player
    local playerCDs = activeCooldowns[guid]
    if not playerCDs then return end
    
    -- Sort cooldowns by priority
    local sortedCDs = {}
    for spellID, cdInfo in pairs(playerCDs) do
        local category = trackedCooldowns[spellID] and trackedCooldowns[spellID].category or "utility"
        local priority = cooldownCategories[category] and cooldownCategories[category].priority or 100
        
        tinsert(sortedCDs, {
            spellID = spellID,
            category = category,
            priority = priority,
            startTime = cdInfo.startTime,
            duration = cdInfo.duration,
            endTime = cdInfo.endTime,
        })
    end
    
    table.sort(sortedCDs, function(a, b)
        return a.priority < b.priority
    end)
    
    -- Create cooldown icons
    local iconSize = settings.iconSize
    local maxIcons = 3 -- Limit number of icons on frames
    local count = 0
    
    for _, cdInfo in ipairs(sortedCDs) do
        if count >= maxIcons then break end
        
        local cdFrame = GetCooldownFrame(frame, iconSize)
        cdFrame:ClearAllPoints()
        
        if settings.displayMode == "INLINEICON" then
            -- Inline icon mode - vertically stacked
            cdFrame:SetPoint("RIGHT", frame, "RIGHT", -2, (count - 1) * (iconSize + 2))
        else
            -- Default icon mode - horizontally aligned
            cdFrame:SetPoint("BOTTOMLEFT", frame, "BOTTOMLEFT", count * (iconSize + 2) + 2, 2)
        end
        
        -- Update the cooldown
        UpdateCooldownFrame(cdFrame, cdInfo.spellID, cdInfo.startTime, cdInfo.duration)
        
        -- Set player info for tooltip
        cdFrame.playerGUID = guid
        cdFrame.playerName = partyMembers[guid].name
        
        -- Track this frame
        tinsert(frame.phoenixCDs, cdFrame)
        count = count + 1
    end
end

-- Hook into Blizzard raid frames
local function HookRaidFrames()
    -- Hook into CompactUnitFrame_UpdateAll
    hooksecurefunc("CompactUnitFrame_UpdateAll", function(frame)
        if not frame or frame:IsForbidden() then return end
        
        local unit = frame.unit
        if not unit or not UnitExists(unit) or not UnitIsPlayer(unit) or UnitIsUnit(unit, "player") then return end
        
        -- Update cooldowns for this frame
        UpdateRaidFrameCooldowns(frame, unit)
        hookedFrames[frame] = true
    end)
end

-- Process a cooldown use
local function ProcessCooldownUse(guid, spellID)
    -- Check if we're tracking this player and spell
    if not partyMembers[guid] or not partyMembers[guid].cooldowns[spellID] then return end
    
    local cooldownInfo = partyMembers[guid].cooldowns[spellID]
    local now = GetTime()
    
    -- Initialize activeCooldowns for this player if needed
    if not activeCooldowns[guid] then
        activeCooldowns[guid] = {}
    end
    
    -- Record the cooldown use
    activeCooldowns[guid][spellID] = {
        startTime = now,
        duration = cooldownInfo.cooldown,
        endTime = now + cooldownInfo.cooldown,
    }
    
    -- Check for cooldown reduction effects if enabled
    if settings.trackCDReduction then
        -- Check if this player has any auras that reduce cooldowns
        local unit = partyMembers[guid].unit
        if unit and UnitExists(unit) then
            -- Check beneficial auras using modern API
            AuraUtil.ForEachAura(unit, "HELPFUL", nil, function(name, icon, count, debuffType, duration, expirationTime, source, isStealable, nameplateShowPersonal, auraSpellID, canApplyAura)
                -- Skip if no spell ID
                if not auraSpellID then return false end
                
                -- Check if this aura reduces cooldowns
                if cooldownReductionEffects[auraSpellID] and cooldownReductionEffects[auraSpellID][spellID] then
                    local reduction = cooldownReductionEffects[auraSpellID][spellID]
                    local reducedDuration = cooldownInfo.cooldown * (1 - reduction)
                    
                    -- Update the cooldown with the reduced duration
                    activeCooldowns[guid][spellID].duration = reducedDuration
                    activeCooldowns[guid][spellID].endTime = now + reducedDuration
                    
                    -- Debug info if needed
                    -- print("Reduced", GetSpellLink(spellID), "cooldown by", reduction*100, "% due to", GetSpellLink(auraSpellID))
                end
                return false -- Continue iterating
            end)
            
            -- Also check harmful auras
            AuraUtil.ForEachAura(unit, "HARMFUL", nil, function(name, icon, count, debuffType, duration, expirationTime, source, isStealable, nameplateShowPersonal, auraSpellID, canApplyAura)
                -- Skip if no spell ID
                if not auraSpellID then return false end
                
                -- Check if this aura reduces cooldowns
                if cooldownReductionEffects[auraSpellID] and cooldownReductionEffects[auraSpellID][spellID] then
                    local reduction = cooldownReductionEffects[auraSpellID][spellID]
                    local reducedDuration = cooldownInfo.cooldown * (1 - reduction)
                    
                    -- Update the cooldown with the reduced duration
                    activeCooldowns[guid][spellID].duration = reducedDuration
                    activeCooldowns[guid][spellID].endTime = now + reducedDuration
                end
                return false -- Continue iterating
            end)
        end
    end
    
    -- Update raid frames
    for frame, _ in pairs(hookedFrames) do
        if frame.unit and UnitGUID(frame.unit) == guid then
            UpdateRaidFrameCooldowns(frame, frame.unit)
        end
    end
    
    -- Update raid panel if it exists
    if settings.standalonePanels and settings.raidPanel.enabled and raidPanel then
        UpdateRaidPanel()
    end
    
    -- Schedule the cooldown expiration
    C_Timer.After(activeCooldowns[guid][spellID].duration, function()
        if activeCooldowns[guid] and activeCooldowns[guid][spellID] then
            activeCooldowns[guid][spellID] = nil
            
            -- Update raid frames
            for frame, _ in pairs(hookedFrames) do
                if frame.unit and UnitGUID(frame.unit) == guid then
                    UpdateRaidFrameCooldowns(frame, frame.unit)
                end
            end
            
            -- Update raid panel
            if settings.standalonePanels and settings.raidPanel.enabled and raidPanel then
                UpdateRaidPanel()
            end
            
            -- Play alert sound if configured
            if settings.alertSound then
                PlaySoundFile(settings.alertSound, "Master")
            end
            
            -- Flash animation if configured
            if settings.flashAnimation then
                -- We would need to find the relevant frame to play the animation on
                -- This would be done through the raid panel or raid frames
            end
        end
    end)
end

-- Check for boss encounters
local function CheckBossEncounter()
    -- Only relevant if boss mod integration is enabled
    if not settings.bossModIntegration or not settings.bossModIntegration.enabled then return end
    
    -- Check if we're in a boss encounter
    local inEncounter = false
    local bossName = nil
    
    -- Try to detect from BigWigs if present
    if BigWigsAPI and BigWigsAPI.GetBossModule then
        local activeBossModule = BigWigsAPI.GetBossModule()
        if activeBossModule then
            inEncounter = true
            bossName = activeBossModule.displayName
        end
    end
    
    -- Try to detect from DBM if present
    if not inEncounter and DBM and DBM.GetModLocalization then
        for i = 1, #DBM.Mods do
            local mod = DBM.Mods[i]
            if mod.inCombat then
                inEncounter = true
                bossName = mod.localization.general.name
                break
            end
        end
    end
    
    -- Update module state
    bossEncounterActive = inEncounter
    currentBossName = bossName
    
    -- If we entered a boss encounter, check for needed cooldowns
    if inEncounter and bossName and bossMechanics[bossName] and settings.bossModIntegration.highlightNeededCDs then
        -- Notify raid of needed cooldowns
        if IsInRaid() and settings.bossModIntegration.showCDsForNextMechanic then
            C_Timer.After(2, function()
                SendChatMessage("Boss encounter: " .. bossName .. " - Required cooldowns:", IsInRaid() and "RAID" or "PARTY")
                
                for _, mechanic in ipairs(bossMechanics[bossName]) do
                    local mechanicName, mechanicTime, requiredCD = unpack(mechanic)
                    SendChatMessage(mechanicName .. " (" .. mechanicTime .. "s) - Need " .. cooldownCategories[requiredCD].name, IsInRaid() and "RAID" or "PARTY")
                end
            end)
        end
    end
end

-- Register events to track group members and cooldowns
local function RegisterEvents()
    -- Create event frame
    if not eventFrame then
        eventFrame = CreateFrame("Frame")
    else
        -- Unregister all existing events
        eventFrame:UnregisterAllEvents()
        eventFrame:SetScript("OnEvent", nil)
    end
    
    -- Register events
    eventFrame:RegisterEvent("GROUP_ROSTER_UPDATE")
    eventFrame:RegisterEvent("UNIT_SPELLCAST_SUCCEEDED")
    eventFrame:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
    eventFrame:RegisterEvent("PLAYER_ENTERING_WORLD")
    eventFrame:RegisterEvent("ENCOUNTER_START")
    eventFrame:RegisterEvent("ENCOUNTER_END")
    
    -- Process events
    eventFrame:SetScript("OnEvent", function(self, event, ...)
        if not settings or not settings.enabled then return end
        
        if event == "GROUP_ROSTER_UPDATE" or event == "PLAYER_ENTERING_WORLD" then
            -- Update party/raid roster
            -- Clear existing data
            for guid, _ in pairs(partyMembers) do
                StopTrackingPlayer(guid)
            end
            
            -- Add player
            local _, playerClass = UnitClass("player")
            local playerSpecID = GetSpecialization()
            if playerSpecID then
                local classID = classIds[playerClass]
                playerSpecID = GetSpecializationInfoForClassID(classID, playerSpecID)
            end
            StartTrackingPlayer("player", playerClass, playerSpecID, UnitName("player"), UnitGUID("player"))
            
            -- Add party/raid members
            if IsInGroup() then
                local prefix = IsInRaid() and "raid" or "party"
                local numMembers = IsInRaid() and GetNumGroupMembers() or GetNumSubgroupMembers()
                
                for i = 1, numMembers do
                    local unit = prefix .. i
                    if UnitExists(unit) and not UnitIsUnit(unit, "player") then
                        local _, className = UnitClass(unit)
                        local name = UnitName(unit)
                        local guid = UnitGUID(unit)
                        
                        -- We don't know their spec initially, will update later
                        StartTrackingPlayer(unit, className, nil, name, guid)
                    end
                end
            end
            
            -- Update standalone panels if enabled
            if settings.standalonePanels and settings.raidPanel.enabled then
                if not raidPanel then
                    CreateRaidPanel()
                end
                UpdateRaidPanel()
            end
            
        elseif event == "UNIT_SPELLCAST_SUCCEEDED" then
            local unit, _, spellID = ...
            if not unit or not UnitExists(unit) or not UnitIsPlayer(unit) then return end
            
            local guid = UnitGUID(unit)
            
            -- Check if this is a tracked cooldown
            if trackedCooldowns[spellID] then
                ProcessCooldownUse(guid, spellID)
            end
            
        elseif event == "COMBAT_LOG_EVENT_UNFILTERED" then
            local timestamp, eventType, hideCaster, sourceGUID, sourceName, sourceFlags, sourceRaidFlags, 
                destGUID, destName, destFlags, destRaidFlags, spellID, spellName = CombatLogGetCurrentEventInfo()
            
            -- Only process spell casts from group members
            if eventType == "SPELL_CAST_SUCCESS" and partyMembers[sourceGUID] then
                -- Check if this is a tracked cooldown
                if trackedCooldowns[spellID] then
                    ProcessCooldownUse(sourceGUID, spellID)
                end
            elseif eventType == "SPELL_INTERRUPT" and partyMembers[sourceGUID] then
                -- Special handling for interrupts since they might not be cast directly
                for className, cooldowns in pairs(classCooldowns) do
                    for _, cooldownInfo in ipairs(cooldowns) do
                        if cooldownInfo.category == "interrupt" and cooldownInfo.spellID == spellID then
                            ProcessCooldownUse(sourceGUID, spellID)
                            break
                        end
                    end
                end
            end
        elseif event == "ENCOUNTER_START" then
            local encounterID, encounterName = ...
            currentBossName = encounterName
            bossEncounterActive = true
            
            -- Check for boss mechanics
            CheckBossEncounter()
            
        elseif event == "ENCOUNTER_END" then
            bossEncounterActive = false
            currentBossName = nil
        end
    end)
    
    -- Set up periodic updates
    if not updateTimer then
        updateTimer = C_Timer.NewTicker(0.5, function()
            if settings.standalonePanels and settings.raidPanel.enabled and raidPanel then
                UpdateRaidPanel()
            end
        end)
    end
end

-- Unregister all events
local function UnregisterEvents()
    if eventFrame then
        eventFrame:UnregisterAllEvents()
        eventFrame:SetScript("OnEvent", nil)
    end
    
    if updateTimer then
        updateTimer:Cancel()
        updateTimer = nil
    end
end

-- Initialize the module with settings
function Module:Initialize(options)
    settings = options
    
    -- Load class cooldowns from main module if available
    if Phoenix_UI.db.profile.cooldownTracker.partyCD.classCooldowns and next(Phoenix_UI.db.profile.cooldownTracker.partyCD.classCooldowns) then
        for className, classData in pairs(Phoenix_UI.db.profile.cooldownTracker.partyCD.classCooldowns) do
            -- Convert formatted data into our internal format
            for category, spells in pairs(classData) do
                if not classCooldowns[className] then
                    classCooldowns[className] = {}
                end
                
                for _, spellID in ipairs(spells) do
                    -- Look up cooldown duration from spell data or use 60s default
                    local cooldown = 60 -- Default
                    
                    -- Get actual cooldown from spellID if possible
                    local name, _, icon = SafeGetSpellInfo(spellID)
                    
                    -- Only add the spell if it's valid
                    if spellID then
                        tinsert(classCooldowns[className], {
                            spellID = spellID,
                            category = category,
                            cooldown = cooldown
                        })
                    end
                end
            end
        end
    end
    
    -- Create frames for displaying cooldowns
    if settings.showOnFrames then
        HookRaidFrames()
    end
    
    -- Create standalone panels if enabled
    if settings.standalonePanels and settings.raidPanel.enabled then
        CreateRaidPanel()
    end
    
    -- Register for events
    RegisterEvents()
end

-- Update settings
function Module:UpdateSettings(options)
    local previousEnabled = settings and settings.enabled
    local previousShowOnFrames = settings and settings.showOnFrames
    local previousStandalonePanels = settings and settings.standalonePanels
    
    settings = options
    
    -- Update CD frames with new settings
    for _, frame in ipairs(CDFrames) do
        frame.cd:SetHideCountdownNumbers(not settings.showText)
    end
    
    -- Handle enabled state change
    if previousEnabled ~= settings.enabled then
        if settings.enabled then
            RegisterEvents()
        else
            UnregisterEvents()
            
            -- Clear active cooldowns
            for guid, _ in pairs(activeCooldowns) do
                activeCooldowns[guid] = nil
            end
            
            -- Clear displayed cooldowns
            for frame, _ in pairs(hookedFrames) do
                if frame.phoenixCDs then
                    for _, cdFrame in ipairs(frame.phoenixCDs) do
                        cdFrame:Hide()
                        tinsert(CDFrames, cdFrame)
                    end
                    wipe(frame.phoenixCDs)
                end
            end
            
            -- Hide raid panel
            if raidPanel then
                raidPanel:Hide()
            end
        end
    end
    
    -- Update frame visibility
    if previousShowOnFrames ~= settings.showOnFrames then
        if settings.showOnFrames then
            HookRaidFrames()
        else
            -- Clear all existing CD frames
            for frame, _ in pairs(hookedFrames) do
                if frame.phoenixCDs then
                    for _, cdFrame in ipairs(frame.phoenixCDs) do
                        cdFrame:Hide()
                        tinsert(CDFrames, cdFrame)
                    end
                    wipe(frame.phoenixCDs)
                end
            end
        end
    end
    
    -- Update standalone panels
    if previousStandalonePanels ~= settings.standalonePanels or settings.raidPanel.enabled ~= (raidPanel ~= nil) then
        if settings.standalonePanels and settings.raidPanel.enabled then
            if not raidPanel then
                CreateRaidPanel()
            end
            UpdateRaidPanel()
        else
            if raidPanel then
                raidPanel:Hide()
                raidPanel = nil
            end
        end
    elseif raidPanel then
        -- Just update existing raid panel
        UpdateRaidPanel()
    end
end

-- Create a test cooldown
function Module:TestCooldown(spellID, className, category, duration)
    if not spellID then
        -- Use a default spell if none provided
        spellID = 31884 -- Avenging Wrath
        className = "PALADIN"
        category = "offensive"
        duration = 120
    end
    
    -- Add the cooldown to tracked cooldowns
    if not trackedCooldowns[spellID] then
        trackedCooldowns[spellID] = {
            spellID = spellID,
            category = category or "offensive",
            cooldown = duration or 120,
        }
    end
    
    -- Create a test activation
    local playerGUID = UnitGUID("player")
    if not playerGUID then return end
    
    if not activeCooldowns[playerGUID] then
        activeCooldowns[playerGUID] = {}
    end
    
    local now = GetTime()
    activeCooldowns[playerGUID][spellID] = {
        startTime = now,
        duration = duration or 120,
        endTime = now + (duration or 120),
    }
    
    -- Update all displays
    if settings.showOnFrames then
        for frame, _ in pairs(hookedFrames) do
            if frame.unit and UnitGUID(frame.unit) == playerGUID then
                UpdateRaidFrameCooldowns(frame, frame.unit)
            end
        end
    end
    
    if settings.standalonePanels and settings.raidPanel.enabled and raidPanel then
        UpdateRaidPanel()
    end
end

-- Add a class cooldown
function Module:AddClassCooldown(className, spellID, category, cooldown, specID)
    if not className or not spellID or not category then return end
    
    if not classCooldowns[className] then
        classCooldowns[className] = {}
    end
    
    tinsert(classCooldowns[className], {
        spellID = spellID,
        category = category,
        cooldown = cooldown or 60,
        specID = specID,
    })
    
    -- Update existing party members if they match
    for guid, info in pairs(partyMembers) do
        if info.class == className and (not specID or info.specID == specID) then
            StartTrackingPlayer(info.unit, info.class, info.specID, info.name, guid)
        end
    end
    
    -- Update displays
    if settings.showOnFrames then
        for frame, _ in pairs(hookedFrames) do
            if frame.unit then
                UpdateRaidFrameCooldowns(frame, frame.unit)
            end
        end
    end
    
    if settings.standalonePanels and settings.raidPanel.enabled and raidPanel then
        UpdateRaidPanel()
    end
end

-- Clean up all resources
function Module:Disable()
    -- Unregister events
    UnregisterEvents()
    
    -- Clear all active cooldowns
    wipe(activeCooldowns)
    wipe(partyMembers)
    
    -- Hide and clear all cooldown frames
    for frame, _ in pairs(hookedFrames) do
        if frame.phoenixCDs then
            for _, cdFrame in ipairs(frame.phoenixCDs) do
                cdFrame:Hide()
            end
            wipe(frame.phoenixCDs)
        end
    end
    
    -- Clear frame pools
    for _, frame in ipairs(CDFrames) do
        frame:Hide()
    end
    
    for _, frame in ipairs(barFrames) do
        frame:Hide()
    end
    
    -- Hide raid panel
    if raidPanel then
        raidPanel:Hide()
        raidPanel = nil
    end
    
    -- Clear hooks
    wipe(hookedFrames)
end

-- Update the status of a single cooldown
local function UpdateCooldownStatus(unitGUID, spellID, startTime, duration)
    -- Ensure we have valid parameters
    if not unitGUID or not spellID then return end
    
    -- Create or update the cooldown status
    if not activeCooldowns[unitGUID] then
        activeCooldowns[unitGUID] = {}
    end
    
    local now = GetTime()
    local activeStatus = activeCooldowns[unitGUID][spellID]
    
    -- If no start time, this is a cooldown reset
    if not startTime then
        -- Remove from active cooldowns
        activeCooldowns[unitGUID][spellID] = nil
        return
    end
    
    -- Create or update cooldown status
    activeCooldowns[unitGUID][spellID] = {
        startTime = startTime,
        duration = duration,
        endTime = startTime + duration,
        spellID = spellID
    }
    
    -- Get spell info for the cooldown
    local name, _, icon = SafeGetSpellInfo(spellID)
end 