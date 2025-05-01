local Layout = Phoenix_UI:NewModule('Config.Layout.MoveAny')

function Layout:OnEnable()
    if not Phoenix_UI.layouts then
        Phoenix_UI.layouts = {}
    end
    
    -- Helper function to check if MoveAny is loaded
    local function IsMoveAnyLoaded()
        return _G.MoveAny ~= nil
    end

    -- Helper function to get MoveAny settings
    local function GetMoveAnySettings()
        if not IsMoveAnyLoaded() then
            return nil
        end
        
        return _G.MoveAny.db
    end

    -- Helper to check if Phoenix_UI has MoveAny integration enabled
    local function IsIntegrationEnabled()
        local db = Phoenix_UI.db
        return db and db.profile and db.profile.general and db.profile.general.enableMoveAnyIntegration
    end
    
    -- Helper to safely get MoveAny setting values
    local function GetMAValue(key, default)
        if not IsMoveAnyLoaded() or not MoveAny.MAGV then
            return default
        end
        return MoveAny:MAGV(key, default)
    end
    
    -- Helper to safely set MoveAny setting values
    local function SetMAValue(key, value)
        if not IsMoveAnyLoaded() or not MoveAny.MASV then
            return
        end
        MoveAny:MASV(key, value)
    end
    
    -- Helper to create a MoveAny category header
    local function CreateCategoryHeader(label, order)
        return {
            header = {
                type = 'header',
                label = label,
                column = 12,
                order = order
            }
        }
    end

    -- Create layout for the MoveAny module
    local layout = {
        layoutConfig = { padding = { top = 15 } },
        rows = {
            {
                header = {
                    type = 'header',
                    label = 'MoveAny Panel'
                }
            },
            {
                description = {
                    type = 'description',
                    text = 'MoveAny allows you to move and scale any UI element in the game. Configure MoveAny settings here.',
                    column = 12
                }
            },
            {
                divider = {
                    type = 'divider',
                    column = 12
                }
            },
            {
                moduleStatus = {
                    type = 'description',
                    text = function()
                        if IsMoveAnyLoaded() then
                            return "MoveAny is |cFF00FF00loaded and active|r."
                        else
                            return "MoveAny is |cFFFF0000not loaded|r. Make sure it's enabled in your addon list."
                        end
                    end,
                    column = 12,
                    order = 1
                }
            },
            {
                divider2 = {
                    type = 'divider',
                    column = 12
                }
            },
            {
                header2 = {
                    type = 'header',
                    label = 'Integration Settings',
                    column = 12,
                    order = 2
                }
            },
            {
                enableIntegration = {
                    type = 'checkbox',
                    label = 'Enable MoveAny Integration',
                    tooltip = 'Enable integration between Phoenix UI and MoveAny',
                    get = function()
                        return IsIntegrationEnabled()
                    end,
                    set = function(value)
                        if Phoenix_UI.db and Phoenix_UI.db.profile and Phoenix_UI.db.profile.general then
                            Phoenix_UI.db.profile.general.enableMoveAnyIntegration = value
                            
                            -- Refresh the integration if MoveAny is loaded
                            if IsMoveAnyLoaded() and value then
                                -- Re-hook functions if needed
                                if MoveAny.ShowMainFrame and not MoveAny._originalShowMainFrame then
                                    MoveAny._originalShowMainFrame = MoveAny.ShowMainFrame
                                    
                                    -- Replace with navigation to the appropriate tab
                                    MoveAny.ShowMainFrame = function()
                                        -- Only override if Phoenix_UI integration is enabled
                                        if IsIntegrationEnabled() then
                                            if Phoenix_UI.Config then
                                                Phoenix_UI:Config(false)
                                                -- Try to select the MoveAny tab
                                                if Phoenix_UI.UI and Phoenix_UI.UI.SelectTab then
                                                    Phoenix_UI.UI:SelectTab("MoveAny")
                                                end
                                            end
                                        else
                                            -- If integration is disabled, call the original function
                                            if MoveAny._originalShowMainFrame then
                                                MoveAny._originalShowMainFrame()
                                            end
                                        end
                                    end
                                end
                            elseif IsMoveAnyLoaded() and not value then
                                -- Restore original function if integration is disabled
                                if MoveAny._originalShowMainFrame then
                                    MoveAny.ShowMainFrame = MoveAny._originalShowMainFrame
                                    MoveAny._originalShowMainFrame = nil
                                end
                            end
                        end
                    end,
                    disabled = function() return not IsMoveAnyLoaded() end,
                    column = 12,
                    order = 3
                }
            },
            {
                divider3 = {
                    type = 'divider',
                    column = 12
                }
            },
            {
                header3 = {
                    type = 'header',
                    label = 'General Settings',
                    column = 12,
                    order = 4
                }
            },
            {
                showMinimapButton = {
                    type = 'checkbox',
                    label = 'Show Minimap Button',
                    tooltip = 'Show or hide the MoveAny minimap button',
                    get = function()
                        return GetMAValue("MINIMAPBUTTON", true)
                    end,
                    set = function(value)
                        SetMAValue("MINIMAPBUTTON", value)
                        
                        -- Update minimap button visibility immediately
                        if IsMoveAnyLoaded() and MoveAny.InitMinimap then
                            MoveAny:InitMinimap()
                        end
                    end,
                    disabled = function() return not IsMoveAnyLoaded() end,
                    column = 6,
                    order = 5
                },
                showTips = {
                    type = 'checkbox',
                    label = 'Show Tips',
                    tooltip = 'Show or hide MoveAny tips',
                    get = function()
                        return GetMAValue("SHOWTIPS", true)
                    end,
                    set = function(value)
                        SetMAValue("SHOWTIPS", value)
                    end,
                    disabled = function() return not IsMoveAnyLoaded() end,
                    column = 6,
                    order = 6
                }
            },
            {
                gridSize = {
                    type = 'slider',
                    label = 'Grid Size',
                    tooltip = 'Set the size of the movement grid',
                    initialValue = 10,
                    get = function()
                        return GetMAValue("GRIDSIZE", 10)
                    end,
                    set = function(value)
                        SetMAValue("GRIDSIZE", value)
                    end,
                    min = 1,
                    max = 50,
                    step = 1,
                    disabled = function() return not IsMoveAnyLoaded() end,
                    column = 6,
                    order = 7
                },
                snapSize = {
                    type = 'slider',
                    label = 'Snap Size',
                    tooltip = 'Set the snap size for the movement grid',
                    initialValue = 2,
                    get = function()
                        return GetMAValue("SNAPSIZE", 2)
                    end,
                    set = function(value)
                        SetMAValue("SNAPSIZE", value)
                    end,
                    min = 1,
                    max = 20,
                    step = 1,
                    disabled = function() return not IsMoveAnyLoaded() end,
                    column = 6,
                    order = 8
                }
            },
            {
                disableMovement = {
                    type = 'checkbox',
                    label = 'Disable Movement Keys in Edit Mode',
                    tooltip = 'Disable movement keyboard bindings when in MoveAny edit mode',
                    get = function()
                        return GetMAValue("DISABLEMOVEMENT", false)
                    end,
                    set = function(value)
                        SetMAValue("DISABLEMOVEMENT", value)
                    end,
                    disabled = function() return not IsMoveAnyLoaded() end,
                    column = 6,
                    order = 9
                },
                smartAnchors = {
                    type = 'checkbox',
                    label = 'Smart Anchors',
                    tooltip = 'Automatically suggest anchors when moving frames',
                    get = function()
                        return GetMAValue("SMARTANCHORS", true)
                    end,
                    set = function(value)
                        SetMAValue("SMARTANCHORS", value)
                    end,
                    disabled = function() return not IsMoveAnyLoaded() end,
                    column = 6,
                    order = 10
                }
            },
            {
                divider4 = {
                    type = 'divider',
                    column = 12
                }
            },
            {
                header4 = {
                    type = 'header',
                    label = 'Keyboard Shortcuts',
                    column = 12,
                    order = 11
                }
            },
            {
                keyDescription = {
                    type = 'description',
                    text = 'Configure which key modifiers are used to interact with frames',
                    column = 12
                }
            },
            {
                moveKey = {
                    type = 'dropdown',
                    label = 'Move Modifier Key',
                    tooltip = 'Key modifier to press while clicking and dragging to move frames',
                    get = function()
                        return GetMAValue("KEYBINDMOVE", 1)
                    end,
                    set = function(value)
                        SetMAValue("KEYBINDMOVE", value)
                    end,
                    options = {
                        [1] = "SHIFT",
                        [2] = "CTRL",
                        [3] = "ALT"
                    },
                    disabled = function() return not IsMoveAnyLoaded() end,
                    column = 4,
                    order = 12
                },
                scaleKey = {
                    type = 'dropdown',
                    label = 'Scale Modifier Key',
                    tooltip = 'Key modifier to press while clicking and dragging to scale frames',
                    get = function()
                        return GetMAValue("KEYBINDSCALE", 2)
                    end,
                    set = function(value)
                        SetMAValue("KEYBINDSCALE", value)
                    end,
                    options = {
                        [1] = "SHIFT",
                        [2] = "CTRL",
                        [3] = "ALT"
                    },
                    disabled = function() return not IsMoveAnyLoaded() end,
                    column = 4,
                    order = 13
                },
                windowKey = {
                    type = 'dropdown',
                    label = 'Config Window Key',
                    tooltip = 'Key modifier to press while clicking to open config for a frame',
                    get = function()
                        return GetMAValue("KEYBINDWINDOW", 1)
                    end,
                    set = function(value)
                        SetMAValue("KEYBINDWINDOW", value)
                    end,
                    options = {
                        [1] = "SHIFT",
                        [2] = "CTRL",
                        [3] = "ALT"
                    },
                    disabled = function() return not IsMoveAnyLoaded() end,
                    column = 4,
                    order = 14
                }
            },
            {
                divider5 = {
                    type = 'divider',
                    column = 12
                }
            },
            {
                header5 = {
                    type = 'header',
                    label = 'Default Frame Settings',
                    column = 12,
                    order = 15
                }
            },
            {
                defaultScale = {
                    type = 'slider',
                    label = 'Default Scale',
                    tooltip = 'Default scale for frames when first moved',
                    get = function()
                        return GetMAValue("DEFAULTSCALE", 1)
                    end,
                    set = function(value)
                        SetMAValue("DEFAULTSCALE", value)
                    end,
                    min = 0.1,
                    max = 3,
                    step = 0.1,
                    disabled = function() return not IsMoveAnyLoaded() end,
                    column = 6,
                    order = 16
                },
                defaultAlpha = {
                    type = 'slider',
                    label = 'Default Alpha',
                    tooltip = 'Default transparency for frames when first moved',
                    get = function()
                        return GetMAValue("DEFAULTALPHA", 1)
                    end,
                    set = function(value)
                        SetMAValue("DEFAULTALPHA", value)
                    end,
                    min = 0.1,
                    max = 1,
                    step = 0.1,
                    disabled = function() return not IsMoveAnyLoaded() end,
                    column = 6,
                    order = 17
                }
            },
            {
                divider6 = {
                    type = 'divider',
                    column = 12
                }
            },
            {
                header6 = {
                    type = 'header',
                    label = 'Advanced',
                    column = 12,
                    order = 18
                }
            },
            {
                enableActionBarFeatures = {
                    type = 'checkbox',
                    label = 'Action Bar Styling Features',
                    tooltip = 'Enable MoveAny action bar styling features (|cffFF0000Warning:|r Can cause conflicts with Phoenix UI action bars)',
                    get = function()
                        return GetMAValue("ENABLEACTIONBARSTYLING", false)
                    end,
                    set = function(value)
                        SetMAValue("ENABLEACTIONBARSTYLING", value)
                        -- Inform user about potential conflicts
                        if value then
                            print("|cffFF7D0APhoenix|r|cffFF0000_|r|cffFFD100UI|r: Warning - Enabling MoveAny action bar styling may conflict with Phoenix UI action bars and cause errors.")
                        end
                    end,
                    disabled = function() return not IsMoveAnyLoaded() end,
                    column = 12,
                    order = 19
                }
            },
            {
                divider7 = {
                    type = 'divider',
                    column = 12
                }
            },
            {
                resetHeader = {
                    type = 'header',
                    label = 'Reset Options',
                    column = 12,
                    order = 20
                }
            },
            {
                resetAll = {
                    type = 'button',
                    text = 'Reset All Frames',
                    tooltip = 'Reset all frame positions and settings',
                    onClick = function()
                        if IsMoveAnyLoaded() and MoveAny.ResetAllFrames then
                            MoveAny:ResetAllFrames()
                            print("|cffFF7D0APhoenix|r|cffFF0000_|r|cffFFD100UI|r: All MoveAny frames have been reset")
                        end
                    end,
                    disabled = function() return not IsMoveAnyLoaded() end,
                    column = 6,
                    style = {
                        textColor = { r = 1, g = 0, b = 0 }
                    },
                    order = 21
                },
                openMoveAny = {
                    type = 'button',
                    text = 'Open MoveAny Panel',
                    tooltip = 'Open the full MoveAny configuration panel for advanced options',
                    onClick = function()
                        if IsMoveAnyLoaded() then
                            if MoveAny.ShowMainFrame then
                                MoveAny:ShowMainFrame()
                            elseif MoveAny.ToggleGUI then
                                MoveAny:ToggleGUI()
                            else
                                print("|cffFF7D0APhoenix|r|cffFF0000_|r|cffFFD100UI|r: MoveAny function not found")
                            end
                        else
                            print("|cffFF7D0APhoenix|r|cffFF0000_|r|cffFFD100UI|r: MoveAny is not loaded")
                        end
                    end,
                    disabled = function() return not IsMoveAnyLoaded() end,
                    column = 6,
                    order = 22
                }
            }
        }
    }

    -- Register the layout
    Phoenix_UI.layouts.MoveAny = layout
    
    -- Get the MoveAny module
    local MoveAnyModule = Phoenix_UI:GetModule("MoveAny", true)
    
    -- Connect the layout to the module
    if MoveAnyModule then
        MoveAnyModule.layout = layout
        if MoveAnyModule.OnLayoutRegistered then
            MoveAnyModule:OnLayoutRegistered(layout)
        end
    end
end