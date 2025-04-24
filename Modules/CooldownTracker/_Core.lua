-- Phoenix_UI: CooldownTracker Core Module
-- Integrates functionality similar to OmniCC, TrufiGCD, and OmniCD 
-- Complete feature implementation to match original addons

--[[
    CooldownTracker provides cooldown text, spell tracking, and party cooldown monitoring in one integrated module.
    
    Integration with Phoenix_UI:
    1. Core Module (this file) - Main functionality and submodule coordination 
    2. Config Module (_Config.lua) - Registers with Phoenix_UI config panel
    3. Submodules:
       - CooldownText - OmniCC-like cooldown text functionality
       - SpellTracker - TrufiGCD-like spell tracking
       - PartyCD - OmniCD-like party cooldown tracking
       
    The module is fully integrated with Phoenix_UI's configuration system and uses the shared database.
    You can access configuration via /cooldowntracker, /cdtracker, or /cdt slash commands,
    or through the main Phoenix_UI configuration panel.
]]

local Module = Phoenix_UI:NewModule("CooldownTracker", "AceEvent-3.0");
local LSM = LibStub("LibSharedMedia-3.0")
local LibCustomGlow = LibStub("LibCustomGlow-1.0", true)
local LibSpec = LibStub("LibSpecialization", true)

-- Default settings with all enhanced options
local defaults = {
    -- General settings
    general = {
        enableKeybinds = true,
        performanceMode = false, -- Reduces update frequency in heavy combat
        showModuleButtons = true, -- Show module toggle buttons in UI
        minimapButton = true,
        version = "11.0.43", -- Match Phoenix_UI version
    },
    
    -- Enhanced CooldownText settings (OmniCC-like)
    cooldownText = {
        enabled = true,
        minDuration = 2.5,       -- Only show for cooldowns longer than this
        mmSSDuration = 10,       -- mm:ss format threshold
        tenthsDuration = 5,      -- Show tenths of seconds threshold
        swipe = true,            -- Show the cooldown swipe
        textSize = 15,           -- Font size for cooldown text
        textPosition = "CENTER", -- CENTER, TOP, BOTTOM
        expiringDuration = 3,    -- When to start flashing/changing color
        enableAnimations = true,  -- Enable animations for cooldown text
        textFont = "Interface\\AddOns\\Phoenix_UI\\Media\\Fonts\\Expressway.ttf",
        textOutline = "OUTLINE",
        textColor = {1, 1, 1},   -- Default white
        expiringColor = {1, 0.3, 0.3}, -- Red when expiring
        soonColor = {1, 0.7, 0}, -- Yellow for soon expiring
        minuteColor = {0.6, 0.6, 1}, -- Cyan for minutes
        hourColor = {0.4, 0.4, 1}, -- Blue for hours
        daysColor = {0.4, 0.4, 0.6}, -- Gray for days
        secondsColor = {1, 1, 1}, -- White for seconds
        formatSettings = {
            day = "%dd",
            hour = "%dh",
            minute = "%dm",
            shortMinute = "%d:%02d",
            second = "%d",
            tenths = "%.1f",
            soon = "Soon",
        },
        
        -- Font settings
        fontFace = nil,          -- Use Phoenix_UI default
        scaleText = true,        -- Scale text based on frame size
        
        -- Finish effects
        finishEffects = {
            enableFlash = true,
            flashColor = {1, 1, 1, 0.7},
            enablePulse = true,
            pulseScale = 1.5,
            enableShine = false,
            shineColor = {1, 1, 1, 0.7},
        },
        
        -- Rule groups for different frame types
        rules = {
            actionBar = {
                scale = 1,
                enabled = true
            },
            bags = {
                scale = 0.75,
                enabled = true
            },
            nameplates = {
                scale = 0.8,
                enabled = true
            },
            unitFrames = {
                scale = 0.9,
                enabled = true
            },
            minScale = 0.5, -- Minimum scale for very small cooldowns
            minSize = 15,   -- Minimum size of cooldown to show text on
        },
    },
    
    -- Enhanced SpellTracker settings (TrufiGCD-like)
    spellTracker = {
        enabled = true,
        displayMode = "ICON", -- ICON, BAR, TEXT
        size = 30,           -- Icon size
        maxIcons = 5,        -- Number of recent spells to show
        direction = "LEFT",  -- Direction of icon flow
        fadeTime = 3,        -- How long spells stay visible
        
        -- Animation settings
        fadeInTime = 0.2,
        fadeOutTime = 0.3,
        animationType = "FADE", -- FADE, SCALE, SLIDE
        
        -- Filtering options
        showTooltip = true,  -- Show spell tooltips on mouseover
        blacklist = {},      -- Spells to ignore
        whitelist = {},      -- Spells to always show
        
        -- Filter by categories 
        showDamageSpells = true,
        showHealingSpells = true,
        showUtilitySpells = true,
        showInterrupts = true,
        showDispels = true,
        
        -- Filter by schools
        showArcane = true,
        showFire = true,
        showFrost = true,
        showNature = true,
        showShadow = true,
        showHoly = true,
        showPhysical = true,
        
        -- Visual settings
        opacity = 0.8,         -- Transparency
        showGlow = true,     -- Show glow on recent spells
        showSpellName = false, -- Show spell name under icon
        highlightImportant = true, -- Highlight important spells
        importantScale = 1.3, -- Scale for important spells
        position = {"CENTER", "UIParent", "CENTER", 0, -140},
        
        -- Bar mode settings (when displayMode = "BAR")
        barWidth = 150,
        barHeight = 18,
        barTexture = "Blizzard",
        barColor = {0.2, 0.4, 0.8},
        barTextSize = 10,
        barTextAlign = "LEFT",
        barIconPosition = "LEFT", -- LEFT or RIGHT
        
        -- Spec-specific settings
        perSpec = {
            -- These will be populated for each spec
        },
        
        -- Extended features
        includeChannel = true,
        showCooldown = true,
        showBorder = true,
        borderColor = {0.3, 0.3, 0.3, 1},
        filterOptions = {
            minDuration = 0,
            maxDuration = 0, -- 0 means no limit
            onlyPlayer = true,
            showPet = true,
            ignoreAutoAttacks = true,
            ignoreHeals = false,
            filterBySchool = {},  -- Empty means show all
            priority = {
                ["INTERRUPT"] = 10,
                ["DISPEL"] = 9,
                ["DEFENSIVE"] = 8,
                ["OFFENSIVE"] = 7,
                ["HEALING"] = 6,
                ["UTILITY"] = 5,
                ["STANDARD"] = 3
            }
        },
        animations = {
            fadeIn = {
                duration = 0.2,
                type = "alpha", -- alpha, scale, slide
            },
            fadeOut = {
                duration = 0.3,
                type = "alpha", -- alpha, scale, slide
            },
            highlight = {
                duration = 0.3,
                color = {1, 1, 1, 0.5}
            }
        },
        scalingOptions = {
            baseScale = 1.0,
            priorityScaling = true, -- Scale important spells larger
            priorityMultiplier = 1.2,
            combatMultiplier = 1.1 -- Scale up during combat
        }
    },
    
    -- Enhanced PartyCD settings (OmniCD-like)
    partyCD = {
        enabled = true,
        displayMode = "ICON", -- ICON, BAR, INLINEICON
        showOnFrames = true,   -- Show on party/raid frames
        standalonePanels = false, -- Show standalone panels
        raidPanel = {
            enabled = true,
            growth = "RIGHT",
            scale = 1.0,
            spacing = 2,
            columns = 5,
            showName = true,
            size = 22,
            position = {"TOPLEFT", "UIParent", "TOPLEFT", 300, -300}
        },
        iconSize = 18,         -- Size of cooldown icons
        barWidth = 140,        -- Width of bars in BAR mode
        barHeight = 18,        -- Height of bars in BAR mode
        barTexture = "Blizzard", -- Bar texture
        showText = true,       -- Show text on cooldown icons
        textSize = 10,         -- Cooldown text size
        showIcon = true,       -- Show icon in BAR mode
        alertSound = nil,      -- Sound to play when cooldown is ready
        flashAnimation = true, -- Flash when cooldown is ready
        
        -- Cooldown type settings
        trackedCDs = {         -- Categories to track
            interrupt = true,  -- Interrupts
            defensive = true,  -- Defensive cooldowns
            offensive = true,  -- Major offensive CDs
            raidCD = true,     -- Major raid CDs
            utility = true,    -- Utility cooldowns
            covenant = true,   -- Covenant abilities
            dispel = true,     -- Dispel abilities
            custom = true,     -- Custom added cooldowns
        },
        
        -- Raid leader tools
        raidTools = {
            enabled = false,
            assignCDs = true,  -- Allow CD assignment
            requestCDs = true, -- Request CD usage
            showPlannedCDs = true, -- Show planned CD usage
            showHistoryCDs = true, -- Show historic CD usage
        },
        
        -- Display settings by role
        roleSettings = {
            TANK = { enabled = true, scale = 1.0, alpha = 1.0 },
            HEALER = { enabled = true, scale = 1.0, alpha = 1.0 },
            DAMAGER = { enabled = true, scale = 0.8, alpha = 0.8 },
        },
        
        -- Integration with boss mods
        bossModIntegration = {
            enabled = false,
            showCDsForNextMechanic = true,
            highlightNeededCDs = true,
        },
        
        -- Class color settings
        useClassColors = true,
        
        -- Track external cooldown reduction
        trackCDReduction = true,
        
        -- Highlight active cooldowns
        highlightActive = true,
        
        -- Custom class cooldowns (expanded from previous)
        classCooldowns = {}, -- Will be populated from module data
        
        -- Extended features
        displayMode = "ICON", -- ICON, BAR, RAID_ICON
        raidPanel = {
            enabled = true,
            anchorPoint = "TOPLEFT",
            position = {"CENTER", "UIParent", "CENTER", 200, 0},
            growDirection = "DOWN",
            showEmptyCDs = true,
            showLabel = true,
            width = 200,
            height = 250,
            barWidth = 180,
            barHeight = 18,
            barSpacing = 2,
            barTexture = "Interface\\AddOns\\Phoenix_UI\\Media\\Textures\\Status\\Flat.blp",
            backgroundColor = {0, 0, 0, 0.5},
            borderColor = {0.3, 0.3, 0.3, 1},
            inactiveAlpha = 0.5,
            outOfRangeAlpha = 0.5,
            showClassColors = true,
            groupByClass = true,
            showDeadMembersText = true,
            iconPosition = "LEFT", -- LEFT, RIGHT
        },
        cooldownTypes = {
            interrupt = {
                enabled = true,
                priority = 10,
                color = {0.6, 0.8, 1, 1}
            },
            defensive = {
                enabled = true,
                priority = 8,
                color = {0.3, 0.7, 0.3, 1}
            },
            offensive = {
                enabled = true,
                priority = 7,
                color = {1, 0.3, 0.3, 1}
            },
            raidCD = {
                enabled = true,
                priority = 9,
                color = {1, 0.8, 0, 1}
            },
            utility = {
                enabled = true,
                priority = 5,
                color = {0.7, 0.3, 0.8, 1}
            },
            covenant = {
                enabled = true,
                priority = 6,
                color = {0.4, 0.7, 0.9, 1}
            }
        },
        integration = {
            bossModsEnabled = true,
            showPlannedCDs = true,
            announceRaidCDs = false,
            announceMissedInterrupts = false
        },
    }
}

-- Cache frequently used functions
local GetTime = GetTime
local CreateFrame = CreateFrame
local pairs, ipairs = pairs, ipairs
local tinsert, tremove, wipe = table.insert, table.remove, wipe
local format, floor, min, max = string.format, math.floor, math.min, math.max

-- Performance throttling constants
local NORMAL_THROTTLE = 0.05  -- Update every 0.05 seconds in normal conditions
local HEAVY_THROTTLE = 0.2    -- Update every 0.2 seconds under heavy load
local updateThrottle = NORMAL_THROTTLE
local heavyLoad = false
local inCombat = false

-- Callback system for module events
local callbacks = {}

-- Register a callback for a specific event
function Module:RegisterCallback(event, callback)
    if not event or type(callback) ~= "function" then return end
    
    callbacks[event] = callbacks[event] or {}
    tinsert(callbacks[event], callback)
    
    self:LogDebug("Registered callback for event: " .. tostring(event))
end

-- Fire a callback for a specific event
function Module:FireCallback(event, ...)
    if not event or not callbacks[event] then return end
    
    for _, callback in ipairs(callbacks[event]) do
        local success, err = pcall(callback, self, ...)
        if not success then
            self:LogError("Error in callback for event " .. tostring(event) .. ": " .. tostring(err))
        end
    end
end

-- Initialize local cache for module data
local cooldownCache = {
    addonCooldowns = {},
    frames = {}
}

-- Cache the font path for use by submodules
function Module:GetFontPath()
    if not fontPath then
        -- Check for LibSharedMedia
        if LSM then
            fontPath = LSM:Fetch("font", "Expressway") or 
                      LSM:Fetch("font", "Arial Narrow") or
                      LSM:Fetch("font", "Friz Quadrata TT")
        end
        
        -- Fallback to Phoenix_UI's fonts
        if not fontPath and Phoenix_UI.Media and Phoenix_UI.Media.Fonts and Phoenix_UI.Media.Fonts.Normal then
            fontPath = Phoenix_UI.Media.Fonts.Normal
        end
        
        -- Ultimate fallback
        if not fontPath then
            fontPath = "Interface\\AddOns\\Phoenix_UI\\Media\\Fonts\\Expressway.ttf"
            if not fontPath then
                fontPath = STANDARD_TEXT_FONT
            end
        end
    end
    return fontPath
end

-- Get status bar texture path
function Module:GetBarTexture(textureName)
    if not textureName or textureName == "Blizzard" then
        return "Interface\\TARGETINGFRAME\\UI-StatusBar"
    end
    
    if LSM then
        return LSM:Fetch("statusbar", textureName) or "Interface\\TARGETINGFRAME\\UI-StatusBar"
    end
    
    return "Interface\\TARGETINGFRAME\\UI-StatusBar"
end

-- Get sound path
function Module:GetSoundByName(soundName)
    if not soundName then return nil end
    
    if LSM then
        return LSM:Fetch("sound", soundName)
    end
    
    return soundName -- Return as-is, might be a file path
end

function Module:OnInitialize()
    -- Initialize database with defaults
    self:EnsureDBDefaults()
    
    -- Initialize the cooldown cache
    self.cooldownCache = {
        addonCooldowns = {},
        frames = {}
    }
    
    -- Cache media paths for performance
    self:CacheMedia()
    
    -- Register media paths with LibSharedMedia
    self:RegisterMediaPaths()
    
    -- Initialize class cooldowns data
    self:InitializeClassCooldowns()
    
    -- Initialize addon-specific cooldowns
    
    -- Check if database is available
    if not Phoenix_UI.db or not Phoenix_UI.db.profile or not Phoenix_UI.db.profile.cooldownTracker then
        return
    end
    
    -- Initialize submodules if module is enabled
    local db = Phoenix_UI.db.profile.cooldownTracker
    
    if db.enabled then
        -- Try to enable submodules based on settings
        self:EnableSubmodules()
    else
        -- Even if module is disabled, initialize config panel
        self:InitConfig()
        self:LogDebug("CooldownTracker module is disabled. Only configuration initialized.")
    end
    
    -- Register for standard WoW events
    self:RegisterEvent("PLAYER_TALENT_UPDATE", "UpdateTalentInfo")
    self:RegisterEvent("PLAYER_SPECIALIZATION_CHANGED", "UpdateSpecInfo")
    self:RegisterEvent("PLAYER_REGEN_DISABLED", "OnCombatStart")
    self:RegisterEvent("PLAYER_REGEN_ENABLED", "OnCombatEnd")
    
    -- Listen for Phoenix_UI settings changes through AceEvent
    if Phoenix_UI.RegisterMessage then
        Phoenix_UI:RegisterMessage("PHOENIX_UI_SETTINGS_CHANGED", function(_, module, settingsTable)
            if module == "cooldownTracker" and settingsTable then
                self:UpdateSettings()
            end
        end)
    end
    
    self:LogDebug("CooldownTracker initialized")
end

-- Cache frequently used media to improve performance
function Module:CacheMedia()
    -- Pre-fetch common fonts and textures
    fontPath = self:GetFontPath()
    barTexturePath = self:GetBarTexture(Phoenix_UI.db.profile.cooldownTracker.partyCD.barTexture)
    
    -- Cache sounds if defined
    local db = Phoenix_UI.db.profile.cooldownTracker
    if db.cooldownText.finishEffects.sound then
        customSounds.cooldownFinish = self:GetSoundByName(db.cooldownText.finishEffects.sound)
    end
    if db.partyCD.alertSound then
        customSounds.partyCDAlert = self:GetSoundByName(db.partyCD.alertSound)
    end
end

-- Ensure all defaults are present in database with improved handling
function Module:EnsureDBDefaults()
    -- Make sure database exists
    if not Phoenix_UI then
        print("Phoenix_UI not found, cannot initialize CooldownTracker module")
        return false
    end
    
    -- Ensure db structure exists
    Phoenix_UI.db = Phoenix_UI.db or {}
    Phoenix_UI.db.profile = Phoenix_UI.db.profile or {}
    
    -- Check if cooldownTracker profile section exists
    if not Phoenix_UI.db.profile.cooldownTracker then
        -- Create it from defaults
        Phoenix_UI.db.profile.cooldownTracker = self:CopyTable(defaults)
        return true
    end
    
    -- Get a local reference to avoid repeated table lookups
    local db = Phoenix_UI.db.profile.cooldownTracker
    if type(db) ~= "table" then
        -- Fix corrupted database entry
        Phoenix_UI.db.profile.cooldownTracker = self:CopyTable(defaults)
        return true
    end
    
    -- Check for general settings
    if not db.general then
        db.general = self:CopyTable(defaults.general)
    else
        self:EnsureDBDefaultsRecursive(db.general, defaults.general)
    end
    
    -- Check for cooldownText settings
    if not db.cooldownText then
        db.cooldownText = self:CopyTable(defaults.cooldownText)
    else
        self:EnsureDBDefaultsRecursive(db.cooldownText, defaults.cooldownText)
    end
    
    -- Check for spellTracker settings
    if not db.spellTracker then
        db.spellTracker = self:CopyTable(defaults.spellTracker)
    else
        self:EnsureDBDefaultsRecursive(db.spellTracker, defaults.spellTracker)
    end
    
    -- Check for partyCD settings
    if not db.partyCD then
        db.partyCD = self:CopyTable(defaults.partyCD)
    else
        self:EnsureDBDefaultsRecursive(db.partyCD, defaults.partyCD)
    end
    
    return true
end

-- Recursive function to ensure defaults for nested tables
function Module:EnsureDBDefaultsRecursive(db, defaults)
    if type(db) ~= "table" or type(defaults) ~= "table" then return end
    
    for k, v in pairs(defaults) do
        if db[k] == nil then
            db[k] = self:CopyTable(v)
        elseif type(v) == "table" then
            if type(db[k]) ~= "table" then
                db[k] = self:CopyTable(v)
            else
                self:EnsureDBDefaultsRecursive(db[k], v)
            end
        end
    end
end

-- Deep copy a table
function Module:CopyTable(source)
    if type(source) ~= "table" then return source end
    local copy = {}
    for k, v in pairs(source) do
        if type(v) == "table" then
            copy[k] = self:CopyTable(v)
        else
            copy[k] = v
        end
    end
    return copy
end

-- Register media paths with LibSharedMedia
function Module:RegisterMediaPaths()
    if not LSM then return end
    
    -- Check if LSM has the required methods
    if not LSM.IsRegistered or not LSM.Register then return end
    
    -- Safely register fonts
    local function SafeRegister(mediaType, name, path)
        if type(LSM.IsRegistered) == "function" and type(LSM.Register) == "function" then
            if not LSM:IsRegistered(mediaType, name) then
                LSM:Register(mediaType, name, path)
            end
        end
    end
    
    -- Register fonts
    SafeRegister("font", "Expressway", "Interface\\AddOns\\Phoenix_UI\\Media\\Fonts\\Expressway.ttf")
    
    -- Register status bar textures
    SafeRegister("statusbar", "Phoenix_UI Flat", "Interface\\AddOns\\Phoenix_UI\\Media\\Textures\\statusbar_flat.tga")
    
    -- Register sounds
    SafeRegister("sound", "Phoenix_UI Alert", "Interface\\AddOns\\Phoenix_UI\\Media\\Sounds\\alert.ogg")
end

-- Initialize class cooldowns
function Module:InitializeClassCooldowns()
    -- This will be populated from external file or inline data
    local db = Phoenix_UI.db.profile.cooldownTracker
    if not db.partyCD.classCooldowns or next(db.partyCD.classCooldowns) == nil then
        -- Load default class cooldown data from our module file
        db.partyCD.classCooldowns = self:GetDefaultClassCooldowns()
    end
end

-- Get default class cooldown data
function Module:GetDefaultClassCooldowns()
    -- We'll implement a comprehensive default set of cooldowns for all classes
    -- For now using a placeholder that will be expanded
    return {
        PALADIN = {
            -- Sample cooldowns
            interrupts = {96231}, -- Rebuke
            defensive = {642, 633, 1022, 1044}, -- Divine Shield, Lay on Hands, etc.
            offensive = {31884, 216331}, -- Avenging Wrath, Avenging Crusader
            raidCD = {31821, 6940}, -- Aura Mastery, Blessing of Sacrifice
            utility = {1044, 853}, -- Blessing of Freedom, Hammer of Justice
        },
        PRIEST = {
            interrupts = {15487}, -- Silence (Shadow)
            defensive = {47585, 33206, 47788}, -- Dispersion, Pain Suppression, Guardian Spirit
            offensive = {10060, 316262, 228260}, -- Power Infusion, Shadow Word: Death, Void Eruption
            raidCD = {64843, 62618, 265202}, -- Divine Hymn, Barrier, Holy Word: Salvation
            utility = {73325, 32375, 8122}, -- Leap of Faith, Mass Dispel, Psychic Scream
        },
        -- Other classes will be defined in full implementation
    }
end

function Module:EnableSubmodules()
    local db = Phoenix_UI.db.profile.cooldownTracker
    
    -- Reset submodule status
    for k in pairs(submoduleStatus) do
        submoduleStatus[k] = false
    end
    
    -- Define a helper function to enable a submodule
    local function enableSubmodule(name, settings)
        if not settings or not settings.enabled then return false end
        
        local success, err = pcall(function()
            local submodule = self:GetSubmodule(name)
            if submodule then
                submodule:SetEnabledState(true)
                submodule:Enable()
                return true
            end
            return false
        end)
        
        if not success then
            self:LogError("Failed to enable " .. name .. ": " .. tostring(err))
            return false
        end
        
        submoduleStatus[name:lower()] = true
        self:LogDebug(name .. " submodule enabled")
        return true
    end
    
    -- Enable appropriate submodules
    if db.cooldownText.enabled then
        enableSubmodule("CooldownText", db.cooldownText)
    end
    
    if db.spellTracker.enabled then
        enableSubmodule("SpellTracker", db.spellTracker)
    end
    
    if db.partyCD.enabled then
        enableSubmodule("PartyCD", db.partyCD)
    end
    
    -- Initialize config after enabling submodules
    self:InitConfig()
    
    -- Update all submodules with current settings
    self:UpdateSubmodules()
end

function Module:OnEnable()
    -- Make sure we have a database reference with improved handling
    if not Phoenix_UI.db or not Phoenix_UI.db.profile then
        C_Timer.After(2, function() 
            if self.IsEnabled and self:IsEnabled() then
                self:OnEnable() 
            end
        end)
        return
    end
    
    -- Initialize default settings if needed
    local success = self:EnsureDBDefaults()
    if not success then
        return
    end
    
    -- Cache media
    self:CacheMedia()
    
    -- Register events
    self:RegisterEvent("PLAYER_ENTERING_WORLD", "OnEvent")
    self:RegisterEvent("ADDON_LOADED", "ADDON_LOADED")
    
    -- Initialize class cooldowns if not already done
    self:InitializeClassCooldowns()
    
    -- Setup performance tracking
    self:SetupPerformanceMonitor()
    
    -- Get database reference with validation
    local db = Phoenix_UI.db.profile.cooldownTracker
    if not db then
        Phoenix_UI.db.profile.cooldownTracker = self:CopyTable(defaults)
        db = Phoenix_UI.db.profile.cooldownTracker
    end
    
    -- Enable submodules based on settings
    if db.cooldownText and db.cooldownText.enabled then
        self:ToggleModule("cooldownText", true)
    end
    
    if db.spellTracker and db.spellTracker.enabled then
        self:ToggleModule("spellTracker", true)
    end
    
    if db.partyCD and db.partyCD.enabled then
        self:ToggleModule("partyCD", true)
    end
    
    -- Register with Phoenix_UI config system safely
    if Phoenix_UI then
        local success, err
        
        -- Try to use the CallModuleMethod function with better error handling
        if type(Phoenix_UI.CallModuleMethod) == "function" then
            success = Phoenix_UI:CallModuleMethod("CooldownTracker.Config", "SetupConfig")
            if not success then
                -- Try direct module access as a fallback
                local configModule = Phoenix_UI:GetModule("CooldownTracker.Config", true)
                if configModule and type(configModule.SetupConfig) == "function" then
                    pcall(function() configModule:SetupConfig() end)
                end
            end
        else
            -- Fallback method - try direct access if CallModuleMethod doesn't exist
            local configModule = Phoenix_UI:GetModule("CooldownTracker.Config", true)
            if configModule and type(configModule.SetupConfig) == "function" then
                pcall(function() configModule:SetupConfig() end)
            end
        end
    end
    
    -- Record status for diagnostics
    self:LogModuleStatus()
end

-- Helper function to get the module's database
function Module:GetDB()
    -- Ensure database exists
    if not Phoenix_UI or not Phoenix_UI.db or not Phoenix_UI.db.profile then
        return nil
    end
    
    -- Initialize if necessary
    if not Phoenix_UI.db.profile.cooldownTracker then
        Phoenix_UI.db.profile.cooldownTracker = self:CopyTable(defaults)
    end
    
    return Phoenix_UI.db.profile.cooldownTracker
end

-- Always set up the config regardless of module state
function Module:InitModule()
    -- Make sure database exists and has default values
    self:EnsureDBDefaults()
    
    -- Register config even if module is not enabled
    -- This ensures config options are always visible
    if Phoenix_UI then
        -- Set up configuration
        local configModule = Phoenix_UI:GetModule("CooldownTracker.Config", true)
        if configModule and type(configModule.SetupConfig) == "function" then
            pcall(function() configModule:SetupConfig() end)
        end
    end
end

-- Register with InitModule so configuration is set up even if module is disabled
C_Timer.After(1, function()
    -- This ensures the config is always set up, even if the module is disabled
    if Module.InitModule then
        Module:InitModule()
    end
end)

-- Configuration panel access
function Module:OpenConfigPanel()
    if not Phoenix_UI or not Phoenix_UI.Config then
        return
    end
    
    -- Force the module config to appear even if module is disabled
    local configModule = Phoenix_UI:GetModule("CooldownTracker.Config", true)
    if configModule and type(configModule.SetupConfig) == "function" then
        pcall(function() configModule:SetupConfig() end)
    end
    
    -- Open Phoenix UI config
    Phoenix_UI:Config(true)
end

-- Detailed logging of module status for diagnostics
function Module:LogModuleStatus()
    if not self.loggedStatus then
        self.loggedStatus = true
        
        local status = {}
        
        -- Check core module
        table.insert(status, "Core: " .. (self:IsEnabled() and "Enabled" or "Disabled"))
        
        -- Check submodules
        for _, submoduleName in ipairs({"CooldownText", "SpellTracker", "PartyCD"}) do
            local fullName = "CooldownTracker." .. submoduleName
            local submodule = Phoenix_UI:GetModule(fullName, true)
            local submoduleState = "Unknown"
            
            if submodule then
                if type(submodule.IsEnabled) == "function" then
                    submoduleState = submodule:IsEnabled() and "Enabled" or "Disabled"
                else
                    submoduleState = "No IsEnabled method"
                end
            else
                submoduleState = "Not found"
            end
            
            table.insert(status, submoduleName .. ": " .. submoduleState)
        end
        
        -- Log diagnostics info without printing
        self:LogDebug("Module Status: " .. table.concat(status, ", "))
    end
end

function Module:OnCombatStart()
    inCombat = true
    local db = Phoenix_UI.db.profile.cooldownTracker
    if db and db.usePerformanceMode then
        self:UpdatePerformanceState(true)
    end
end

function Module:OnCombatEnd()
    inCombat = false
    local db = Phoenix_UI.db.profile.cooldownTracker
    if db and db.usePerformanceMode then
        self:UpdatePerformanceState(false)
    end
end

-- Set up performance monitor
function Module:SetupPerformanceMonitor()
    if not self.performanceFrame then
        self.performanceFrame = CreateFrame("Frame")
        
        local updateCounter = 0
        local lastUpdate = GetTime()
        
        self.performanceFrame:SetScript("OnUpdate", function(self, elapsed)
            updateCounter = updateCounter + elapsed
            
            -- Check if we need to throttle updates
            if updateCounter < updateThrottle then return end
            updateCounter = 0
            
            -- Check current FPS
            local currentTime = GetTime()
            local timeDiff = currentTime - lastUpdate
            lastUpdate = currentTime
            
            if timeDiff > 0 then
                local currentFPS = 1 / timeDiff
                
                -- Adjust throttling based on FPS
                if currentFPS < 20 and not heavyLoad then
                    -- FPS is low, increase throttling
                    updateThrottle = HEAVY_THROTTLE
                    heavyLoad = true
                elseif currentFPS > 30 and heavyLoad and not inCombat then
                    -- FPS is good again and not in combat, reset throttling
                    updateThrottle = NORMAL_THROTTLE
                    heavyLoad = false
                end
            end
        end)
    end
end

-- Set up keybindings
function Module:SetupKeybindings()
    -- Set up keybinding header
    _G["BINDING_HEADER_PHOENIX_UI_COOLDOWNTRACKER"] = "Phoenix UI Cooldown Tracker"
    
    -- Set up individual bindings
    _G["BINDING_NAME_PHOENIX_UI_TOGGLE_COOLDOWNTEXT"] = "Toggle Cooldown Text"
    _G["BINDING_NAME_PHOENIX_UI_TOGGLE_SPELLTRACKER"] = "Toggle Spell Tracker"
    _G["BINDING_NAME_PHOENIX_UI_TOGGLE_PARTYCD"] = "Toggle Party Cooldowns"
    
    -- Define the actual binding functions
    _G["PHOENIX_UI_TOGGLE_COOLDOWNTEXT"] = function()
        Module:ToggleModule("cooldownText")
    end
    
    _G["PHOENIX_UI_TOGGLE_SPELLTRACKER"] = function()
        Module:ToggleModule("spellTracker")
    end
    
    _G["PHOENIX_UI_TOGGLE_PARTYCD"] = function()
        Module:ToggleModule("partyCD")
    end
end

-- Create minimap button
function Module:CreateMinimapButton()
    if not LibStub or not LibStub("LibDataBroker-1.1", true) then
        return
    end
    
    local LDB = LibStub("LibDataBroker-1.1")
    local icon = "Interface\\Icons\\Spell_Nature_TimeStop"
    
    -- Create data broker object
    local CooldownTrackerLDB = LDB:NewDataObject("Phoenix_UI_CooldownTracker", {
        type = "launcher",
        icon = icon,
        OnClick = function(self, button)
            if button == "LeftButton" then
                Module:ToggleConfig()
            elseif button == "RightButton" then
                Module:ShowModuleMenu()
            end
        end,
        OnTooltipShow = function(tooltip)
            tooltip:AddLine("Phoenix UI Cooldown Tracker")
            tooltip:AddLine(" ")
            tooltip:AddLine("Left-click: Open configuration panel")
            tooltip:AddLine("Right-click: Toggle modules")
            
            tooltip:AddLine(" ")
            tooltip:AddLine("Status:")
            tooltip:AddLine("Cooldown Text: " .. (submoduleStatus.cooldownText and "|cFF00FF00Enabled|r" or "|cFFFF0000Disabled|r"))
            tooltip:AddLine("Spell Tracker: " .. (submoduleStatus.spellTracker and "|cFF00FF00Enabled|r" or "|cFFFF0000Disabled|r"))
            tooltip:AddLine("Party Cooldowns: " .. (submoduleStatus.partyCD and "|cFF00FF00Enabled|r" or "|cFFFF0000Disabled|r"))
        end,
    })
    
    -- Register with LibDBIcon if available
    local LibDBIcon = LibStub("LibDBIcon-1.0", true)
    if LibDBIcon then
        LibDBIcon:Register("Phoenix_UI_CooldownTracker", CooldownTrackerLDB, Phoenix_UI.db.profile.cooldownTracker.minimapButton)
    end
end

-- Show module menu
function Module:ShowModuleMenu()
    -- Create dropdown menu to toggle modules
    local menu = {
        { text = "Phoenix UI Cooldown Tracker", isTitle = true },
        { text = "Cooldown Text", checked = submoduleStatus.cooldownText, func = function() Module:ToggleModule("cooldownText") end },
        { text = "Spell Tracker", checked = submoduleStatus.spellTracker, func = function() Module:ToggleModule("spellTracker") end },
        { text = "Party Cooldowns", checked = submoduleStatus.partyCD, func = function() Module:ToggleModule("partyCD") end },
        { text = " ", isTitle = true },
        { text = "Open Configuration", func = function() Module:ToggleConfig() end },
    }
    
    local dropDown = CreateFrame("Frame", "Phoenix_UI_CooldownTracker_DropDown", UIParent, "UIDropDownMenuTemplate")
    EasyMenu(menu, dropDown, "cursor", 0, 0, "MENU")
end

function Module:ToggleConfig()
    -- Open Phoenix_UI configuration to cooldown tracker section
    if Phoenix_UI.OpenConfig then
        Phoenix_UI:OpenConfig("cooldownTracker")
    end
end

function Module:UpdateSubmodules()
    local db = Phoenix_UI.db.profile.cooldownTracker
    if not db then
        self:LogError("Cannot update submodules - settings not found")
        return
    end
    
    -- Define a helper function for safe updates
    local function safeUpdateModule(name, settings)
        if not settings then
            self:LogDebug(name .. " settings not found, skipping update")
            return false
        end
        
        local success, err = pcall(function()
            local submodule = self:GetSubmodule(name)
            if submodule and submodule.UpdateSettings then
                submodule:UpdateSettings(settings)
                return true
            end
            return false
        end)
        
        if not success then
            self:LogError("Failed to update " .. name .. ": " .. tostring(err))
            return false
        end
        
        return true
    end
    
    -- Update CooldownText submodule
    if db.cooldownText.enabled and submoduleStatus.cooldowntext then
        safeUpdateModule("CooldownText", db.cooldownText)
    elseif db.cooldownText.enabled and not submoduleStatus.cooldowntext then
        -- Try to enable if setting is enabled but module is not
        local submodule = self:GetSubmodule("CooldownText")
        if submodule then
            submodule:SetEnabledState(true)
            submodule:Enable()
            safeUpdateModule("CooldownText", db.cooldownText)
            submoduleStatus.cooldowntext = true
        end
    elseif not db.cooldownText.enabled and submoduleStatus.cooldowntext then
        -- Disable if setting is disabled but module is enabled
        local submodule = self:GetSubmodule("CooldownText")
        if submodule then
            submodule:Disable()
            submoduleStatus.cooldowntext = false
        end
    end
    
    -- Update SpellTracker submodule
    if db.spellTracker.enabled and submoduleStatus.spelltracker then
        safeUpdateModule("SpellTracker", db.spellTracker)
    elseif db.spellTracker.enabled and not submoduleStatus.spelltracker then
        -- Try to enable if setting is enabled but module is not
        local submodule = self:GetSubmodule("SpellTracker")
        if submodule then
            submodule:SetEnabledState(true)
            submodule:Enable()
            safeUpdateModule("SpellTracker", db.spellTracker)
            submoduleStatus.spelltracker = true
        end
    elseif not db.spellTracker.enabled and submoduleStatus.spelltracker then
        -- Disable if setting is disabled but module is enabled
        local submodule = self:GetSubmodule("SpellTracker")
        if submodule then
            submodule:Disable()
            submoduleStatus.spelltracker = false
        end
    end
    
    -- Update PartyCD submodule
    if db.partyCD.enabled and submoduleStatus.partycd then
        safeUpdateModule("PartyCD", db.partyCD)
    elseif db.partyCD.enabled and not submoduleStatus.partycd then
        -- Try to enable if setting is enabled but module is not
        local submodule = self:GetSubmodule("PartyCD")
        if submodule then
            submodule:SetEnabledState(true)
            submodule:Enable()
            safeUpdateModule("PartyCD", db.partyCD)
            submoduleStatus.partycd = true
        end
    elseif not db.partyCD.enabled and submoduleStatus.partycd then
        -- Disable if setting is disabled but module is enabled
        local submodule = self:GetSubmodule("PartyCD")
        if submodule then
            submodule:Disable()
            submoduleStatus.partycd = false
        end
    end
    
    -- Update Styling submodule (always update as it's required for proper appearance)
    local stylingModule = self:GetSubmodule("Styling")
    if stylingModule then
        if type(stylingModule.UpdateAllStyles) == "function" then
            local success, err = pcall(function() 
                stylingModule:UpdateAllStyles() 
            end)
            if not success then
                self:LogError("Failed to update Styling: " .. tostring(err))
            end
        end
    end
    
    self:LogDebug("All submodules updated with current settings")
end

-- Handle the ADDON_LOADED event (required for AceEvent-3.0)
function Module:ADDON_LOADED(addon)
    if addon == "Phoenix_UI" then
        -- Setup configuration options
        self:SetupConfig()
    end
end

function Module:OnEvent(event, ...)
    if event == "PLAYER_ENTERING_WORLD" then
        -- Re-initialize everything on login/reload
        local db = Phoenix_UI.db.profile.cooldownTracker
        self:InitializeSubmodules(db)
    elseif event == "ADDON_LOADED" then
        local addon = ...
        if addon == "Phoenix_UI" then
            -- Setup configuration options
            self:SetupConfig()
        end
    end
end

function Module:RegisterWithPhoenixUI()
    -- Register this module with the main Phoenix_UI frame for tracking
    if Phoenix_UI and Phoenix_UI.RegisterModule then
        Phoenix_UI:RegisterModule("CooldownTracker", self)
    end
end

-- Function to allow other modules to toggle cooldown modules
function Module:ToggleModule(moduleName, state)
    if not moduleName then 
        return false 
    end
    
    -- Ensure database exists
    if not Phoenix_UI.db or not Phoenix_UI.db.profile or not Phoenix_UI.db.profile.cooldownTracker then
        return false
    end
    
    local db = Phoenix_UI.db.profile.cooldownTracker
    
    -- Initialize submodule status if it doesn't exist
    if not submoduleStatus then
        submoduleStatus = {
            cooldownText = false,
            spellTracker = false,
            partyCD = false
        }
    end
    
    -- Safely call module methods with improved error handling
    local function safeCallModuleMethod(module, method, arg1)
        -- First check if module exists
        local moduleObj
        local moduleExists = false
        
        if Phoenix_UI and type(Phoenix_UI.GetModule) == "function" then
            moduleObj = Phoenix_UI:GetModule(module, true)
            moduleExists = (moduleObj ~= nil)
        end
        
        if not moduleExists then
            return false, "Module not found: " .. module
        end
        
        -- Try to use Phoenix_UI.CallModuleMethod if available for better error reporting
        if Phoenix_UI and type(Phoenix_UI.CallModuleMethod) == "function" then
            return Phoenix_UI:CallModuleMethod(module, method, arg1)
        elseif moduleObj and type(moduleObj[method]) == "function" then
            -- Fallback to direct access with error handling
            return pcall(function() return moduleObj[method](moduleObj, arg1) end)
        else
            return false, "Method not found: " .. module .. "." .. method
        end
    end
    
    -- Helper to get default settings for a module when needed
    local function getDefaultModuleSettings(moduleType)
        if defaults and defaults[moduleType] then
            return self:CopyTable(defaults[moduleType])
        else
            -- Create minimal working defaults if module settings are missing
            if moduleType == "cooldownText" then
                return {
                    enabled = true,
                    minDuration = 2.5,
                    textSize = 15,
                    expiringDuration = 3,
                    textColor = {1, 1, 1},
                    expiringColor = {1, 0.3, 0.3}
                }
            elseif moduleType == "spellTracker" then
                return {
                    enabled = true,
                    size = 30,
                    maxIcons = 5,
                    direction = "LEFT",
                    fadeTime = 3
                }
            elseif moduleType == "partyCD" then
                return {
                    enabled = true,
                    size = 24,
                    direction = "DOWN",
                    spacing = 2
                }
            else
                return { enabled = true }
            end
        end
    end
    
    -- Common function for handling module state changes
    local function handleModuleToggle(moduleType, fullModuleName)
        -- If state not specified, toggle
        if state == nil then
            state = not (db[moduleType] and db[moduleType].enabled)
        end
        
        -- Update database setting
        if not db[moduleType] then
            db[moduleType] = getDefaultModuleSettings(moduleType)
        end
        
        db[moduleType].enabled = state
        
        -- Enable or disable the module
        if state then
            -- Ensure settings exist
            if type(db[moduleType]) ~= "table" or next(db[moduleType]) == nil then
                db[moduleType] = getDefaultModuleSettings(moduleType)
            end
            
            -- Try to initialize the module
            local success, err = safeCallModuleMethod(fullModuleName, "Initialize", db[moduleType])
            
            -- If initialization fails with current settings, try with defaults
            if not success then
                local defaultSettings = getDefaultModuleSettings(moduleType)
                success = safeCallModuleMethod(fullModuleName, "Initialize", defaultSettings)
                
                -- If successful with defaults, update db
                if success then
                    db[moduleType] = defaultSettings
                end
            end
            
            -- Update status
            submoduleStatus[moduleType] = success
        else
            -- Disable the module
            safeCallModuleMethod(fullModuleName, "Disable")
            submoduleStatus[moduleType] = false
        end
        
        return state
    end
    
    -- Process based on module name
    if moduleName == "cooldownText" then
        return handleModuleToggle("cooldownText", "CooldownTracker.CooldownText")
    elseif moduleName == "spellTracker" then
        return handleModuleToggle("spellTracker", "CooldownTracker.SpellTracker")
    elseif moduleName == "partyCD" then
        return handleModuleToggle("partyCD", "CooldownTracker.PartyCD")
    else
        return false
    end
    
    -- Update database
    Phoenix_UI.db.profile.cooldownTracker = db
    
    -- Force save to preserve changes
    if Phoenix_UI.SaveDB then
        Phoenix_UI:SaveDB()
    end
    
    return state
end

function Module:UpdateSettings()
    local db = Phoenix_UI.db.profile.cooldownTracker
    
    -- Handle module enable/disable state change
    if self.isEnabled ~= db.enabled then
        if db.enabled then
            self:Enable()
        else
            self:Disable()
        end
        self.isEnabled = db.enabled
        return
    end
    
    -- Only update if module is enabled
    if not db.enabled then return end
    
    -- Cache media if needed
    self:CacheMedia()
    
    -- Update all cooldowns with forced style update
    self:UpdateAllCooldowns(true)
    
    -- Fire callback for settings changed
    self:FireCallback("SettingsChanged", db)
    
    -- Update submodules with current settings
    self:UpdateSubmodules()
    
    -- Update config UI if it exists
    if self.configFrame and self.configFrame.UpdateDisplay then
        self.configFrame:UpdateDisplay()
    end
    
    self:LogDebug("Settings updated successfully")
end

function Module:OnDisable()
    -- Safely disable all submodules
    local function safeDisableModule(name)
        local success, err = pcall(function()
            local submodule = self:GetSubmodule(name)
            if submodule then
                submodule:Disable()
                return true
            end
            return false
        end)
        
        if not success then
            self:LogError("Failed to disable " .. name .. ": " .. tostring(err))
            return false
        end
        
        submoduleStatus[name:lower()] = false
        return true
    end
    
    -- Disable all submodules
    safeDisableModule("CooldownText")
    safeDisableModule("SpellTracker")
    safeDisableModule("PartyCD")
    
    -- Update config UI
    if self.configFrame and self.configFrame.UpdateDisplay then
        self.configFrame:UpdateDisplay()
    end
    
    self:LogDebug("CooldownTracker module disabled")
end

-- Setup configuration menu
function Module:SetupConfig()
    -- Configuration setup will be in _Config.lua
    -- This is just a placeholder
    if Phoenix_UI and type(Phoenix_UI.CallModuleMethod) == "function" then
        Phoenix_UI:CallModuleMethod("CooldownTracker.Config", "SetupOptions")
    else
        -- Fallback if CallModuleMethod doesn't exist
        if Phoenix_UI and Phoenix_UI.modules and Phoenix_UI.modules["CooldownTracker.Config"] then
            local configModule = Phoenix_UI.modules["CooldownTracker.Config"]
            if configModule and type(configModule.SetupOptions) == "function" then
                configModule:SetupOptions()
            end
        end
    end
end

function Module:UpdateConfig()
    -- Update configuration menu if it exists
    if Phoenix_UI and type(Phoenix_UI.CallModuleMethod) == "function" then
        Phoenix_UI:CallModuleMethod("CooldownTracker.Config", "UpdateOptions")
    else
        -- Fallback if CallModuleMethod doesn't exist
        -- Try to access the module directly as a fallback
        if Phoenix_UI and Phoenix_UI.modules and Phoenix_UI.modules["CooldownTracker.Config"] then
            local configModule = Phoenix_UI.modules["CooldownTracker.Config"]
            if configModule and type(configModule.UpdateOptions) == "function" then
                configModule:UpdateOptions()
            end
        end
    end
end

-- API for other modules to access cooldown data
function Module:GetCooldownInfo(spellID)
    if not spellID then return nil end
    
    local db = Phoenix_UI.db.profile.cooldownTracker
    
    -- Search through class cooldowns to find this spell
    for className, classData in pairs(db.partyCD.classCooldowns) do
        for category, spells in pairs(classData) do
            for _, id in ipairs(spells) do
                if id == spellID then
                    local name, _, icon = SafeGetSpellInfo(spellID)
                    return {
                        name = name,
                        icon = icon,
                        class = className,
                        category = category
                    }
                end
            end
        end
    end
    
    -- Fallback to just spell info if not found
    local name, _, icon = SafeGetSpellInfo(spellID)
    if name then
        return {
            name = name,
            icon = icon
        }
    end
    
    return nil
end

-- Get cooldown duration including talents/effects
function Module:GetAdjustedCooldown(spellID, unitID)
    if not spellID or not unitID then return nil end
    
    -- Use spell cooldown API to get actual cooldown
    local start, duration, enabled = GetSpellCooldown(spellID, unitID)
    if start and duration then
        return start, duration, enabled
    end
    
    return nil
end

-- Open configuration panel for CooldownTracker
function Module:OpenConfigPanel()
    if not Phoenix_UI or not Phoenix_UI.Config then
        print("|cffFF7D0APhoenix|r|cffFF0000_|r|cffFFD100UI|r: Config system not loaded")
        return
    end
    
    Phoenix_UI:Config(true)
    -- The tab selection will be handled by the hook in Gui:IntegrateModules
end

-- Added for compatibility with other modules
function Module:RegisterWithPhoenixUI()
    -- This is handled through the Config/_Gui.lua integration now
end

-- Make the module available globally for access
Phoenix_UI.CooldownTracker = Module 

function Module:InitializeSubmodules(db)
    -- Initialize and enable each submodule with its configuration
    -- With enhanced error handling and fallback mechanisms
    
    -- Helper function to safely call module methods with robust error handling
    local function safeInitializeModule(moduleName, methodName, options, fallbackOptions)
        -- Try to use Phoenix_UI.CallModuleMethod if available
        if Phoenix_UI and type(Phoenix_UI.CallModuleMethod) == "function" then
            local success, err = Phoenix_UI:CallModuleMethod(moduleName, methodName, options)
            if success then
                return true
            elseif fallbackOptions then
                -- Try with fallback options
                local fallbackSuccess = Phoenix_UI:CallModuleMethod(moduleName, methodName, fallbackOptions)
                return fallbackSuccess
            else
                self:LogError(moduleName .. " initialization failed: " .. tostring(err))
                return false
            end
        elseif Phoenix_UI and type(Phoenix_UI.GetModule) == "function" then
            -- Fallback to direct module access
            local moduleObj = Phoenix_UI:GetModule(moduleName, true)
            if moduleObj and type(moduleObj[methodName]) == "function" then
                local success, err = pcall(function() moduleObj[methodName](moduleObj, options) end)
                if success then
                    return true
                elseif fallbackOptions then
                    -- Try with fallback options
                    local fallbackSuccess = pcall(function() moduleObj[methodName](moduleObj, fallbackOptions) end)
                    return fallbackSuccess
                else
                    self:LogError(moduleName .. " initialization failed: " .. tostring(err))
                    return false
                end
            else
                self:LogError(moduleName .. " not found or method missing")
                return false
            end
        else
            self:LogError("Phoenix_UI module system not available")
            return false
        end
    end
    
    -- CooldownText module
    if db.cooldownText.enabled then
        submoduleStatus.cooldownText = safeInitializeModule(
            "CooldownTracker.CooldownText", 
            "Initialize", 
            db.cooldownText, 
            self:GetDefaultSettings("cooldownText")
        )
    end
    
    -- SpellTracker module
    if db.spellTracker.enabled then
        submoduleStatus.spellTracker = safeInitializeModule(
            "CooldownTracker.SpellTracker", 
            "Initialize", 
            db.spellTracker, 
            self:GetDefaultSettings("spellTracker")
        )
    end
    
    -- PartyCD module
    if db.partyCD.enabled then
        submoduleStatus.partyCD = safeInitializeModule(
            "CooldownTracker.PartyCD", 
            "Initialize", 
            db.partyCD, 
            self:GetDefaultSettings("partyCD")
        )
    end
    
    -- Log initialization status
    self:LogDebug("CooldownTracker submodule status - CooldownText: " .. 
                 (submoduleStatus.cooldownText and "Active" or "Inactive") .. 
                 ", SpellTracker: " .. (submoduleStatus.spellTracker and "Active" or "Inactive") .. 
                 ", PartyCD: " .. (submoduleStatus.partyCD and "Active" or "Inactive"))
end

-- Get default settings for configuration
function Module:GetDefaultSettings(moduleName)
    if moduleName and moduleName ~= "" then
        -- Return specific module defaults if requested
        if defaults[moduleName] then
            return defaults[moduleName]
        end
        return {}
    end
    
    -- Return entire defaults table
    return defaults
end

-- Logging functions
function Module:LogDebug(message)
    -- Simply record to debug log without printing
    if Phoenix_UI.Debug then
        Phoenix_UI:Debug("CooldownTracker", message)
    end
end

function Module:LogError(message)
    -- Just record error but don't print
    -- Let the error be caught by BugSack/BugGrabber
end

-- Function to initialize the configuration
function Module:InitConfig()
    -- Initialize the configuration system
    if Phoenix_UI and Phoenix_UI.modules and Phoenix_UI.modules["CooldownTracker.Config"] then
        local configModule = Phoenix_UI.modules["CooldownTracker.Config"]
        if configModule and type(configModule.SetupConfig) == "function" then
            pcall(function() configModule:SetupConfig() end)
        end
    else
        -- Fallback to direct initialization
        if Phoenix_UI and Phoenix_UI.CooldownTracker and Phoenix_UI.CooldownTracker.Config then
            local configModule = Phoenix_UI.CooldownTracker.Config
            if configModule and type(configModule.SetupConfig) == "function" then
                pcall(function() configModule:SetupConfig() end)
            end
        end
    end
    
    self:LogDebug("Configuration initialized")
end

-- Update talent information
function Module:UpdateTalentInfo()
    -- This function updates the module when player talents change
    -- Currently just a placeholder that updates submodules
    self:UpdateSubmodules()
    self:LogDebug("Talent information updated")
end

-- Update specialization information
function Module:UpdateSpecInfo()
    -- This function updates the module when player specialization changes
    -- Currently just a placeholder that updates submodules
    self:UpdateSubmodules()
    self:LogDebug("Specialization information updated")
end

-- Update performance state based on combat and system performance
function Module:UpdatePerformanceState(inCombat)
    -- Adjust update throttling based on combat state
    if inCombat then
        updateThrottle = HEAVY_THROTTLE
        heavyLoad = true
        self:LogDebug("Performance mode: Combat - Heavy throttling enabled")
    else
        updateThrottle = NORMAL_THROTTLE
        heavyLoad = false
        self:LogDebug("Performance mode: Normal - Standard throttling")
    end
end

-- Function to get a submodule reference
function Module:GetSubmodule(name)
    -- Safety check
    if not name then return nil end
    
    -- Try different ways to access the submodule
    
    -- First try through Phoenix_UI modules system using full name
    local fullName = "CooldownTracker." .. name
    if Phoenix_UI and Phoenix_UI.GetModule then
        local submodule = Phoenix_UI:GetModule(fullName, true)
        if submodule then return submodule end
    end
    
    -- Try through AceAddon direct module lookup
    if self.modules and self.modules[name] then
        return self.modules[name]
    end
    
    -- Try through Phoenix_UI's CooldownTracker global reference
    if Phoenix_UI and Phoenix_UI.CooldownTracker then
        if Phoenix_UI.CooldownTracker[name] then
            return Phoenix_UI.CooldownTracker[name]
        end
    end
    
    -- Not found
    return nil
end

-- Function to create or get a cooldown frame
function Module:GetCooldownFrame(parent, size, specID)
    if not parent then return nil end
    
    -- Create a new frame if one doesn't exist for this parent
    local frame = parent.cooldownFrame
    local isNew = false
    
    if not frame then
        isNew = true
        frame = CreateFrame("Frame", nil, parent)
        frame:SetSize(size or parent:GetWidth() or 36, size or parent:GetHeight() or 36)
        frame:SetPoint("CENTER", parent, "CENTER", 0, 0)
        
        -- Set up the frame with necessary elements
        self:SetupCooldownFrame(frame, specID)
        
        -- Store reference in parent
        parent.cooldownFrame = frame
        
        -- Store in cooldown cache
        if not self.cooldownCache then
            self.cooldownCache = {
                addonCooldowns = {},
                frames = {}
            }
        end
        self.cooldownCache.frames[frame] = true
        
        -- Fire callback for new cooldown frame
        self:FireCallback("CooldownCreated", frame)
    end
    
    return frame, isNew
end

-- Set up a cooldown frame with all necessary elements
function Module:SetupCooldownFrame(frame, specID)
    if not frame then return nil end
    
    -- Create text element if it doesn't exist
    if not frame.text then
        frame.text = frame:CreateFontString(nil, "OVERLAY")
        frame.text:SetPoint("CENTER", frame, "CENTER", 0, 0)
        
        -- Set font from settings
        local db = self:GetDB()
        if db and db.cooldownText then
            frame.text:SetFont(
                db.cooldownText.textFont or "Friz Quadrata TT",
                db.cooldownText.textSize or 14,
                db.cooldownText.textFlags or "OUTLINE"
            )
        else
            frame.text:SetFont("Friz Quadrata TT", 14, "OUTLINE")
        end
        
        -- Set initial text color
        frame.text:SetTextColor(1, 1, 1, 1)
    end
    
    -- Set up any spec-specific customizations
    if specID then
        -- Apply any spec-specific settings
    end
    
    return frame
end

-- Update all registered cooldown frames
function Module:UpdateAllCooldowns(forceStyleUpdate)
    -- Get all registered frames
    local frames = self:GetAllCooldownFrames()
    if not frames then return end
    
    -- Update each frame
    for frame in pairs(frames) do
        if frame and frame:IsShown() then
            -- Update the frame's appearance and text
            -- This would typically be handled by your cooldown update code
            
            -- For this stub, we're just ensuring the text element exists
            if not frame.text then
                self:SetupCooldownFrame(frame)
            end
        end
    end
    
    -- Fire callback to update styles if requested
    if forceStyleUpdate then
        self:FireCallback("StylesUpdated")
    end
    
    self:LogDebug("Updated all cooldown frames, style update: " .. (forceStyleUpdate and "Yes" or "No"))
end

-- Get all registered cooldown frames
function Module:GetAllCooldownFrames()
    -- Create the cooldown cache if it doesn't exist yet
    if not self.cooldownCache then
        self.cooldownCache = {
            addonCooldowns = {},
            frames = {}
        }
    end
    
    return self.cooldownCache.frames or {}
end

-- Safe wrapper for GetSpellInfo to handle errors
local function SafeGetSpellInfo(spellID)
    if not spellID then return nil end
    
    -- Use pcall to catch any errors
    local success, result = pcall(GetSpellInfo, spellID)
    if success and result then
        return result, select(2, GetSpellInfo(spellID)), select(3, GetSpellInfo(spellID))
    else
        -- Return nil values if GetSpellInfo fails
        return nil, nil, nil
    end
end

-- Submodule initialization status
submoduleStatus = {
    cooldownText = false,
    spellTracker = false,
    partyCD = false
} 
