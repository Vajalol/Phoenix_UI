local Layout = Phoenix_UI:NewModule('Config.Layout.Tooltip')

-- Create a dedicated tooltip settings change handler
local function tooltipSettingChanged(element, value)
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
        
        -- Get the Tooltip module
        local tooltipModule = Phoenix_UI:GetModule("Tooltip.Core", true)
        
        -- Update tooltip settings immediately
        if tooltipModule then
            if tooltipModule.UpdateSettings then
                tooltipModule:UpdateSettings()
            end
            
            -- Force a tooltip refresh if needed
            if GameTooltip:IsShown() then
                GameTooltip:Hide()
                GameTooltip:Show()
            end
        end
        
        -- Trigger config changed event
        Phoenix_UI:SendMessage("PHOENIX_UI_CONFIG_CHANGED", "tooltip")
        
        -- Force an immediate save
        if Phoenix_UI.SaveDB then
            Phoenix_UI:SaveDB()
        end
        
        -- Ensure settings are written to disk
        if FlushSavedVariables then
            FlushSavedVariables()
        end
    end
end

function Layout:OnEnable()
    -- Database
    local db = Phoenix_UI.db

    -- Ensure tooltip settings exist
    if not db.profile.tooltip then
        db.profile.tooltip = {
            mouseanchor = false,
            hideincombat = false,
            healthBarTop = false,
            targetOfTarget = true,
            roleIcons = true,
            whoTargeting = true,
            showHealth = true,
            showItemLevel = true,
            spellIDs = false,
            showAFK = true,
            showDND = true,
            showPVP = true,
            showRaidIcon = true,
            showGuild = true,
            showRealm = true,
            cacheTooltips = true,
            updateFrequency = 0.5
        }
    end

    -- Layout
    Layout.layout = {
        layoutConfig = { padding = { top = 15 } },
        database = db.profile.tooltip,
        rows = {
            {
                header = {
                    type = 'header',
                    label = 'Tooltip Configuration'
                }
            },
            {
                description = {
                    type = 'description',
                    text = 'Configure how tooltips are displayed and what information they show.',
                    column = 12,
                    order = 1
                }
            },
            {
                divider1 = {
                    type = 'divider',
                    column = 12,
                    order = 2
                }
            },
            {
                mouseanchor = {
                    key = 'mouseanchor',
                    type = 'checkbox',
                    label = 'Anchor to Mouse',
                    tooltip = 'Attach tooltip to mouse cursor position',
                    column = 4,
                    order = 3,
                    onChange = tooltipSettingChanged
                },
                hideincombat = {
                    key = 'hideincombat',
                    type = 'checkbox',
                    label = 'Hide in Combat',
                    tooltip = 'Hide tooltips while in combat',
                    column = 4,
                    order = 4,
                    onChange = tooltipSettingChanged
                },
                healthBarTop = {
                    key = 'healthBarTop',
                    type = 'checkbox',
                    label = 'Health Bar on Top',
                    tooltip = 'Show health bar at the top of tooltips',
                    column = 4,
                    order = 5,
                    onChange = tooltipSettingChanged
                }
            },
            {
                targetOfTarget = {
                    key = 'targetOfTarget',
                    type = 'checkbox',
                    label = 'Target of Target',
                    tooltip = 'Show the target\'s target in tooltips',
                    column = 4,
                    order = 6,
                    onChange = tooltipSettingChanged
                },
                roleIcons = {
                    key = 'roleIcons',
                    type = 'checkbox',
                    label = 'Role Icons',
                    tooltip = 'Show role icons in tooltips',
                    column = 4,
                    order = 7,
                    onChange = tooltipSettingChanged
                },
                whoTargeting = {
                    key = 'whoTargeting',
                    type = 'checkbox',
                    label = 'Show Who\'s Targeting',
                    tooltip = 'Show who is targeting this unit',
                    column = 4,
                    order = 8,
                    onChange = tooltipSettingChanged
                }
            },
            {
                healthText = {
                    key = 'showHealth',
                    type = 'checkbox',
                    label = 'Health Text',
                    tooltip = 'Show health information in tooltips',
                    column = 4,
                    order = 9,
                    onChange = tooltipSettingChanged
                },
                itemLevel = {
                    key = 'showItemLevel',
                    type = 'checkbox',
                    label = 'Item Level',
                    tooltip = 'Show item level for players',
                    column = 4,
                    order = 10,
                    onChange = tooltipSettingChanged
                },
                spellIDs = {
                    key = 'spellIDs',
                    type = 'checkbox',
                    label = 'Spell IDs',
                    tooltip = 'Show spell IDs in tooltips',
                    column = 4,
                    order = 11,
                    onChange = tooltipSettingChanged
                }
            },
            {
                divider2 = {
                    type = 'divider',
                    column = 12,
                    order = 12
                }
            },
            {
                header2 = {
                    type = 'header',
                    label = 'Advanced Settings',
                    column = 12,
                    order = 13
                }
            },
            {
                showAFK = {
                    key = 'showAFK',
                    type = 'checkbox',
                    label = 'Show AFK Status',
                    tooltip = 'Show AFK status in tooltips',
                    column = 4,
                    order = 14,
                    onChange = tooltipSettingChanged
                },
                showDND = {
                    key = 'showDND',
                    type = 'checkbox',
                    label = 'Show DND Status',
                    tooltip = 'Show Do Not Disturb status in tooltips',
                    column = 4,
                    order = 15,
                    onChange = tooltipSettingChanged
                },
                showPVP = {
                    key = 'showPVP',
                    type = 'checkbox',
                    label = 'Show PvP Status',
                    tooltip = 'Show PvP status in tooltips',
                    column = 4,
                    order = 16,
                    onChange = tooltipSettingChanged
                }
            },
            {
                showRaidIcon = {
                    key = 'showRaidIcon',
                    type = 'checkbox',
                    label = 'Show Raid Icon',
                    tooltip = 'Show raid target icon in tooltips',
                    column = 4,
                    order = 17,
                    onChange = tooltipSettingChanged
                },
                showGuild = {
                    key = 'showGuild',
                    type = 'checkbox',
                    label = 'Show Guild',
                    tooltip = 'Show guild information in tooltips',
                    column = 4,
                    order = 18,
                    onChange = tooltipSettingChanged
                },
                showRealm = {
                    key = 'showRealm',
                    type = 'checkbox',
                    label = 'Show Realm',
                    tooltip = 'Show realm information in tooltips',
                    column = 4,
                    order = 19,
                    onChange = tooltipSettingChanged
                }
            },
            {
                divider3 = {
                    type = 'divider',
                    column = 12,
                    order = 20
                }
            },
            {
                header3 = {
                    type = 'header',
                    label = 'Performance Settings',
                    column = 12,
                    order = 21
                }
            },
            {
                cacheTooltips = {
                    key = 'cacheTooltips',
                    type = 'checkbox',
                    label = 'Cache Tooltips',
                    tooltip = 'Cache tooltip data to improve performance',
                    column = 4,
                    order = 22,
                    onChange = tooltipSettingChanged
                },
                updateFrequency = {
                    key = 'updateFrequency',
                    type = 'slider',
                    label = 'Update Frequency',
                    tooltip = 'How often tooltips update (in seconds)',
                    min = 0.1,
                    max = 1.0,
                    step = 0.1,
                    column = 8,
                    order = 23,
                    onChange = tooltipSettingChanged
                }
            }
        }
    }
    
    -- Register the layout
    Phoenix_UI.layouts.Tooltip = Layout.layout
    
    -- Get the Tooltip module
    local TooltipModule = Phoenix_UI:GetModule("Tooltip.Core", true)
    
    -- Connect the layout to the module
    if TooltipModule then
        TooltipModule.layout = Layout.layout
        if TooltipModule.OnLayoutRegistered then
            TooltipModule:OnLayoutRegistered(Layout.layout)
        end
        
        -- Register for profile changes
        db.RegisterCallback(self, "OnProfileChanged", "RefreshSettings")
        db.RegisterCallback(self, "OnProfileCopied", "RefreshSettings")
        db.RegisterCallback(self, "OnProfileReset", "RefreshSettings")
    end
end

-- Add a refresh method to update controls with current values
function Layout:RefreshSettings()
    -- Get the Tooltip module
    local tooltipModule = Phoenix_UI:GetModule("Tooltip.Core", true)
    
    if tooltipModule then
        -- Update module settings
        if tooltipModule.UpdateSettings then
            tooltipModule:UpdateSettings()
        end
        
        -- Force a tooltip refresh if needed
        if GameTooltip:IsShown() then
            GameTooltip:Hide()
            GameTooltip:Show()
        end
    end
    
    -- Force save to disk
    if Phoenix_UI.SaveDB then
        Phoenix_UI:SaveDB()
    end
    
    -- Ensure settings are written to disk
    if FlushSavedVariables then
        FlushSavedVariables()
    end
end
