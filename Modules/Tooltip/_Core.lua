local Module = Phoenix_UI:NewModule("Tooltip.Core");

function Module:OnEnable()
    local db = Phoenix_UI.db.profile.tooltip

    local TooltipFrame = CreateFrame('Frame', "TooltipFrame", UIParent)
    TooltipFrame:SetPoint("BOTTOMRIGHT", UIParent, "BOTTOMRIGHT", -50, 120)
    TooltipFrame:SetSize(150, 25)

    -- tooltip anchor
    if (db.mouseanchor) then
        hooksecurefunc("GameTooltip_SetDefaultAnchor", function(tooltip, parent)
            tooltip:SetOwner(parent, "ANCHOR_CURSOR")
        end)
    else
        hooksecurefunc("GameTooltip_SetDefaultAnchor", function(tooltip, parent)
            tooltip:SetOwner(parent, "ANCHOR_NONE")
        end)
    end

    if (db.style == "Custom") then
        FONT = STANDARD_TEXT_FONT
        local classColorHex, factionColorHex = {}, {}

        local cfg = {
            textColor = { 0.4, 0.4, 0.4 },
            bossColor = { 1, 0, 0 },
            eliteColor = { 1, 0, 0.5 },
            rareeliteColor = { 1, 0.5, 0 },
            rareColor = { 1, 0.5, 0 },
            levelColor = { 0.8, 0.8, 0.5 },
            deadColor = { 0.5, 0.5, 0.5 },
            targetColor = { 1, 0.5, 0.5 },
            guildColor = { 0.8, 0.0, 0.6 },
            afkColor = { 0, 1, 1 },
            scale = 0.95,
            fontFamily = STANDARD_TEXT_FONT,
        }

        if (db) then
            GameTooltipStatusBar:SetStatusBarTexture(
                "Interface\\Phoenix_UI\\Media\\Textures\\Tooltip\\UI-TargetingFrame-BarFill_test")
        end

        local function GetHexColor(color)
            if color.r then
                return ("%.2x%.2x%.2x"):format(color.r * 255, color.g * 255, color.b * 255)
            else
                local r, g, b, a = unpack(color)
                return ("%.2x%.2x%.2x"):format(r * 255, g * 255, b * 255)
            end
        end

        local function GetTarget(unit)
            if UnitIsUnit(unit, "player") then
                return ("|cffff0000%s|r"):format("<YOU>")
            elseif UnitIsPlayer(unit) then
                local _, class = UnitClass(unit)
                return ("|cff%s%s|r"):format(classColorHex[class], UnitName(unit))
            elseif UnitReaction(unit, "player") then
                return ("|cff%s%s|r"):format(factionColorHex[UnitReaction(unit, "player")], UnitName(unit))
            else
                return ("|cffffffff%s|r"):format(UnitName(unit))
            end
        end

        local function OnTooltipSetUnit(self, data)
            if self ~= _G.GameTooltip then
                return
            end

            local unitName, unit
            
            -- For WoW 10.0+, use the data parameter with TooltipDataProcessor
            if data and data.guid then
                unit = data.guid and C_PlayerInfo and C_PlayerInfo.GetUnitByGUID and C_PlayerInfo.GetUnitByGUID(data.guid)
                if not unit and data.token then
                    unit = data.token
                end
                unitName = data.name
            else
                -- Fallback to older method
                unitName, unit = self:GetUnit()
            end
            
            if not unit then return end
            
            -- Add role and target of target information via DisplayUnit
            if Phoenix_UI.db.profile.tooltip.roleIcons or Phoenix_UI.db.profile.tooltip.targetOfTarget or Phoenix_UI.db.profile.tooltip.showHealth then
                Phoenix_UI:GetModule("Tooltip.Core"):DisplayUnit(self, unit)
            end
            
            --color tooltip textleft
            for i = 2, GameTooltip:NumLines() do
                local line = _G["GameTooltipTextLeft" .. i]
                if line then
                    if not line == 4 then
                        line:SetTextColor(unpack(cfg.textColor))
                    end
                end
            end
            
            --position raidicon
            if unit and GetRaidTargetIndex(unit) then
                local raidIconIndex = GetRaidTargetIndex(unit)
                if GetRaidTargetIndex(unit) == 16 then
                    GameTooltipTextLeft1:SetText(("%s"):format(unitName))
                else
                    GameTooltipTextLeft1:SetText(("%s %s"):format(ICON_LIST[raidIconIndex] .. "14|t", unitName))
                end
            end
            if not UnitIsPlayer(unit) then
                local reaction = UnitReaction(unit, "player")
                if reaction then
                    local color = FACTION_BAR_COLORS[reaction]
                    if color then
                        cfg.barColor = color
                        GameTooltipStatusBar:SetStatusBarColor(color.r, color.g, color.b)
                        GameTooltipTextLeft1:SetTextColor(color.r, color.g, color.b)
                    end
                end
                --color textleft2 by classificationcolor
                local unitClassification = UnitClassification(unit)
                local levelLine
                if string.find(GameTooltipTextLeft2:GetText() or "empty", "%a%s%d") then
                    levelLine = GameTooltipTextLeft2
                elseif GameTooltipTextLeft3 ~= nil and string.find(GameTooltipTextLeft3:GetText() or "empty", "%a%s%d") then
                    GameTooltipTextLeft2:SetTextColor(unpack(cfg.guildColor))
                    levelLine = GameTooltipTextLeft3
                end
                if levelLine then
                    local l = UnitLevel(unit)
                    local color = GetCreatureDifficultyColor((l > 0) and l or 999)
                    levelLine:SetTextColor(color.r, color.g, color.b)
                end
                if unitClassification == "worldboss" or UnitLevel(unit) == -1 then
                    self:AppendText(" |cffff0000[B]|r")
                    GameTooltipTextLeft2:SetTextColor(unpack(cfg.bossColor))
                elseif unitClassification == "rare" then
                    self:AppendText(" |cffff9900[R]|r")
                elseif unitClassification == "rareelite" then
                    self:AppendText(" |cffff0000[R+]|r")
                elseif unitClassification == "elite" then
                    self:AppendText(" |cffff6666[E]|r")
                end
            else
                --unit is any player
                local _, unitClass = UnitClass(unit)
                --color textleft1 and statusbar by class color
                local color = RAID_CLASS_COLORS[unitClass]
                cfg.barColor = color
                GameTooltipStatusBar:SetStatusBarColor(color.r, color.g, color.b)
                _G["GameTooltipTextLeft1"]:SetTextColor(color.r, color.g, color.b)
                --color textleft2 by guildcolor
                local guildName, guildRank = GetGuildInfo(unit)
                if guildName then
                    _G["GameTooltipTextLeft2"]:SetText("<" .. guildName .. "> [" .. guildRank .. "]")
                    _G["GameTooltipTextLeft2"]:SetTextColor(unpack(cfg.guildColor))
                end
                local levelLine = guildName and _G["GameTooltipTextLeft3"] or _G["GameTooltipTextLeft2"]
                local l = UnitLevel(unit)
                local color = GetCreatureDifficultyColor((l > 0) and l or 999)
                levelLine:SetTextColor(color.r, color.g, color.b)
                --afk?
                if UnitIsAFK(unit) then
                    self:AppendText((" |cff%s<AFK>|r"):format(cfg.afkColorHex))
                end
            end
            --dead?
            if UnitIsDeadOrGhost(unit) then
                _G["GameTooltipTextLeft1"]:SetTextColor(unpack(cfg.deadColor))
            end
            --target line
            if (UnitExists(unit .. "target")) then
                GameTooltip:AddDoubleLine(("|cff%s%s|r"):format(cfg.targetColorHex, "Target"),
                    GetTarget(unit .. "target") or "Unknown")
            end
        end

        local function SetStatusBarColor(self, r, g, b)
            if not cfg.barColor then return end
            if r == cfg.barColor.r and g == cfg.barColor.g and b == cfg.barColor.b then return end
            self:SetStatusBarColor(cfg.barColor.r, cfg.barColor.g, cfg.barColor.b)
        end

        --hex class colors
        for class, color in next, RAID_CLASS_COLORS do
            classColorHex[class] = GetHexColor(color)
        end
        --hex reaction colors
        --for idx, color in next, FACTION_BAR_COLORS do
        for i = 1, #FACTION_BAR_COLORS do
            factionColorHex[i] = GetHexColor(FACTION_BAR_COLORS[i])
        end

        cfg.targetColorHex = GetHexColor(cfg.targetColor)
        cfg.afkColorHex = GetHexColor(cfg.afkColor)

        --GameTooltipHeaderText:SetFont(cfg.fontFamily, 14)
        --GameTooltipHeaderText:SetShadowOffset(1,-2)
        --GameTooltipHeaderText:SetShadowColor(0,0,0,0.75)
        --GameTooltipText:SetFont(cfg.fontFamily, 12, "NONE")
        --GameTooltipText:SetShadowOffset(1,-2)
        --GameTooltipText:SetShadowColor(0,0,0,0.75)
        --Tooltip_Small:SetFont(cfg.fontFamily, 11, "NONE")
        --Tooltip_Small:SetShadowOffset(1,-2)
        --Tooltip_Small:SetShadowColor(0,0,0,0.75)

        if (db.lifeontop) then
            GameTooltipStatusBar:ClearAllPoints()
            GameTooltipStatusBar:SetPoint("LEFT", 4.5, 0)
            GameTooltipStatusBar:SetPoint("RIGHT", -4.5, 0)
            GameTooltipStatusBar:SetPoint("TOP", 0, -3)
            GameTooltipStatusBar:SetHeight(4)
        else
            GameTooltipStatusBar:ClearAllPoints()
            GameTooltipStatusBar:SetPoint("LEFT", 4.5, 0)
            GameTooltipStatusBar:SetPoint("RIGHT", -4.5, 0)
            GameTooltipStatusBar:SetPoint("BOTTOM", 0, 3)
            GameTooltipStatusBar:SetHeight(4)
        end

        --gametooltip statusbar bg
        GameTooltipStatusBar.bg = GameTooltipStatusBar:CreateTexture(nil, "BACKGROUND", nil, -8)
        GameTooltipStatusBar.bg:SetAllPoints()
        GameTooltipStatusBar.bg:SetColorTexture(1, 1, 1)
        GameTooltipStatusBar.bg:SetVertexColor(0, 0, 0, 0.5)

        --GameTooltipStatusBar:SetStatusBarColor()
        hooksecurefunc(GameTooltipStatusBar, "SetStatusBarColor", SetStatusBarColor)
        --OnTooltipSetUnit
        TooltipDataProcessor.AddTooltipPostCall(Enum.TooltipDataType.Unit, OnTooltipSetUnit)
        --GameTooltip:HookScript("OnTooltipSetUnit", OnTooltipSetUnit)

        --loop over menues
        local menues = {
            DropDownList1MenuBackdrop,
            DropDownList2MenuBackdrop,
        }
        for i, menu in next, menues do
            menu:SetScale(cfg.scale)
        end

        --TooltipAddSpellID
        local function TooltipAddSpellID(self, spellid)
            if not spellid then return end
            if type(spellid) == "table" and #spellid == 1 then spellid = spellid[1] end
            local frame, text
            for i = 1, 15 do
                frame = _G[self:GetName() .. "TextLeft" .. i]
                if frame then text = frame:GetText() end
                if text and string.find(text, "|cff0099ffID|r") then return end
            end
            self:AddDoubleLine("|cff0099ffID|r", spellid)
            self:Show()
        end

        local function TooltipAddBuffSource(self, caster)
            local name = caster and UnitName(caster)
            if name then
                self:AddDoubleLine("|cff0099ffCast by|r", name, nil, nil, nil, 1, 1, 1)
                self:Show()
            end
        end

        --hooksecurefunc GameTooltip SetUnitBuff
        hooksecurefunc(GameTooltip, "SetUnitBuff", function(self, unitToken, index, filter)
            -- Get the buff details
            local auraData = C_UnitAuras.GetBuffDataByIndex(unitToken, index, filter)
            if not auraData then return end

            local spellId = select(10, AuraUtil.UnpackAuraData(auraData))
            TooltipAddSpellID(self, spellId)
            
            -- Add enhanced aura information if enabled in settings
            if db.detailedAuras then
                -- Add aura source/caster
                if db.auraSource then
                    local sourceUnit = auraData.sourceUnit
                    if sourceUnit then
                        local name = UnitName(sourceUnit) or "Unknown"
                        local _, class = UnitClass(sourceUnit)
                        local color = class and RAID_CLASS_COLORS[class] or {r=1, g=1, b=1}
                        self:AddDoubleLine("|cff0099ffCast by|r", name, nil, nil, nil, color.r, color.g, color.b)
                    end
                end
                
                -- Add duration information
                if db.auraDuration then
                    local duration = auraData.duration or 0
                    local expirationTime = auraData.expirationTime
                    
                    if duration > 0 and expirationTime then
                        local timeLeft = expirationTime - GetTime()
                        local formattedTime = ""
                        
                        if timeLeft > 60 then
                            formattedTime = string.format("%.0fm %.0fs", floor(timeLeft/60), timeLeft % 60)
                        else
                            formattedTime = string.format("%.1fs", timeLeft)
                        end
                        
                        self:AddDoubleLine("|cff0099ffDuration|r", formattedTime, nil, nil, nil, 1, 1, 0)
                    elseif duration == 0 then
                        self:AddDoubleLine("|cff0099ffDuration|r", "Permanent", nil, nil, nil, 0, 1, 0)
                    end
                end
                
                -- Add aura type information
                if db.auraType then
                    local auraType = auraData.dispelName
                    if auraType then
                        local color = DebuffTypeColor[auraType] or {r=0.8, g=0.8, b=0.8}
                        self:AddDoubleLine("|cff0099ffType|r", auraType, nil, nil, nil, color.r, color.g, color.b)
                    end
                end
            end
            
            self:Show()
        end)
        
        -- SetUnitDebuff hook for enhanced debuff information
        hooksecurefunc(GameTooltip, "SetUnitDebuff", function(self, unitToken, index, filter)
            -- Get the debuff details
            local auraData = C_UnitAuras.GetDebuffDataByIndex(unitToken, index, filter)
            if not auraData then return end

            local spellId = select(10, AuraUtil.UnpackAuraData(auraData))
            TooltipAddSpellID(self, spellId)
            
            -- Add enhanced aura information if enabled in settings
            if db.detailedAuras then
                -- Add aura source/caster
                if db.auraSource then
                    local sourceUnit = auraData.sourceUnit
                    if sourceUnit then
                        local name = UnitName(sourceUnit) or "Unknown"
                        local _, class = UnitClass(sourceUnit)
                        local color = class and RAID_CLASS_COLORS[class] or {r=1, g=1, b=1}
                        self:AddDoubleLine("|cff0099ffCast by|r", name, nil, nil, nil, color.r, color.g, color.b)
                    end
                end
                
                -- Add duration information
                if db.auraDuration then
                    local duration = auraData.duration or 0
                    local expirationTime = auraData.expirationTime
                    
                    if duration > 0 and expirationTime then
                        local timeLeft = expirationTime - GetTime()
                        local formattedTime = ""
                        
                        if timeLeft > 60 then
                            formattedTime = string.format("%.0fm %.0fs", floor(timeLeft/60), timeLeft % 60)
                        else
                            formattedTime = string.format("%.1fs", timeLeft)
                        end
                        
                        self:AddDoubleLine("|cff0099ffDuration|r", formattedTime, nil, nil, nil, 1, 1, 0)
                    elseif duration == 0 then
                        self:AddDoubleLine("|cff0099ffDuration|r", "Permanent", nil, nil, nil, 0, 1, 0)
                    end
                end
                
                -- Add aura type information
                if db.auraType then
                    local auraType = auraData.dispelName
                    if auraType then
                        local color = DebuffTypeColor[auraType] or {r=0.8, g=0.8, b=0.8}
                        self:AddDoubleLine("|cff0099ffType|r", auraType, nil, nil, nil, color.r, color.g, color.b)
                    end
                end
            end
            
            self:Show()
        end)

        --hooksecurefunc GameTooltip SetUnitAura
        hooksecurefunc(GameTooltip, "SetUnitAura", function(self, unit, index, filter)
            if not db.detailedAuras then return end
            
            -- Validate unit parameter before proceeding 
            if not unit or not UnitExists(unit) then return end
            
            -- Use C_UnitAuras API with proper error checking
            if not C_UnitAuras or not C_UnitAuras.GetAuraDataByIndex then return end
            
            -- Safely get aura data with error handling
            local auraData
            local success, err = pcall(function()
                auraData = C_UnitAuras.GetAuraDataByIndex(unit, index, filter)
            end)
            
            if not success or not auraData then return end
            
            local name = auraData.name
            local spellId = auraData.spellId
            local duration = auraData.duration
            local expirationTime = auraData.expirationTime
            local source = auraData.sourceUnit
            local debuffType = auraData.dispelName
            
            if not name then return end
            
            -- Add spell ID if detailed auras enabled
            self:AddLine(" ")
            self:AddLine("Spell ID: " .. (spellId or "Unknown"), 0.7, 0.7, 1.0)
            
            -- Add aura source if available and enabled
            if db.auraSource and source and UnitExists(source) then
                local _, sourceClass = UnitClass(source)
                local color = sourceClass and RAID_CLASS_COLORS[sourceClass] or NORMAL_FONT_COLOR
                self:AddLine("Source: " .. UnitName(source), color.r, color.g, color.b)
            end
            
            -- Add remaining time if enabled
            if db.auraDuration and duration and duration > 0 then
                local timeLeft = expirationTime - GetTime()
                local formattedTime
                
                if timeLeft >= 60 then
                    formattedTime = math.floor(timeLeft / 60) .. "m " .. math.floor(timeLeft % 60) .. "s"
                else
                    formattedTime = math.floor(timeLeft) .. "s"
                end
                
                self:AddLine("Duration: " .. formattedTime, 1, 0.82, 0)
            end
            
            -- Add aura type if available and enabled
            if db.auraType and debuffType then
                local color = DebuffTypeColor[debuffType] or NORMAL_FONT_COLOR
                self:AddLine("Type: " .. debuffType, color.r, color.g, color.b)
            end
            
            self:Show()
        end)

        --hooksecurefunc SetItemRef
        hooksecurefunc("SetItemRef", function(link)
            local type, value = link:match("(%a+):(.+)")
            if type == "spell" then
                TooltipAddSpellID(ItemRefTooltip, value:match("([^:]+)"))
            end
        end)

        --HookScript GameTooltip OnTooltipSetSpell
        local function OnTooltipSetSpell(self, data)
            TooltipAddSpellID(self, data.id)
        end

        local function OnMacroTooltipSetSpell(self)
            if self:GetTooltipData() and self:GetTooltipData().lines and self:GetTooltipData().lines[2] and
                self:GetTooltipData().lines[2].leftText then
                local tooltipData = self:GetTooltipData()
                local tooltipName = tooltipData.lines[2].leftText
                local spellInfo   = C_Spell.GetSpellInfo(tooltipName)

                if (spellInfo and spellInfo.spellID) then
                    TooltipAddSpellID(self, spellInfo.spellID)
                end
            end
        end

        TooltipDataProcessor.AddTooltipPostCall(Enum.TooltipDataType.Macro, OnMacroTooltipSetSpell)
        TooltipDataProcessor.AddTooltipPostCall(Enum.TooltipDataType.Spell, OnTooltipSetSpell)
        TooltipDataProcessor.AddTooltipPostCall(Enum.TooltipDataType.UnitAura, OnTooltipSetSpell)
    end

    if (db.hideincombat) then
        local f = CreateFrame("Frame")
        f:RegisterEvent("PLAYER_REGEN_DISABLED")
        f:RegisterEvent("PLAYER_REGEN_ENABLED")
        f:SetScript("OnEvent", function(self, event, ...)
            if event == "PLAYER_REGEN_DISABLED" then
                GameTooltip:SetScript('OnShow', GameTooltip.Hide)
            else
                GameTooltip:SetScript('OnShow', GameTooltip.Show)
            end
        end)
    end

    -- Apply settings on enable
    self:ApplySettings()
    
    -- Hook tooltip events for custom functionality
    self:HookTooltips()
    
    -- Add a protective hook for Blizzard's UnitFrame_UpdateTooltip function to avoid C_TooltipInfo.GetUnit errors
    if UnitFrame_UpdateTooltip then
        local originalUnitFrameUpdateTooltip = UnitFrame_UpdateTooltip
        UnitFrame_UpdateTooltip = function(self, ...)
            -- Validate the unit before proceeding
            if self and self.unit and (UnitExists(self.unit) or self.unit:match("^nameplate%d+$")) then
                local success, err = pcall(originalUnitFrameUpdateTooltip, self, ...)
                if not success and err and err:find("bad argument #1 to '?'") then
                    -- Error in C_TooltipInfo.GetUnit, silently fail
                    return
                end
            else
                -- Invalid unit, don't call the original function
                return
            end
        end
    end
end

-- Add a function to save tooltip settings specifically
function Module:SaveTooltipSettings()
    -- Ensure settings are initialized
    local db = Phoenix_UI.db.profile.tooltip
    if not db then return end
    
    -- Mark the tooltip section as requiring update
    db.__updated = GetTime()
    
    -- Save tooltip settings immediately to ensure they're not lost
    if Phoenix_UI.SaveDB then
        -- Force tooltip settings to be saved in global table directly
        if _G["Phoenix_UIDB"] and _G["Phoenix_UIDB"].profiles then
            local currentProfile = Phoenix_UI.db.keys and Phoenix_UI.db.keys.profile or "Default"
            
            if _G["Phoenix_UIDB"].profiles[currentProfile] then
                _G["Phoenix_UIDB"].profiles[currentProfile].tooltip = CopyTable(db)
            end
        end
        
        -- Trigger a save
        Phoenix_UI:SaveDB()
        
        -- Force flush to disk
        if FlushSavedVariables then
            FlushSavedVariables()
        elseif FlushSettingsDB then
            FlushSettingsDB()
        end
    end
end

-- Register events to auto-save when config panel is closed
local configFrame = CreateFrame("Frame")
configFrame:RegisterEvent("PLAYER_ENTERING_WORLD")
configFrame:SetScript("OnEvent", function(self, event)
    -- Wait until first load to hook events
    if event == "PLAYER_ENTERING_WORLD" then
        self:UnregisterEvent("PLAYER_ENTERING_WORLD")
        
        -- Hook to the config panel closing
        if Phoenix_UI and Phoenix_UI.UI then
            C_Timer.After(1, function()
                if Phoenix_UI.UI.mainPanel then
                    Phoenix_UI.UI.mainPanel:HookScript("OnHide", function()
                        -- Save tooltip settings when main config panel is closed
                        C_Timer.After(0.5, function()
                            Module:SaveTooltipSettings()
                        end)
                    end)
                end
            end)
        end
    end
end)

-- Apply tooltip settings based on database values
function Module:ApplySettings()
    local db = Phoenix_UI.db.profile.tooltip
    if not db then return end
    
    -- Only proceed if we have GameTooltip available
    if not GameTooltip then return end
    
    -- Apply scale if set
    if db.scale then
        GameTooltip:SetScale(db.scale)
        
        -- Also apply to other tooltips
        if ItemRefTooltip then ItemRefTooltip:SetScale(db.scale) end
        if ShoppingTooltip1 then ShoppingTooltip1:SetScale(db.scale) end
        if ShoppingTooltip2 then ShoppingTooltip2:SetScale(db.scale) end
        if EmbeddedItemTooltip then EmbeddedItemTooltip:SetScale(db.scale) end
    end
    
    -- Apply background opacity
    if db.backgroundOpacity and GameTooltip.SetBackdropColor then
        local backdrop = GameTooltip:GetBackdrop()
        if backdrop then
            local r, g, b = 0.03, 0.03, 0.03
            if Phoenix_UI.db.profile.general and Phoenix_UI.db.profile.general.theme == "Light" then
                r, g, b = 0.9, 0.9, 0.9
            end
            GameTooltip:SetBackdropColor(r, g, b, db.backgroundOpacity)
        end
    end
    
    -- Apply border color if set
    if db.borderColor and GameTooltip.SetBackdropBorderColor then
        GameTooltip:SetBackdropBorderColor(
            db.borderColor.r or 0.6,
            db.borderColor.g or 0.4,
            db.borderColor.b or 0.1,
            db.borderColor.a or 1.0
        )
    end
end

function Module:OnInitialize()
    -- Create a frame for events instead of directly registering them on the module
    self.eventFrame = CreateFrame("Frame")
    self.eventFrame:SetScript("OnEvent", function(_, event, ...) 
        if self[event] then
            self[event](self, ...)
        end
    end)
    
    -- Register for events that require tooltip handling
    self.eventFrame:RegisterEvent("PLAYER_ENTERING_WORLD")
    self.eventFrame:RegisterEvent("INSPECT_READY")
    
    -- Initialize item level cache
    self.itemLevelCache = {}
    self.pendingInspects = {}
    self.slotItemLevels = {}
    
    -- Create a timer for cache cleaning
    self.cleanupTimer = C_Timer.NewTicker(60, function() self:CleanUpCache() end)
end

function Module:PLAYER_ENTERING_WORLD()
    -- Apply settings when entering world
    self:ApplySettings()
end

-- Hook tooltip functions to apply custom behavior
function Module:HookTooltips()
    local db = Phoenix_UI.db.profile.tooltip
    
    -- Hook GameTooltip's OnShow to apply settings each time the tooltip is shown
    GameTooltip:HookScript("OnShow", function(self)
        -- Apply hide in combat
        if db.hideincombat and InCombatLockdown() then
            self:Hide()
            return
        end
        
        -- Apply mouse anchor if enabled
        if db.mouseanchor then
            self:SetOwner(UIParent, "ANCHOR_CURSOR")
        end
        
        -- Apply scale
        if db.scale then
            self:SetScale(db.scale)
        end
        
        -- Apply border color
        if db.borderColor and self.SetBackdropBorderColor then
            self:SetBackdropBorderColor(
                db.borderColor.r or 0.6,
                db.borderColor.g or 0.4,
                db.borderColor.b or 0.1,
                db.borderColor.a or 1.0
            )
        end
        
        -- Apply background opacity
        if db.backgroundOpacity and self.SetBackdropColor then
            local backdrop = self:GetBackdrop()
            if backdrop then
                local r, g, b = 0.03, 0.03, 0.03
                if Phoenix_UI.db.profile.general and Phoenix_UI.db.profile.general.theme == "Light" then
                    r, g, b = 0.9, 0.9, 0.9
                end
                self:SetBackdropColor(r, g, b, db.backgroundOpacity)
            end
        end
    end)
    
    -- Hook tooltip spell info
    if db.detailedAuras then
        -- The SetUnitAura hook is already defined above
        -- Removing duplicate implementation here
    end
    
    -- Apply hook to other tooltips
    if ItemRefTooltip then self:ApplyTooltipHooks(ItemRefTooltip) end
    if ShoppingTooltip1 then self:ApplyTooltipHooks(ShoppingTooltip1) end
    if ShoppingTooltip2 then self:ApplyTooltipHooks(ShoppingTooltip2) end
end

-- Apply common tooltip hooks to a tooltip frame
function Module:ApplyTooltipHooks(tooltip)
    local db = Phoenix_UI.db.profile.tooltip
    
    tooltip:HookScript("OnShow", function(self)
        -- Apply hide in combat
        if db.hideincombat and InCombatLockdown() then
            self:Hide()
            return
        end
        
        -- Apply scale
        if db.scale then
            self:SetScale(db.scale)
        end
        
        -- Apply border color if applicable
        if db.borderColor and self.SetBackdropBorderColor then
            self:SetBackdropBorderColor(
                db.borderColor.r or 0.6, 
                db.borderColor.g or 0.4, 
                db.borderColor.b or 0.1, 
                db.borderColor.a or 1.0
            )
        end
        
        -- Apply background opacity
        if db.backgroundOpacity and self.SetBackdropColor then
            local backdrop = self:GetBackdrop()
            if backdrop then
                local r, g, b = 0.03, 0.03, 0.03
                if Phoenix_UI.db.profile.general and Phoenix_UI.db.profile.general.theme == "Light" then
                    r, g, b = 0.9, 0.9, 0.9
                end
                self:SetBackdropColor(r, g, b, db.backgroundOpacity)
            end
        end
    end)
end

-- Implement the DisplayUnit method in the Module
function Module:DisplayUnit(tooltip, unit)
    local db = Phoenix_UI.db.profile.tooltip
    
    if not unit then return end
    if InCombatLockdown() and db.hideincombat then return end
    
    local unitExists = UnitExists(unit)
    if not unitExists then return end
    
    -- Add role indicator if needed
    if db.roleIcons and UnitIsPlayer(unit) then
        local role = UnitGroupRolesAssigned(unit)
        if role and role ~= "NONE" then
            local roleIcon = ""
            if role == "TANK" then
                roleIcon = "|TInterface\\LFGFrame\\UI-LFG-ICON-PORTRAITROLES:16:16:0:0:64:64:0:19:22:41|t "
            elseif role == "HEALER" then
                roleIcon = "|TInterface\\LFGFrame\\UI-LFG-ICON-PORTRAITROLES:16:16:0:0:64:64:20:39:1:20|t "
            elseif role == "DAMAGER" then
                roleIcon = "|TInterface\\LFGFrame\\UI-LFG-ICON-PORTRAITROLES:16:16:0:0:64:64:20:39:22:41|t "
            end
            
            -- Add role icon to the name line
            local firstLine = _G[tooltip:GetName().."TextLeft1"]
            local text = firstLine and firstLine:GetText()
            if text and not text:find("Interface\\LFGFrame") then
                firstLine:SetText(roleIcon .. text)
            end
        end
    end
    
    -- Show item level if enabled
    if db.showItemLevel and UnitIsPlayer(unit) then
        local averageItemLevel = self:GetItemLevel(unit)
        if averageItemLevel then
            tooltip:AddLine("Item Level: |cff00ff00" .. averageItemLevel .. "|r", 1, 1, 1)
            
            -- Show detailed breakdown if Alt is held down
            if IsAltKeyDown() and UnitIsVisible(unit) then
                tooltip:AddLine(" ")
                tooltip:AddLine("Equipment: (hold Alt to view)", 1, 0.82, 0)
                
                local slotNames = {
                    [1] = "Head",
                    [2] = "Neck",
                    [3] = "Shoulders",
                    [5] = "Chest",
                    [6] = "Waist",
                    [7] = "Legs",
                    [8] = "Feet",
                    [9] = "Wrists",
                    [10] = "Hands",
                    [11] = "Ring 1",
                    [12] = "Ring 2",
                    [13] = "Trinket 1",
                    [14] = "Trinket 2",
                    [15] = "Cloak",
                    [16] = "Main Hand",
                    [17] = "Off Hand"
                }
                
                for slotID, slotName in pairs(slotNames) do
                    local itemLink = GetInventoryItemLink(unit, slotID)
                    if itemLink then
                        local _, _, quality, itemLevel = GetItemInfo(itemLink)
                        
                        -- Get the effective item level with bonuses
                        local effectiveILvl = itemLevel
                        
                        -- Try C_Item API for more accurate level
                        if CanInspect(unit) and C_Item and C_Item.GetCurrentItemLevel then
                            if UnitIsUnit(unit, "player") then
                                local itemLocation = ItemLocation:CreateFromEquipmentSlot(slotID)
                                if C_Item.DoesItemExist(itemLocation) then
                                    effectiveILvl = C_Item.GetCurrentItemLevel(itemLocation) or itemLevel
                                end
                            elseif self.slotItemLevels and self.slotItemLevels[UnitGUID(unit)] then
                                effectiveILvl = self.slotItemLevels[UnitGUID(unit)][slotID] or itemLevel
                            end
                        end
                        
                        if quality then
                            local r, g, b = GetItemQualityColor(quality)
                            local text = string.format("%s: |c%02x%02x%02x%s|r (%d)", 
                                slotName, 
                                r*255, g*255, b*255, 
                                select(1, GetItemInfo(itemLink)) or "Unknown", 
                                effectiveILvl or 0)
                            tooltip:AddLine(text)
                        end
                    end
                end
            end
        else
            -- If we're scanning for item level data, show scanning message
            local guid = UnitGUID(unit)
            if guid and self.pendingInspects[guid] then
                tooltip:AddLine("Item Level: |cffFFCC00Scanning...|r", 1, 1, 1)
            else
                tooltip:AddLine("Item Level: |cff999999Unknown|r", 1, 1, 1)
            end
        end
    end
    
    -- Find who is targeting this unit (multiple players targeting info)
    if db.showExtendedTargeting and UnitIsPlayer(unit) and not UnitIsUnit(unit, "player") then
        -- Collect players who are targeting this unit
        local targetingPlayers = {}
        local targetingCount = 0
        
        -- Check all group members
        local groupSize = IsInRaid() and GetNumGroupMembers() or IsInGroup() and GetNumGroupMembers() or 0
        local prefix = IsInRaid() and "raid" or "party"
        
        -- Include the player in the check
        if UnitIsUnit("target", unit) then
            table.insert(targetingPlayers, {name = UnitName("player"), class = select(2, UnitClass("player"))})
            targetingCount = targetingCount + 1
        end
        
        -- Check all party/raid members
        for i = 1, groupSize do
            local unitID = prefix..i
            if not UnitIsUnit(unitID, "player") and UnitExists(unitID) then
                local targetID = unitID.."target"
                if UnitExists(targetID) and UnitIsUnit(targetID, unit) then
                    local name = UnitName(unitID)
                    local _, class = UnitClass(unitID)
                    table.insert(targetingPlayers, {name = name, class = class})
                    targetingCount = targetingCount + 1
                end
            end
        end
        
        -- Display players targeting this unit
        if targetingCount > 0 then
            tooltip:AddLine(" ")
            tooltip:AddLine("Targeted by:", 1, 0.8, 0)
            
            for _, player in ipairs(targetingPlayers) do
                local color = player.class and RAID_CLASS_COLORS[player.class] or NORMAL_FONT_COLOR
                tooltip:AddLine("  " .. player.name, color.r, color.g, color.b)
            end
        end
    end
    
    -- Target of target information
    if db.targetOfTarget and UnitExists(unit .. "target") then
        local targetName = UnitName(unit.."target")
        local targetReaction = UnitReaction(unit.."target", "player") or 4
        local targetClass = UnitIsPlayer(unit.."target") and select(2, UnitClass(unit.."target"))
        
        if targetName then
            -- Format target name with appropriate colors
            local color = targetClass and RAID_CLASS_COLORS[targetClass] or 
                          FACTION_BAR_COLORS[targetReaction] or 
                          HIGHLIGHT_FONT_COLOR
            
            -- Use targetFormat from config to avoid confusion with "Target" label
            local formatLabel = "Targeting"
            if db.targetFormat then
                -- Get the format value based on the dropdown selection
                local formats = {"Target", "Targeting", "Target >>", "Targets:"}
                local formatIndex = db.targetFormat
                if type(formatIndex) == "number" and formatIndex >= 1 and formatIndex <= #formats then
                    formatLabel = formats[formatIndex]
                elseif type(db.targetFormat) == "string" then
                    formatLabel = db.targetFormat
                end
            end
            
            tooltip:AddLine(" ")
            tooltip:AddLine(formatLabel .. ": " .. targetName, color.r, color.g, color.b)
        end
    end
    
    -- Show health text if enabled
    if db.showHealth then
        local health = UnitHealth(unit)
        local maxHealth = UnitHealthMax(unit)
        
        if health and maxHealth and maxHealth > 0 then
            -- Format health values
            local healthText
            if maxHealth >= 1000000 then
                healthText = string.format("%.1fM/%.1fM (%.0f%%)", 
                    health/1000000, maxHealth/1000000, health/maxHealth*100)
            elseif maxHealth >= 1000 then
                healthText = string.format("%.1fK/%.1fK (%.0f%%)", 
                    health/1000, maxHealth/1000, health/maxHealth*100)
            else
                healthText = string.format("%d/%d (%.0f%%)", 
                    health, maxHealth, health/maxHealth*100)
            end
            
            -- Check if health bar is already showing
            local healthAlreadyShown = false
            for i = 2, tooltip:NumLines() do
                local line = _G[tooltip:GetName().."TextLeft"..i]
                local text = line and line:GetText() or ""
                if text:find("/") and text:find("%%") then 
                    healthAlreadyShown = true
                    break
                end
            end
            
            -- Add health text near the top if not already shown
            if not healthAlreadyShown then
                tooltip:AddLine("Health: " .. healthText, 0.5, 0.75, 1)
            end
        end
    end
end

-- Clean up old item level cache entries
function Module:CleanUpCache()
    local currentTime = GetTime()
    for guid, data in pairs(self.itemLevelCache) do
        if currentTime - data.time > 300 then -- 5 minute cache
            self.itemLevelCache[guid] = nil
            -- Also clean up slot item levels
            if self.slotItemLevels[guid] then
                self.slotItemLevels[guid] = nil
            end
        end
    end
end

-- Handle inspection data ready
function Module:INSPECT_READY(guid)
    local unit = self.pendingInspects[guid]
    if unit and UnitExists(unit) then
        local averageItemLevel, slotItemLevels = self:CalculateAverageItemLevel(unit, true)
        if averageItemLevel then
            self.itemLevelCache[guid] = {
                itemLevel = averageItemLevel,
                time = GetTime()
            }
            -- Store slot-specific item levels
            self.slotItemLevels[guid] = slotItemLevels
        end
        
        -- Remove from pending
        self.pendingInspects[guid] = nil
        
        -- Update any visible tooltips showing this unit
        if GameTooltip:IsShown() then
            local tooltipUnit = select(2, GameTooltip:GetUnit())
            if tooltipUnit and UnitGUID(tooltipUnit) == guid then
                self:DisplayUnit(GameTooltip, unit)
                GameTooltip:Show()
            end
        end
    end
end

-- Calculate average item level
function Module:GetItemLevel(unit)
    if not unit or not UnitExists(unit) then return nil end
    
    -- Only show item level for players
    if not UnitIsPlayer(unit) then return nil end
    
    local guid = UnitGUID(unit)
    if not guid then return nil end
    
    -- Check cache first
    if self.itemLevelCache[guid] then
        return self.itemLevelCache[guid].itemLevel
    end
    
    -- Queue inspection if needed and we can inspect
    if CanInspect(unit) and not InCombatLockdown() and not self.pendingInspects[guid] then
        self.pendingInspects[guid] = unit
        NotifyInspect(unit)
    end
    
    -- For player, we can get item level directly
    if UnitIsUnit(unit, "player") then
        local averageItemLevel = self:CalculateAverageItemLevel(unit)
        self.itemLevelCache[guid] = {
            itemLevel = averageItemLevel,
            time = GetTime()
        }
        return averageItemLevel
    end
    
    -- Return approximate item level from C_PlayerInfo if available
    if C_PlayerInfo and C_PlayerInfo.GetPlayerItemLevel then
        local approximateItemLevel = C_PlayerInfo.GetPlayerItemLevel(guid)
        if approximateItemLevel and approximateItemLevel > 0 then
            self.itemLevelCache[guid] = {
                itemLevel = approximateItemLevel,
                time = GetTime()
            }
            return approximateItemLevel
        end
    end
    
    return nil
end

-- Calculate average item level
function Module:CalculateAverageItemLevel(unit, storeSlotLevels)
    local total, count = 0, 0
    local itemLevelBySlot = {}
    
    -- Get all equippable slots
    for i = 1, 18 do
        -- Skip slots that don't contribute to overall ilevel
        if i ~= 4 and i ~= 17 then -- Skip shirt and tabard slots
            local itemLink = GetInventoryItemLink(unit, i)
            
            if itemLink then
                local _, _, _, itemLevel = GetItemInfo(itemLink)
                
                -- Get the actual item level with bonuses
                local effectiveILvl = itemLevel
                if C_Item and C_Item.GetCurrentItemLevel then
                    -- Use the more accurate API if available (10.0+)
                    if UnitIsUnit("player", unit) then
                        local itemLocation = ItemLocation:CreateFromEquipmentSlot(i)
                        if C_Item.DoesItemExist(itemLocation) then
                            effectiveILvl = C_Item.GetCurrentItemLevel(itemLocation) or itemLevel
                        end
                    end
                end
                
                if effectiveILvl and effectiveILvl > 0 then
                    if storeSlotLevels then
                        itemLevelBySlot[i] = effectiveILvl
                    end
                    total = total + effectiveILvl
                    count = count + 1
                end
            end
        end
    end
    
    if count == 0 then return nil end
    
    -- Calculate average item level
    local averageItemLevel = math.floor(total / count)
    
    -- Get two-handed weapon info - count it twice for average
    local mainHandLink = GetInventoryItemLink(unit, 16) -- Main hand
    local offHandLink = GetInventoryItemLink(unit, 17) -- Off hand
    
    if mainHandLink and not offHandLink then
        local itemEquipLoc = select(9, GetItemInfo(mainHandLink))
        if itemEquipLoc and (itemEquipLoc == "INVTYPE_2HWEAPON" or 
                           itemEquipLoc == "INVTYPE_RANGED" or 
                           itemEquipLoc == "INVTYPE_RANGEDRIGHT") then
            -- Adjust for two-handed weapons
            if itemLevelBySlot[16] then
                total = total + itemLevelBySlot[16]
                count = count + 1
                averageItemLevel = math.floor(total / count)
            end
        end
    end
    
    return averageItemLevel, itemLevelBySlot
end



