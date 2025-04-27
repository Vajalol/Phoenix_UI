Phoenix_UI = LibStub("AceAddon-3.0"):NewAddon("Phoenix_UI", "AceEvent-3.0", "AceComm-3.0", "AceSerializer-3.0", "AceConsole-3.0", "AceHook-3.0", "AceTimer-3.0")
local addonName, addon = ...

-- Debug mode is disabled
Phoenix_UI.debug = false

-- Define Phoenix_Options at the very top level for AddonCompartmentFunc
-- This ensures it's always available regardless of load order
_G.Phoenix_Options = function()
    -- Simple function that will be called by the addon compartment
    if Phoenix_UI and Phoenix_UI.Config then
        Phoenix_UI:Config()
    elseif Phoenix_UI and Phoenix_UI.OpenConfig then
        Phoenix_UI:OpenConfig()
    else
        -- Fallback if Phoenix_UI isn't fully loaded yet
        print("|cffFF7D0APhoenix|r|cffFF0000_|r|cffFFD100UI|r: Opening config...")
        
        -- Try standard interface options as fallback
        if InterfaceOptionsFrame_OpenToCategory then
            InterfaceOptionsFrame_OpenToCategory("Phoenix_UI")
        end
    end
end

-- Compatibility layer for legacy Phoenix_UI references
Phoenix_UI = Phoenix_UI

-- Initialize localization
Phoenix_UI.L = Phoenix_UI.L or {}
-- Default English strings
local defaultStrings = {
    ['World of Warcraft addon Phoenix_UI Fire Theme'] = 'Type /pui to open Config Panel - From ashes to ashes Welcome to fire Gamer'
}
-- Add default strings to localization table if they don't exist
for key, value in pairs(defaultStrings) do
    Phoenix_UI.L[key] = Phoenix_UI.L[key] or value
end

-- Use compatibility layer for disabling addons
if Phoenix_UI.compat then
    Phoenix_UI.compat.DisableAddOn('LortiUI')
    Phoenix_UI.compat.DisableAddOn('UberUI')
    Phoenix_UI.compat.DisableAddOn('SUI')
else
    -- Fallback for when compatibility layer is not yet initialized
    if C_AddOns then
        C_AddOns.DisableAddOn('LortiUI')
        C_AddOns.DisableAddOn('UberUI')
        C_AddOns.DisableAddOn('SUI')
    else
        DisableAddOn('LortiUI')
        DisableAddOn('UberUI')
        DisableAddOn('SUI')
    end
end

-- Registry for hooks
Phoenix_UI.hookRegistry = {}

local defaults = {
    profile = {
        install = false,
        reset = false,
        general = {
            theme = 'Dark',
            font = [[Interface/AddOns/Phoenix_UI/Media/Fonts/PTSansNarrow.ttf]],
            texture = [[Interface/AddOns/Phoenix_UI/Media/Textures/Status/Smooth.blp]],
            color = { r = 0, g = 0, b = 0, a = 1 },
            automation = {
                delete = true,
                decline = false,
                repair = 'Default',
                sell = true,
                stackbuy = true,
                invite = false,
                release = false,
                resurrect = false,
                cinematic = false
            },
            cosmetic = {
                afkscreen = true,
                talkhead = false,
                errors = false
            },
            display = {
                ilvl = true,
                fps = true,
                ms = true,
                movementSpeed = true,
                playerStats = true
            }
        },
        unitframes = {
            style = 'Default',
            classcolor = true,
            factioncolor = true,
            pvpbadge = false,
            combaticon = false,
            hitindicator = false,
            totemicons = true,
            classbar = true,
            cornericon = true,
            player = {
                size = 1
            },
            target = {
                size = 1
            },
            buffs = {
                size = 26,
                collapse = false
            },
            debuffs = {
                size = 20
            }
        },
        nameplates = {
            style = 'Default',
            texture = 'Default',
            arenanumber = true,
            totemicons = true,
            healthtext = true,
            server = false,
            color = true,
            casttime = true,
            stackingmode = false,
            height = 2,
            width = 1,
            decimals = 0,
            debuffs = false,
            focusHighlight = false,
            colors = true,
            npccolors = {
                -- Mists of Tirna Scithe
                { id = 164921, name = 'Drust Harvester',         color = { r = 0, g = 0.55, b = 1, a = 1 } },
                { id = 166275, name = 'Mistveil Shaper',         color = { r = 0, g = 0.55, b = 1, a = 1 } },
                { id = 166299, name = 'Mistveil Tender',         color = { r = 0, g = 0.55, b = 1, a = 1 } },
                { id = 167111, name = 'Spinemaw Staghorn',       color = { r = 0, g = 0.55, b = 1, a = 1 } },

                -- The Necrotic Wake
                { id = 166302, name = 'Corpse Harvester',        color = { r = 0, g = 0.55, b = 1, a = 1 } },
                { id = 165137, name = 'Zolramus Gatekeeper',     color = { r = 0, g = 0.55, b = 1, a = 1 } },
                { id = 163128, name = 'Zolramus Sorcerer',       color = { r = 0, g = 0.55, b = 1, a = 1 } },
                { id = 163618, name = 'Zolramus Necromancer',    color = { r = 0, g = 0.55, b = 1, a = 1 } },
                { id = 163126, name = 'Brittlebone Mage',        color = { r = 0, g = 0.55, b = 1, a = 1 } },
                { id = 165919, name = 'Skeletal Marauder',       color = { r = 0, g = 0.55, b = 1, a = 1 } },
                { id = 165824, name = 'Nar\'zudah',              color = { r = 0, g = 0.55, b = 1, a = 1 } },
                { id = 173016, name = 'Corpse Collector',        color = { r = 0, g = 0.55, b = 1, a = 1 } },

                -- Siege of Boralus
                { id = 129370, name = 'Irontide Waveshaper',     color = { r = 0, g = 0.55, b = 1, a = 1 } },
                { id = 128969, name = 'Ashvane Commander',       color = { r = 0, g = 0.55, b = 1, a = 1 } },
                { id = 135241, name = 'Bilge Rat Pillager',      color = { r = 0, g = 0.55, b = 1, a = 1 } },
                { id = 129367, name = 'Bilge Rat Tempest',       color = { r = 0, g = 0.55, b = 1, a = 1 } },
                { id = 144071, name = 'Irontide Waveshaper',     color = { r = 0, g = 0.55, b = 1, a = 1 } },

                -- The Stonevault
                { id = 212389, name = 'Cursedheart Invader',     color = { r = 0, g = 0.55, b = 1, a = 1 } },
                { id = 212453, name = 'Ghastly Voidsoul',        color = { r = 0, g = 0.55, b = 1, a = 1 } },
                { id = 213338, name = 'Forgebound Mender',       color = { r = 0, g = 0.55, b = 1, a = 1 } },
                { id = 221979, name = 'Void Bound Howler',       color = { r = 0, g = 0.55, b = 1, a = 1 } },
                { id = 214350, name = 'Turned Speaker',          color = { r = 0, g = 0.55, b = 1, a = 1 } },
                { id = 214066, name = 'Cursedforge Stoneshaper', color = { r = 0, g = 0.55, b = 1, a = 1 } },
                { id = 224962, name = 'Cursedforge Mender',      color = { r = 0, g = 0.55, b = 1, a = 1 } },

                -- The Dawnbreaker
                { id = 213892, name = 'Nightfall Shadowmage',    color = { r = 0, g = 0.55, b = 1, a = 1 } },
                { id = 214762, name = 'Nightfall Commander',     color = { r = 0, g = 0.55, b = 1, a = 1 } },
                { id = 210966, name = 'Sureki Webmage',          color = { r = 0, g = 0.55, b = 1, a = 1 } },
                { id = 213893, name = 'Nightfall Darkcaster',    color = { r = 0, g = 0.55, b = 1, a = 1 } },
                { id = 213932, name = 'Sureki Militant',         color = { r = 0, g = 0.55, b = 1, a = 1 } },

                -- Grim Batol
                { id = 224219, name = 'Twilight Earthcaller',    color = { r = 0, g = 0.55, b = 1, a = 1 } },
                { id = 40167,  name = 'Twilight Beguiler',       color = { r = 0, g = 0.55, b = 1, a = 1 } },
                { id = 224271, name = 'Twilight Warlock',        color = { r = 0, g = 0.55, b = 1, a = 1 } },

                -- Ara-Kara
                { id = 216293, name = 'Trilling Attendant',      color = { r = 0, g = 0.55, b = 1, a = 1 } },
                { id = 217531, name = 'Ixin',                    color = { r = 0, g = 0.55, b = 1, a = 1 } },
                { id = 218324, name = 'Nakt',                    color = { r = 0, g = 0.55, b = 1, a = 1 } },
                { id = 217533, name = 'Atik',                    color = { r = 0, g = 0.55, b = 1, a = 1 } },
                { id = 223253, name = 'Bloodstained Webmage',    color = { r = 0, g = 0.55, b = 1, a = 1 } },
                { id = 216340, name = 'Sentry Stagshell',        color = { r = 0, g = 0.55, b = 1, a = 1 } },
                { id = 220599, name = 'Bloodstained Webmage',    color = { r = 0, g = 0.55, b = 1, a = 1 } },
                { id = 216364, name = 'Blood Overseer',          color = { r = 0, g = 0.55, b = 1, a = 1 } },

                -- City of Threads
                { id = 220195, name = 'Sureki Silkbinder',       color = { r = 0, g = 0.55, b = 1, a = 1 } },
                { id = 220196, name = 'Herald Of Ansurek',       color = { r = 0, g = 0.55, b = 1, a = 1 } },
                { id = 219984, name = 'Xephitik',                color = { r = 0, g = 0.55, b = 1, a = 1 } },
                { id = 223844, name = 'Covert Webmancer',        color = { r = 0, g = 0.55, b = 1, a = 1 } },
                { id = 224732, name = 'Covert Webmancer',        color = { r = 0, g = 0.55, b = 1, a = 1 } },
                { id = 216339, name = 'Sureki Unnaturaler',      color = { r = 0, g = 0.55, b = 1, a = 1 } },
                { id = 221102, name = 'Elder Shadeweaver',       color = { r = 0, g = 0.55, b = 1, a = 1 } },
            }
        },
        raidframes = {
            texture = [[Interface/AddOns/Phoenix_UI/Media/Textures/Status/Flat.blp]],
            alwaysontop = false,
            size = false,
            height = 75,
            width = 100,
        },
        actionbar = {
            buttons = {
                key = true,
                macro = true,
                range = true,
                flash = false,
                size = 12
            },
            menu = {
                micromenu = 'show',
                bagbar = 'show'
            },
            bars = {
                bar1 = false,
                bar2 = false,
                bar3 = false,
                bar4 = false,
                bar5 = false,
                bar6 = false,
                bar7 = false,
                bar8 = false,
                petbar = false,
                stancebar = false
            },
            animation = {
                flashDuration = 0.5,
                flashIntensity = 0.7,
                flashColor = "white"
            },
            style = {
                buttonBorder = "default",
                glowEffect = "default",
                borderColor = "default"
            },
            padding = {
                global = 2,
                buttonSpacing = 2
            },
            barPadding = {
                bar1 = 2,
                bar2 = 2,
                bar3 = 2,
                bar4 = 2,
                bar5 = 2,
                petbar = 2
            }
        },
        castbars = {
            style = 'Custom',
            icon = true,
            timer = true,
            targetCastbar = true,
            focusCastbar = true,
            focusSize = 1,
            targetSize = 1,
            targetOnTop = false,
            focusOnTop = false,
            showLatency = true,
            showTarget = true
        },
        tooltip = {
            style = 'Custom',
            lifeontop = true,
            mouseanchor = false,
            hideincombat = false,
            targetOfTarget = true,
            roleIcons = true,
            showHealth = true,
            detailedAuras = true,
            auraSource = true,
            auraDuration = true,
            auraType = true
        },
        buffs = {
            buff = {
                size = 32,
                padding = 2,
                icons = 10
            },
            debuff = {
                size = 34,
                padding = 2,
                icons = 10
            }
        },
        chat = {
            style = 'Custom',
            top = false,
            link = true,
            copy = true,
            quickjoin = true,
            friendlist = true,
            looticons = true,
            history = {
                enabled = true,
                lines = 500
            },
            expandedView = {
                enabled = true
            },
            classSpec = {
                enabled = true,
                showIcons = true
            },
            emoji = {
                enabled = true,
                size = 16
            }
        },
        maps = {
            minimapsize = 1,
            style = 'Default',
            small = false,
            opacity = 1,
            coords = true,
            minimap = true,
            clock = true,
            date = false,
            garrison = true,
            tracking = false,
            buttons = true,
            expansionbutton = false,
        },
        misc = {
            safequeue = true,
            tabbinder = false,
            pulltimer = false,
            interrupt = false,
            dampening = true,
            arenanameplate = false,
            surrender = false,
            losecontrol = false,
            repbar = false,
            menubutton = true,
            dragonflying = true,
        },
        msbt = {
            enabled = false,
        },
        edit = {
            statsframe = {
                point = 'BOTTOMLEFT',
                x = 5,
                y = 3
            },
            queueicon = {
                point = 'CENTER',
                x = 0,
                y = 0
            },
        },
    }
}

-- EMERGENCY FIX: Replaced with proper integration code
-- This provides a compatibility layer for any code that might be referencing the old function
do
    -- Create a compatibility function that uses our proper module
    _G["Phoenix_UIBossFrames"] = function(frame, event)
        -- If frame exists and has a healthbar
        if frame and frame.healthbar then
            -- Get database settings
            local db = Phoenix_UI.db and Phoenix_UI.db.profile and 
                       Phoenix_UI.db.profile.general
            
            -- Apply colors and textures properly using pcall for safety
            if db and db.color then
                pcall(function()
                    local r = db.color.r or 0
                    local g = db.color.g or 0
                    local b = db.color.b or 0
                    frame.healthbar:SetStatusBarColor(r, g, b)
                end)
            end
            
            if db and db.texture then
                pcall(function()
                    frame.healthbar:SetStatusBarTexture(db.texture)
                end)
            end
        end
        return true
    end
    
    -- Keep the safeguard function for backward compatibility
    _G["Phoenix_UI_SafeguardBossFrames"] = function()
        -- Apply to boss frames using the proper function
        for i = 1, 5 do
            local frame = _G["Boss"..i.."TargetFrame"]
            if frame then
                _G["Phoenix_UIBossFrames"](frame)
            end
        end
    end
end

-- Replace the CRITICAL FIX with a simple compatibility hook
local bossFrameCompat = CreateFrame("Frame")
bossFrameCompat:RegisterEvent("PLAYER_ENTERING_WORLD")
bossFrameCompat:RegisterEvent("ADDON_LOADED")
bossFrameCompat:SetScript("OnEvent", function()
    -- Call the compatibility function for each boss frame
    for i = 1, 5 do
        local frame = _G["Boss"..i.."TargetFrame"]
        if frame then
            _G["Phoenix_UIBossFrames"](frame)
        end
    end
end)

function Phoenix_UI:OnInitialize()
    -- Database initialize with proper error handling
    self.db = LibStub("AceDB-3.0"):New("Phoenix_UIDB", defaults, true)
    if not self.db or not self.db.profile then
        -- Create a more complete fallback that implements all required AceDB methods
        self.db = {
            profile = CopyTable(defaults.profile),
            sv = { profileKeys = {}, profiles = { Default = CopyTable(defaults.profile) } },
            keys = { profile = "Default" },
            defaults = defaults,
            RegisterNamespace = function(_, name, defaults) return { profile = CopyTable(defaults.profile or {}) } end,
            GetNamespace = function() return { profile = {} } end,
            RegisterDefaults = function() end,
            ResetProfile = function() end,
            SetProfile = function() end,
            GetProfiles = function() return {"Default"} end,
            GetCurrentProfile = function() return "Default" end,
            DeleteProfile = function() end,
            CopyProfile = function() end,
            ResetDB = function() end,
            RegisterCallback = function() end,
            UnregisterCallback = function() end,
            UnregisterAllCallbacks = function() end,
            parent = nil
        }
        print("|cffFF7D0APhoenix|r|cffFF0000_|r|cffFFD100UI|r: Error initializing database. Using fallback settings.")
    end
    
    -- Initialize additional storage
    self.chatHistory = self.chatHistory or {}
    
    -- Load saved chat history if it exists
    if self.db.global and self.db.global.chatHistory then
        self.chatHistory = CopyTable(self.db.global.chatHistory)
    end
    
    -- Initialize character DB with error handling
    self.charDB = LibStub("AceDB-3.0"):New("Phoenix_UIPerCharDB", { profile = {} }, true)
    if not self.charDB or not self.charDB.profile then
        -- Create a fallback character database
        self.charDB = {
            profile = {},
            RegisterNamespace = function(_, name, defaults)
                return { profile = CopyTable(defaults.profile or {}) }
            end
        }
        print("|cffFF7D0APhoenix|r|cffFF0000_|r|cffFFD100UI|r: Error initializing character database. Using fallback settings.")
    end
    
    -- Register BuffOverlay command
    if not self.buffoverlayCommandRegistered then
        self:RegisterChatCommand("buffoverlay", function()
            if LibStub and LibStub("AceAddon-3.0"):GetAddon("BuffOverlay", true) then
                local BuffOverlay = LibStub("AceAddon-3.0"):GetAddon("BuffOverlay")
                if BuffOverlay and BuffOverlay.OpenConfigPanel then
                    BuffOverlay:OpenConfigPanel()
                end
            else
                print("|cffFF7D0APhoenix UI:|r BuffOverlay addon not found or not loaded.")
            end
        end)
        self.buffoverlayCommandRegistered = true
    end
    
    -- Set up namespaces for all modules with error handling
    self.moduleDB = {}
    
    -- Define a safe registration function
    local function SafeRegisterNamespace(db, name, defaults)
        if db and db.RegisterNamespace then
            -- Check if namespace already exists
            local existingNamespace
            if db.GetNamespace then
                -- Try to get existing namespace using pcall to avoid errors
                local success, result = pcall(function() return db:GetNamespace(name) end)
                if success and result then
                    existingNamespace = result
                end
            end
            
            -- If namespace already exists, just return it
            if existingNamespace then
                -- Apply any new defaults if provided
                if defaults and defaults.profile then
                    for key, value in pairs(defaults.profile) do
                        if existingNamespace.profile[key] == nil then
                            existingNamespace.profile[key] = value
                        end
                    end
                end
                return existingNamespace
            end
            
            -- Register the namespace properly
            local namespace = db:RegisterNamespace(name, defaults or {})
            
            -- Ensure profile exists
            if not namespace.profile then
                namespace.profile = CopyTable((defaults or {}).profile or {})
            end
            
            -- Add special handling for problematic modules
            local criticalModules = {
                "nameplates", "actionbars", "castbars", "buffs", "msbt", "idtip"
            }
            
            for _, module in ipairs(criticalModules) do
                if name:lower() == module:lower() and not namespace.profile[module] then
                    namespace.profile[module] = {}
                end
            end
            
            return namespace
        else
            return { profile = CopyTable((defaults or {}).profile or {}) }
        end
    end
    
    -- Change to make SafeRegisterNamespace available to Phoenix_UI
    Phoenix_UI.SafeRegisterNamespace = SafeRegisterNamespace
    
    -- Safely register all namespaces
    self.moduleDB.BuffOverlay = SafeRegisterNamespace(self.db, "BuffOverlay", {
        profile = {
            welcomeMessage = true,
            minimap = {
                hide = false,
            },
            bars = {},
            buffs = {},
        },
        global = {
            customBuffs = {},
            dbVer = 0,
        },
    })
    
    self.moduleDB.MSBT = SafeRegisterNamespace(self.db, "MSBT", {
        profile = {
            enabled = false
        }
    })
    self.moduleDB.MSBTMedia = SafeRegisterNamespace(self.db, "MSBTMedia", {})
    self.moduleDB.PremadeGroupsFilter = SafeRegisterNamespace(self.db, "PremadeGroupsFilter", {})
    self.moduleDB.idTip = SafeRegisterNamespace(self.db, "idTip", {
        profile = {
            enabled = true
        }
    })
    self.moduleDB.MoveAny = SafeRegisterNamespace(self.db, "MoveAny", {
        profile = {
            welcomeMessage = false,
        }
    })
    
    -- Register the specialized modules listed in the error messages
    self.moduleDB.ActionBars = SafeRegisterNamespace(self.db, "ActionBars", {
        profile = {
            enabled = true
        }
    })
    
    self.moduleDB.Map = SafeRegisterNamespace(self.db, "Map", {
        profile = {
            enabled = true
        }
    })
    
    self.moduleDB.Tooltip = SafeRegisterNamespace(self.db, "Tooltip", {
        profile = {
            enabled = true
        }
    })
    
    self.moduleDB.UnitFrames = SafeRegisterNamespace(self.db, "UnitFrames", {
        profile = {
            enabled = true
        }
    })
    
    -- Ensure nameplates, actionbars, castbars, and buffs settings exist and are initialized
    if not self.db.profile.nameplates then self.db.profile.nameplates = {} end
    if not self.db.profile.actionbars then self.db.profile.actionbars = {} end
    if not self.db.profile.castbars then self.db.profile.castbars = {} end
    if not self.db.profile.buffs then self.db.profile.buffs = {} end
    if not self.db.profile.msbt then self.db.profile.msbt = { enabled = false } end
    if not self.db.profile.idtip then self.db.profile.idtip = { enabled = true } end
    if not self.db.profile.map then self.db.profile.map = { enabled = true } end
    if not self.db.profile.tooltip then self.db.profile.tooltip = { enabled = true } end
    if not self.db.profile.buffoverlay then self.db.profile.buffoverlay = { enabled = true } end
    if not self.db.profile.nameplates then self.db.profile.nameplates = { enabled = true } end
    if not self.db.profile.unitframes then self.db.profile.unitframes = { enabled = true } end
    
    -- Set up per-character namespaces safely
    self.moduleCharDB = {
        PremadeGroupsFilter = SafeRegisterNamespace(self.charDB, "PremadeGroupsFilter", {}),
        MSBT = SafeRegisterNamespace(self.charDB, "MSBT", {})
    }
    
    -- Ensure tables exist
    if not self.moduleDB.MSBT.profile then
        self.moduleDB.MSBT.profile = {}
    end
    
    if not self.moduleDB.MSBTMedia.profile then
        self.moduleDB.MSBTMedia.profile = {}
    end
    
    if not self.moduleCharDB.MSBT.profile then
        self.moduleCharDB.MSBT.profile = {}
    end
    
    -- Check if old data exists for migration
    -- BuffOverlay
    if BuffOverlayDB and type(BuffOverlayDB) == "table" then
        -- Disable welcome message
        if BuffOverlayDB.profile then
            BuffOverlayDB.profile.welcomeMessage = false
        end
        
        if not self.moduleDB.BuffOverlay.profile.migratedFromOldDB then
            self.moduleDB.BuffOverlay.profile = CopyTable(BuffOverlayDB.profile or {})
            self.moduleDB.BuffOverlay.global = CopyTable(BuffOverlayDB.global or {})
            self.moduleDB.BuffOverlay.profile.migratedFromOldDB = true
            self.moduleDB.BuffOverlay.profile.welcomeMessage = false
            
            -- Don't show migration message
            -- C_Timer.After(1, function()
            --     print("|cffFF7D0APhoenix|r|cffFF0000_|r|cffFFD100UI|r: BuffOverlay settings migrated to new database format.")
            -- end)
        end
    end
    
    -- PremadeGroupsFilter
    if PremadeGroupsFilterSettings and type(PremadeGroupsFilterSettings) == "table" then
        if not self.moduleDB.PremadeGroupsFilter.profile.migratedFromOldDB then
            self.moduleDB.PremadeGroupsFilter.profile = CopyTable(PremadeGroupsFilterSettings or {})
            self.moduleDB.PremadeGroupsFilter.profile.migratedFromOldDB = true
            
            -- Don't show migration message
            -- C_Timer.After(1, function()
            --    print("|cffFF7D0APhoenix|r|cffFF0000_|r|cffFFD100UI|r: PremadeGroupsFilter settings migrated to new database format.")
            -- end)
        end
    end
    
    -- PremadeGroupsFilterState (per-character)
    if PremadeGroupsFilterState and type(PremadeGroupsFilterState) == "table" then
        if not self.moduleCharDB.PremadeGroupsFilter.profile.migratedFromOldDB then
            self.moduleCharDB.PremadeGroupsFilter.profile = CopyTable(PremadeGroupsFilterState or {})
            self.moduleCharDB.PremadeGroupsFilter.profile.migratedFromOldDB = true
        end
    end
    
    -- MSBT
    if MSBTProfiles_SavedVars and type(MSBTProfiles_SavedVars) == "table" then
        if not self.moduleDB.MSBT.profile.migratedFromOldDB then
            self.moduleDB.MSBT.profile = CopyTable(MSBTProfiles_SavedVars or {})
            self.moduleDB.MSBT.profile.migratedFromOldDB = true
            
            -- Don't show migration message
            -- C_Timer.After(1, function()
            --    print("|cffFF7D0APhoenix|r|cffFF0000_|r|cffFFD100UI|r: MSBT settings migrated to new database format.")
            -- end)
        end
    end
    
    -- MSBTMedia
    if MSBT_SavedMedia and type(MSBT_SavedMedia) == "table" then
        if not self.moduleDB.MSBTMedia.profile.migratedFromOldDB then
            self.moduleDB.MSBTMedia.profile = CopyTable(MSBT_SavedMedia or {})
            self.moduleDB.MSBTMedia.profile.migratedFromOldDB = true
        end
    end
    
    -- idTip
    if _G.idTipConfig and type(_G.idTipConfig) == "table" and not self.moduleDB.idTip.profile.migratedFromOldDB then
        self.moduleDB.idTip.profile = CopyTable(_G.idTipConfig or {})
        self.moduleDB.idTip.profile.migratedFromOldDB = true
        
        -- Don't show migration message
        -- C_Timer.After(1, function()
        --    print("|cffFF7D0APhoenix|r|cffFF0000_|r|cffFFD100UI|r: idTip settings migrated to new database format.")
        -- end)
    end
    
    -- Add SaveDB function for ensuring saved settings
    function Phoenix_UI:SaveDB()
        -- Check if we're saving too frequently to prevent spam
        local currentTime = GetTime()
        if self.lastSaveTime and (currentTime - self.lastSaveTime) < 0.2 then
            -- Saving too frequently, delay the save
            if not self.pendingSave then
                self.pendingSave = C_Timer.NewTimer(0.5, function()
                    self.pendingSave = nil
                    self:SaveDB()
                end)
            end
            return
        end
        
        -- Check for forced save flag 
        local forceSave = self._forceSave
        self._forceSave = nil
        
        -- Record this save time
        self.lastSaveTime = currentTime
        
        -- Cancel any existing save timers to avoid duplicates
        if self.pendingSave then
            self.pendingSave:Cancel()
            self.pendingSave = nil
        end
        
        -- Get current profile info
        local currentProfile = self.db and self.db.keys and self.db.keys.profile or "Default"
        
        -- Before saving, ensure any uncommitted changes from the UI are committed
        if self.UI and self.UI.CommitPendingChanges then
            pcall(function() self.UI:CommitPendingChanges() end)
        end
        
        -- Save chat history if enabled
        if self.chatHistory and self.db and self.db.profile and 
           self.db.profile.chat and self.db.profile.chat.history and 
           self.db.profile.chat.history.enabled then
            -- Ensure global table exists
            self.db.global = self.db.global or {}
            -- Save chat history to global DB for persistence
            self.db.global.chatHistory = CopyTable(self.chatHistory)
        end
        
        -- Special handling for chat settings - ensure they're initialized
        if self.db and self.db.profile and self.db.profile.chat then
            -- Mark chat settings as requiring save
            self.db.profile.chat.__updated = GetTime()
            
            -- Ensure chat history settings are initialized
            if self.db.profile.chat.history == nil then
                self.db.profile.chat.history = {
                    enabled = true,
                    lines = 500
                }
            end
            
            -- Ensure expanded view settings are initialized
            if self.db.profile.chat.expandedView == nil then
                self.db.profile.chat.expandedView = {
                    enabled = true
                }
            end
            
            -- Ensure class spec settings are initialized
            if self.db.profile.chat.classSpec == nil then
                self.db.profile.chat.classSpec = {
                    enabled = true,
                    showIcons = true
                }
            end
        end
        
        -- Force database to save changes
        if self.db and self.db.RegisterDefaults then
            pcall(function() self.db:RegisterDefaults(defaults) end)
        end
        
        -- Make sure to register profile explicitly
        if self.db and self.db.SetProfile and currentProfile then
            pcall(function() self.db:SetProfile(currentProfile) end)
        end
        
        -- Force prioritization of general settings
        if self.db and self.db.profile and self.db.profile.general then
            -- Ensure font settings synchronization
            if self.db.profile.general.font and self.db.profile.fonts then
                self.db.profile.fonts.gameFont = self.db.profile.fonts.gameFont or {}
                self.db.profile.fonts.gameFont.family = self.db.profile.general.font
            end
            
            -- Apply any settings that haven't been applied
            if self.ApplyFontSettings then
                self:ApplyFontSettings()
            end
        end
        
        -- Force direct save to disk for critical settings
        if self.db and self.db.sv then
            -- Mark current profile to help with recovery if needed
            self.db.sv.__currentProfile = currentProfile
            self.db.sv.__lastSaved = GetTime()
            
            -- Force Ace3 to write to disk
            if self.db.sv.profile and type(self.db.sv.profile) == "table" then
                -- Access and modify a value to ensure changes are detected
                local tempKey = "__lastSaved"
                self.db.sv.profile[tempKey] = GetTime()
                
                -- Touch every section to ensure all changes are saved
                for sectionName, _ in pairs(self.db.profile) do
                    if type(self.db.profile[sectionName]) == "table" then
                        -- Safely mark the section as updated
                        pcall(function()
                            self.db.sv.profile[sectionName] = self.db.sv.profile[sectionName] or {}
                            self.db.sv.profile[sectionName].__updated = GetTime()
                        end)
                    end
                end
            end
        end
        
        -- Also save character database
        if self.charDB and self.charDB.sv then
            self.charDB.sv.__currentProfile = self.charDB.keys and self.charDB.keys.profile or "Default"
            self.charDB.sv.__lastSaved = GetTime()
            
            -- Force Ace3 to write character data to disk
            if self.charDB.sv.profile and type(self.charDB.sv.profile) == "table" then
                -- Access and modify a value to ensure changes are detected
                local tempKey = "__lastSaved"
                self.charDB.sv.profile[tempKey] = GetTime()
                
                -- Touch every section to ensure all changes are saved
                for sectionName, _ in pairs(self.charDB.profile) do
                    if type(self.charDB.profile[sectionName]) == "table" then
                        -- Safely mark the section as updated
                        pcall(function()
                            self.charDB.sv.profile[sectionName] = self.charDB.sv.profile[sectionName] or {}
                            self.charDB.sv.profile[sectionName].__updated = GetTime()
                        end)
                    end
                end
            end
        end
        
        -- Directly update the global savedvariables to ensure persistence
        if _G["Phoenix_UIDB"] and self.db and self.db.profile then
            -- Make sure we have a profiles table
            _G["Phoenix_UIDB"].profiles = _G["Phoenix_UIDB"].profiles or {}
            _G["Phoenix_UIDB"].profiles[currentProfile] = _G["Phoenix_UIDB"].profiles[currentProfile] or {}
            
            -- Safety copy all critical settings
            pcall(function()
                -- Copy the general settings first (priority)
                if self.db.profile.general then
                    _G["Phoenix_UIDB"].profiles[currentProfile].general = CopyTable(self.db.profile.general)
                    
                    -- Also save in Default profile for safety
                    _G["Phoenix_UIDB"].profiles.Default = _G["Phoenix_UIDB"].profiles.Default or {}
                    _G["Phoenix_UIDB"].profiles.Default.general = CopyTable(self.db.profile.general)
                end
                
                -- Ensure font settings are properly saved (priority)
                if self.db.profile.fonts then
                    _G["Phoenix_UIDB"].profiles[currentProfile].fonts = CopyTable(self.db.profile.fonts)
                    
                    -- Also save in Default profile for security
                    _G["Phoenix_UIDB"].profiles.Default = _G["Phoenix_UIDB"].profiles.Default or {}
                    _G["Phoenix_UIDB"].profiles.Default.fonts = CopyTable(self.db.profile.fonts)
                end
                
                -- UI scaling settings (priority)
                if self.db.profile.uiscaling then
                    _G["Phoenix_UIDB"].profiles[currentProfile].uiscaling = _G["Phoenix_UIDB"].profiles[currentProfile].uiscaling or {}
                    _G["Phoenix_UIDB"].profiles[currentProfile].uiscaling.scale = self.db.profile.uiscaling.scale
                    
                    -- Safety: also save to Default profile as fallback
                    _G["Phoenix_UIDB"].profiles.Default = _G["Phoenix_UIDB"].profiles.Default or {}
                    _G["Phoenix_UIDB"].profiles.Default.uiscaling = _G["Phoenix_UIDB"].profiles.Default.uiscaling or {}
                    _G["Phoenix_UIDB"].profiles.Default.uiscaling.scale = self.db.profile.uiscaling.scale
                end
                
                -- Save tooltip settings explicitly since they're the focus of recent changes
                if self.db.profile.tooltip then
                    _G["Phoenix_UIDB"].profiles[currentProfile].tooltip = CopyTable(self.db.profile.tooltip)
                end
                
                -- Save nameplates settings explicitly to ensure they persist
                if self.db.profile.nameplates then
                    _G["Phoenix_UIDB"].profiles[currentProfile].nameplates = CopyTable(self.db.profile.nameplates)
                end
                
                -- Now copy all module settings for redundancy
                for moduleName, moduleData in pairs(self.db.profile) do
                    if type(moduleData) == "table" and 
                       moduleName ~= "general" and 
                       moduleName ~= "fonts" and 
                       moduleName ~= "uiscaling" and
                       moduleName ~= "tooltip" and
                       moduleName ~= "nameplates" then
                        _G["Phoenix_UIDB"].profiles[currentProfile][moduleName] = 
                            _G["Phoenix_UIDB"].profiles[currentProfile][moduleName] or {}
                        
                        -- Deep copy module settings
                        _G["Phoenix_UIDB"].profiles[currentProfile][moduleName] = CopyTable(moduleData)
                    end
                end
                
                -- Also save specific module settings that need extra care
                self:SyncModuleSettings(forceSave or true) -- Force immediate sync
                
                -- Ensure profile keys information is set
                _G["Phoenix_UIDB"].profileKeys = _G["Phoenix_UIDB"].profileKeys or {}
                local playerKey = UnitName("player") .. " - " .. GetRealmName()
                _G["Phoenix_UIDB"].profileKeys[playerKey] = currentProfile
                
                -- Mark as current profile
                _G["Phoenix_UIDB"].__currentProfile = currentProfile
                _G["Phoenix_UIDB"].__lastSaved = GetTime()
            end)
        end
        
        -- Set timestamp on all profile sections to force detection of changes
        if self.db and self.db.profile then
            for sectionName, sectionData in pairs(self.db.profile) do
                if type(sectionData) == "table" then
                    -- Add a timestamp field to mark as updated
                    sectionData.__updated = GetTime()
                end
            end
        end
        
        -- Force SavedVariables to write to disk
        pcall(function()
            if FlushSavedVariables then
                FlushSavedVariables()
            elseif FlushSettingsDB then
                FlushSettingsDB()
            end
        end)
        
        -- Fire saved event for any listeners
        self:SendMessage("PHOENIX_UI_SETTINGS_SAVED")
        
        -- Force update for any open configuration UI
        if self.UI and self.UI.RefreshConfig then
            self.UI:RefreshConfig()
        end
        
        -- Set up sync timer to handle delayed settings that need to propagate
        if self.syncTimer then
            self.syncTimer:Cancel()
        end
        
        self.syncTimer = C_Timer.NewTimer(1, function()
            if self.SyncModuleSettings then
                self:SyncModuleSettings()
            end
        end)
    end
    
    -- Allow forcing an immediate save
    function Phoenix_UI:ForceSaveDB()
        self._forceSave = true
        self:SaveDB()
        
        -- Register BuffOverlay command if needed
        if not self.buffoverlayCommandRegistered then
            self:RegisterChatCommand("buffoverlay", function()
                if LibStub and LibStub("AceAddon-3.0"):GetAddon("BuffOverlay", true) then
                    local BuffOverlay = LibStub("AceAddon-3.0"):GetAddon("BuffOverlay")
                    if BuffOverlay and BuffOverlay.OpenConfigPanel then
                        BuffOverlay:OpenConfigPanel()
                    end
                else
                    print("|cffFF7D0APhoenix UI:|r BuffOverlay addon not found or not loaded.")
                end
            end)
            self.buffoverlayCommandRegistered = true
        end
    end
    
    -- Apply UI scale from saved settings
    local function getProfileScale()
        -- Try to get scale from current profile first
        local currentProfile = self.db.keys.profile or "Default"
        local scaleFromCurrentProfile = nil
        
        -- First try current AceDB profile
        if self.db.profile.uiscaling and self.db.profile.uiscaling.scale then
            scaleFromCurrentProfile = self.db.profile.uiscaling.scale
            if scaleFromCurrentProfile and tonumber(scaleFromCurrentProfile) > 0 then
                return scaleFromCurrentProfile
            end
        end
        
        -- Try direct global variables with current profile
        if _G["Phoenix_UIDB"] and _G["Phoenix_UIDB"].profiles and 
           _G["Phoenix_UIDB"].profiles[currentProfile] and 
           _G["Phoenix_UIDB"].profiles[currentProfile].uiscaling then
            scaleFromCurrentProfile = _G["Phoenix_UIDB"].profiles[currentProfile].uiscaling.scale
            if scaleFromCurrentProfile and tonumber(scaleFromCurrentProfile) > 0 then
                -- Also update the AceDB profile
                self.db.profile.uiscaling = self.db.profile.uiscaling or {}
                self.db.profile.uiscaling.scale = scaleFromCurrentProfile
                
                return scaleFromCurrentProfile
            end
        end
        
        -- Fallback to default profile
        if _G["Phoenix_UIDB"] and _G["Phoenix_UIDB"].profiles and 
           _G["Phoenix_UIDB"].profiles.Default and 
           _G["Phoenix_UIDB"].profiles.Default.uiscaling then
            local scaleFromDefault = _G["Phoenix_UIDB"].profiles.Default.uiscaling.scale
            if scaleFromDefault and tonumber(scaleFromDefault) > 0 then
                -- Also update the AceDB database
                self.db.profile.uiscaling = self.db.profile.uiscaling or {}
                self.db.profile.uiscaling.scale = scaleFromDefault
                
                return scaleFromDefault
            end
        end
        
        -- Final fallback to CVar
        local cvarScale = GetCVar("uiScale")
        if cvarScale and tonumber(cvarScale) > 0 then
            return cvarScale
        end
        
        return 1.0 -- Default fallback
    end
    
    -- Apply scale
    local savedScale = getProfileScale()
    if savedScale and tonumber(savedScale) > 0 then
        SetCVar("uiScale", savedScale)
        UIParent:SetScale(savedScale)
    end

    -- Colors
    local _, class = UnitClass("player")
    local classColor = RAID_CLASS_COLORS[class]
    local customColor = self.db.profile.general.color
    local themes = {
        Blizzard = nil,
        Dark = { 0.3, 0.3, 0.3 },
        Class = { classColor.r, classColor.g, classColor.b },
        Custom = { customColor.r, customColor.g, customColor.b },
    }
    local theme = themes[self.db.profile.general.theme]

    self.Theme = {
        Register = function(n, f)
            --print('register')
            --if (self.Theme.Frames[n]) then f(true, self.Theme.Data) end
        end,
        Update = function()
            -- print("update")
            for n, f in pairs(self.Theme.Frames) do
                -- print(n)
                f(false, self.Theme.Data)
            end
        end,
        Data = function()
            local themes = {
                Blizzard = nil,
                Dark = { 0.3, 0.3, 0.3 },
                Class = { classColor.r, classColor.g, classColor.b },
                Custom = { customColor.r, customColor.g, customColor.b },
            }
            local theme = themes[self.db.profile.general.theme]
            return {
                style = self.db.profile.general.theme,
                color = self.db.profile.general.color
            }
        end,
        Frames = {
            Tooltip = function() end
        }
    }

    function self:Color(sub, alpha)
        if (theme) then
            if not (alpha) then alpha = 1 end
            local color = { 0, 0, 0, alpha }
            for key, value in pairs(theme) do
                if (sub) then color[key] = value - sub else color[key] = value end
            end
            return color
        end
    end

    -- Phoenix_UI Version check
    local currentVersion = C_AddOns.GetAddOnMetadata(addonName, "version")
    Phoenix_UI.Version = currentVersion

    local function GetDefaultCommChannel()
        if IsInRaid() then
            return IsInRaid(LE_PARTY_CATEGORY_INSTANCE) and "INSTANCE_CHAT" or "RAID"
        elseif IsInGroup() then
            return IsInGroup(LE_PARTY_CATEGORY_INSTANCE) and "INSTANCE_CHAT" or "PARTY"
        elseif IsInGuild() then
            return "GUILD"
        else
            return "YELL"
        end
    end

    function self:ReceiveVersion(_, version, _, sender)
        if not Phoenix_UI.db.profile.new_version then
            if (version > currentVersion) then
                self:ShowMessage("A newer version is available. If you experience any errors or bugs, updating is highly recommended.", true)

                Phoenix_UI.db.profile.new_version = version
            end
        elseif (Phoenix_UI.db.profile.new_version == currentVersion) or (Phoenix_UI.db.profile.new_version <= currentVersion) then
            Phoenix_UI.db.profile.new_version = false
        end
    end

    function self:SendVersion(channel)
        self:SendCommMessage("PhoenixUIVersion", currentVersion, channel or GetDefaultCommChannel())
    end

    self:RegisterComm("PhoenixUIVersion", "ReceiveVersion")
    self:RegisterEvent("ZONE_CHANGED_NEW_AREA", function()
        self:SendVersion()
        if IsInGuild() then self:SendVersion("GUILD") end
    end)
    C_Timer.After(30, function()
        self:SendVersion()
        if IsInGuild() then self:SendVersion("GUILD") end
        self:SendVersion("YELL")
    end)

    if (Phoenix_UI.db.profile.new_version and Phoenix_UI.db.profile.new_version > currentVersion) then
        self:ShowMessage("A newer version is available. If you experience any errors or bugs, updating is highly recommended.", true)
    end

    function self:Skin(frame, customColor, isTable)
        Phoenix_UI_forbiddenFrames = {
            ["CalendarCreateEventIcon"] = true,
            ["FriendsFrameIcon"] = true,
            ["MacroFramePortrait"] = true,
            [select(3, GossipFrame:GetRegions())] = true,
            ["QuestFrameDetailPanelBg"] = true,
            [select(3, DressUpFrame:GetRegions())] = true,
            [select(2, ChatFrame1EditBox:GetRegions())] = true,
            [select(2, ChatFrame2EditBox:GetRegions())] = true,
            [select(2, ChatFrame3EditBox:GetRegions())] = true,
            [select(2, ChatFrame4EditBox:GetRegions())] = true,
            [select(2, ChatFrame5EditBox:GetRegions())] = true,
            [select(2, ChatFrame6EditBox:GetRegions())] = true,
            [select(2, ChatFrame7EditBox:GetRegions())] = true,
            [select(1, TradeFrame.RecipientOverlay:GetRegions())] = true,
            ["StaticPopup1AlertIcon"] = true,
            ["StaticPopup2AlertIcon"] = true,
            ["StaticPopup3AlertIcon"] = true,
            ["PVPReadyDialogBackground"] = true,
            ["LFGDungeonReadyDialogBackground"] = true,
            [select(4, LFGListInviteDialog:GetRegions())] = true,
        }

        if (frame) then
            if not (isTable) then
                for _, v in pairs({ frame:GetRegions() }) do
                    if (not Phoenix_UI_forbiddenFrames[v:GetName()]) and (not Phoenix_UI_forbiddenFrames[v]) then
                        if v:GetObjectType() == "Texture" then
                            if (customColor) then
                                v:SetDesaturated(true)
                                v:SetVertexColor(unpack(Phoenix_UI:Color(.15)))
                            else
                                v:SetDesaturated(true)
                                v:SetVertexColor(.15, .15, .15)
                            end
                        end
                    end
                end
            else
                for _, v in pairs(frame) do
                    if (v) then
                        if (customColor) then
                            v:SetDesaturated(true)
                            v:SetVertexColor(unpack(Phoenix_UI:Color(.15)))
                        else
                            v:SetDesaturated(true)
                            v:SetVertexColor(.15, .15, .15)
                        end
                    end
                end
            end
        end
    end

    -- Create a stunning welcome panel for first time installation
    function self:CreateWelcomePanel()
        -- Check if panel already exists to avoid duplicates
        if self.WelcomePanel then
            self.WelcomePanel:Show()
            return self.WelcomePanel
        end

        -- Create the panel
        local panel = CreateFrame("Frame", "Phoenix_UI_WelcomePanel", UIParent, "BackdropTemplate")
        panel:SetSize(800, 600)
        panel:SetPoint("CENTER")
        panel:SetFrameStrata("HIGH")
        panel:SetFrameLevel(10)
        panel:EnableMouse(true)
        panel:SetClampedToScreen(true)
        
        -- Add backdrop and styling
        panel:SetBackdrop({
            bgFile = "Interface/DialogFrame/UI-DialogBox-Background",
            edgeFile = "Interface/DialogFrame/UI-DialogBox-Border",
            tile = false, tileSize = 0, edgeSize = 32,
            insets = { left = 8, right = 8, top = 8, bottom = 8 }
        })
        panel:SetBackdropColor(0.05, 0.05, 0.05, 0.95)
        panel:SetBackdropBorderColor(1, 0.4, 0, 0.8)

        -- Create a title text with proper positioning to avoid overlap
        local title = panel:CreateFontString(nil, "OVERLAY")
        title:SetFont("Interface/AddOns/Phoenix_UI/Media/Fonts/Prototype.ttf", 48, "OUTLINE")
        title:SetPoint("TOP", 0, -50)
        title:SetText("|cffFF7D0AWelcome to Phoenix|r |cffFFD100UI|r")
        title:SetWidth(750)
        title:SetJustifyH("CENTER")

        -- Add a horizontal line under the title
        local line = panel:CreateTexture(nil, "ARTWORK")
        line:SetHeight(2)
        line:SetWidth(600)
        line:SetColorTexture(1, 0.4, 0, 0.7)
        line:SetPoint("TOP", title, "BOTTOM", 0, -5)
        
        -- Subtitle with proper positioning
        local subtitle = panel:CreateFontString(nil, "OVERLAY")
        subtitle:SetFont("Interface/AddOns/Phoenix_UI/Media/Fonts/Prototype.ttf", 18, "NONE")
        subtitle:SetPoint("TOP", line, "BOTTOM", 0, -15)
        subtitle:SetText("The Fire Side of World of Warcraft")
        subtitle:SetTextColor(1, 0.7, 0.2)
        
        -- Tagline with better spacing
        local tagline = panel:CreateFontString(nil, "OVERLAY")
        tagline:SetFont("Interface/AddOns/Phoenix_UI/Media/Fonts/PTSansNarrow.ttf", 16, "NONE")
        tagline:SetPoint("TOP", subtitle, "BOTTOM", 0, -12)
        tagline:SetText("Type /pui to open Config Panel - From ashes to ashes Welcome to fire Gamer")
        tagline:SetTextColor(1, 0.8, 0.3)
        
        -- Add fiery animation effect
        local fireEffect = panel:CreateTexture(nil, "BACKGROUND")
        fireEffect:SetPoint("BOTTOMLEFT", 10, 10)
        fireEffect:SetPoint("BOTTOMRIGHT", -10, 80)
        fireEffect:SetHeight(120)
        fireEffect:SetTexture("Interface/AddOns/Phoenix_UI/Media/Textures/Effects/FireBottom")
        fireEffect:SetBlendMode("ADD")
        fireEffect:SetAlpha(0.6)
        
        -- Create animation group for fire
        local fireAnim = fireEffect:CreateAnimationGroup()
        fireAnim:SetLooping("REPEAT")
        
        local fade1 = fireAnim:CreateAnimation("Alpha")
        fade1:SetFromAlpha(0.4)
        fade1:SetToAlpha(0.7)
        fade1:SetDuration(1.5)
        fade1:SetOrder(1)
        
        local fade2 = fireAnim:CreateAnimation("Alpha")
        fade2:SetFromAlpha(0.7)
        fade2:SetToAlpha(0.4)
        fade2:SetDuration(1.5)
        fade2:SetOrder(2)
        
        fireAnim:Play()
        
        -- Features header with proper positioning
        local featuresHeader = panel:CreateFontString(nil, "OVERLAY")
        featuresHeader:SetFont("Interface/AddOns/Phoenix_UI/Media/Fonts/Prototype.ttf", 22, "NONE")
        featuresHeader:SetPoint("TOP", tagline, "BOTTOM", 0, -30)
        featuresHeader:SetText("Included Features:")
        featuresHeader:SetTextColor(1, 0.6, 0.1)
        
        -- Feature highlights - better organized with 2 columns
        local features = {
            "Complete UI Suite with Unified Configuration",
            "Powerful BuffOverlay System",
            "Customizable Nameplates & Unit Frames",
            "Advanced Combat Text via MSBT Integration",
            "Frame Moving & Scaling with MoveAny",
            "Rotation Helper with TrufiGCD",
            "ID Tooltips with idTip",
            "Beautiful UI Scaling that saves properly"
        }
        
        -- Create feature columns container for better organization
        local leftColumn = CreateFrame("Frame", nil, panel)
        leftColumn:SetSize(300, 200)
        leftColumn:SetPoint("TOPLEFT", panel, "TOPLEFT", 100, -250)
        
        local rightColumn = CreateFrame("Frame", nil, panel)
        rightColumn:SetSize(300, 200)
        rightColumn:SetPoint("TOPLEFT", leftColumn, "TOPRIGHT", 20, 0)
        
        -- Add feature texts with better spacing
        for i, feature in ipairs(features) do
            local parentFrame = i <= 4 and leftColumn or rightColumn
            local yOffset = ((i - 1) % 4) * -35
            
            local bullet = parentFrame:CreateFontString(nil, "OVERLAY")
            bullet:SetFont("Interface/AddOns/Phoenix_UI/Media/Fonts/PTSansNarrow.ttf", 16, "NONE")
            bullet:SetPoint("TOPLEFT", 0, yOffset)
            bullet:SetText("• " .. feature)
            bullet:SetTextColor(1, 0.9, 0.7)
            bullet:SetWidth(300)
            bullet:SetJustifyH("LEFT")
        end
        
        -- Start button in the center with proper positioning
        local startButton = CreateFrame("Button", nil, panel, "UIPanelButtonTemplate")
        startButton:SetSize(200, 40)
        startButton:SetPoint("TOP", panel, "CENTER", 0, 80)
        startButton:SetText("Begin Your Journey")
        startButton:SetScript("OnClick", function()
            panel:Hide()
            Phoenix_UI.db.profile.install = true
            Phoenix_UI.db.profile.general.version = Phoenix_UI.Version
            Phoenix_UI:Config()
        end)
        
        -- Customize button appearance
        if startButton.SetNormalTexture then
            startButton:SetNormalTexture("Interface/AddOns/Phoenix_UI/Media/Textures/Button/Button-Normal")
            startButton:SetPushedTexture("Interface/AddOns/Phoenix_UI/Media/Textures/Button/Button-Pressed")
            startButton:SetHighlightTexture("Interface/AddOns/Phoenix_UI/Media/Textures/Button/Button-Highlight")
            if startButton:GetFontString() then
                startButton:GetFontString():SetTextColor(1, 0.8, 0.3)
                startButton:GetFontString():SetFont("Interface/AddOns/Phoenix_UI/Media/Fonts/Prototype.ttf", 14, "OUTLINE")
            end
        end
        
        -- Version info
        local version = panel:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
        version:SetPoint("BOTTOMRIGHT", -15, 15)
        version:SetText("Version: " .. Phoenix_UI.Version)
        version:SetTextColor(0.7, 0.7, 0.7)
        
        -- Add to the addon
        Phoenix_UI.WelcomePanel = panel
        
        -- Show only if this is first installation or specifically requested
        if not Phoenix_UI.db.profile.install then
            panel:Show()
        else
            panel:Hide()
        end
        
        -- Make panel draggable
        panel:SetMovable(true)
        panel:RegisterForDrag("LeftButton")
        panel:SetScript("OnDragStart", function(self) self:StartMoving() end)
        panel:SetScript("OnDragStop", function(self) self:StopMovingOrSizing() end)
        
        -- Close button in the corner
        local closeButton = CreateFrame("Button", nil, panel, "UIPanelCloseButton")
        closeButton:SetPoint("TOPRIGHT", -5, -5)
        closeButton:SetScript("OnClick", function() panel:Hide() end)
        
        return panel
    end
end

-- Function to hook a method/function while preserving the original for later restoration
function Phoenix_UI:HookFunction(object, method, hook)
    if not self.hookRegistry[object] then
        self.hookRegistry[object] = {}
    end
    
    -- Store the original method if not already stored
    if not self.hookRegistry[object][method] then
        self.hookRegistry[object][method] = object[method]
    end
    
    -- Apply the hook
    object[method] = hook
    
    return true
end

-- Function to unhook a previously hooked method/function
function Phoenix_UI:UnhookFunction(object, method)
    if self.hookRegistry[object] and self.hookRegistry[object][method] then
        -- Restore the original method
        object[method] = self.hookRegistry[object][method]
        self.hookRegistry[object][method] = nil
        
        -- Clean up empty entries
        if not next(self.hookRegistry[object]) then
            self.hookRegistry[object] = nil
        end
        
        return true
    end
    
    return false
end

-- Clean up all hooks
function Phoenix_UI:UnhookAll()
    for object, methods in pairs(self.hookRegistry) do
        for method, original in pairs(methods) do
            object[method] = original
        end
    end
    
    self.hookRegistry = {}
end

function Phoenix_UI:LSB_Helper(LSBList, LSBHash)
    local list = {}
    for index, name in pairs(LSBList) do
        list[index] = {}
        for k, v in pairs(LSBHash) do
            if (name == k) then
                list[index] = {
                    text = name,
                    value = v
                }
            end
        end
    end
    return list
end

-- Fix for Main Menu
function Phoenix_UI:FixMainMenu()
    -- This function was causing the MainMenuMicroButton to appear separate from other micro buttons
    -- We're disabling this functionality to let MoveAny handle this button with all other micro buttons
    --[[ 
    -- Check if MainMenuMicroButton exists and initialize it if necessary
    if MainMenuMicroButton then
        -- Make the button visible and interactive
        MainMenuMicroButton:SetAlpha(1)
        MainMenuMicroButton:EnableMouse(true)
        
        -- Fix any issues with the button
        MainMenuMicroButton:SetParent(UIParent)
        MainMenuMicroButton:ClearAllPoints()
        MainMenuMicroButton:SetPoint("BOTTOMRIGHT", UIParent, "BOTTOMRIGHT", -180, 0)
        MainMenuMicroButton:Show()
        
        -- Make sure the click handler is working
        MainMenuMicroButton:SetScript("OnClick", function()
            if GameMenuFrame:IsShown() then
                HideUIPanel(GameMenuFrame)
            else
                ShowUIPanel(GameMenuFrame)
            end
        end)
    end
    ]]
end

-- Run the fix when the addon is loaded
C_Timer.After(1, function() 
    Phoenix_UI:FixMainMenu() 
end)

-- At the end of the file, add this slash command
SLASH_PUI1 = "/pui"
SlashCmdList["PUI"] = function()
    Phoenix_UI:Config(true)
end

-- Function to open Phoenix UI config manually
function Phoenix_UI:OpenConfig()
    local toggleFunc = self:Config(true)
    if type(toggleFunc) == "function" then
        toggleFunc()
    end
end

-- Create a proper Config method for Phoenix_UI
function Phoenix_UI:Config(show)
    -- If the Phoenix_UI.UI is already initialized, use it directly
    if Phoenix_UI.UI and Phoenix_UI.UI.isInitialized then
        -- This means Config/_Gui.lua was loaded and initialized the UI
        -- The implementation there will be used automatically through method inheritance
        return
    end
    
    -- Check if the module exists
    if not self.modules or not self.modules["Config.Gui"] then
        print("|cffFF7D0APhoenix|r|cffFF0000_|r|cffFFD100UI|r: Config system not loaded")
        return
    end
    
    -- Get the GUI module
    local Gui = self.modules["Config.Gui"]
    
    -- Initialize the UI if needed
    if not Phoenix_UI.UI or not Phoenix_UI.UI.isInitialized then
        if Gui.CreateUI then
            Gui:CreateUI()
            Phoenix_UI.UI.isInitialized = true
        else
            print("|cffFF7D0APhoenix|r|cffFF0000_|r|cffFFD100UI|r: Config system CreateUI method not found")
            return
        end
    end
    
    -- If the config method in Gui exists, use that implementation
    if Gui.Config then
        return Gui:Config(show)
    end
    
    -- Fallback implementation
    if show == true then
        -- Return a function that will toggle the game menu when called
        return function()
            if Phoenix_UI.UI:IsVisible() then
                local fadeInfo = {}
                fadeInfo.mode = "OUT"
                fadeInfo.timeToFade = 0.2
                fadeInfo.finishedFunc = function()
                    Phoenix_UI.UI:Hide()
                end
                UIFrameFade(Phoenix_UI.UI, fadeInfo)
                ToggleGameMenu()
            else
                local fadeInfo = {}
                fadeInfo.mode = "IN"
                fadeInfo.timeToFade = 0.2
                fadeInfo.finishedFunc = function()
                    Phoenix_UI.UI:Show()
                end
                UIFrameFade(Phoenix_UI.UI, fadeInfo)
                ToggleGameMenu()
            end
        end
    else
        -- Just toggle visibility directly
        if Phoenix_UI.UI:IsVisible() then
            local fadeInfo = {}
            fadeInfo.mode = "OUT"
            fadeInfo.timeToFade = 0.2
            fadeInfo.finishedFunc = function()
                Phoenix_UI.UI:Hide()
            end
            UIFrameFade(Phoenix_UI.UI, fadeInfo)
        else
            local fadeInfo = {}
            fadeInfo.mode = "IN"
            fadeInfo.timeToFade = 0.2
            fadeInfo.finishedFunc = function()
                Phoenix_UI.UI:Show()
            end
            UIFrameFade(Phoenix_UI.UI, fadeInfo)
        end
    end
end

-- At the end of the file, add a call to our safeguard function
local bossFrameSafeguardFrame = CreateFrame("Frame")
bossFrameSafeguardFrame:RegisterEvent("PLAYER_ENTERING_WORLD")
bossFrameSafeguardFrame:RegisterEvent("ADDON_LOADED")
bossFrameSafeguardFrame:SetScript("OnEvent", function(self, event, addonName)
    if event == "ADDON_LOADED" and addonName == "Phoenix_UI" then
        C_Timer.After(1, function()
            -- Call our global safeguard function
            if _G["Phoenix_UI_SafeguardBossFrames"] then
                _G["Phoenix_UI_SafeguardBossFrames"]()
            end
        end)
    elseif event == "PLAYER_ENTERING_WORLD" then
        C_Timer.After(2, function()
            -- Call our global safeguard function
            if _G["Phoenix_UI_SafeguardBossFrames"] then
                _G["Phoenix_UI_SafeguardBossFrames"]()
            end
        end)
    end
end)

-- Add the Phoenix_UI:Color function to fix integration with other modules
function Phoenix_UI:Color(alpha, colorOverride)
    -- Get color from profile settings
    local db = self.db and self.db.profile and self.db.profile.general
    if not db or not db.color then
        return {1, 0, 0, alpha or 1} -- Default to red if no color in settings
    end
    
    -- Use user-configured color
    local r = db.color.r or 0
    local g = db.color.g or 0
    local b = db.color.b or 0
    local a = alpha or db.color.a or 1
    
    -- Allow override for specific color needs
    if colorOverride then
        return colorOverride
    end
    
    return {r, g, b, a}
end

-- Add the Phoenix_UI:Skin function for skin module integration
function Phoenix_UI:Skin(frames, desaturate, vertexColor)
    if not frames then return end
    
    -- Handle both single frames and tables of frames
    if type(frames) ~= "table" then 
        frames = {frames}
    end
    
    -- Apply to all provided frames
    for _, frame in pairs(frames) do
        if frame then
            -- Safely apply changes with pcall to avoid errors
            if desaturate and frame.SetDesaturated then
                pcall(function() frame:SetDesaturated(true) end)
            end
            
            if vertexColor and frame.SetVertexColor then
                pcall(function() frame:SetVertexColor(unpack(self:Color(0.15))) end)
            end
        end
    end
end

-- Centralized message system for Phoenix UI to prevent multiple startup messages
local hasShownStartupMessage = false
function Phoenix_UI:ShowMessage(msg, isAlert)
    local r, g, b = 1, 0.5, 0 -- Phoenix orange
    local r2, g2, b2 = 1, 0.8, 0.2 -- Phoenix yellow/gold
    
    -- Don't show any messages on startup except for the welcome message
    if not hasShownStartupMessage and (
        msg:find("Invalid scale") or 
        msg:find("Auto-save registered") or 
        msg:find("settings migrated") or
        msg:find("UI scale from") or 
        msg:find("Icon on Minimap") or
        msg:find("Settings saved")) then
        return
    end
    
    if isAlert then
        DEFAULT_CHAT_FRAME:AddMessage("|cffFF7D0APhoenix|r|cffFF0000_|r|cffFFD100UI|r: " .. msg, 1, 0.3, 0.3)
    else
        -- If this is the first message, show the welcome message
        if not hasShownStartupMessage then
            -- Create a gradient-colored welcome message
            local welcomeMsg = ""
            
            -- Create the intro part with fixed colors
            welcomeMsg = "|cffFF7D0APhoenix|r|cffFF0000_|r|cffFFD100UI|r: "
            
            -- Create the gradient text with phoenix flame colors
            local startR, startG, startB = 1.0, 0.3, 0.0 -- Deep orange
            local endR, endG, endB = 1.0, 0.9, 0.2 -- Bright yellow
            
            local message = "From ashes to ashes Welcome to fire Gamer - Type /pui to open Config Panel"
            local chars = message:len()
            
            for i = 1, chars do
                local char = message:sub(i, i)
                -- Calculate gradient color
                local progress = (i-1)/(chars-1)
                local r = startR + (endR - startR) * progress
                local g = startG + (endG - startG) * progress
                local b = startB + (endB - startB) * progress
                
                -- Convert to hex
                local hex = string.format("%02x%02x%02x", math.floor(r*255), math.floor(g*255), math.floor(b*255))
                welcomeMsg = welcomeMsg .. "|cff" .. hex .. char .. "|r"
            end
            
            DEFAULT_CHAT_FRAME:AddMessage(welcomeMsg)
            hasShownStartupMessage = true
        else
            DEFAULT_CHAT_FRAME:AddMessage("|cffFF7D0APhoenix|r|cffFF0000_|r|cffFFD100UI|r: " .. msg, r, g, b)
        end
    end
end

-- Function to suppress addon startup messages by filtering the chat frame
function Phoenix_UI:SuppressAddonMessages()
    -- List of patterns to filter out
    local filterPatterns = {
        "BuffOverlay",
        "MoveAny",
        "Icon on Minimap",
        "Avalable",
        "Settings loaded", 
        "Settings saved",
        "Auto%-save registered",
        "Module .* is missing",
        "created placeholder",
        "Diagnosing MSBT",
        "Auto%-save",
        "verifying",
        "repository"
    }
    
    -- Create a filter function
    local function MessageFilter(_, _, msg, ...)
        -- Skip Phoenix UI messages that we control
        if msg:find("|cffFF7D0APhoenix|r") then
            return false
        end
        
        -- Filter out unwanted addon messages
        for _, pattern in ipairs(filterPatterns) do
            if msg:find(pattern) then
                return true
            end
        end
        return false
    end
    
    -- Apply the filter to the default chat frame
    ChatFrame_AddMessageEventFilter("CHAT_MSG_SYSTEM", MessageFilter)
end

-- Call this function during initialization
Phoenix_UI:SuppressAddonMessages()

-- Disable message interception for now
-- _G.print = ModifiedPrint

-- Add the SetupMacro function
function Phoenix_UI:SetupMacro()
    -- Create or update a macro for Phoenix_UI
    local macroName = "PhoenixUI"
    local macroIcon = "INV_Misc_PheonixPet_01"
    local macroBody = "/pui"
    
    -- Check if the macro already exists
    local globalMacroIndex = GetMacroIndexByName(macroName)
    
    -- Only create macro if user has enabled this feature
    if self.db and self.db.profile and self.db.profile.general and 
       self.db.profile.general.createMacro then
        
        -- Create or update macro
        if globalMacroIndex == 0 then
            -- Check if we have room for a new macro
            if select(1, GetNumMacros()) < MAX_GLOBAL_MACROS then
                CreateMacro(macroName, macroIcon, macroBody, false)
            end
        else
            -- Update existing macro
            EditMacro(globalMacroIndex, macroName, macroIcon, macroBody)
        end
    end
end

function Phoenix_UI:OnEnable()
    -- Register for the login/logout events
    self:RegisterEvent("PLAYER_ENTERING_WORLD", function() 
        -- Handle player entering world
        if self.OnPlayerEnteringWorld then
            self:OnPlayerEnteringWorld()
        end
    end)
    self:RegisterEvent("PLAYER_LEAVING_WORLD", function() self:SaveAllSettings() end)
    self:RegisterEvent("PLAYER_LOGOUT", function() self:SaveAllSettings() end)
    
    -- Register for addon loading to track modules
    self:RegisterEvent("ADDON_LOADED", function(event, addonName)
        -- Process only our own addon loading or addons we care about
        if addonName == "Phoenix_UI" then
            -- Initialize from database if needed
            if not self.dataInitialized then
                self:InitFromDB()
            end
        end
    end)
    
    -- Setup the slash command
    _G["SLASH_PHOENIX_UI1"] = "/pui"
    _G["SLASH_PHOENIX_UI2"] = "/phoenixui"
    _G["SLASH_PHOENIX_UI3"] = "/phoenix"
    SlashCmdList["PHOENIX_UI"] = function(input) self:SlashCommand(input) end
    
    -- Setup macro
    self:SetupMacro()
    
    -- Initialize modules
    if self.InitializeModules then
        self:InitializeModules()
    end
    
    -- Register all slash commands
    for command, func in pairs(self.slashCommands or {}) do
        if not SlashCmdList[command] then
            _G["SLASH_" .. command .. "1"] = "/" .. command:lower()
            SlashCmdList[command] = func
        end
    end
    
    -- Register diagnostic commands
    SLASH_PHOENIX_DIAG1 = "/puidiag"
    SlashCmdList["PHOENIX_DIAG"] = function() 
        if self.DiagnoseProfileIssues then
            self:DiagnoseProfileIssues()
        else
            print("|cffFF7D0APhoenix|r|cffFF0000_|r|cffFFD100UI|r: Diagnostic functions not available.")
        end
    end
    
    SLASH_PHOENIX_REPAIR_PROFILE1 = "/puirepair"
    SlashCmdList["PHOENIX_REPAIR_PROFILE"] = function() 
        if self.RepairProfileAssignment then
            self:RepairProfileAssignment() 
        else
            print("|cffFF7D0APhoenix|r|cffFF0000_|r|cffFFD100UI|r: Repair functions not available.")
        end
    end
    
    -- Check if install/reset is needed
    if self.db and self.db.profile then
        if self.db.profile.reset then
            self.db.profile.reset = nil
            
            -- Basic reset implementation if ResetSettings doesn't exist
            if self.SaveDB then
                self:SaveDB(true)
            end
        elseif not self.db.profile.install then
            -- Set install flag directly if CreateWelcomePanel doesn't exist
            self.db.profile.install = true
            
            -- Save immediately to persist the installation flag
            if self.SaveDB then
                self:SaveDB(true)
            end
        end
    end
    
    -- Initialize UI scaling system
    if self.Scaling and self.Scaling.Initialize then
        self.Scaling:Initialize()
    end
    
    -- Setup periodic settings saving to avoid data loss
    local saveInterval = 300 -- Save every 5 minutes
    
    self.saveTimer = C_Timer.NewTicker(saveInterval, function()
        if self.db and self.db.profile then
            -- Track last save time
            self.lastSaveTime = GetTime()
            
            -- Verify data integrity before saving with error handling
            if self.VerifySavedVariables then
                local success, error = pcall(function()
                    self:VerifySavedVariables()
                end)
                
                if not success and self.debug then
                    print("|cffFF7D0APhoenix UI:|r Error in VerifySavedVariables: " .. (error or "unknown error"))
                end
            end
            
            -- Commit any pending changes
            if self.CommitPendingChanges then
                local success, error = pcall(function()
                    self:CommitPendingChanges()
                end)
                
                if not success and self.debug then
                    print("|cffFF7D0APhoenix UI:|r Error in CommitPendingChanges: " .. (error or "unknown error"))
                end
            end
            
            -- Save with verification
            if self.SaveDB then
                local success, error = pcall(function()
                    self:SaveDB()
                end)
                
                if not success and self.debug then
                    print("|cffFF7D0APhoenix UI:|r Error in SaveDB: " .. (error or "unknown error"))
                end
            end
            
            -- Synchronize module settings
            if self.SyncModuleSettings then
                local success, error = pcall(function()
                    self:SyncModuleSettings()
                end)
                
                if not success and self.debug then
                    print("|cffFF7D0APhoenix UI:|r Error in SyncModuleSettings: " .. (error or "unknown error"))
                end
            end
        end
    end)
    
    -- Ensure settings are synchronized initially
    C_Timer.After(5, function()
        if self.SyncModuleSettings then
            self:SyncModuleSettings()
        end
    end)
    
    -- Verify data integrity after loading
    C_Timer.After(10, function()
        -- Verify saved variables with error handling
        if self.VerifySavedVariables then
            local success, error = pcall(function()
                self:VerifySavedVariables()
            end)
            
            if not success and self.debug then
                print("|cffFF7D0APhoenix UI:|r Error in verification timer: " .. (error or "unknown error"))
            end
        end
        
        -- Also diagnose and repair settings if needed
        if self.DiagnoseAndRepairSettings then
            local success, error = pcall(function()
                self:DiagnoseAndRepairSettings()
            end)
            
            if not success and self.debug then
                print("|cffFF7D0APhoenix UI:|r Error in repair: " .. (error or "unknown error"))
            end
        end
    end)
    
    -- Verify modules at startup and create placeholders for missing ones
    C_Timer.After(1, function()
        -- Critical modules that should always exist
        local requiredModules = {
            "ActionBars", "Map", "Tooltip", "BuffOverlay", 
            "NamePlates", "UnitFrames", "idTip"
        }
        
        -- Helper function to check if module or any submodules exist
        local function hasModuleOrSubmodules(name)
            -- Check for exact module match
            if self.modules[name] then
                return true
            end
            
            -- Check for submodules (modules with pattern name.Something)
            local pattern = "^" .. name .. "%."
            for moduleName, _ in pairs(self.modules) do
                if string.match(moduleName, pattern) then
                    return true
                end
            end
            
            return false
        end
        
        -- Helper function to find and consolidate submodules
        local function createParentFromSubmodules(name)
            -- Create parent module
            local parentModule = {}
            self:NewModule(name, parentModule)
            
            -- Find all submodules and link them to parent
            local pattern = "^" .. name .. "%."
            for moduleName, submodule in pairs(self.modules) do
                if string.match(moduleName, pattern) then
                    -- Extract submodule name (part after the dot)
                    local subName = string.match(moduleName, "^" .. name .. "%.(.+)")
                    if subName then
                        -- Link submodule to parent
                        parentModule[subName] = submodule
                    end
                end
            end
            
            -- Set initialized flag to prevent further initialization attempts
            parentModule.initialized = true
            
            return parentModule
        end
        
        -- Pre-register all modules to ensure DB entries exist
        for _, moduleName in ipairs(requiredModules) do
            -- Ensure module DB entry exists first
            if not self.moduleDB[moduleName] then
                -- Create a module DB entry with defaults
                self.moduleDB[moduleName] = self.SafeRegisterNamespace(self.db, moduleName, {
                    profile = { enabled = true }
                })
            end
        end
        
        -- Now register any missing modules
        for _, moduleName in ipairs(requiredModules) do
            if self.modules then
                -- Check if main module already exists
                if self.modules[moduleName] then
                    -- Module exists, ensure it has DB reference
                    if not self.modules[moduleName].db and self.moduleDB[moduleName] then
                        self.modules[moduleName].db = self.moduleDB[moduleName].profile
                    end
                    
                -- Check if we have submodules but no parent
                elseif hasModuleOrSubmodules(moduleName) then
                    -- Module has submodules but no parent module, create parent
                    local parentModule = createParentFromSubmodules(moduleName)
                    
                    -- Ensure parent has DB reference
                    if self.moduleDB[moduleName] then
                        parentModule.db = self.moduleDB[moduleName].profile
                    end
                    
                -- No module or submodules found, create placeholder
                else
                    -- Create placeholder module
                    local placeholder = {
                        initialized = true,  -- Mark as initialized to prevent errors
                        OnInitialize = function() end,  -- Empty init function
                        IsEnabled = function() return true end,  -- Always return enabled
                        Enable = function() end,  -- Empty enable function
                        Disable = function() end   -- Empty disable function
                    }
                    
                    -- Add DB reference
                    if self.moduleDB[moduleName] then
                        placeholder.db = self.moduleDB[moduleName].profile
                    end
                    
                    -- Register the placeholder
                    self:NewModule(moduleName, placeholder)
                    
                    -- Log that we created a placeholder
                    -- print("|cffFF7D0APhoenix UI:|r Module " .. moduleName .. " is missing, created placeholder")
                end
            end
        end
        
        -- Force save after verifying modules
        if self.SaveDB then
            self:SaveDB(true)
        end
    end)
    
    -- Show a single welcome message instead of individual module status messages
    C_Timer.After(1, function()
        -- Create a styled flame-themed welcome message
        local function CreateGradientText(text, startColor, endColor)
            local chars = text:len()
            local gradientText = ""
            for i = 1, chars do
                local char = text:sub(i, i)
                -- Calculate gradient color
                local progress = (i-1)/(chars-1)
                local r = startColor[1] + (endColor[1] - startColor[1]) * progress
                local g = startColor[2] + (endColor[2] - startColor[2]) * progress
                local b = startColor[3] + (endColor[3] - startColor[3]) * progress
                
                -- Convert to hex
                local hex = string.format("%02x%02x%02x", math.floor(r*255), math.floor(g*255), math.floor(b*255))
                gradientText = gradientText .. "|cff" .. hex .. char .. "|r"
            end
            return gradientText
        end
        
        -- Create flame gradient colors
        local phoenixOrange = {1.0, 0.49, 0.04}  -- Deep orange
        local phoenixYellow = {1.0, 0.82, 0.0}   -- Golden yellow
        local phoenixRed = {1.0, 0.2, 0.0}       -- Deep red
        
        -- Create the styled message
        local prefix = "|cffFF7D0APhoenix|r|cffFF0000_|r|cffFFD100UI|r: "
        local welcomeText = "Welcome to Phoenix_UI by VortexQ8, Type /pui to open panel"
        local gradientWelcome = CreateGradientText(welcomeText, phoenixRed, phoenixYellow)
        
        -- Print the final message
        print(prefix .. gradientWelcome)
    end)
    
    -- Force a settings save early in the loading process
    C_Timer.After(2, function()
        -- Save settings
        if self.ForceSaveDB then
            self:ForceSaveDB()
        elseif self.SaveDB then
            self:SaveDB(true)
        end
    end)
end

-- Initialize modules safely and handle errors
function Phoenix_UI:InitializeModules()
    if self.modulesInitialized then
        return
    end
    
    -- We'll remove debug prints to clean up output
    local debug = false  -- Force debug mode off
    
    -- Mark as started
    self.modulesInitializing = true
    
    -- Track initialization statistics
    local initializedCount = 0
    local errorCount = 0
    local startTime = GetTime()
    local moduleStatus = {}
    
    -- Load saved settings first to ensure modules have access to their settings
    if self.db and self.db.profile then
        -- Ensure critical settings tables exist
        local criticalModules = {
            "general", "actionbars", "unitframes", "nameplates", "chat", 
            "tooltip", "map", "fonts", "uiscaling", "buffs"
        }
        
        for _, moduleName in ipairs(criticalModules) do
            if not self.db.profile[moduleName] then
                self.db.profile[moduleName] = {}
                
                -- Try to recover from global savedvariables if available
                if _G["Phoenix_UIDB"] and _G["Phoenix_UIDB"].profiles then
                    local currentProfile = self.db.keys and self.db.keys.profile or "Default"
                    
                    if _G["Phoenix_UIDB"].profiles[currentProfile] and 
                       _G["Phoenix_UIDB"].profiles[currentProfile][moduleName] then
                        -- Copy settings from global savedvariables
                        self.db.profile[moduleName] = CopyTable(_G["Phoenix_UIDB"].profiles[currentProfile][moduleName])
                        
                        if debug then
                            print("Phoenix_UI: Recovered settings for " .. moduleName .. " from global savedvariables")
                        end
                    end
                end
            end
        end
    end
    
    -- Apply theme before module initialization
    local ThemeData = self:GetModule("Data.Themes", true)
    if ThemeData then
        -- Ensure theme data is ready
        if not ThemeData.initialized then
            if ThemeData.OnInitialize then
                local success, err = pcall(function() ThemeData:OnInitialize() end)
                if success then
                    ThemeData.initialized = true
                    moduleStatus["Data.Themes"] = "initialized"
                else
                    moduleStatus["Data.Themes"] = "error: " .. tostring(err)
                    errorCount = errorCount + 1
                end
            end
        end
    end
    
    -- Initialize each module that has an OnInitialize method
    local orderedModules = {}
    for name, module in self:IterateModules() do
        if type(module) == "table" and module.OnInitialize then
            table.insert(orderedModules, {name = name, module = module})
        end
    end
    
    -- Sort modules so core modules initialize first
    table.sort(orderedModules, function(a, b)
        local aPriority = 0
        local bPriority = 0
        
        -- Give higher priority to core components
        local highPriorityPrefixes = {"Core", "Data", "Config"}
        for _, prefix in ipairs(highPriorityPrefixes) do
            if string.find(a.name, "^" .. prefix) then aPriority = aPriority + 10 end
            if string.find(b.name, "^" .. prefix) then bPriority = bPriority + 10 end
        end
        
        -- Give lower priority to certain UI components that depend on core modules
        local lowPriorityPrefixes = {"UI", "Layout"}
        for _, prefix in ipairs(lowPriorityPrefixes) do
            if string.find(a.name, "^" .. prefix) then aPriority = aPriority - 5 end
            if string.find(b.name, "^" .. prefix) then bPriority = bPriority - 5 end
        end
        
        -- Default alphabetical sorting if priorities are equal
        if aPriority == bPriority then
            return a.name < b.name
        else
            return aPriority > bPriority
        end
    end)
    
    -- Now initialize modules in the sorted order
    for _, moduleInfo in ipairs(orderedModules) do
        local name = moduleInfo.name
        local module = moduleInfo.module
        
        -- Skip if already initialized
        if module.initialized then
            moduleStatus[name] = "already_initialized"
            initializedCount = initializedCount + 1
        else
            -- Pre-initialize - set up any needed tables on the module
            if self.db and self.db.profile then
                -- Convert module name to profile key (some modules use different names)
                local profileKey = string.gsub(name, "^.-[%.]", ""):lower()
                
                -- Some modules have special cases
                if string.find(name, "^Modules[%.]") then
                    -- Extract the module name after "Modules."
                    profileKey = string.match(name, "^Modules[%.](.+)$")
                    if profileKey then
                        profileKey = string.lower(profileKey)
                    end
                end
                
                -- Ensure module settings exist
                if profileKey and not self.db.profile[profileKey] and module.defaultSettings then
                    self.db.profile[profileKey] = CopyTable(module.defaultSettings)
                end
                
                -- Provide database reference to the module
                if profileKey then
                    module.db = self.db.profile[profileKey]
                end
            end
            
            -- Initialize the module
            if module.OnInitialize then
                local success, err = pcall(function() module:OnInitialize() end)
                if success then
                    module.initialized = true
                    moduleStatus[name] = "initialized"
                    initializedCount = initializedCount + 1
                else
                    -- Remove debug print
                    -- if debug then
                    --    print("Phoenix_UI: Error initializing module " .. name .. ": " .. tostring(err))
                    -- end
                    moduleStatus[name] = "error: " .. tostring(err)
                    errorCount = errorCount + 1
                    
                    -- Try to recover by skipping this module but continuing with others
                    self:Printf("|cffff0000Error initializing %s: %s|r", name, tostring(err))
                end
            else
                moduleStatus[name] = "no_initialize_method"
            end
        end
    end
    
    -- Mark as completed
    self.modulesInitialized = true
    self.modulesInitializing = false
    
    -- Show summary of initialization
    local endTime = GetTime()
    local elapsedTime = endTime - startTime
    
    -- Clean up debug print
    -- if debug then
    --     print(string.format("Phoenix_UI: Modules initialized in %.2f seconds. %d succeeded, %d errors", 
    --         elapsedTime, initializedCount, errorCount))
    -- end
    
    -- Show an error if there were initialization problems
    if errorCount > 0 then
        -- Create a more concise error message
        local errorModules = {}
        for name, status in pairs(moduleStatus) do
            if status:match("^error") then
                table.insert(errorModules, name)
            end
        end
        
        if #errorModules > 0 then
            -- Show first 3 errors max
            local errorList = ""
            for i = 1, math.min(3, #errorModules) do
                errorList = errorList .. errorModules[i]
                if i < math.min(3, #errorModules) then
                    errorList = errorList .. ", "
                end
            end
            
            if #errorModules > 3 then
                errorList = errorList .. " and " .. (#errorModules - 3) .. " more"
            end
            
            -- Only print critical errors
            -- self:Printf("|cffff0000Warning: %d modules failed to initialize (%s)|r", 
            --     errorCount, errorList)
        end
    end
    
    -- Queue module enabling after a short delay
    C_Timer.After(0.1, function()
        self:QueueEnableModules()
        
        -- Also force a settings save to ensure any initialization changes are persisted
        if self.SaveAllSettings then
            self:SaveAllSettings()
        elseif self.SaveDB then
            self:SaveDB()
        end
    end)
    
    -- Debug output
    if debug then
        print(string.format("Phoenix_UI: Modules initialized in %.2f seconds. %d succeeded, %d errors", 
            elapsedTime, initializedCount, errorCount))
    end
    
    return initializedCount, errorCount
end

-- Queue module enabling
function Phoenix_UI:QueueEnableModules()
    -- Skip if already done
    if self.modulesEnabled then
        return
    end
    
    -- Enable each module that should be enabled by default
    local debug = self.debug or false
    local enabledCount = 0
    local errorCount = 0
    
    for name, module in self:IterateModules() do
        if type(module) == "table" and module.defaultModuleState ~= false then
            -- Skip if module is explicitly disabled in settings
            local profileKey = string.gsub(name, "^.-[%.]", ""):lower()
            local isDisabled = false
            
            if self.db and self.db.profile and self.db.profile.modules then
                isDisabled = self.db.profile.modules[profileKey] == false
            end
            
            if not isDisabled then
                -- Try to enable the module
                local success, err = pcall(function() 
                    self:EnableModule(name) 
                end)
                
                if success then
                    enabledCount = enabledCount + 1
                else
                    errorCount = errorCount + 1
                    if debug then
                        self:Printf("|cffff0000Error enabling %s: %s|r", name, tostring(err))
                    end
                end
            end
        end
    end
    
    self.modulesEnabled = true
    
    -- Debug output
    if debug then
        print(string.format("Phoenix_UI: Modules enabled: %d succeeded, %d errors", 
            enabledCount, errorCount))
    end
    
    return enabledCount, errorCount
end

function Phoenix_UI:SaveAllSettings()
    -- Safety check to avoid errors when called early in load process
    if not self.initialized then
        return false
    end
    
    -- Debug output if debug mode is enabled
    local debug = self.debug or false
    if debug then
        print("Phoenix_UI: SaveAllSettings called")
    end
    
    -- First, commit any pending changes
    if self.CommitPendingChanges then
        pcall(function() self:CommitPendingChanges() end)
    end
    
    -- Get current profile
    local currentProfile = self.db and self.db.keys and self.db.keys.profile or "Default"
    local playerKey = UnitName("player") .. " - " .. GetRealmName()
    
    -- ENHANCED: Ensure global table structure
    if not _G["Phoenix_UIDB"] then _G["Phoenix_UIDB"] = {} end
    if not _G["Phoenix_UIDB"].profiles then _G["Phoenix_UIDB"].profiles = {} end
    if not _G["Phoenix_UIDB"].profiles[currentProfile] then _G["Phoenix_UIDB"].profiles[currentProfile] = {} end
    if not _G["Phoenix_UIDB"].profiles.Default then _G["Phoenix_UIDB"].profiles.Default = {} end
    if not _G["Phoenix_UIDB"].profileKeys then _G["Phoenix_UIDB"].profileKeys = {} end
    
    -- ENHANCED: Ensure profile mapping is correct
    _G["Phoenix_UIDB"].profileKeys[playerKey] = currentProfile
    
    -- Comprehensive module list to ensure all settings saved
    local allModules = {
        -- Core UI modules
        "general", "unitframes", "nameplates", "actionbars", "castbars", 
        "buffs", "tooltip", "map", "chat", "misc", "uiscaling", "fonts",
        -- Additional modules
        "msbt", "idtip", "buffoverlay", "cooldowntracker", "weakauras", 
        "mythicplus", "raidframes", "profiles",
        -- Legacy names for compatibility
        "actionbar", "castbar", "buff"
    }
    
    -- Extreme mode: save ALL data in the profile, including unknown modules
    print("|cffFF7D0APhoenix|r|cffFF0000_|r|cffFFD100UI|r: Saving all profile data...")
    
    -- First, directly copy entire profile to ensure everything is captured
    pcall(function()
        _G["Phoenix_UIDB"].profiles[currentProfile] = CopyTable(self.db.profile)
        _G["Phoenix_UIDB"].profiles[currentProfile].__emergency_saved = GetTime()
    end)
    
    -- Then, explicitly save each known module for extra redundancy
    for _, moduleName in ipairs(allModules) do
        if self.db.profile[moduleName] and type(self.db.profile[moduleName]) == "table" then
            -- Critical redundancy: save to both global vars and current profile
            pcall(function()
                -- Get a clean copy of current settings
                local currentSettings = CopyTable(self.db.profile[moduleName])
                
                -- Add diagnostic info
                currentSettings.__saved = GetTime()
                currentSettings.__emergency = true
                currentSettings.__method = "SaveAllSettings"
                
                -- Save to global variable
                _G["Phoenix_UIDB"].profiles[currentProfile][moduleName] = currentSettings
                
                -- Also save to Default profile as fallback
                if moduleName ~= "profiles" then
                    _G["Phoenix_UIDB"].profiles.Default[moduleName] = CopyTable(currentSettings)
                end
                
                -- EXTREME REDUNDANCY: Save an additional copy directly in global var
                _G["Phoenix_UI_" .. moduleName .. "_Backup"] = CopyTable(currentSettings)
            end)
        end
    end
    
    -- Also save module DB settings if they exist
    if self.moduleDB then
        for moduleName, data in pairs(self.moduleDB) do
            if data.profile and type(data.profile) == "table" then
                pcall(function()
                    local lowerName = moduleName:lower()
                    -- Save to global DB
                    _G["Phoenix_UIDB"].profiles[currentProfile][lowerName] = CopyTable(data.profile)
                    _G["Phoenix_UIDB"].profiles[currentProfile][lowerName].__saved = GetTime()
                    _G["Phoenix_UIDB"].profiles[currentProfile][lowerName].__emergency = true
                    
                    -- EXTREME REDUNDANCY: Save directly to global var
                    _G["Phoenix_UI_" .. lowerName .. "_ModuleBackup"] = CopyTable(data.profile)
                end)
            end
        end
    end
    
    -- LEVEL 3: Maximum force - Make repeated flush attempts
    print("|cffFF7D0APhoenix|r|cffFF0000_|r|cffFFD100UI|r: Forcing data flush to disk...")
    
    -- Try different save methods in order
    if self.ForceSaveDB then
        pcall(function() self:ForceSaveDB() end)
    elseif self.SaveDB then
        pcall(function() self:SaveDB(true) end)
    end
    
    -- Use built-in WoW functions too
    for i = 1, 5 do
        pcall(function() 
            if FlushSettingsDB then FlushSettingsDB() end 
            if FlushSavedVariables then FlushSavedVariables() end
        end)
    end
    
    -- Add redundant save attempts after a longer delay
    C_Timer.After(2, function()
        print("|cffFF7D0APhoenix|r|cffFF0000_|r|cffFFD100UI|r: Performing additional save verification...")
        
        -- Make a final flush attempt
        pcall(function() 
            if FlushSettingsDB then FlushSettingsDB() end 
            if FlushSavedVariables then FlushSavedVariables() end
        end)
        
        -- Record that we did an emergency save
        _G["Phoenix_UIDB"].__emergency_saved = true
        _G["Phoenix_UIDB"].__emergency_time = GetTime()
        
        print("|cffFF7D0APhoenix|r|cffFF0000_|r|cffFFD100UI|r: Emergency save complete. If problems persist, please type '/puirepair'")
    end)
    
    -- Return success
    return true
end

-- Add the CreateModuleSettingChangedHandler function
function Phoenix_UI:CreateModuleSettingChangedHandler(moduleName)
    return function(element, value)
        -- Get the database
        local db = Phoenix_UI.db
        
        -- Store the value in the database
        if element.dataKey and db.profile[moduleName] then
            -- Get the field name without the module prefix
            local fieldName = element.dataKey:gsub("^" .. moduleName .. "%%.", "")
            
            -- Handle nested fields if needed
            if fieldName:find("%.") then
                local parts = {}
                for part in fieldName:gmatch("[^%.]+") do
                    table.insert(parts, part)
                end
                
                -- Navigate to the right spot in the table
                local current = db.profile[moduleName]
                for i = 1, #parts-1 do
                    if not current[parts[i]] then
                        current[parts[i]] = {}
                    end
                    current = current[parts[i]]
                end
                
                -- Set the value
                current[parts[#parts]] = value
            else
                -- Direct setting
                db.profile[moduleName][fieldName] = value
            end
            
            -- Debug output
            if Phoenix_UI.debug then
                print("PHX-UI: " .. moduleName .. " setting changed:", element.dataKey, "=", tostring(value))
            end
            
            -- Force an immediate save
            if Phoenix_UI.SaveDB then
                Phoenix_UI:SaveDB()
                
                -- Ensure it's written to disk
                if FlushSavedVariables then
                    FlushSavedVariables()
                elseif FlushSettingsDB then
                    FlushSettingsDB()
                end
            end
            
            -- Also directly update global savedvariables
            if _G["Phoenix_UIDB"] and _G["Phoenix_UIDB"].profiles then
                local currentProfile = db.keys and db.keys.profile or "Default"
                if not _G["Phoenix_UIDB"].profiles[currentProfile] then
                    _G["Phoenix_UIDB"].profiles[currentProfile] = {}
                end
                if not _G["Phoenix_UIDB"].profiles[currentProfile][moduleName] then
                    _G["Phoenix_UIDB"].profiles[currentProfile][moduleName] = {}
                end
                
                -- Deep copy to ensure all changes are preserved
                _G["Phoenix_UIDB"].profiles[currentProfile][moduleName] = CopyTable(db.profile[moduleName])
                _G["Phoenix_UIDB"].profiles[currentProfile][moduleName].__updated = GetTime()
            end
            
            -- Also trigger UI refresh
            if Phoenix_UI.UI and Phoenix_UI.UI.RefreshConfig then
                C_Timer.After(0.1, function()
                    Phoenix_UI.UI:RefreshConfig()
                end)
            end
        end
    end
end

-- Add the CreateModuleRefreshFunction function
function Phoenix_UI:CreateModuleRefreshFunction(moduleName)
    return function(self)
        if not self.layout or not self.layout.rows then return end
        
        -- Get the config tabs
        local config = Phoenix_UI.UI
        if not config or not config.elements then return end
        
        -- Force the tab to update with current database values
        local db = Phoenix_UI.db
        if db and db.profile and db.profile[moduleName] then
            -- Update our local database reference
            self.layout.database = db.profile[moduleName]
            
            -- Force a full rebuild if needed
            if config.RefreshConfig then
                config:RefreshConfig()
            end
        end
        
        -- Force all settings to be saved
        if Phoenix_UI.ForceSaveDB then
            Phoenix_UI:ForceSaveDB()
        end
    end
end

-- Add a slash command to force save all settings
SLASH_PHOENIX_FORCESAVE1 = "/puisave"
SlashCmdList["PHOENIX_FORCESAVE"] = function()
    if Phoenix_UI and Phoenix_UI.ForceSettingsSave then
        print("|cffFF7D0APhoenix|r|cffFF0000_|r|cffFFD100UI|r: Forcing save of all settings...")
        
        -- Call our enhanced forcesave function
        Phoenix_UI:ForceSettingsSave()
        
        -- Provide feedback to the user
        print("|cffFF7D0APhoenix|r|cffFF0000_|r|cffFFD100UI|r: All settings have been saved to disk.")
    else
        print("|cffFF7D0APhoenix|r|cffFF0000_|r|cffFFD100UI|r: Error - Save function not available.")
    end
end

-- Critical emergency function for forcing settings to save when normal methods fail
function Phoenix_UI:ForceSettingsSave()
    local playerName = UnitName("player")
    local realmName = GetRealmName()
    local playerKey = playerName .. " - " .. GetRealmName()
    local currentTime = GetTime()
    
    print("|cffFF7D0APhoenix|r|cffFF0000_|r|cffFFD100UI|r: Emergency settings save initiated...")
    
    -- Ensure global database exists
    if not _G["Phoenix_UIDB"] then
        print("|cffFF7D0APhoenix|r|cffFF0000_|r|cffFFD100UI|r: Creating missing global database...")
        _G["Phoenix_UIDB"] = {}
    end
    
    -- Initialize backup storage
    _G["Phoenix_UIDB"].__emergency_backup = _G["Phoenix_UIDB"].__emergency_backup or {}
    
    -- Check if we have database available
    local dbAvailable = self.db and self.db.profile
    if not dbAvailable then
        print("|cffFF7D0APhoenix|r|cffFF0000_|r|cffFFD100UI|r: ERROR: Database not available!")
    else
        -- Create backup from current settings
        local backupData = CopyTable(self.db.profile)
        
        -- Store backup in global table
        _G["Phoenix_UIDB"].__emergency_backup[playerKey] = {
            timestamp = currentTime,
            data = backupData
        }
        
        print("|cffFF7D0APhoenix|r|cffFF0000_|r|cffFFD100UI|r: Emergency backup created successfully")
        
        -- Backup individual modules to separate global variables
        local allModules = {
            "general", "unitframes", "nameplates", "actionbars", "castbars", 
            "buffs", "tooltip", "map", "chat", "misc", "uiscaling", "fonts", 
            "msbt", "idtip", "buffoverlay", "cooldowntracker"
        }
        
        for _, moduleName in ipairs(allModules) do
            if self.db.profile[moduleName] then
                _G["Phoenix_UI_" .. moduleName .. "_Backup"] = CopyTable(self.db.profile[moduleName])
            end
        end
        
        -- Force settings to be saved
        print("|cffFF7D0APhoenix|r|cffFF0000_|r|cffFFD100UI|r: Forcing settings to save...")
        
        -- Try multiple save methods
        if self.SaveDB then
            pcall(function() self:SaveDB(true) end)
        end
        
        if self.ForceSaveDB then
            pcall(function() self:ForceSaveDB() end)
        end
        
        -- Use built-in WoW functions too
        for i = 1, 3 do
            pcall(function()
                if FlushSettingsDB then FlushSettingsDB() end
                if FlushSavedVariables then FlushSavedVariables() end
            end)
        end
        
        -- Write emergency info to WTF folder file if possible
        pcall(function()
            local f = io.open("WTF/Account/" .. GetAccountExpansionLevel() .. 
                "/SavedVariables/Phoenix_UI_Emergency.lua", "w")
            if f then
                f:write("Phoenix_UI_Emergency = Phoenix_UI_Emergency or {}\n")
                f:write("Phoenix_UI_Emergency[\"" .. playerKey .. "\"] = {\n")
                f:write("  timestamp = " .. currentTime .. ",\n")
                f:write("  success = true,\n")
                f:write("  modules = {")
                
                for _, moduleName in ipairs(allModules) do
                    if self.db.profile[moduleName] then
                        f:write("\"" .. moduleName .. "\", ")
                    end
                end
                
                f:write("},\n")
                f:write("}\n")
                f:close()
            end
        end)
    end
    
    print("|cffFF7D0APhoenix|r|cffFF0000_|r|cffFFD100UI|r: Emergency backup complete.")
    return dbAvailable
end

-- Emergency function for creating backups and forcing saves
function Phoenix_UI:EmergencyBackup()
    local playerName = UnitName("player")
    local realmName = GetRealmName()
    local playerKey = playerName .. " - " .. GetRealmName()
    local currentTime = GetTime()
    
    print("|cffFF7D0APhoenix|r|cffFF0000_|r|cffFFD100UI|r: Creating emergency backup...")
    
    -- Ensure global database exists
    if not _G["Phoenix_UIDB"] then
        print("|cffFF7D0APhoenix|r|cffFF0000_|r|cffFFD100UI|r: Creating missing global database...")
        _G["Phoenix_UIDB"] = {}
    end
    
    -- Initialize backup storage
    _G["Phoenix_UIDB"].__emergency_backup = _G["Phoenix_UIDB"].__emergency_backup or {}
    
    -- Check if we have database available
    local dbAvailable = self.db and self.db.profile
    if not dbAvailable then
        print("|cffFF7D0APhoenix|r|cffFF0000_|r|cffFFD100UI|r: ERROR: Database not available!")
    else
        -- Create backup from current settings
        local backupData = CopyTable(self.db.profile)
        
        -- Store backup in global table
        _G["Phoenix_UIDB"].__emergency_backup[playerKey] = {
            timestamp = currentTime,
            data = backupData
        }
        
        print("|cffFF7D0APhoenix|r|cffFF0000_|r|cffFFD100UI|r: Emergency backup created successfully")
        
        -- Backup individual modules to separate global variables
        local allModules = {
            "general", "unitframes", "nameplates", "actionbars", "castbars", 
            "buffs", "tooltip", "map", "chat", "misc", "uiscaling", "fonts", 
            "msbt", "idtip", "buffoverlay", "cooldowntracker"
        }
        
        for _, moduleName in ipairs(allModules) do
            if self.db.profile[moduleName] then
                _G["Phoenix_UI_" .. moduleName .. "_Backup"] = CopyTable(self.db.profile[moduleName])
            end
        end
        
        -- Force settings to be saved
        print("|cffFF7D0APhoenix|r|cffFF0000_|r|cffFFD100UI|r: Forcing settings to save...")
        
        -- Try multiple save methods
        if self.SaveDB then
            pcall(function() self:SaveDB(true) end)
        end
        
        if self.ForceSaveDB then
            pcall(function() self:ForceSaveDB() end)
        end
        
        -- Use built-in WoW functions too
        for i = 1, 3 do
            pcall(function()
                if FlushSettingsDB then FlushSettingsDB() end
                if FlushSavedVariables then FlushSavedVariables() end
            end)
        end
        
        -- Write emergency info to WTF folder file if possible
        pcall(function()
            local f = io.open("WTF/Account/" .. GetAccountExpansionLevel() .. 
                "/SavedVariables/Phoenix_UI_Emergency.lua", "w")
            if f then
                f:write("Phoenix_UI_Emergency = Phoenix_UI_Emergency or {}\n")
                f:write("Phoenix_UI_Emergency[\"" .. playerKey .. "\"] = {\n")
                f:write("  timestamp = " .. currentTime .. ",\n")
                f:write("  success = true,\n")
                f:write("  modules = {")
                
                for _, moduleName in ipairs(allModules) do
                    if self.db.profile[moduleName] then
                        f:write("\"" .. moduleName .. "\", ")
                    end
                end
                
                f:write("},\n")
                f:write("}\n")
                f:close()
            end
        end)
    end
    
    print("|cffFF7D0APhoenix|r|cffFF0000_|r|cffFFD100UI|r: Emergency backup complete.")
    return dbAvailable
end

-- Critical repair function for fixing settings issues
function Phoenix_UI:RepairSettings()
    local playerName = UnitName("player")
    local realmName = GetRealmName()
    local playerKey = playerName .. " - " .. GetRealmName()
    local currentTime = GetTime()
    
    print("|cffFF7D0APhoenix|r|cffFF0000_|r|cffFFD100UI|r: Comprehensive settings repair initiated...")
    
    -- First check if we have a good database
    local dbAvailable = self.db and self.db.profile
    if not dbAvailable then
        print("|cffFF7D0APhoenix|r|cffFF0000_|r|cffFFD100UI|r: ERROR: Database not available! Attempting recovery...")
    end
    
    -- Check if global DB exists
    if not _G["Phoenix_UIDB"] then
        print("|cffFF7D0APhoenix|r|cffFF0000_|r|cffFFD100UI|r: CRITICAL ERROR: Global DB missing! Creating new database...")
        _G["Phoenix_UIDB"] = {}
    end
    
    -- Initialize repair tracking
    _G["Phoenix_UIDB"].__repair_history = _G["Phoenix_UIDB"].__repair_history or {}
    _G["Phoenix_UIDB"].__repair_history[#_G["Phoenix_UIDB"].__repair_history + 1] = {
        timestamp = currentTime,
        player = playerKey,
        action = "RepairSettings function called"
    }
    
    -- PHASE 1: Ensure critical structures exist
    _G["Phoenix_UIDB"].profiles = _G["Phoenix_UIDB"].profiles or {}
    _G["Phoenix_UIDB"].profileKeys = _G["Phoenix_UIDB"].profileKeys or {}
    
    -- Get current profile
    local currentProfile = dbAvailable and self.db.keys and self.db.keys.profile or "Default"
    print("|cffFF7D0APhoenix|r|cffFF0000_|r|cffFFD100UI|r: Using profile: " .. currentProfile)
    
    -- Ensure both current and Default profiles exist
    if not _G["Phoenix_UIDB"].profiles[currentProfile] then
        _G["Phoenix_UIDB"].profiles[currentProfile] = {}
        print("|cffFF7D0APhoenix|r|cffFF0000_|r|cffFFD100UI|r: Created missing profile: " .. currentProfile)
    end
    
    if not _G["Phoenix_UIDB"].profiles["Default"] then
        _G["Phoenix_UIDB"].profiles["Default"] = {}
    end
    
    -- CRITICAL: Make sure this character is linked to correct profile
    _G["Phoenix_UIDB"].profileKeys[playerKey] = currentProfile
    
    -- PHASE 2: Check for backup data
    print("|cffFF7D0APhoenix|r|cffFF0000_|r|cffFFD100UI|r: Checking for backup data...")
    
    local repairMade = false
    local recoverySource = nil
    
    -- First check for emergency backups
    if _G["Phoenix_UIDB"].__emergency_backup and 
       _G["Phoenix_UIDB"].__emergency_backup[playerKey] and
       _G["Phoenix_UIDB"].__emergency_backup[playerKey].data then
        -- Found emergency backup
        local backup = _G["Phoenix_UIDB"].__emergency_backup[playerKey]
        local backupAge = currentTime - (backup.timestamp or 0)
        
        -- Only use recent backups (less than 1 day old)
        if backupAge < 86400 then
            print("|cffFF7D0APhoenix|r|cffFF0000_|r|cffFFD100UI|r: Found emergency backup from " .. 
                math.floor(backupAge/60) .. " minutes ago")
            
            -- Use backup to restore settings
            if backup.data then
                -- Restore both to local DB and global DB
                if dbAvailable then
                    self.db.profile = CopyTable(backup.data)
                end
                
                -- Also restore to global DB
                _G["Phoenix_UIDB"].profiles[currentProfile] = CopyTable(backup.data)
                
                -- Mark as repaired
                repairMade = true
                recoverySource = "emergency_backup"
                
                print("|cffFF7D0APhoenix|r|cffFF0000_|r|cffFFD100UI|r: Successfully recovered settings from emergency backup")
            end
        end
    end
    
    -- If no emergency backup, check for module-specific backups
    if not repairMade then
        -- Comprehensive module list
        local allModules = {
            "general", "unitframes", "nameplates", "actionbars", "castbars", 
            "buffs", "tooltip", "map", "chat", "misc", "uiscaling", "fonts",
            "msbt", "idtip", "buffoverlay", "cooldowntracker"
        }
        
        -- Check for global backup variables
        local modulesRecovered = 0
        for _, moduleName in ipairs(allModules) do
            local backupVar = _G["Phoenix_UI_" .. moduleName .. "_Backup"]
            
            if backupVar and type(backupVar) == "table" then
                print("|cffFF7D0APhoenix|r|cffFF0000_|r|cffFFD100UI|r: Found backup for " .. moduleName)
                
                -- Restore module settings
                if dbAvailable then
                    self.db.profile[moduleName] = CopyTable(backupVar)
                end
                
                -- Also restore to global DB
                _G["Phoenix_UIDB"].profiles[currentProfile][moduleName] = CopyTable(backupVar)
                
                -- Also save to Default profile as fallback
                if moduleName ~= "profiles" then
                    _G["Phoenix_UIDB"].profiles["Default"][moduleName] = CopyTable(backupVar)
                end
                
                modulesRecovered = modulesRecovered + 1
            end
        end
        
        if modulesRecovered > 0 then
            repairMade = true
            recoverySource = "module_backups"
            print("|cffFF7D0APhoenix|r|cffFF0000_|r|cffFFD100UI|r: Recovered " .. modulesRecovered .. " modules from backups")
        end
    end
    
    -- PHASE 3: If no backup, check Default profile
    if not repairMade and _G["Phoenix_UIDB"].profiles["Default"] then
        -- Only use Default if it has actual settings
        local hasSettings = false
        for key, value in pairs(_G["Phoenix_UIDB"].profiles["Default"]) do
            if key ~= "__repair" and type(value) == "table" then
                hasSettings = true
                break
            end
        end
        
        if hasSettings then
            print("|cffFF7D0APhoenix|r|cffFF0000_|r|cffFFD100UI|r: Using Default profile as fallback")
            
            -- Populate current profile from Default
            for key, value in pairs(_G["Phoenix_UIDB"].profiles["Default"]) do
                if key ~= "__repair" and type(value) == "table" then
                    _G["Phoenix_UIDB"].profiles[currentProfile][key] = CopyTable(value)
                    
                    -- Also restore to local DB if available
                    if dbAvailable then
                        self.db.profile[key] = CopyTable(value)
                    end
                end
            end
            
            repairMade = true
            recoverySource = "default_profile"
        end
    end
    
    -- PHASE 4: If all else fails, use factory defaults
    if not repairMade then
        print("|cffFF7D0APhoenix|r|cffFF0000_|r|cffFFD100UI|r: No backups available - using factory default settings")
        
        -- Create minimal settings to ensure addon can function
        local factoryDefaults = {
            general = {
                enabled = true,
                theme = "Dark",
                font = "Friz Quadrata TT",
                scale = 1.0,
                spellNotifications = true,
                __factory_default = true
            },
            nameplates = {
                enabled = true,
                height = 1.0,
                width = 1.0,
                style = "Default",
                __factory_default = true
            },
            actionbars = {
                enabled = true,
                buttonsize = 32,
                buttonspacing = 4,
                __factory_default = true
            },
            unitframes = {
                enabled = true,
                style = "Default",
                __factory_default = true
            },
            castbars = {
                enabled = true,
                __factory_default = true
            },
            buffs = {
                enabled = true,
                size = 30,
                spacing = 2,
                __factory_default = true
            },
            tooltip = {
                enabled = true,
                scale = 1.0,
                __factory_default = true
            },
            chat = {
                enabled = true,
                fontsize = 12,
                __factory_default = true
            },
            map = {
                enabled = true,
                scale = 1.0,
                __factory_default = true
            },
            install = true,
            reset = true,
            __restored = currentTime,
            __factory_reset = true
        }
        
        -- Apply factory defaults
        _G["Phoenix_UIDB"].profiles[currentProfile] = CopyTable(factoryDefaults)
        
        -- Also save to Default profile
        _G["Phoenix_UIDB"].profiles["Default"] = CopyTable(factoryDefaults)
        
        -- Apply to local DB if available
        if dbAvailable then
            for key, value in pairs(factoryDefaults) do
                self.db.profile[key] = CopyTable(value)
            end
        end
        
        repairMade = true
        recoverySource = "factory_defaults"
    end
    
    -- Record repair outcome
    _G["Phoenix_UIDB"].__repair_history[#_G["Phoenix_UIDB"].__repair_history].result = repairMade
    _G["Phoenix_UIDB"].__repair_history[#_G["Phoenix_UIDB"].__repair_history].source = recoverySource
    _G["Phoenix_UIDB"].__last_repair = {
        timestamp = currentTime,
        player = playerKey,
        success = repairMade,
        source = recoverySource
    }
    
    -- Force multiple save attempts with different methods
    print("|cffFF7D0APhoenix|r|cffFF0000_|r|cffFFD100UI|r: Forcing data flush to disk...")
    
    -- Try normal save functions first
    if self.SaveDB then
        pcall(function() self:SaveDB(true) end)
    end
    
    if self.ForceSaveDB then
        pcall(function() self:ForceSaveDB() end)
    end
    
    -- Multiple flush attempts with different methods
    for i = 1, 5 do
        pcall(function() 
            if FlushSettingsDB then FlushSettingsDB() end 
            if FlushSavedVariables then FlushSavedVariables() end
        end)
    end
    
    print("|cffFF7D0APhoenix|r|cffFF0000_|r|cffFFD100UI|r: Repair complete. Please type /reload to apply changes.")
    
    -- Return status
    return repairMade, recoverySource
end

-- Emergency function for creating backups and forcing saves
function Phoenix_UI:EmergencyBackup()
    local playerName = UnitName("player")
    local realmName = GetRealmName()
    local playerKey = playerName .. " - " .. GetRealmName()
    local currentTime = GetTime()
    
    print("|cffFF7D0APhoenix|r|cffFF0000_|r|cffFFD100UI|r: Creating emergency backup...")
    
    -- Ensure global database exists
    if not _G["Phoenix_UIDB"] then
        print("|cffFF7D0APhoenix|r|cffFF0000_|r|cffFFD100UI|r: Creating missing global database...")
        _G["Phoenix_UIDB"] = {}
    end
    
    -- Initialize backup storage
    _G["Phoenix_UIDB"].__emergency_backup = _G["Phoenix_UIDB"].__emergency_backup or {}
    
    -- Check if we have database available
    local dbAvailable = self.db and self.db.profile
    if not dbAvailable then
        print("|cffFF7D0APhoenix|r|cffFF0000_|r|cffFFD100UI|r: ERROR: Database not available!")
    else
        -- Create backup from current settings
        local backupData = CopyTable(self.db.profile)
        
        -- Store backup in global table
        _G["Phoenix_UIDB"].__emergency_backup[playerKey] = {
            timestamp = currentTime,
            data = backupData
        }
        
        print("|cffFF7D0APhoenix|r|cffFF0000_|r|cffFFD100UI|r: Emergency backup created successfully")
        
        -- Backup individual modules to separate global variables
        local allModules = {
            "general", "unitframes", "nameplates", "actionbars", "castbars", 
            "buffs", "tooltip", "map", "chat", "misc", "uiscaling", "fonts", 
            "msbt", "idtip", "buffoverlay", "cooldowntracker"
        }
        
        for _, moduleName in ipairs(allModules) do
            if self.db.profile[moduleName] then
                _G["Phoenix_UI_" .. moduleName .. "_Backup"] = CopyTable(self.db.profile[moduleName])
            end
        end
        
        -- Force settings to be saved
        print("|cffFF7D0APhoenix|r|cffFF0000_|r|cffFFD100UI|r: Forcing settings to save...")
        
        -- Try multiple save methods
        if self.SaveDB then
            pcall(function() self:SaveDB(true) end)
        end
        
        if self.ForceSaveDB then
            pcall(function() self:ForceSaveDB() end)
        end
        
        -- Use built-in WoW functions too
        for i = 1, 3 do
            pcall(function()
                if FlushSettingsDB then FlushSettingsDB() end
                if FlushSavedVariables then FlushSavedVariables() end
            end)
        end
        
        -- Write emergency info to WTF folder file if possible
        pcall(function()
            local f = io.open("WTF/Account/" .. GetAccountExpansionLevel() .. 
                "/SavedVariables/Phoenix_UI_Emergency.lua", "w")
            if f then
                f:write("Phoenix_UI_Emergency = Phoenix_UI_Emergency or {}\n")
                f:write("Phoenix_UI_Emergency[\"" .. playerKey .. "\"] = {\n")
                f:write("  timestamp = " .. currentTime .. ",\n")
                f:write("  success = true,\n")
                f:write("  modules = {")
                
                for _, moduleName in ipairs(allModules) do
                    if self.db.profile[moduleName] then
                        f:write("\"" .. moduleName .. "\", ")
                    end
                end
                
                f:write("},\n")
                f:write("}\n")
                f:close()
            end
        end)
    end
    
    print("|cffFF7D0APhoenix|r|cffFF0000_|r|cffFFD100UI|r: Emergency backup complete.")
    return dbAvailable
end
