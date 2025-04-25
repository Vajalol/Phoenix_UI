local Layout = Phoenix_UI:NewModule('Config.Layout.Actionbar')

-- Create a common change handler for actionbar settings to ensure they save properly
local function actionBarSettingChanged(element, value)
    -- Get the database
    local db = Phoenix_UI.db
    
    -- Store the value in the database
    if element.dataKey and db.profile.actionbars then
        -- Get the field name without the actionbars. prefix
        local fieldName = element.dataKey:gsub("^actionbars%.", "")
        
        -- Handle nested fields if needed
        if fieldName:find("%.") then
            local parts = {}
            for part in fieldName:gmatch("[^%.]+") do
                table.insert(parts, part)
            end
            
            -- Navigate to the right spot in the table
            local current = db.profile.actionbars
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
            db.profile.actionbars[fieldName] = value
        end
        
        -- Debug output
        if Phoenix_UI.debug then
            print("PHX-UI: ActionBar setting changed:", element.dataKey, "=", tostring(value))
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
            if not _G["Phoenix_UIDB"].profiles[currentProfile].actionbars then
                _G["Phoenix_UIDB"].profiles[currentProfile].actionbars = {}
            end
            
            -- Deep copy to ensure all changes are preserved
            _G["Phoenix_UIDB"].profiles[currentProfile].actionbars = CopyTable(db.profile.actionbars)
            _G["Phoenix_UIDB"].profiles[currentProfile].actionbars.__updated = GetTime()
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

    -- Layout
    Layout.layout = {
        layoutConfig = { 
            padding = { top = 15 },
            initialScrollOffset = 0  -- Ensure panel starts scrolled to the top
        },
        database = db.profile.actionbar,
        rows = {
            {
                header = {
                    type = 'header',
                    label = 'Buttons'
                },
            },
            {
                hotkeys = {
                    key = 'buttons.key',
                    type = 'checkbox',
                    label = 'Hotkeys Text',
                    tooltip = 'Show Hotkeys text',
                    column = 4,
                    order = 1
                },
                macros = {
                    key = 'buttons.macro',
                    type = 'checkbox',
                    label = 'Macro Text',
                    tooltip = 'Show Macro text',
                    column = 4,
                    order = 2
                },
                flash = {
                    key = 'buttons.flash',
                    type = 'checkbox',
                    label = 'Flash Animation',
                    tooltip = 'Flash spell-icon when pressing it',
                    column = 4,
                    order = 2
                }
            },
            {
                range = {
                    key = 'buttons.range',
                    type = 'checkbox',
                    label = 'Range Color',
                    tooltip = 'Show spell-color in red if out of range',
                    column = 4,
                    order = 1,
                    onChange = actionBarSettingChanged
                },
                size = {
                    key = 'buttons.size',
                    type = 'slider',
                    label = 'Text size',
                    max = 20,
                    initialValue = 12,
                    column = 4,
                    order = 1,
                    onChange = actionBarSettingChanged
                },
            },
            {
                header = {
                    type = 'header',
                    label = 'Animation Settings'
                },
            },
            {
                flashDuration = {
                    key = 'animation.flashDuration',
                    type = 'slider',
                    label = 'Flash Duration',
                    tooltip = 'Duration of flash animation in seconds',
                    min = 0.1,
                    max = 2.0,
                    step = 0.1,
                    initialValue = 0.5,
                    column = 4,
                    order = 1,
                    onChange = actionBarSettingChanged
                },
                flashIntensity = {
                    key = 'animation.flashIntensity',
                    type = 'slider',
                    label = 'Flash Intensity',
                    tooltip = 'Intensity of the flash effect',
                    min = 0.1,
                    max = 1.0,
                    step = 0.1,
                    initialValue = 0.7,
                    column = 4,
                    order = 2,
                    onChange = actionBarSettingChanged
                },
                flashColor = {
                    key = 'animation.flashColor',
                    type = 'dropdown',
                    label = 'Flash Color',
                    tooltip = 'The color of the flash animation',
                    column = 4,
                    order = 3,
                    onChange = actionBarSettingChanged,
                    options = {
                        { value = 'white', text = 'White' },
                        { value = 'class', text = 'Class Color' },
                        { value = 'spell', text = 'Spell Type Color' }
                    }
                }
            },
            {
                header = {
                    type = 'header',
                    label = 'Button Styling'
                },
            },
            {
                buttonBorder = {
                    key = 'style.buttonBorder',
                    type = 'dropdown',
                    label = 'Button Border',
                    tooltip = 'Style of button borders',
                    column = 4,
                    order = 1,
                    onChange = actionBarSettingChanged,
                    options = {
                        { value = 'default', text = 'Default' },
                        { value = 'thin', text = 'Thin' },
                        { value = 'thick', text = 'Thick' },
                        { value = 'none', text = 'None' }
                    }
                },
                glowEffect = {
                    key = 'style.glowEffect',
                    type = 'dropdown',
                    label = 'Glow Effect',
                    tooltip = 'Glow effect on usable abilities',
                    column = 4,
                    order = 2,
                    onChange = actionBarSettingChanged,
                    options = {
                        { value = 'default', text = 'Default' },
                        { value = 'pixel', text = 'Pixel Glow' },
                        { value = 'auto', text = 'Auto Cast Glow' },
                        { value = 'none', text = 'None' }
                    }
                },
                borderColor = {
                    key = 'style.borderColor',
                    type = 'dropdown',
                    label = 'Border Color',
                    tooltip = 'Color of button borders',
                    column = 4,
                    order = 3,
                    onChange = actionBarSettingChanged,
                    options = {
                        { value = 'default', text = 'Default' },
                        { value = 'class', text = 'Class Color' },
                        { value = 'custom', text = 'Custom' }
                    }
                }
            },
            {
                header = {
                    type = 'header',
                    label = 'Bar Padding & Spacing'
                },
            },
            {
                globalPadding = {
                    key = 'padding.global',
                    type = 'slider',
                    label = 'Global Padding',
                    tooltip = 'Default padding for all action bars',
                    min = 0,
                    max = 20,
                    step = 1,
                    initialValue = 2,
                    column = 4,
                    order = 1,
                    onChange = actionBarSettingChanged
                },
                buttonSpacing = {
                    key = 'padding.buttonSpacing',
                    type = 'slider',
                    label = 'Button Spacing',
                    tooltip = 'Space between action buttons',
                    min = 0,
                    max = 10,
                    step = 1,
                    initialValue = 2,
                    column = 4,
                    order = 2,
                    onChange = actionBarSettingChanged
                }
            },
            {
                bagbar = {
                    key = 'menu.bagbar',
                    type = 'dropdown',
                    label = 'Bag Buttons',
                    column = 4,
                    order = 2,
                    options = {
                        { value = 'show', text = 'Show' },
                        { value = 'mouse_over', text = 'Show on Mouseover' },
                        { value = 'hide', text = 'Hide' }
                    }
                },
                micromenu = {
                    key = 'menu.micromenu',
                    type = 'dropdown',
                    label = 'MicroMenu',
                    column = 4,
                    order = 3,
                    options = {
                        { value = 'show', text = 'Show' },
                        { value = 'mouse_over', text = 'Show on Mouseover' },
                        { value = 'hide', text = 'Hide' }
                    },
                }
            },
            {
                header = {
                    type = 'header',
                    label = 'Show on Mouseover'
                },
            },
            {
                actionbar1 = {
                    key = 'bars.bar1',
                    type = 'checkbox',
                    label = 'Bar 1',
                    column = 3,
                    order = 1,
                    onChange = actionBarSettingChanged
                },
                actionbar2 = {
                    key = 'bars.bar2',
                    type = 'checkbox',
                    label = 'Bar 2',
                    column = 3,
                    order = 2,
                    onChange = actionBarSettingChanged
                },
                actionbar3 = {
                    key = 'bars.bar3',
                    type = 'checkbox',
                    label = 'Bar 3',
                    column = 3,
                    order = 3,
                    onChange = actionBarSettingChanged
                },
                actionbar4 = {
                    key = 'bars.bar4',
                    type = 'checkbox',
                    label = 'Bar 4',
                    column = 3,
                    order = 4,
                    onChange = actionBarSettingChanged
                }
            },
            {
                actionbar5 = {
                    key = 'bars.bar5',
                    type = 'checkbox',
                    label = 'Bar 5',
                    column = 3,
                    order = 1,
                    onChange = actionBarSettingChanged
                },
                actionbar6 = {
                    key = 'bars.bar6',
                    type = 'checkbox',
                    label = 'Bar 6',
                    column = 3,
                    order = 2,
                    onChange = actionBarSettingChanged
                },
                actionbar7 = {
                    key = 'bars.bar7',
                    type = 'checkbox',
                    label = 'Bar 7',
                    column = 3,
                    order = 3,
                    onChange = actionBarSettingChanged
                },
                actionbar8 = {
                    key = 'bars.bar8',
                    type = 'checkbox',
                    label = 'Bar 8',
                    column = 3,
                    order = 4,
                    onChange = actionBarSettingChanged
                }
            },
            {
                petbar = {
                    key = 'bars.petbar',
                    type = 'checkbox',
                    label = 'Pet Bar',
                    column = 3,
                    order = 1
                },
                stancebar = {
                    key = 'bars.stancebar',
                    type = 'checkbox',
                    label = 'Stance Bar',
                    column = 3,
                    order = 2
                },
            },
            {
                header = {
                    type = 'header',
                    label = 'Individual Bar Padding'
                },
            },
            {
                bar1Padding = {
                    key = 'barPadding.bar1',
                    type = 'slider',
                    label = 'Bar 1 Padding',
                    min = 0,
                    max = 20,
                    step = 1,
                    initialValue = 2,
                    column = 3,
                    order = 1
                },
                bar2Padding = {
                    key = 'barPadding.bar2',
                    type = 'slider',
                    label = 'Bar 2 Padding',
                    min = 0,
                    max = 20,
                    step = 1,
                    initialValue = 2,
                    column = 3,
                    order = 2
                },
                bar3Padding = {
                    key = 'barPadding.bar3',
                    type = 'slider',
                    label = 'Bar 3 Padding',
                    min = 0,
                    max = 20,
                    step = 1,
                    initialValue = 2,
                    column = 3,
                    order = 3
                }
            },
            {
                bar4Padding = {
                    key = 'barPadding.bar4',
                    type = 'slider',
                    label = 'Bar 4 Padding',
                    min = 0,
                    max = 20,
                    step = 1,
                    initialValue = 2,
                    column = 3,
                    order = 1
                },
                bar5Padding = {
                    key = 'barPadding.bar5',
                    type = 'slider',
                    label = 'Bar 5 Padding',
                    min = 0,
                    max = 20,
                    step = 1,
                    initialValue = 2,
                    column = 3,
                    order = 2
                },
                petbarPadding = {
                    key = 'barPadding.petbar',
                    type = 'slider',
                    label = 'Pet Bar Padding',
                    min = 0,
                    max = 20,
                    step = 1,
                    initialValue = 2,
                    column = 3,
                    order = 3
                }
            },
            -- Add an empty row with padding to ensure enough scroll space
            {
                bottomPadding = {
                    type = 'spacer',
                    height = 500,
                    column = 12,
                    order = 1
                }
            }
        }
    }
end

-- Add a refresh method to update controls with current values
function Layout:Refresh()
    if not self.layout or not self.layout.rows then return end
    
    -- Get the config tabs
    local config = Phoenix_UI.UI
    if not config or not config.elements then return end
    
    -- Force the ActionBar tab to update with current database values
    local db = Phoenix_UI.db
    if db and db.profile and db.profile.actionbars then
        -- Update our local database reference
        self.layout.database = db.profile.actionbars
        
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
