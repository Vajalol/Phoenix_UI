local Layout = Phoenix_UI:NewModule('Config.Layout.Tooltip')

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
                    order = 1
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
                    order = 1
                },
                lifeontop = {
                    key = 'lifeontop',
                    type = 'checkbox',
                    label = 'Health Bar on Top',
                    tooltip = 'Show health bar at the top of tooltips',
                    column = 4,
                    order = 2
                },
                hideincombat = {
                    key = 'hideincombat',
                    type = 'checkbox',
                    tooltip = 'Hide tooltips while in combat',
                    label = 'Hide in Combat',
                    column = 4,
                    order = 3
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
                    initialValue = 0.9
                },
                borderColor = {
                    key = 'borderColor',
                    type = 'colorpicker',
                    label = 'Border Color',
                    tooltip = 'Set the color of tooltip borders',
                    column = 6,
                    order = 2,
                    initialValue = {r = 0.7, g = 0.7, b = 0.7, a = 1.0}
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
                    initialValue = 7
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
                    initialValue = 7
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
