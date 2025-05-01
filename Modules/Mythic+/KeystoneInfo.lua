-- Phoenix_UI: KeystoneInfo Submodule for Mythic+
-- Enhanced display of keystone information

local addonName, Phoenix = ...
local MythicPlus = Phoenix.Modules.MythicPlus
local KeystoneInfo = MythicPlus:NewModule("KeystoneInfo", "AceEvent-3.0", "AceHook-3.0", "AceTimer-3.0")
local L = MythicPlus.L

-- Constants
local KEYSTONE_LEVEL_SCORE_MULTIPLIER = {
    [0] = 0,     -- Invalid/no keystone
    [2] = 40,    -- Starting score multiplier
    [3] = 45,
    [4] = 55,
    [5] = 60,
    [6] = 65,
    [7] = 75,
    [8] = 80, 
    [9] = 85,
    [10] = 95,   -- First Valor cap
    [11] = 100,
    [12] = 105,
    [13] = 110,
    [14] = 115,
    [15] = 120,  -- First seasonal affix in most seasons
    [16] = 125,
    [17] = 130,
    [18] = 135,
    [19] = 140,
    [20] = 145,  -- Top end for most casual players
    [21] = 150,
    [22] = 155,
    [23] = 160, 
    [24] = 165,
    [25] = 170,
    [26] = 175,
    [27] = 180,
    [28] = 185,
    [29] = 190,
    [30] = 195,  -- Very high keys
    [31] = 200,  -- Elite keys
}

-- Calculate score for levels above those explicitly defined
local function GetScoreMultiplierForLevel(level)
    if KEYSTONE_LEVEL_SCORE_MULTIPLIER[level] then
        return KEYSTONE_LEVEL_SCORE_MULTIPLIER[level]
    elseif level > 31 then
        -- For very high keys, add 5 points per level above 31
        return 200 + ((level - 31) * 5)
    else
        -- Fallback for any undefined levels
        return level * 10
    end
end

-- Time Score Multipliers
local TIME_MODIFIER = {
    ["OnTime"] = 1.0,      -- Completed within the timer
    ["Overtime"] = 0.8,     -- Completed but overtime
    ["TwoChest"] = 1.1,     -- Beat the timer by 20%
    ["ThreeChest"] = 1.2,   -- Beat the timer by 40% 
}

-- Seasonal Dungeon Data
local CURRENT_SEASON_DUNGEONS = {
    -- The War Within Season 2 dungeons with accurate timer values
    [2516] = { name = "Operation: Floodgate", timeLimit = 1800, bosses = 4 },     -- 30 minutes
    [2451] = { name = "Cinderbrew Meadery", timeLimit = 1980, bosses = 4 },       -- 33 minutes
    [2579] = { name = "Darkflame Cleft", timeLimit = 2100, bosses = 5 },          -- 35 minutes
    [2520] = { name = "The Rookery", timeLimit = 2160, bosses = 4 },              -- 36 minutes
    [2337] = { name = "Priory of the Sacred Flame", timeLimit = 1980, bosses = 4 }, -- 33 minutes
    [1683] = { name = "Theater of Pain", timeLimit = 2280, bosses = 5 },          -- 38 minutes
    [2097] = { name = "Operation: Mechagon - Workshop", timeLimit = 1920, bosses = 3 }, -- 32 minutes
    [1594] = { name = "The MOTHERLODE!!", timeLimit = 2220, bosses = 4 },         -- 37 minutes
}

-- Local variables
local playerScores = {}
local dungeonHistory = {}
local seasonalBest = {}
local keystoneHistory = {}
local weeklyBest = 0
local lastUpdateTime = 0
local updateFrequency = 5  -- in seconds

-- Initialize module
function KeystoneInfo:OnInitialize()
    -- Register messages
    self:RegisterMessage("PHOENIX_MYTHICPLUS_ENABLED")
    self:RegisterMessage("PHOENIX_MYTHICPLUS_KEYSTONE_UPDATED")
    self:RegisterMessage("PHOENIX_MYTHICPLUS_START")
    self:RegisterMessage("PHOENIX_MYTHICPLUS_COMPLETE")
    
    -- Register events
    self:RegisterEvent("CHALLENGE_MODE_MAPS_UPDATE")
    self:RegisterEvent("CHALLENGE_MODE_COMPLETED")
    self:RegisterEvent("PLAYER_ENTERING_WORLD")
    
    -- Store the original GetActivities function before hooking
    self.originalGetActivities = C_WeeklyRewards.GetActivities
    
    -- Flag to prevent recursive calls
    self.isProcessingActivities = false
    
    -- Hook C_WeeklyRewards.GetActivities to track weekly best
    if not self.GetWeeklyChestRewardLevelHooked then
        hooksecurefunc(C_WeeklyRewards, "GetActivities", function()
            -- Prevent recursion
            if self.isProcessingActivities then return end
            
            -- Set the flag to prevent recursion
            self.isProcessingActivities = true
            
            -- Call the original function safely
            local activities = self.originalGetActivities()
            
            -- Process activities
            if activities then
                for _, activityInfo in ipairs(activities) do
                    -- The Mythic+ activity type is 1
                    if activityInfo.type == 1 and activityInfo.level and activityInfo.level > weeklyBest then
                        weeklyBest = activityInfo.level
                        self:SaveData()
                    end
                end
            end
            
            -- Reset the flag
            self.isProcessingActivities = false
        end)
        self.GetWeeklyChestRewardLevelHooked = true
    end
    
    -- Initialize data
    self:LoadSavedData()
end

-- Load saved data
function KeystoneInfo:LoadSavedData()
    if not Phoenix_UIPerCharDB then
        Phoenix_UIPerCharDB = {}
    end
    
    if not Phoenix_UIPerCharDB.mythicplus then
        Phoenix_UIPerCharDB.mythicplus = {
            keystoneHistory = {},
            dungeonHistory = {},
            seasonalBest = {},
            weeklyBest = 0,
        }
    end
    
    keystoneHistory = Phoenix_UIPerCharDB.mythicplus.keystoneHistory or {}
    dungeonHistory = Phoenix_UIPerCharDB.mythicplus.dungeonHistory or {}
    seasonalBest = Phoenix_UIPerCharDB.mythicplus.seasonalBest or {}
    weeklyBest = Phoenix_UIPerCharDB.mythicplus.weeklyBest or 0
    
    -- Ensure all current season dungeons have entries
    for mapID, _ in pairs(CURRENT_SEASON_DUNGEONS) do
        if not seasonalBest[mapID] then
            seasonalBest[mapID] = {
                fortified = { level = 0, score = 0, time = 0, completed = false },
                tyrannical = { level = 0, score = 0, time = 0, completed = false },
            }
        end
    end
    
    -- Update player scores
    self:UpdatePlayerScores()
end

-- Save data
function KeystoneInfo:SaveData()
    if not Phoenix_UIPerCharDB then return end
    
    Phoenix_UIPerCharDB.mythicplus = Phoenix_UIPerCharDB.mythicplus or {}
    Phoenix_UIPerCharDB.mythicplus.keystoneHistory = keystoneHistory
    Phoenix_UIPerCharDB.mythicplus.dungeonHistory = dungeonHistory
    Phoenix_UIPerCharDB.mythicplus.seasonalBest = seasonalBest
    Phoenix_UIPerCharDB.mythicplus.weeklyBest = weeklyBest
end

-- Update player scores
function KeystoneInfo:UpdatePlayerScores()
    local total = 0
    local count = 0
    
    for mapID, dungeonData in pairs(seasonalBest) do
        if CURRENT_SEASON_DUNGEONS[mapID] then
            local fortifiedScore = dungeonData.fortified.score or 0
            local tyrannicalScore = dungeonData.tyrannical.score or 0
            
            -- Use the higher of the two scores for this dungeon
            local dungeonScore = math.max(fortifiedScore, tyrannicalScore)
            
            -- Add to total score
            if dungeonScore > 0 then
                total = total + dungeonScore
                count = count + 1
            end
        end
    end
    
    -- Calculate average score if we have any dungeon scores
    local average = count > 0 and (total / count) or 0
    
    -- Store player scores
    playerScores = {
        total = total,
        average = average,
        dungeonCount = count
    }
    
    -- Save data
    self:SaveData()
end

-- Handle messages
function KeystoneInfo:PHOENIX_MYTHICPLUS_ENABLED()
    -- Use ScheduleRepeatingTimer if available, otherwise fallback to C_Timer
    if self.ScheduleRepeatingTimer then
        self:ScheduleRepeatingTimer("UpdateDungeonInfo", updateFrequency)
    else
        -- Fallback for when AceTimer is not available
        local function TimerLoop()
            self:UpdateDungeonInfo()
            C_Timer.After(updateFrequency, TimerLoop)
        end
        C_Timer.After(updateFrequency, TimerLoop)
    end
    
    -- Initial update
    self:UpdateDungeonInfo()
end

function KeystoneInfo:PHOENIX_MYTHICPLUS_KEYSTONE_UPDATED(_, keystoneData)
    -- Record keystone to history
    if keystoneData.level > 0 then
        table.insert(keystoneHistory, {
            level = keystoneData.level,
            mapID = keystoneData.mapID,
            name = keystoneData.name,
            time = GetServerTime()
        })
        
        -- Keep history to last 100 keystones
        while #keystoneHistory > 100 do
            table.remove(keystoneHistory, 1)
        end
        
        -- Save data
        self:SaveData()
    end
end

function KeystoneInfo:PHOENIX_MYTHICPLUS_START(_, timeLimit)
    -- Nothing special to do here yet
end

function KeystoneInfo:PHOENIX_MYTHICPLUS_COMPLETE(_, success)
    if success then
        -- Get challenge details using the modern API
        local mapChallengeModeID = C_ChallengeMode.GetActiveChallengeMapID()
        local level = C_ChallengeMode.GetActiveKeystoneInfo()
        local completionTime = C_ChallengeMode.GetCompletionTime()
        local onTime = C_ChallengeMode.IsCompletionTimerActive()
        local keystoneUpgrades = 0
        
        -- Calculate keystone upgrades based on time if completion was on time
        if onTime and completionTime > 0 and mapChallengeModeID then
            local timeLimit = CURRENT_SEASON_DUNGEONS[mapChallengeModeID] and CURRENT_SEASON_DUNGEONS[mapChallengeModeID].timeLimit or 0
            if timeLimit > 0 then
                local timeRemaining = timeLimit - completionTime
                local timePct = timeRemaining / timeLimit
                
                if timePct >= 0.4 then
                    keystoneUpgrades = 3  -- 40% or more time remaining = 3 chest
                elseif timePct >= 0.2 then
                    keystoneUpgrades = 2  -- 20% or more time remaining = 2 chest
                else
                    keystoneUpgrades = 1  -- Just in time = 1 chest
                end
            else
                keystoneUpgrades = 1  -- Default to 1 if we can't calculate
            end
        end
        
        if mapChallengeModeID and level and completionTime then
            -- Check if mapID is in current season
            if CURRENT_SEASON_DUNGEONS[mapChallengeModeID] then
                -- Get current affixes
                local affixes = C_MythicPlus.GetCurrentAffixes()
                local affixIDs = {}
                local isTyrannical = false
                
                -- Extract affix IDs and check for Tyrannical
                if affixes then
                    for _, affix in ipairs(affixes) do
                        table.insert(affixIDs, affix.id)
                        if affix.id == 9 then -- Tyrannical
                            isTyrannical = true
                        end
                    end
                end
                
                -- Determine which affix type this run was
                local affixType = isTyrannical and "tyrannical" or "fortified"
                
                -- Calculate score
                local baseScoreMultiplier = GetScoreMultiplierForLevel(level)
                local timeModifier = onTime and (keystoneUpgrades > 1 and (keystoneUpgrades > 2 and TIME_MODIFIER["ThreeChest"] or TIME_MODIFIER["TwoChest"]) or TIME_MODIFIER["OnTime"]) or TIME_MODIFIER["Overtime"]
                local score = baseScoreMultiplier * timeModifier
                
                -- Record run to history
                table.insert(dungeonHistory, {
                    mapID = mapChallengeModeID,
                    level = level,
                    time = completionTime,
                    timeLimit = CURRENT_SEASON_DUNGEONS[mapChallengeModeID] and CURRENT_SEASON_DUNGEONS[mapChallengeModeID].timeLimit or 0,
                    onTime = onTime,
                    affixes = affixIDs,
                    affixType = affixType,
                    keystoneUpgrades = keystoneUpgrades,
                    score = score,
                    timestamp = GetServerTime()
                })
                
                -- Keep history to last 100 runs
                while #dungeonHistory > 100 do
                    table.remove(dungeonHistory, 1)
                end
                
                -- Update seasonal best
                if not seasonalBest[mapChallengeModeID] then
                    seasonalBest[mapChallengeModeID] = {
                        fortified = { level = 0, score = 0, time = 0, completed = false },
                        tyrannical = { level = 0, score = 0, time = 0, completed = false },
                    }
                end
                
                local currentBest = seasonalBest[mapChallengeModeID][affixType]
                
                -- Check if this run is better than our current best
                local isNewBest = false
                
                if level > currentBest.level then
                    isNewBest = true
                elseif level == currentBest.level and score > currentBest.score then
                    isNewBest = true
                end
                
                if isNewBest then
                    seasonalBest[mapChallengeModeID][affixType] = {
                        level = level,
                        score = score,
                        time = completionTime,
                        completed = true,
                        onTime = onTime,
                        keystoneUpgrades = keystoneUpgrades,
                        timestamp = GetServerTime()
                    }
                    
                    -- Update player scores
                    self:UpdatePlayerScores()
                    
                    -- Notify about new best
                    if MythicPlus.db.profile.showSeasonNotification then
                        local dungeonName = CURRENT_SEASON_DUNGEONS[mapChallengeModeID] and CURRENT_SEASON_DUNGEONS[mapChallengeModeID].name or "Unknown Dungeon"
                        local message = string.format(L["New seasonal best for %s (%s): +%d - %.1f score!"], 
                            dungeonName, 
                            affixType:gsub("^%l", string.upper), 
                            level, 
                            score)
                            
                        MythicPlus:Print(message)
                    end
                end
                
                -- Update weekly best
                if level > weeklyBest then
                    weeklyBest = level
                end
                
                -- Save data
                self:SaveData()
            end
        end
    end
end

-- Event handlers
function KeystoneInfo:CHALLENGE_MODE_MAPS_UPDATE()
    self:UpdateDungeonInfo()
end

function KeystoneInfo:CHALLENGE_MODE_COMPLETED()
    self:UpdateDungeonInfo()
end

function KeystoneInfo:PLAYER_ENTERING_WORLD()
    self:UpdateDungeonInfo()
end

-- Update dungeon info
function KeystoneInfo:UpdateDungeonInfo()
    -- Don't update too frequently
    local currentTime = GetTime()
    if currentTime - lastUpdateTime < updateFrequency then
        return
    end
    lastUpdateTime = currentTime
    
    -- Get all available dungeon info
    local maps = C_ChallengeMode.GetMapTable()
    if not maps then return end
    
    -- Process each dungeon
    for _, mapID in ipairs(maps) do
        -- Get map info
        local mapName, _, timeLimit = C_ChallengeMode.GetMapUIInfo(mapID)
        
        -- Store/update dungeon info
        if mapName and timeLimit and CURRENT_SEASON_DUNGEONS[mapID] then
            CURRENT_SEASON_DUNGEONS[mapID].name = mapName
            CURRENT_SEASON_DUNGEONS[mapID].timeLimit = timeLimit
        end
    end
    
    -- Get current weekly best using the modern API - use safe approach
    if not self.isProcessingActivities then
        self.isProcessingActivities = true
        local activities = self.originalGetActivities and self.originalGetActivities() or C_WeeklyRewards.GetActivities()
        if activities then
            for _, activityInfo in ipairs(activities) do
                -- The Mythic+ activity type is 1
                if activityInfo.type == 1 and activityInfo.level and activityInfo.level > weeklyBest then
                    weeklyBest = activityInfo.level
                    self:SaveData()
                end
            end
        end
        self.isProcessingActivities = false
    end
end

-- Get player score
function KeystoneInfo:GetPlayerScore()
    return playerScores
end

-- Get seasonal best for all dungeons
function KeystoneInfo:GetSeasonalBest()
    return seasonalBest
end

-- Get seasonal best for a specific dungeon
function KeystoneInfo:GetDungeonBest(mapID)
    return seasonalBest[mapID]
end

-- Get weekly best
function KeystoneInfo:GetWeeklyBest()
    return weeklyBest
end

-- Get dungeon history
function KeystoneInfo:GetDungeonHistory()
    return dungeonHistory
end

-- Get keystone history
function KeystoneInfo:GetKeystoneHistory()
    return keystoneHistory
end

-- Get score estimate for a dungeon at specific level
function KeystoneInfo:GetScoreEstimate(mapID, level, inTime)
    if not CURRENT_SEASON_DUNGEONS[mapID] then
        return 0
    end
    
    local baseScoreMultiplier = GetScoreMultiplierForLevel(level)
    local timeModifier = inTime and TIME_MODIFIER["OnTime"] or TIME_MODIFIER["Overtime"]
    
    return baseScoreMultiplier * timeModifier
end

-- Calculate predicted rating for the season
function KeystoneInfo:GetPredictedRating()
    local allDungeons = {}
    local dupeCheck = {}
    local totalScore = 0
    
    -- First combine all dungeon scores across fortified and tyrannical
    for mapID, data in pairs(seasonalBest) do
        if CURRENT_SEASON_DUNGEONS[mapID] then
            -- Get scores for both affixes
            local fortifiedScore = data.fortified.score or 0
            local tyrannicalScore = data.tyrannical.score or 0
            
            -- Add both scores to our list
            if fortifiedScore > 0 then
                table.insert(allDungeons, {mapID = mapID, score = fortifiedScore, affixType = "fortified"})
            end
            
            if tyrannicalScore > 0 then
                table.insert(allDungeons, {mapID = mapID, score = tyrannicalScore, affixType = "tyrannical"})
            end
        end
    end
    
    -- Sort all scores from highest to lowest
    table.sort(allDungeons, function(a, b) return a.score > b.score end)
    
    -- Final score uses the 8 highest unique dungeon+affix combinations
    -- To reach the max score, you need your best runs for each dungeon on both affixes
    local used = 0
    
    for _, entry in ipairs(allDungeons) do
        local key = entry.mapID .. "-" .. entry.affixType
        
        if not dupeCheck[key] then
            dupeCheck[key] = true
            totalScore = totalScore + entry.score
            used = used + 1
            
            -- Stop after we have 8 unique dungeon+affix combinations (or fewer if not enough completed)
            if used >= 8 then
                break
            end
        end
    end
    
    -- Return total score and how many unique dungeon+affix combinations were used
    return totalScore, used
end

-- Get formatted player score text
function KeystoneInfo:GetFormattedScoreText()
    local totalScore, usedCount = self:GetPredictedRating()
    
    -- Color the score based on ranges (similar to in-game coloring)
    local colorStr = "|cffffffff" -- Default white
    
    if totalScore >= 2500 then
        colorStr = "|cffa335ee" -- Epic/Purple for very high scores
    elseif totalScore >= 2000 then
        colorStr = "|cff0070dd" -- Rare/Blue for high scores
    elseif totalScore >= 1500 then
        colorStr = "|cff1eff00" -- Uncommon/Green for average scores
    elseif totalScore >= 1000 then
        colorStr = "|cffffffff" -- Common/White for basic scores
    else
        colorStr = "|cff9d9d9d" -- Poor/Gray for low scores
    end
    
    local scoreText = string.format("%s%d|r", colorStr, totalScore)
    local fullText = string.format(L["M+ Score: %s (%d/%d)"], scoreText, usedCount, 8)
    
    return fullText
end

-- Return module to parent
MythicPlus.KeystoneInfo = KeystoneInfo