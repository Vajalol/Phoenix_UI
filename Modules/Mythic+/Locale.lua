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