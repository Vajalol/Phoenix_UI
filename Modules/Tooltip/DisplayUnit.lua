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
    local db = Phoenix_UI.db.profile.tooltip
    
    if not unit or not tooltip then return end
    if InCombatLockdown() and db.hideincombat then return end
    
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
    
    -- Role Icons - Only add if not already present
    if db.roleIcons and UnitIsPlayer(unit) then
        local roleIcon = GetRoleIcon(unit)
        if roleIcon ~= "" then
            local firstLine = _G[tooltip:GetName().."TextLeft1"]
            local text = firstLine and firstLine:GetText()
            if text and not text:find("Interface\\LFGFrame\\UI%-LFG%-ICON%-PORTRAITROLES") then
                firstLine:SetText(roleIcon .. " " .. text)
            end
        end
    end
    
    -- Target of target information
    if db.targetOfTarget and UnitExists(unit .. "target") then
        local targetName = UnitName(unit.."target")
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
        
        -- Add target information to tooltip (only if not already present)
        local targetLine = false
        for i = 2, tooltip:NumLines() do
            local line = _G[tooltip:GetName().."TextLeft"..i]
            local text = line and line:GetText() or ""
            if text:find(GetLocalizedText("Target", "Target")) then
                targetLine = true
                break
            end
        end
        
        if not targetLine then
            tooltip:AddDoubleLine(GetLocalizedText("Target", "Target") .. ":", targetText)
        end
    end
    
    -- Status indicator (AFK/DND) - only if not already added
    if UnitIsPlayer(unit) then
        local statusAdded = false
        for i = 2, tooltip:NumLines() do
            local line = _G[tooltip:GetName().."TextLeft"..i]
            local text = line and line:GetText() or ""
            if text:find("<AFK>") or text:find("<DND>") then
                statusAdded = true
                break
            end
        end
        
        if not statusAdded then
            if UnitIsAFK(unit) then
                tooltip:AddLine(GetLocalizedText("<AFK>", "<AFK>"), 0.5, 0.5, 1)
            elseif UnitIsDND(unit) then
                tooltip:AddLine(GetLocalizedText("<DND>", "<DND>"), 1, 0, 0)
            end
        end
    end
    
    -- Health information - only add if not already present and enabled
    if db.showHealth then
        local hp = UnitHealth(unit)
        local maxhp = UnitHealthMax(unit)
        local percent = maxhp > 0 and floor(hp/maxhp*100) or 0
        
        -- Check if health information is already in the tooltip
        local healthInfoExists = false
        for i = 2, tooltip:NumLines() do
            local line = _G[tooltip:GetName().."TextLeft"..i]
            local text = line and line:GetText() or ""
            if text:find(GetLocalizedText("Health", "Health")) then
                healthInfoExists = true
                break
            end
        end
        
        if not healthInfoExists then
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
    
    -- Add item level if enabled and available
    if db.showItemLevel and UnitIsPlayer(unit) then
        local itemLevel = GetItemLevel(unit)
        if itemLevel then
            -- Check if item level is already in the tooltip
            local itemLevelExists = false
            for i = 2, tooltip:NumLines() do
                local line = _G[tooltip:GetName().."TextLeft"..i]
                local text = line and line:GetText() or ""
                if text:find("iLvl:") then
                    itemLevelExists = true
                    break
                end
            end
            
            if not itemLevelExists then
                -- Color code the item level based on value
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
    end
    
    tooltip:Show()
end 