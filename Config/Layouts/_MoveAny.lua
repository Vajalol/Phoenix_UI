local Layout = Phoenix_UI:NewModule('Config.Layout.MoveAny')

function Layout:OnEnable()
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

    -- Create layout for the MoveAny module
    Layout.layout = {
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
                                            -- If integration disabled, use original function
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
                    label = 'MoveAny Settings',
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
                        if IsMoveAnyLoaded() and MoveAny.MAGV then
                            return MoveAny:MAGV("SHOWMINIMAPBUTTON", true)
                        end
                        return true
                    end,
                    set = function(value)
                        if IsMoveAnyLoaded() and MoveAny.MASV then
                            MoveAny:MASV("SHOWMINIMAPBUTTON", value)
                            -- Update minimap button visibility
                            if MoveAny.minimapButton then
                                if value then
                                    MoveAny.minimapButton:Show()
                                else
                                    MoveAny.minimapButton:Hide()
                                end
                            end
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
                        if IsMoveAnyLoaded() and MoveAny.MAGV then
                            return MoveAny:MAGV("SHOWTIPS", true)
                        end
                        return true
                    end,
                    set = function(value)
                        if IsMoveAnyLoaded() and MoveAny.MASV then
                            MoveAny:MASV("SHOWTIPS", value)
                        end
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
                        if IsMoveAnyLoaded() and MoveAny.MAGV then
                            return MoveAny:MAGV("GRIDSIZE", 10)
                        end
                        return 10
                    end,
                    set = function(value)
                        if IsMoveAnyLoaded() and MoveAny.MASV then
                            MoveAny:MASV("GRIDSIZE", value)
                        end
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
                        if IsMoveAnyLoaded() and MoveAny.MAGV then
                            return MoveAny:MAGV("SNAPSIZE", 2)
                        end
                        return 2
                    end,
                    set = function(value)
                        if IsMoveAnyLoaded() and MoveAny.MASV then
                            MoveAny:MASV("SNAPSIZE", value)
                        end
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
                        if IsMoveAnyLoaded() and MoveAny.MAGV then
                            return MoveAny:MAGV("DISABLEMOVEMENT", false)
                        end
                        return false
                    end,
                    set = function(value)
                        if IsMoveAnyLoaded() and MoveAny.MASV then
                            MoveAny:MASV("DISABLEMOVEMENT", value)
                        end
                    end,
                    disabled = function() return not IsMoveAnyLoaded() end,
                    column = 12,
                    order = 9
                }
            },
            {
                divider4 = {
                    type = 'divider',
                    column = 12
                }
            },
            {
                openMoveAny = {
                    type = 'button',
                    text = 'Open MoveAny Panel',
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
                    column = 12,
                    order = 10
                }
            }
        }
    }
end 