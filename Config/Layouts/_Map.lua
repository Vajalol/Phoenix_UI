local Layout = Phoenix_UI:NewModule('Config.Layout.Map')

function Layout:OnEnable()
    -- Database
    local db = Phoenix_UI.db

    -- Layout
    Layout.layout = {
        layoutConfig = { padding = { top = 15 } },
        database = db.profile.maps,
        rows = {
            {
                header = {
                    type = 'header',
                    label = 'Worldmap'
                }
            },
            {
                opacity = {
                    key = 'opacity',
                    type = 'slider',
                    label = 'Opacity',
                    precision = 1,
                    min = 0.1,
                    max = 1,
                    initialValue = 0.9,
                    column = 4,
                    order = 1,
                    onChange = function(slider)
                        WorldMapFrame:SetAlpha(slider.value)
                    end,
                },
                cords = {
                    key = 'coords',
                    type = 'checkbox',
                    label = 'Coordinates',
                    tooltip = 'Display coordinates on map',
                    column = 4,
                    order = 2
                }
            },
            {
                header = {
                    type = 'header',
                    label = 'Minimap'
                }
            },
            {
                showminimap = {
                    key = 'minimap',
                    type = 'checkbox',
                    label = 'Show Minimap',
                    tooltip = 'Show/Hide minimap',
                    column = 4,
                    order = 1
                },
                showclock = {
                    key = 'clock',
                    type = 'checkbox',
                    label = 'Show Clock',
                    tooltip = 'Show/Hide clock on minimap',
                    column = 4,
                    order = 2
                },
                showdate = {
                    key = 'date',
                    type = 'checkbox',
                    label = 'Show Date',
                    tooltip = 'Show/Hide calendar icon on minimap',
                    column = 4,
                    order = 3
                }
            },
            {
                showtracking = {
                    key = 'tracking',
                    type = 'checkbox',
                    label = 'Tracking Symbol',
                    tooltip = 'Show/Hide tracking icon on minimap',
                    column = 4,
                    order = 1
                },
                buttons = {
                    key = 'buttons',
                    type = 'checkbox',
                    label = 'Buttons on Mouseover',
                    tooltip = 'Show minimap buttons on mouseover',
                    column = 4,
                    order = 2
                },
                expansionbutton = {
                    key = 'expansionbutton',
                    type = 'checkbox',
                    label = 'Expansion Button Mouseover',
                    tooltip = 'Show Expansion Button on mouseover',
                    column = 4,
                    order = 3
                }
            },
            {
                squareminimap = {
                    key = 'squareminimap',
                    type = 'checkbox',
                    label = 'Square Minimap',
                    tooltip = 'Use square style for minimap instead of circular',
                    column = 4,
                    order = 1
                },
                smoothfade = {
                    key = 'smoothfade',
                    type = 'checkbox',
                    label = 'Smooth Button Fade',
                    tooltip = 'Enable smooth fading for minimap buttons',
                    column = 4,
                    order = 2,
                    initialValue = true
                },
                fadeSpeed = {
                    key = 'fadespeed',
                    type = 'slider',
                    label = 'Fade Speed',
                    tooltip = 'Adjust the speed of button fading animations',
                    min = 0.1,
                    max = 1.0,
                    step = 0.1,
                    initialValue = 0.3,
                    column = 4,
                    order = 3
                }
            },
            {
                header = {
                    type = 'header',
                    label = 'Enhanced Features'
                }
            },
            {
                moveableminimap = {
                    key = 'moveableminimap',
                    type = 'checkbox',
                    label = 'Movable Minimap',
                    tooltip = 'Enable minimap position saving and easy movement',
                    column = 4,
                    order = 1,
                    initialValue = true,
                    onChange = function(widget)
                        -- Request reload if changing this setting
                        if Phoenix_UI and Phoenix_UI.RequestReload then
                            Phoenix_UI:RequestReload("Minimap position feature requires a UI reload to apply changes")
                        end
                    end
                },
                minimapLocked = {
                    key = 'minimapLocked',
                    type = 'checkbox',
                    label = 'Lock Minimap Position',
                    tooltip = 'Lock the minimap in its current position',
                    column = 4,
                    order = 2,
                    initialValue = true,
                    disabled = function()
                        return not db.profile.maps.moveableminimap
                    end
                },
                resetPosition = {
                    type = 'button',
                    label = 'Reset Position',
                    tooltip = 'Reset minimap to default position',
                    column = 4,
                    order = 3,
                    click = function()
                        -- Clear saved position data
                        if db.profile.maps.position then
                            db.profile.maps.position = nil
                            -- Request reload
                            if Phoenix_UI and Phoenix_UI.RequestReload then
                                Phoenix_UI:RequestReload("Minimap position has been reset. Reload UI to apply changes.")
                            end
                        end
                    end,
                    disabled = function()
                        return not db.profile.maps.moveableminimap or not db.profile.maps.position
                    end
                }
            },
            {
                minimapCoords = {
                    key = 'minimapCoords',
                    type = 'checkbox',
                    label = 'Show Minimap Coordinates',
                    tooltip = 'Display player coordinates on the minimap',
                    column = 4,
                    order = 1,
                    initialValue = true
                },
                minimapCoordsOnHover = {
                    key = 'minimapCoordsOnHover',
                    type = 'checkbox',
                    label = 'Fade Coordinates',
                    tooltip = 'Only show coordinates when mouse is over the minimap',
                    column = 4,
                    order = 2,
                    initialValue = false,
                    disabled = function()
                        return not db.profile.maps.minimapCoords
                    end
                },
                coordPrecision = {
                    key = 'coordPrecision',
                    type = 'slider',
                    label = 'Coordinate Precision',
                    tooltip = 'Number of decimal places to show in coordinates',
                    min = 0,
                    max = 2,
                    step = 1,
                    initialValue = 1,
                    column = 4,
                    order = 3,
                    disabled = function()
                        return not (db.profile.maps.minimapCoords or db.profile.maps.coords)
                    end
                }
            }
        },
    }
end



