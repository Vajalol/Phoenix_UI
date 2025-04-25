-- Phoenix_UI: Mythic+ Module - Localization
local addonName, Phoenix = ...

-- Get the main module
local Module = Phoenix_UI:GetModule("MythicPlus")
if not Module then return end

-- Set up localization
local L = Phoenix.L or {}
local locale = GetLocale()

-- English (default) localization
L["MYTHIC_PLUS"] = "Mythic+"
L["MYTHIC_PLUS_DESC"] = "Enhanced Mythic+ features for Phoenix UI"
L["ENABLED"] = "Enabled"
L["DISABLED"] = "Disabled"
L["MYTHIC_PLUS_ENABLE_DESC"] = "Toggling this option will enable or disable all Mythic+ enhancements."
L["MYTHIC_PLUS_FEATURES"] = "Individual Features"
L["MYTHIC_PLUS_INTEGRATION"] = "Integration Settings"
L["MYTHIC_PLUS_INTEGRATE_PHOENIX"] = "Add to Phoenix UI Tab"
L["MYTHIC_PLUS_INTEGRATE_PHOENIX_DESC"] = "Add Mythic+ settings to the main Phoenix UI configuration panel"
L["MYTHIC_PLUS_INTEGRATION_INFO"] = "Changes to this option will take effect after reloading your UI."
L["MYTHIC_PLUS_INTEGRATED"] = "Mythic+ settings integrated into Phoenix UI panel"
L["MYTHIC_PLUS_STANDALONE"] = "Mythic+ settings will use standalone panel"

-- Progress Tracker
L["ENEMY_FORCES"] = "Enemy Forces"
L["ENEMY_FORCES_DESC"] = "Track progress towards enemy forces requirement"
L["ENEMY_FORCES_FORMAT"] = "Format"
L["ENEMY_FORCES_FORMAT_DESC"] = "How to display enemy forces progress"
L["ENEMY_FORCES_PERCENTAGE"] = "Percentage only"
L["ENEMY_FORCES_VALUE"] = "Value only"
L["ENEMY_FORCES_BOTH"] = "Percentage and value"
L["ENEMY_FORCES_TOOLTIP"] = "Show progress value on enemy tooltips"
L["ENEMY_FORCES_TOOLTIP_DESC"] = "Display the amount of enemy forces progress each mob gives"
L["ENEMY_FORCES_VALUE"] = "Enemy Forces Value"
L["CURRENT_PULL"] = "Current Pull"
L["ENEMY_FORCES_SET_USAGE"] = "Usage: /setforce <npcID> <value>"
L["ENEMY_FORCES_NO_DUNGEON"] = "You must be in a dungeon to set enemy forces values"
L["ENEMY_FORCES_SET_SUCCESS"] = "Updated NPC ID %d (%s) enemy forces value from %d to %d"
L["ENEMY_FORCES_SET_FAILED"] = "Failed to update enemy forces value. Please check your syntax."
L["ENEMY_FORCES_SEASON_UPDATED"] = "Enemy forces database updated for The War Within Season 2"

-- Timer
L["TIMER"] = "Timer"
L["TIMER_DESC"] = "Enhanced timer display"
L["TIMER_STYLE"] = "Timer Style"
L["TIMER_STYLE_DESC"] = "Visual style of the timer"
L["TIMER_STYLE_PHOENIX"] = "Phoenix UI"
L["TIMER_STYLE_CLASSIC"] = "Classic"
L["TIMER_STYLE_MINIMALIST"] = "Minimalist"
L["TIMER_CHEST_MARKERS"] = "Chest Timers"
L["TIMER_CHEST_MARKERS_DESC"] = "Show bonus chest time markers"
L["TIMER_PLUS_ONE"] = "+1 Chest"
L["TIMER_PLUS_TWO"] = "+2 Chest"
L["TIMER_PLUS_THREE"] = "+3 Chest"
L["TIMER_EXPIRED"] = "Timer Expired"
L["TIMER_FORMAT"] = "Timer Format"
L["TIMER_FORMAT_DESC"] = "Format for displaying timer information"
L["TIMER_FORMAT_REMAINING"] = "Time Remaining Only"
L["TIMER_FORMAT_ELAPSED"] = "Time Elapsed Only"
L["TIMER_FORMAT_DUAL"] = "Both Elapsed and Remaining"
L["Elapsed"] = "Elapsed"
L["Remaining"] = "Remaining"

-- Death Tracker
L["DEATH_TRACKER"] = "Death Tracker"
L["DEATH_TRACKER_DESC"] = "Track deaths during Mythic+ runs"
L["DEATHS"] = "Deaths"
L["DEATH_COUNTER"] = "Death Counter"
L["DEATH_COUNTER_DESC"] = "Show death counter in objective tracker"
L["DEATH_DETAILS"] = "Death Details"
L["DEATH_DETAILS_DESC"] = "Show detailed death information"
L["TIME_LOST"] = "Time Lost"
L["TIME_PENALTY"] = "Time Penalty"
L["DEATH_RECORD"] = "%s died (%d)"

-- Keystone Link
L["KEYSTONE_LINK"] = "Keystone Link"
L["KEYSTONE_LINK_DESC"] = "Enhanced keystone links in chat"
L["KEYSTONE"] = "Keystone"
L["KEYSTONE_LEVEL"] = "Level %d"
L["KEYSTONE_DEPLETED"] = "Depleted"
L["KEYSTONE_DUNGEON"] = "Dungeon"

-- Auto Gossip
L["AUTO_GOSSIP"] = "Auto Gossip"
L["AUTO_GOSSIP_DESC"] = "Automatically select gossip options in Mythic+ dungeons"
L["SHOW_CLUES"] = "Show Clues"
L["SHOW_CLUES_DESC"] = "Output Court of Stars clues to party chat"
L["COURT_CLUE"] = "Court of Stars Clue"

-- Schedule
L["SCHEDULE"] = "Affix Schedule"
L["SCHEDULE_DESC"] = "Track weekly Mythic+ affixes"
L["CURRENT_AFFIXES"] = "Current Affixes"
L["NEXT_WEEK"] = "Next Week"

-- Affix names
L["TYRANNICAL"] = "Tyrannical"
L["FORTIFIED"] = "Fortified"
L["BOLSTERING"] = "Bolstering"
L["RAGING"] = "Raging"
L["SANGUINE"] = "Sanguine"
L["BURSTING"] = "Bursting"
L["INSPIRING"] = "Inspiring"
L["SPITEFUL"] = "Spiteful"
L["NECROTIC"] = "Necrotic"
L["EXPLOSIVE"] = "Explosive"
L["QUAKING"] = "Quaking"
L["VOLCANIC"] = "Volcanic"
L["GRIEVOUS"] = "Grievous"
L["STORMING"] = "Storming"
L["ENTANGLING"] = "Entangling"
L["AFFLICTED"] = "Afflicted"
L["INCORPOREAL"] = "Incorporeal"
L["THUNDERING"] = "Thundering"

-- The War Within Season 2
L["TWW_SEASON2"] = "The War Within S2"
L["TWW_SEASON2_DESC"] = "Configuration for The War Within Season 2 enemy forces"
L["TWW_SHOW_SEASON_NOTIFICATION"] = "Show Season Notification"
L["TWW_SHOW_SEASON_NOTIFICATION_DESC"] = "Show a notification about Season 2 support when loading"
L["TWW_EXPORT_ENEMY_FORCES"] = "Export Enemy Forces"
L["TWW_EXPORT_ENEMY_FORCES_DESC"] = "Export your enemy forces database"
L["TWW_IMPORT_ENEMY_FORCES"] = "Import Enemy Forces"
L["TWW_IMPORT_ENEMY_FORCES_DESC"] = "Import enemy forces values from a string"
L["TWW_RESET_ENEMY_FORCES"] = "Reset Enemy Forces"
L["TWW_RESET_ENEMY_FORCES_DESC"] = "Reset enemy forces to default values"
L["TWW_DUNGEONS"] = "Season 2 Dungeons"
L["TWW_DUNGEONS_DESC"] = "Show enemy forces values in Season 2 dungeons"
L["TWW_FLOODGATE"] = "Operation: Floodgate"
L["TWW_FLOODGATE_DESC"] = "Show enemy forces values in Operation: Floodgate"
L["TWW_CINDERBREW"] = "Cinderbrew Meadery"
L["TWW_CINDERBREW_DESC"] = "Show enemy forces values in Cinderbrew Meadery"
L["TWW_DARKFLAME"] = "Darkflame Cleft"
L["TWW_DARKFLAME_DESC"] = "Show enemy forces values in Darkflame Cleft"
L["TWW_ROOKERY"] = "The Rookery"
L["TWW_ROOKERY_DESC"] = "Show enemy forces values in The Rookery"
L["TWW_PRIORY"] = "Priory of the Sacred Flame"
L["TWW_PRIORY_DESC"] = "Show enemy forces values in Priory of the Sacred Flame"
L["TWW_THEATEROFPAIN"] = "Theater of Pain"
L["TWW_THEATEROFPAIN_DESC"] = "Show enemy forces values in Theater of Pain"
L["TWW_MECHAGONWORKSHOP"] = "Operation: Mechagon - Workshop"
L["TWW_MECHAGONWORKSHOP_DESC"] = "Show enemy forces values in Operation: Mechagon - Workshop"
L["TWW_MOTHERLODE"] = "The MOTHERLODE!!"
L["TWW_MOTHERLODE_DESC"] = "Show enemy forces values in The MOTHERLODE!!"
L["TWW_EXPORT_SUCCESS"] = "Enemy forces database exported to clipboard"
L["TWW_IMPORT_SUCCESS"] = "Enemy forces database imported successfully"
L["TWW_RESET_SUCCESS"] = "Enemy forces database reset to defaults"
L["TWW_EXPORT_INSTRUCTIONS"] = "Copy the text below to share your enemy forces data:"
L["TWW_IMPORT_INSTRUCTIONS"] = "Paste exported enemy forces data below:"
L["TWW_IMPORT"] = "Import"
L["TWW_IMPORT_FAILED"] = "Failed to import enemy forces data. Check that the format is correct."

-- Other locales can be added here
if locale == "deDE" then
    -- German translations
    -- ...
elseif locale == "frFR" then
    -- French translations
    -- ...
end

-- Make localizations available to the module
Module.L = L 