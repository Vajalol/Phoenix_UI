local Layout = Phoenix_UI:NewModule('Config.Layout.General')

-- Create a common change handler for general settings to ensure they save properly
local function generalSettingChanged(element, value)
    -- Get the database
    local db = Phoenix_UI.db
    
    -- Store the value in the database
    if element.dataKey and db.profile.general then
        -- Get the field name without the general. prefix
        local fieldName = element.dataKey:gsub("^general%.", "")
        
        -- Handle nested fields if needed
        if fieldName:find("%.") then
            local parts = {}
            for part in fieldName:gmatch("[^%.]+") do
                table.insert(parts, part)
            end
            
            -- Navigate to the right spot in the table
            local current = db.profile.general
            for i = 1, #parts-1 do
                if not current[parts[i]] then
                    current[parts[i]] = {}
                end
                current = current[parts[i]]
            end
            
            -- Set the value
            current[parts[#parts]] = value
        else
            -- Direct setting
            db.profile.general[fieldName] = value
        end
        
        -- Debug output
        if Phoenix_UI.debug then
            print("PHX-UI: General setting changed:", element.dataKey, "=", tostring(value))
        end
        
        -- Force an immediate save
        if Phoenix_UI.SaveDB then
            Phoenix_UI:SaveDB()
            
            -- Ensure it's written to disk
            if FlushSavedVariables then
                FlushSavedVariables()
            elseif FlushSettingsDB then
                FlushSettingsDB()
            end
        end
        
        -- Also trigger UI refresh
        if Phoenix_UI.UI and Phoenix_UI.UI.RefreshConfig then
            C_Timer.After(0.1, function()
                Phoenix_UI.UI:RefreshConfig()
            end)
        end
    end
end

function Layout:OnEnable()
    -- Database
    local db = Phoenix_UI.db

    -- Data
    local Themes = Phoenix_UI:GetModule("Data.Themes")
    local Fonts = Phoenix_UI:GetModule("Data.Fonts")
    local Textures = Phoenix_UI:GetModule("Data.Textures")

    -- Layout
    Layout.layout = {
        layoutConfig = { padding = { top = 15 } },
        database = db.profile.general,
        rows = {
            {
                header = {
                    type = 'header',
                    label = 'General'
                }
            },
            {
                theme = {
                    key = 'theme',
                    type = 'dropdown',
                    label = 'Theme',
                    options = Themes.data,
                    column = 5,
                    order = 1,
                    onChange = generalSettingChanged
                },
                font = {
                    key = 'font',
                    type = 'dropdown',
                    label = 'Font',
                    options = Fonts.data,
                    column = 5,
                    order = 2,
                    onChange = generalSettingChanged,
                    OnValueChanged = function(dropdown, value)
                        if value and db.profile then
                            -- Store the value in the appropriate places
                            db.profile.fonts = db.profile.fonts or {}
                            db.profile.fonts.gameFont = db.profile.fonts.gameFont or {}
                            
                            -- Set the value in both places to ensure proper handling
                            db.profile.fonts.gameFont.family = value
                            db.profile.general = db.profile.general or {}
                            db.profile.general.font = value
                            
                            -- Apply the new font settings immediately
                            Phoenix_UI:ApplyFontSettings()
                            
                            -- Force immediate save to database
                            if Phoenix_UI.SaveDB then
                                C_Timer.After(0.1, function()
                                    Phoenix_UI:SaveDB()
                                    
                                    -- Explicitly update the general UI
                                    C_Timer.After(0.2, function()
                                        -- Force immediate write to disk
                                        if FlushSavedVariables then
                                            FlushSavedVariables()
                                        elseif FlushSettingsDB then 
                                            FlushSettingsDB()
                                        end
                                        
                                        -- Also update UI if needed
                                        if Phoenix_UI.UI and Phoenix_UI.UI.RefreshConfig then
                                            Phoenix_UI.UI:RefreshConfig()
                                        end
                                    end)
                                end)
                            end
                        end
                    end
                },
                --[[texture = {
          key = 'texture',
          type = 'dropdown',
          label = 'Texture',
          options = Textures.data,
          column = 4,
          order = 3
        }]]
            },
            {
                color = {
                    key = 'color',
                    type = 'color',
                    label = 'Custom Color',
                    column = 3,
                    initialValue = {r = 0.7, g = 0.7, b = 0.7, a = 1.0},
                    update = function() end,
                    cancel = function() end,
                    onChange = generalSettingChanged
                }
            },
            {
                header = {
                    type = 'header',
                    label = 'Modules'
                },
            },
            {
                spellNotifications = {
                    key = 'spellNotifications',
                    type = 'checkbox',
                    label = 'Spell Notifications',
                    tooltip = 'Enable/disable spell notifications (dispels, interrupts, reflects, etc.)',
                    column = 3,
                    order = 1,
                    initialValue = true,
                    onChange = function(element, value)
                        generalSettingChanged(element, value)
                        -- Initialize or disable SpellNotifications based on the setting
                        if value then
                            if SpellNotifications and SpellNotifications.Initialize then
                                SpellNotifications:Initialize()
                            end
                        end
                    end
                }
            },
            {
                header = {
                    type = 'header',
                    label = 'Automation'
                },
            },
            {
                sell    = {
                    key = 'automation.sell',
                    type = 'checkbox',
                    label = 'Sell',
                    tooltip = 'Sells grey items automatically',
                    column = 3,
                    order = 1,
                    onChange = generalSettingChanged
                },
                delete  = {
                    key = 'automation.delete',
                    type = 'checkbox',
                    label = 'Delete',
                    tooltip = 'Inserts "DELETE" when deleting Rare+ items',
                    column = 3,
                    order = 2,
                    onChange = generalSettingChanged
                },
                duel    = {
                    key = 'automation.decline',
                    type = 'checkbox',
                    label = 'Duel',
                    tooltip = 'Declines duels automatically',
                    column = 3,
                    order = 3,
                    onChange = generalSettingChanged
                },
                release = {
                    key = 'automation.release',
                    type = 'checkbox',
                    label = 'Release',
                    tooltip = 'Release automatically when you died',
                    column = 3,
                    order = 4,
                    onChange = generalSettingChanged
                }
            },
            {
                resurrect = {
                    key = 'automation.resurrect',
                    type = 'checkbox',
                    label = 'Resurrect',
                    tooltip = 'Accept ress automatically',
                    column = 3,
                    order = 1,
                    onChange = generalSettingChanged
                },
                invite = {
                    key = 'automation.invite',
                    type = 'checkbox',
                    label = 'Invite',
                    tooltip = 'Accept group invite automatically',
                    column = 3,
                    order = 2,
                    onChange = generalSettingChanged
                },
                cinematic = {
                    key = 'automation.cinematic',
                    type = 'checkbox',
                    label = 'Cinematic',
                    tooltip = 'Skip cinematics automatically',
                    column = 3,
                    order = 3,
                    onChange = generalSettingChanged
                },
            },
            {
                repair = {
                    key = 'automation.repair',
                    type = 'dropdown',
                    label = 'Repair',
                    options = {
                        { value = 'Default', text = 'Default' },
                        { value = 'Player', text = 'Repair automatically' },
                        { value = 'Guild', text = 'Repair automatically using guild bank' }
                    },
                    initialValue = 1,
                    column = 9,
                    order = 1,
                    onChange = generalSettingChanged
                }
            },
            {
                header = {
                    type = 'header',
                    label = 'Display'
                },
            },
            {
                items = {
                    key = 'display.ilvl',
                    type = 'checkbox',
                    label = 'Item Info',
                    tooltip = 'Display item information on items in bags/bank and character/inspect frame',
                    column = 3,
                    order = 1,
                    onChange = generalSettingChanged
                },
                fps = {
                    key = 'display.fps',
                    type = 'checkbox',
                    label = 'FPS',
                    tooltip = 'Show current FPS',
                    column = 2,
                    order = 2,
                    onChange = generalSettingChanged
                },
                ms = {
                    key = 'display.ms',
                    type = 'checkbox',
                    label = 'MS',
                    tooltip = 'Show current ping',
                    column = 2,
                    order = 3
                },
                movementSpeed = {
                    key = 'display.movementSpeed',
                    type = 'checkbox',
                    label = 'Movement Speed',
                    tooltip = 'Show current movement speed',
                    column = 2,
                    order = 4
                },
            },
            {
                playerStats = {
                    key = 'display.playerStats',
                    type = 'checkbox',
                    label = 'Player Stats',
                    tooltip = 'Show detailed player stats frame with Crit, Haste, Mastery, etc.',
                    column = 3,
                    order = 1,
                    onChange = function(element, value)
                        generalSettingChanged(element, value)
                        
                        -- Update frame visibility immediately
                        if _G.Phoenix_PlayerStatsFrame then
                            if value then
                                _G.Phoenix_PlayerStatsFrame:Show()
                            else
                                _G.Phoenix_PlayerStatsFrame:Hide()
                            end
                        end
                    end
                },
                playerStatsConfig = {
                    type = 'button',
                    label = '',
                    text = 'Configure Stats',
                    tooltip = 'Open the detailed configuration panel for Player Stats with enhanced options',
                    column = 2,
                    order = 1,
                    onClick = function()
                        -- Open the PlayerStats config tab if it exists
                        if Phoenix_UI.UI and Phoenix_UI.UI.SelectTab then
                            Phoenix_UI.UI:SelectTab("PlayerStats")
                        end
                    end
                },
                afkscreen = {
                    key = 'cosmetic.afkscreen',
                    type = 'checkbox',
                    label = 'AFK Screen',
                    tooltip = 'Display a nice screen while you are AFK',
                    column = 3,
                    order = 1,
                    onChange = generalSettingChanged
                },
                talkhead = {
                    key = 'cosmetic.talkinghead',
                    type = 'checkbox',
                    label = 'Talkinghead',
                    tooltip = 'Show Talkinghead frame',
                    column = 3,
                    order = 2,
                    onChange = generalSettingChanged
                },
                Errors = {
                    key = 'cosmetic.errors',
                    type = 'checkbox',
                    label = 'Error Messages',
                    tooltip = 'Show Error Messages',
                    column = 3,
                    order = 3,
                    onChange = generalSettingChanged
                }
            },
            {
                spec = {
                    key = 'display.spec',
                    type = 'checkbox',
                    label = 'Specialization',
                    tooltip = 'Show current talent specialization',
                    column = 3,
                    order = 1,
                    initialValue = true,
                    onChange = generalSettingChanged
                },
                lootSpec = {
                    key = 'display.loot',
                    type = 'checkbox',
                    label = 'Loot Spec',
                    tooltip = 'Show current loot specialization',
                    column = 3,
                    order = 2,
                    initialValue = true,
                    onChange = generalSettingChanged
                }
            }
        }
    }

    -- Create a common change handler for general settings to ensure they save properly
    local function generalSettingChanged(element, value)
        -- Store the value in the database
        if element.dataKey and db.profile.general then
            -- Get the field name without the general. prefix
            local fieldName = element.dataKey:gsub("^general%.", "")
            
            -- Handle nested fields if needed
            if fieldName:find("%.") then
                local parts = {}
                for part in fieldName:gmatch("[^%.]+") do
                    table.insert(parts, part)
                end
                
                -- Navigate to the right spot in the table
                local current = db.profile.general
                for i = 1, #parts-1 do
                    if not current[parts[i]] then
                        current[parts[i]] = {}
                    end
                    current = current[parts[i]]
                end
                
                -- Set the value
                current[parts[#parts]] = value
            else
                -- Direct setting
                db.profile.general[fieldName] = value
            end
            
            -- Force an immediate save
            if Phoenix_UI.SaveDB then
                Phoenix_UI:SaveDB()
                
                -- Ensure it's written to disk
                if FlushSavedVariables then
                    FlushSavedVariables()
                elseif FlushSettingsDB then
                    FlushSettingsDB()
                end
            end
            
            -- Also trigger UI refresh
            if Phoenix_UI.UI and Phoenix_UI.UI.RefreshConfig then
                C_Timer.After(0.1, function()
                    Phoenix_UI.UI:RefreshConfig()
                end)
            end
        end
    end
end

-- Add a refresh method to update controls with current values
function Layout:Refresh()
    if not self.layout or not self.layout.rows then return end
    
    -- Get the config tabs
    local config = Phoenix_UI.UI
    if not config or not config.elements then return end
    
    -- Force the General tab to update with current database values
    local db = Phoenix_UI.db
    if db and db.profile and db.profile.general then
        -- Update our local database reference
        self.layout.database = db.profile.general
        
        -- Force a full rebuild if needed
        if config.RefreshConfig then
            config:RefreshConfig()
        end
    end
    
    -- Force all settings to be saved
    if Phoenix_UI.ForceSaveDB then
        Phoenix_UI:ForceSaveDB()
    end
end



