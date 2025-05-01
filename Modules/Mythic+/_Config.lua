-- Phoenix_UI: Mythic+ Module - Configuration
local addonName, Phoenix = ...

-- Get the module
local Module = Phoenix.Modules.MythicPlus
if not Module then 
    print("Phoenix UI WARNING: Mythic+ module not found, configuration will not work correctly.")
    return 
end

-- Ensure Module.db exists to prevent nil errors
if not Module.db then
    print("Phoenix UI WARNING: Mythic+ module database not found, creating fallback.")
    Module.db = {
        profile = {
            enabled = true,
            showTimer = true,
            showObjectives = true,
            deathPenalty = true,
            enhanceKeystones = true,
            integrateWithPhoenix = true,
            progressFormat = "PERCENTAGE_AND_VALUE",
            timerFormat = "REMAINING",
            showEnemyTooltip = true,
            showChestTimers = true,
            -- Add other default settings as needed
        }
    }
end

-- If Module.db isn't a proper table with a profile, fix it
if type(Module.db) ~= "table" or type(Module.db.profile) ~= "table" then
    print("Phoenix UI WARNING: Mythic+ module database structure invalid, repairing.")
    Module.db = {
        profile = Module.db.profile or {
            enabled = true,
            showTimer = true,
            showObjectives = true,
            deathPenalty = true,
            enhanceKeystones = true,
            integrateWithPhoenix = true,
            progressFormat = "PERCENTAGE_AND_VALUE",
            timerFormat = "REMAINING",
            showEnemyTooltip = true,
            showChestTimers = true,
        }
    }
end

-- Get localization
local L = Module.L or Phoenix.L or {}

-- Configuration module
local Config = Module:NewModule("Config")

-- Safe getter function to prevent errors
local function SafeGet(path, default)
    if not Module.db or not Module.db.profile then return default end
    
    local keys = {strsplit(".", path)}
    local value = Module.db.profile
    
    for i=1, #keys do
        if type(value) ~= "table" then return default end
        value = value[keys[i]]
        if value == nil then return default end
    end
    
    return value
end

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
                        get = function() return SafeGet("enabled", true) end,
                        set = function(info, value)
                            if not Module.db or not Module.db.profile then 
                                print("Phoenix UI ERROR: Cannot save Mythic+ settings, database not initialized.")
                                return 
                            end
                            
                            Module.db.profile.enabled = value
                            
                            if Module.UpdateSettings then
                                Module:UpdateSettings()
                            end
                            
                            -- If we're disabling the module, trigger a message
                            if not value then
                                Module:SendMessage("PHOENIX_MYTHICPLUS_DISABLED")
                            else
                                Module:SendMessage("PHOENIX_MYTHICPLUS_ENABLED")
                            end
                            
                            -- Notify the user
                            if value then
                                Module:Print(L["MYTHIC_PLUS"] .. " " .. (L["ENABLED"] or "enabled"))
                            else
                                Module:Print(L["MYTHIC_PLUS"] .. " " .. (L["DISABLED"] or "disabled"))
                            end
                        end
                    },
                    enabledInfo = {
                        type = "description",
                        name = "|cffff8800" .. L["MYTHIC_PLUS_ENABLE_DESC"] or "Toggling this option will enable or disable all Mythic+ enhancements." .. "|r",
                        order = 4,
                        fontSize = "medium",
                        hidden = function() return Module.db.profile.enabled end,
                    },
                    separator1 = {
                        type = "header",
                        name = "",
                        order = 10,
                        hidden = function() return not Module.db.profile.enabled end,
                    },
                    featureSection = {
                        type = "description",
                        name = L["MYTHIC_PLUS_FEATURES"] or "Individual Features",
                        order = 11,
                        fontSize = "medium",
                        hidden = function() return not Module.db.profile.enabled end,
                    },
                    showTimer = {
                        type = "toggle",
                        name = L["TIMER"] or "Timer",
                        desc = L["TIMER_DESC"] or "Enhanced timer display",
                        order = 12,
                        width = "half",
                        hidden = function() return not Module.db.profile.enabled end,
                        get = function() return Module.db.profile.showTimer end,
                        set = function(info, value)
                            Module.db.profile.showTimer = value
                            Module:UpdateSettings()
                        end
                    },
                    showObjectives = {
                        type = "toggle",
                        name = L["ENEMY_FORCES"] or "Enemy Forces",
                        desc = L["ENEMY_FORCES_DESC"] or "Track progress towards enemy forces requirement",
                        order = 13,
                        width = "half",
                        hidden = function() return not Module.db.profile.enabled end,
                        get = function() return Module.db.profile.showObjectives end,
                        set = function(info, value)
                            Module.db.profile.showObjectives = value
                            Module:UpdateSettings()
                        end
                    },
                    deathPenalty = {
                        type = "toggle",
                        name = L["DEATH_TRACKER"] or "Death Tracker",
                        desc = L["DEATH_TRACKER_DESC"] or "Track deaths during Mythic+ runs",
                        order = 14,
                        width = "half",
                        hidden = function() return not Module.db.profile.enabled end,
                        get = function() return Module.db.profile.deathPenalty end,
                        set = function(info, value)
                            Module.db.profile.deathPenalty = value
                            Module:UpdateSettings()
                        end
                    },
                    enhanceKeystones = {
                        type = "toggle",
                        name = L["KEYSTONE_LINK"] or "Keystone Link",
                        desc = L["KEYSTONE_LINK_DESC"] or "Enhanced keystone links in chat",
                        order = 15,
                        width = "half",
                        hidden = function() return not Module.db.profile.enabled end,
                        get = function() return Module.db.profile.enhanceKeystones end,
                        set = function(info, value)
                            Module.db.profile.enhanceKeystones = value
                            Module:UpdateSettings()
                        end
                    },
                    separator2 = {
                        type = "header",
                        name = "",
                        order = 20,
                        hidden = function() return not Module.db.profile.enabled end,
                    },
                    integrationSection = {
                        type = "description",
                        name = L["MYTHIC_PLUS_INTEGRATION"] or "Integration Settings",
                        order = 21,
                        fontSize = "medium",
                        hidden = function() return not Module.db.profile.enabled end,
                    },
                    integrateWithPhoenix = {
                        type = "toggle",
                        name = L["MYTHIC_PLUS_INTEGRATE_PHOENIX"] or "Add to Phoenix UI Tab",
                        desc = L["MYTHIC_PLUS_INTEGRATE_PHOENIX_DESC"] or "Add Mythic+ settings to the main Phoenix UI configuration panel",
                        order = 22,
                        width = "full",
                        hidden = function() return not Module.db.profile.enabled end,
                        get = function() return Module.db.profile.integrateWithPhoenix end,
                        set = function(info, value)
                            Module.db.profile.integrateWithPhoenix = value
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
                        hidden = function() return not Module.db.profile.enabled end,
                    },
                }
            },
            progressTracker = {
                type = "group",
                name = L["ENEMY_FORCES"] or "Enemy Forces",
                order = 2,
                disabled = function() return not Module.db.profile.enabled or not Module.db.profile.showObjectives end,
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
                        get = function() return Module.db.profile.progressFormat end,
                        set = function(info, value)
                            Module.db.profile.progressFormat = value
                            Module:UpdateSettings()
                        end
                    },
                    showEnemyTooltip = {
                        type = "toggle",
                        name = L["ENEMY_FORCES_TOOLTIP"] or "Show progress value on enemy tooltips",
                        desc = L["ENEMY_FORCES_TOOLTIP_DESC"] or "Display the amount of enemy forces progress each mob gives",
                        order = 4,
                        width = "full",
                        get = function() return Module.db.profile.showEnemyTooltip end,
                        set = function(info, value)
                            Module.db.profile.showEnemyTooltip = value
                            Module:UpdateSettings()
                        end
                    }
                }
            },
            timer = {
                type = "group",
                name = L["TIMER"] or "Timer",
                order = 3,
                disabled = function() return not Module.db.profile.enabled or not Module.db.profile.showTimer end,
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
                        get = function() return Module.db.profile.enhancedTimer end,
                        set = function(info, value)
                            Module.db.profile.enhancedTimer = value
                            Module:UpdateSettings()
                        end
                    },
                    timerStyle = {
                        type = "select",
                        name = L["TIMER_STYLE"] or "Timer Style",
                        desc = L["TIMER_STYLE_DESC"] or "Visual style of the timer",
                        order = 4,
                        width = "double",
                        disabled = function() return not Module.db.profile.enhancedTimer end,
                        values = {
                            ["PHOENIX"] = L["TIMER_STYLE_PHOENIX"] or "Phoenix UI",
                            ["CLASSIC"] = L["TIMER_STYLE_CLASSIC"] or "Classic",
                            ["MINIMALIST"] = L["TIMER_STYLE_MINIMALIST"] or "Minimalist"
                        },
                        get = function() return Module.db.profile.timerStyle end,
                        set = function(info, value)
                            Module.db.profile.timerStyle = value
                            Module:UpdateSettings()
                        end
                    },
                    showChestTimers = {
                        type = "toggle",
                        name = L["TIMER_CHEST_MARKERS"] or "Chest Timers",
                        desc = L["TIMER_CHEST_MARKERS_DESC"] or "Show bonus chest time markers",
                        order = 5,
                        width = "full",
                        disabled = function() return not Module.db.profile.enhancedTimer end,
                        get = function() return Module.db.profile.showChestTimers end,
                        set = function(info, value)
                            Module.db.profile.showChestTimers = value
                            Module:UpdateSettings()
                        end
                    },
                    timerFormat = {
                        type = "select",
                        name = L["TIMER_FORMAT"] or "Timer Format",
                        desc = L["TIMER_FORMAT_DESC"] or "Format for displaying timer information",
                        order = 6,
                        width = "double",
                        disabled = function() return not Module.db.profile.enhancedTimer end,
                        values = {
                            ["REMAINING"] = L["TIMER_FORMAT_REMAINING"] or "Time Remaining Only",
                            ["ELAPSED"] = L["TIMER_FORMAT_ELAPSED"] or "Time Elapsed Only",
                            ["DUAL"] = L["TIMER_FORMAT_DUAL"] or "Both Elapsed and Remaining"
                        },
                        get = function() return Module.db.profile.timerFormat or "REMAINING" end,
                        set = function(info, value)
                            Module.db.profile.timerFormat = value
                            Module:UpdateSettings()
                        end
                    }
                }
            },
            deathTracker = {
                type = "group",
                name = L["DEATH_TRACKER"] or "Death Tracker",
                order = 4,
                disabled = function() return not Module.db.profile.enabled or not Module.db.profile.deathPenalty end,
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
                        get = function() return Module.db.profile.deathTracker end,
                        set = function(info, value)
                            Module.db.profile.deathTracker = value
                            Module:UpdateSettings()
                        end
                    },
                    showDeathDetails = {
                        type = "toggle",
                        name = L["DEATH_DETAILS"] or "Death Details",
                        desc = L["DEATH_DETAILS_DESC"] or "Show detailed death information",
                        order = 4,
                        width = "full",
                        disabled = function() return not Module.db.profile.deathTracker end,
                        get = function() return Module.db.profile.showDeathDetails end,
                        set = function(info, value)
                            Module.db.profile.showDeathDetails = value
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
                        get = function() return Module.db.profile.keystoneLink end,
                        set = function(info, value)
                            Module.db.profile.keystoneLink = value
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
                        get = function() return Module.db.profile.autoGossip end,
                        set = function(info, value)
                            Module.db.profile.autoGossip = value
                            Module:UpdateSettings()
                        end
                    },
                    showClues = {
                        type = "toggle",
                        name = L["SHOW_CLUES"] or "Show Clues",
                        desc = L["SHOW_CLUES_DESC"] or "Output Court of Stars clues to party chat",
                        order = 4,
                        width = "full",
                        disabled = function() return not Module.db.profile.autoGossip end,
                        get = function() return Module.db.profile.showClues end,
                        set = function(info, value)
                            Module.db.profile.showClues = value
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
                        get = function() return Module.db.profile.showSeasonNotification end,
                        set = function(info, value)
                            Module.db.profile.showSeasonNotification = value
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
                        get = function() return Module.db.profile.dungeons and Module.db.profile.dungeons[2579] or true end,
                        set = function(info, value)
                            if not Module.db.profile.dungeons then Module.db.profile.dungeons = {} end
                            Module.db.profile.dungeons[2579] = value
                            Module:UpdateSettings()
                        end
                    },
                    dawnbreaker = {
                        type = "toggle",
                        name = L["TWW_DAWNBREAKER"] or "The Dawnbreaker",
                        desc = L["TWW_DAWNBREAKER_DESC"] or "Show enemy forces values in The Dawnbreaker",
                        order = 12,
                        width = "full",
                        get = function() return Module.db.profile.dungeons and Module.db.profile.dungeons[2580] or true end,
                        set = function(info, value)
                            if not Module.db.profile.dungeons then Module.db.profile.dungeons = {} end
                            Module.db.profile.dungeons[2580] = value
                            Module:UpdateSettings()
                        end
                    },
                    ataldazar = {
                        type = "toggle",
                        name = L["TWW_ATALDAZAR"] or "Atal'Dazar",
                        desc = L["TWW_ATALDAZAR_DESC"] or "Show enemy forces values in Atal'Dazar",
                        order = 13,
                        width = "full",
                        get = function() return Module.db.profile.dungeons and Module.db.profile.dungeons[968] or true end,
                        set = function(info, value)
                            if not Module.db.profile.dungeons then Module.db.profile.dungeons = {} end
                            Module.db.profile.dungeons[968] = value
                            Module:UpdateSettings()
                        end
                    },
                    blackrookhold = {
                        type = "toggle",
                        name = L["TWW_BLACKROOKHOLD"] or "Black Rook Hold",
                        desc = L["TWW_BLACKROOKHOLD_DESC"] or "Show enemy forces values in Black Rook Hold",
                        order = 14,
                        width = "full",
                        get = function() return Module.db.profile.dungeons and Module.db.profile.dungeons[1501] or true end,
                        set = function(info, value)
                            if not Module.db.profile.dungeons then Module.db.profile.dungeons = {} end
                            Module.db.profile.dungeons[1501] = value
                            Module:UpdateSettings()
                        end
                    },
                    waycrestmanor = {
                        type = "toggle",
                        name = L["TWW_WAYCRESTMANOR"] or "Waycrest Manor",
                        desc = L["TWW_WAYCRESTMANOR_DESC"] or "Show enemy forces values in Waycrest Manor",
                        order = 15,
                        width = "full",
                        get = function() return Module.db.profile.dungeons and Module.db.profile.dungeons[1862] or true end,
                        set = function(info, value)
                            if not Module.db.profile.dungeons then Module.db.profile.dungeons = {} end
                            Module.db.profile.dungeons[1862] = value
                            Module:UpdateSettings()
                        end
                    },
                    everbloom = {
                        type = "toggle",
                        name = L["TWW_EVERBLOOM"] or "Everbloom",
                        desc = L["TWW_EVERBLOOM_DESC"] or "Show enemy forces values in Everbloom",
                        order = 16,
                        width = "full",
                        get = function() return Module.db.profile.dungeons and Module.db.profile.dungeons[1279] or true end,
                        set = function(info, value)
                            if not Module.db.profile.dungeons then Module.db.profile.dungeons = {} end
                            Module.db.profile.dungeons[1279] = value
                            Module:UpdateSettings()
                        end
                    },
                    theaterofpain = {
                        type = "toggle",
                        name = L["TWW_THEATEROFPAIN"] or "Theater of Pain",
                        desc = L["TWW_THEATEROFPAIN_DESC"] or "Show enemy forces values in Theater of Pain",
                        order = 19,
                        width = "full",
                        get = function() return Module.db.profile.dungeons and Module.db.profile.dungeons[1683] or true end,
                        set = function(info, value)
                            if not Module.db.profile.dungeons then Module.db.profile.dungeons = {} end
                            Module.db.profile.dungeons[1683] = value
                            Module:UpdateSettings()
                        end
                    },
                    mechagonworkshop = {
                        type = "toggle",
                        name = L["TWW_MECHAGONWORKSHOP"] or "Operation: Mechagon - Workshop",
                        desc = L["TWW_MECHAGONWORKSHOP_DESC"] or "Show enemy forces values in Operation: Mechagon - Workshop",
                        order = 20,
                        width = "full",
                        get = function() return Module.db.profile.dungeons and Module.db.profile.dungeons[2097] or true end,
                        set = function(info, value)
                            if not Module.db.profile.dungeons then Module.db.profile.dungeons = {} end
                            Module.db.profile.dungeons[2097] = value
                            Module:UpdateSettings()
                        end
                    }
                }
            }
        }
    }
    
    -- Ensure Phoenix_UI.configOptions exists before using it
    if not Phoenix_UI.configOptions then
        Phoenix_UI.configOptions = {}
    end
    
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
    if not Phoenix_UI then return end
    if not Phoenix_UI.configOptions then
        Phoenix_UI.configOptions = {}
    end
    
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
                        Module.db.profile.enabled = value
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
                        Module.db.profile.progressFormat = value
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
                        Module.db.profile.showEnemyTooltip = value
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
                        Module.db.profile.enhancedTimer = value
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
                    disabled = function() return not Module.db.profile.enhancedTimer end,
                    onChange = function(widget, value)
                        Module.db.profile.timerStyle = value
                        Module:UpdateSettings()
                    end,
                    column = 4
                },
                showChestTimers = {
                    key = 'showChestTimers',
                    type = 'checkbox',
                    label = L["TIMER_CHEST_MARKERS"] or "Chest Timers",
                    tooltip = L["TIMER_CHEST_MARKERS_DESC"] or "Show bonus chest time markers",
                    disabled = function() return not Module.db.profile.enhancedTimer end,
                    onChange = function(widget, value)
                        Module.db.profile.showChestTimers = value
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
                    disabled = function() return not Module.db.profile.enhancedTimer end,
                    onChange = function(widget, value)
                        Module.db.profile.timerFormat = value
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
                        Module.db.profile.deathTracker = value
                        Module:UpdateSettings()
                    end,
                    column = 6
                },
                showDeathDetails = {
                    key = 'showDeathDetails',
                    type = 'checkbox',
                    label = L["DEATH_DETAILS"] or "Death Details",
                    tooltip = L["DEATH_DETAILS_DESC"] or "Show detailed death information",
                    disabled = function() return not Module.db.profile.deathTracker end,
                    onChange = function(widget, value)
                        Module.db.profile.showDeathDetails = value
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
                        Module.db.profile.keystoneLink = value
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
                        Module.db.profile.autoGossip = value
                        Module:UpdateSettings()
                    end,
                    column = 6
                },
                showClues = {
                    key = 'showClues',
                    type = 'checkbox',
                    label = L["SHOW_CLUES"] or "Show Clues",
                    tooltip = L["SHOW_CLUES_DESC"] or "Output Court of Stars clues to party chat",
                    disabled = function() return not Module.db.profile.autoGossip end,
                    onChange = function(widget, value)
                        Module.db.profile.showClues = value
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
                        Module.db.profile.showSeasonNotification = value
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
                        if not Module.db.profile.dungeons then Module.db.profile.dungeons = {} end
                        Module.db.profile.dungeons[2579] = value
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
                        if not Module.db.profile.dungeons then Module.db.profile.dungeons = {} end
                        Module.db.profile.dungeons[2580] = value
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
                        if not Module.db.profile.dungeons then Module.db.profile.dungeons = {} end
                        Module.db.profile.dungeons[968] = value
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
                        if not Module.db.profile.dungeons then Module.db.profile.dungeons = {} end
                        Module.db.profile.dungeons[1501] = value
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
                        if not Module.db.profile.dungeons then Module.db.profile.dungeons = {} end
                        Module.db.profile.dungeons[1862] = value
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
                        if not Module.db.profile.dungeons then Module.db.profile.dungeons = {} end
                        Module.db.profile.dungeons[1279] = value
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
                        if not Module.db.profile.dungeons then Module.db.profile.dungeons = {} end
                        Module.db.profile.dungeons[1683] = value
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
                        if not Module.db.profile.dungeons then Module.db.profile.dungeons = {} end
                        Module.db.profile.dungeons[2097] = value
                        Module:UpdateSettings()
                    end,
                    column = 4
                }
            }
        }
    }
    
    -- Register the layout with Phoenix_UI
    if not Phoenix_UI.configOptions then
        Phoenix_UI.configOptions = {}
    end
    Phoenix_UI.configOptions["MythicPlus"] = layout
    
    -- If the ConfigSystem is available, register with it too
    if Phoenix_UI.ConfigSystem and Phoenix_UI.ConfigSystem.RegisterLayout then
        Phoenix_UI.ConfigSystem:RegisterLayout("MythicPlus", layout)
    end
    
    return layout
end

function Config:OnInitialize()
    self:SetupConfig()
    
    -- Ensure the layout is loaded and registered
    if Phoenix_UI and Phoenix_UI.layouts and Phoenix_UI.layouts.MythicPlus then
        -- Make sure the module can access the layout
        local MythicPlus = Phoenix:GetModule("MythicPlus") or Phoenix_UI:GetModule("MythicPlus", true)
        if MythicPlus then
            MythicPlus.layout = Phoenix_UI.layouts.MythicPlus
        end
    end
end

-- Ensure update settings method exists
if Module and not Module.UpdateSettings then
    Module.UpdateSettings = function(self)
        -- Notify all submodules to update their settings
        self:SendMessage("PHOENIX_MYTHICPLUS_SETTINGS_CHANGED")
        -- If we have Timer module, update its settings
        if self:GetModule("Timer") then
            self:GetModule("Timer"):UpdateSettings()
        end
        -- If we have Objectives module, update its settings
        if self:GetModule("Objectives") then
            self:GetModule("Objectives"):UpdateSettings()
        end
    end
end

-- NO LONGER NEEDED: The modules should be properly registered earlier
-- if not Phoenix_UI:GetModule("MythicPlus", true) then
--     local MythicPlus = Phoenix_UI:NewModule("MythicPlus", "AceEvent-3.0", "AceHook-3.0", "AceConsole-3.0")
--     MythicPlus.Config = Config
-- end