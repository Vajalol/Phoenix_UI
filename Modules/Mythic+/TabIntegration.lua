-- Phoenix_UI: Mythic+ Tab Integration for Main GUI
-- Adds a dedicated Mythic+ tab to the main Phoenix_UI panel

local addonName, Phoenix = ...
local MythicPlus = Phoenix.Modules.MythicPlus
if not MythicPlus then return end

local TabIntegration = MythicPlus:NewModule("TabIntegration")
local L = MythicPlus.L

-- Function to create the tab icon
local function CreateTabIcon()
    -- Use a phoenix or fire themed icon for the tab
    local iconPath = "Interface\\Icons\\Ability_Mount_FireHawk"
    
    -- Set the texture path here if using a custom texture
    -- For example: iconPath = "Interface\\AddOns\\Phoenix_UI\\Media\\Icons\\MythicPlus"
    
    return iconPath
end

-- Create the tab content
function TabIntegration:CreateTab(container)
    -- Header
    local header = container:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    header:SetPoint("TOPLEFT", container, "TOPLEFT", 16, -16)
    header:SetText("|cffFFD100" .. L["MYTHIC_PLUS"] .. "|r")
    
    -- Description
    local desc = container:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
    desc:SetPoint("TOPLEFT", header, "BOTTOMLEFT", 0, -8)
    desc:SetText(L["MYTHIC_PLUS_DESC"])
    desc:SetWidth(container:GetWidth() - 32)
    
    -- Main enable/disable toggle
    local enabledCheckbox = CreateFrame("CheckButton", nil, container, "UICheckButtonTemplate")
    enabledCheckbox:SetPoint("TOPLEFT", desc, "BOTTOMLEFT", 0, -16)
    enabledCheckbox.text:SetText(ENABLE)
    enabledCheckbox:SetChecked(MythicPlus.db.profile.enabled)
    enabledCheckbox:SetScript("OnClick", function(self)
        MythicPlus.db.profile.enabled = self:GetChecked()
        MythicPlus:UpdateSettings()
    end)
    
    -- Create scrollable content area
    local scrollFrame = CreateFrame("ScrollFrame", nil, container, "UIPanelScrollFrameTemplate")
    scrollFrame:SetPoint("TOPLEFT", enabledCheckbox, "BOTTOMLEFT", 0, -16)
    scrollFrame:SetPoint("BOTTOMRIGHT", container, "BOTTOMRIGHT", -32, 16)
    
    local scrollChild = CreateFrame("Frame")
    scrollFrame:SetScrollChild(scrollChild)
    scrollChild:SetWidth(scrollFrame:GetWidth())
    scrollChild:SetHeight(1) -- Will be resized as content is added
    
    local contentWidth = scrollChild:GetWidth() - 16
    local currentHeight = 8
    
    -- Helper function to create section headers
    local function CreateSectionHeader(title)
        local section = scrollChild:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
        section:SetPoint("TOPLEFT", scrollChild, "TOPLEFT", 8, -currentHeight)
        section:SetText("|cffFFD100" .. title .. "|r")
        currentHeight = currentHeight + section:GetHeight() + 8
        
        local divider = scrollChild:CreateTexture(nil, "ARTWORK")
        divider:SetHeight(1)
        divider:SetColorTexture(0.6, 0.6, 0.6, 0.8)
        divider:SetPoint("TOPLEFT", section, "BOTTOMLEFT", 0, -4)
        divider:SetPoint("RIGHT", scrollChild, "RIGHT", -8, 0)
        currentHeight = currentHeight + 8
        
        return currentHeight
    end
    
    -- Helper function to create checkboxes
    local function CreateCheckbox(text, dbKey, parent, extraOffset, tooltip)
        local checkbox = CreateFrame("CheckButton", nil, parent, "UICheckButtonTemplate")
        checkbox:SetPoint("TOPLEFT", parent, "TOPLEFT", 8, -currentHeight - (extraOffset or 0))
        checkbox.text:SetText(text)
        checkbox:SetChecked(MythicPlus.db.profile[dbKey])
        checkbox:SetScript("OnClick", function(self)
            MythicPlus.db.profile[dbKey] = self:GetChecked()
            MythicPlus:UpdateSettings()
        end)
        
        if tooltip then
            checkbox.tooltipText = tooltip
            checkbox:SetScript("OnEnter", function(self)
                GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
                GameTooltip:SetText(self.tooltipText, nil, nil, nil, nil, true)
                GameTooltip:Show()
            end)
            checkbox:SetScript("OnLeave", function(self)
                GameTooltip:Hide()
            end)
        end
        
        currentHeight = currentHeight + checkbox:GetHeight() + 4
        return checkbox
    end
    
    -- Helper function to create dropdowns
    local function CreateDropdown(text, dbKey, options, width, parent, extraOffset)
        local label = parent:CreateFontString(nil, "OVERLAY", "GameFontNormal")
        label:SetPoint("TOPLEFT", parent, "TOPLEFT", 8, -currentHeight - (extraOffset or 0))
        label:SetText(text)
        
        local dropdown = CreateFrame("Frame", nil, parent, "UIDropDownMenuTemplate")
        dropdown:SetPoint("TOPLEFT", label, "BOTTOMLEFT", -16, -2)
        UIDropDownMenu_SetWidth(dropdown, width or 180)
        
        local currentValue = MythicPlus.db.profile[dbKey]
        UIDropDownMenu_SetText(dropdown, options[currentValue] or "")
        
        UIDropDownMenu_Initialize(dropdown, function(self, level)
            local info = UIDropDownMenu_CreateInfo()
            
            for value, text in pairs(options) do
                info.text = text
                info.value = value
                info.checked = (currentValue == value)
                info.func = function()
                    UIDropDownMenu_SetText(dropdown, text)
                    MythicPlus.db.profile[dbKey] = value
                    MythicPlus:UpdateSettings()
                    CloseDropDownMenus()
                end
                UIDropDownMenu_AddButton(info, level)
            end
        end)
        
        currentHeight = currentHeight + label:GetHeight() + 40
        return dropdown
    end
    
    -- Section 1: Timer
    currentHeight = CreateSectionHeader(L["TIMER"] or "Timer")
    
    local showTimerCheckbox = CreateCheckbox(L["TIMER"] or "Enhanced Timer", "showTimer", scrollChild, 0, L["TIMER_DESC"])
    
    -- Timer style dropdown
    local timerStyleOptions = {
        ["PHOENIX"] = L["TIMER_STYLE_PHOENIX"] or "Phoenix UI",
        ["CLASSIC"] = L["TIMER_STYLE_CLASSIC"] or "Classic",
        ["MINIMALIST"] = L["TIMER_STYLE_MINIMALIST"] or "Minimalist"
    }
    local timerStyleDropdown = CreateDropdown(L["TIMER_STYLE"] or "Timer Style", "timerStyle", timerStyleOptions, 150, scrollChild, 8)
    
    -- Chest markers checkbox
    local showChestTimersCheckbox = CreateCheckbox(L["TIMER_CHEST_MARKERS"] or "Chest Timers", "showChestTimers", scrollChild, 0, L["TIMER_CHEST_MARKERS_DESC"])
    
    -- Lock timer frame checkbox
    local lockTimerFrameCheckbox = CreateCheckbox(L["LOCK_TIMER_FRAME"] or "Lock Timer Frame", "lockTimerFrame", scrollChild)
    
    -- Section 2: Progress Tracker
    currentHeight = CreateSectionHeader(L["ENEMY_FORCES"] or "Enemy Forces")
    
    local trackProgressCheckbox = CreateCheckbox(L["ENEMY_FORCES"] or "Track Enemy Forces", "trackProgress", scrollChild, 0, L["ENEMY_FORCES_DESC"])
    
    -- Progress format dropdown
    local progressFormatOptions = {
        ["PERCENTAGE_ONLY"] = L["ENEMY_FORCES_PERCENTAGE"] or "Percentage only",
        ["VALUE_ONLY"] = L["ENEMY_FORCES_VALUE"] or "Value only",
        ["PERCENTAGE_AND_VALUE"] = L["ENEMY_FORCES_BOTH"] or "Percentage and value"
    }
    local progressFormatDropdown = CreateDropdown(L["ENEMY_FORCES_FORMAT"] or "Format", "progressFormat", progressFormatOptions, 180, scrollChild, 8)
    
    -- Show enemy tooltip checkbox
    local showEnemyTooltipCheckbox = CreateCheckbox(L["ENEMY_FORCES_TOOLTIP"] or "Show progress value on enemy tooltips", "showEnemyTooltip", scrollChild, 0, L["ENEMY_FORCES_TOOLTIP_DESC"])
    
    -- Section 3: Death Tracker
    currentHeight = CreateSectionHeader(L["DEATH_TRACKER"] or "Death Tracker")
    
    local deathTrackerCheckbox = CreateCheckbox(L["DEATH_COUNTER"] or "Death Counter", "deathTracker", scrollChild, 0, L["DEATH_COUNTER_DESC"])
    
    local showDeathDetailsCheckbox = CreateCheckbox(L["DEATH_DETAILS"] or "Death Details", "showDeathDetails", scrollChild, 0, L["DEATH_DETAILS_DESC"])
    
    -- Death penalty checkbox
    local deathPenaltyCheckbox = CreateCheckbox(L["TIME_PENALTY"] or "Apply Time Penalty", "deathPenalty", scrollChild)
    
    -- Announce deaths checkbox
    local announceDeathsCheckbox = CreateCheckbox(L["ANNOUNCE_DEATHS"] or "Announce Deaths", "announceDeaths", scrollChild)
    
    -- Section 4: Keystone Link
    currentHeight = CreateSectionHeader(L["KEYSTONE_LINK"] or "Keystone Link")
    
    local keystoneLinkCheckbox = CreateCheckbox(L["KEYSTONE_LINK"] or "Enhanced Keystone Links", "keystoneLink", scrollChild, 0, L["KEYSTONE_LINK_DESC"])
    
    -- Section 5: Auto Gossip
    currentHeight = CreateSectionHeader(L["AUTO_GOSSIP"] or "Auto Gossip")
    
    local autoGossipCheckbox = CreateCheckbox(L["AUTO_GOSSIP"] or "Auto Gossip", "autoGossip", scrollChild, 0, L["AUTO_GOSSIP_DESC"])
    
    local showCluesCheckbox = CreateCheckbox(L["SHOW_CLUES"] or "Show Court of Stars Clues", "showClues", scrollChild, 0, L["SHOW_CLUES_DESC"])
    
    -- Set final height of scroll child
    scrollChild:SetHeight(currentHeight + 20)
    
    -- Handle dependencies between options
    showTimerCheckbox:SetScript("OnClick", function(self)
        MythicPlus.db.profile.showTimer = self:GetChecked()
        timerStyleDropdown:SetEnabled(self:GetChecked())
        showChestTimersCheckbox:SetEnabled(self:GetChecked())
        lockTimerFrameCheckbox:SetEnabled(self:GetChecked())
        MythicPlus:UpdateSettings()
    end)
    
    deathTrackerCheckbox:SetScript("OnClick", function(self)
        MythicPlus.db.profile.deathTracker = self:GetChecked()
        showDeathDetailsCheckbox:SetEnabled(self:GetChecked())
        MythicPlus:UpdateSettings()
    end)
    
    autoGossipCheckbox:SetScript("OnClick", function(self)
        MythicPlus.db.profile.autoGossip = self:GetChecked()
        showCluesCheckbox:SetEnabled(self:GetChecked())
        MythicPlus:UpdateSettings()
    end)
    
    -- Initial state
    timerStyleDropdown:SetEnabled(MythicPlus.db.profile.showTimer)
    showChestTimersCheckbox:SetEnabled(MythicPlus.db.profile.showTimer)
    lockTimerFrameCheckbox:SetEnabled(MythicPlus.db.profile.showTimer)
    showDeathDetailsCheckbox:SetEnabled(MythicPlus.db.profile.deathTracker)
    showCluesCheckbox:SetEnabled(MythicPlus.db.profile.autoGossip)
    
    return container
end

-- Register with Phoenix_UI tab system
function TabIntegration:OnInitialize()
    -- Wait for Phoenix_UI to be ready
    if Phoenix_UI and Phoenix_UI.RegisterTab then
        Phoenix_UI:RegisterTab({
            name = "MythicPlus",
            displayName = L["MYTHIC_PLUS"] or "Mythic+",
            icon = CreateTabIcon(),
            createTabFn = function(container)
                return self:CreateTab(container)
            end
        })
    else
        -- Try again when Phoenix_UI is ready
        Phoenix_UI:RegisterMessage("PHOENIX_UI_READY", function()
            if Phoenix_UI and Phoenix_UI.RegisterTab then
                Phoenix_UI:RegisterTab({
                    name = "MythicPlus",
                    displayName = L["MYTHIC_PLUS"] or "Mythic+",
                    icon = CreateTabIcon(),
                    createTabFn = function(container)
                        return self:CreateTab(container)
                    end
                })
            end
        end)
    end
end 