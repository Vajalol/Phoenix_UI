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

-- Enhanced tooltip method that supports target of target and role indicators
function Phoenix_Tooltip:DisplayUnit(tooltip, unit)
    local db = Phoenix_UI.db.profile.tooltip
    
    if not unit then return end
    if InCombatLockdown() and db.hideincombat then return end
    
    local unitExists = UnitExists(unit)
    if not unitExists then return end
    
    -- Instead of overriding the name, which is handled by _Core.lua
    -- just add role indicator if needed
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
        
        -- Add target information to tooltip
        tooltip:AddDoubleLine(GetLocalizedText("Target", "Target") .. ":", targetText)
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
    
    -- Health information - only add if not already present
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
            local formattedHp = BreakUpLargeNumbers and BreakUpLargeNumbers(hp) or tostring(hp)
            local formattedMaxHp = BreakUpLargeNumbers and BreakUpLargeNumbers(maxhp) or tostring(maxhp)
            tooltip:AddLine(GetLocalizedText("Health", "Health") .. ": " .. formattedHp .. " / " .. formattedMaxHp .. " (" .. percent .. "%)")
        end
    end
end 