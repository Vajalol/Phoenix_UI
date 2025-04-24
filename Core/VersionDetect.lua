-- Phoenix_UI Version Detection and Compatibility
-- This file detects the WoW version and sets up appropriate compatibility flags

local addonName, addon = ...

-- WoW version detection constants
local RETAIL = 1
local WRATH = 2
local TBC = 3
local CLASSIC = 4
local CATACLYSM = 5

-- Initialize Phoenix_UI global
_G[addonName] = _G[addonName] or {}
Phoenix_UI = _G[addonName]

-- Initialize Phoenix_UI.gameVersion table
Phoenix_UI.gameVersion = {
    isRetail = false,
    isWrath = false,
    isTBC = false,
    isClassic = false,
    isCataclysm = false,
    versionName = "Unknown",
    versionId = 0,
}

-- Detect WoW version
local function DetectWoWVersion()
    local gameVersion = Phoenix_UI.gameVersion
    
    -- Check if WOW_PROJECT_ID is defined (it should be in all modern versions)
    if WOW_PROJECT_ID then
        if WOW_PROJECT_ID == WOW_PROJECT_MAINLINE then
            gameVersion.isRetail = true
            gameVersion.versionName = "Retail"
            gameVersion.versionId = RETAIL
        elseif WOW_PROJECT_ID == WOW_PROJECT_WRATH_CLASSIC then
            gameVersion.isWrath = true
            gameVersion.versionName = "Wrath Classic"
            gameVersion.versionId = WRATH
        elseif WOW_PROJECT_ID == WOW_PROJECT_BURNING_CRUSADE_CLASSIC then
            gameVersion.isTBC = true
            gameVersion.versionName = "Burning Crusade Classic"
            gameVersion.versionId = TBC
        elseif WOW_PROJECT_ID == WOW_PROJECT_CLASSIC then
            gameVersion.isClassic = true
            gameVersion.versionName = "Classic Era"
            gameVersion.versionId = CLASSIC
        elseif WOW_PROJECT_ID == WOW_PROJECT_CATACLYSM_CLASSIC then
            gameVersion.isCataclysm = true
            gameVersion.versionName = "Cataclysm Classic"
            gameVersion.versionId = CATACLYSM
        end
    else
        -- Fallback detection for older versions
        local _, build = GetBuildInfo()
        local buildNumber = tonumber(build)
        
        if buildNumber > 40000 then
            gameVersion.isRetail = true
            gameVersion.versionName = "Retail"
            gameVersion.versionId = RETAIL
        elseif buildNumber > 20000 then
            gameVersion.isWrath = true
            gameVersion.versionName = "Wrath Classic"
            gameVersion.versionId = WRATH
        elseif buildNumber > 8000 then
            gameVersion.isTBC = true
            gameVersion.versionName = "Burning Crusade Classic"
            gameVersion.versionId = TBC
        else
            gameVersion.isClassic = true
            gameVersion.versionName = "Classic Era"
            gameVersion.versionId = CLASSIC
        end
    end
    
    -- Print version detection (only in debug mode)
    if Phoenix_UI.debug then
        print("|cffFF7D0APhoenix|r|cffFF0000_|r|cffFFD100UI|r: Detected WoW version: " .. gameVersion.versionName)
    end
end

-- Initialize API compatibility layer
local function InitAPICompatibility()
    local gameVersion = Phoenix_UI.gameVersion
    
    -- Create compatibility functions based on version
    Phoenix_UI.compat = Phoenix_UI.compat or {}
    local compat = Phoenix_UI.compat
    
    -- Example compatibility functions
    
    -- Get color string for class
    compat.GetClassColorStr = function(className)
        if gameVersion.isRetail or gameVersion.isWrath or gameVersion.isCataclysm then
            local color = RAID_CLASS_COLORS[className] or NORMAL_FONT_COLOR
            return string.format("ff%02x%02x%02x", color.r * 255, color.g * 255, color.b * 255)
        else
            -- Classic fallback
            local color = RAID_CLASS_COLORS[className] or NORMAL_FONT_COLOR
            return string.format("ff%02x%02x%02x", color.r * 255, color.g * 255, color.b * 255)
        end
    end
    
    -- Get AddOn data
    compat.GetAddOnInfo = function(addonName)
        if C_AddOns and C_AddOns.GetAddOnInfo then
            return C_AddOns.GetAddOnInfo(addonName)
        else
            return GetAddOnInfo(addonName)
        end
    end
    
    -- Check if AddOn is loaded
    compat.IsAddOnLoaded = function(addonName)
        if C_AddOns and C_AddOns.IsAddOnLoaded then
            return C_AddOns.IsAddOnLoaded(addonName)
        else
            return IsAddOnLoaded(addonName)
        end
    end
    
    -- Disable AddOn
    compat.DisableAddOn = function(addonName)
        if C_AddOns and C_AddOns.DisableAddOn then
            return C_AddOns.DisableAddOn(addonName)
        else
            return DisableAddOn(addonName)
        end
    end
    
    -- Guild Roster refresh
    compat.GuildRoster = function()
        if C_GuildInfo and C_GuildInfo.GuildRoster then
            return C_GuildInfo.GuildRoster()
        else
            return GuildRoster()
        end
    end
    
    -- Define additional compatibility functions as needed for different WoW versions
end

-- Run detection and setup
DetectWoWVersion()
InitAPICompatibility()

-- Make functions available in the addon namespace
Phoenix_UI.DetectWoWVersion = DetectWoWVersion 