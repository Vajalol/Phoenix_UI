-- Phoenix_UI: Mythic+ Layout for Phoenix UI integration
local Layout = Phoenix_UI:NewModule('Config.Layout.MythicPlus')

-- Get the Mythic+ module
local MythicPlus = Phoenix_UI:GetModule('MythicPlus')

function Layout:OnEnable()
    -- Skip if the Mythic+ module is not available
    if not MythicPlus then return end
    
    -- Get the database from the module
    local db = MythicPlus.db.profile
    
    -- Get localization
    local L = MythicPlus.L or {}
    
    -- Layout configuration
    Layout.layout = {
        layoutConfig = { padding = { top = 15 } },
        database = db,
        rows = {
            {
                header = {
                    type = 'header',
                    label = L["MYTHIC_PLUS"] or 'Mythic+ Module'
                }
            },
            {
                desc = {
                    type = 'description',
                    label = L["MYTHIC_PLUS_DESC"] or [[Enhanced Mythic+ features for Phoenix UI.

|cffff9900Note: You can configure all settings below even without having a keystone or being in a Mythic+ dungeon. Your configured settings will be automatically applied when you obtain a keystone or enter a Mythic+ dungeon.|r

Some features might appear disabled until their prerequisites are met, but all configurations are saved.]],
                    column = 12
                }
            },
            {
                keystoneStatus = {
                    type = 'text',
                    label = function()
                        local MythicPlus = Phoenix_UI:GetModule("MythicPlus")
                        if MythicPlus and MythicPlus:ShouldEnableOptions() then
                            return '|cff00ff00You have an active keystone or are in a Mythic+ dungeon. All options are enabled.|r'
                        end
                        return '|cffff9900You do not currently have a keystone or are not in a Mythic+ dungeon. Configure options below and they will be applied when conditions are met.|r'
                    end,
                    fontSize = 'medium',
                    fontStyle = 'normal',
                    column = 12,
                    order = 1
                }
            },
            {
                enabled = {
                    key = 'enabled',
                    type = 'checkbox',
                    label = ENABLE,
                    tooltip = L["MYTHIC_PLUS_ENABLE_DESC"] or 'Toggle all Mythic+ enhancements',
                    column = 12,
                    order = 2
                }
            },
            {
                header = {
                    type = 'header',
                    label = L["MYTHIC_PLUS_FEATURES"] or 'Individual Features'
                }
            },
            {
                showTimer = {
                    key = 'showTimer',
                    type = 'checkbox',
                    label = L["TIMER"] or 'Timer',
                    tooltip = L["TIMER_DESC"] or 'Enhanced timer display',
                    column = 6,
                    order = 1,
                    disabled = function() return not MythicPlus:ShouldEnableOptions() or not db.enabled end
                },
                showObjectives = {
                    key = 'showObjectives',
                    type = 'checkbox',
                    label = L["ENEMY_FORCES"] or 'Enemy Forces',
                    tooltip = L["ENEMY_FORCES_DESC"] or 'Track progress towards enemy forces requirement',
                    column = 6,
                    order = 2,
                    disabled = function() return not MythicPlus:ShouldEnableOptions() or not db.enabled end
                }
            },
            {
                deathPenalty = {
                    key = 'deathPenalty',
                    type = 'checkbox',
                    label = L["DEATH_TRACKER"] or 'Death Tracker',
                    tooltip = L["DEATH_TRACKER_DESC"] or 'Track deaths during Mythic+ runs',
                    column = 6,
                    order = 3,
                    disabled = function() return not MythicPlus:ShouldEnableOptions() or not db.enabled end
                },
                enhanceKeystones = {
                    key = 'enhanceKeystones',
                    type = 'checkbox',
                    label = L["KEYSTONE_LINK"] or 'Keystone Link',
                    tooltip = L["KEYSTONE_LINK_DESC"] or 'Enhanced keystone links in chat',
                    column = 6,
                    order = 4,
                    disabled = function() return not MythicPlus:ShouldEnableOptions() or not db.enabled end
                }
            },
            {
                header = {
                    type = 'header',
                    label = L["TIMER"] or 'Timer'
                }
            },
            {
                enhancedTimer = {
                    key = 'enhancedTimer',
                    type = 'checkbox',
                    label = L["TIMER"] or 'Enhanced Timer',
                    tooltip = L["TIMER_DESC"] or 'Enhanced timer display',
                    column = 6,
                    order = 1,
                    disabled = function() return not MythicPlus:ShouldEnableOptions() or not db.enabled or not db.showTimer end
                },
                timerStyle = {
                    key = 'timerStyle',
                    type = 'dropdown',
                    label = L["TIMER_STYLE"] or 'Timer Style',
                    tooltip = L["TIMER_STYLE_DESC"] or 'Visual style of the timer',
                    column = 6,
                    order = 2,
                    disabled = function() return not MythicPlus:ShouldEnableOptions() or not db.enabled or not db.showTimer or not db.enhancedTimer end,
                    options = {
                        ["PHOENIX"] = L["TIMER_STYLE_PHOENIX"] or "Phoenix UI",
                        ["CLASSIC"] = L["TIMER_STYLE_CLASSIC"] or "Classic",
                        ["MINIMALIST"] = L["TIMER_STYLE_MINIMALIST"] or "Minimalist"
                    }
                }
            },
            {
                showChestTimers = {
                    key = 'showChestTimers',
                    type = 'checkbox',
                    label = L["TIMER_CHEST_MARKERS"] or 'Chest Timers',
                    tooltip = L["TIMER_CHEST_MARKERS_DESC"] or 'Show bonus chest time markers',
                    column = 6,
                    order = 3,
                    disabled = function() return not MythicPlus:ShouldEnableOptions() or not db.enabled or not db.showTimer or not db.enhancedTimer end
                },
                lockTimerFrame = {
                    key = 'lockTimerFrame',
                    type = 'checkbox',
                    label = L["LOCK_TIMER_FRAME"] or 'Lock Timer Frame',
                    tooltip = L["LOCK_TIMER_FRAME_DESC"] or 'Prevent the timer frame from being moved',
                    column = 6,
                    order = 4,
                    disabled = function() return not MythicPlus:ShouldEnableOptions() or not db.enabled or not db.showTimer or not db.enhancedTimer end
                }
            },
            {
                header = {
                    type = 'header',
                    label = L["ENEMY_FORCES"] or 'Enemy Forces'
                }
            },
            {
                progressFormat = {
                    key = 'progressFormat',
                    type = 'dropdown',
                    label = L["ENEMY_FORCES_FORMAT"] or 'Format',
                    tooltip = L["ENEMY_FORCES_FORMAT_DESC"] or 'How to display enemy forces progress',
                    column = 6,
                    order = 1,
                    disabled = function() return not MythicPlus:ShouldEnableOptions() or not db.enabled or not db.showObjectives end,
                    options = {
                        ["PERCENTAGE_ONLY"] = L["ENEMY_FORCES_PERCENTAGE"] or "Percentage only",
                        ["VALUE_ONLY"] = L["ENEMY_FORCES_VALUE"] or "Value only",
                        ["PERCENTAGE_AND_VALUE"] = L["ENEMY_FORCES_BOTH"] or "Percentage and value"
                    }
                },
                showEnemyTooltip = {
                    key = 'showEnemyTooltip',
                    type = 'checkbox',
                    label = L["ENEMY_FORCES_TOOLTIP"] or 'Show enemy tooltip values',
                    tooltip = L["ENEMY_FORCES_TOOLTIP_DESC"] or 'Display the amount of enemy forces progress each mob gives',
                    column = 6,
                    order = 2,
                    disabled = function() return not MythicPlus:ShouldEnableOptions() or not db.enabled or not db.showObjectives end
                }
            },
            {
                header = {
                    type = 'header',
                    label = L["DEATH_TRACKER"] or 'Death Tracker'
                }
            },
            {
                deathTracker = {
                    key = 'deathTracker',
                    type = 'checkbox',
                    label = L["DEATH_COUNTER"] or 'Death Counter',
                    tooltip = L["DEATH_COUNTER_DESC"] or 'Show death counter in objective tracker',
                    column = 6,
                    order = 1,
                    disabled = function() return not MythicPlus:ShouldEnableOptions() or not db.enabled or not db.deathPenalty end
                },
                showDeathDetails = {
                    key = 'showDeathDetails',
                    type = 'checkbox',
                    label = L["DEATH_DETAILS"] or 'Death Details',
                    tooltip = L["DEATH_DETAILS_DESC"] or 'Show detailed death information',
                    column = 6,
                    order = 2,
                    disabled = function() return not MythicPlus:ShouldEnableOptions() or not db.enabled or not db.deathPenalty or not db.deathTracker end
                }
            },
            {
                header = {
                    type = 'header',
                    label = L["SEASON_DUNGEONS"] or 'Current Season Dungeons'
                }
            }
        }
    }
    
    -- Add each dungeon as a separate checkbox
    local dungeonRow = {}
    local dungeonNames = {
        [2516] = L["TWW_FLOODGATE"] or "Operation: Floodgate",
        [2451] = L["TWW_CINDERBREW"] or "Cinderbrew Meadery",
        [2579] = L["TWW_DARKFLAME"] or "Darkflame Cleft",
        [2520] = L["TWW_ROOKERY"] or "The Rookery",
        [2337] = L["TWW_PRIORY"] or "Priory of the Sacred Flame",
        [1683] = L["TWW_THEATEROFPAIN"] or "Theater of Pain",
        [2097] = L["TWW_MECHAGONWORKSHOP"] or "Operation: Mechagon - Workshop",
        [1594] = L["TWW_MOTHERLODE"] or "The MOTHERLODE!!"
    }
    
    local index = 1
    local currentRow = {}
    
    for dungeonID, dungeonName in pairs(dungeonNames) do
        currentRow["dungeon_" .. dungeonID] = {
            key = "dungeons." .. dungeonID,
            type = 'checkbox',
            label = dungeonName,
            tooltip = L["DUNGEON_TOOLTIP"]:format(dungeonName) or "Show enemy forces values in " .. dungeonName,
            column = 6,
            order = index,
            disabled = function() return not MythicPlus:ShouldEnableOptions() or not db.enabled or not db.showObjectives end
        }
        
        -- Start a new row after every 2 dungeons
        index = index + 1
        if index > 2 then
            table.insert(Layout.layout.rows, currentRow)
            currentRow = {}
            index = 1
        end
    end
    
    -- Add the last row if it has any elements
    if index > 1 then
        table.insert(Layout.layout.rows, currentRow)
    end
end

-- Add slash command to open the Mythic+ config panel
Phoenix_UI:RegisterChatCommand("puimplus", function()
    if Phoenix_UI.OpenConfig then
        Phoenix_UI:OpenConfig("MythicPlus")
    else
        Phoenix_UI:Config()
    end
end) 