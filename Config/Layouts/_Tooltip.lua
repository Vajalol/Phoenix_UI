local Layout = Phoenix_UI:NewModule('Config.Layout.Tooltip')

-- Create a dedicated tooltip settings change handler
local function tooltipSettingChanged(element, value)
    -- Use the centralized handler function if available
    if Phoenix_UI.CreateModuleSettingChangedHandler then
        -- Call the centralized handler directly
        Phoenix_UI:CreateModuleSettingChangedHandler("tooltip")(element, value)
    else
        -- Fallback implementation if the central handler isn't available
        -- Get the database
        local db = Phoenix_UI.db
        
        -- Store the value in the database
        if element.dataKey and db.profile.tooltip then
            -- Get the field name without the tooltip. prefix
            local fieldName = element.dataKey:gsub("^tooltip%.", "")
            
            -- Handle nested fields if needed
            if fieldName:find("%.") then
                local parts = {}
                for part in fieldName:gmatch("[^%.]+") do
                    table.insert(parts, part)
                end
                
                -- Navigate to the right spot in the table
                local current = db.profile.tooltip
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
                db.profile.tooltip[fieldName] = value
            end
            
            -- Debug output
            if Phoenix_UI.debug then
                print("PHX-UI: Tooltip setting changed:", element.dataKey, "=", tostring(value))
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
            
            -- Also directly update global savedvariables
            if _G["Phoenix_UIDB"] and _G["Phoenix_UIDB"].profiles then
                local currentProfile = db.keys and db.keys.profile or "Default"
                if not _G["Phoenix_UIDB"].profiles[currentProfile] then
                    _G["Phoenix_UIDB"].profiles[currentProfile] = {}
                end
                if not _G["Phoenix_UIDB"].profiles[currentProfile].tooltip then
                    _G["Phoenix_UIDB"].profiles[currentProfile].tooltip = {}
                end
                
                -- Deep copy to ensure all changes are preserved
                _G["Phoenix_UIDB"].profiles[currentProfile].tooltip = CopyTable(db.profile.tooltip)
                _G["Phoenix_UIDB"].profiles[currentProfile].tooltip.__updated = GetTime()
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

function Layout:OnEnable()
    -- Database
    local db = Phoenix_UI.db

    -- Layout
    Layout.layout = {
        layoutConfig = { 
            padding = { top = 15 },
            initialScrollOffset = 0  -- Ensure panel starts scrolled to the top
        },
        database = db.profile.tooltip,
        rows = {
            -- Main Header and Style Selection
            {
                header = {
                    type = 'header',
                    label = 'Tooltip Configuration'
                }
            },
            {
                style = {
                    key = 'style',
                    label = 'Tooltip Style',
                    type = 'dropdown',
                    options = {
                        { value = 'Default', text = 'Default' },
                        { value = 'Custom', text = 'Custom' }
                    },
                    initialValue = 1,
                    column = 12,
                    order = 1,
                    onChange = tooltipSettingChanged
                }
            },
            
            -- General Settings Header
            {
                generalHeader = {
                    type = 'header',
                    label = 'General Settings'
                },
            },
            
            -- First row of general options
            {
                mouseanchor = {
                    key = 'mouseanchor',
                    type = 'checkbox',
                    label = 'Anchor to Mouse',
                    tooltip = 'Attach tooltip to mouse cursor position',
                    column = 4,
                    order = 1,
                    onChange = tooltipSettingChanged
                },
                lifeontop = {
                    key = 'lifeontop',
                    type = 'checkbox',
                    label = 'Health Bar on Top',
                    tooltip = 'Show health bar at the top of tooltips',
                    column = 4,
                    order = 2,
                    onChange = tooltipSettingChanged
                },
                hideincombat = {
                    key = 'hideincombat',
                    type = 'checkbox',
                    tooltip = 'Hide tooltips while in combat',
                    label = 'Hide in Combat',
                    column = 4,
                    order = 3,
                    onChange = tooltipSettingChanged
                }
            },
            
            -- Appearance Settings Header
            {
                appearanceHeader = {
                    type = 'header',
                    label = 'Appearance Options'
                },
            },
            
            -- Appearance options
            {
                backgroundOpacity = {
                    key = 'backgroundOpacity',
                    type = 'slider',
                    label = 'Background Opacity',
                    tooltip = 'Adjust the opacity of tooltip backgrounds',
                    min = 0.1,
                    max = 1.0,
                    step = 0.05,
                    column = 6,
                    order = 1,
                    initialValue = 0.9,
                    onChange = tooltipSettingChanged
                },
                borderColor = {
                    key = 'borderColor',
                    type = 'colorpicker',
                    label = 'Border Color',
                    tooltip = 'Set the color of tooltip borders',
                    column = 6,
                    order = 2,
                    initialValue = {r = 0.7, g = 0.7, b = 0.7, a = 1.0},
                    onChange = tooltipSettingChanged
                },
            },
            {
                healthBar = {
                    key = 'healthBar',
                    type = 'slider',
                    label = 'Health Bar Height',
                    tooltip = 'Set the height of the health bar',
                    min = 1,
                    max = 20,
                    step = 1,
                    column = 6,
                    order = 1,
                    initialValue = 7,
                    onChange = tooltipSettingChanged
                },
                powerBar = {
                    key = 'powerBar',
                    type = 'slider',
                    label = 'Power Bar Height',
                    tooltip = 'Set the height of the power bar',
                    min = 1,
                    max = 20,
                    step = 1,
                    column = 6,
                    order = 2,
                    initialValue = 7,
                    onChange = tooltipSettingChanged
                },
            },
            {
                backgroundColor = {
                    key = 'backgroundColor',
                    type = 'colorpicker',
                    label = 'Background Color',
                    tooltip = 'Set the background color of tooltips',
                    column = 12,
                    order = 1,
                    initialValue = {r = 0.1, g = 0.1, b = 0.1, a = 0.8}
                }
            },
            
            -- Information Display Header
            {
                infoHeader = {
                    type = 'header',
                    label = 'Information Display'
                },
            },
            
            -- First row of information options
            {
                targetOfTarget = {
                    key = 'targetOfTarget',
                    type = 'checkbox',
                    label = 'Target of Target',
                    tooltip = 'Show the target\'s target in tooltips',
                    column = 4,
                    initialValue = true,
                    order = 1
                },
                roleIcons = {
                    key = 'roleIcons',
                    type = 'checkbox',
                    label = 'Role Icons',
                    tooltip = 'Show role icons (tank, healer, DPS) in tooltips',
                    column = 4,
                    initialValue = true,
                    order = 2
                },
                whoTargeting = {
                    key = 'whoTargeting',
                    type = 'checkbox',
                    label = 'Show Who\'s Targeting',
                    tooltip = 'Show all players who are targeting this unit',
                    column = 4,
                    initialValue = true,
                    order = 3
                }
            },
            
            -- Second row of information options
            {
                showHealth = {
                    key = 'showHealth',
                    type = 'checkbox',
                    label = 'Health Text',
                    tooltip = 'Display health values in tooltips',
                    column = 4,
                    initialValue = true,
                    order = 1
                },
                showItemLevel = {
                    key = 'showItemLevel',
                    type = 'checkbox',
                    label = 'Item Level',
                    tooltip = 'Display player\'s item level in tooltips',
                    column = 4,
                    initialValue = true,
                    order = 2
                },
                showSpellID = {
                    key = 'showSpellID',
                    type = 'checkbox',
                    label = 'Spell IDs',
                    tooltip = 'Display spell IDs for abilities and effects',
                    column = 4,
                    initialValue = true,
                    order = 3
                }
            },
            
            -- Aura Information Header
            {
                auraHeader = {
                    type = 'header',
                    label = 'Aura Information'
                },
            },
            
            -- Aura display options
            {
                detailedAuras = {
                    key = 'detailedAuras',
                    type = 'checkbox',
                    label = 'Detailed Auras',
                    tooltip = 'Show expanded buff/debuff information',
                    column = 4,
                    initialValue = true,
                    order = 1
                },
                auraSource = {
                    key = 'auraSource',
                    type = 'checkbox',
                    label = 'Aura Source',
                    tooltip = 'Show who applied buffs/debuffs',
                    column = 4,
                    initialValue = true,
                    order = 2
                },
                auraDuration = {
                    key = 'auraDuration',
                    type = 'checkbox',
                    label = 'Aura Duration',
                    tooltip = 'Show buff/debuff duration',
                    column = 4,
                    initialValue = true,
                    order = 3
                }
            },
            
            -- Second row of aura options
            {
                auraType = {
                    key = 'auraType',
                    type = 'checkbox',
                    label = 'Aura Classification',
                    tooltip = 'Show type of aura (Magic/Curse/Disease/Poison)',
                    column = 4,
                    initialValue = true,
                    order = 1
                },
                auraIcons = {
                    key = 'auraIcons',
                    type = 'checkbox',
                    label = 'Aura Icons',
                    tooltip = 'Display icons next to aura names',
                    column = 4,
                    initialValue = true,
                    order = 2
                },
                colorCodeAuras = {
                    key = 'colorCodeAuras',
                    type = 'checkbox',
                    label = 'Color-Code Auras',
                    tooltip = 'Use colors to indicate aura types',
                    column = 4,
                    initialValue = true,
                    order = 3
                }
            },
            
            -- Advanced Settings Header
            {
                advancedHeader = {
                    type = 'header',
                    label = 'Advanced Options'
                },
            },
            
            -- Advanced options
            {
                scale = {
                    key = 'scale',
                    type = 'slider',
                    label = 'Tooltip Scale',
                    tooltip = 'Adjust the overall scale of tooltips',
                    min = 0.5,
                    max = 2.0,
                    step = 0.05,
                    column = 6,
                    order = 1,
                    initialValue = 1.0
                },
                fadeTime = {
                    key = 'fadeTime',
                    type = 'slider',
                    label = 'Fade Duration',
                    tooltip = 'Set how quickly tooltips fade in/out',
                    min = 0.1,
                    max = 1.0,
                    step = 0.05,
                    column = 6,
                    order = 2,
                    initialValue = 0.3
                }
            },
            
            -- Add an empty row with padding to ensure enough scroll space
            {
                bottomPadding = {
                    type = 'spacer',
                    height = 400,
                    column = 12,
                    order = 1
                }
            }
        },
    }
end

-- Add a refresh method to update controls with current values
function Layout:Refresh()
    -- Use the centralized refresh function if available
    if Phoenix_UI.CreateModuleRefreshFunction then
        -- Call the centralized refresh function
        Phoenix_UI:CreateModuleRefreshFunction("tooltip")(self)
    else
        -- Fallback implementation if the central function isn't available
        if not self.layout or not self.layout.rows then return end
        
        -- Get the config tabs
        local config = Phoenix_UI.UI
        if not config or not config.elements then return end
        
        -- Force the Tooltip tab to update with current database values
        local db = Phoenix_UI.db
        if db and db.profile and db.profile.tooltip then
            -- Update our local database reference
            self.layout.database = db.profile.tooltip
            
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
end
