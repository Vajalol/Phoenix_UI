-- Phoenix_UI: CooldownTracker Config Module
-- Configuration panel for OmniCC, TrufiGCD, and OmniCD integrations

local Module = Phoenix_UI:NewModule("CooldownTracker.Config");
local L = Phoenix_UI.L

-- Initialize the layout property to ensure it exists before OnInitialize is called
Module.layout = {}

-- Configuration Presets
Module.presets = {
    {
        name = "Default",
        description = "Standard cooldown display with basic features",
        settings = {
            cooldownText = {
                enabled = true,
                swipe = true,
                textSize = 14,
                textPosition = "CENTER",
                expiringDuration = 3,
                normalColor = {r = 1, g = 1, b = 1, a = 1},
                expiringColor = {r = 1, g = 0, b = 0, a = 1},
                finishEffects = {
                    enableFlash = true,
                    flashColor = {r = 1, g = 1, b = 1, a = 0.7},
                    flashDuration = 0.8,
                    effectType = "FLASH"
                }
            }
        }
    },
    {
        name = "Minimal",
        description = "Clean, minimalistic display with small text",
        settings = {
            cooldownText = {
                enabled = true,
                swipe = false,
                textSize = 12,
                textPosition = "CENTER",
                expiringDuration = 2,
                normalColor = {r = 0.8, g = 0.8, b = 0.8, a = 0.9},
                expiringColor = {r = 1, g = 0.3, b = 0.3, a = 1},
                finishEffects = {
                    enableFlash = false
                }
            }
        }
    },
    {
        name = "Phoenix Flame",
        description = "Fiery, eye-catching effects with the Phoenix theme",
        settings = {
            cooldownText = {
                enabled = true,
                swipe = true,
                textSize = 15,
                textPosition = "CENTER",
                expiringDuration = 3,
                normalColor = {r = 1, g = 0.7, b = 0.3, a = 1},
                expiringColor = {r = 1, g = 0.3, b = 0, a = 1},
                finishEffects = {
                    enableFlash = true,
                    effectType = "FLAME",
                    flashColor = {r = 1, g = 0.5, b = 0, a = 0.7},
                    flashDuration = 0.8,
                    flameHeight = 20,
                    flameDuration = 1.0
                }
            }
        }
    },
    {
        name = "High Visibility",
        description = "Large, bold text with animated effects",
        settings = {
            cooldownText = {
                enabled = true,
                swipe = true,
                textSize = 18,
                textPosition = "CENTER",
                textOutline = "THICKOUTLINE",
                expiringDuration = 5,
                normalColor = {r = 1, g = 0.82, b = 0, a = 1},
                expiringColor = {r = 1, g = 0.1, b = 0.1, a = 1},
                finishEffects = {
                    enableFlash = true,
                    effectType = "PULSE",
                    flashColor = {r = 1, g = 1, b = 1, a = 0.8},
                    flashDuration = 1.0,
                    pulseScale = 1.8,
                    pulseDuration = 0.8
                }
            }
        }
    }
}

-- Preview frame for configuration
local function CreatePreviewFrame()
    if Module.previewFrame then return Module.previewFrame end
    
    local frame = CreateFrame("Frame", "PhoenixCDT_PreviewFrame", UIParent)
    frame:SetSize(200, 200)
    frame:SetPoint("CENTER", 0, 0)
    frame:SetFrameStrata("DIALOG")
    
    -- Create a background 
    frame.bg = frame:CreateTexture(nil, "BACKGROUND")
    frame.bg:SetAllPoints()
    frame.bg:SetColorTexture(0.1, 0.1, 0.1, 0.7)
    
    -- Create a title
    frame.title = frame:CreateFontString(nil, "OVERLAY")
    frame.title:SetPoint("TOP", 0, -10)
    frame.title:SetFont(STANDARD_TEXT_FONT, 14, "OUTLINE")
    frame.title:SetText("Preview")
    
    -- Create sample cooldown button
    frame.button = CreateFrame("Button", nil, frame)
    frame.button:SetSize(40, 40)
    frame.button:SetPoint("CENTER", 0, 20)
    
    -- Add icon texture
    frame.button.icon = frame.button:CreateTexture(nil, "BACKGROUND")
    frame.button.icon:SetAllPoints()
    frame.button.icon:SetTexture("Interface\\Icons\\Spell_Nature_Rejuvenation")
    
    -- Create cooldown model
    frame.button.cooldown = CreateFrame("Cooldown", nil, frame.button, "CooldownFrameTemplate")
    frame.button.cooldown:SetAllPoints()
    frame.button.cooldown:SetCooldown(GetTime(), 10) -- 10 second cooldown
    
    -- Create cooldown text
    frame.button.text = frame.button:CreateFontString(nil, "OVERLAY")
    frame.button.text:SetPoint("CENTER", 0, 0)
    frame.button.text:SetFont(STANDARD_TEXT_FONT, 16, "OUTLINE")
    frame.button.text:SetText("10")
    
    -- Create effect textures
    frame.button.flash = frame.button:CreateTexture(nil, "OVERLAY")
    frame.button.flash:SetAllPoints()
    frame.button.flash:SetTexture("Interface\\AddOns\\Phoenix_UI\\Media\\Textures\\Flash")
    frame.button.flash:SetBlendMode("ADD")
    frame.button.flash:SetAlpha(0)
    
    -- Create start button
    frame.startButton = CreateFrame("Button", nil, frame, "UIPanelButtonTemplate")
    frame.startButton:SetSize(80, 22)
    frame.startButton:SetPoint("BOTTOM", 0, 40)
    frame.startButton:SetText("Start")
    frame.startButton:SetScript("OnClick", function()
        frame.button.cooldown:SetCooldown(GetTime(), 10)
        frame.updateTime = GetTime()
        frame.duration = 10
        frame:SetScript("OnUpdate", frame.OnUpdate)
    end)
    
    -- Create close button
    frame.closeButton = CreateFrame("Button", nil, frame, "UIPanelCloseButton")
    frame.closeButton:SetPoint("TOPRIGHT", 0, 0)
    frame.closeButton:SetScript("OnClick", function() frame:Hide() end)
    
    -- Update function for cooldown text
    frame.OnUpdate = function(self, elapsed)
        local timeLeft = (self.updateTime + self.duration) - GetTime()
        if timeLeft <= 0 then
            -- Cooldown expired
            self.button.text:SetText("")
            
            -- Play finish effect
            local db = Phoenix_UI.db.profile.cooldownTracker.cooldownText
            if db and db.finishEffects and db.finishEffects.enableFlash and not self.played then
                local CT = Phoenix_UI:GetModule("CooldownTracker")
                local Styling
                if CT and type(CT.GetModule) == "function" then
                    Styling = CT:GetModule("Styling")
                end
                
                if Styling and type(Styling.PlayFinishEffect) == "function" then
                    Styling:PlayFinishEffect(self.button, db.finishEffects.effectType, db.finishEffects)
                else
                    -- Fallback if styling module isn't available
                    self.button.flash:SetVertexColor(1, 1, 1, 0.7)
                    self.button.flash:SetAlpha(1)
                    self.button.flash:Show()
                    C_Timer.After(0.8, function()
                        self.button.flash:SetAlpha(0)
                        self.button.flash:Hide()
                    end)
                end
                self.played = true
            end
            
            -- Stop updating after effect is played
            if timeLeft < -1 then
                self:SetScript("OnUpdate", nil)
                self.played = nil
            end
            
            return
        end
        
        -- Update cooldown text
        if timeLeft < 60 then
            if timeLeft < 10 then
                self.button.text:SetText(string.format("%.1f", timeLeft))
            else
                self.button.text:SetText(string.format("%d", math.floor(timeLeft)))
            end
        else
            self.button.text:SetText(string.format("%d:%02d", math.floor(timeLeft/60), math.floor(timeLeft%60)))
        end
        
        -- Apply expiring color
        local db = Phoenix_UI.db.profile.cooldownTracker.cooldownText
        if db then
            if timeLeft < (db.expiringDuration or 3) then
                self.button.text:SetTextColor(
                    db.expiringColor and db.expiringColor.r or 1,
                    db.expiringColor and db.expiringColor.g or 0,
                    db.expiringColor and db.expiringColor.b or 0,
                    db.expiringColor and db.expiringColor.a or 1
                )
            else
                self.button.text:SetTextColor(
                    db.normalColor and db.normalColor.r or 1,
                    db.normalColor and db.normalColor.g or 1,
                    db.normalColor and db.normalColor.b or 1,
                    db.normalColor and db.normalColor.a or 1
                )
            end
            
            -- Apply text size and position
            local size = db.textSize or 16
            local position = db.textPosition or "CENTER"
            local font = db.textFont or STANDARD_TEXT_FONT
            local outline = db.textOutline or "OUTLINE"
            
            self.button.text:SetFont(font, size, outline)
            self.button.text:ClearAllPoints()
            self.button.text:SetPoint(position)
            
            -- Show/hide cooldown swipe
            if db.swipe ~= nil then
                if db.swipe then
                    self.button.cooldown:SetDrawSwipe(true)
                    self.button.cooldown:SetDrawEdge(true)
                else
                    self.button.cooldown:SetDrawSwipe(false)
                    self.button.cooldown:SetDrawEdge(false)
                end
            end
        end
    end
    
    frame:Hide()
    Module.previewFrame = frame
    return frame
end

-- Function to update CooldownText module settings
local function UpdateCooldownTextSettings(info, value)
    local options = Phoenix_UI.db.profile.cooldownTracker.cooldownText
    
    -- Handle nested settings
    if info[#info-1] == "cooldownText" then
        options[info[#info]] = value
    end
    
    Phoenix_UI:CallModuleMethod("CooldownTracker.CooldownText", "UpdateSettings", options)
end

-- Function to update SpellTracker module settings
local function UpdateSpellTrackerSettings(info, value)
    local options = Phoenix_UI.db.profile.cooldownTracker.spellTracker
    
    -- Handle nested settings
    if info[#info-1] == "spellTracker" then
        options[info[#info]] = value
    end
    
    Phoenix_UI:CallModuleMethod("CooldownTracker.SpellTracker", "UpdateSettings", options)
end

-- Function to update PartyCD module settings
local function UpdatePartyCDSettings(info, value)
    local options = Phoenix_UI.db.profile.cooldownTracker.partyCD
    
    -- Handle nested settings
    if info[#info-1] == "partyCD" then
        options[info[#info]] = value
    elseif info[#info-2] == "partyCD" and info[#info-1] == "trackedCDs" then
        options.trackedCDs[info[#info]] = value
    end
    
    Phoenix_UI:CallModuleMethod("CooldownTracker.PartyCD", "UpdateSettings", options)
end

-- Apply a configuration preset
function Module:ApplyPreset(presetIndex)
    local preset = self.presets[presetIndex]
    if not preset or not preset.settings then return end
    
    local db = Phoenix_UI.db.profile.cooldownTracker
    
    -- Apply cooldown text settings
    if preset.settings.cooldownText then
        for k, v in pairs(preset.settings.cooldownText) do
            if type(v) == "table" then
                db.cooldownText[k] = CopyTable(v)
            else
                db.cooldownText[k] = v
            end
        end
    end
    
    -- Apply spell tracker settings
    if preset.settings.spellTracker then
        for k, v in pairs(preset.settings.spellTracker) do
            if type(v) == "table" then
                db.spellTracker[k] = CopyTable(v)
            else
                db.spellTracker[k] = v
            end
        end
    end
    
    -- Apply party CD settings
    if preset.settings.partyCD then
        for k, v in pairs(preset.settings.partyCD) do
            if type(v) == "table" then
                db.partyCD[k] = CopyTable(v)
            else
                db.partyCD[k] = v
            end
        end
    end
    
    -- Update all modules
    local CT = Phoenix_UI:GetModule("CooldownTracker")
    if CT then
        CT:UpdateAllCooldowns(true)
    end
    
    -- Update preview if it's open
    if self.previewFrame and self.previewFrame:IsShown() then
        self.previewFrame.updateTime = GetTime()
        self.previewFrame.duration = 10
        self.previewFrame.button.cooldown:SetCooldown(GetTime(), 10)
        self.previewFrame:SetScript("OnUpdate", self.previewFrame.OnUpdate)
    end
    
    -- Save settings
    Phoenix_UI:SaveDB()
    
    -- Refresh config UI
    if Phoenix_UI.UI and Phoenix_UI.UI.RefreshConfig then
        Phoenix_UI.UI:RefreshConfig()
    end
end

-- Save current settings as a user preset
function Module:SaveUserPreset(name, description)
    if not name or name == "" then 
        name = "Custom " .. #self.presets + 1
    end
    
    if not description or description == "" then
        description = "User defined preset"
    end
    
    local db = Phoenix_UI.db.profile.cooldownTracker
    
    -- Create new preset
    local newPreset = {
        name = name,
        description = description,
        isUserPreset = true,
        settings = {
            cooldownText = CopyTable(db.cooldownText),
            spellTracker = CopyTable(db.spellTracker),
            partyCD = CopyTable(db.partyCD)
        }
    }
    
    -- Add to presets
    table.insert(self.presets, newPreset)
    
    -- Save to user data
    if not Phoenix_UI.db.profile.cooldownTracker.userPresets then
        Phoenix_UI.db.profile.cooldownTracker.userPresets = {}
    end
    
    table.insert(Phoenix_UI.db.profile.cooldownTracker.userPresets, newPreset)
    Phoenix_UI:SaveDB()
    
    -- Refresh config UI
    if Phoenix_UI.UI and Phoenix_UI.UI.RefreshConfig then
        Phoenix_UI.UI:RefreshConfig()
    end
    
    return #self.presets
end

-- Delete a user preset
function Module:DeleteUserPreset(presetIndex)
    local preset = self.presets[presetIndex]
    if not preset or not preset.isUserPreset then return end
    
    -- Remove from presets
    table.remove(self.presets, presetIndex)
    
    -- Remove from user data
    if Phoenix_UI.db.profile.cooldownTracker.userPresets then
        for i, userPreset in ipairs(Phoenix_UI.db.profile.cooldownTracker.userPresets) do
            if userPreset.name == preset.name then
                table.remove(Phoenix_UI.db.profile.cooldownTracker.userPresets, i)
                break
            end
        end
    end
    
    Phoenix_UI:SaveDB()
    
    -- Refresh config UI
    if Phoenix_UI.UI and Phoenix_UI.UI.RefreshConfig then
        Phoenix_UI.UI:RefreshConfig()
    end
end

-- Show feature preview
function Module:ShowPreview()
    local frame = CreatePreviewFrame()
    
    -- Apply current settings to preview
    local db = Phoenix_UI.db.profile.cooldownTracker.cooldownText
    if db then
        -- Set text font, size, color
        local size = db.textSize or 16
        local font = db.textFont or STANDARD_TEXT_FONT
        local outline = db.textOutline or "OUTLINE"
        
        frame.button.text:SetFont(font, size, outline)
        
        -- Set text position
        local position = db.textPosition or "CENTER"
        frame.button.text:ClearAllPoints()
        frame.button.text:SetPoint(position)
        
        -- Set cooldown swipe
        if db.swipe ~= nil then
            if db.swipe then
                frame.button.cooldown:SetDrawSwipe(true)
                frame.button.cooldown:SetDrawEdge(true)
            else
                frame.button.cooldown:SetDrawSwipe(false)
                frame.button.cooldown:SetDrawEdge(false)
            end
        end
    end
    
    -- Start the preview
    frame.updateTime = GetTime()
    frame.duration = 10
    frame.button.cooldown:SetCooldown(frame.updateTime, frame.duration)
    frame:SetScript("OnUpdate", frame.OnUpdate)
    
    -- Show the frame
    frame:Show()
end

function Module:SetupConfig()
    -- Ensure we have valid settings to display
    if not Phoenix_UI.db or not Phoenix_UI.db.profile then
        -- Create fallback settings if needed
        return
    end
    
    -- Ensure database exists
    if not Phoenix_UI.db.profile.cooldownTracker then
        if Phoenix_UI.CooldownTracker and Phoenix_UI.CooldownTracker.CopyTable then
            local defaults = Phoenix_UI.CooldownTracker:GetDefaultSettings()
            Phoenix_UI.db.profile.cooldownTracker = Phoenix_UI.CooldownTracker:CopyTable(defaults)
        else
            -- Create minimal settings if main module not available
            Phoenix_UI.db.profile.cooldownTracker = {
                cooldownText = { enabled = false },
                spellTracker = { enabled = false },
                partyCD = { enabled = false },
                general = { enableKeybinds = true }
            }
        end
    end
    
    -- Load user presets
    if Phoenix_UI.db.profile.cooldownTracker.userPresets then
        for _, userPreset in ipairs(Phoenix_UI.db.profile.cooldownTracker.userPresets) do
            -- Check if this preset already exists
            local exists = false
            for i, preset in ipairs(self.presets) do
                if preset.name == userPreset.name and preset.isUserPreset then
                    exists = true
                    break
                end
            end
            
            if not exists then
                table.insert(self.presets, userPreset)
            end
        end
    end
    
    local cooldownText = Phoenix_UI.db.profile.cooldownTracker.cooldownText or {}
    local spellTracker = Phoenix_UI.db.profile.cooldownTracker.spellTracker or {}
    local partyCD = Phoenix_UI.db.profile.cooldownTracker.partyCD or {}
    
    -- Ensure required settings exist
    cooldownText.enabled = cooldownText.enabled ~= nil and cooldownText.enabled or false
    spellTracker.enabled = spellTracker.enabled ~= nil and spellTracker.enabled or false
    partyCD.enabled = partyCD.enabled ~= nil and partyCD.enabled or false
    
    -- Create configuration options
    local options = {
        name = "Cooldowns & Spell Tracking",
        type = "group",
        childGroups = "tab",
        args = {
            moduleEnable = {
                order = 0,
                name = "Enable Cooldown Tracker Module",
                desc = "Master switch for all cooldown tracking functionality",
                type = "toggle",
                width = "full",
                get = function() 
                    local module = Phoenix_UI:GetModule("CooldownTracker", true)
                    return module and module:IsEnabled()
                end,
                set = function(info, value)
                    local module = Phoenix_UI:GetModule("CooldownTracker", true)
                    if module then
                        if value then
                            module:Enable()
                        else
                            module:Disable()
                        end
                        
                        -- Force refresh of the config screen
                        if Phoenix_UI.UI and Phoenix_UI.UI.RefreshConfig then
                            Phoenix_UI.UI:RefreshConfig()
                        end
                    end
                end
            },
            intro = {
                order = 1,
                type = "description",
                name = "Configure cooldown texts, spell tracking, and party cooldown monitoring.",
            },
            -- Quick Settings section
            quickSettings = {
                order = 2,
                type = "group",
                name = "Quick Settings",
                args = {
                    presetHeader = {
                        order = 1,
                        type = "header",
                        name = "Configuration Presets",
                    },
                    presetDescription = {
                        order = 2,
                        type = "description",
                        name = "Select a preset configuration to quickly set up your cooldown tracker.",
                    },
                    presetSelector = {
                        order = 3,
                        type = "select",
                        name = "Select Preset",
                        desc = "Choose a predefined configuration",
                        values = function()
                            local values = {}
                            for i, preset in ipairs(Module.presets) do
                                values[i] = preset.name
                            end
                            return values
                        end,
                        get = function() return 1 end, -- Default to first preset
                        set = function(info, value)
                            Module:ApplyPreset(value)
                        end,
                    },
                    presetDescription = {
                        order = 4,
                        type = "description",
                        name = function()
                            local selected = Module.presets[1]
                            return selected and selected.description or ""
                        end,
                        width = "full",
                    },
                    previewButton = {
                        order = 5,
                        type = "execute",
                        name = "Preview Settings",
                        desc = "Show a preview of the current cooldown settings",
                        func = function() Module:ShowPreview() end,
                    },
                    savePresetButton = {
                        order = 6,
                        type = "execute",
                        name = "Save Current Settings as Preset",
                        desc = "Save your current configuration as a custom preset",
                        func = function()
                            -- Show popup to enter preset name
                            StaticPopupDialogs["PHOENIX_SAVE_PRESET"] = {
                                text = "Enter a name for your preset:",
                                button1 = "Save",
                                button2 = "Cancel",
                                OnAccept = function(self)
                                    local name = self.editBox:GetText()
                                    Module:SaveUserPreset(name)
                                end,
                                timeout = 0,
                                whileDead = true,
                                hideOnEscape = true,
                                preferredIndex = 3,
                                hasEditBox = true,
                                enterClicksFirstButton = true,
                            }
                            StaticPopup_Show("PHOENIX_SAVE_PRESET")
                        end,
                    },
                    deletePresetButton = {
                        order = 7,
                        type = "execute",
                        name = "Delete Custom Preset",
                        desc = "Delete a custom preset configuration",
                        func = function()
                            -- Show popup to select and delete preset
                            StaticPopupDialogs["PHOENIX_DELETE_PRESET"] = {
                                text = "Select a custom preset to delete:",
                                button1 = "Delete",
                                button2 = "Cancel",
                                OnAccept = function(self)
                                    local presetIndex = self.data
                                    Module:DeleteUserPreset(presetIndex)
                                end,
                                timeout = 0,
                                whileDead = true,
                                hideOnEscape = true,
                                preferredIndex = 3,
                            }
                            
                            -- Find user presets
                            local userPresets = {}
                            for i, preset in ipairs(Module.presets) do
                                if preset.isUserPreset then
                                    userPresets[i] = preset.name
                                end
                            end
                            
                            if next(userPresets) then
                                -- There are user presets to delete
                                local dropdown = CreateFrame("Frame", "PhoenixPresetDropdown", UIParent, "UIDropDownMenuTemplate")
                                UIDropDownMenu_Initialize(dropdown, function(self, level)
                                    for index, name in pairs(userPresets) do
                                        local info = UIDropDownMenu_CreateInfo()
                                        info.text = name
                                        info.func = function()
                                            StaticPopupDialogs["PHOENIX_DELETE_PRESET"].data = index
                                            StaticPopup_Show("PHOENIX_DELETE_PRESET")
                                        end
                                        UIDropDownMenu_AddButton(info, level)
                                    end
                                end)
                                ToggleDropDownMenu(1, nil, dropdown, "cursor", 0, 0)
                            else
                                -- No user presets found
                                print("No custom presets found to delete.")
                            end
                        end,
                    },
                    simpleModeHeader = {
                        order = 8,
                        type = "header",
                        name = "Simple Mode Settings",
                    },
                    simpleModeDescription = {
                        order = 9,
                        type = "description",
                        name = "Quickly enable or disable key features without complex configuration.",
                    },
                    enableCooldownText = {
                        order = 10,
                        type = "toggle",
                        name = "Enable Cooldown Text",
                        desc = "Show countdown text on ability and item cooldowns",
                        width = "full",
                        get = function() return cooldownText.enabled end,
                        set = function(info, value)
                            cooldownText.enabled = value
                            UpdateCooldownTextSettings(info, value)
                        end
                    },
                    enableSpellTracker = {
                        order = 11,
                        type = "toggle",
                        name = "Enable Spell Tracker",
                        desc = "Show recently used abilities and spells",
                        width = "full",
                        get = function() return spellTracker.enabled end,
                        set = function(info, value)
                            spellTracker.enabled = value
                            UpdateSpellTrackerSettings(info, value)
                        end
                    },
                    enablePartyCD = {
                        order = 12,
                        type = "toggle",
                        name = "Enable Party Cooldowns",
                        desc = "Track important cooldowns of your party/raid members",
                        width = "full",
                        get = function() return partyCD.enabled end,
                        set = function(info, value)
                            partyCD.enabled = value
                            UpdatePartyCDSettings(info, value)
                        end
                    },
                    performanceMode = {
                        order = 13,
                        type = "toggle",
                        name = "Performance Mode",
                        desc = "Reduce update frequency during combat to improve performance",
                        width = "full",
                        get = function() return Phoenix_UI.db.profile.cooldownTracker.general.performanceMode end,
                        set = function(info, value)
                            Phoenix_UI.db.profile.cooldownTracker.general.performanceMode = value
                        end
                    }
                }
            },
            -- OmniCC-like cooldown text settings
            cooldownText = {
                order = 10,
                name = "Cooldown Text",
                desc = "Settings for cooldown countdown text (OmniCC-like functionality).",
                type = "group",
                args = {
                    header = {
                        order = 1,
                        type = "header",
                        name = "Cooldown Text Settings",
                    },
                    enabled = {
                        order = 2,
                        name = "Enable Cooldown Text",
                        desc = "Show countdown text on cooldowns.",
                        type = "toggle",
                        width = "full",
                        get = function() return cooldownText.enabled end,
                        set = function(info, value)
                            cooldownText.enabled = value
                            UpdateCooldownTextSettings(info, value)
                        end
                    },
                    minDuration = {
                        order = 3,
                        name = "Minimum Duration",
                        desc = "Only show countdown text for cooldowns longer than this many seconds.",
                        type = "range",
                        min = 0,
                        max = 30,
                        step = 0.5,
                        disabled = function() return not cooldownText.enabled end,
                        get = function() return cooldownText.minDuration end,
                        set = function(info, value)
                            cooldownText.minDuration = value
                            UpdateCooldownTextSettings(info, value)
                        end
                    },
                    swipe = {
                        order = 4,
                        name = "Show Cooldown Swipe",
                        desc = "Show the cooldown spiral animation.",
                        type = "toggle",
                        disabled = function() return not cooldownText.enabled end,
                        get = function() return cooldownText.swipe end,
                        set = function(info, value)
                            cooldownText.swipe = value
                            UpdateCooldownTextSettings(info, value)
                        end
                    },
                    textSize = {
                        order = 5,
                        name = "Text Size",
                        desc = "Size of the cooldown text.",
                        type = "range",
                        min = 8,
                        max = 24,
                        step = 1,
                        disabled = function() return not cooldownText.enabled end,
                        get = function() return cooldownText.textSize end,
                        set = function(info, value)
                            cooldownText.textSize = value
                            UpdateCooldownTextSettings(info, value)
                        end
                    },
                    expiringDuration = {
                        order = 6,
                        name = "Expiring Duration",
                        desc = "When to start showing as expiring (in seconds).",
                        type = "range",
                        min = 1,
                        max = 10,
                        step = 0.5,
                        disabled = function() return not cooldownText.enabled end,
                        get = function() return cooldownText.expiringDuration end,
                        set = function(info, value)
                            cooldownText.expiringDuration = value
                            UpdateCooldownTextSettings(info, value)
                        end
                    },
                    colorHeader = {
                        order = 7,
                        type = "header",
                        name = "Text Colors",
                    },
                    textColor = {
                        order = 8,
                        name = "Text Color",
                        desc = "Color of the cooldown text.",
                        type = "color",
                        hasAlpha = false,
                        disabled = function() return not cooldownText.enabled end,
                        get = function() return 
                            cooldownText.textColor[1], 
                            cooldownText.textColor[2], 
                            cooldownText.textColor[3]
                        end,
                        set = function(info, r, g, b)
                            cooldownText.textColor[1] = r
                            cooldownText.textColor[2] = g
                            cooldownText.textColor[3] = b
                            UpdateCooldownTextSettings(info, cooldownText.textColor)
                        end
                    },
                    expiringColor = {
                        order = 9,
                        name = "Expiring Color",
                        desc = "Text color when cooldown is about to expire.",
                        type = "color",
                        hasAlpha = false,
                        disabled = function() return not cooldownText.enabled end,
                        get = function() return 
                            cooldownText.expiringColor[1], 
                            cooldownText.expiringColor[2], 
                            cooldownText.expiringColor[3]
                        end,
                        set = function(info, r, g, b)
                            cooldownText.expiringColor[1] = r
                            cooldownText.expiringColor[2] = g
                            cooldownText.expiringColor[3] = b
                            UpdateCooldownTextSettings(info, cooldownText.expiringColor)
                        end
                    },
                    textOutline = {
                        order = 10,
                        name = "Text Outline",
                        desc = "Style of text outline.",
                        type = "select",
                        values = {
                            [""] = "None",
                            ["OUTLINE"] = "Outline",
                            ["THICKOUTLINE"] = "Thick Outline",
                            ["MONOCHROME"] = "Monochrome"
                        },
                        disabled = function() return not cooldownText.enabled end,
                        get = function() return cooldownText.textOutline end,
                        set = function(info, value)
                            cooldownText.textOutline = value
                            UpdateCooldownTextSettings(info, value)
                        end
                    }
                }
            },
            
            -- TrufiGCD-like spell tracking settings
            spellTracker = {
                order = 20,
                name = "Spell Tracker",
                desc = "Settings for recent spell casting display (TrufiGCD-like functionality).",
                type = "group",
                args = {
                    header = {
                        order = 1,
                        type = "header",
                        name = "Spell Tracker Settings",
                    },
                    enabled = {
                        order = 2,
                        name = "Enable Spell Tracker",
                        desc = "Show recently used abilities.",
                        type = "toggle",
                        width = "full",
                        get = function() return spellTracker.enabled end,
                        set = function(info, value)
                            spellTracker.enabled = value
                            UpdateSpellTrackerSettings(info, value)
                        end
                    },
                    size = {
                        order = 3,
                        name = "Icon Size",
                        desc = "Size of the spell icons.",
                        type = "range",
                        min = 16,
                        max = 64,
                        step = 2,
                        disabled = function() return not spellTracker.enabled end,
                        get = function() return spellTracker.size end,
                        set = function(info, value)
                            spellTracker.size = value
                            UpdateSpellTrackerSettings(info, value)
                        end
                    },
                    maxIcons = {
                        order = 4,
                        name = "Max Icons",
                        desc = "Maximum number of spell icons to display.",
                        type = "range",
                        min = 1,
                        max = 10,
                        step = 1,
                        disabled = function() return not spellTracker.enabled end,
                        get = function() return spellTracker.maxIcons end,
                        set = function(info, value)
                            spellTracker.maxIcons = value
                            UpdateSpellTrackerSettings(info, value)
                        end
                    },
                    fadeTime = {
                        order = 5,
                        name = "Fade Time",
                        desc = "How long spells stay visible (in seconds).",
                        type = "range",
                        min = 1,
                        max = 10,
                        step = 0.5,
                        disabled = function() return not spellTracker.enabled end,
                        get = function() return spellTracker.fadeTime end,
                        set = function(info, value)
                            spellTracker.fadeTime = value
                            UpdateSpellTrackerSettings(info, value)
                        end
                    },
                    direction = {
                        order = 6,
                        name = "Direction",
                        desc = "Direction that new spells flow.",
                        type = "select",
                        values = {
                            LEFT = "Left",
                            RIGHT = "Right",
                            UP = "Up",
                            DOWN = "Down"
                        },
                        disabled = function() return not spellTracker.enabled end,
                        get = function() return spellTracker.direction end,
                        set = function(info, value)
                            spellTracker.direction = value
                            UpdateSpellTrackerSettings(info, value)
                        end
                    },
                    showGlow = {
                        order = 7,
                        name = "Show Glow",
                        desc = "Show a glow effect on recent spells.",
                        type = "toggle",
                        disabled = function() return not spellTracker.enabled end,
                        get = function() return spellTracker.showGlow end,
                        set = function(info, value)
                            spellTracker.showGlow = value
                            UpdateSpellTrackerSettings(info, value)
                        end
                    },
                    showTooltip = {
                        order = 8,
                        name = "Show Tooltips",
                        desc = "Show spell tooltips on mouseover.",
                        type = "toggle",
                        disabled = function() return not spellTracker.enabled end,
                        get = function() return spellTracker.showTooltip end,
                        set = function(info, value)
                            spellTracker.showTooltip = value
                            UpdateSpellTrackerSettings(info, value)
                        end
                    },
                    opacity = {
                        order = 9,
                        name = "Opacity",
                        desc = "Transparency of the icons.",
                        type = "range",
                        min = 0.1,
                        max = 1,
                        step = 0.05,
                        disabled = function() return not spellTracker.enabled end,
                        get = function() return spellTracker.opacity end,
                        set = function(info, value)
                            spellTracker.opacity = value
                            UpdateSpellTrackerSettings(info, value)
                        end
                    },
                    resetPosition = {
                        order = 10,
                        name = "Reset Position",
                        desc = "Reset the position of the spell tracker frame.",
                        type = "execute",
                        disabled = function() return not spellTracker.enabled end,
                        func = function()
                            spellTracker.position = {"CENTER", "UIParent", "CENTER", 0, -140}
                            UpdateSpellTrackerSettings("position", spellTracker.position)
                        end
                    },
                    blacklistHeader = {
                        order = 11,
                        type = "header",
                        name = "Spell Blacklist",
                    },
                    blacklistNote = {
                        order = 12,
                        type = "description",
                        name = "Type a spell ID to add to the blacklist. These spells will not show in the tracker.",
                        width = "full"
                    },
                    addToBlacklist = {
                        order = 13,
                        name = "Add Spell to Blacklist",
                        desc = "Add a spell to the blacklist by its ID",
                        type = "input",
                        width = 1.5,
                        disabled = function() return not spellTracker.enabled end,
                        set = function(info, value)
                            local spellID = tonumber(value)
                            if spellID and GetSpellInfo(spellID) then
                                spellTracker.blacklist[spellID] = true
                                Phoenix_UI:CallModuleMethod("CooldownTracker.SpellTracker", "AddToBlacklist", spellID)
                                return ""
                            end
                        end,
                        get = function() return "" end
                    }
                }
            },
            
            -- OmniCD-like party cooldown tracking settings
            partyCD = {
                order = 30,
                name = "Party Cooldowns",
                desc = "Settings for tracking party member cooldowns (OmniCD-like functionality).",
                type = "group",
                args = {
                    header = {
                        order = 1,
                        type = "header",
                        name = "Party Cooldown Settings",
                    },
                    enabled = {
                        order = 2,
                        name = "Enable Party Cooldowns",
                        desc = "Track cooldowns of party/raid members.",
                        type = "toggle",
                        width = "full",
                        get = function() return partyCD.enabled end,
                        set = function(info, value)
                            partyCD.enabled = value
                            UpdatePartyCDSettings(info, value)
                        end
                    },
                    displayHeader = {
                        order = 3,
                        type = "header",
                        name = "Display Options",
                    },
                    showOnFrames = {
                        order = 4,
                        name = "Show on Raid Frames",
                        desc = "Display cooldown icons on party/raid frames.",
                        type = "toggle",
                        disabled = function() return not partyCD.enabled end,
                        get = function() return partyCD.showOnFrames end,
                        set = function(info, value)
                            partyCD.showOnFrames = value
                            UpdatePartyCDSettings(info, value)
                        end
                    },
                    standalone = {
                        order = 5,
                        name = "Standalone Window",
                        desc = "Display cooldowns in a separate window.",
                        type = "toggle",
                        disabled = function() return not partyCD.enabled end,
                        get = function() return partyCD.standalone end,
                        set = function(info, value)
                            partyCD.standalone = value
                            UpdatePartyCDSettings(info, value)
                        end
                    },
                    iconSize = {
                        order = 6,
                        name = "Icon Size",
                        desc = "Size of the cooldown icons on frames.",
                        type = "range",
                        min = 8,
                        max = 32,
                        step = 1,
                        disabled = function() return not partyCD.enabled or not partyCD.showOnFrames end,
                        get = function() return partyCD.iconSize end,
                        set = function(info, value)
                            partyCD.iconSize = value
                            UpdatePartyCDSettings(info, value)
                        end
                    },
                    showText = {
                        order = 7,
                        name = "Show Countdown Text",
                        desc = "Show remaining time on cooldown icons.",
                        type = "toggle",
                        disabled = function() return not partyCD.enabled end,
                        get = function() return partyCD.showText end,
                        set = function(info, value)
                            partyCD.showText = value
                            UpdatePartyCDSettings(info, value)
                        end
                    },
                    groupCDs = {
                        order = 8,
                        name = "Group Similar CDs",
                        desc = "Group similar cooldowns together.",
                        type = "toggle",
                        disabled = function() return not partyCD.enabled end,
                        get = function() return partyCD.groupCDs end,
                        set = function(info, value)
                            partyCD.groupCDs = value
                            UpdatePartyCDSettings(info, value)
                        end
                    },
                    alertSoundHeader = {
                        order = 9,
                        type = "header",
                        name = "Alert Sounds",
                    },
                    alertSound = {
                        order = 10,
                        name = "Alert Sound",
                        desc = "Play a sound when a major cooldown becomes available.",
                        type = "select",
                        values = function()
                            local sounds = {
                                ["none"] = "None"
                            }
                            
                            -- Add standard WoW sounds
                            sounds["Interface\\AddOns\\Phoenix_UI\\Media\\Sounds\\ReadyCheck.ogg"] = "Ready Check"
                            sounds["Interface\\AddOns\\Phoenix_UI\\Media\\Sounds\\ProcSound.ogg"] = "Proc"
                            
                            return sounds
                        end,
                        disabled = function() return not partyCD.enabled end,
                        get = function() 
                            return partyCD.alertSound or "none"
                        end,
                        set = function(info, value)
                            partyCD.alertSound = (value ~= "none") and value or nil
                            UpdatePartyCDSettings(info, partyCD.alertSound)
                        end
                    },
                    trackedCDHeader = {
                        order = 11,
                        type = "header",
                        name = "Tracked Cooldown Types",
                    },
                    trackedCDs = {
                        order = 12,
                        name = "Tracked Categories",
                        desc = "Select which types of cooldowns to track.",
                        type = "group",
                        inline = true,
                        disabled = function() return not partyCD.enabled end,
                        args = {
                            interrupt = {
                                order = 1,
                                name = "Interrupts",
                                desc = "Track interrupt abilities.",
                                type = "toggle",
                                width = "half",
                                get = function() return partyCD.trackedCDs.interrupt end,
                                set = function(info, value)
                                    partyCD.trackedCDs.interrupt = value
                                    UpdatePartyCDSettings(info, value)
                                end
                            },
                            defensive = {
                                order = 2,
                                name = "Defensive CDs",
                                desc = "Track personal defensive cooldowns.",
                                type = "toggle",
                                width = "half",
                                get = function() return partyCD.trackedCDs.defensive end,
                                set = function(info, value)
                                    partyCD.trackedCDs.defensive = value
                                    UpdatePartyCDSettings(info, value)
                                end
                            },
                            offensive = {
                                order = 3,
                                name = "Offensive CDs",
                                desc = "Track major offensive cooldowns.",
                                type = "toggle",
                                width = "half",
                                get = function() return partyCD.trackedCDs.offensive end,
                                set = function(info, value)
                                    partyCD.trackedCDs.offensive = value
                                    UpdatePartyCDSettings(info, value)
                                end
                            },
                            raidCD = {
                                order = 4,
                                name = "Raid CDs",
                                desc = "Track major raid cooldowns.",
                                type = "toggle",
                                width = "half",
                                get = function() return partyCD.trackedCDs.raidCD end,
                                set = function(info, value)
                                    partyCD.trackedCDs.raidCD = value
                                    UpdatePartyCDSettings(info, value)
                                end
                            },
                            utility = {
                                order = 5,
                                name = "Utility",
                                desc = "Track utility abilities.",
                                type = "toggle",
                                width = "half",
                                get = function() return partyCD.trackedCDs.utility end,
                                set = function(info, value)
                                    partyCD.trackedCDs.utility = value
                                    UpdatePartyCDSettings(info, value)
                                end
                            },
                            covenant = {
                                order = 6,
                                name = "Covenant",
                                desc = "Track covenant abilities.",
                                type = "toggle",
                                width = "half",
                                get = function() return partyCD.trackedCDs.covenant end,
                                set = function(info, value)
                                    partyCD.trackedCDs.covenant = value
                                    UpdatePartyCDSettings(info, value)
                                end
                            }
                        }
                    }
                }
            }
        }
    }
    
    -- Register with Phoenix_UI's config system
    if not Phoenix_UI.options then
        Phoenix_UI.options = {}
    elseif not Phoenix_UI.options.args then
        Phoenix_UI.options.args = {}
    end
    
    -- Add our options to Phoenix_UI's config
    Phoenix_UI.options.args.cooldownTracker = options
    
    -- Add to main panel if available
    if Phoenix_UI.MainPanel and Phoenix_UI.MainPanel.AddModule then
        Phoenix_UI.MainPanel:AddModule("CooldownTracker", "Cooldowns & Spell Tracking", function()
            -- Open options to CooldownTracker panel
            Phoenix_UI:OpenConfig("cooldownTracker")
        end)
    end
    
    return true
end

-- Function to initialize or update the layout
function Module:OnInitialize()
    self:SetupConfig()
    
    -- Store the options in the layout property for Phoenix_UI config integration
    local options = {
        name = "Cooldowns & Spell Tracking",
        type = "group",
        childGroups = "tab",
        args = {
            intro = {
                order = 1,
                type = "description",
                name = "Configure cooldown texts, spell tracking, and party cooldown monitoring.",
            },
            -- OmniCC-like cooldown text settings
            cooldownText = {
                order = 10,
                name = "Cooldown Text",
                desc = "Settings for cooldown countdown text (OmniCC-like functionality).",
                type = "group",
                args = {
                    header = {
                        order = 1,
                        type = "header",
                        name = "Cooldown Text Settings",
                    },
                    enabled = {
                        order = 2,
                        name = "Enable Cooldown Text",
                        desc = "Show countdown text on cooldowns.",
                        type = "toggle",
                        width = "full",
                        get = function() return Phoenix_UI.db.profile.cooldownTracker.cooldownText.enabled end,
                        set = function(info, value)
                            Phoenix_UI.db.profile.cooldownTracker.cooldownText.enabled = value
                            UpdateCooldownTextSettings(info, value)
                        end
                    },
                    minDuration = {
                        order = 3,
                        name = "Minimum Duration",
                        desc = "Only show countdown text for cooldowns longer than this many seconds.",
                        type = "range",
                        min = 0,
                        max = 30,
                        step = 0.5,
                        disabled = function() return not Phoenix_UI.db.profile.cooldownTracker.cooldownText.enabled end,
                        get = function() return Phoenix_UI.db.profile.cooldownTracker.cooldownText.minDuration end,
                        set = function(info, value)
                            Phoenix_UI.db.profile.cooldownTracker.cooldownText.minDuration = value
                            UpdateCooldownTextSettings(info, value)
                        end
                    },
                    swipe = {
                        order = 4,
                        name = "Show Cooldown Swipe",
                        desc = "Show the cooldown spiral animation.",
                        type = "toggle",
                        disabled = function() return not Phoenix_UI.db.profile.cooldownTracker.cooldownText.enabled end,
                        get = function() return Phoenix_UI.db.profile.cooldownTracker.cooldownText.swipe end,
                        set = function(info, value)
                            Phoenix_UI.db.profile.cooldownTracker.cooldownText.swipe = value
                            UpdateCooldownTextSettings(info, value)
                        end
                    },
                    textSize = {
                        order = 5,
                        name = "Text Size",
                        desc = "Size of the cooldown text.",
                        type = "range",
                        min = 8,
                        max = 24,
                        step = 1,
                        disabled = function() return not Phoenix_UI.db.profile.cooldownTracker.cooldownText.enabled end,
                        get = function() return Phoenix_UI.db.profile.cooldownTracker.cooldownText.textSize end,
                        set = function(info, value)
                            Phoenix_UI.db.profile.cooldownTracker.cooldownText.textSize = value
                            UpdateCooldownTextSettings(info, value)
                        end
                    },
                    expiringDuration = {
                        order = 6,
                        name = "Expiring Duration",
                        desc = "When to start showing as expiring (in seconds).",
                        type = "range",
                        min = 1,
                        max = 10,
                        step = 0.5,
                        disabled = function() return not Phoenix_UI.db.profile.cooldownTracker.cooldownText.enabled end,
                        get = function() return Phoenix_UI.db.profile.cooldownTracker.cooldownText.expiringDuration end,
                        set = function(info, value)
                            Phoenix_UI.db.profile.cooldownTracker.cooldownText.expiringDuration = value
                            UpdateCooldownTextSettings(info, value)
                        end
                    },
                    colorHeader = {
                        order = 7,
                        type = "header",
                        name = "Text Colors",
                    },
                    textColor = {
                        order = 8,
                        name = "Text Color",
                        desc = "Color of the cooldown text.",
                        type = "color",
                        hasAlpha = false,
                        disabled = function() return not Phoenix_UI.db.profile.cooldownTracker.cooldownText.enabled end,
                        get = function() return 
                            Phoenix_UI.db.profile.cooldownTracker.cooldownText.textColor[1], 
                            Phoenix_UI.db.profile.cooldownTracker.cooldownText.textColor[2], 
                            Phoenix_UI.db.profile.cooldownTracker.cooldownText.textColor[3]
                        end,
                        set = function(info, r, g, b)
                            Phoenix_UI.db.profile.cooldownTracker.cooldownText.textColor[1] = r
                            Phoenix_UI.db.profile.cooldownTracker.cooldownText.textColor[2] = g
                            Phoenix_UI.db.profile.cooldownTracker.cooldownText.textColor[3] = b
                            UpdateCooldownTextSettings(info, Phoenix_UI.db.profile.cooldownTracker.cooldownText.textColor)
                        end
                    },
                    expiringColor = {
                        order = 9,
                        name = "Expiring Color",
                        desc = "Text color when cooldown is about to expire.",
                        type = "color",
                        hasAlpha = false,
                        disabled = function() return not Phoenix_UI.db.profile.cooldownTracker.cooldownText.enabled end,
                        get = function() return 
                            Phoenix_UI.db.profile.cooldownTracker.cooldownText.expiringColor[1], 
                            Phoenix_UI.db.profile.cooldownTracker.cooldownText.expiringColor[2], 
                            Phoenix_UI.db.profile.cooldownTracker.cooldownText.expiringColor[3]
                        end,
                        set = function(info, r, g, b)
                            Phoenix_UI.db.profile.cooldownTracker.cooldownText.expiringColor[1] = r
                            Phoenix_UI.db.profile.cooldownTracker.cooldownText.expiringColor[2] = g
                            Phoenix_UI.db.profile.cooldownTracker.cooldownText.expiringColor[3] = b
                            UpdateCooldownTextSettings(info, Phoenix_UI.db.profile.cooldownTracker.cooldownText.expiringColor)
                        end
                    },
                    textOutline = {
                        order = 10,
                        name = "Text Outline",
                        desc = "Style of text outline.",
                        type = "select",
                        values = {
                            [""] = "None",
                            ["OUTLINE"] = "Outline",
                            ["THICKOUTLINE"] = "Thick Outline",
                            ["MONOCHROME"] = "Monochrome"
                        },
                        disabled = function() return not Phoenix_UI.db.profile.cooldownTracker.cooldownText.enabled end,
                        get = function() return Phoenix_UI.db.profile.cooldownTracker.cooldownText.textOutline end,
                        set = function(info, value)
                            Phoenix_UI.db.profile.cooldownTracker.cooldownText.textOutline = value
                            UpdateCooldownTextSettings(info, value)
                        end
                    }
                }
            },
            -- SpellTracker settings
            spellTracker = {
                order = 20,
                name = "Spell Tracker",
                desc = "Settings for tracking spell casts (like TrufiGCD).",
                type = "group",
                args = {
                    header = {
                        order = 1,
                        type = "header",
                        name = "Spell Tracker Settings",
                    },
                    enabled = {
                        order = 2,
                        name = "Enable Spell Tracker",
                        desc = "Track spell casts to display recently used abilities.",
                        type = "toggle",
                        width = "full",
                        get = function() return Phoenix_UI.db.profile.cooldownTracker.spellTracker.enabled end,
                        set = function(info, value)
                            Phoenix_UI.db.profile.cooldownTracker.spellTracker.enabled = value
                            UpdateSpellTrackerSettings(info, value)
                        end
                    },
                    size = {
                        order = 3,
                        name = "Icon Size",
                        desc = "Size of the spell icons.",
                        type = "range",
                        min = 16,
                        max = 64,
                        step = 2,
                        disabled = function() return not Phoenix_UI.db.profile.cooldownTracker.spellTracker.enabled end,
                        get = function() return Phoenix_UI.db.profile.cooldownTracker.spellTracker.size end,
                        set = function(info, value)
                            Phoenix_UI.db.profile.cooldownTracker.spellTracker.size = value
                            UpdateSpellTrackerSettings(info, value)
                        end
                    },
                    maxIcons = {
                        order = 4,
                        name = "Max Icons",
                        desc = "Maximum number of spell icons to display.",
                        type = "range",
                        min = 1,
                        max = 10,
                        step = 1,
                        disabled = function() return not Phoenix_UI.db.profile.cooldownTracker.spellTracker.enabled end,
                        get = function() return Phoenix_UI.db.profile.cooldownTracker.spellTracker.maxIcons end,
                        set = function(info, value)
                            Phoenix_UI.db.profile.cooldownTracker.spellTracker.maxIcons = value
                            UpdateSpellTrackerSettings(info, value)
                        end
                    },
                    fadeTime = {
                        order = 5,
                        name = "Fade Time",
                        desc = "How long spells stay visible (in seconds).",
                        type = "range",
                        min = 1,
                        max = 10,
                        step = 0.5,
                        disabled = function() return not Phoenix_UI.db.profile.cooldownTracker.spellTracker.enabled end,
                        get = function() return Phoenix_UI.db.profile.cooldownTracker.spellTracker.fadeTime end,
                        set = function(info, value)
                            Phoenix_UI.db.profile.cooldownTracker.spellTracker.fadeTime = value
                            UpdateSpellTrackerSettings(info, value)
                        end
                    },
                    direction = {
                        order = 6,
                        name = "Direction",
                        desc = "Direction that new spells flow.",
                        type = "select",
                        values = {
                            LEFT = "Left",
                            RIGHT = "Right",
                            UP = "Up",
                            DOWN = "Down"
                        },
                        disabled = function() return not Phoenix_UI.db.profile.cooldownTracker.spellTracker.enabled end,
                        get = function() return Phoenix_UI.db.profile.cooldownTracker.spellTracker.direction end,
                        set = function(info, value)
                            Phoenix_UI.db.profile.cooldownTracker.spellTracker.direction = value
                            UpdateSpellTrackerSettings(info, value)
                        end
                    },
                    showGlow = {
                        order = 7,
                        name = "Show Glow",
                        desc = "Show a glow effect on recent spells.",
                        type = "toggle",
                        disabled = function() return not Phoenix_UI.db.profile.cooldownTracker.spellTracker.enabled end,
                        get = function() return Phoenix_UI.db.profile.cooldownTracker.spellTracker.showGlow end,
                        set = function(info, value)
                            Phoenix_UI.db.profile.cooldownTracker.spellTracker.showGlow = value
                            UpdateSpellTrackerSettings(info, value)
                        end
                    },
                    showTooltip = {
                        order = 8,
                        name = "Show Tooltips",
                        desc = "Show spell tooltips on mouseover.",
                        type = "toggle",
                        disabled = function() return not Phoenix_UI.db.profile.cooldownTracker.spellTracker.enabled end,
                        get = function() return Phoenix_UI.db.profile.cooldownTracker.spellTracker.showTooltip end,
                        set = function(info, value)
                            Phoenix_UI.db.profile.cooldownTracker.spellTracker.showTooltip = value
                            UpdateSpellTrackerSettings(info, value)
                        end
                    },
                    opacity = {
                        order = 9,
                        name = "Opacity",
                        desc = "Transparency of the icons.",
                        type = "range",
                        min = 0.1,
                        max = 1,
                        step = 0.05,
                        disabled = function() return not Phoenix_UI.db.profile.cooldownTracker.spellTracker.enabled end,
                        get = function() return Phoenix_UI.db.profile.cooldownTracker.spellTracker.opacity end,
                        set = function(info, value)
                            Phoenix_UI.db.profile.cooldownTracker.spellTracker.opacity = value
                            UpdateSpellTrackerSettings(info, value)
                        end
                    },
                    resetPosition = {
                        order = 10,
                        name = "Reset Position",
                        desc = "Reset the position of the spell tracker frame.",
                        type = "execute",
                        disabled = function() return not Phoenix_UI.db.profile.cooldownTracker.spellTracker.enabled end,
                        func = function()
                            Phoenix_UI.db.profile.cooldownTracker.spellTracker.position = {"CENTER", "UIParent", "CENTER", 0, -140}
                            UpdateSpellTrackerSettings("position", Phoenix_UI.db.profile.cooldownTracker.spellTracker.position)
                        end
                    },
                    blacklistHeader = {
                        order = 11,
                        type = "header",
                        name = "Spell Blacklist",
                    },
                    blacklistNote = {
                        order = 12,
                        type = "description",
                        name = "Type a spell ID to add to the blacklist. These spells will not show in the tracker.",
                        width = "full"
                    },
                    addToBlacklist = {
                        order = 13,
                        name = "Add Spell to Blacklist",
                        desc = "Add a spell to the blacklist by its ID",
                        type = "input",
                        width = 1.5,
                        disabled = function() return not Phoenix_UI.db.profile.cooldownTracker.spellTracker.enabled end,
                        set = function(info, value)
                            local spellID = tonumber(value)
                            if spellID and GetSpellInfo(spellID) then
                                Phoenix_UI.db.profile.cooldownTracker.spellTracker.blacklist[spellID] = true
                                Phoenix_UI:CallModuleMethod("CooldownTracker.SpellTracker", "AddToBlacklist", spellID)
                                return ""
                            end
                        end,
                        get = function() return "" end
                    }
                }
            },
            -- PartyCD settings
            partyCD = {
                order = 30,
                name = "Party Cooldowns",
                desc = "Settings for tracking party and raid member cooldowns (like OmniCD).",
                type = "group",
                args = {
                    header = {
                        order = 1,
                        type = "header",
                        name = "Party Cooldown Settings",
                    },
                    enabled = {
                        order = 2,
                        name = "Enable Party Cooldown Tracking",
                        desc = "Track important cooldowns of party and raid members.",
                        type = "toggle",
                        width = "full",
                        get = function() return Phoenix_UI.db.profile.cooldownTracker.partyCD.enabled end,
                        set = function(info, value)
                            Phoenix_UI.db.profile.cooldownTracker.partyCD.enabled = value
                            UpdatePartyCDSettings(info, value)
                        end
                    },
                    displayHeader = {
                        order = 3,
                        type = "header",
                        name = "Display Options",
                    },
                    showOnFrames = {
                        order = 4,
                        name = "Show on Raid Frames",
                        desc = "Display cooldown icons on party/raid frames.",
                        type = "toggle",
                        disabled = function() return not Phoenix_UI.db.profile.cooldownTracker.partyCD.enabled end,
                        get = function() return Phoenix_UI.db.profile.cooldownTracker.partyCD.showOnFrames end,
                        set = function(info, value)
                            Phoenix_UI.db.profile.cooldownTracker.partyCD.showOnFrames = value
                            UpdatePartyCDSettings(info, value)
                        end
                    },
                    standalone = {
                        order = 5,
                        name = "Standalone Window",
                        desc = "Display cooldowns in a separate window.",
                        type = "toggle",
                        disabled = function() return not Phoenix_UI.db.profile.cooldownTracker.partyCD.enabled end,
                        get = function() return Phoenix_UI.db.profile.cooldownTracker.partyCD.standalone end,
                        set = function(info, value)
                            Phoenix_UI.db.profile.cooldownTracker.partyCD.standalone = value
                            UpdatePartyCDSettings(info, value)
                        end
                    },
                    iconSize = {
                        order = 6,
                        name = "Icon Size",
                        desc = "Size of the cooldown icons on frames.",
                        type = "range",
                        min = 8,
                        max = 32,
                        step = 1,
                        disabled = function() return not Phoenix_UI.db.profile.cooldownTracker.partyCD.enabled or not Phoenix_UI.db.profile.cooldownTracker.partyCD.showOnFrames end,
                        get = function() return Phoenix_UI.db.profile.cooldownTracker.partyCD.iconSize end,
                        set = function(info, value)
                            Phoenix_UI.db.profile.cooldownTracker.partyCD.iconSize = value
                            UpdatePartyCDSettings(info, value)
                        end
                    },
                    showText = {
                        order = 7,
                        name = "Show Countdown Text",
                        desc = "Show remaining time on cooldown icons.",
                        type = "toggle",
                        disabled = function() return not Phoenix_UI.db.profile.cooldownTracker.partyCD.enabled end,
                        get = function() return Phoenix_UI.db.profile.cooldownTracker.partyCD.showText end,
                        set = function(info, value)
                            Phoenix_UI.db.profile.cooldownTracker.partyCD.showText = value
                            UpdatePartyCDSettings(info, value)
                        end
                    },
                    groupCDs = {
                        order = 8,
                        name = "Group Similar CDs",
                        desc = "Group similar cooldowns together.",
                        type = "toggle",
                        disabled = function() return not Phoenix_UI.db.profile.cooldownTracker.partyCD.enabled end,
                        get = function() return Phoenix_UI.db.profile.cooldownTracker.partyCD.groupCDs end,
                        set = function(info, value)
                            Phoenix_UI.db.profile.cooldownTracker.partyCD.groupCDs = value
                            UpdatePartyCDSettings(info, value)
                        end
                    },
                    alertSoundHeader = {
                        order = 9,
                        type = "header",
                        name = "Alert Sounds",
                    },
                    alertSound = {
                        order = 10,
                        name = "Alert Sound",
                        desc = "Play a sound when a major cooldown becomes available.",
                        type = "select",
                        values = function()
                            local sounds = {
                                ["none"] = "None"
                            }
                            
                            -- Add standard WoW sounds
                            sounds["Interface\\AddOns\\Phoenix_UI\\Media\\Sounds\\ReadyCheck.ogg"] = "Ready Check"
                            sounds["Interface\\AddOns\\Phoenix_UI\\Media\\Sounds\\ProcSound.ogg"] = "Proc"
                            
                            return sounds
                        end,
                        disabled = function() return not Phoenix_UI.db.profile.cooldownTracker.partyCD.enabled end,
                        get = function() 
                            return Phoenix_UI.db.profile.cooldownTracker.partyCD.alertSound or "none"
                        end,
                        set = function(info, value)
                            Phoenix_UI.db.profile.cooldownTracker.partyCD.alertSound = (value ~= "none") and value or nil
                            UpdatePartyCDSettings(info, Phoenix_UI.db.profile.cooldownTracker.partyCD.alertSound)
                        end
                    },
                    trackedCDHeader = {
                        order = 11,
                        type = "header",
                        name = "Tracked Cooldown Types",
                    },
                    trackedCDs = {
                        order = 12,
                        name = "Tracked Categories",
                        desc = "Select which types of cooldowns to track.",
                        type = "group",
                        inline = true,
                        disabled = function() return not Phoenix_UI.db.profile.cooldownTracker.partyCD.enabled end,
                        args = {
                            interrupt = {
                                order = 1,
                                name = "Interrupts",
                                desc = "Track interrupt abilities.",
                                type = "toggle",
                                width = "half",
                                get = function() return Phoenix_UI.db.profile.cooldownTracker.partyCD.trackedCDs.interrupt end,
                                set = function(info, value)
                                    Phoenix_UI.db.profile.cooldownTracker.partyCD.trackedCDs.interrupt = value
                                    UpdatePartyCDSettings(info, value)
                                end
                            },
                            defensive = {
                                order = 2,
                                name = "Defensive CDs",
                                desc = "Track personal defensive cooldowns.",
                                type = "toggle",
                                width = "half",
                                get = function() return Phoenix_UI.db.profile.cooldownTracker.partyCD.trackedCDs.defensive end,
                                set = function(info, value)
                                    Phoenix_UI.db.profile.cooldownTracker.partyCD.trackedCDs.defensive = value
                                    UpdatePartyCDSettings(info, value)
                                end
                            },
                            offensive = {
                                order = 3,
                                name = "Offensive CDs",
                                desc = "Track major offensive cooldowns.",
                                type = "toggle",
                                width = "half",
                                get = function() return Phoenix_UI.db.profile.cooldownTracker.partyCD.trackedCDs.offensive end,
                                set = function(info, value)
                                    Phoenix_UI.db.profile.cooldownTracker.partyCD.trackedCDs.offensive = value
                                    UpdatePartyCDSettings(info, value)
                                end
                            },
                            raidCD = {
                                order = 4,
                                name = "Raid CDs",
                                desc = "Track major raid cooldowns.",
                                type = "toggle",
                                width = "half",
                                get = function() return Phoenix_UI.db.profile.cooldownTracker.partyCD.trackedCDs.raidCD end,
                                set = function(info, value)
                                    Phoenix_UI.db.profile.cooldownTracker.partyCD.trackedCDs.raidCD = value
                                    UpdatePartyCDSettings(info, value)
                                end
                            },
                            utility = {
                                order = 5,
                                name = "Utility",
                                desc = "Track utility abilities.",
                                type = "toggle",
                                width = "half",
                                get = function() return Phoenix_UI.db.profile.cooldownTracker.partyCD.trackedCDs.utility end,
                                set = function(info, value)
                                    Phoenix_UI.db.profile.cooldownTracker.partyCD.trackedCDs.utility = value
                                    UpdatePartyCDSettings(info, value)
                                end
                            },
                            covenant = {
                                order = 6,
                                name = "Covenant",
                                desc = "Track covenant abilities.",
                                type = "toggle",
                                width = "half",
                                get = function() return Phoenix_UI.db.profile.cooldownTracker.partyCD.trackedCDs.covenant end,
                                set = function(info, value)
                                    Phoenix_UI.db.profile.cooldownTracker.partyCD.trackedCDs.covenant = value
                                    UpdatePartyCDSettings(info, value)
                                end
                            }
                        }
                    }
                }
            },
        },
    }
    
    self.layout = options
end

-- Make the module available globally for access
if not Phoenix_UI.CooldownTracker then 
    Phoenix_UI.CooldownTracker = {} 
end
Phoenix_UI.CooldownTracker.Config = Module 