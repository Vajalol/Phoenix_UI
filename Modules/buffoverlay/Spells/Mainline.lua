if WOW_PROJECT_ID ~= WOW_PROJECT_MAINLINE then return end

---@class BuffOverlay: AceModule
local BuffOverlay = LibStub("AceAddon-3.0"):GetAddon("BuffOverlay")
local L = BuffOverlay.L

--[[------------------------------------------------

 If you are editing this file, you should be aware
 that everything can now be done from the in-game
 interface, including adding custom buffs.

 Use the /buffoverlay or /bo command.

------------------------------------------------]]

-- Lower prio = shown above other buffs
BuffOverlay.defaultSpells = {
    -- Death Knight
    [48707] = { class = "DEATHKNIGHT", prio = 50 },  --Anti-Magic Shell
    [48792] = { class = "DEATHKNIGHT", prio = 50 },  --Icebound Fortitude
    [49039] = { class = "DEATHKNIGHT", prio = 50 },  --Lichborne
    [55233] = { class = "DEATHKNIGHT", prio = 50 },  --Vampiric Blood
    [194679] = { class = "DEATHKNIGHT", prio = 50 }, --Rune Tap
    [145629] = { class = "DEATHKNIGHT", prio = 50 }, --Anti-Magic Zone
    [81256] = { class = "DEATHKNIGHT", prio = 50 },  --Dancing Rune Weapon
    [410305] = { class = "DEATHKNIGHT", prio = 50 }, --Bloodforged Armor

    -- Demon Hunter
    [196555] = { class = "DEMONHUNTER", prio = 10 }, --Netherwalk
    [209426] = { class = "DEMONHUNTER", prio = 50 }, --Darkness
    [206804] = { class = "DEMONHUNTER", prio = 50 }, --Rain from Above
    [187827] = { class = "DEMONHUNTER", prio = 50 }, --Metamorphosis (Vengeance)
    [212800] = { class = "DEMONHUNTER", prio = 50 }, --Blur
    [263648] = { class = "DEMONHUNTER", prio = 50 }, --Soul Barrier

    -- Druid
    [203554] = { class = "DRUID", prio = 5 },  --Focused Growth
        [347621] = { parent = 203554 },
    [362486] = { class = "DRUID", prio = 10 }, --Tranquility (Druid PVP)
    [22842] = { class = "DRUID", prio = 50 },  --Frenzied Regeneration
    [102342] = { class = "DRUID", prio = 50 }, --Ironbark
    [22812] = { class = "DRUID", prio = 50 },  --Barkskin
    [61336] = { class = "DRUID", prio = 50 },  --Survival Instincts
    [5215] = { class = "DRUID", prio = 70 },   --Prowl

    -- Evoker
    [378441] = { class = "EVOKER", prio = 10 }, --Time Stop
    [363916] = { class = "EVOKER", prio = 50 }, --Obsidian Scales
    [357170] = { class = "EVOKER", prio = 50 }, --Time Dilation
    [383005] = { class = "EVOKER", prio = 50 }, --Chrono Loop
    [374348] = { class = "EVOKER", prio = 50 }, --Renewing Blaze
    [370960] = { class = "EVOKER", prio = 50 }, --Emerald Communion
    [363534] = { class = "EVOKER", prio = 50 }, --Rewind
    [404381] = { class = "EVOKER", prio = 50 }, --Defy Fate

    -- Hunter
    [186265] = { class = "HUNTER", prio = 10 }, --Aspect of the Turtle
    [202748] = { class = "HUNTER", prio = 20 }, --Survival Tactics
    [53480] = { class = "HUNTER", prio = 50 },  --Roar of Sacrifice
    [264735] = { class = "HUNTER", prio = 50 }, --Survival of the Fittest (Pet Ability)
        [281195] = { parent = 264735 },         --Survival of the Fittest (Lone Wolf)
    [388035] = { class = "HUNTER", prio = 50 }, --Fortitude of the Bear
    [199483] = { class = "HUNTER", prio = 70 }, --Camouflage

    -- Mage
    [45438] = { class = "MAGE", prio = 10 },  --Ice Block
    [41425] = { class = "MAGE", prio = 20 },  --Hypothermia
    [414658] = { class = "MAGE", prio = 50 }, --Ice Cold
    [66] = { class = "MAGE", prio = 50 },     --Invisibility
        [32612] = { parent = 66 },
    [414664] = { class = "MAGE", prio = 50 }, --Mass Invisibility
    [198111] = { class = "MAGE", prio = 50 }, --Temporal Shield
    [113862] = { class = "MAGE", prio = 50 }, --Greater Invisibility
    [342246] = { class = "MAGE", prio = 50 }, --Alter Time
        [110909] = { parent = 342246 },
        [108978] = { parent = 342246 },

    -- Monk
    [353319] = { class = "MONK", prio = 10 }, --Peaceweaver
    [125174] = { class = "MONK", prio = 10 }, --Touch of Karma
    [202577] = { class = "MONK", prio = 50 }, --Dome of Mist
    [120954] = { class = "MONK", prio = 50 }, --Fortifying Brew
    [115176] = { class = "MONK", prio = 50 }, --Zen Meditation
    [116849] = { class = "MONK", prio = 50 }, --Life Cocoon
    [122278] = { class = "MONK", prio = 50 }, --Dampen Harm
    [122783] = { class = "MONK", prio = 50 }, --Diffuse Magic

    -- Paladin
    [204018] = { class = "PALADIN", prio = 10 }, --Blessing of Spellwarding
    [642] = { class = "PALADIN", prio = 10 },    --Divine Shield
    [228050] = { class = "PALADIN", prio = 10 }, --Guardian of the Forgotten Queen
    [1022] = { class = "PALADIN", prio = 10 },   --Blessing of Protection
    [25771] = { class = "PALADIN", prio = 20 },  --Forbearance
    [6940] = { class = "PALADIN", prio = 50 },   --Blessing of Sacrifice
        [199448] = { parent = 6940 },            --Blessing of Ultimate Sacrifice
    [498] = { class = "PALADIN", prio = 50 },    --Divine Protection
        [403876] = { parent = 498 },             --Divine Protection (Retribution)
    [31850] = { class = "PALADIN", prio = 50 },  --Ardent Defender
    [86659] = { class = "PALADIN", prio = 50 },  --Guardian of Ancient Kings
    [205191] = { class = "PALADIN", prio = 50 }, --Eye for an Eye
    [184662] = { class = "PALADIN", prio = 50 }, --Shield of Vengeance
    [31821] = { class = "PALADIN", prio = 50 },  --Aura Mastery
    [327193] = { class = "PALADIN", prio = 50 }, --Moment of Glory

    -- Priest
    [197268] = { class = "PRIEST", prio = 10 }, --Ray of Hope
        [232707] = { parent = 197268 },         --Ray of Hope (Positive)
        [232708] = { parent = 197268 },         --Ray of Hope (Negative)
    [47788] = { class = "PRIEST", prio = 10 },  --Guardian Spirit
    [27827] = { class = "PRIEST", prio = 10 },  --Spirit of Redemption
        [215769] = { parent = 27827 },          --Spirit of the Redeemer
    [586] = { class = "PRIEST", prio = 50 },    --Fade
    [47585] = { class = "PRIEST", prio = 50 },  --Dispersion
    [33206] = { class = "PRIEST", prio = 50 },  --Pain Suppression
    [81782] = { class = "PRIEST", prio = 50 },  --Power Word: Barrier
    [271466] = { class = "PRIEST", prio = 50 }, --Luminous Barrier
    [19236] = { class = "PRIEST", prio = 50 },  --Desperate Prayer
    [64844] = { class = "PRIEST", prio = 50 },  --Divine Hymn

    -- Rogue
    [31224] = { class = "ROGUE", prio = 10 },  --Cloak of Shadows
    [45182] = { class = "ROGUE", prio = 50 },  --Cheating Death
    [5277] = { class = "ROGUE", prio = 50 },   --Evasion
    [1966] = { class = "ROGUE", prio = 50 },   --Feint
    [1784] = { class = "ROGUE", prio = 70 },   --Stealth
        [115191] = { parent = 1784 },          --Stealth (Shadowrunner)
    [11327] = { class = "ROGUE", prio = 70 },  --Vanish
    [114018] = { class = "ROGUE", prio = 70 }, --Shroud of Concealment
        [115834] = { parent = 114018 },

    -- Shaman
    [409293] = { class = "SHAMAN", prio = 10 }, --Burrow
    [108271] = { class = "SHAMAN", prio = 50 }, --Astral Shift
    [118337] = { class = "SHAMAN", prio = 50 }, --Harden Skin
    [201633] = { class = "SHAMAN", prio = 50 }, --Earthen Wall Totem
    [383018] = { class = "SHAMAN", prio = 50 }, --Stoneskin Totem
    [325174] = { class = "SHAMAN", prio = 50 }, --Spirit Link Totem
    [207498] = { class = "SHAMAN", prio = 50 }, --Ancestral Protection Totem
    [8178] = { class = "SHAMAN", prio = 50 },   --Grounding Totem

    -- Warlock
    [212295] = { class = "WARLOCK", prio = 50 }, --Nether Ward
    [104773] = { class = "WARLOCK", prio = 50 }, --Unending Resolve
    [108416] = { class = "WARLOCK", prio = 50 }, --Dark Pact

    -- Warrior
    [871] = { class = "WARRIOR", prio = 50 },    --Shield Wall
    [118038] = { class = "WARRIOR", prio = 50 }, --Die by the Sword
    [147833] = { class = "WARRIOR", prio = 50 }, --Intervene
    [23920] = { class = "WARRIOR", prio = 50 },  --Spell Reflection
    [184364] = { class = "WARRIOR", prio = 50 }, --Enraged Regeneration
    [97463] = { class = "WARRIOR", prio = 50 },  --Rallying Cry
    [12975] = { class = "WARRIOR", prio = 50 },  --Last Stand
    [190456] = { class = "WARRIOR", prio = 50 }, --Ignore Pain
    [213871] = { class = "WARRIOR", prio = 50 }, --Bodyguard
    [424655] = { class = "WARRIOR", prio = 50 }, --Safeguard

    -- Racials
    [58984] = { class = "MISC", prio = 70 }, --Shadowmeld

    -- Misc
    [L["Eating/Drinking"]] = { class = "MISC", prio = 90 },      --Food umbrella
        [L["Food & Drink"]] = { parent = L["Eating/Drinking"] }, --Food & Drink
        [L["Food"]] = { parent = L["Eating/Drinking"] },         --Food
        [L["Drink"]] = { parent = L["Eating/Drinking"] },        --Drink
        [L["Refreshment"]] = { parent = L["Eating/Drinking"] },  --Refreshment
        [185710] = { parent = L["Eating/Drinking"] },            --Sugar-Crusted Fish Feast
        [L["NewFood"]] = L["NewFood"] ~= "Remove" and { parent = L["Eating/Drinking"] } or nil,
        [L["NewDrink"]] = L["NewDrink"] ~= "Remove" and { parent = L["Eating/Drinking"] } or nil,
    [320224] = { class = "MISC", prio = 70 }, -- Podtender
    [363522] = { class = "MISC", prio = 70 }, -- Gladiator's Eternal Aegis
    [345231] = { class = "MISC", prio = 70 }, -- Gladiator's Emblem
}

-- Add PvE spell priority categories
BuffOverlay.PvECategories = {
    HEAL_PRIORITY = 10,  -- Highest priority for critical healing cooldowns
    TANK_CD = 9,         -- Tank defensive cooldowns
    DUNGEON_DANGEROUS = 8, -- Dangerous dungeon mechanics to track
    RAID_CRITICAL = 7,   -- Critical raid mechanics
    HEALER_UTILITY = 6,  -- Healer utility spells (mana regen, etc)
    DPS_CD = 5,          -- Important DPS cooldowns
    RAID_NORMAL = 4,     -- Normal raid mechanics 
    DUNGEON_NORMAL = 3,  -- Normal dungeon mechanics
    BUFF_NORMAL = 2,     -- Normal buffs
    BUFF_LOW = 1         -- Low priority buffs
}

-- Build PvE tracking spells for "War Within" season
BuffOverlay.PvESpells = {
    -- Critical healing cooldowns for all healers (useful to track as a healer)
    [363534] = { class = "EVOKER", spec = "Preservation", priority = BuffOverlay.PvECategories.HEAL_PRIORITY }, -- Reversion
    [370960] = { class = "EVOKER", spec = "Preservation", priority = BuffOverlay.PvECategories.HEAL_PRIORITY }, -- Emerald Communion
    [197268] = { class = "MONK", spec = "Mistweaver", priority = BuffOverlay.PvECategories.HEAL_PRIORITY },     -- Revival
    [115310] = { class = "MONK", spec = "Mistweaver", priority = BuffOverlay.PvECategories.HEAL_PRIORITY },     -- Revival
    [64843]  = { class = "PRIEST", spec = "Holy", priority = BuffOverlay.PvECategories.HEAL_PRIORITY },         -- Divine Hymn
    [47788]  = { class = "PRIEST", spec = "Holy", priority = BuffOverlay.PvECategories.HEAL_PRIORITY },         -- Guardian Spirit
    [62618]  = { class = "PRIEST", spec = "Discipline", priority = BuffOverlay.PvECategories.HEAL_PRIORITY },   -- Power Word: Barrier
    [109964] = { class = "PRIEST", spec = "Discipline", priority = BuffOverlay.PvECategories.HEAL_PRIORITY },   -- Spirit Shell
    [33891]  = { class = "DRUID", spec = "Restoration", priority = BuffOverlay.PvECategories.HEAL_PRIORITY },   -- Tree of Life
    [740]    = { class = "DRUID", spec = "Restoration", priority = BuffOverlay.PvECategories.HEAL_PRIORITY },   -- Tranquility
    [31821]  = { class = "PALADIN", spec = "Holy", priority = BuffOverlay.PvECategories.HEAL_PRIORITY },        -- Aura Mastery
    [1022]   = { class = "PALADIN", spec = "Holy", priority = BuffOverlay.PvECategories.HEAL_PRIORITY },        -- Blessing of Protection
    [204018] = { class = "PALADIN", spec = "Holy", priority = BuffOverlay.PvECategories.HEAL_PRIORITY },        -- Blessing of Spellwarding
    
    -- Restoration Shaman critical healing cooldowns
    [108280] = { class = "SHAMAN", spec = "Restoration", priority = BuffOverlay.PvECategories.HEAL_PRIORITY },  -- Healing Tide Totem
    [198838] = { class = "SHAMAN", spec = "Restoration", priority = BuffOverlay.PvECategories.HEAL_PRIORITY },  -- Earthen Wall Totem
    [207399] = { class = "SHAMAN", spec = "Restoration", priority = BuffOverlay.PvECategories.HEAL_PRIORITY },  -- Ancestral Protection Totem
    [114052] = { class = "SHAMAN", spec = "Restoration", priority = BuffOverlay.PvECategories.HEAL_PRIORITY },  -- Ascendance
    [98008]  = { class = "SHAMAN", spec = "Restoration", priority = BuffOverlay.PvECategories.HEAL_PRIORITY },  -- Spirit Link Totem
    
    -- Restoration Shaman utility
    [79206]  = { class = "SHAMAN", spec = "Restoration", priority = BuffOverlay.PvECategories.HEALER_UTILITY }, -- Spiritwalker's Grace
    [16191]  = { class = "SHAMAN", spec = "Restoration", priority = BuffOverlay.PvECategories.HEALER_UTILITY }, -- Mana Tide Totem
    [73920]  = { class = "SHAMAN", spec = "Restoration", priority = BuffOverlay.PvECategories.HEALER_UTILITY }, -- Healing Rain
    [157153] = { class = "SHAMAN", spec = "Restoration", priority = BuffOverlay.PvECategories.HEALER_UTILITY }, -- Cloudburst Totem
    [61295]  = { class = "SHAMAN", spec = "Restoration", priority = BuffOverlay.PvECategories.HEALER_UTILITY }, -- Riptide (multiple targets tracking)
    [288675] = { class = "SHAMAN", spec = "Restoration", priority = BuffOverlay.PvECategories.HEALER_UTILITY }, -- High Tide
    
    -- Restoration Shaman defensive cooldowns
    [108271] = { class = "SHAMAN", spec = "Restoration", priority = BuffOverlay.PvECategories.TANK_CD },        -- Astral Shift
    [383018] = { class = "SHAMAN", spec = "Restoration", priority = BuffOverlay.PvECategories.TANK_CD },        -- Stoneskin Totem 
    [409293] = { class = "SHAMAN", spec = "Restoration", priority = BuffOverlay.PvECategories.TANK_CD },        -- Burrow
    
    -- Important tank defensive cooldowns (useful to track as a healer)
    [48792]  = { class = "DEATHKNIGHT", priority = BuffOverlay.PvECategories.TANK_CD }, -- Icebound Fortitude
    [55233]  = { class = "DEATHKNIGHT", priority = BuffOverlay.PvECategories.TANK_CD }, -- Vampiric Blood
    [203720] = { class = "DEMONHUNTER", priority = BuffOverlay.PvECategories.TANK_CD }, -- Demon Spikes
    [187827] = { class = "DEMONHUNTER", priority = BuffOverlay.PvECategories.TANK_CD }, -- Metamorphosis (Tank)
    [192081] = { class = "DRUID", priority = BuffOverlay.PvECategories.TANK_CD },       -- Ironfur
    [22812]  = { class = "DRUID", priority = BuffOverlay.PvECategories.TANK_CD },       -- Barkskin
    [61336]  = { class = "DRUID", priority = BuffOverlay.PvECategories.TANK_CD },       -- Survival Instincts
    [388370] = { class = "EVOKER", priority = BuffOverlay.PvECategories.TANK_CD },      -- Obsidian Scales
    [132578] = { class = "MONK", priority = BuffOverlay.PvECategories.TANK_CD },        -- Invoke Niuzao
    [115203] = { class = "MONK", priority = BuffOverlay.PvECategories.TANK_CD },        -- Fortifying Brew
    [31850]  = { class = "PALADIN", priority = BuffOverlay.PvECategories.TANK_CD },     -- Ardent Defender
    [86659]  = { class = "PALADIN", priority = BuffOverlay.PvECategories.TANK_CD },     -- Guardian of Ancient Kings
    [132403] = { class = "WARRIOR", priority = BuffOverlay.PvECategories.TANK_CD },     -- Shield Block
    [871]    = { class = "WARRIOR", priority = BuffOverlay.PvECategories.TANK_CD },     -- Shield Wall
    
    -- Healer utility spells (useful to track)
    [64901]  = { class = "PRIEST", spec = "Holy", priority = BuffOverlay.PvECategories.HEALER_UTILITY },       -- Symbol of Hope (Mana restoration)
    [265202] = { class = "PRIEST", spec = "Discipline", priority = BuffOverlay.PvECategories.HEALER_UTILITY }, -- Tali's Evangelism (Covenant)
    [29166]  = { class = "DRUID", spec = "Restoration", priority = BuffOverlay.PvECategories.HEALER_UTILITY }, -- Innervate
    [116680] = { class = "MONK", spec = "Mistweaver", priority = BuffOverlay.PvECategories.HEALER_UTILITY },   -- Thunder Focus Tea
    [320338] = { class = "SHAMAN", spec = "Restoration", priority = BuffOverlay.PvECategories.HEALER_UTILITY }, -- Mana Tide Totem
    
    -- Dungeon Mechanics - Important effects to track in "War Within" dungeons
    -- These values are placeholders and should be updated with specific spell IDs 
    [396411] = { mechanic = true, priority = BuffOverlay.PvECategories.DUNGEON_DANGEROUS }, -- Example Dangerous Mechanic
    [396412] = { mechanic = true, priority = BuffOverlay.PvECategories.DUNGEON_NORMAL },    -- Example Normal Mechanic
    
    -- Raid Mechanics - Critical effects to track in current raid
    -- These values are placeholders and should be updated with specific spell IDs
    [396413] = { mechanic = true, priority = BuffOverlay.PvECategories.RAID_CRITICAL },   -- Example Critical Raid Mechanic  
    [396414] = { mechanic = true, priority = BuffOverlay.PvECategories.RAID_NORMAL },     -- Example Normal Raid Mechanic
}

-- Function to integrate PvE spell priorities with default spell system
BuffOverlay.ApplyPvESpellPriorities = function(self)
    -- Only process if we have the PvE spells table
    if not self.PvESpells then return end
    
    -- Check player specialization to highlight relevant spells
    local playerClass = select(2, UnitClass("player"))
    local playerSpec = nil
    
    if GetSpecialization then
        local specIndex = GetSpecialization()
        if specIndex then
            playerSpec = select(2, GetSpecializationInfo(specIndex))
        end
    end
    
    -- Add PvE spells to the tracking list
    for spellID, spellInfo in pairs(self.PvESpells) do
        -- Skip class/spec specific spells that don't match the player
        if spellInfo.class and spellInfo.class ~= playerClass then
            -- Skip if class doesn't match
        elseif spellInfo.spec and playerSpec and spellInfo.spec ~= playerSpec then
            -- Skip if spec doesn't match
        else
            -- Add to default spells if not already present
            if not self.defaultSpells[spellID] then
                self.defaultSpells[spellID] = spellInfo.priority or 1
            else
                -- Increase priority of existing spells if PvE priority is higher
                local currentPriority = self.defaultSpells[spellID]
                -- Ensure we're comparing numbers to numbers, handle if the default spell entry is a table
                if type(currentPriority) == "table" and currentPriority.prio then
                    currentPriority = currentPriority.prio
                end
                
                if spellInfo.priority and type(currentPriority) == "number" and spellInfo.priority > currentPriority then
                    self.defaultSpells[spellID] = spellInfo.priority
                end
            end
        end
    end
end

-- Add PvE-specific enhancements to the defaultSpells table
BuffOverlay.defaultSpells = BuffOverlay.defaultSpells or {}

-- Apply PvE spell priorities after the default spells have been initialized
C_Timer.After(0.5, function()
    BuffOverlay:ApplyPvESpellPriorities()
end)



