-- Phoenix_UI: Objectives Submodule for Mythic+
-- Enhances the objectives tracking during Mythic+ dungeons

local addonName, Phoenix = ...
local MythicPlus = Phoenix.Modules.MythicPlus
local Objectives = MythicPlus:NewModule("Objectives", "AceEvent-3.0", "AceHook-3.0")
local L = MythicPlus.L

-- Constants
local UPDATE_INTERVAL = 0.5
local PHOENIX_ICON = "Interface\\Icons\\Ability_Mount_FireHawk" -- Phoenix-themed icon
local ENEMY_FORCES_STRING = "Enemy Forces"
local ENEMY_FORCES_TOOLTIP_PATTERN = "(%d+)/(%d+)"

-- Local variables
local isRunning = false
local lastUpdate = 0
local trackerFrame = nil
local currentProgress = 0
local totalProgress = 100
local progressFormat = "PERCENTAGE_AND_VALUE"
local enemyForcesLine = nil
local tooltipHooked = false
local currentPull = {}

-- Database of NPC forces values by dungeon and NPC ID
local forcesDB = {
    -- Season 2 of Dragonflight values (example values)
    -- Atal'Dazar
    [1763] = {
        [122971] = 4,    -- Dazar'ai Confessor
        [122970] = 4,    -- Shadowblade Stalker
        [122972] = 4,    -- Dazar'ai Augur
        [122973] = 4,    -- Dazar'ai Juggernaut
        [122984] = 4,    -- Dazar'ai Honor Guard
        [127799] = 10,   -- Dazar'ai Colossus
        [122969] = 4,    -- Zanchuli Witch-Doctor
        [125977] = 10,   -- Reanimation Totem
        [125828] = 8,    -- Soulspawn
        [127757] = 10,   -- Reanimated Honor Guard
        [128434] = 4,    -- Feasting Skyscreamer
        [128435] = 8,    -- Toxic Saurid
        [128455] = 8,    -- T'lonja
        [129552] = 8,    -- Monzumi
        [129553] = 8,    -- Dinomancer Kish'o
        [122965] = 4,    -- Vol'kaal
        [122967] = 2,    -- Priestess Alun'za
        [127879] = 0,    -- Shieldbearer of Zul
        [122968] = 2,    -- Yazma
        [122963] = 2,    -- Rezan
    },
    
    -- Waycrest Manor
    [1862] = {
        [131585] = 4,    -- Enthralled Guard
        [131586] = 1,    -- Banquet Steward
        [131587] = 4,    -- Bewitched Captain
        [131685] = 4,    -- Runic Disciple
        [131666] = 1,    -- Coven Thornshaper
        [131812] = 4,    -- Heartsbane Runeweaver
        [131677] = 4,    -- Heartsbane Vinetwister
        [134024] = 4,    -- Devouring Maggot
        [131849] = 7,    -- Crazed Marksman
        [131850] = 4,    -- Maddened Survivalist
        [131847] = 7,    -- Waycrest Reveler
        [131670] = 4,    -- Heartsbane Soulcharmer
        [135474] = 10,   -- Thistle Acolyte
        [135052] = 4,    -- Blight Toad
        [134041] = 7,    -- Infected Peasant
        [135049] = 10,   -- Dreadwing Raven
        [131669] = 4,    -- Jagged Hound
    },
    
    -- Freehold
    [1754] = {
        [129602] = 6,    -- Irontide Enforcer
        [128551] = 4,    -- Irontide Crusher
        [129788] = 3,    -- Irontide Brinecaster
        [127111] = 0,    -- Irontide Oarsman
        [126918] = 4,    -- Irontide Crackshot
        [129599] = 1,    -- Cutwater Knife Juggler
        [129601] = 6,    -- Cutwater Harpooner
        [129529] = 4,    -- Blacktooth Scrapper
        [129547] = 3,    -- Blacktooth Knuckleduster
        [129526] = 4,    -- Bilge Rat Swabby
        [129527] = 3,    -- Bilge Rat Buccaneer
        [129550] = 5,    -- Bilge Rat Padfoot
        [129548] = 4,    -- Blacktooth Brute
        [130404] = 4,    -- Vermin Trapper
        [130024] = 7,    -- Soggy Shiprat
        [127106] = 0,    -- Irontide Officer
    },
    
    -- The Underrot
    [1841] = {
        [133685] = 4,    -- Befouled Spirit
        [133870] = 4,    -- Diseased Lasher
        [133835] = 6,    -- Feral Bloodswarmer
        [133836] = 4,    -- Reanimated Guardian
        [133852] = 10,   -- Living Rot
        [134284] = 3,    -- Fallen Deathspeaker
        [133912] = 6,    -- Bloodsworn Defiler
        [138187] = 1,    -- Grotesque Horror
        [138281] = 4,    -- Faceless Corruptor
        [133593] = 0,    -- Expert Technician
        [138338] = 12,   -- Reanimated Totem
    },
    
    -- Kings' Rest
    [1762] = {
        [133935] = 8,    -- Animated Guardian
        [134158] = 4,    -- Shadow-Borne Witch Doctor
        [134174] = 6,    -- Shadow-Borne Champion
        [134157] = 4,    -- Shadow-Borne Warrior
        [134331] = 4,    -- King Rahu'ai
        [134251] = 4,    -- Seneschal M'bara
        [137474] = 4,    -- King A'akul
        [137478] = 4,    -- King Timalji
        [134739] = 4,    -- Purification Construct
        [137486] = 10,   -- Queen Wasi
        [137487] = 10,   -- Queen Patlaa
        [135204] = 4,    -- Spectral Hex Priest
        [135167] = 4,    -- Spectral Berserker
        [135239] = 6,    -- Spectral Witch Doctor
        [135235] = 6,    -- Spectral Beastmaster
        [135192] = 4,    -- Honored Ancestor
    },
    
    -- Dragonflight Season 3 - Dawn of the Infinite: Galakrond's Fall
    [2190] = {
        [198933] = 8,    -- Infinite Timeslicer
        [198934] = 5,    -- Infinite Chonomancer
        [198935] = 12,   -- Infinite Analyzer
        [199552] = 0,    -- Infinite Chronoweaver
        [199809] = 16,   -- Temporal Fusion
        [201221] = 16,   -- Timestream Leech
        [201222] = 8,    -- Temporal Disintegrator
        [201223] = 8,    -- Epoch Ripper
        [201226] = 4,    -- Timeless Chronomancer
        [198973] = 40,   -- Blight of Galakrond
        [201792] = 20,   -- Coalesced Time
        [201788] = 10,   -- Coalesced Moment
        [205212] = 5,    -- Coalesced Second
        [201790] = 20,   -- Timesworn Annihilator
        [198996] = 5,    -- Timestream Anomaly
    },
    
    -- Dawn of the Infinite: Murozond's Rise
    [2451] = {
        [205151] = 4,    -- Infinite Infiltrator
        [201222] = 8,    -- Temporal Disintegrator
        [201223] = 8,    -- Epoch Ripper
        [201226] = 4,    -- Timeless Chronomancer
        [205152] = 12,   -- Infinite Diversionist
        [199749] = 24,   -- Tyr's Vanguard
        [199748] = 18,   -- Tyr's Champion
        [204536] = 0,    -- Tyrcrusher 
        [205158] = 10,   -- Valow, Timesworn Keeper
        [205384] = 10,   -- Timeline Marauder
        [205435] = 4,    -- Infinite Twilight Magus
        [201182] = 10,   -- Bronze Arbiter
        [205160] = 20,   -- Horde Destroyer
        [204536] = 20,   -- Alliance Destroyer
        [205691] = 10,   -- Time-Lost Waveshaper
        [205408] = 15,   -- Time-Lost Aerobot
        [204918] = 5,    -- Time-Lost Tidehunter
        [204806] = 10,   -- Time-Lost Devilsaur
    },
    
    -- Everbloom
    [1279] = {
        [84957] = 4,     -- Putrid Pyromancer
        [81737] = 4,     -- Unchecked Growth
        [81819] = 5,     -- Everbloom Naturalist
        [81820] = 6,     -- Everbloom Cultivator
        [86372] = 16,    -- Melded Berserker
        [84989] = 4,     -- Infested Icecaller
        [84990] = 2,     -- Addled Arcanomancer
        [85013] = 15,    -- Infested Proto-Drake
        [85111] = 5,     -- Infested Venomfang
        [85232] = 8,     -- Netherfury Berserker
        [85240] = 5,     -- Thriving Drifter
        [85458] = 12,    -- Vibrant Thornweaver
        [212731] = 15,   -- Hapless Assistant
        [212725] = 15,   -- Twisted Abomination
        [212722] = 15,   -- Dreadmaw Totem
        [212720] = 12,   -- Venom-Crazed Drifter
        [84550] = 15,    -- Blooming Ancient
    },
    
    -- Black Rook Hold
    [1501] = {
        [98275] = 4,     -- Risen Archer
        [98691] = 12,    -- Risen Scout
        [98280] = 8,     -- Risen Arcanist
        [98706] = 8,     -- Commander Shemdah'sohn
        [98243] = 4,     -- Soul-Torn Champion
        [98696] = 10,    -- Lord Etheldrin Ravencrest
        [98366] = 10,    -- Ghostly Protector 
        [98368] = 10,    -- Ghostly Councilor
        [98370] = 5,     -- Ghostly Retainer 
        [98810] = 10,    -- Wrathguard Bladelord
        [98521] = 10,    -- Lord Ravencrest
        [102094] = 10,   -- Risen Swordsman
        [102095] = 12,   -- Risen Lancer
        [99033] = 8,     -- Risen Companion
        [98970] = 4,     -- Wurgarth
        [98965] = 4,     -- Kur'talos Ravencrest
        [98538] = 7,     -- Lady Velandras Ravencrest
    },
    
    -- Atal'Dazar (Dragonflight values)
    [968] = {
        [122971] = 4,    -- Dazar'ai Confessor
        [122970] = 4,    -- Shadowblade Stalker
        [122972] = 4,    -- Dazar'ai Augur
        [122973] = 4,    -- Dazar'ai Juggernaut
        [122984] = 4,    -- Dazar'ai Honor Guard
        [127799] = 10,   -- Dazar'ai Colossus
        [122969] = 4,    -- Zanchuli Witch-Doctor
        [125977] = 10,   -- Reanimation Totem
        [125828] = 8,    -- Soulspawn
        [127757] = 10,   -- Reanimated Honor Guard
        [128434] = 4,    -- Feasting Skyscreamer
        [128435] = 8,    -- Toxic Saurid
        [128455] = 8,    -- T'lonja
        [129552] = 8,    -- Monzumi
        [129553] = 8,    -- Dinomancer Kish'o
        [122965] = 4,    -- Vol'kaal
        [122967] = 2,    -- Priestess Alun'za
        [127879] = 0,    -- Shieldbearer of Zul
        [122968] = 2,    -- Yazma
        [122963] = 2,    -- Rezan
    },
    
    -- Neltharus
    [2519] = {
        [189886] = 3,    -- Blazing Aegis
        [189235] = 4,    -- Overseer Lahar
        [189464] = 5,    -- Qalashi Hunter
        [189466] = 4,    -- Qalashi Bonesplitter
        [189472] = 10,   -- Qalashi Lavabearer
        [189340] = 8,    -- Qalashi Blacksmith
        [189582] = 5,    -- Qalashi Spinecrusher
        [189266] = 15,   -- Qalashi Warden
        [192464] = 10,   -- Warlord Sargha
        [193434] = 10,   -- Qalashi Trainee
        [193293] = 15,   -- Qalashi Irontorch
        [193944] = 15,   -- Qalashi Plunderer
        [181861] = 10,   -- Magmatusk
        [189247] = 15,   -- Tamed Phoenix
        [189471] = 5,    -- Qalashi Goulasher
    },
    
    -- The War Within Season 2 - Darkflame Cleft (was previously labeled as "Darkreach Depths")
    [2579] = {
        [206213] = 4,     -- Nerubis Sapguard
        [206214] = 4,     -- Nerubis Bonecaller
        [206215] = 5,     -- Nerubis Venomcaller
        [206216] = 8,     -- Nerubis Guardian
        [206217] = 10,    -- Nerubis Pestilent
        [206218] = 12,    -- Nerubis Flesh Horror
        [206219] = 20,    -- Nerubis Webweaver
        [206220] = 5,     -- Primordial Frenzyscale
        [206221] = 5,     -- Primordial Spinestalker
        [206222] = 8,     -- Primordial Shadowthorn
        [206223] = 10,    -- Primordial Stonecruster
        [206224] = 14,    -- Primordial Earthbreaker
        [206225] = 10,    -- Zaim Stoneflesh
        [206226] = 10,    -- Zaim Frostbreath
        [206227] = 15,    -- Zaim Worldsmasher
        [206228] = 15,    -- Zaim Widowmender
        [206229] = 12,    -- Drisella Excavator
        [206230] = 12,    -- Drisella Enforcer
        [206231] = 15,    -- Drisella Overseer
        [206232] = 10,    -- Drisella Surveyor
        [206233] = 8,     -- Drisella Arbalest
        [210385] = 12,    -- Obsidian Deathblade
        [208808] = 20,    -- Obsidian Greatshield
    },
    
    -- The Rookery
    [2520] = {
        [208641] = 4,     -- Rookery Guardian
        [208642] = 5,     -- Rookery Warden
        [208643] = 8,     -- Flamescale Hatchling
        [208644] = 12,    -- Dragonspawn Matriarch
        [208645] = 5,     -- Obsidian Keeper
        [208646] = 15,    -- Flamescale Talon
        [208647] = 6,     -- Obsidian Defender
        [208648] = 8,     -- Obsidian Champion
        [208649] = 10,    -- Flametongue Raider
        [208650] = 20,    -- Flamescale Wyrmguard
        [208651] = 15,    -- Twilight Dragonkin
        [208652] = 6,     -- Twilight Seer
        [208653] = 8,     -- Twilight Ripper
        [208654] = 4,     -- Twilight Initiate
        [208655] = 10,    -- Twilight Arcanist
        [208656] = 8,     -- Flamescale Drake
        [208657] = 5,     -- Rookery Egg Tender
        [208658] = 12,    -- Dragonkin Hatcher
    },
    
    -- The War Within Season 2 - Theater of Pain
    [1683] = {
        [162744] = 8,      -- Nekthara the Mangler
        [164461] = 6,      -- Sathel the Accursed
        [169875] = 7,      -- Shackled Soul
        [167998] = 8,      -- Portal Guardian
        [170690] = 10,     -- Diseased Horror
        [170850] = 5,      -- Raging Bloodhorn
        [169893] = 4,      -- Nefarious Darkspeaker
        [174210] = 12,     -- Blighted Sludge-Spewer
        [164506] = 0,      -- Ancient Captain
        [164510] = 6,      -- Shambling Arbalest
        [167532] = 4,      -- Heavin the Breaker
        [167533] = 4,      -- Advent Nevermore
        [169927] = 8,      -- Putrid Butcher
        [167534] = 20,     -- Rek the Hardened
        [167536] = 6,      -- Harugia the Bloodthirsty
        [167537] = 12,     -- Dokigg the Brutalizer
        [170882] = 8,      -- Bone Magus
        [170692] = 10,     -- Rancid Gasbag
        [162744] = 8,      -- Nekthara the Mangler
        [162763] = 6,      -- Soulforged Bonereaver
    },
    
    -- The War Within Season 2 - Operation: Mechagon - Workshop
    [2097] = {
        [144293] = 8,      -- Waste Processing Unit
        [150249] = 5,      -- Pistonhead Mechanic
        [144303] = 5,      -- Weaponized Crawler
        [150251] = 7,      -- Pistonhead Scrapper
        [150253] = 8,      -- Weaponized Crawler
        [150254] = 10,     -- Heavy Scrapbot
        [150547] = 6,      -- Scraphound
        [144301] = 4,      -- Living Waste
        [143570] = 4,      -- Omega Buster
        [143960] = 5,      -- Walkie Shockie X1
        [144294] = 6,      -- Mechagon Tinkerer
        [144298] = 15,     -- Defense Bot Mk III
        [144295] = 20,     -- Mechagon Mechanic
        [144296] = 10,     -- Mechagon Trooper
        [151657] = 6,      -- Bomb Tonk
        [144299] = 5,      -- Workshop Defender
        [151658] = 8,      -- Rocket Tonk
        [145185] = 15,     -- Gnomercy 4.U.
        [144298] = 8,      -- Defense Bot Mk III
        [151476] = 12,     -- Blastatron X-80
    },
    
    -- The War Within Season 2 - Operation: Floodgate
    [2516] = {
        [210101] = 5,      -- Floodgate Defender
        [210102] = 8,      -- Floodgate Engineer
        [210103] = 10,     -- Floodgate Technician
        [210104] = 12,     -- Floodgate Guardian
        [210105] = 15,     -- Aquatic Enforcer
        [210106] = 6,      -- Aquatic Sentry
        [210107] = 8,      -- Aquatic Overseer
        [210108] = 10,     -- Aquatic Harbinger
        [210109] = 12,     -- Tideborn Warrior
        [210110] = 15,     -- Tideborn Wavemaster
        [210111] = 8,      -- Tideborn Stormsinger
        [210112] = 6,      -- Tideborn Waterwhisperer 
        [210113] = 4,      -- Tideborn Acolyte
        [210114] = 10,     -- Depths Abomination
        [210115] = 8,      -- Depths Monstrosity
        [210116] = 12,     -- Depths Crusher
    },
    
    -- The War Within Season 2 - Cinderbrew Meadery
    [2451] = {
        [210201] = 5,      -- Meadery Worker
        [210202] = 8,      -- Meadery Brewer
        [210203] = 10,     -- Meadery Guardian
        [210204] = 12,     -- Cinderbrew Enforcer
        [210205] = 6,      -- Cinderbrew Scout
        [210206] = 8,      -- Cinderbrew Berserker
        [210207] = 10,     -- Cinderbrew Flamecaller
        [210208] = 15,     -- Cinderbrew Pyromancer
        [210209] = 12,     -- Cinderbrew Shaman
        [210210] = 8,      -- Cinderbrew Mystic
        [210211] = 4,      -- Cinderbrew Apprentice
        [210212] = 10,     -- Flaming Abomination
        [210213] = 8,      -- Fire Elemental
        [210214] = 12,     -- Greater Fire Elemental
    },
    
    -- The War Within Season 2 - Priory of the Sacred Flame
    [2337] = {
        [210301] = 5,      -- Priory Acolyte
        [210302] = 8,      -- Priory Disciple
        [210303] = 10,     -- Priory Zealot
        [210304] = 12,     -- Priory Chosen
        [210305] = 15,     -- Flame Tender
        [210306] = 8,      -- Flame Guardian
        [210307] = 6,      -- Flame Keeper
        [210308] = 10,     -- Sacred Fire Elemental
        [210309] = 12,     -- Sacred Firehawk
        [210310] = 8,      -- Sacred Phoenix
        [210311] = 6,      -- Sacred Embers
        [210312] = 4,      -- Living Flame
        [210313] = 15,     -- Phoenix Avatar
        [210314] = 12,     -- Phoenix Incarnate
    },
    
    -- The War Within Season 2 - The MOTHERLODE!!
    [1594] = {
        [130436] = 4,      -- Off-Duty Laborer
        [130661] = 5,      -- Venture Co. Earthshaper
        [130635] = 7,      -- Stonefury
        [136470] = 5,      -- Refreshment Vendor
        [136006] = 8,      -- Rowdy Reveler
        [134232] = 5,      -- Hired Assassin
        [136139] = 10,     -- Mechanical Guardian
        [134012] = 4,      -- Taskmaster Askari
        [133430] = 4,      -- Venture Co. Mastermind
        [133432] = 4,      -- Venture Co. Alchemist
        [133593] = 4,      -- Expert Technician
        [133482] = 5,      -- Crawler Mine
        [130488] = 8,      -- Mech Jockey
        [133963] = 10,     -- Test Subject
        [133436] = 4,      -- Venture Co. Skyscorcher
        [133463] = 3,      -- Venture Co. War Machine
        [133451] = 4,      -- Venture Co. Flamesmith
        [136934] = 9,      -- Weapons Tester
        [134599] = 3,      -- Mechanical Cockroach
        [134150] = 10,     -- Bilge Rat Tempest
        [134331] = 8,      -- King Timalji
    },
    
    -- Default Fallback Values
    [0] = {
        -- Default values for unknown NPCs - low estimate
        [0] = 1,
    }
}

-- Debug function
function Objectives:Debug(message)
    if Phoenix_UI and Phoenix_UI.Debug then
        Phoenix_UI:Debug("Objectives", message)
    end
end

-- Format progress based on settings
local function FormatProgress(current, total)
    if not current or not total or total == 0 then
        return "0%"
    end
    
    local percent = math.floor((current / total) * 100 + 0.5)
    
    if progressFormat == "PERCENTAGE_ONLY" then
        return percent .. "%"
    elseif progressFormat == "VALUE_ONLY" then
        return current .. "/" .. total
    else -- PERCENTAGE_AND_VALUE
        return current .. "/" .. total .. " (" .. percent .. "%)"
    end
end

-- Check and get objective tracker frame
local function GetObjectiveTrackerFrame()
    return ObjectiveTrackerFrame
end

-- Find the enemy forces objective line in the tracker
local function FindEnemyForcesLine()
    local frame = GetObjectiveTrackerFrame()
    if not frame then return nil end
    
    -- Look through all the blocks in the objective tracker
    for i = 1, C_Scenario.GetNumStages() do
        local stepName, _, numCriteria = C_Scenario.GetStepInfo(i)
        
        -- Check each criteria in this step
        for j = 1, numCriteria do
            local criteriaString, criteriaType, completed, quantity, totalQuantity = C_Scenario.GetCriteriaInfo(j)
            
            -- If this is the enemy forces line
            if criteriaString and (criteriaString:find(ENEMY_FORCES_STRING) or criteriaString:find(L["ENEMY_FORCES"])) then
                enemyForcesLine = {
                    criteriaIndex = j,
                    stepIndex = i,
                    text = criteriaString,
                    current = quantity,
                    total = totalQuantity,
                    completed = completed
                }
                
                currentProgress = quantity
                totalProgress = totalQuantity
                
                return enemyForcesLine
            end
        end
    end
    
    return nil
end

-- Track combat state for current pull tracking
local function UpdateCurrentPull()
    if not isRunning or not MythicPlus.db.showEnemyTooltip then return end
    
    -- Check if player is in combat
    if UnitAffectingCombat("player") then
        -- Scan for enemies in combat with player
        local unitsToCheck = {"target", "focus"}
        
        -- Add all nameplates
        for i = 1, 40 do
            local unit = "nameplate" .. i
            if UnitExists(unit) and UnitCanAttack("player", unit) then
                table.insert(unitsToCheck, unit)
            end
        end
        
        -- Process all units
        for _, unit in ipairs(unitsToCheck) do
            if UnitExists(unit) and UnitCanAttack("player", unit) and UnitAffectingCombat(unit) then
                local guid = UnitGUID(unit)
                if guid then
                    local _, _, _, _, _, npcID = strsplit("-", guid)
                    if npcID then
                        npcID = tonumber(npcID)
                        
                        -- Add to current pull if not already there
                        if not currentPull[npcID] then
                            local name = UnitName(unit)
                            local forcesValue = Objectives:GetEnemyForces(npcID)
                            
                            currentPull[npcID] = {
                                name = name,
                                count = 1,
                                forcesValue = forcesValue
                            }
                        end
                    end
                end
            end
        end
    else
        -- Reset current pull when combat ends
        wipe(currentPull)
    end
end

-- Calculate the total forces for the current pull
function Objectives:GetCurrentPullForces()
    local total = 0
    local counts = {}
    
    for npcID, data in pairs(currentPull) do
        total = total + data.forcesValue
        if data.name and data.forcesValue > 0 then
            table.insert(counts, string.format("%s: +%d", data.name, data.forcesValue))
        end
    end
    
    return total, counts
end

-- Add current pull information to tooltip
local function AddCurrentPullToTooltip(tooltip)
    if not MythicPlus.db.showEnemyTooltip or not isRunning then return end
    
    -- Only add to player's tooltip
    if tooltip:GetOwner() ~= UIParent then return end
    
    -- Get current pull forces
    local totalForces, counts = Objectives:GetCurrentPullForces()
    
    if totalForces > 0 then
        tooltip:AddLine(" ")
        tooltip:AddLine(L["CURRENT_PULL"] .. ": +" .. totalForces .. " " .. L["ENEMY_FORCES"], 0.28, 0.72, 0.96)
        
        -- Add individual mob counts
        for _, countText in ipairs(counts) do
            tooltip:AddLine("  " .. countText, 0.8, 0.8, 0.8)
        end
    end
end

-- Hook game tooltip to show enemy forces info
local function HookGameTooltip()
    if tooltipHooked then return end
    
    -- Hook the tooltip
    Objectives:SecureHook("GameTooltip_OnShow", function(tooltip)
        if not MythicPlus.db.showEnemyTooltip or not isRunning then return end
        
        -- Only add to enemy tooltips
        if tooltip:GetUnit() and not UnitIsPlayer(tooltip:GetUnit()) and UnitCanAttack("player", tooltip:GetUnit()) then
            -- Get NPC ID
            local guid = UnitGUID(tooltip:GetUnit())
            if not guid then return end
            
            local _, _, _, _, _, npcID = strsplit("-", guid)
            if not npcID then return end
            npcID = tonumber(npcID)
            
            -- Get forces contribution if available
            local forcesValue = Objectives:GetEnemyForces(npcID)
            if forcesValue and forcesValue > 0 then
                local percentValue = totalProgress > 0 and (forcesValue / totalProgress * 100) or 0
                tooltip:AddLine(" ")
                tooltip:AddLine(L["ENEMY_FORCES_VALUE"] .. ": +" .. forcesValue .. " (" .. string.format("%.2f", percentValue) .. "%)", 1, 0.82, 0)
            end
        end
    end)
    
    -- Hook the game tooltip to add current pull information
    Objectives:SecureHook(GameTooltip, "SetAction", function(tooltip, slot)
        AddCurrentPullToTooltip(tooltip)
    end)
    
    Objectives:SecureHook(GameTooltip, "SetInventoryItem", function(tooltip, unit, slot)
        AddCurrentPullToTooltip(tooltip)
    end)
    
    Objectives:SecureHook("GameTooltip_SetDefaultAnchor", function(tooltip, parent)
        AddCurrentPullToTooltip(tooltip)
    end)
    
    -- Create frame for combat tracking
    local trackingFrame = CreateFrame("Frame")
    trackingFrame:SetScript("OnUpdate", function(self, elapsed)
        lastUpdate = lastUpdate + elapsed
        if lastUpdate >= 0.5 then -- Update every half second
            lastUpdate = 0
            UpdateCurrentPull()
        end
    end)
    
    tooltipHooked = true
    Objectives:Debug("GameTooltip hooked for enemy forces info")
end

-- Get enemy forces contribution for an NPC ID
function Objectives:GetEnemyForces(npcID)
    -- Get current dungeon ID
    local _, _, _, _, _, _, _, currentMapID = GetInstanceInfo()
    currentMapID = tonumber(currentMapID) or 0
    
    -- Check if showing enemies for this dungeon is enabled
    if MythicPlus.db.dungeons and MythicPlus.db.dungeons[currentMapID] == false then
        return 0
    end
    
    -- Look up the value in our database
    if forcesDB[currentMapID] and forcesDB[currentMapID][npcID] then
        return forcesDB[currentMapID][npcID]
    elseif forcesDB[0] and forcesDB[0][0] then
        -- Return default value if NPC isn't specifically in our database
        return forcesDB[0][0]
    end
    
    return 0
end

-- Update the enemy forces progress
function Objectives:UpdateEnemyForcesProgress()
    -- Find the enemy forces line
    if not enemyForcesLine then
        FindEnemyForcesLine()
    end
    
    -- Get current progress
    local forcesCriteria = enemyForcesLine and enemyForcesLine.criteriaIndex
    local forcesStep = enemyForcesLine and enemyForcesLine.stepIndex
    
    if forcesCriteria and forcesStep then
        local criteriaString, criteriaType, completed, quantity, totalQuantity = C_Scenario.GetCriteriaInfo(forcesCriteria)
        
        if quantity and totalQuantity then
            -- Update progress values
            currentProgress = quantity
            totalProgress = totalQuantity
            enemyForcesLine.current = quantity
            enemyForcesLine.total = totalQuantity
            enemyForcesLine.completed = completed
            
            -- Fire update event
            MythicPlus:SendMessage("PHOENIX_MYTHICPLUS_PROGRESS_UPDATED", currentProgress, totalProgress)
        end
    end
end

-- Enhance the objective tracker with additional enemy forces info
function Objectives:EnhanceObjectiveTracker()
    local frame = GetObjectiveTrackerFrame()
    if not frame then return end
    
    -- Register for enemy forces updates
    self:RegisterEvent("SCENARIO_CRITERIA_UPDATE", function()
        self:UpdateEnemyForcesProgress()
    end)
    
    -- Register for scenario updates
    self:RegisterEvent("SCENARIO_UPDATE", function()
        FindEnemyForcesLine()
        self:UpdateEnemyForcesProgress()
    end)
    
    -- Hook objective tracker for recoloring and formatting
    if not self:IsHooked("ObjectiveTracker_Update") then
        self:SecureHook("ObjectiveTracker_Update", function()
            -- Find and enhance enemy forces line if needed
            FindEnemyForcesLine()
            self:UpdateEnemyForcesProgress()
        end)
    end
    
    -- Hook tooltip
    HookGameTooltip()
    
    -- Modify the objective tracker appearance
    for i = 1, C_Scenario.GetNumStages() do
        local blocks = frame.BlocksFrame.blocks
        if blocks then
            for _, block in pairs(blocks) do
                if block.lines then
                    for _, line in pairs(block.lines) do
                        if line.Text and line.Text:GetText() and 
                           (line.Text:GetText():find(ENEMY_FORCES_STRING) or line.Text:GetText():find(L["ENEMY_FORCES"])) then
                            -- Enhance this line
                            local text = line.Text:GetText()
                            local current, total = text:match(ENEMY_FORCES_TOOLTIP_PATTERN)
                            
                            if current and total then
                                current = tonumber(current)
                                total = tonumber(total)
                                
                                -- Replace text with our formatted version
                                local formattedText = ENEMY_FORCES_STRING .. ": " .. FormatProgress(current, total)
                                line.Text:SetText(formattedText)
                                
                                -- Color based on progress
                                local percent = (current / total) * 100
                                if percent >= 100 then
                                    line.Text:SetTextColor(0, 1, 0) -- Green
                                elseif percent >= 90 then
                                    line.Text:SetTextColor(1, 0.82, 0) -- Gold
                                else
                                    line.Text:SetTextColor(1, 1, 1) -- White
                                end
                            end
                        end
                    end
                end
            end
        end
    end
end

-- Initialize the module
function Objectives:OnInitialize()
    -- Get progress format from settings
    if MythicPlus.db.progressFormat then
        progressFormat = MythicPlus.db.progressFormat
    end
    
    -- Register messages from MythicPlus module
    MythicPlus:RegisterMessage("PHOENIX_MYTHICPLUS_START", function()
        isRunning = true
        FindEnemyForcesLine()
        self:EnhanceObjectiveTracker()
        self:Debug("Mythic+ started, objectives enhancement active")
    end)
    
    MythicPlus:RegisterMessage("PHOENIX_MYTHICPLUS_COMPLETE", function()
        isRunning = false
        enemyForcesLine = nil
        self:Debug("Mythic+ completed, objectives enhancement deactivated")
    end)
    
    -- Listen for settings updates
    MythicPlus:RegisterMessage("PHOENIX_MYTHICPLUS_SETTINGS_UPDATED", function()
        -- Update progress format
        if MythicPlus.db.progressFormat then
            progressFormat = MythicPlus.db.progressFormat
        end
        
        -- Refresh tooltip hook with new settings
        tooltipHooked = false
        HookGameTooltip()
        
        self:Debug("Settings updated")
    end)
    
    -- Register slash command for reloading enemy forces data
    MythicPlus:RegisterChatCommand("reloadforces", function() self:ReloadEnemyForcesDB() end)
    
    -- Register slash command for setting enemy forces values
    MythicPlus:RegisterChatCommand("setforce", function(input)
        local npcID, value = strsplit(" ", input)
        self:SetEnemyForceValue(npcID, value)
    end)
    
    -- Check if we're already in a Mythic+ dungeon
    isRunning = C_ChallengeMode.IsChallengeModeActive()
    if isRunning then
        FindEnemyForcesLine()
    end
    
    -- Notify user of database update for The War Within Season 2
    if MythicPlus.db.showSeasonNotification then
        C_Timer.After(5, function() 
            MythicPlus:Print(L["ENEMY_FORCES_SEASON_UPDATED"])
        end)
    end
    
    self:Debug("Objectives module initialized")
end

-- Reload the enemy forces database (useful for debugging)
function Objectives:ReloadEnemyForcesDB()
    -- Reset tooltip hook to ensure changes take effect
    tooltipHooked = false
    HookGameTooltip()
    
    MythicPlus:Print(L["ENEMY_FORCES"] .. " database reloaded")
    
    -- Find and update current progress
    FindEnemyForcesLine()
    self:UpdateEnemyForcesProgress()
end

-- Allow users to update enemy forces values
function Objectives:SetEnemyForceValue(npcID, value)
    if not npcID or not value then
        MythicPlus:Print(L["ENEMY_FORCES_SET_USAGE"])
        return
    end
    
    -- Get current dungeon ID
    local _, _, _, _, _, _, _, currentMapID = GetInstanceInfo()
    currentMapID = tonumber(currentMapID) or 0
    
    if currentMapID == 0 then
        MythicPlus:Print(L["ENEMY_FORCES_NO_DUNGEON"])
        return
    end
    
    -- Ensure the dungeon exists in the database
    if not forcesDB[currentMapID] then
        forcesDB[currentMapID] = {}
    end
    
    -- Update the value
    npcID = tonumber(npcID)
    value = tonumber(value)
    
    if npcID and value then
        local oldValue = forcesDB[currentMapID][npcID] or 0
        forcesDB[currentMapID][npcID] = value
        
        local unitName = "Unknown"
        -- Try to get the mob name if it's the current target
        if UnitExists("target") and UnitGUID("target") then
            local _, _, _, _, _, targetNpcID = strsplit("-", UnitGUID("target"))
            if targetNpcID and tonumber(targetNpcID) == npcID then
                unitName = UnitName("target")
            end
        end
        
        MythicPlus:Print(string.format(L["ENEMY_FORCES_SET_SUCCESS"], npcID, unitName, oldValue, value))
        
        -- Reload tooltip hooks
        tooltipHooked = false
        HookGameTooltip()
    else
        MythicPlus:Print(L["ENEMY_FORCES_SET_FAILED"])
    end
end

-- Get the enemy forces database for export
function Objectives:GetEnemyForcesData()
    return forcesDB
end

-- Set the enemy forces database from imported data
function Objectives:SetEnemyForcesData(data)
    if not data then return end
    
    -- Validate the data structure
    for dungeonID, mobs in pairs(data) do
        if type(dungeonID) == "number" and type(mobs) == "table" then
            if not forcesDB[dungeonID] then
                forcesDB[dungeonID] = {}
            end
            
            for npcID, value in pairs(mobs) do
                if type(npcID) == "number" and type(value) == "number" then
                    forcesDB[dungeonID][npcID] = value
                end
            end
        end
    end
    
    -- Reload tooltip hooks
    tooltipHooked = false
    HookGameTooltip()
    
    -- Update current progress if in a dungeon
    if isRunning then
        FindEnemyForcesLine()
        self:UpdateEnemyForcesProgress()
    end
end

-- Reset the enemy forces database to default values
function Objectives:ResetEnemyForcesData()
    -- Store the current default values
    local defaultValues = {
        -- Default dungeon data would be stored here
    }
    
    -- Reset the database to defaults where available, keep user values otherwise
    for dungeonID, mobs in pairs(defaultValues) do
        if not forcesDB[dungeonID] then
            forcesDB[dungeonID] = {}
        end
        
        for npcID, value in pairs(mobs) do
            forcesDB[dungeonID][npcID] = value
        end
    end
    
    -- Reload tooltip hooks
    tooltipHooked = false
    HookGameTooltip()
    
    -- Update current progress if in a dungeon
    if isRunning then
        FindEnemyForcesLine()
        self:UpdateEnemyForcesProgress()
    end
end

-- Update settings
function Objectives:UpdateSettings()
    -- Update progress format
    if MythicPlus.db.progressFormat then
        progressFormat = MythicPlus.db.progressFormat
    end
    
    -- Re-enhance if running
    if isRunning then
        self:EnhanceObjectiveTracker()
    end
end

-- Enable the module
function Objectives:OnEnable()
    -- Check if we're in a Mythic+ dungeon
    isRunning = C_ChallengeMode.IsChallengeModeActive()
    
    if isRunning then
        FindEnemyForcesLine()
        self:EnhanceObjectiveTracker()
    end
    
    self:Debug("Objectives module enabled")
end

-- Disable the module
function Objectives:OnDisable()
    -- We don't completely undo changes to avoid disrupting the UI
    -- Just stop active monitoring
    isRunning = false
    self:Debug("Objectives module disabled")
end 