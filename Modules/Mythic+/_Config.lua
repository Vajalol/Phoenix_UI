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
                        end
                    },
                    separator1 = {
                        type = "header",
                        name = "",
                        order = 10
                    },
                }
            },
            progressTracker = {
                type = "group",
                name = L["ENEMY_FORCES"] or "Enemy Forces",
                order = 2,
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
                    }
                }
            },
            deathTracker = {
                type = "group",
                name = L["DEATH_TRACKER"] or "Death Tracker",
                order = 4,
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