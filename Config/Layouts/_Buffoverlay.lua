local Layout = Phoenix_UI:NewModule('Config.Layout.Buffoverlay')

function Layout:OnEnable()
    -- Helper function to access BuffOverlay
    local function GetBuffOverlay()
        return LibStub("AceAddon-3.0"):GetAddon("BuffOverlay", true)
    end

    -- Helper function to check if BuffOverlay is available
    local function IsBuffOverlayLoaded()
        return GetBuffOverlay() ~= nil
    end

    -- Get the BuffOverlay addon
    local BuffOverlay = GetBuffOverlay()
    
    -- Check if BuffOverlay is loaded before proceeding
    if not BuffOverlay then
        -- Create a simplified layout if BuffOverlay isn't available
        Layout.layout = {
            layoutConfig = { padding = { top = 15 } },
            rows = {
                {
                    header = {
                        type = 'header',
                        label = 'Buff / Debuff / BuffOverlay'
                    }
                },
                {
                    notLoadedMessage = {
                        type = 'text',
                        text = '|cffFF0000BuffOverlay addon is not loaded or not available.|r',
                        column = 12,
                        order = 1
                    }
                }
            }
        }
        return
    end
    
    -- Get localization
    local L = BuffOverlay.L or {}
    
    -- Access the DB
    local db = BuffOverlay.db and BuffOverlay.db.profile or {}
    
    -- Initialize comprehensive layout that mimics the original BuffOverlay panel
    Layout.layout = {
        layoutConfig = { padding = { top = 15 } },
        rows = {
            {
                header = {
                    type = 'header',
                    label = 'BuffOverlay Configuration'
                }
            },
            -- General Settings Section
            {
                generalHeader = {
                    type = 'header',
                    label = 'General Settings',
                    order = 10
                }
            },
            {
                enabled = {
                    type = 'toggle',
                    label = 'Enable BuffOverlay',
                    tooltip = 'Enable or disable BuffOverlay functionality',
                    column = 6,
                    order = 11,
                    get = function() return db.enabled ~= false end,  -- Default to true if nil
                    set = function(value)
                        db.enabled = value
                        if BuffOverlay.RefreshOverlays then
                            BuffOverlay:RefreshOverlays()
                        end
                    end
                },
                welcomeMessage = {
                    type = 'toggle',
                    label = 'Show Welcome Message',
                    tooltip = 'Toggle showing of the welcome message on login',
                    column = 6,
                    order = 12,
                    get = function() return db.welcomeMessage ~= false end,
                    set = function(value)
                        db.welcomeMessage = value
                    end
                }
            },
            {
                lockFrames = {
                    type = 'toggle',
                    label = 'Lock Frames',
                    tooltip = 'Lock all BuffOverlay frames to prevent moving',
                    column = 6,
                    order = 13,
                    get = function() return db.lockFrames end,
                    set = function(value)
                        db.lockFrames = value
                        if BuffOverlay.RefreshOverlays then
                            BuffOverlay:RefreshOverlays()
                        end
                    end
                },
                minimapIcon = {
                    type = 'toggle',
                    label = 'Show Minimap Icon',
                    tooltip = 'Toggle visibility of the BuffOverlay minimap icon',
                    column = 6,
                    order = 14,
                    get = function() return not (db.minimap and db.minimap.hide) end,
                    set = function(value)
                        if BuffOverlay.ToggleMinimapIcon then
                            BuffOverlay:ToggleMinimapIcon()
                        end
                    end
                }
            },
            
            -- Display Options Section
            {
                displayHeader = {
                    type = 'header',
                    label = 'Display Options',
                    order = 20
                }
            },
            {
                showIcons = {
                    type = 'toggle',
                    label = 'Show Icons',
                    tooltip = 'Show spell icons in the BuffOverlay display',
                    column = 6,
                    order = 21,
                    get = function() return db.showIcons ~= false end,
                    set = function(value)
                        db.showIcons = value
                        if BuffOverlay.RefreshOverlays then
                            BuffOverlay:RefreshOverlays()
                        end
                    end
                },
                showText = {
                    type = 'toggle',
                    label = 'Show Text',
                    tooltip = 'Show spell names in the BuffOverlay display',
                    column = 6,
                    order = 22,
                    get = function() return db.showText ~= false end,
                    set = function(value)
                        db.showText = value
                        if BuffOverlay.RefreshOverlays then
                            BuffOverlay:RefreshOverlays()
                        end
                    end
                }
            },
            {
                showCooldown = {
                    type = 'toggle',
                    label = 'Show Cooldown',
                    tooltip = 'Show cooldown sweep animation on icons',
                    column = 6,
                    order = 23,
                    get = function() return db.showCooldown ~= false end,
                    set = function(value)
                        db.showCooldown = value
                        if BuffOverlay.RefreshOverlays then
                            BuffOverlay:RefreshOverlays()
                        end
                    end
                },
                showDuration = {
                    type = 'toggle',
                    label = 'Show Duration Text',
                    tooltip = 'Show remaining duration on buffs and debuffs',
                    column = 6,
                    order = 24,
                    get = function() return db.showDuration ~= false end,
                    set = function(value)
                        db.showDuration = value
                        if BuffOverlay.RefreshOverlays then
                            BuffOverlay:RefreshOverlays()
                        end
                    end
                }
            },
            
            -- Sizing Options
            {
                sizingHeader = {
                    type = 'header',
                    label = 'Sizing & Layout',
                    order = 30
                }
            },
            {
                iconSize = {
                    type = 'slider',
                    label = 'Icon Size',
                    tooltip = 'Adjust the size of buff/debuff icons',
                    min = 16,
                    max = 64,
                    step = 1,
                    column = 6,
                    order = 31,
                    get = function() return db.iconSize or 32 end,
                    set = function(value)
                        db.iconSize = value
                        if BuffOverlay.RefreshOverlays then
                            BuffOverlay:RefreshOverlays()
                        end
                    end
                },
                spacing = {
                    type = 'slider',
                    label = 'Icon Spacing',
                    tooltip = 'Adjust the spacing between buff/debuff icons',
                    min = 0,
                    max = 20,
                    step = 1,
                    column = 6,
                    order = 32,
                    get = function() return db.spacing or 2 end,
                    set = function(value)
                        db.spacing = value
                        if BuffOverlay.RefreshOverlays then
                            BuffOverlay:RefreshOverlays()
                        end
                    end
                }
            },
            
            -- Class & Spell Management
            {
                classHeader = {
                    type = 'header',
                    label = 'Class & Spell Management',
                    order = 40
                }
            },
            {
                openDetailedConfig = {
                    type = 'button',
                    text = 'Open Detailed Class & Spell Configuration',
                    tooltip = 'Opens the detailed spell management interface for configuring tracked buffs, debuffs, and cooldowns',
                    column = 12,
                    order = 41,
                    onClick = function()
                        if BuffOverlay and BuffOverlay.OpenOptions then
                            if BuffOverlay.OpenOptions then
                                -- Close the Phoenix UI config
                                if Phoenix_UI.CloseConfig then
                                    Phoenix_UI:CloseConfig()
                                end
                                -- Open the BuffOverlay options
                                BuffOverlay:OpenOptions()
                            end
                        end
                    end
                }
            },
            {
                note = {
                    type = 'text',
                    text = '|cffFFD100Note:|r Detailed spell configuration requires the full BuffOverlay panel due to its complexity.',
                    column = 12,
                    order = 42
                }
            },
            
            -- Bar Management
            {
                barHeader = {
                    type = 'header',
                    label = 'Aura Bar Management',
                    order = 50
                }
            },
            {
                barNote = {
                    type = 'text',
                    text = '|cffFFD100Note:|r Bar management requires the full BuffOverlay panel for complete functionality.',
                    column = 12,
                    order = 51
                }
            },
            {
                barManagement = {
                    type = 'button',
                    text = 'Configure Aura Bars',
                    tooltip = 'Opens the aura bar configuration interface',
                    column = 12,
                    order = 52,
                    onClick = function()
                        if BuffOverlay and BuffOverlay.OpenOptions then
                            if BuffOverlay.OpenOptions then
                                -- Close the Phoenix UI config
                                if Phoenix_UI.CloseConfig then
                                    Phoenix_UI:CloseConfig()
                                end
                                -- Open the BuffOverlay options
                                BuffOverlay:OpenOptions()
                            end
                        end
                    end
                }
            },
            
            -- Reset Section
            {
                resetHeader = {
                    type = 'header',
                    label = 'Reset Options',
                    order = 60
                }
            },
            {
                resetPositions = {
                    type = 'button',
                    text = 'Reset Positions',
                    tooltip = 'Reset the positions of all BuffOverlay frames',
                    column = 6,
                    order = 61,
                    onClick = function()
                        if BuffOverlay and BuffOverlay.ResetPositions then
                            BuffOverlay:ResetPositions()
                        end
                    end
                },
                resetAll = {
                    type = 'button',
                    text = 'Reset All Settings',
                    tooltip = 'Reset all BuffOverlay settings to default values',
                    column = 6,
                    order = 62,
                    onClick = function()
                        if BuffOverlay and BuffOverlay.ResetDB then
                            BuffOverlay:ResetDB()
                        end
                    end,
                    style = {
                        textColor = { r = 1, g = 0, b = 0 }
                    }
                }
            }
        }
    }
end
