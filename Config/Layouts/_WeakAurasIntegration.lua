local addonName, Phoenix = ...

-- Create the module
local module = Phoenix_UI:NewModule('Config.Layout.WeakAurasIntegration')

function module:OnEnable()
    -- Get database
    local db = Phoenix_UI.db
    
    -- Ensure weakauras table exists
    if not db.profile.weakauras then
        db.profile.weakauras = {
            enabled = true,
            applyTheme = true,
            themedBorders = true,
            themedBars = true,
            useFonts = true,
            performanceMode = true,
            combatUpdateRate = 0.1,
            throttleDuringFPSDrops = true,
            fpsThreshold = 20,
            shareAuraUpdates = true,
            syncWithPhoenixUI = true,
            groupAurasByType = true,
            showTemplates = true
        }
    end
    
    -- Layout
    self.layout = {
        database = db.profile.weakauras,
        rows = {
            {
                header1 = {
                    type = "header",
                    label = "WeakAuras Integration"
                }
            },
            {
                enabled = {
                    type = "checkbox",
                    key = "enabled",
                    label = "Enable WeakAuras Integration",
                    tooltip = "Enable or disable WeakAuras integration",
                    column = 4,
                    order = 1
                }
            },
            {
                applyTheme = {
                    type = "checkbox",
                    key = "applyTheme",
                    label = "Apply Phoenix Theme",
                    tooltip = "Apply Phoenix UI theme to WeakAuras elements",
                    column = 4,
                    order = 2
                }
            },
            {
                header2 = {
                    type = "header",
                    label = "Visual Settings"
                }
            },
            {
                themedBorders = {
                    type = "checkbox",
                    key = "themedBorders",
                    label = "Themed Borders",
                    tooltip = "Apply themed borders to WeakAuras icons",
                    column = 4,
                    order = 1
                }
            },
            {
                themedBars = {
                    type = "checkbox",
                    key = "themedBars",
                    label = "Themed Bars",
                    tooltip = "Apply themed bars to WeakAuras progress bars",
                    column = 4,
                    order = 2
                }
            },
            {
                useFonts = {
                    type = "checkbox",
                    key = "useFonts",
                    label = "Use Phoenix Fonts",
                    tooltip = "Use Phoenix UI fonts in WeakAuras",
                    column = 4,
                    order = 3
                }
            }
        }
    }
    
    -- IMPORTANT: Assign the layout to the module itself
    self.layout = self.layout
    
    -- Direct assignment to config options for immediate availability
    if Phoenix_UI and Phoenix_UI.configOptions then
        Phoenix_UI.configOptions["WeakAurasIntegration"] = self.layout
    end
    
    -- Register the layout with the config system
    if Phoenix_UI.config and Phoenix_UI.config.AddLayout then
        Phoenix_UI.config:AddLayout(self.layout)
    elseif Phoenix_UI.ConfigSystem and Phoenix_UI.ConfigSystem.Layouts then
        -- Direct fallback - store layout in the ConfigSystem
        Phoenix_UI.ConfigSystem.Layouts["WeakAurasIntegration"] = self.layout
    end
    
    -- Force config refresh if config is already open
    if Phoenix_UI.GetConfig and Phoenix_UI:GetConfig() and Phoenix_UI:GetConfig():IsShown() then
        if Phoenix.Config and Phoenix.Config.RefreshConfig then
            Phoenix.Config:RefreshConfig()
        end
    end
end 