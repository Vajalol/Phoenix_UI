local Layout = Phoenix_UI:NewModule('Config.Layout.RaidFrames')

function Layout:OnEnable()
    -- Helper function to get module
    local function GetRaidFrames()
        return Phoenix_UI:GetModule("RaidFrames", true)
    end

    -- Helper function to check if module is available
    local function IsRaidFramesLoaded()
        return GetRaidFrames() ~= nil
    end

    -- Create layout for the RaidFrames module
    Layout.layout = {
        layoutConfig = { padding = { top = 15 } },
        rows = {
            {
                header = {
                    type = 'header',
                    label = 'Raid Frames'
                }
            },
            {
                description = {
                    type = 'description',
                    text = 'Configure your raid and party frames appearance and functionality.',
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
                        if IsRaidFramesLoaded() then
                            return "RaidFrames module is |cFF00FF00loaded and active|r."
                        else
                            return "RaidFrames module is |cFFFF0000not loaded|r. Make sure it's enabled."
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
                    label = 'General Settings',
                    column = 12,
                    order = 2
                }
            },
            {
                enableModule = {
                    type = 'checkbox',
                    label = 'Enable Raid Frames Module',
                    get = function()
                        local db = Phoenix_UI.db.profile
                        return db and db.general and db.general.raidframes
                    end,
                    set = function(value)
                        local db = Phoenix_UI.db.profile
                        if db and db.general then
                            db.general.raidframes = value
                            
                            -- Toggle module if available
                            local module = GetRaidFrames()
                            if module then
                                if value then
                                    module:Enable()
                                else
                                    module:Disable()
                                end
                            end
                            
                            -- Force UI reload to apply changes
                            StaticPopupDialogs["PHOENIX_UI_RELOAD"] = {
                                text = "Changes to raid frames require a UI reload to take effect. Reload UI now?",
                                button1 = "Yes",
                                button2 = "No",
                                OnAccept = function() ReloadUI() end,
                                timeout = 0,
                                whileDead = true,
                                hideOnEscape = true,
                                preferredIndex = 3,
                            }
                            StaticPopup_Show("PHOENIX_UI_RELOAD")
                        end
                    end,
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
                    label = 'Frame Appearance',
                    column = 12,
                    order = 4
                }
            },
            {
                texture = {
                    type = 'dropdown',
                    label = 'Health Bar Texture',
                    tooltip = 'Choose the texture for health bars in raid frames',
                    get = function()
                        local db = Phoenix_UI.db.profile
                        if db and db.raidframes and db.raidframes.texture then
                            return db.raidframes.texture
                        end
                        return "Blizzard"
                    end,
                    set = function(value)
                        local db = Phoenix_UI.db.profile
                        if db and not db.raidframes then
                            db.raidframes = {}
                        end
                        if db and db.raidframes then
                            db.raidframes.texture = value
                            
                            -- Update frames if module is active
                            local module = GetRaidFrames()
                            if module and module.UpdateFrameTextures then
                                module:UpdateFrameTextures()
                            end
                        end
                    end,
                    options = {
                        { text = "Blizzard", value = "Blizzard" },
                        { text = "Flat", value = "Flat" },
                        { text = "Gloss", value = "Gloss" },
                        { text = "Phoenix_UI Flat", value = "Phoenix_UI Flat" }
                    },
                    column = 6,
                    order = 5
                },
                scale = {
                    type = 'slider',
                    label = 'Frame Scale',
                    tooltip = 'Set the scale of the raid frames',
                    get = function()
                        local db = Phoenix_UI.db.profile
                        if db and db.raidframes and db.raidframes.scale then
                            return db.raidframes.scale
                        end
                        return 1.0
                    end,
                    set = function(value)
                        local db = Phoenix_UI.db.profile
                        if db and not db.raidframes then
                            db.raidframes = {}
                        end
                        if db and db.raidframes then
                            db.raidframes.scale = value
                            
                            -- Update frames if module is active
                            local module = GetRaidFrames()
                            if module and module.UpdateFrameScale then
                                module:UpdateFrameScale()
                            end
                        end
                    end,
                    min = 0.5,
                    max = 2.0,
                    step = 0.05,
                    column = 6,
                    order = 6
                }
            },
            {
                frameWidth = {
                    type = 'slider',
                    label = 'Frame Width',
                    tooltip = 'Set the width of individual raid frames',
                    initialValue = 100,
                    get = function()
                        local db = Phoenix_UI.db.profile
                        if db and db.raidframes and db.raidframes.width then
                            return db.raidframes.width
                        end
                        return 100
                    end,
                    set = function(value)
                        local db = Phoenix_UI.db.profile
                        if db and not db.raidframes then
                            db.raidframes = {}
                        end
                        if db and db.raidframes then
                            db.raidframes.width = value
                            
                            -- Update frames if module is active
                            local module = GetRaidFrames()
                            if module and module.UpdateFrameDimensions then
                                module:UpdateFrameDimensions()
                            end
                        end
                    end,
                    min = 50,
                    max = 200,
                    step = 5,
                    column = 6,
                    order = 7
                },
                frameHeight = {
                    type = 'slider',
                    label = 'Frame Height',
                    tooltip = 'Set the height of individual raid frames',
                    initialValue = 40,
                    get = function()
                        local db = Phoenix_UI.db.profile
                        if db and db.raidframes and db.raidframes.height then
                            return db.raidframes.height
                        end
                        return 40
                    end,
                    set = function(value)
                        local db = Phoenix_UI.db.profile
                        if db and not db.raidframes then
                            db.raidframes = {}
                        end
                        if db and db.raidframes then
                            db.raidframes.height = value
                            
                            -- Update frames if module is active
                            local module = GetRaidFrames()
                            if module and module.UpdateFrameDimensions then
                                module:UpdateFrameDimensions()
                            end
                        end
                    end,
                    min = 20,
                    max = 100,
                    step = 5,
                    column = 6,
                    order = 8
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
                    label = 'Visual Elements',
                    column = 12,
                    order = 9
                }
            },
            {
                showBorder = {
                    type = 'checkbox',
                    label = 'Show Frame Borders',
                    tooltip = 'Show or hide borders around raid frames',
                    get = function()
                        local db = Phoenix_UI.db.profile
                        if db and db.raidframes then
                            -- If explicitly false, return false; otherwise default to true
                            return db.raidframes.showBorder ~= false
                        end
                        return true
                    end,
                    set = function(value)
                        local db = Phoenix_UI.db.profile
                        if db and not db.raidframes then
                            db.raidframes = {}
                        end
                        if db and db.raidframes then
                            db.raidframes.showBorder = value
                            
                            -- Update frames if module is active
                            local module = GetRaidFrames()
                            if module and module.UpdateFrameVisuals then
                                module:UpdateFrameVisuals()
                            end
                        end
                    end,
                    column = 6,
                    order = 10
                },
                showNames = {
                    type = 'checkbox',
                    label = 'Show Player Names',
                    tooltip = 'Show or hide player names on raid frames',
                    get = function()
                        local db = Phoenix_UI.db.profile
                        if db and db.raidframes then
                            -- If explicitly false, return false; otherwise default to true
                            return db.raidframes.showNames ~= false
                        end
                        return true
                    end,
                    set = function(value)
                        local db = Phoenix_UI.db.profile
                        if db and not db.raidframes then
                            db.raidframes = {}
                        end
                        if db and db.raidframes then
                            db.raidframes.showNames = value
                            
                            -- Update frames if module is active
                            local module = GetRaidFrames()
                            if module and module.UpdateFrameVisuals then
                                module:UpdateFrameVisuals()
                            end
                        end
                    end,
                    column = 6,
                    order = 11
                }
            },
            {
                showHealthText = {
                    type = 'checkbox',
                    label = 'Show Health Text',
                    tooltip = 'Show or hide health values on raid frames',
                    get = function()
                        local db = Phoenix_UI.db.profile
                        if db and db.raidframes then
                            return db.raidframes.showHealthText == true
                        end
                        return false
                    end,
                    set = function(value)
                        local db = Phoenix_UI.db.profile
                        if db and not db.raidframes then
                            db.raidframes = {}
                        end
                        if db and db.raidframes then
                            db.raidframes.showHealthText = value
                            
                            -- Update frames if module is active
                            local module = GetRaidFrames()
                            if module and module.UpdateFrameVisuals then
                                module:UpdateFrameVisuals()
                            end
                        end
                    end,
                    column = 6,
                    order = 12
                },
                classColors = {
                    type = 'checkbox',
                    label = 'Use Class Colors',
                    tooltip = 'Color health bars according to player class',
                    get = function()
                        local db = Phoenix_UI.db.profile
                        if db and db.raidframes then
                            -- If explicitly false, return false; otherwise default to true
                            return db.raidframes.classColors ~= false
                        end
                        return true
                    end,
                    set = function(value)
                        local db = Phoenix_UI.db.profile
                        if db and not db.raidframes then
                            db.raidframes = {}
                        end
                        if db and db.raidframes then
                            db.raidframes.classColors = value
                            
                            -- Update frames if module is active
                            local module = GetRaidFrames()
                            if module and module.UpdateFrameColors then
                                module:UpdateFrameColors()
                            end
                        end
                    end,
                    column = 6,
                    order = 13
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
                    label = 'Functionality',
                    column = 12,
                    order = 14
                }
            },
            {
                alwaysKeepGrouped = {
                    type = 'checkbox',
                    label = 'Always Keep Grouped',
                    tooltip = 'Always show raid-style frames for party members',
                    get = function()
                        local db = Phoenix_UI.db.profile
                        if db and db.raidframes then
                            return db.raidframes.alwaysKeepGrouped == true
                        end
                        return false
                    end,
                    set = function(value)
                        local db = Phoenix_UI.db.profile
                        if db and not db.raidframes then
                            db.raidframes = {}
                        end
                        if db and db.raidframes then
                            db.raidframes.alwaysKeepGrouped = value
                            
                            -- This setting typically requires a UI reload
                            StaticPopupDialogs["PHOENIX_UI_RELOAD"] = {
                                text = "This setting requires a UI reload to take effect. Reload UI now?",
                                button1 = "Yes",
                                button2 = "No",
                                OnAccept = function() ReloadUI() end,
                                timeout = 0,
                                whileDead = true,
                                hideOnEscape = true,
                                preferredIndex = 3,
                            }
                            StaticPopup_Show("PHOENIX_UI_RELOAD")
                        end
                    end,
                    column = 6,
                    order = 15
                },
                smartRaidFilter = {
                    type = 'checkbox',
                    label = 'Smart Raid Filter',
                    tooltip = 'Automatically filter raid frames based on your role',
                    get = function()
                        local db = Phoenix_UI.db.profile
                        if db and db.raidframes then
                            return db.raidframes.smartRaidFilter == true
                        end
                        return false
                    end,
                    set = function(value)
                        local db = Phoenix_UI.db.profile
                        if db and not db.raidframes then
                            db.raidframes = {}
                        end
                        if db and db.raidframes then
                            db.raidframes.smartRaidFilter = value
                            
                            -- Update frames if module is active
                            local module = GetRaidFrames()
                            if module and module.UpdateFilterSettings then
                                module:UpdateFilterSettings()
                            end
                        end
                    end,
                    column = 6,
                    order = 16
                }
            },
            {
                divider6 = {
                    type = 'divider',
                    column = 12
                }
            },
            {
                note = {
                    type = 'description',
                    text = "Note: Some settings may require a UI reload to take full effect.",
                    column = 12,
                    order = 17
                }
            }
        }
    }
end 