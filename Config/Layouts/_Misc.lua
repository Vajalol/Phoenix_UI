local Layout = Phoenix_UI:NewModule('Config.Layout.Misc')

function Layout:OnEnable()
    -- Database
    local db = Phoenix_UI.db

    -- Components
    local CvarsBrowser
    -- Try with both naming conventions
    if Phoenix_UI:GetModule("Config.Components.CVarsBrowser", true) then
        CvarsBrowser = Phoenix_UI:GetModule("Config.Components.CVarsBrowser")
    elseif Phoenix_UI:GetModule("Config.Components._CVarsBrowser", true) then
        CvarsBrowser = Phoenix_UI:GetModule("Config.Components._CVarsBrowser")
    end

    -- Layout
    Layout.layout = {
        layoutConfig = { padding = { top = 15 } },
        database = db.profile.misc,
        rows = {
            {
                header = {
                    type = 'header',
                    label = 'Misc'
                }
            },
            {
                cvars = {
                    type = 'button',
                    text = 'CVars Browser',
                    onClick = function()
                        -- Only try to show if we found the module
                        if CvarsBrowser and CvarsBrowser.Show then
                            CvarsBrowser.Show()
                        else
                            print("|cffFF7D0APhoenix|r|cffFF0000_|r|cffFFD100UI|r: CVars Browser module not found")
                        end
                    end,
                    column = 3,
                    order = 3
                }
            },
            {
                header = {
                    type = 'header',
                    label = 'General'
                }
            },
            {
                interrupt = {
                    key = 'interrupt',
                    type = 'checkbox',
                    label = 'Interrupt',
                    tooltip = 'Announce successful interrupts party',
                    column = 3,
                    order = 1
                },
                menubutton = {
                    key = 'menubutton',
                    type = 'checkbox',
                    label = 'Menu Button',
                    tooltip = 'Show Phoenix_UI Button on ESC-Menu',
                    column = 3,
                    order = 2
                }
            },
            {
                header = {
                    type = 'header',
                    label = 'PvP'
                }
            },
            {
                safequeue = {
                    key = 'safequeue',
                    type = 'checkbox',
                    label = 'SafeQueue',
                    tooltip = 'Show time left to join and remove leave-button on queuepop-window',
                    column = 3,
                    order = 1
                },
                tabbinder = {
                    key = 'tabbinder',
                    type = 'checkbox',
                    label = 'Tab Binder',
                    tooltip = 'Only target players with TAB in PVP-Combat',
                    column = 3,
                    order = 1
                },
                dampening = {
                    key = 'dampening',
                    type = 'checkbox',
                    label = 'Dampening',
                    tooltip = 'Shows dampening right below the arena timer',
                    column = 3,
                    order = 1
                },
                surrender = {
                    key = 'surrender',
                    type = 'checkbox',
                    label = 'Surrender',
                    tooltip = 'Allows you to surrender by typing /gg',
                    column = 3,
                    order = 1
                },
            },
            {
                losecontrol = {
                    key = 'losecontrol',
                    type = 'checkbox',
                    label = 'LoseControl',
                    tooltip = 'More transparent Loss of Control Alert frame',
                    column = 3,
                    order = 1
                },
            },
            {
                header = {
                    type = 'header',
                    label = 'Hide Frames'
                },
            },
            {
                repbar = {
                    key = 'repbar',
                    type = 'checkbox',
                    label = 'XP/Rep/Honor Bar',
                    tooltip = 'Hide the XP/Rep/Honor Bar',
                    column = 4,
                    order = 1
                },
                dragonflying = {
                    key = 'dragonflying',
                    type = 'checkbox',
                    label = 'Dragonflying Wings',
                    tooltip = 'Hide the Dragonflying Bar Wings',
                    column = 4,
                    order = 2
                },
            }
        },
    }
end



