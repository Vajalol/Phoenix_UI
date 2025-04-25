-- Phoenix_UI: Mythic+ Module - Configuration
local addonName, Phoenix = ...

-- Get the module
local Module = Phoenix_UI:GetModule("MythicPlus")
if not Module then return end

-- Get localization
local L = Module.L or Phoenix.L or {}

-- Configuration module
local Config = Module:NewModule("Config")

-- Set up the configuration options
function Config:SetupConfig()
    local options = {
        type = "group",
        name = L["MYTHIC_PLUS"] or "Mythic+",
        args = {
            general = {
                type = "group",
                name = L["MYTHIC_PLUS"] or "Mythic+",
                order = 1,
                args = {
                    header = {
                        type = "header",
                        name = L["MYTHIC_PLUS"] or "Mythic+",
                        order = 1
                    },
                    desc = {
                        type = "description",
                        name = L["MYTHIC_PLUS_DESC"] or "Enhanced Mythic+ features for Phoenix UI",
                        order = 2,
                        fontSize = "medium"
                    },
                    enabled = {
                        type = "toggle",
                        name = ENABLE,
                        desc = L["MYTHIC_PLUS_DESC"] or "Enable all Mythic+ features",
                        order = 3,
                        width = "full",
                        get = function() return Module.db.enabled end,
                        set = function(info, value)
                            Module.db.enabled = value
                            Module:UpdateSettings()
                            
                            -- If we're disabling the module, trigger a message
                            if not value then
                                Module:SendMessage("PHOENIX_MYTHICPLUS_DISABLED")
                            else
                                Module:SendMessage("PHOENIX_MYTHICPLUS_ENABLED")
                            end
                            
                            -- Notify the user
                            if value then
                                Module:Print(L["MYTHIC_PLUS"] .. " " .. L["ENABLED"])
                            else
                                Module:Print(L["MYTHIC_PLUS"] .. " " .. L["DISABLED"])
                            end
                        end
                    },
                    enabledInfo = {
                        type = "description",
                        name = "|cffff8800" .. L["MYTHIC_PLUS_ENABLE_DESC"] or "Toggling this option will enable or disable all Mythic+ enhancements." .. "|r",
                        order = 4,
                        fontSize = "medium",
                        hidden = function() return Module.db.enabled end,
                    },
                    separator1 = {
                        type = "header",
                        name = "",
                        order = 10,
                        hidden = function() return not Module.db.enabled end,
                    },
                    featureSection = {
                        type = "description",
                        name = L["MYTHIC_PLUS_FEATURES"] or "Individual Features",
                        order = 11,
                        fontSize = "medium",
                        hidden = function() return not Module.db.enabled end,
                    },
                    showTimer = {
                        type = "toggle",
                        name = L["TIMER"] or "Timer",
                        desc = L["TIMER_DESC"] or "Enhanced timer display",
                        order = 12,
                        width = "half",
                        hidden = function() return not Module.db.enabled end,
                        get = function() return Module.db.showTimer end,
                        set = function(info, value)
                            Module.db.showTimer = value
                            Module:UpdateSettings()
                        end
                    },
                    showObjectives = {
                        type = "toggle",
                        name = L["ENEMY_FORCES"] or "Enemy Forces",
                        desc = L["ENEMY_FORCES_DESC"] or "Track progress towards enemy forces requirement",
                        order = 13,
                        width = "half",
                        hidden = function() return not Module.db.enabled end,
                        get = function() return Module.db.showObjectives end,
                        set = function(info, value)
                            Module.db.showObjectives = value
                            Module:UpdateSettings()
                        end
                    },
                    deathPenalty = {
                        type = "toggle",
                        name = L["DEATH_TRACKER"] or "Death Tracker",
                        desc = L["DEATH_TRACKER_DESC"] or "Track deaths during Mythic+ runs",
                        order = 14,
                        width = "half",
                        hidden = function() return not Module.db.enabled end,
                        get = function() return Module.db.deathPenalty end,
                        set = function(info, value)
                            Module.db.deathPenalty = value
                            Module:UpdateSettings()
                        end
                    },
                    enhanceKeystones = {
                        type = "toggle",
                        name = L["KEYSTONE_LINK"] or "Keystone Link",
                        desc = L["KEYSTONE_LINK_DESC"] or "Enhanced keystone links in chat",
                        order = 15,
                        width = "half",
                        hidden = function() return not Module.db.enabled end,
                        get = function() return Module.db.enhanceKeystones end,
                        set = function(info, value)
                            Module.db.enhanceKeystones = value
                            Module:UpdateSettings()
                        end
                    },
                    separator2 = {
                        type = "header",
                        name = "",
                        order = 20,
                        hidden = function() return not Module.db.enabled end,
                    },
                    integrationSection = {
                        type = "description",
                        name = L["MYTHIC_PLUS_INTEGRATION"] or "Integration Settings",
                        order = 21,
                        fontSize = "medium",
                        hidden = function() return not Module.db.enabled end,
                    },
                    integrateWithPhoenix = {
                        type = "toggle",
                        name = L["MYTHIC_PLUS_INTEGRATE_PHOENIX"] or "Add to Phoenix UI Tab",
                        desc = L["MYTHIC_PLUS_INTEGRATE_PHOENIX_DESC"] or "Add Mythic+ settings to the main Phoenix UI configuration panel",
                        order = 22,
                        width = "full",
                        hidden = function() return not Module.db.enabled end,
                        get = function() return Module.db.integrateWithPhoenix end,
                        set = function(info, value)
                            Module.db.integrateWithPhoenix = value
                            -- Refresh configuration panel integration
                            if Phoenix.RefreshConfig then
                                Phoenix:RefreshConfig()
                            end
                            
                            if value then
                                Module:Print(L["MYTHIC_PLUS_INTEGRATED"])
                            else
                                Module:Print(L["MYTHIC_PLUS_STANDALONE"])
                            end
                        end
                    },
                    integrationInfo = {
                        type = "description",
                        name = "|cffAAAAAA" .. L["MYTHIC_PLUS_INTEGRATION_INFO"] or "Changes to this option will take effect after reloading your UI." .. "|r",
                        order = 23,
                        fontSize = "small",
                        hidden = function() return not Module.db.enabled end,
                    },
                }
            },
            progressTracker = {
                type = "group",
                name = L["ENEMY_FORCES"] or "Enemy Forces",
                order = 2,
                disabled = function() return not Module.db.enabled or not Module.db.showObjectives end,
                args = {
                    header = {
                        type = "header",
                        name = L["ENEMY_FORCES"] or "Enemy Forces",
                        order = 1
                    },
                    desc = {
                        type = "description",
                        name = L["ENEMY_FORCES_DESC"] or "Track progress towards enemy forces requirement",
                        order = 2,
                        fontSize = "medium"
                    },
                    progressFormat = {
                        type = "select",
                        name = L["ENEMY_FORCES_FORMAT"] or "Format",
                        desc = L["ENEMY_FORCES_FORMAT_DESC"] or "How to display enemy forces progress",
                        order = 3,
                        width = "double",
                        values = {
                            ["PERCENTAGE_ONLY"] = L["ENEMY_FORCES_PERCENTAGE"] or "Percentage only",
                            ["VALUE_ONLY"] = L["ENEMY_FORCES_VALUE"] or "Value only",
                            ["PERCENTAGE_AND_VALUE"] = L["ENEMY_FORCES_BOTH"] or "Percentage and value"
                        },
                        get = function() return Module.db.progressFormat end,
                        set = function(info, value)
                            Module.db.progressFormat = value
                            Module:UpdateSettings()
                        end
                    },
                    showEnemyTooltip = {
                        type = "toggle",
                        name = L["ENEMY_FORCES_TOOLTIP"] or "Show progress value on enemy tooltips",
                        desc = L["ENEMY_FORCES_TOOLTIP_DESC"] or "Display the amount of enemy forces progress each mob gives",
                        order = 4,
                        width = "full",
                        get = function() return Module.db.showEnemyTooltip end,
                        set = function(info, value)
                            Module.db.showEnemyTooltip = value
                            Module:UpdateSettings()
                        end
                    }
                }
            },
            timer = {
                type = "group",
                name = L["TIMER"] or "Timer",
                order = 3,
                disabled = function() return not Module.db.enabled or not Module.db.showTimer end,
                args = {
                    header = {
                        type = "header",
                        name = L["TIMER"] or "Timer",
                        order = 1
                    },
                    desc = {
                        type = "description",
                        name = L["TIMER_DESC"] or "Enhanced timer display",
                        order = 2,
                        fontSize = "medium"
                    },
                    enhancedTimer = {
                        type = "toggle",
                        name = L["TIMER"] or "Enhanced Timer",
                        desc = L["TIMER_DESC"] or "Enhanced timer display",
                        order = 3,
                        width = "full",
                        get = function() return Module.db.enhancedTimer end,
                        set = function(info, value)
                            Module.db.enhancedTimer = value
                            Module:UpdateSettings()
                        end
                    },
                    timerStyle = {
                        type = "select",
                        name = L["TIMER_STYLE"] or "Timer Style",
                        desc = L["TIMER_STYLE_DESC"] or "Visual style of the timer",
                        order = 4,
                        width = "double",
                        disabled = function() return not Module.db.enhancedTimer end,
                        values = {
                            ["PHOENIX"] = L["TIMER_STYLE_PHOENIX"] or "Phoenix UI",
                            ["CLASSIC"] = L["TIMER_STYLE_CLASSIC"] or "Classic",
                            ["MINIMALIST"] = L["TIMER_STYLE_MINIMALIST"] or "Minimalist"
                        },
                        get = function() return Module.db.timerStyle end,
                        set = function(info, value)
                            Module.db.timerStyle = value
                            Module:UpdateSettings()
                        end
                    },
                    showChestTimers = {
                        type = "toggle",
                        name = L["TIMER_CHEST_MARKERS"] or "Chest Timers",
                        desc = L["TIMER_CHEST_MARKERS_DESC"] or "Show bonus chest time markers",
                        order = 5,
                        width = "full",
                        disabled = function() return not Module.db.enhancedTimer end,
                        get = function() return Module.db.showChestTimers end,
                        set = function(info, value)
                            Module.db.showChestTimers = value
                            Module:UpdateSettings()
                        end
                    },
                    timerFormat = {
                        type = "select",
                        name = L["TIMER_FORMAT"] or "Timer Format",
                        desc = L["TIMER_FORMAT_DESC"] or "Format for displaying timer information",
                        order = 6,
                        width = "double",
                        disabled = function() return not Module.db.enhancedTimer end,
                        values = {
                            ["REMAINING"] = L["TIMER_FORMAT_REMAINING"] or "Time Remaining Only",
                            ["ELAPSED"] = L["TIMER_FORMAT_ELAPSED"] or "Time Elapsed Only",
                            ["DUAL"] = L["TIMER_FORMAT_DUAL"] or "Both Elapsed and Remaining"
                        },
                        get = function() return Module.db.timerFormat or "REMAINING" end,
                        set = function(info, value)
                            Module.db.timerFormat = value
                            Module:UpdateSettings()
                        end
                    }
                }
            },
            deathTracker = {
                type = "group",
                name = L["DEATH_TRACKER"] or "Death Tracker",
                order = 4,
                disabled = function() return not Module.db.enabled or not Module.db.deathPenalty end,
                args = {
                    header = {
                        type = "header",
                        name = L["DEATH_TRACKER"] or "Death Tracker",
                        order = 1
                    },
                    desc = {
                        type = "description",
                        name = L["DEATH_TRACKER_DESC"] or "Track deaths during Mythic+ runs",
                        order = 2,
                        fontSize = "medium"
                    },
                    deathTracker = {
                        type = "toggle",
                        name = L["DEATH_COUNTER"] or "Death Counter",
                        desc = L["DEATH_COUNTER_DESC"] or "Show death counter in objective tracker",
                        order = 3,
                        width = "full",
                        get = function() return Module.db.deathTracker end,
                        set = function(info, value)
                            Module.db.deathTracker = value
                            Module:UpdateSettings()
                        end
                    },
                    showDeathDetails = {
                        type = "toggle",
                        name = L["DEATH_DETAILS"] or "Death Details",
                        desc = L["DEATH_DETAILS_DESC"] or "Show detailed death information",
                        order = 4,
                        width = "full",
                        disabled = function() return not Module.db.deathTracker end,
                        get = function() return Module.db.showDeathDetails end,
                        set = function(info, value)
                            Module.db.showDeathDetails = value
                            Module:UpdateSettings()
                        end
                    }
                }
            },
            keystoneLink = {
                type = "group",
                name = L["KEYSTONE_LINK"] or "Keystone Link",
                order = 5,
                args = {
                    header = {
                        type = "header",
                        name = L["KEYSTONE_LINK"] or "Keystone Link",
                        order = 1
                    },
                    desc = {
                        type = "description",
                        name = L["KEYSTONE_LINK_DESC"] or "Enhanced keystone links in chat",
                        order = 2,
                        fontSize = "medium"
                    },
                    keystoneLink = {
                        type = "toggle",
                        name = L["KEYSTONE_LINK"] or "Keystone Link",
                        desc = L["KEYSTONE_LINK_DESC"] or "Enhanced keystone links in chat",
                        order = 3,
                        width = "full",
                        get = function() return Module.db.keystoneLink end,
                        set = function(info, value)
                            Module.db.keystoneLink = value
                            Module:UpdateSettings()
                        end
                    }
                }
            },
            autoGossip = {
                type = "group",
                name = L["AUTO_GOSSIP"] or "Auto Gossip",
                order = 6,
                args = {
                    header = {
                        type = "header",
                        name = L["AUTO_GOSSIP"] or "Auto Gossip",
                        order = 1
                    },
                    desc = {
                        type = "description",
                        name = L["AUTO_GOSSIP_DESC"] or "Automatically select gossip options in Mythic+ dungeons",
                        order = 2,
                        fontSize = "medium"
                    },
                    autoGossip = {
                        type = "toggle",
                        name = L["AUTO_GOSSIP"] or "Auto Gossip",
                        desc = L["AUTO_GOSSIP_DESC"] or "Automatically select gossip options in Mythic+ dungeons",
                        order = 3,
                        width = "full",
                        get = function() return Module.db.autoGossip end,
                        set = function(info, value)
                            Module.db.autoGossip = value
                            Module:UpdateSettings()
                        end
                    },
                    showClues = {
                        type = "toggle",
                        name = L["SHOW_CLUES"] or "Show Clues",
                        desc = L["SHOW_CLUES_DESC"] or "Output Court of Stars clues to party chat",
                        order = 4,
                        width = "full",
                        disabled = function() return not Module.db.autoGossip end,
                        get = function() return Module.db.showClues end,
                        set = function(info, value)
                            Module.db.showClues = value
                            Module:UpdateSettings()
                        end
                    }
                }
            },
            season2 = {
                type = "group",
                name = L["TWW_SEASON2"] or "The War Within S2",
                order = 7,
                args = {
                    header = {
                        type = "header",
                        name = L["TWW_SEASON2"] or "The War Within Season 2",
                        order = 1
                    },
                    desc = {
                        type = "description",
                        name = L["TWW_SEASON2_DESC"] or "Configuration for The War Within Season 2 enemy forces",
                        order = 2,
                        fontSize = "medium"
                    },
                    showSeasonNotification = {
                        type = "toggle",
                        name = L["TWW_SHOW_SEASON_NOTIFICATION"] or "Show Season Notification",
                        desc = L["TWW_SHOW_SEASON_NOTIFICATION_DESC"] or "Show a notification about Season 2 support when loading",
                        order = 3,
                        width = "full",
                        get = function() return Module.db.showSeasonNotification end,
                        set = function(info, value)
                            Module.db.showSeasonNotification = value
                            Module:UpdateSettings()
                        end
                    },
                    exportEnemyForces = {
                        type = "execute",
                        name = L["TWW_EXPORT_ENEMY_FORCES"] or "Export Enemy Forces",
                        desc = L["TWW_EXPORT_ENEMY_FORCES_DESC"] or "Export your enemy forces database",
                        order = 4,
                        width = "full",
                        func = function()
                            Module:ExportEnemyForces()
                        end
                    },
                    importEnemyForces = {
                        type = "execute",
                        name = L["TWW_IMPORT_ENEMY_FORCES"] or "Import Enemy Forces",
                        desc = L["TWW_IMPORT_ENEMY_FORCES_DESC"] or "Import enemy forces values from a string",
                        order = 5,
                        width = "full",
                        func = function()
                            Module:ImportEnemyForces()
                        end
                    },
                    resetEnemyForces = {
                        type = "execute",
                        name = L["TWW_RESET_ENEMY_FORCES"] or "Reset Enemy Forces",
                        desc = L["TWW_RESET_ENEMY_FORCES_DESC"] or "Reset enemy forces to default values",
                        order = 6,
                        width = "full",
                        func = function()
                            Module:ResetEnemyForces()
                        end
                    },
                    dungeonHeader = {
                        type = "header",
                        name = L["TWW_DUNGEONS"] or "Season 2 Dungeons",
                        order = 10
                    },
                    darkreach = {
                        type = "toggle",
                        name = L["TWW_DARKREACH"] or "Darkreach Depths",
                        desc = L["TWW_DARKREACH_DESC"] or "Show enemy forces values in Darkreach Depths",
                        order = 11,
                        width = "full",
                        get = function() return Module.db.dungeons and Module.db.dungeons[2579] or true end,
                        set = function(info, value)
                            if not Module.db.dungeons then Module.db.dungeons = {} end
                            Module.db.dungeons[2579] = value
                            Module:UpdateSettings()
                        end
                    },
                    dawnbreaker = {
                        type = "toggle",
                        name = L["TWW_DAWNBREAKER"] or "The Dawnbreaker",
                        desc = L["TWW_DAWNBREAKER_DESC"] or "Show enemy forces values in The Dawnbreaker",
                        order = 12,
                        width = "full",
                        get = function() return Module.db.dungeons and Module.db.dungeons[2580] or true end,
                        set = function(info, value)
                            if not Module.db.dungeons then Module.db.dungeons = {} end
                            Module.db.dungeons[2580] = value
                            Module:UpdateSettings()
                        end
                    },
                    ataldazar = {
                        type = "toggle",
                        name = L["TWW_ATALDAZAR"] or "Atal'Dazar",
                        desc = L["TWW_ATALDAZAR_DESC"] or "Show enemy forces values in Atal'Dazar",
                        order = 13,
                        width = "full",
                        get = function() return Module.db.dungeons and Module.db.dungeons[968] or true end,
                        set = function(info, value)
                            if not Module.db.dungeons then Module.db.dungeons = {} end
                            Module.db.dungeons[968] = value
                            Module:UpdateSettings()
                        end
                    },
                    blackrookhold = {
                        type = "toggle",
                        name = L["TWW_BLACKROOKHOLD"] or "Black Rook Hold",
                        desc = L["TWW_BLACKROOKHOLD_DESC"] or "Show enemy forces values in Black Rook Hold",
                        order = 14,
                        width = "full",
                        get = function() return Module.db.dungeons and Module.db.dungeons[1501] or true end,
                        set = function(info, value)
                            if not Module.db.dungeons then Module.db.dungeons = {} end
                            Module.db.dungeons[1501] = value
                            Module:UpdateSettings()
                        end
                    },
                    waycrestmanor = {
                        type = "toggle",
                        name = L["TWW_WAYCRESTMANOR"] or "Waycrest Manor",
                        desc = L["TWW_WAYCRESTMANOR_DESC"] or "Show enemy forces values in Waycrest Manor",
                        order = 15,
                        width = "full",
                        get = function() return Module.db.dungeons and Module.db.dungeons[1862] or true end,
                        set = function(info, value)
                            if not Module.db.dungeons then Module.db.dungeons = {} end
                            Module.db.dungeons[1862] = value
                            Module:UpdateSettings()
                        end
                    },
                    everbloom = {
                        type = "toggle",
                        name = L["TWW_EVERBLOOM"] or "Everbloom",
                        desc = L["TWW_EVERBLOOM_DESC"] or "Show enemy forces values in Everbloom",
                        order = 16,
                        width = "full",
                        get = function() return Module.db.dungeons and Module.db.dungeons[1279] or true end,
                        set = function(info, value)
                            if not Module.db.dungeons then Module.db.dungeons = {} end
                            Module.db.dungeons[1279] = value
                            Module:UpdateSettings()
                        end
                    },
                    theaterofpain = {
                        type = "toggle",
                        name = L["TWW_THEATEROFPAIN"] or "Theater of Pain",
                        desc = L["TWW_THEATEROFPAIN_DESC"] or "Show enemy forces values in Theater of Pain",
                        order = 19,
                        width = "full",
                        get = function() return Module.db.dungeons and Module.db.dungeons[1683] or true end,
                        set = function(info, value)
                            if not Module.db.dungeons then Module.db.dungeons = {} end
                            Module.db.dungeons[1683] = value
                            Module:UpdateSettings()
                        end
                    },
                    mechagonworkshop = {
                        type = "toggle",
                        name = L["TWW_MECHAGONWORKSHOP"] or "Operation: Mechagon - Workshop",
                        desc = L["TWW_MECHAGONWORKSHOP_DESC"] or "Show enemy forces values in Operation: Mechagon - Workshop",
                        order = 20,
                        width = "full",
                        get = function() return Module.db.dungeons and Module.db.dungeons[2097] or true end,
                        set = function(info, value)
                            if not Module.db.dungeons then Module.db.dungeons = {} end
                            Module.db.dungeons[2097] = value
                            Module:UpdateSettings()
                        end
                    }
                }
            }
        }
    }
    
    -- Register with Phoenix_UI's config system
    if Phoenix_UI.ConfigRegistry then
        Phoenix_UI.ConfigRegistry:RegisterModuleOptions("MythicPlus", options)
    else
        -- Fallback for older Phoenix_UI versions
        Phoenix_UI.optionsFrames = Phoenix_UI.optionsFrames or {}
        Phoenix_UI.optionsFrames["MythicPlus"] = options
    end
    
    -- Create a config layout for the Phoenix_UI panel
    self:CreateConfigLayout()
end

-- Create a config layout for Phoenix_UI's custom panel system
function Config:CreateConfigLayout()
    if not Phoenix_UI.configOptions then return end
    
    local layout = {
        -- Layout configuration
        layoutConfig = { padding = { top = 15 } },
        database = Module.db,
        -- Rows of configuration options
        rows = {
            -- General section
            {
                header = {
                    type = 'header',
                    label = L["MYTHIC_PLUS"] or "Mythic+"
                }
            },
            {
                description = {
                    type = 'description',
                    text = L["MYTHIC_PLUS_DESC"] or "Enhanced Mythic+ features for Phoenix UI",
                    column = 12
                }
            },
            {
                enabled = {
                    key = 'enabled',
                    type = 'checkbox',
                    label = ENABLE,
                    tooltip = L["MYTHIC_PLUS_DESC"] or "Enable all Mythic+ features",
                    onChange = function(widget, value)
                        Module.db.enabled = value
                        Module:UpdateSettings()
                    end,
                    column = 12
                }
            },
            {
                divider1 = {
                    type = 'divider',
                    column = 12
                }
            },
            
            -- Progress Tracker section
            {
                header2 = {
                    type = 'header',
                    label = L["ENEMY_FORCES"] or "Enemy Forces"
                }
            },
            {
                description2 = {
                    type = 'description',
                    text = L["ENEMY_FORCES_DESC"] or "Track progress towards enemy forces requirement",
                    column = 12
                }
            },
            {
                progressFormat = {
                    key = 'progressFormat',
                    type = 'dropdown',
                    label = L["ENEMY_FORCES_FORMAT"] or "Format",
                    tooltip = L["ENEMY_FORCES_FORMAT_DESC"] or "How to display enemy forces progress",
                    options = {
                        { value = "PERCENTAGE_ONLY", text = L["ENEMY_FORCES_PERCENTAGE"] or "Percentage only" },
                        { value = "VALUE_ONLY", text = L["ENEMY_FORCES_VALUE"] or "Value only" },
                        { value = "PERCENTAGE_AND_VALUE", text = L["ENEMY_FORCES_BOTH"] or "Percentage and value" }
                    },
                    onChange = function(widget, value)
                        Module.db.progressFormat = value
                        Module:UpdateSettings()
                    end,
                    column = 6
                },
                showEnemyTooltip = {
                    key = 'showEnemyTooltip',
                    type = 'checkbox',
                    label = L["ENEMY_FORCES_TOOLTIP"] or "Show progress value on enemy tooltips",
                    tooltip = L["ENEMY_FORCES_TOOLTIP_DESC"] or "Display the amount of enemy forces progress each mob gives",
                    onChange = function(widget, value)
                        Module.db.showEnemyTooltip = value
                        Module:UpdateSettings()
                    end,
                    column = 6
                }
            },
            {
                divider2 = {
                    type = 'divider',
                    column = 12
                }
            },
            
            -- Timer section
            {
                header3 = {
                    type = 'header',
                    label = L["TIMER"] or "Timer"
                }
            },
            {
                description3 = {
                    type = 'description',
                    text = L["TIMER_DESC"] or "Enhanced timer display",
                    column = 12
                }
            },
            {
                enhancedTimer = {
                    key = 'enhancedTimer',
                    type = 'checkbox',
                    label = L["TIMER"] or "Enhanced Timer",
                    tooltip = L["TIMER_DESC"] or "Enhanced timer display",
                    onChange = function(widget, value)
                        Module.db.enhancedTimer = value
                        Module:UpdateSettings()
                    end,
                    column = 4
                },
                timerStyle = {
                    key = 'timerStyle',
                    type = 'dropdown',
                    label = L["TIMER_STYLE"] or "Timer Style",
                    tooltip = L["TIMER_STYLE_DESC"] or "Visual style of the timer",
                    options = {
                        { value = "PHOENIX", text = L["TIMER_STYLE_PHOENIX"] or "Phoenix UI" },
                        { value = "CLASSIC", text = L["TIMER_STYLE_CLASSIC"] or "Classic" },
                        { value = "MINIMALIST", text = L["TIMER_STYLE_MINIMALIST"] or "Minimalist" }
                    },
                    disabled = function() return not Module.db.enhancedTimer end,
                    onChange = function(widget, value)
                        Module.db.timerStyle = value
                        Module:UpdateSettings()
                    end,
                    column = 4
                },
                showChestTimers = {
                    key = 'showChestTimers',
                    type = 'checkbox',
                    label = L["TIMER_CHEST_MARKERS"] or "Chest Timers",
                    tooltip = L["TIMER_CHEST_MARKERS_DESC"] or "Show bonus chest time markers",
                    disabled = function() return not Module.db.enhancedTimer end,
                    onChange = function(widget, value)
                        Module.db.showChestTimers = value
                        Module:UpdateSettings()
                    end,
                    column = 4
                },
                timerFormat = {
                    key = 'timerFormat',
                    type = 'dropdown',
                    label = L["TIMER_FORMAT"] or "Timer Format",
                    tooltip = L["TIMER_FORMAT_DESC"] or "Format for displaying timer information",
                    options = {
                        { value = "REMAINING", text = L["TIMER_FORMAT_REMAINING"] or "Time Remaining Only" },
                        { value = "ELAPSED", text = L["TIMER_FORMAT_ELAPSED"] or "Time Elapsed Only" },
                        { value = "DUAL", text = L["TIMER_FORMAT_DUAL"] or "Both Elapsed and Remaining" }
                    },
                    disabled = function() return not Module.db.enhancedTimer end,
                    onChange = function(widget, value)
                        Module.db.timerFormat = value
                        Module:UpdateSettings()
                    end,
                    column = 4
                }
            },
            {
                divider3 = {
                    type = 'divider',
                    column = 12
                }
            },
            
            -- Death Tracker section
            {
                header4 = {
                    type = 'header',
                    label = L["DEATH_TRACKER"] or "Death Tracker"
                }
            },
            {
                description4 = {
                    type = 'description',
                    text = L["DEATH_TRACKER_DESC"] or "Track deaths during Mythic+ runs",
                    column = 12
                }
            },
            {
                deathTracker = {
                    key = 'deathTracker',
                    type = 'checkbox',
                    label = L["DEATH_COUNTER"] or "Death Counter",
                    tooltip = L["DEATH_COUNTER_DESC"] or "Show death counter in objective tracker",
                    onChange = function(widget, value)
                        Module.db.deathTracker = value
                        Module:UpdateSettings()
                    end,
                    column = 6
                },
                showDeathDetails = {
                    key = 'showDeathDetails',
                    type = 'checkbox',
                    label = L["DEATH_DETAILS"] or "Death Details",
                    tooltip = L["DEATH_DETAILS_DESC"] or "Show detailed death information",
                    disabled = function() return not Module.db.deathTracker end,
                    onChange = function(widget, value)
                        Module.db.showDeathDetails = value
                        Module:UpdateSettings()
                    end,
                    column = 6
                }
            },
            {
                divider4 = {
                    type = 'divider',
                    column = 12
                }
            },
            
            -- Keystone Link section
            {
                header5 = {
                    type = 'header',
                    label = L["KEYSTONE_LINK"] or "Keystone Link"
                }
            },
            {
                description5 = {
                    type = 'description',
                    text = L["KEYSTONE_LINK_DESC"] or "Enhanced keystone links in chat",
                    column = 12
                }
            },
            {
                keystoneLink = {
                    key = 'keystoneLink',
                    type = 'checkbox',
                    label = L["KEYSTONE_LINK"] or "Keystone Link",
                    tooltip = L["KEYSTONE_LINK_DESC"] or "Enhanced keystone links in chat",
                    onChange = function(widget, value)
                        Module.db.keystoneLink = value
                        Module:UpdateSettings()
                    end,
                    column = 12
                }
            },
            {
                divider5 = {
                    type = 'divider',
                    column = 12
                }
            },
            
            -- Auto Gossip section
            {
                header6 = {
                    type = 'header',
                    label = L["AUTO_GOSSIP"] or "Auto Gossip"
                }
            },
            {
                description6 = {
                    type = 'description',
                    text = L["AUTO_GOSSIP_DESC"] or "Automatically select gossip options in Mythic+ dungeons",
                    column = 12
                }
            },
            {
                autoGossip = {
                    key = 'autoGossip',
                    type = 'checkbox',
                    label = L["AUTO_GOSSIP"] or "Auto Gossip",
                    tooltip = L["AUTO_GOSSIP_DESC"] or "Automatically select gossip options in Mythic+ dungeons",
                    onChange = function(widget, value)
                        Module.db.autoGossip = value
                        Module:UpdateSettings()
                    end,
                    column = 6
                },
                showClues = {
                    key = 'showClues',
                    type = 'checkbox',
                    label = L["SHOW_CLUES"] or "Show Clues",
                    tooltip = L["SHOW_CLUES_DESC"] or "Output Court of Stars clues to party chat",
                    disabled = function() return not Module.db.autoGossip end,
                    onChange = function(widget, value)
                        Module.db.showClues = value
                        Module:UpdateSettings()
                    end,
                    column = 6
                }
            },
            {
                divider6 = {
                    type = 'divider',
                    column = 12
                }
            },
            
            -- Season 2 section
            {
                header7 = {
                    type = 'header',
                    label = L["TWW_SEASON2"] or "The War Within Season 2"
                }
            },
            {
                description7 = {
                    type = 'description',
                    text = L["TWW_SEASON2_DESC"] or "Configuration for The War Within Season 2 enemy forces",
                    column = 12
                }
            },
            {
                showSeasonNotification = {
                    key = 'showSeasonNotification',
                    type = 'checkbox',
                    label = L["TWW_SHOW_SEASON_NOTIFICATION"] or "Show Season Notification",
                    tooltip = L["TWW_SHOW_SEASON_NOTIFICATION_DESC"] or "Show a notification about Season 2 support when loading",
                    onChange = function(widget, value)
                        Module.db.showSeasonNotification = value
                        Module:UpdateSettings()
                    end,
                    column = 6
                },
                exportEnemyForces = {
                    key = 'exportEnemyForces',
                    type = 'execute',
                    label = L["TWW_EXPORT_ENEMY_FORCES"] or "Export Enemy Forces",
                    tooltip = L["TWW_EXPORT_ENEMY_FORCES_DESC"] or "Export your enemy forces database",
                    func = function()
                        Module:ExportEnemyForces()
                    end,
                    column = 6
                }
            },
            {
                importEnemyForces = {
                    key = 'importEnemyForces',
                    type = 'execute',
                    label = L["TWW_IMPORT_ENEMY_FORCES"] or "Import Enemy Forces",
                    tooltip = L["TWW_IMPORT_ENEMY_FORCES_DESC"] or "Import enemy forces values from a string",
                    func = function()
                        Module:ImportEnemyForces()
                    end,
                    column = 6
                },
                resetEnemyForces = {
                    key = 'resetEnemyForces',
                    type = 'execute',
                    label = L["TWW_RESET_ENEMY_FORCES"] or "Reset Enemy Forces",
                    tooltip = L["TWW_RESET_ENEMY_FORCES_DESC"] or "Reset enemy forces to default values",
                    func = function()
                        Module:ResetEnemyForces()
                    end,
                    column = 6
                }
            },
            {
                divider7 = {
                    type = 'divider',
                    column = 12
                }
            },
            
            -- Season 2 dungeons section
            {
                header8 = {
                    type = 'header',
                    label = L["TWW_DUNGEONS"] or "Season 2 Dungeons"
                }
            },
            {
                description8 = {
                    type = 'description',
                    text = L["TWW_DUNGEONS_DESC"] or "Show enemy forces values in Season 2 dungeons",
                    column = 12
                }
            },
            {
                darkreach = {
                    key = 'darkreach',
                    type = 'checkbox',
                    label = L["TWW_DARKREACH"] or "Darkreach Depths",
                    tooltip = L["TWW_DARKREACH_DESC"] or "Show enemy forces values in Darkreach Depths",
                    onChange = function(widget, value)
                        if not Module.db.dungeons then Module.db.dungeons = {} end
                        Module.db.dungeons[2579] = value
                        Module:UpdateSettings()
                    end,
                    column = 4
                },
                dawnbreaker = {
                    key = 'dawnbreaker',
                    type = 'checkbox',
                    label = L["TWW_DAWNBREAKER"] or "The Dawnbreaker",
                    tooltip = L["TWW_DAWNBREAKER_DESC"] or "Show enemy forces values in The Dawnbreaker",
                    onChange = function(widget, value)
                        if not Module.db.dungeons then Module.db.dungeons = {} end
                        Module.db.dungeons[2580] = value
                        Module:UpdateSettings()
                    end,
                    column = 4
                }
            },
            {
                ataldazar = {
                    key = 'ataldazar',
                    type = 'checkbox',
                    label = L["TWW_ATALDAZAR"] or "Atal'Dazar",
                    tooltip = L["TWW_ATALDAZAR_DESC"] or "Show enemy forces values in Atal'Dazar",
                    onChange = function(widget, value)
                        if not Module.db.dungeons then Module.db.dungeons = {} end
                        Module.db.dungeons[968] = value
                        Module:UpdateSettings()
                    end,
                    column = 4
                },
                blackrookhold = {
                    key = 'blackrookhold',
                    type = 'checkbox',
                    label = L["TWW_BLACKROOKHOLD"] or "Black Rook Hold",
                    tooltip = L["TWW_BLACKROOKHOLD_DESC"] or "Show enemy forces values in Black Rook Hold",
                    onChange = function(widget, value)
                        if not Module.db.dungeons then Module.db.dungeons = {} end
                        Module.db.dungeons[1501] = value
                        Module:UpdateSettings()
                    end,
                    column = 4
                }
            },
            {
                waycrestmanor = {
                    key = 'waycrestmanor',
                    type = 'checkbox',
                    label = L["TWW_WAYCRESTMANOR"] or "Waycrest Manor",
                    tooltip = L["TWW_WAYCRESTMANOR_DESC"] or "Show enemy forces values in Waycrest Manor",
                    onChange = function(widget, value)
                        if not Module.db.dungeons then Module.db.dungeons = {} end
                        Module.db.dungeons[1862] = value
                        Module:UpdateSettings()
                    end,
                    column = 4
                },
                everbloom = {
                    key = 'everbloom',
                    type = 'checkbox',
                    label = L["TWW_EVERBLOOM"] or "Everbloom",
                    tooltip = L["TWW_EVERBLOOM_DESC"] or "Show enemy forces values in Everbloom",
                    onChange = function(widget, value)
                        if not Module.db.dungeons then Module.db.dungeons = {} end
                        Module.db.dungeons[1279] = value
                        Module:UpdateSettings()
                    end,
                    column = 4
                }
            },
            {
                theaterofpain = {
                    key = 'theaterofpain',
                    type = 'checkbox',
                    label = L["TWW_THEATEROFPAIN"] or "Theater of Pain",
                    tooltip = L["TWW_THEATEROFPAIN_DESC"] or "Show enemy forces values in Theater of Pain",
                    onChange = function(widget, value)
                        if not Module.db.dungeons then Module.db.dungeons = {} end
                        Module.db.dungeons[1683] = value
                        Module:UpdateSettings()
                    end,
                    column = 4
                },
                mechagonworkshop = {
                    key = 'mechagonworkshop',
                    type = 'checkbox',
                    label = L["TWW_MECHAGONWORKSHOP"] or "Operation: Mechagon - Workshop",
                    tooltip = L["TWW_MECHAGONWORKSHOP_DESC"] or "Show enemy forces values in Operation: Mechagon - Workshop",
                    onChange = function(widget, value)
                        if not Module.db.dungeons then Module.db.dungeons = {} end
                        Module.db.dungeons[2097] = value
                        Module:UpdateSettings()
                    end,
                    column = 4
                }
            }
        }
    }
    
    -- Register the layout with Phoenix_UI
    Phoenix_UI.configOptions["MythicPlus"] = layout
    
    -- If the ConfigSystem is available, register with it too
    if Phoenix_UI.ConfigSystem and Phoenix_UI.ConfigSystem.RegisterLayout then
        Phoenix_UI.ConfigSystem:RegisterLayout("MythicPlus", layout)
    end
end

-- Initialize the config module
function Config:OnInitialize()
    -- Set up configuration when Phoenix_UI is ready
    if Phoenix_UI.configReady then
        self:SetupConfig()
    else
        -- Wait for Phoenix_UI config to be ready
        Phoenix_UI:RegisterMessage("PHOENIX_UI_CONFIG_READY", function()
            self:SetupConfig()
        end)
    end
end 