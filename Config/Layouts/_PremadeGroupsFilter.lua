local addonName, Phoenix = ...

-- Create the module
local module = Phoenix_UI:NewModule('Config.Layout.PremadeGroupsFilter')

-- Helper function to get PremadeGroupsFilter
local function GetPGF()
    return Phoenix_UI:GetModule('PremadeGroupsFilter', true)
end

-- Helper function to check if the module is loaded
local function IsPGFLoaded()
    return GetPGF() ~= nil
end

-- Helper to check if PremadeGroupsFilter addon is available
local function IsPGFAddonLoaded()
    -- First try IsAddOnLoaded 
    if _G.IsAddOnLoaded and _G.IsAddOnLoaded("PremadeGroupsFilter") then
        return true
    end
    
    -- Then check if global PremadeGroupsFilter exists
    if _G.PremadeGroupsFilter then
        return true
    end
    
    -- Check for common PGF global variables
    if _G.PremadeGroupsFilterState or _G.PremadeGroupsFilterMixin then
        return true
    end
    
    -- Final fallback - check for any PGF-related globals
    for key, value in pairs(_G) do
        if type(key) == "string" and (key:match("^PremadeGroupsFilter") or key:match("^PGF")) then
            return true
        end
    end
    
    return false
end

-- Helper function to get database
local function GetDB()
    -- Get the main addon database
    if Phoenix_UI and Phoenix_UI.db and Phoenix_UI.db.profile then
        -- Ensure premadeGroupsFilter table exists
        if not Phoenix_UI.db.profile.premadeGroupsFilter then
            Phoenix_UI.db.profile.premadeGroupsFilter = {
                enabled = true,
                enhancedUI = true,
                customFilters = {},
                favoritesEnabled = true,
                favorites = {},
                autoRefresh = true,
                refreshInterval = 60,
                enhancedTooltips = true,
                advancedFiltering = true
            }
        end
        return Phoenix_UI.db.profile
    end
    return {}
end

function module:OnEnable()
    -- Get Config
    local L = Phoenix.L or {}
    local C = Phoenix.Config or {}
    local DB = GetDB()
    
    -- Layout Configuration
    local layout = {
        title = L["Premade Groups Filter"] or "Premade Groups Filter",
        subtitle = L["Filter and manage premade group listings"] or "Filter and manage premade group listings",
        icon = "Interface\\Icons\\Achievement_GuildPerk_EverybodysFriend",
        color = {0.6, 0.8, 0.2},
        widgetLayout = "Flow",
        description = L["Configure how premade group listings are filtered and displayed in the group finder."] or "Configure how premade group listings are filtered and displayed in the group finder.",
        widgets = {
            -- Header - Module Status
            {
                type = "Header",
                text = L["Module Status"] or "Module Status"
            },
            {
                type = "Description",
                text = L["Enable or disable the Premade Groups Filter functionality"] or "Enable or disable the Premade Groups Filter functionality"
            },
            {
                type = "CheckBox",
                text = L["Enable Premade Groups Filter"] or "Enable Premade Groups Filter",
                tooltip = L["Master toggle for the Premade Groups Filter module"] or "Master toggle for the Premade Groups Filter module",
                get = function() 
                    if not IsPGFLoaded() then return false end
                    return DB.premadegroupsfilter and DB.premadegroupsfilter.enabled or false
                end,
                set = function(value)
                    if not IsPGFLoaded() then return end
                    if not DB.premadegroupsfilter then DB.premadegroupsfilter = {} end
                    DB.premadegroupsfilter.enabled = value
                    local pgf = GetPGF()
                    if pgf and pgf.UpdateSettings then
                        pgf:UpdateSettings()
                    end
                end,
                disabled = function() return not IsPGFLoaded() end
            },
            {
                type = "Divider"
            },
            
            -- General Settings
            {
                type = "Header",
                text = L["General Settings"] or "General Settings"
            },
            {
                type = "Description",
                text = L["Configure how the filter behaves in the Group Finder interface"] or "Configure how the filter behaves in the Group Finder interface"
            },
            {
                type = "CheckBox",
                text = L["Show Mini-Button"] or "Show Mini-Button",
                tooltip = L["Show a button on the Group Finder for quick access to filter settings"] or "Show a button on the Group Finder for quick access to filter settings",
                get = function() 
                    if not IsPGFLoaded() or not DB.premadegroupsfilter then return true end
                    return DB.premadegroupsfilter.showMiniButton or true
                end,
                set = function(value)
                    if not IsPGFLoaded() then return end
                    if not DB.premadegroupsfilter then DB.premadegroupsfilter = {} end
                    DB.premadegroupsfilter.showMiniButton = value
                    local pgf = GetPGF()
                    if pgf and pgf.UpdateSettings then
                        pgf:UpdateSettings()
                    end
                end,
                disabled = function() 
                    if not IsPGFLoaded() then return true end
                    return not (DB.premadegroupsfilter and DB.premadegroupsfilter.enabled)
                end
            },
            {
                type = "CheckBox",
                text = L["Auto Apply Filter"] or "Auto Apply Filter",
                tooltip = L["Automatically apply saved filters when opening the Group Finder"] or "Automatically apply saved filters when opening the Group Finder",
                get = function() 
                    if not IsPGFLoaded() or not DB.premadegroupsfilter then return false end
                    return DB.premadegroupsfilter.autoApply or false
                end,
                set = function(value)
                    if not IsPGFLoaded() then return end
                    if not DB.premadegroupsfilter then DB.premadegroupsfilter = {} end
                    DB.premadegroupsfilter.autoApply = value
                    local pgf = GetPGF()
                    if pgf and pgf.UpdateSettings then
                        pgf:UpdateSettings()
                    end
                end,
                disabled = function() 
                    if not IsPGFLoaded() then return true end
                    return not (DB.premadegroupsfilter and DB.premadegroupsfilter.enabled)
                end
            },
            {
                type = "CheckBox",
                text = L["Lock Window Position"] or "Lock Window Position",
                tooltip = L["Prevent the filter dialog from being moved"] or "Prevent the filter dialog from being moved",
                get = function() 
                    if not IsPGFLoaded() or not DB.premadegroupsfilter then return false end
                    return DB.premadegroupsfilter.lockWindowPosition or false
                end,
                set = function(value)
                    if not IsPGFLoaded() then return end
                    if not DB.premadegroupsfilter then DB.premadegroupsfilter = {} end
                    DB.premadegroupsfilter.lockWindowPosition = value
                    local pgf = GetPGF()
                    if pgf and pgf.UpdateSettings then
                        pgf:UpdateSettings()
                    end
                end,
                disabled = function() 
                    if not IsPGFLoaded() then return true end
                    return not (DB.premadegroupsfilter and DB.premadegroupsfilter.enabled)
                end
            },
            {
                type = "Divider"
            },
            
            -- Filter Storage
            {
                type = "Header",
                text = L["Saved Filters"] or "Saved Filters"
            },
            {
                type = "Description",
                text = L["Manage your saved search expressions for different group finder activities"] or "Manage your saved search expressions for different group finder activities"
            },
            {
                type = "CheckBox",
                text = L["Remember Last Search"] or "Remember Last Search",
                tooltip = L["Save your last search expression for each activity type"] or "Save your last search expression for each activity type",
                get = function() 
                    if not IsPGFLoaded() or not DB.premadegroupsfilter then return true end
                    return DB.premadegroupsfilter.rememberLastSearch or true
                end,
                set = function(value)
                    if not IsPGFLoaded() then return end
                    if not DB.premadegroupsfilter then DB.premadegroupsfilter = {} end
                    DB.premadegroupsfilter.rememberLastSearch = value
                    local pgf = GetPGF()
                    if pgf and pgf.UpdateSettings then
                        pgf:UpdateSettings()
                    end
                end,
                disabled = function() 
                    if not IsPGFLoaded() then return true end
                    return not (DB.premadegroupsfilter and DB.premadegroupsfilter.enabled)
                end
            },
            {
                type = "CheckBox",
                text = L["Save Per Character"] or "Save Per Character",
                tooltip = L["Save filter settings separately for each character (instead of account-wide)"] or "Save filter settings separately for each character (instead of account-wide)",
                get = function() 
                    if not IsPGFLoaded() or not DB.premadegroupsfilter then return false end
                    return DB.premadegroupsfilter.savePerCharacter or false
                end,
                set = function(value)
                    if not IsPGFLoaded() then return end
                    if not DB.premadegroupsfilter then DB.premadegroupsfilter = {} end
                    DB.premadegroupsfilter.savePerCharacter = value
                    local pgf = GetPGF()
                    if pgf and pgf.UpdateSettings then
                        pgf:UpdateSettings()
                    end
                end,
                disabled = function() 
                    if not IsPGFLoaded() then return true end
                    return not (DB.premadegroupsfilter and DB.premadegroupsfilter.enabled)
                end
            },
            {
                type = "Button",
                text = L["Reset Saved Filters"] or "Reset Saved Filters",
                tooltip = L["Delete all saved filter expressions"] or "Delete all saved filter expressions",
                onClick = function()
                    if not IsPGFLoaded() then return end
                    local pgf = GetPGF()
                    if pgf and pgf.ResetSavedFilters then
                        pgf:ResetSavedFilters()
                        C_Timer.After(0.5, function()
                            if Phoenix and Phoenix.Print then
                                Phoenix:Print(L["Saved filters have been reset"] or "Saved filters have been reset")
                            end
                        end)
                    end
                end,
                disabled = function() 
                    if not IsPGFLoaded() then return true end
                    return not (DB.premadegroupsfilter and DB.premadegroupsfilter.enabled)
                end
            },
            {
                type = "Divider"
            },
            
            -- Advanced Filtering
            {
                type = "Header",
                text = L["Advanced Filtering"] or "Advanced Filtering"
            },
            {
                type = "Description",
                text = L["Configure advanced filtering options and expression behavior"] or "Configure advanced filtering options and expression behavior"
            },
            {
                type = "CheckBox",
                text = L["Show Advanced Options"] or "Show Advanced Options",
                tooltip = L["Show expert filter expression builder in the filter dialog"] or "Show expert filter expression builder in the filter dialog",
                get = function() 
                    if not IsPGFLoaded() or not DB.premadegroupsfilter then return true end
                    return DB.premadegroupsfilter.showAdvanced or true
                end,
                set = function(value)
                    if not IsPGFLoaded() then return end
                    if not DB.premadegroupsfilter then DB.premadegroupsfilter = {} end
                    DB.premadegroupsfilter.showAdvanced = value
                    local pgf = GetPGF()
                    if pgf and pgf.UpdateSettings then
                        pgf:UpdateSettings()
                    end
                end,
                disabled = function() 
                    if not IsPGFLoaded() then return true end
                    return not (DB.premadegroupsfilter and DB.premadegroupsfilter.enabled)
                end
            },
            {
                type = "Slider",
                text = L["Minimum Refresh Time"] or "Minimum Refresh Time",
                tooltip = L["Minimum time in seconds between automatic refreshes of the group list"] or "Minimum time in seconds between automatic refreshes of the group list",
                min = 0.1,
                max = 5,
                step = 0.1,
                get = function() 
                    if not IsPGFLoaded() or not DB.premadegroupsfilter then return 0.5 end
                    return DB.premadegroupsfilter.minRefreshTime or 0.5
                end,
                set = function(value)
                    if not IsPGFLoaded() then return end
                    if not DB.premadegroupsfilter then DB.premadegroupsfilter = {} end
                    DB.premadegroupsfilter.minRefreshTime = value
                    local pgf = GetPGF()
                    if pgf and pgf.UpdateSettings then
                        pgf:UpdateSettings()
                    end
                end,
                disabled = function() 
                    if not IsPGFLoaded() then return true end
                    return not (DB.premadegroupsfilter and DB.premadegroupsfilter.enabled)
                end
            },
            {
                type = "CheckBox",
                text = L["Extended Results"] or "Extended Results",
                tooltip = L["Show additional information about filter matches (slower, but helpful for debugging)"] or "Show additional information about filter matches (slower, but helpful for debugging)",
                get = function() 
                    if not IsPGFLoaded() or not DB.premadegroupsfilter then return false end
                    return DB.premadegroupsfilter.extendedResults or false
                end,
                set = function(value)
                    if not IsPGFLoaded() then return end
                    if not DB.premadegroupsfilter then DB.premadegroupsfilter = {} end
                    DB.premadegroupsfilter.extendedResults = value
                    local pgf = GetPGF()
                    if pgf and pgf.UpdateSettings then
                        pgf:UpdateSettings()
                    end
                end,
                disabled = function() 
                    if not IsPGFLoaded() then return true end
                    return not (DB.premadegroupsfilter and DB.premadegroupsfilter.enabled)
                end
            },
            {
                type = "Divider"
            },
            
            -- Favorites
            {
                type = "Header",
                text = L["Favorite Expressions"] or "Favorite Expressions"
            },
            {
                type = "Description",
                text = L["Save your most commonly used filter expressions for quick access"] or "Save your most commonly used filter expressions for quick access"
            },
            {
                type = "CheckBox",
                text = L["Enable Favorites"] or "Enable Favorites",
                tooltip = L["Allow saving filter expressions as favorites"] or "Allow saving filter expressions as favorites",
                get = function() 
                    if not IsPGFLoaded() or not DB.premadegroupsfilter then return true end
                    return DB.premadegroupsfilter.enableFavorites or true
                end,
                set = function(value)
                    if not IsPGFLoaded() then return end
                    if not DB.premadegroupsfilter then DB.premadegroupsfilter = {} end
                    DB.premadegroupsfilter.enableFavorites = value
                    local pgf = GetPGF()
                    if pgf and pgf.UpdateSettings then
                        pgf:UpdateSettings()
                    end
                end,
                disabled = function() 
                    if not IsPGFLoaded() then return true end
                    return not (DB.premadegroupsfilter and DB.premadegroupsfilter.enabled)
                end
            },
            {
                type = "Slider",
                text = L["Maximum Favorites"] or "Maximum Favorites",
                tooltip = L["Maximum number of favorite expressions that can be saved"] or "Maximum number of favorite expressions that can be saved",
                min = 1,
                max = 10,
                step = 1,
                get = function() 
                    if not IsPGFLoaded() or not DB.premadegroupsfilter then return 5 end
                    return DB.premadegroupsfilter.maxFavorites or 5
                end,
                set = function(value)
                    if not IsPGFLoaded() then return end
                    if not DB.premadegroupsfilter then DB.premadegroupsfilter = {} end
                    DB.premadegroupsfilter.maxFavorites = value
                    local pgf = GetPGF()
                    if pgf and pgf.UpdateSettings then
                        pgf:UpdateSettings()
                    end
                end,
                disabled = function() 
                    if not IsPGFLoaded() then return true end
                    local pgfEnabled = DB.premadegroupsfilter and DB.premadegroupsfilter.enabled
                    local favoritesEnabled = DB.premadegroupsfilter and DB.premadegroupsfilter.enableFavorites
                    return not (pgfEnabled and favoritesEnabled)
                end
            },
            {
                type = "Button",
                text = L["Clear Favorites"] or "Clear Favorites",
                tooltip = L["Delete all saved favorite expressions"] or "Delete all saved favorite expressions",
                onClick = function()
                    if not IsPGFLoaded() then return end
                    local pgf = GetPGF()
                    if pgf and pgf.ClearFavorites then
                        pgf:ClearFavorites()
                        C_Timer.After(0.5, function()
                            if Phoenix and Phoenix.Print then
                                Phoenix:Print(L["Favorite expressions have been cleared"] or "Favorite expressions have been cleared")
                            end
                        end)
                    end
                end,
                disabled = function() 
                    if not IsPGFLoaded() then return true end
                    local pgfEnabled = DB.premadegroupsfilter and DB.premadegroupsfilter.enabled
                    local favoritesEnabled = DB.premadegroupsfilter and DB.premadegroupsfilter.enableFavorites
                    return not (pgfEnabled and favoritesEnabled)
                end
            },
            {
                type = "Divider"
            },
            
            -- Open advanced options
            {
                type = "Button",
                text = L["Open Full Configuration"],
                tooltip = L["Open the complete Premade Groups Filter configuration panel"],
                onClick = function()
                    if not IsPGFLoaded() then return end
                    GetPGF():OpenConfigPanel()
                end,
                disabled = function() 
                    if not IsPGFLoaded() then return true end
                    return not DB.premadegroupsfilter.enabled
                end
            }
        }
    }
    
    -- IMPORTANT: Assign the layout to the module itself
    self.layout = layout
    
    -- Direct assignment to config options for immediate availability
    if Phoenix_UI and Phoenix_UI.configOptions then
        Phoenix_UI.configOptions["PremadeGroupsFilter"] = layout
    end
    
    -- Register the layout with the config system
    if C and type(C) == "table" and C.RegisterLayout then
        C:RegisterLayout("PremadeGroupsFilter", layout)
    elseif C and type(C) == "function" then
        -- If C is a function, call it first to get the config object
        local configObj = C()
        if configObj and configObj.RegisterLayout then
            configObj:RegisterLayout("PremadeGroupsFilter", layout)
        else
            -- Fallback to Phoenix_UI.config
            if Phoenix_UI.config and Phoenix_UI.config.AddLayout then
                Phoenix_UI.config:AddLayout(layout)
            elseif Phoenix_UI.ConfigSystem and Phoenix_UI.ConfigSystem.Layouts then
                -- Direct fallback - store layout in the ConfigSystem
                Phoenix_UI.ConfigSystem.Layouts["PremadeGroupsFilter"] = layout
            end
        end
    elseif Phoenix_UI.config and Phoenix_UI.config.AddLayout then
        Phoenix_UI.config:AddLayout(layout)
        
        -- Direct fallback - store layout in the ConfigSystem
        if Phoenix_UI.ConfigSystem and Phoenix_UI.ConfigSystem.Layouts then
            Phoenix_UI.ConfigSystem.Layouts["PremadeGroupsFilter"] = layout
        end
    end
    
    -- Force config refresh if config is already open
    if Phoenix_UI.GetConfig and Phoenix_UI:GetConfig() and Phoenix_UI:GetConfig():IsShown() then
        if Phoenix.Config and Phoenix.Config.RefreshConfig then
            Phoenix.Config:RefreshConfig()
        end
    end
end 