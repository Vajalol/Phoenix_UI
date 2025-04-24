-- Create or modify the General.lua file to add theme selection
local General = Phoenix_UI:GetModule("Config.Layout.General")

-- Create a new layout if it doesn't exist
if not General.layout then
    General.layout = {
        name = "General",
        enabled = true,
        options = {}
    }
end

-- Add theme selection to options
General.layout.options = {
    appearance = {
        type = "group",
        name = "Appearance",
        order = 1,
        args = {
            theme = {
                type = "select",
                name = "Theme",
                desc = "Choose the visual theme for Phoenix UI",
                values = function()
                    local themes = {}
                    if Phoenix_UI.themes then
                        for name, themeData in pairs(Phoenix_UI.themes) do
                            -- Use displayName if available, otherwise use the internal name
                            themes[name] = themeData.displayName or name
                        end
                    end
                    -- Always ensure Default is available
                    if not themes["Default"] then
                        themes["Default"] = "Default"
                    end
                    return themes
                end,
                get = function()
                    -- First try currentTheme which is the active theme
                    if Phoenix_UI.currentTheme then
                        return Phoenix_UI.currentTheme
                    end
                    
                    -- Fall back to stored theme in DB
                    return (Phoenix_UI.db.profile.General and Phoenix_UI.db.profile.General.theme) or "Default"
                end,
                set = function(info, value)
                    -- Make sure General table exists
                    if not Phoenix_UI.db.profile.General then
                        Phoenix_UI.db.profile.General = {}
                    end
                    
                    -- Store the selected theme
                    Phoenix_UI.db.profile.General.theme = value
                    
                    -- Apply the theme
                    if Phoenix_UI.ApplyTheme then
                        Phoenix_UI:ApplyTheme(value)
                    end
                    
                    -- Save the setting immediately
                    if Phoenix_UI.SaveDB then
                        Phoenix_UI:SaveDB()
                    end
                end,
                width = "full",
                order = 1
            },
            themeDesc = {
                type = "description",
                name = function()
                    local theme = Phoenix_UI.currentTheme or (Phoenix_UI.db.profile.General and Phoenix_UI.db.profile.General.theme) or "Default"
                    local themeData = Phoenix_UI.themes and Phoenix_UI.themes[theme]
                    
                    if themeData then
                        local desc = themeData.description or ("Theme: " .. theme)
                        if themeData.author then
                            desc = desc .. " (by " .. themeData.author .. ")"
                        end
                        return desc
                    else
                        return "Theme: " .. theme
                    end
                end,
                order = 2,
                width = "full"
            },
            spacer1 = {
                type = "description",
                name = " ",
                order = 3,
                width = "full"
            },
            resetTheme = {
                type = "execute",
                name = "Reset to Default Theme",
                desc = "Reset to the default Phoenix UI theme",
                func = function()
                    -- Restore default theme
                    if not Phoenix_UI.db.profile.General then
                        Phoenix_UI.db.profile.General = {}
                    end
                    
                    Phoenix_UI.db.profile.General.theme = "Default"
                    
                    -- Apply the theme
                    if Phoenix_UI.ApplyTheme then
                        Phoenix_UI:ApplyTheme("Default")
                    end
                    
                    -- Save the setting immediately
                    if Phoenix_UI.SaveDB then
                        Phoenix_UI:SaveDB()
                    end
                end,
                order = 4,
                width = "half"
            },
            applyTheme = {
                type = "execute",
                name = "Apply Current Theme",
                desc = "Force-apply the current theme to all UI elements",
                func = function()
                    local theme = Phoenix_UI.currentTheme or (Phoenix_UI.db.profile.General and Phoenix_UI.db.profile.General.theme) or "Default"
                    
                    -- Apply the theme
                    if Phoenix_UI.ApplyTheme then
                        Phoenix_UI:ApplyTheme(theme)
                    end
                end,
                order = 5,
                width = "half"
            }
        }
    },
    
    -- Add other option groups here
    general = {
        type = "group",
        name = "General Settings",
        order = 2,
        args = {
            welcomePanel = {
                type = "toggle",
                name = "Show Welcome Panel",
                desc = "Show welcome panel on startup",
                get = function()
                    return Phoenix_UI.db.profile.General and Phoenix_UI.db.profile.General.showWelcomePanel
                end,
                set = function(info, value)
                    if not Phoenix_UI.db.profile.General then
                        Phoenix_UI.db.profile.General = {}
                    end
                    Phoenix_UI.db.profile.General.showWelcomePanel = value
                end,
                width = "full",
                order = 1
            }
        }
    },
    
    about = {
        type = "group",
        name = "About",
        order = 10,
        args = {
            version = {
                type = "description",
                name = function()
                    local version = Phoenix_UI.Version or C_AddOns.GetAddOnMetadata and C_AddOns.GetAddOnMetadata("Phoenix_UI", "version") or "Unknown"
                    return "Phoenix UI version: " .. version
                end,
                fontSize = "medium",
                order = 1,
                width = "full"
            },
            author = {
                type = "description",
                name = "By: VortexQ8",
                fontSize = "medium",
                order = 2,
                width = "full"
            },
            description = {
                type = "description",
                name = "Rise from the ashes with a fiery UI experience",
                fontSize = "medium",
                order = 3,
                width = "full"
            }
        }
    }
}

-- Expose the layout
Phoenix_UI.configOptions = Phoenix_UI.configOptions or {}
Phoenix_UI.configOptions.General = General.layout 