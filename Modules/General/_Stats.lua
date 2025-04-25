local Module = Phoenix_UI:NewModule("General.Stats");

-- Add module-level variables to store these references
Module.primaryStats = nil
Module.secondaryStats = nil 
Module.stats = nil
Module.separator = nil
Module.cdHeader = nil
Module.cdSeparator = nil
Module.bloodlustCDFrame = nil
Module.combatResCDFrame = nil
Module.bloodlustText = nil
Module.combatResText = nil
Module.contentFrame = nil
Module.addonFont = nil
Module.statsTextSize = nil
Module.UpdateCooldowns = nil

function Module:OnEnable()
    -- Load from database with fallback values
    local db = {
        display = {
            fps = Phoenix_UI.db.profile.general.display and Phoenix_UI.db.profile.general.display.fps ~= nil 
                  and Phoenix_UI.db.profile.general.display.fps or true,
            ms = Phoenix_UI.db.profile.general.display and Phoenix_UI.db.profile.general.display.ms ~= nil 
                and Phoenix_UI.db.profile.general.display.ms or true,
            movementSpeed = Phoenix_UI.db.profile.general.display and Phoenix_UI.db.profile.general.display.movementSpeed or false,
            spec = Phoenix_UI.db.profile.general.display and Phoenix_UI.db.profile.general.display.spec ~= nil 
                  and Phoenix_UI.db.profile.general.display.spec or true,
            loot = Phoenix_UI.db.profile.general.display and Phoenix_UI.db.profile.general.display.loot ~= nil 
                  and Phoenix_UI.db.profile.general.display.loot or true,
            playerStats = Phoenix_UI.db.profile.general.display and Phoenix_UI.db.profile.general.display.playerStats ~= nil
                  and Phoenix_UI.db.profile.general.display.playerStats or true
        },
        statsframe = Phoenix_UI.db.profile.edit and Phoenix_UI.db.profile.edit.statsframe or {
            point = "TOPLEFT",
            x = 10,
            y = -10
        },
        playerStatsFrame = Phoenix_UI.db.profile.edit and Phoenix_UI.db.profile.edit.playerStatsFrame or {
            point = "TOPRIGHT",
            x = -10,
            y = -150,
            width = 150,
            height = 250  -- Increased from 180 to 250 for better fit
        }
    }

    -- Create or get existing frame
    StatsFrame = StatsFrame or CreateFrame("Frame", "StatsFrame", UIParent)
    StatsFrame:ClearAllPoints()
    StatsFrame:SetPoint(db.statsframe.point, UIParent, db.statsframe.point, db.statsframe.x, db.statsframe.y)
    StatsFrame:SetFrameStrata("HIGH")
    StatsFrame:SetFrameLevel(1)

    local font = STANDARD_TEXT_FONT
    local fontSize = 13
    local fontFlag = "THINOUTLINE"
    local textAlign = "CENTER"
    local useShadow = true

    -- Get class color
    local _, class = UnitClass("player")
    local color = (CUSTOM_CLASS_COLORS or RAID_CLASS_COLORS)[class]

    local function status()
        local function getFPS() return "|c00ffffff" .. floor(GetFramerate()) .. "|r fps" end
        local function getLatency() return "|c00ffffff" .. select(4, GetNetStats()) .. "|r ms" end
        
        local function getSpec()
            local specID = GetSpecialization()
            if specID then
                local _, specName = GetSpecializationInfo(specID)
                if specName then
                    return "|c00ffffff" .. specName .. "|r"
                else
                    -- Fallback if specName is nil
                    return "|c00ffffff" .. "Spec " .. specID .. "|r"
                end
            end
            return ""
        end
        
        local function getLootSpec()
            local specID = GetLootSpecialization()
            if specID and specID > 0 then
                local _, specName = GetSpecializationInfoByID(specID)
                if specName then
                    return "|c00ffffff" .. specName .. "|r loot"
                else
                    -- Fallback if specName is nil
                    return "|c00ffffff" .. "Spec " .. specID .. "|r loot"
                end
            elseif specID == 0 then
                -- Current spec
                return "|c00ffffff" .. "Current Spec" .. "|r loot"
            end
            return ""
        end

        local result = {}
        if db.display.fps then
            table.insert(result, getFPS())
        end
        
        if db.display.ms then
            table.insert(result, getLatency())
        end
        
        if db.display.spec then
            local specText = getSpec()
            if specText ~= "" then
                table.insert(result, specText)
            end
        end
        
        if db.display.loot then
            local lootText = getLootSpec()
            if lootText ~= "" then
                table.insert(result, lootText)
            end
        end
        
        return table.concat(result, " ")
    end

    StatsFrame:SetWidth(200) -- Set wider initially to accommodate more text
    StatsFrame:SetHeight(fontSize)
    StatsFrame.text = StatsFrame.text or StatsFrame:CreateFontString(nil, "BACKGROUND")
    StatsFrame.text:SetPoint(textAlign, StatsFrame)
    StatsFrame.text:SetFont(font, fontSize, fontFlag)
    if useShadow then
        StatsFrame.text:SetShadowOffset(1, -1)
        StatsFrame.text:SetShadowColor(0, 0, 0)
    end
    StatsFrame.text:SetTextColor(color.r, color.g, color.b)

    local lastUpdate = 0
    local function update(self, elapsed)
        lastUpdate = lastUpdate + elapsed
        if lastUpdate > 0.2 then
            lastUpdate = 0
            StatsFrame.text:SetText(status())
            self:SetWidth(StatsFrame.text:GetStringWidth() + 10) -- Add padding
            self:SetHeight(StatsFrame.text:GetStringHeight())
        end
    end

    StatsFrame:SetScript("OnUpdate", update)
    StatsFrame:Show()

    -- PLAYER STATS FRAME IMPLEMENTATION
    -- Create and configure player stats frame
    local PlayerStatsFrame = CreateFrame("Frame", "Phoenix_PlayerStatsFrame", UIParent, "BackdropTemplate")
    PlayerStatsFrame:SetSize(db.playerStatsFrame.width, db.playerStatsFrame.height)
    PlayerStatsFrame:SetPoint(db.playerStatsFrame.point, UIParent, db.playerStatsFrame.point, db.playerStatsFrame.x, db.playerStatsFrame.y)
    PlayerStatsFrame:SetFrameStrata("MEDIUM")
    PlayerStatsFrame:EnableMouse(true)
    PlayerStatsFrame:SetMovable(true)
    -- We'll handle resizing manually with the resize button
    PlayerStatsFrame:SetClampedToScreen(true)
    
    -- Create transparent backdrop
    local backdropInfo = {
        bgFile = "Interface/Tooltips/UI-Tooltip-Background",
        edgeFile = "Interface/Tooltips/UI-Tooltip-Border",
        tile = true,
        tileSize = 16,
        edgeSize = 16,
        insets = { left = 4, right = 4, top = 4, bottom = 4 }
    }
    
    -- Apply backdrop with compatibility for all WoW versions
    if PlayerStatsFrame.SetBackdrop then
        PlayerStatsFrame:SetBackdrop(backdropInfo)
        PlayerStatsFrame:SetBackdropColor(0, 0, 0, 0.6)
        PlayerStatsFrame:SetBackdropBorderColor(0.3, 0.3, 0.3, 0.8)
    else
        -- For newer WoW versions
        PlayerStatsFrame.backdropInfo = backdropInfo
        Mixin(PlayerStatsFrame, BackdropTemplateMixin)
        PlayerStatsFrame:OnBackdropLoaded()
        PlayerStatsFrame:SetBackdropColor(0, 0, 0, 0.6)
        PlayerStatsFrame:SetBackdropBorderColor(0.3, 0.3, 0.3, 0.8)
    end
    
    -- Add a title bar
    local titleBar = CreateFrame("Frame", nil, PlayerStatsFrame, "BackdropTemplate")
    titleBar:SetHeight(20)
    titleBar:SetPoint("TOPLEFT", PlayerStatsFrame, "TOPLEFT", 0, 0)
    titleBar:SetPoint("TOPRIGHT", PlayerStatsFrame, "TOPRIGHT", 0, 0)
    
    -- Title bar backdrop with compatibility
    local titleBackdropInfo = {
        bgFile = "Interface/Tooltips/UI-Tooltip-Background",
        tile = true,
        tileSize = 16
    }
    
    -- Apply title bar backdrop with compatibility for all WoW versions
    if titleBar.SetBackdrop then
        titleBar:SetBackdrop(titleBackdropInfo)
        titleBar:SetBackdropColor(0.1, 0.1, 0.1, 0.8)
    else
        -- For newer WoW versions
        titleBar.backdropInfo = titleBackdropInfo
        Mixin(titleBar, BackdropTemplateMixin)
        titleBar:OnBackdropLoaded()
        titleBar:SetBackdropColor(0.1, 0.1, 0.1, 0.8)
    end
    
    -- Title text
    local titleText = titleBar:CreateFontString(nil, "OVERLAY")
    titleText:SetFont(Phoenix_UI.db.profile.general.font or [[Interface/AddOns/Phoenix_UI/Media/Fonts/Prototype.ttf]], 10, "OUTLINE")
    titleText:SetPoint("CENTER", titleBar, "CENTER", 0, 0)
    titleText:SetText("Player Stats")
    
    -- Make the frame draggable by the title bar
    titleBar:SetScript("OnMouseDown", function(self, button)
        if button == "LeftButton" then
            PlayerStatsFrame:StartMoving()
        end
    end)
    
    titleBar:SetScript("OnMouseUp", function(self, button)
        PlayerStatsFrame:StopMovingOrSizing()
        -- Save position
        local point, _, _, xOfs, yOfs = PlayerStatsFrame:GetPoint()
        if not Phoenix_UI.db.profile.edit then Phoenix_UI.db.profile.edit = {} end
        if not Phoenix_UI.db.profile.edit.playerStatsFrame then Phoenix_UI.db.profile.edit.playerStatsFrame = {} end
        
        Phoenix_UI.db.profile.edit.playerStatsFrame.point = point
        Phoenix_UI.db.profile.edit.playerStatsFrame.x = xOfs
        Phoenix_UI.db.profile.edit.playerStatsFrame.y = yOfs
        
        -- Save size
        Phoenix_UI.db.profile.edit.playerStatsFrame.width = PlayerStatsFrame:GetWidth()
        Phoenix_UI.db.profile.edit.playerStatsFrame.height = PlayerStatsFrame:GetHeight()
        
        -- Force DB save
        if Phoenix_UI.SaveDB then
            Phoenix_UI:SaveDB()
        end
    end)
    
    -- Add resize handle
    local resizeButton = CreateFrame("Button", nil, PlayerStatsFrame)
    resizeButton:SetSize(16, 16)
    resizeButton:SetPoint("BOTTOMRIGHT")
    resizeButton:SetNormalTexture("Interface/ChatFrame/UI-ChatIM-SizeGrabber-Up")
    resizeButton:SetHighlightTexture("Interface/ChatFrame/UI-ChatIM-SizeGrabber-Highlight")
    resizeButton:SetPushedTexture("Interface/ChatFrame/UI-ChatIM-SizeGrabber-Down")
    
    resizeButton:SetScript("OnMouseDown", function(self, button)
        if button == "LeftButton" then
            -- Start the manual resize operation
            local initialCursorX, initialCursorY = GetCursorPosition()
            local initialWidth, initialHeight = PlayerStatsFrame:GetSize()
            local uiScale = UIParent:GetEffectiveScale()
            
            -- Store initial values
            self.initialCursorX = initialCursorX
            self.initialCursorY = initialCursorY
            self.initialWidth = initialWidth
            self.initialHeight = initialHeight
            
            -- Create a frame to catch mouse movement events
            if not self.resizeFrame then
                self.resizeFrame = CreateFrame("Frame", nil, UIParent)
                self.resizeFrame:SetScript("OnUpdate", function()
                    if self.resizing then
                        local currentCursorX, currentCursorY = GetCursorPosition()
                        local diffX = (currentCursorX - self.initialCursorX) / uiScale
                        local diffY = (currentCursorY - self.initialCursorY) / uiScale
                        
                        -- Calculate new dimensions
                        local newWidth = self.initialWidth + diffX
                        local newHeight = self.initialHeight - diffY
                        
                        -- Apply min/max constraints
                        newWidth = max(120, min(600, newWidth))    -- Increased from 300 to 600
                        newHeight = max(150, min(600, newHeight))  -- Increased from 300 to 600
                        
                        -- Apply the new size
                        PlayerStatsFrame:SetSize(newWidth, newHeight)
                    end
                end)
            end
            
            -- Begin resize operation
            self.resizing = true
            self.resizeFrame:Show()
        end
    end)
    
    resizeButton:SetScript("OnMouseUp", function(self, button)
        -- End resize operation
        self.resizing = false
        if self.resizeFrame then
            self.resizeFrame:Hide()
        end
        
        -- Save size
        if not Phoenix_UI.db.profile.edit then Phoenix_UI.db.profile.edit = {} end
        if not Phoenix_UI.db.profile.edit.playerStatsFrame then Phoenix_UI.db.profile.edit.playerStatsFrame = {} end
        
        Phoenix_UI.db.profile.edit.playerStatsFrame.width = PlayerStatsFrame:GetWidth()
        Phoenix_UI.db.profile.edit.playerStatsFrame.height = PlayerStatsFrame:GetHeight()
        
        -- Force DB save
        if Phoenix_UI.SaveDB then
            Phoenix_UI:SaveDB()
        end
    end)
    
    -- Create content frame to hold stat items
    local contentFrame = CreateFrame("Frame", nil, PlayerStatsFrame)
    contentFrame:SetPoint("TOPLEFT", PlayerStatsFrame, "TOPLEFT", 14, -25)  -- Increased left padding from 10 to 14 and top padding from -22 to -25
    contentFrame:SetPoint("BOTTOMRIGHT", PlayerStatsFrame, "BOTTOMRIGHT", -14, 14)  -- Increased right padding from -10 to -14 and bottom padding from 10 to 14
    
    -- Store reference at module level
    self.contentFrame = contentFrame
    
    -- Function to get stat values with caching for better performance
    local function GetPlayerStat(statID)
        local statName, _, effectiveStat = UnitStat("player", statID)
        return effectiveStat or 0
    end

    -- Constants for formatting with Phoenix theme integration
    local STAT_COLORS = {
        PRIMARY = "FFFF9900",      -- Phoenix orange for primary stats
        CRIT = "FFFF5555",         -- Light red
        HASTE = "FFFFFF00",        -- Yellow
        MASTERY = "FF55AAFF",      -- Light blue
        VERSATILITY = "FF00FF00",  -- Green
        SPEED = "FFAA66FF",        -- Purple
        LEECH = "FF00AA00",        -- Green
        AVOIDANCE = "FFFFFFFF",    -- White
        ARMOR = "FF888888"         -- Grey
    }

    local addonFont = Phoenix_UI.db.profile.general.font or [[Interface/AddOns/Phoenix_UI/Media/Fonts/Prototype.ttf]]
    local statsTextSize = 11
    
    -- Store references at module level
    self.addonFont = addonFont
    self.statsTextSize = statsTextSize

    -- Function to create stat text entries with comparison support
    local function CreateStatDisplay(parent, name, color, statFunc, order, tooltip)
        local statFrame = CreateFrame("Frame", nil, parent)
        statFrame:SetHeight(statsTextSize + 5) -- Increased height
        statFrame:SetPoint("TOPLEFT", parent, "TOPLEFT", 0, -((order-1) * (statsTextSize + 9))) -- Increased spacing from 7 to 9
        statFrame:SetPoint("TOPRIGHT", parent, "TOPRIGHT", 0, -((order-1) * (statsTextSize + 9)))
        
        local label = statFrame:CreateFontString(nil, "OVERLAY")
        label:SetFont(addonFont, statsTextSize, "THICKOUTLINE") -- Changed from OUTLINE to THICKOUTLINE
        label:SetPoint("LEFT", statFrame, "LEFT", 0, 0)
        label:SetTextColor(1, 1, 1)
        label:SetText(name)
        statFrame.labelText = label
        
        local value = statFrame:CreateFontString(nil, "OVERLAY")
        value:SetFont(addonFont, statsTextSize, "THICKOUTLINE") -- Changed from OUTLINE to THICKOUTLINE
        value:SetPoint("RIGHT", statFrame, "RIGHT", 0, 0)
        value:SetTextColor(1, 1, 1)
        statFrame.valueText = value
        
        -- Add indicator for stat changes
        local indicator = statFrame:CreateFontString(nil, "OVERLAY")
        indicator:SetFont(addonFont, 10, "THICKOUTLINE") -- Changed from OUTLINE to THICKOUTLINE
        indicator:SetPoint("RIGHT", value, "LEFT", -2, 0)
        indicator:SetTextColor(1, 1, 1)
        indicator:SetText("")
        
        -- Store previous value for comparison
        statFrame.previousValue = 0
        
        -- Add tooltip if provided
        if tooltip then
            statFrame:EnableMouse(true)
            statFrame:SetScript("OnEnter", function(self)
                GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
                GameTooltip:SetText(name:gsub(":", ""), 1, 1, 1)
                GameTooltip:AddLine(tooltip, 1, 0.82, 0, true)
                GameTooltip:Show()
            end)
            statFrame:SetScript("OnLeave", function()
                GameTooltip:Hide()
            end)
        end
        
        -- Update function with change indicator
        statFrame.Update = function()
            local val, rawValue = statFunc()
            
            -- Store raw value for comparison if available
            rawValue = rawValue or tonumber(string.match(val, "%(([%d%.]+)") or "0")
            
            -- Set the formatted text
            value:SetText("|c" .. color .. val .. "|r")
            
            -- Update change indicator if we have previous value and in combat
            if statFrame.previousValue > 0 and rawValue ~= statFrame.previousValue then
                if rawValue > statFrame.previousValue then
                    indicator:SetText("▲")
                    indicator:SetTextColor(0, 1, 0) -- Green for increase
                elseif rawValue < statFrame.previousValue then
                    indicator:SetText("▼") 
                    indicator:SetTextColor(1, 0, 0) -- Red for decrease
                end
                
                -- Fade out indicator after a short time
                C_Timer.After(3, function() indicator:SetText("") end)
            end
            
            -- Store value for next comparison
            statFrame.previousValue = rawValue
        end
        
        return statFrame
    end

    -- Enhanced helper functions to get specific stats with tooltips

    -- Primary Stats
    local function GetStrength()
        local val = GetPlayerStat(1)
        return string.format("%d", val), val
    end

    local function GetAgility()
        local val = GetPlayerStat(2)
        return string.format("%d", val), val
    end

    local function GetStamina()
        local val = GetPlayerStat(3)
        return string.format("%d", val), val
    end

    local function GetIntellect()
        local val = GetPlayerStat(4)
        return string.format("%d", val), val
    end

    local function GetCritChanceValue()
        local critRating = GetCombatRating(CR_CRIT_MELEE)
        local critPercent = GetCritChance()
        return string.format("%d (%.2f%%)", critRating, critPercent), critPercent
    end

    local function GetHastePercentage()
        local hasteRating = GetCombatRating(CR_HASTE_MELEE)
        local hastePercent = GetHaste()
        return string.format("%d (%.2f%%)", hasteRating, hastePercent), hastePercent
    end

    local function GetMasteryPercentage()
        local masteryRating = GetCombatRating(CR_MASTERY)
        local masteryPercent = GetMasteryEffect()
        return string.format("%d (%.2f%%)", masteryRating, masteryPercent), masteryPercent
    end

    local function GetVersatilityPercentage()
        local versRating = GetCombatRating(CR_VERSATILITY_DAMAGE_DONE)
        local versPercent = GetCombatRatingBonus(CR_VERSATILITY_DAMAGE_DONE) + GetVersatilityBonus(CR_VERSATILITY_DAMAGE_DONE)
        return string.format("%d (%.2f%%)", versRating, versPercent), versPercent
    end

    local function GetSpeedPercentage()
        local moveSpeed = GetUnitSpeed("player")
        local speedPercent = moveSpeed / 7 * 100
        return string.format("%.1f (%.2f%%)", moveSpeed, speedPercent), speedPercent
    end

    local function GetLeechPercentage()
        local leechRating = GetCombatRating(CR_LIFESTEAL)
        local leechPercent = GetLifesteal()
        return string.format("%d (%.2f%%)", leechRating, leechPercent), leechPercent
    end

    local function GetAvoidancePercentage()
        local avoidanceRating = GetCombatRating(CR_AVOIDANCE)
        local avoidancePercent = GetAvoidance()
        return string.format("%d (%.2f%%)", avoidanceRating, avoidancePercent), avoidancePercent
    end

    local function GetArmorValue()
        local baseArmor, effectiveArmor = UnitArmor("player")
        local armorReduction = effectiveArmor / (effectiveArmor + 7390) -- Level 120 constant
        return string.format("%d (%.2f%%)", effectiveArmor, armorReduction*100), effectiveArmor
    end

    -- Create stat displays with tooltips
    local primaryStats = {
        CreateStatDisplay(contentFrame, "Strength:", STAT_COLORS.PRIMARY, GetStrength, 1, 
                         "Your primary attribute affecting Attack Power for Plate classes."),
        CreateStatDisplay(contentFrame, "Agility:", STAT_COLORS.PRIMARY, GetAgility, 2,
                         "Your primary attribute affecting Attack Power for Leather/Mail classes."),
        CreateStatDisplay(contentFrame, "Intellect:", STAT_COLORS.PRIMARY, GetIntellect, 3,
                         "Your primary attribute affecting Spell Power."),
        CreateStatDisplay(contentFrame, "Stamina:", STAT_COLORS.PRIMARY, GetStamina, 4,
                         "Increases your maximum health."),
        CreateStatDisplay(contentFrame, "Armor:", STAT_COLORS.ARMOR, GetArmorValue, 5,
                         "Reduces physical damage taken. Percentage shows damage reduction against equal level enemies.")
    }
    
    -- Store at module level
    self.primaryStats = primaryStats

    -- Add a separator line with improved appearance
    local separator = contentFrame:CreateTexture(nil, "ARTWORK")
    separator:SetHeight(2)  -- Increased height from 1 to 2
    separator:SetColorTexture(0.4, 0.4, 0.4, 0.8)  -- Slightly brighter color
    separator:SetPoint("TOPLEFT", contentFrame, "TOPLEFT", 0, -((#primaryStats) * (statsTextSize + 9) + 5))  -- Added more spacing (5 instead of 3)
    separator:SetPoint("TOPRIGHT", contentFrame, "TOPRIGHT", 0, -((#primaryStats) * (statsTextSize + 9) + 5))
    
    -- Store at module level
    self.separator = separator

    -- Create secondary stat displays
    local secondaryStats = {
        CreateStatDisplay(contentFrame, "Crit:", STAT_COLORS.CRIT, GetCritChanceValue, #primaryStats + 2,
                         "Chance to deal increased damage or healing with attacks and spells."),
        CreateStatDisplay(contentFrame, "Haste:", STAT_COLORS.HASTE, GetHastePercentage, #primaryStats + 3,
                         "Increases attack speed, casting speed, and some resource generation."),
        CreateStatDisplay(contentFrame, "Mastery:", STAT_COLORS.MASTERY, GetMasteryPercentage, #primaryStats + 4,
                         "Improves your specialization-specific abilities."),
        CreateStatDisplay(contentFrame, "Versatility:", STAT_COLORS.VERSATILITY, GetVersatilityPercentage, #primaryStats + 5,
                         "Increases damage and healing done, and reduces damage taken."),
        CreateStatDisplay(contentFrame, "Speed:", STAT_COLORS.SPEED, GetSpeedPercentage, #primaryStats + 6,
                         "Increases your movement speed."),
        CreateStatDisplay(contentFrame, "Leech:", STAT_COLORS.LEECH, GetLeechPercentage, #primaryStats + 7,
                         "Percentage of damage and healing that heals you."),
        CreateStatDisplay(contentFrame, "Avoidance:", STAT_COLORS.AVOIDANCE, GetAvoidancePercentage, #primaryStats + 8,
                         "Reduces area-of-effect damage taken.")
    }
    
    -- Store at module level
    self.secondaryStats = secondaryStats

    -- Combine stat tables for easy updates
    local stats = {}
    for _, stat in ipairs(primaryStats) do table.insert(stats, stat) end
    for _, stat in ipairs(secondaryStats) do table.insert(stats, stat) end
    
    -- Store at module level
    self.stats = stats

    -- Create cooldown timers section with enhanced positioning
    local cdHeader = contentFrame:CreateFontString(nil, "OVERLAY")
    cdHeader:SetFont(addonFont, statsTextSize, "THICKOUTLINE") -- Changed from OUTLINE to THICKOUTLINE
    cdHeader:SetPoint("TOPLEFT", contentFrame, "TOPLEFT", 0, -(#stats * (statsTextSize + 9) + 15))  -- Increased spacing from 10 to 15
    cdHeader:SetText("Cooldowns")
    
    -- Store at module level
    self.cdHeader = cdHeader

    -- Add separator above cooldowns with improved appearance
    local cdSeparator = contentFrame:CreateTexture(nil, "ARTWORK")
    cdSeparator:SetHeight(2)  -- Increased height from 1 to 2
    cdSeparator:SetColorTexture(0.4, 0.4, 0.4, 0.8)  -- Slightly brighter color
    cdSeparator:SetPoint("TOPLEFT", contentFrame, "TOPLEFT", 0, -(#stats * (statsTextSize + 9) + 12))  -- Adjusted spacing (12 instead of 8)
    cdSeparator:SetPoint("TOPRIGHT", contentFrame, "TOPRIGHT", 0, -(#stats * (statsTextSize + 9) + 12))
    
    -- Store at module level
    self.cdSeparator = cdSeparator

    -- Create bloodlust timer display with improved visuals
    local bloodlustCDFrame = CreateFrame("Frame", nil, contentFrame)
    bloodlustCDFrame:SetHeight(24)
    bloodlustCDFrame:SetPoint("TOPLEFT", contentFrame, "TOPLEFT", 0, -(#stats * (statsTextSize + 9) + 32))
    bloodlustCDFrame:SetPoint("TOPRIGHT", contentFrame, "TOPRIGHT", 0, -(#stats * (statsTextSize + 9) + 32))
    
    -- Store at module level
    self.bloodlustCDFrame = bloodlustCDFrame

    -- Bloodlust icon with improved border
    local bloodlustIcon = bloodlustCDFrame:CreateTexture(nil, "ARTWORK")
    bloodlustIcon:SetSize(24, 24)
    bloodlustIcon:SetPoint("LEFT", bloodlustCDFrame, "LEFT", 0, 0)
    bloodlustIcon:SetTexture("Interface\\Icons\\Spell_Nature_Bloodlust")
    bloodlustIcon:SetTexCoord(0.08, 0.92, 0.08, 0.92) -- Crop icon borders

    -- Add icon border
    local bloodlustBorder = bloodlustCDFrame:CreateTexture(nil, "BACKGROUND")
    bloodlustBorder:SetPoint("TOPLEFT", bloodlustIcon, "TOPLEFT", -1, 1)
    bloodlustBorder:SetPoint("BOTTOMRIGHT", bloodlustIcon, "BOTTOMRIGHT", 1, -1)
    bloodlustBorder:SetColorTexture(0.4, 0.4, 0.4, 1)

    -- Make sure bloodlust icon looks better with additional border
    local extraBloodlustBorder = bloodlustCDFrame:CreateTexture(nil, "BACKGROUND")
    extraBloodlustBorder:SetPoint("TOPLEFT", bloodlustIcon, "TOPLEFT", -2, 2)
    extraBloodlustBorder:SetPoint("BOTTOMRIGHT", bloodlustIcon, "BOTTOMRIGHT", 2, -2)
    extraBloodlustBorder:SetColorTexture(0.4, 0.4, 0.4, 1)

    -- Bloodlust timer text
    local bloodlustText = bloodlustCDFrame:CreateFontString(nil, "OVERLAY")
    bloodlustText:SetFont(addonFont, statsTextSize, "THICKOUTLINE") -- Changed from OUTLINE to THICKOUTLINE
    bloodlustText:SetPoint("LEFT", bloodlustIcon, "RIGHT", 4, 0) -- Restored original positioning
    bloodlustText:SetTextColor(1, 1, 1)
    bloodlustText:SetText("Ready")
    
    -- Store at module level
    self.bloodlustText = bloodlustText

    -- Combat res timer display with improved visuals
    local combatResCDFrame = CreateFrame("Frame", nil, contentFrame)
    combatResCDFrame:SetHeight(24)
    combatResCDFrame:SetPoint("TOPLEFT", contentFrame, "TOPLEFT", 0, -(#stats * (statsTextSize + 9) + 60))
    combatResCDFrame:SetPoint("TOPRIGHT", contentFrame, "TOPRIGHT", 0, -(#stats * (statsTextSize + 9) + 60))
    
    -- Store at module level
    self.combatResCDFrame = combatResCDFrame

    -- Combat res icon with improved border
    local combatResIcon = combatResCDFrame:CreateTexture(nil, "ARTWORK")
    combatResIcon:SetSize(24, 24)
    combatResIcon:SetPoint("LEFT", combatResCDFrame, "LEFT", 0, 0)
    combatResIcon:SetTexture("Interface\\Icons\\Spell_Nature_Reincarnation")
    combatResIcon:SetTexCoord(0.08, 0.92, 0.08, 0.92) -- Crop icon borders

    -- Add icon border
    local combatResBorder = combatResCDFrame:CreateTexture(nil, "BACKGROUND")
    combatResBorder:SetPoint("TOPLEFT", combatResIcon, "TOPLEFT", -1, 1)
    combatResBorder:SetPoint("BOTTOMRIGHT", combatResIcon, "BOTTOMRIGHT", 1, -1)
    combatResBorder:SetColorTexture(0.4, 0.4, 0.4, 1)
    
    -- Make sure combat res icon looks better with additional border
    local extraCombatResBorder = combatResCDFrame:CreateTexture(nil, "BACKGROUND")
    extraCombatResBorder:SetPoint("TOPLEFT", combatResIcon, "TOPLEFT", -2, 2)
    extraCombatResBorder:SetPoint("BOTTOMRIGHT", combatResIcon, "BOTTOMRIGHT", 2, -2)
    extraCombatResBorder:SetColorTexture(0.4, 0.4, 0.4, 1)

    -- Combat res timer text
    local combatResText = combatResCDFrame:CreateFontString(nil, "OVERLAY")
    combatResText:SetFont(addonFont, statsTextSize, "THICKOUTLINE") -- Changed from OUTLINE to THICKOUTLINE
    combatResText:SetPoint("LEFT", combatResIcon, "RIGHT", 4, 0) -- Restored original positioning
    combatResText:SetTextColor(1, 1, 1)
    combatResText:SetText("Ready")
    
    -- Store at module level
    self.combatResText = combatResText

    -- Improved Update function for bloodlust and combat res cooldowns
    local function UpdateCooldowns()
        -- Check for Bloodlust/Heroism debuff using new C_UnitAuras API
        local expirationTime = nil
        
        -- Helper function to safely check for auras
        local function CheckForDebuff(spellName)
            -- Use C_UnitAuras.GetPlayerAuraBySpellID for modern clients
            local spellID = nil
            
            -- Map of known spell names to IDs
            local spellNameToID = {
                ["Temporal Displacement"] = 80354,
                ["Exhaustion"] = 57723,
                ["Insanity"] = 95809,
                ["Fatigued"] = 160455,
                ["Sated"] = 57724      -- Additional variant
            }
            
            -- Get the spell ID for the given spell name
            spellID = spellNameToID[spellName]
            
            -- If we have a spell ID, try to get aura data
            if spellID and C_UnitAuras then
                local auraData = C_UnitAuras.GetPlayerAuraBySpellID(spellID)
                if auraData and auraData.expirationTime then
                    return auraData.expirationTime
                end
            end
            
            -- Fallback for older clients that still use UnitDebuff
            if UnitDebuff then
                for i=1, 40 do
                    local name, _, _, _, _, expTime = UnitDebuff("player", i)
                    if name == spellName then
                        return expTime
                    end
                end
            end
            
            return nil
        end
        
        -- Check for all possible Bloodlust debuff variants
        expirationTime = CheckForDebuff("Temporal Displacement") -- Alliance
        if not expirationTime then expirationTime = CheckForDebuff("Exhaustion") end -- Horde
        if not expirationTime then expirationTime = CheckForDebuff("Insanity") end -- Mage
        if not expirationTime then expirationTime = CheckForDebuff("Fatigued") end -- Hunter pet
        if not expirationTime then expirationTime = CheckForDebuff("Sated") end -- Additional variant
        
        if expirationTime then
            local remaining = expirationTime - GetTime()
            if remaining > 0 then
                bloodlustText:SetText(string.format("CD: %d:%02d", floor(remaining/60), floor(remaining % 60)))
                bloodlustIcon:SetDesaturated(true)
                bloodlustBorder:SetColorTexture(0.4, 0, 0, 1) -- Red border for active cooldown
            else
                bloodlustText:SetText("Ready")
                bloodlustIcon:SetDesaturated(false)
                bloodlustBorder:SetColorTexture(0.4, 0.4, 0.4, 1) -- Default border
            end
        else
            bloodlustText:SetText("Ready")
            bloodlustIcon:SetDesaturated(false)
            bloodlustBorder:SetColorTexture(0.4, 0.4, 0.4, 1) -- Default border
        end
        
        -- Check for Combat Resurrection cooldown with improved accuracy
        local battleResCharges, _, battleResStart, battleResDuration
        
        -- Use IsInRaid to check for raid status first
        local inRaid = IsInRaid()
        local inGroup = IsInGroup()
        
        -- First try raid-specific battle res tracking if in a raid
        local chargesAvailable, maxCharges, start, duration
        if inRaid and C_DeathInfo and C_DeathInfo.GetCombatResurrectionCharges then
            chargesAvailable, maxCharges, start, duration = C_DeathInfo.GetCombatResurrectionCharges()
            if chargesAvailable and maxCharges and chargesAvailable < maxCharges then
                battleResCharges = chargesAvailable
                battleResStart = start
                battleResDuration = duration
            end
        end
        
        -- Fallback to class-specific resurrection spell check
        if not battleResCharges and (inRaid or inGroup) then
            local _, playerClass = UnitClass("player")
            
            -- Class-specific resurrection spell IDs
            local resSpellIDs = {
                DRUID = 20484,      -- Rebirth
                DEATHKNIGHT = 61999, -- Raise Ally
                WARLOCK = 20707,    -- Soulstone
                MONK = 115178,      -- Resuscitate with Reawaken talent
                PALADIN = 391054,   -- Intercession
                SHAMAN = 20608      -- Reincarnation
            }
            
            local spellID = resSpellIDs[playerClass]
            if spellID and C_Spell and C_Spell.GetSpellCharges then
                battleResCharges, _, battleResStart, battleResDuration = C_Spell.GetSpellCharges(spellID)
            end
        end
        
        -- Update the UI based on cooldown status
        if battleResCharges and type(battleResCharges) == "number" and battleResCharges < 1 and battleResStart and battleResDuration then
            local remaining = battleResStart + battleResDuration - GetTime()
            if remaining > 0 then
                combatResText:SetText(string.format("CD: %d:%02d", floor(remaining/60), floor(remaining % 60)))
                combatResIcon:SetDesaturated(true)
                combatResBorder:SetColorTexture(0.4, 0, 0, 1) -- Red border for active cooldown
            else
                combatResText:SetText("Ready")
                combatResIcon:SetDesaturated(false)
                combatResBorder:SetColorTexture(0.4, 0.4, 0.4, 1) -- Default border
            end
        else
            -- Show available charges if we have that information
            if chargesAvailable and maxCharges then
                combatResText:SetText(string.format("%d/%d", chargesAvailable, maxCharges))
            else
                combatResText:SetText("Ready")
            end
            combatResIcon:SetDesaturated(false)
            combatResBorder:SetColorTexture(0.4, 0.4, 0.4, 1) -- Default border
        end
    end
    
    -- Store at module level
    self.UpdateCooldowns = UpdateCooldowns

    -- Optimized update function for the player stats frame
    local statUpdateInterval = 0
    local inCombatUpdateRate = 0.3     -- Update more frequently in combat
    local outOfCombatUpdateRate = 1.0   -- Update less frequently out of combat

    -- Register for combat events to adjust update frequency
    local combatEventFrame = CreateFrame("Frame")
    combatEventFrame:RegisterEvent("PLAYER_REGEN_DISABLED") -- Entering combat
    combatEventFrame:RegisterEvent("PLAYER_REGEN_ENABLED")  -- Leaving combat

    -- Variable to track current update rate
    local currentUpdateRate = outOfCombatUpdateRate

    combatEventFrame:SetScript("OnEvent", function(self, event)
        if event == "PLAYER_REGEN_DISABLED" then
            -- Entering combat - update more frequently
            currentUpdateRate = inCombatUpdateRate
        elseif event == "PLAYER_REGEN_ENABLED" then
            -- Leaving combat - update less frequently
            currentUpdateRate = outOfCombatUpdateRate
        end
    end)

    -- Register for stat change events to trigger immediate updates
    local statEventFrame = CreateFrame("Frame")
    statEventFrame:RegisterEvent("UNIT_STATS")
    statEventFrame:RegisterEvent("UNIT_ATTACK_POWER")
    statEventFrame:RegisterEvent("UNIT_SPELL_HASTE")
    statEventFrame:RegisterEvent("UNIT_DAMAGE")
    statEventFrame:RegisterEvent("COMBAT_RATING_UPDATE")
    statEventFrame:RegisterEvent("MASTERY_UPDATE")
    statEventFrame:RegisterEvent("SPEED_UPDATE")
    statEventFrame:RegisterEvent("LIFESTEAL_UPDATE")
    statEventFrame:RegisterEvent("AVOIDANCE_UPDATE")
    statEventFrame:RegisterEvent("PLAYER_EQUIPMENT_CHANGED")

    -- Force immediate update on relevant events
    statEventFrame:SetScript("OnEvent", function(self, event, unit)
        if unit and unit ~= "player" then return end
        
        -- Update all stats immediately
        for _, stat in ipairs(stats) do
            stat:Update()
        end
    end)

    -- Optimized OnUpdate handler
    PlayerStatsFrame:SetScript("OnUpdate", function(self, elapsed)
        statUpdateInterval = statUpdateInterval + elapsed
        if statUpdateInterval >= currentUpdateRate then
            statUpdateInterval = 0
            
            -- Update all stats
            for _, stat in ipairs(stats) do
                stat:Update()
            end
            
            -- Update cooldowns
            UpdateCooldowns()
        end
    end)
    
    -- Show or hide based on settings
    if db.display.playerStats then
        PlayerStatsFrame:Show()
    else
        PlayerStatsFrame:Hide()
    end

    -- Apply initial configuration
    Module:RefreshPlayerStats()

    -- Apply the size update after initial stats load
    C_Timer.After(0.5, function() 
        if Module.UpdateFrameSize then
            Module.UpdateFrameSize()
        end
    end)
end

-- Add RefreshPlayerStats function to handle configuration changes
function Module:RefreshPlayerStats()
    -- Get configuration
    local config = Phoenix_UI.db.profile.general.playerStats or {
        showPrimaryStats = true,
        showSecondaryStats = true,
        showCooldowns = true,
        compactMode = false,
        updateFrequency = {
            inCombat = 0.3,
            outOfCombat = 1.0
        }
    }
    
    -- Update visibility of stat sections based on configuration
    if _G.Phoenix_PlayerStatsFrame then
        local frame = _G.Phoenix_PlayerStatsFrame
        
        -- Exit if stats aren't initialized yet
        if not self.primaryStats or not self.secondaryStats or not self.stats then
            return
        end
        
        -- Handle primary stats visibility
        for i, stat in ipairs(self.primaryStats) do
            if config.showPrimaryStats then
                stat:Show()
            else
                stat:Hide()
            end
        end
        
        -- Handle separator visibility
        if config.showPrimaryStats and config.showSecondaryStats then
            self.separator:Show()
        else
            self.separator:Hide()
        end
        
        -- Handle secondary stats visibility
        for i, stat in ipairs(self.secondaryStats) do
            if config.showSecondaryStats then
                stat:Show()
                
                -- Adjust position if primary stats are hidden
                if not config.showPrimaryStats then
                    stat:SetPoint("TOPLEFT", self.contentFrame, "TOPLEFT", 0, -((i-1) * (self.statsTextSize + 9)))
                else
                    stat:SetPoint("TOPLEFT", self.contentFrame, "TOPLEFT", 0, -((#self.primaryStats + 2 + (i-1)) * (self.statsTextSize + 9)))
                end
            else
                stat:Hide()
            end
        end
        
        -- Handle cooldowns visibility
        if config.showCooldowns then
            self.cdHeader:Show()
            self.cdSeparator:Show()
            self.bloodlustCDFrame:Show()
            self.combatResCDFrame:Show()
            
            -- Adjust position based on which stat sections are visible
            local yOffset = 10
            if config.showSecondaryStats then
                yOffset = yOffset + (#self.secondaryStats * (self.statsTextSize + 9))
            end
            if config.showPrimaryStats then
                yOffset = yOffset + (#self.primaryStats * (self.statsTextSize + 9))
            end
            
            self.cdHeader:SetPoint("TOPLEFT", self.contentFrame, "TOPLEFT", 0, -(yOffset))
            self.cdSeparator:SetPoint("TOPLEFT", self.contentFrame, "TOPLEFT", 0, -(yOffset - 2))
            self.cdSeparator:SetPoint("TOPRIGHT", self.contentFrame, "TOPRIGHT", 0, -(yOffset - 2))
            self.bloodlustCDFrame:SetPoint("TOPLEFT", self.contentFrame, "TOPLEFT", 0, -(yOffset + 22))
            self.combatResCDFrame:SetPoint("TOPLEFT", self.contentFrame, "TOPLEFT", 0, -(yOffset + 50))
        else
            self.cdHeader:Hide()
            self.cdSeparator:Hide()
            self.bloodlustCDFrame:Hide()
            self.combatResCDFrame:Hide()
        end
        
        -- Apply compact mode if enabled
        if config.compactMode then
            self.statsTextSize = 10
            
            -- Update font size for all text elements
            for _, stat in ipairs(self.stats) do
                stat:SetHeight(self.statsTextSize + 2)
                
                for _, region in pairs({stat:GetRegions()}) do
                    if region:IsObjectType("FontString") then
                        region:SetFont(self.addonFont, self.statsTextSize, "OUTLINE")
                    end
                end
            end
            
            -- Update cooldown text
            self.bloodlustText:SetFont(self.addonFont, self.statsTextSize, "OUTLINE")
            self.combatResText:SetFont(self.addonFont, self.statsTextSize, "OUTLINE")
            self.cdHeader:SetFont(self.addonFont, self.statsTextSize, "OUTLINE")
            
            -- Reduce spacing between elements
            for i, stat in ipairs(self.stats) do
                local parentIndex = i
                if config.showPrimaryStats and i > #self.primaryStats and config.showSecondaryStats then
                    parentIndex = #self.primaryStats + 2 + (i - #self.primaryStats - 1)
                end
                
                stat:SetPoint("TOPLEFT", self.contentFrame, "TOPLEFT", 0, -((parentIndex-1) * (self.statsTextSize + 4)))
            end
        else
            self.statsTextSize = 11
            
            -- Restore normal font size
            for _, stat in ipairs(self.stats) do
                stat:SetHeight(self.statsTextSize + 4)
                
                for _, region in pairs({stat:GetRegions()}) do
                    if region:IsObjectType("FontString") then
                        region:SetFont(self.addonFont, self.statsTextSize, "OUTLINE")
                    end
                end
            end
            
            -- Restore cooldown text
            self.bloodlustText:SetFont(self.addonFont, self.statsTextSize, "OUTLINE")
            self.combatResText:SetFont(self.addonFont, self.statsTextSize, "OUTLINE")
            self.cdHeader:SetFont(self.addonFont, self.statsTextSize, "OUTLINE")
            
            -- Restore normal spacing
            for i, stat in ipairs(self.stats) do
                local parentIndex = i
                if config.showPrimaryStats and i > #self.primaryStats and config.showSecondaryStats then
                    parentIndex = #self.primaryStats + 2 + (i - #self.primaryStats - 1)
                end
                
                stat:SetPoint("TOPLEFT", self.contentFrame, "TOPLEFT", 0, -((parentIndex-1) * (self.statsTextSize + 9)))
            end
        end
        
        -- Apply update frequency settings
        inCombatUpdateRate = config.updateFrequency.inCombat or 0.3
        outOfCombatUpdateRate = config.updateFrequency.outOfCombat or 1.0
        currentUpdateRate = UnitAffectingCombat("player") and inCombatUpdateRate or outOfCombatUpdateRate
        
        -- Handle change indicators setting
        local showChangeIndicators = config.changeIndicators ~= false
        for _, stat in ipairs(self.stats) do
            for _, region in pairs({stat:GetRegions()}) do
                if region:IsObjectType("FontString") and region ~= stat.labelText and region ~= stat.valueText then
                    if showChangeIndicators then
                        region:Show()
                    else
                        region:Hide()
                    end
                end
            end
        end
        
        -- Force immediate update
        for _, stat in ipairs(self.stats) do
            stat:Update()
        end
        self.UpdateCooldowns()
        
        -- Update frame size based on content
        if self.UpdateFrameSize then
            self.UpdateFrameSize()
        end
        
        -- Save changes to ensure consistency across all modules
        -- This ensures both AceDB and global saved variables are updated
        if Phoenix_UI.SaveDB then
            -- Mark the settings as updated
            if Phoenix_UI.db and Phoenix_UI.db.profile and Phoenix_UI.db.profile.general then
                Phoenix_UI.db.profile.general.__updated = GetTime()
                Phoenix_UI.db.profile.general.__saved_from = "PlayerStats_RefreshConfig"
                
                -- Mark our edit data as updated too
                if Phoenix_UI.db.profile.edit then
                    Phoenix_UI.db.profile.edit.__updated = GetTime()
                    Phoenix_UI.db.profile.edit.__saved_from = "PlayerStats_RefreshConfig"
                end
            end
            
            -- Call the standard save function
            Phoenix_UI:SaveDB()
            
            -- Ensure we also update the direct global variable for extra persistence
            if _G["Phoenix_UIDB"] then
                local currentProfile = Phoenix_UI.db.keys.profile or "Default"
                
                -- Ensure profile exists
                if not _G["Phoenix_UIDB"].profiles then _G["Phoenix_UIDB"].profiles = {} end
                if not _G["Phoenix_UIDB"].profiles[currentProfile] then _G["Phoenix_UIDB"].profiles[currentProfile] = {} end
                
                -- Update general settings
                if not _G["Phoenix_UIDB"].profiles[currentProfile].general then 
                    _G["Phoenix_UIDB"].profiles[currentProfile].general = {} 
                end
                if Phoenix_UI.db.profile.general.playerStats then
                    _G["Phoenix_UIDB"].profiles[currentProfile].general.playerStats = 
                        CopyTable(Phoenix_UI.db.profile.general.playerStats)
                end
                
                -- Update edit settings
                if not _G["Phoenix_UIDB"].profiles[currentProfile].edit then 
                    _G["Phoenix_UIDB"].profiles[currentProfile].edit = {} 
                end
                if Phoenix_UI.db.profile.edit and Phoenix_UI.db.profile.edit.playerStatsFrame then
                    _G["Phoenix_UIDB"].profiles[currentProfile].edit.playerStatsFrame = 
                        CopyTable(Phoenix_UI.db.profile.edit.playerStatsFrame)
                end
                
                -- Mark timestamp
                _G["Phoenix_UIDB"].__lastSaved = GetTime()
                _G["Phoenix_UIDB"].__currentProfile = currentProfile
                
                -- Force immediate write to disk
                pcall(function()
                    if FlushSavedVariables then
                        FlushSavedVariables()
                    elseif FlushSettingsDB then
                        FlushSettingsDB()
                    end
                end)
            end
        end
    end
end

-- Dynamically calculate frame size based on content
local function UpdateFrameSize()
    local totalHeight = 30  -- Increased initial top padding from 22 to 30
    
    -- Calculate height needed for stats
    local statsHeight = #Module.primaryStats * (Module.statsTextSize + 9)
    statsHeight = statsHeight + 15  -- Increased spacing after primary stats
    
    -- Add secondary stats height if shown
    if Phoenix_UI.db.profile.general.playerStats and Phoenix_UI.db.profile.general.playerStats.showSecondaryStats ~= false then
        statsHeight = statsHeight + #Module.secondaryStats * (Module.statsTextSize + 9)
        statsHeight = statsHeight + 20  -- Increased extra spacing between sections
    end
    
    -- Add cooldowns height if shown
    if Phoenix_UI.db.profile.general.playerStats and Phoenix_UI.db.profile.general.playerStats.showCooldowns ~= false then
        statsHeight = statsHeight + 80  -- Increased space for header and cooldown indicators from 65 to 80
    end
    
    -- Add bottom padding
    statsHeight = statsHeight + 30  -- Increased bottom padding from 15 to 30
    
    -- Set minimum size (increased for better visibility)
    statsHeight = math.max(statsHeight, 250)  -- Increased from 200 to 250
    
    -- Update frame size
    if _G.Phoenix_PlayerStatsFrame then
        _G.Phoenix_PlayerStatsFrame:SetHeight(statsHeight)
        
        -- Also adjust width based on content
        local baseWidth = 180  -- Increased from 150 to 180 for better readability
        local maxTextWidth = 0
        
        -- Find the longest text
        for _, stat in ipairs(Module.stats) do
            if stat.labelText and stat.valueText then
                local labelWidth = stat.labelText:GetStringWidth()
                local valueWidth = stat.valueText:GetStringWidth()
                maxTextWidth = math.max(maxTextWidth, labelWidth + valueWidth + 30)  -- Increased padding from 20 to 30
            end
        end
        
        -- Set width based on text, with improved minimum width
        _G.Phoenix_PlayerStatsFrame:SetWidth(math.max(baseWidth, maxTextWidth + 35))  -- Increased padding from 25 to 35
    end
end

-- Add frame to the module for later reference
Module.UpdateFrameSize = UpdateFrameSize

-- Register events to update size when stats change
local sizeUpdateFrame = CreateFrame("Frame")
sizeUpdateFrame:RegisterEvent("UNIT_STATS")
sizeUpdateFrame:RegisterEvent("PLAYER_EQUIPMENT_CHANGED")
sizeUpdateFrame:SetScript("OnEvent", function() 
    C_Timer.After(0.1, function()
        if Module.UpdateFrameSize then
            Module.UpdateFrameSize()
        end
    end)  -- Slight delay to ensure stats are updated first
end)

-- Apply the size update after initial stats load
C_Timer.After(0.5, function()
    if Module.UpdateFrameSize then
        Module.UpdateFrameSize()
    end
end)

-- The code for adding borders to cooldown icons has been moved into the OnEnable function where the frames are created and stored in the Module



