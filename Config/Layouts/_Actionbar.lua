local Layout = Phoenix_UI:NewModule('Config.Layout.Actionbar')

function Layout:OnEnable()
    -- Database
    local db = Phoenix_UI.db

    -- Layout
    Layout.layout = {
        layoutConfig = { padding = { top = 15 } },
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
                    order = 1
                },
                size = {
                    key = 'buttons.size',
                    type = 'slider',
                    label = 'Text size',
                    max = 20,
                    initialValue = 12,
                    column = 4,
                    order = 1
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
                    order = 1
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
                    order = 2
                },
                flashColor = {
                    key = 'animation.flashColor',
                    type = 'dropdown',
                    label = 'Flash Color',
                    tooltip = 'The color of the flash animation',
                    column = 4,
                    order = 3,
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
                    order = 1
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
                    order = 2
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
                    order = 1
                },
                actionbar2 = {
                    key = 'bars.bar2',
                    type = 'checkbox',
                    label = 'Bar 2',
                    column = 3,
                    order = 2
                },
                actionbar3 = {
                    key = 'bars.bar3',
                    type = 'checkbox',
                    label = 'Bar 3',
                    column = 3,
                    order = 3
                },
                actionbar4 = {
                    key = 'bars.bar4',
                    type = 'checkbox',
                    label = 'Bar 4',
                    column = 3,
                    order = 4
                }
            },
            {
                actionbar5 = {
                    key = 'bars.bar5',
                    type = 'checkbox',
                    label = 'Bar 5',
                    column = 3,
                    order = 1
                },
                actionbar6 = {
                    key = 'bars.bar6',
                    type = 'checkbox',
                    label = 'Bar 6',
                    column = 3,
                    order = 2
                },
                actionbar7 = {
                    key = 'bars.bar7',
                    type = 'checkbox',
                    label = 'Bar 7',
                    column = 3,
                    order = 3
                },
                actionbar8 = {
                    key = 'bars.bar8',
                    type = 'checkbox',
                    label = 'Bar 8',
                    column = 3,
                    order = 4
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
            }
        }
    }
end
