-- Phoenix UI: MythicPlus Layout
local Layout = Phoenix_UI:NewModule('Config.Layout.MythicPlus')
local L = Phoenix_UI.L or {['MythicPlus'] = 'Mythic+'}

-- Get the Mythic+ module - use Phoenix_UI, not Phoenix
local MythicPlus = Phoenix_UI:GetModule("MythicPlus", true)
-- We do not have access to Phoenix global here, so don't try to use it
-- Instead, just handle the nil case gracefully

-- Register the layout with Phoenix_UI configuration
function Layout:OnEnable()
    if not Phoenix_UI.layouts then
        Phoenix_UI.layouts = {}
    end
    
    Phoenix_UI.layouts.MythicPlus = self:GetLayout()
    
    -- Connect the layout directly to the module if found
    if MythicPlus then
        MythicPlus.layout = self:GetLayout()
    else
        -- Try to find module through another method if available
        local moduleRegistry = Phoenix_UI.moduleRegistry or Phoenix_UI.modules
        if moduleRegistry and moduleRegistry.MythicPlus then
            moduleRegistry.MythicPlus.layout = self:GetLayout()
        else
            Phoenix_UI:Debug("MythicPlus module not found when registering layout")
        end
    end
end

-- Define the layout structure
function Layout:GetLayout()
    local layout = {
        key = 'MythicPlus',
        parentKey = nil,
        text = L['MythicPlus'] or 'Mythic+',
        layoutOrder = 12, -- Place it after other addon modules
        rows = {
            {
                header = {
                    type = 'header',
                    label = L['MythicPlus'] or 'Mythic+',
                    template = 'PhoenixHeaderTmpl',
                    column = 12,
                    initialValue = '',
                    order = 1
                }
            },
            {
                description = {
                    type = 'text',
                    label = L['MythicPlus_Description'] or 'Enhanced Mythic+ features and tracking for your dungeon runs',
                    fontSize = 'medium',
                    fontStyle = 'normal',
                    column = 12,
                    order = 1
                }
            },
            {
                enabled = {
                    type = 'checkbox',
                    key = 'enabled',
                    label = L['Enable'] or 'Enable',
                    tooltip = L['MythicPlus_Enable_Tooltip'] or 'Enable all Mythic+ features',
                    initialValue = true,
                    column = 12,
                    order = 1,
                    onChange = function(widget, value)
                        if not Phoenix_UI.db.profile.mythicplus then
                            Phoenix_UI.db.profile.mythicplus = {}
                        end
                        Phoenix_UI.db.profile.mythicplus.enabled = value
                        
                        -- Update the MythicPlus module settings if it exists
                        if MythicPlus and MythicPlus.db then
                            MythicPlus.db.enabled = value
                            if MythicPlus.UpdateSettings then
                                MythicPlus:UpdateSettings()
                            end
                        end
                    end
                }
            },
            {
                separator1 = {
                    type = 'spacer',
                    height = 20,
                    column = 12,
                    order = 1
                }
            },
            {
                featureHeader = {
                    type = 'header',
                    label = L['Features'] or 'Features',
                    template = 'PhoenixSubHeaderTmpl',
                    column = 12,
                    initialValue = '',
                    order = 1
                }
            },
            {
                showTimer = {
                    type = 'checkbox',
                    key = 'showTimer',
                    label = L['Timer'] or 'Timer',
                    tooltip = L['Timer_Description'] or 'Show enhanced timer display for Mythic+ dungeons',
                    initialValue = true,
                    column = 4,
                    order = 1,
                    onChange = function(widget, value)
                        if not Phoenix_UI.db.profile.mythicplus then
                            Phoenix_UI.db.profile.mythicplus = {}
                        end
                        Phoenix_UI.db.profile.mythicplus.showTimer = value
                        
                        -- Update the MythicPlus module settings if it exists
                        if MythicPlus and MythicPlus.db then
                            MythicPlus.db.showTimer = value
                            if MythicPlus.UpdateSettings then
                                MythicPlus:UpdateSettings()
                            end
                        end
                    end
                },
                showObjectives = {
                    type = 'checkbox',
                    key = 'showObjectives',
                    label = L['Objectives'] or 'Objectives',
                    tooltip = L['Objectives_Description'] or 'Show enemy forces and progress information',
                    initialValue = true,
                    column = 4,
                    order = 2,
                    onChange = function(widget, value)
                        if not Phoenix_UI.db.profile.mythicplus then
                            Phoenix_UI.db.profile.mythicplus = {}
                        end
                        Phoenix_UI.db.profile.mythicplus.showObjectives = value
                        
                        -- Update the MythicPlus module settings if it exists
                        if MythicPlus and MythicPlus.db then
                            MythicPlus.db.showObjectives = value
                            if MythicPlus.UpdateSettings then
                                MythicPlus:UpdateSettings()
                            end
                        end
                    end
                },
                deathTracker = {
                    type = 'checkbox',
                    key = 'deathTracker',
                    label = L['Death_Tracker'] or 'Death Tracker',
                    tooltip = L['Death_Tracker_Description'] or 'Track deaths during Mythic+ runs',
                    initialValue = true,
                    column = 4,
                    order = 3,
                    onChange = function(widget, value)
                        if not Phoenix_UI.db.profile.mythicplus then
                            Phoenix_UI.db.profile.mythicplus = {}
                        end
                        Phoenix_UI.db.profile.mythicplus.deathTracker = value
                        
                        -- Update the MythicPlus module settings if it exists
                        if MythicPlus and MythicPlus.db then
                            MythicPlus.db.deathTracker = value
                            if MythicPlus.UpdateSettings then
                                MythicPlus:UpdateSettings()
                            end
                        end
                    end
                }
            },
            {
                enhanceKeystones = {
                    type = 'checkbox',
                    key = 'enhanceKeystones',
                    label = L['Enhance_Keystones'] or 'Enhance Keystones',
                    tooltip = L['Enhance_Keystones_Description'] or 'Show keystone information tooltip and enhancements',
                    initialValue = true,
                    column = 4,
                    order = 1,
                    onChange = function(widget, value)
                        if not Phoenix_UI.db.profile.mythicplus then
                            Phoenix_UI.db.profile.mythicplus = {}
                        end
                        Phoenix_UI.db.profile.mythicplus.enhanceKeystones = value
                        
                        -- Update the MythicPlus module settings if it exists
                        if MythicPlus and MythicPlus.db then
                            MythicPlus.db.enhanceKeystones = value
                            if MythicPlus.UpdateSettings then
                                MythicPlus:UpdateSettings()
                            end
                        end
                    end
                },
                autoGossip = {
                    type = 'checkbox',
                    key = 'autoGossip',
                    label = L['Auto_Gossip'] or 'Auto Gossip',
                    tooltip = L['Auto_Gossip_Description'] or 'Automatically select gossip options for NPCs in dungeons',
                    initialValue = true,
                    column = 4,
                    order = 2,
                    onChange = function(widget, value)
                        if not Phoenix_UI.db.profile.mythicplus then
                            Phoenix_UI.db.profile.mythicplus = {}
                        end
                        Phoenix_UI.db.profile.mythicplus.autoGossip = value
                        
                        -- Update the MythicPlus module settings if it exists
                        if MythicPlus and MythicPlus.db then
                            MythicPlus.db.autoGossip = value
                            if MythicPlus.UpdateSettings then
                                MythicPlus:UpdateSettings()
                            end
                        end
                    end
                }
            },
            {
                separator2 = {
                    type = 'spacer',
                    height = 20,
                    column = 12,
                    order = 1
                }
            },
            {
                timerHeader = {
                    type = 'header',
                    label = L['Timer_Options'] or 'Timer Options',
                    template = 'PhoenixSubHeaderTmpl',
                    column = 12,
                    initialValue = '',
                    order = 1
                }
            },
            {
                timerScale = {
                    type = 'slider',
                    key = 'timerScale',
                    label = L['Timer_Scale'] or 'Timer Scale',
                    tooltip = L['Timer_Scale_Description'] or 'Adjust the size of the timer display',
                    min = 0.5,
                    max = 2.0,
                    step = 0.05,
                    initialValue = 1.0,
                    column = 6,
                    order = 1,
                    onChange = function(widget, value)
                        if not Phoenix_UI.db.profile.mythicplus then
                            Phoenix_UI.db.profile.mythicplus = {}
                        end
                        if not Phoenix_UI.db.profile.mythicplus.timer then
                            Phoenix_UI.db.profile.mythicplus.timer = {}
                        end
                        Phoenix_UI.db.profile.mythicplus.timer.scale = value
                        
                        -- Update the MythicPlus module settings if it exists
                        if MythicPlus and MythicPlus.db and MythicPlus.db.timer then
                            MythicPlus.db.timer.scale = value
                            if MythicPlus.UpdateTimerSettings then
                                MythicPlus:UpdateTimerSettings()
                            end
                        end
                    end
                },
                timerPosition = {
                    type = 'select',
                    key = 'timerPosition',
                    label = L['Timer_Position'] or 'Timer Position',
                    tooltip = L['Timer_Position_Description'] or 'Set the position of the timer display',
                    choices = {
                        {text = L['Top'] or 'Top', value = 'TOP'},
                        {text = L['TopLeft'] or 'Top Left', value = 'TOPLEFT'},
                        {text = L['TopRight'] or 'Top Right', value = 'TOPRIGHT'},
                        {text = L['Center'] or 'Center', value = 'CENTER'},
                    },
                    initialValue = 'TOP',
                    column = 6,
                    order = 2,
                    onChange = function(widget, value)
                        if not Phoenix_UI.db.profile.mythicplus then
                            Phoenix_UI.db.profile.mythicplus = {}
                        end
                        if not Phoenix_UI.db.profile.mythicplus.timer then
                            Phoenix_UI.db.profile.mythicplus.timer = {}
                        end
                        Phoenix_UI.db.profile.mythicplus.timer.position = value
                        
                        -- Update the MythicPlus module settings if it exists
                        if MythicPlus and MythicPlus.db and MythicPlus.db.timer then
                            MythicPlus.db.timer.position = value
                            if MythicPlus.UpdateTimerSettings then
                                MythicPlus:UpdateTimerSettings()
                            end
                        end
                    end
                }
            },
            {
                colorThreeChest = {
                    key = 'colorThreeChest',
                    label = L['Color_Three_Chest'] or 'Three Chest Color',
                    type = 'color',
                    hasAlpha = true,
                    initialValue = {r = 0, g = 1, b = 0.1, a = 1},
                    column = 3,
                    order = 1,
                    onChange = function(widget, r, g, b, a)
                        if not Phoenix_UI.db.profile.mythicplus then
                            Phoenix_UI.db.profile.mythicplus = {}
                        end
                        if not Phoenix_UI.db.profile.mythicplus.timer then
                            Phoenix_UI.db.profile.mythicplus.timer = {}
                        end
                        if not Phoenix_UI.db.profile.mythicplus.timer.colors then
                            Phoenix_UI.db.profile.mythicplus.timer.colors = {}
                        end
                        Phoenix_UI.db.profile.mythicplus.timer.colors.threeChest = {r = r, g = g, b = b, a = a}
                        
                        -- Update the MythicPlus module settings if it exists
                        if MythicPlus and MythicPlus.db and MythicPlus.db.timer and MythicPlus.db.timer.colors then
                            MythicPlus.db.timer.colors.threeChest = {r = r, g = g, b = b, a = a}
                            if MythicPlus.UpdateTimerSettings then
                                MythicPlus:UpdateTimerSettings()
                            end
                        end
                    end
                },
                colorTwoChest = {
                    key = 'colorTwoChest',
                    label = L['Color_Two_Chest'] or 'Two Chest Color',
                    type = 'color',
                    hasAlpha = true,
                    initialValue = {r = 0.5, g = 0.9, b = 0, a = 1},
                    column = 3,
                    order = 2,
                    onChange = function(widget, r, g, b, a)
                        if not Phoenix_UI.db.profile.mythicplus then
                            Phoenix_UI.db.profile.mythicplus = {}
                        end
                        if not Phoenix_UI.db.profile.mythicplus.timer then
                            Phoenix_UI.db.profile.mythicplus.timer = {}
                        end
                        if not Phoenix_UI.db.profile.mythicplus.timer.colors then
                            Phoenix_UI.db.profile.mythicplus.timer.colors = {}
                        end
                        Phoenix_UI.db.profile.mythicplus.timer.colors.twoChest = {r = r, g = g, b = b, a = a}
                        
                        -- Update the MythicPlus module settings if it exists
                        if MythicPlus and MythicPlus.db and MythicPlus.db.timer and MythicPlus.db.timer.colors then
                            MythicPlus.db.timer.colors.twoChest = {r = r, g = g, b = b, a = a}
                            if MythicPlus.UpdateTimerSettings then
                                MythicPlus:UpdateTimerSettings()
                            end
                        end
                    end
                },
                colorOneChest = {
                    key = 'colorOneChest',
                    label = L['Color_One_Chest'] or 'One Chest Color',
                    type = 'color',
                    hasAlpha = true,
                    initialValue = {r = 1, g = 0.8, b = 0, a = 1},
                    column = 3,
                    order = 3,
                    onChange = function(widget, r, g, b, a)
                        if not Phoenix_UI.db.profile.mythicplus then
                            Phoenix_UI.db.profile.mythicplus = {}
                        end
                        if not Phoenix_UI.db.profile.mythicplus.timer then
                            Phoenix_UI.db.profile.mythicplus.timer = {}
                        end
                        if not Phoenix_UI.db.profile.mythicplus.timer.colors then
                            Phoenix_UI.db.profile.mythicplus.timer.colors = {}
                        end
                        Phoenix_UI.db.profile.mythicplus.timer.colors.oneChest = {r = r, g = g, b = b, a = a}
                        
                        -- Update the MythicPlus module settings if it exists
                        if MythicPlus and MythicPlus.db and MythicPlus.db.timer and MythicPlus.db.timer.colors then
                            MythicPlus.db.timer.colors.oneChest = {r = r, g = g, b = b, a = a}
                            if MythicPlus.UpdateTimerSettings then
                                MythicPlus:UpdateTimerSettings()
                            end
                        end
                    end
                },
                colorFailed = {
                    key = 'colorFailed',
                    label = L['Color_Failed'] or 'Failed Timer Color',
                    type = 'color',
                    hasAlpha = true,
                    initialValue = {r = 1, g = 0.1, b = 0.1, a = 1},
                    column = 3,
                    order = 4,
                    onChange = function(widget, r, g, b, a)
                        if not Phoenix_UI.db.profile.mythicplus then
                            Phoenix_UI.db.profile.mythicplus = {}
                        end
                        if not Phoenix_UI.db.profile.mythicplus.timer then
                            Phoenix_UI.db.profile.mythicplus.timer = {}
                        end
                        if not Phoenix_UI.db.profile.mythicplus.timer.colors then
                            Phoenix_UI.db.profile.mythicplus.timer.colors = {}
                        end
                        Phoenix_UI.db.profile.mythicplus.timer.colors.failed = {r = r, g = g, b = b, a = a}
                        
                        -- Update the MythicPlus module settings if it exists
                        if MythicPlus and MythicPlus.db and MythicPlus.db.timer and MythicPlus.db.timer.colors then
                            MythicPlus.db.timer.colors.failed = {r = r, g = g, b = b, a = a}
                            if MythicPlus.UpdateTimerSettings then
                                MythicPlus:UpdateTimerSettings()
                            end
                        end
                    end
                }
            },
            -- Add padding at the bottom to ensure all options are visible when scrolling
            {
                bottomPadding = {
                    type = 'spacer',
                    height = 150,
                    column = 12,
                    order = 1
                }
            }
        }
    }
    
    return layout
end
