local GetRaidTargetIndex, InCombatLockdown, UnitAffectingCombat, UnitClass = GetRaidTargetIndex, InCombatLockdown, UnitAffectingCombat, UnitClass
local UnitExists, UnitHealth, UnitHealthMax, UnitIsAFK = UnitExists, UnitHealth, UnitHealthMax, UnitIsAFK
local UnitIsConnected, UnitIsDeadOrGhost, UnitIsDND = UnitIsConnected, UnitIsDeadOrGhost, UnitIsDND
local UnitIsPlayer, UnitIsPVP, UnitIsTapDenied = UnitIsPlayer, UnitIsPVP, UnitIsTapDenied
local UnitIsTrivial, UnitIsUnit, UnitLevel = UnitIsTrivial, UnitIsUnit, UnitLevel
local UnitName, UnitPVPName, UnitReaction = UnitName, UnitPVPName, UnitReaction
local UnitGroupRolesAssigned = UnitGroupRolesAssigned
local floor = math.floor

local Phoenix_Tooltip = Phoenix_UI:GetModule("Tooltip.Core")

-- Initialize text localization - ensure T is never nil
local T = Phoenix_UI.Text or {
    ["YOU"] = "YOU",
    ["Target"] = "Target",
    ["<AFK>"] = "<AFK>",
    ["<DND>"] = "<DND>",
    ["Health"] = "Health"
}

-- Cache for tooltip data to avoid redundant operations
local tooltipCache = {}

-- Function to clean up tooltip cache to prevent memory bloat
local function CleanupTooltipCache()
    local now = GetTime()
    for unitGUID, data in pairs(tooltipCache) do
        if now - data.time > 60 then -- Clear entries older than one minute
            tooltipCache[unitGUID] = nil
        end
    end
end

-- Set up cache cleanup timer
C_Timer.After(5, function()
    C_Timer.NewTicker(60, CleanupTooltipCache)
end)

-- Fallback mechanism to avoid nil errors with text localization
local function GetLocalizedText(key, defaultText)
    if T and T[key] then
        return T[key]
    end
    return defaultText
end

-- Create a function to return the Role Icon for the player
local function GetRoleIcon(unit)
    if not UnitIsPlayer(unit) then return "" end
    
    local role = UnitGroupRolesAssigned(unit)
    if role == "TANK" then
        return "|TInterface\\LFGFrame\\UI-LFG-ICON-PORTRAITROLES:14:14:0:0:64:64:0:19:22:41|t"
    elseif role == "HEALER" then
        return "|TInterface\\LFGFrame\\UI-LFG-ICON-PORTRAITROLES:14:14:0:0:64:64:20:39:1:20|t"
    elseif role == "DAMAGER" then
        return "|TInterface\\LFGFrame\\UI-LFG-ICON-PORTRAITROLES:14:14:0:0:64:64:20:39:22:41|t"
    end
    return ""
end

-- Format large health numbers
local function FormatHealthNumber(number)
    if not number then return "0" end
    
    if number >= 1000000 then
        return string.format("%.1fM", number / 1000000)
    elseif number >= 1000 then
        return string.format("%.1fK", number / 1000)
    else
        return tostring(number)
    end
end

-- Get item level safely
local function GetItemLevel(unit)
    -- Direct call to the Core module if function exists
    if Phoenix_Tooltip.GetItemLevel then
        return Phoenix_Tooltip:GetItemLevel(unit)
    end
    
    -- Fallback to built-in API for player only
    if UnitIsUnit(unit, "player") and C_PaperDollInfo and C_PaperDollInfo.GetAverageItemLevel then
        local avgItemLevel = C_PaperDollInfo.GetAverageItemLevel()
        if avgItemLevel then
            return math.floor(avgItemLevel)
        end
    end
    
    return nil
end

-- Enhanced tooltip method that supports target of target and role indicators
function Phoenix_Tooltip:DisplayUnit(tooltip, unit)
    if not tooltip or not unit then return end
    
    local db = Phoenix_UI.db.profile.tooltip
    if not db then return end
    
    -- Check combat state if hide in combat is enabled
    if InCombatLockdown() and db.hideincombat then 
        tooltip:Hide()
        return 
    end
    
    local unitExists = UnitExists(unit)
    if not unitExists then return end
    
    local unitGUID = UnitGUID(unit)
    
    -- Check cache for recent display
    if unitGUID and tooltipCache[unitGUID] then
        local now = GetTime()
        -- Only update if it's been more than 0.5 seconds since last update
        if now - tooltipCache[unitGUID].time < 0.5 then
            return
        end
    end
    
    -- Update cache
    if unitGUID then
        tooltipCache[unitGUID] = {
            time = GetTime()
        }
    end
    
    -- Role Icons
    if db.roleIcons and UnitIsPlayer(unit) then
        local roleIcon = GetRoleIcon(unit)
        if roleIcon ~= "" then
            local firstLine = _G[tooltip:GetName().."TextLeft1"]
            if firstLine then
                local text = firstLine:GetText()
                if text and not text:find("Interface\\LFGFrame\\UI%-LFG%-ICON%-PORTRAITROLES") then
                    firstLine:SetText(roleIcon .. " " .. text)
                end
            end
        end
    end
    
    -- Target of target information
    if db.targetOfTarget and UnitExists(unit .. "target") then
        local targetName = UnitName(unit.."target")
        if targetName then
            local targetReaction = UnitReaction(unit.."target", "player")
            local targetClass = UnitIsPlayer(unit.."target") and select(2, UnitClass(unit.."target"))
            
            -- Format target name with appropriate colors
            local targetText
            if UnitIsUnit(unit.."target", "player") then
                targetText = "|cffff0000"..GetLocalizedText("YOU", "YOU"):upper().."|r"
            elseif targetClass then
                local color = RAID_CLASS_COLORS[targetClass]
                targetText = string.format("|cff%02x%02x%02x%s|r", 
                    color.r * 255, color.g * 255, color.b * 255, targetName)
            elseif targetReaction then
                local color = FACTION_BAR_COLORS[targetReaction]
                targetText = string.format("|cff%02x%02x%02x%s|r", 
                    color.r * 255, color.g * 255, color.b * 255, targetName)
            else
                targetText = targetName
            end
            
            tooltip:AddDoubleLine(GetLocalizedText("Target", "Target") .. ":", targetText)
        end
    end
    
    -- Health information
    if db.showHealth then
        local hp = UnitHealth(unit)
        local maxhp = UnitHealthMax(unit)
        if hp and maxhp and maxhp > 0 then
            local percent = floor(hp/maxhp*100)
            
            local formattedHp = FormatHealthNumber(hp)
            local formattedMaxHp = FormatHealthNumber(maxhp)
            
            -- Set text color based on health percentage
            local r, g, b = 1, 0, 0  -- Default to red (low health)
            if percent > 75 then
                r, g, b = 0, 1, 0    -- Green for high health
            elseif percent > 30 then
                r, g, b = 1, 1, 0    -- Yellow for medium health
            end
            
            tooltip:AddLine(GetLocalizedText("Health", "Health") .. ": " .. 
                formattedHp .. " / " .. formattedMaxHp .. " (" .. percent .. "%)", r, g, b)
        end
    end
    
    -- Item level information
    if db.showItemLevel and UnitIsPlayer(unit) then
        local itemLevel = GetItemLevel(unit)
        if itemLevel then
            local r, g, b = 1, 1, 0 -- Default yellow
            
            if itemLevel >= 470 then -- Current season high level gear
                r, g, b = 1, 0.5, 0 -- Orange for high level
            elseif itemLevel >= 450 then -- Current season normal gear
                r, g, b = 0, 1, 0   -- Green for good level
            elseif itemLevel < 420 then -- Below current content
                r, g, b = 0.5, 0.5, 0.5 -- Gray for low level
            end
            
            tooltip:AddLine("iLvl: " .. itemLevel, r, g, b)
        end
    end
    
    -- Who's targeting information
    if db.whoTargeting and UnitExists(unit) then
        local targeting = {}
        for i=1, GetNumGroupMembers() do
            local raidUnit = (IsInRaid() and "raid"..i or "party"..i)
            if UnitIsUnit(raidUnit.."target", unit) then
                local name = UnitName(raidUnit)
                if name then
                    table.insert(targeting, name)
                end
            end
        end
        
        if #targeting > 0 then
            tooltip:AddLine("Targeted by: " .. table.concat(targeting, ", "), 0.8, 0.8, 0.8)
        end
    end
    
    -- Spell IDs
    if db.spellIDs then
        local spellId = select(2, tooltip:GetSpell())
        if spellId then
            tooltip:AddLine("Spell ID: " .. spellId, 0.7, 0.7, 0.7)
        end
    end
    
    tooltip:Show() -- Refresh the tooltip
end

-- Register for config changes
Phoenix_UI:RegisterMessage("PHOENIX_UI_CONFIG_CHANGED", function(_, module)
    if module == "tooltip" then
        -- Clear caches to ensure fresh data with new settings
        wipe(tooltipCache)
        
        -- Force tooltip update if hovering over something
        local tooltip = GameTooltip
        if tooltip:IsShown() then
            local owner = tooltip:GetOwner()
            if owner then
                tooltip:Hide()
                tooltip:Show()
            end
        end
    end
end) 