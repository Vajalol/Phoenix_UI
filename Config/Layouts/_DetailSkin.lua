-- Phoenix UI: DetailSkin Layout
local addonName, Phoenix = ...
local Layout = Phoenix_UI:NewModule("Config.Layout.DetailSkin")
local L = Phoenix.L or {['DetailSkin'] = 'Detail Skin'}

-- Register the layout with Phoenix_UI configuration
function Layout:OnEnable()
    if not Phoenix_UI.layouts then
        Phoenix_UI.layouts = {}
    end
    
    Phoenix_UI.layouts.DetailSkin = self:GetLayout()
end

-- Define the layout structure
function Layout:GetLayout()
    local layout = {
        key = 'DetailSkin',
        parentKey = nil,
        text = L['DetailSkin'] or 'Detail Skin',
        layoutOrder = 13, -- Place it after Mythic+
        rows = {
            {
                header = {
                    type = 'header',
                    label = L['DetailSkin'] or 'Detail Skin',
                    template = 'PhoenixHeaderTmpl',
                    column = 12,
                    initialValue = '',
                    order = 1
                }
            },
            {
                description = {
                    type = 'text',
                    label = L['DetailSkin_Description'] or [[Phoenix UI skin for the Details! damage meter addon.

|cffff9900Note: You can configure all settings even if Details! is not currently installed. Once you install Details!, your configured settings will be applied automatically.|r

If this tab appears empty, install Details! from your addon manager, then reload your UI to see the skin in action.]],
                    fontSize = 'medium',
                    fontStyle = 'normal',
                    column = 12,
                    order = 1
                }
            },
            {
                enabled = {
                    type = 'checkbox',
                    key = 'enabled',
                    label = L['Enable'] or 'Enable',
                    tooltip = L['DetailSkin_Enable_Tooltip'] or 'Enable the Phoenix UI skin for Details! damage meter',
                    initialValue = true,
                    column = 12,
                    order = 1,
                    onChange = function(widget, value)
                        if not Phoenix_UI.db.profile.detailskin then
                            Phoenix_UI.db.profile.detailskin = {}
                        end
                        Phoenix_UI.db.profile.detailskin.enabled = value
                        
                        -- Notify Details! to update if it exists
                        if value then
                            if _G.Details then
                                Phoenix_UI:Print(L['DetailSkin_Enabled'] or 'Phoenix UI skin for Details! has been enabled. Please reload your UI to apply changes.')
                            else
                                Phoenix_UI:Print(L['DetailSkin_Details_Missing'] or 'Details! addon is not loaded or installed. Install Details! to use this skin.')
                            end
                        else
                            Phoenix_UI:Print(L['DetailSkin_Disabled'] or 'Phoenix UI skin for Details! has been disabled. Please reload your UI to apply changes.')
                        end
                    end
                }
            },
            {
                reloadNote = {
                    type = 'text',
                    label = L['DetailSkin_Reload_Note'] or '|cffff8800Note: Changes may require a UI reload to take full effect.|r',
                    fontSize = 'small',
                    fontStyle = 'normal',
                    column = 12,
                    order = 1
                }
            },
            {
                detailsStatus = {
                    type = 'text',
                    label = function()
                        local DetailsSkin = Phoenix_UI:GetModule("DetailsSkin")
                        if DetailsSkin and not DetailsSkin:IsDetailsLoaded() then
                            return '|cffff9900Details! is not currently installed or loaded. Configure options below and they will be applied when Details! is available.|r'
                        end
                        return '|cff00ff00Details! is loaded. All options are enabled.|r'
                    end,
                    fontSize = 'medium',
                    fontStyle = 'normal',
                    column = 12,
                    order = 1
                }
            },
            {
                separator1 = {
                    type = 'spacer',
                    height = 20,
                    column = 12,
                    order = 1
                }
            },
            {
                appearanceHeader = {
                    type = 'header',
                    label = L['Appearance'] or 'Appearance',
                    template = 'PhoenixSubHeaderTmpl',
                    column = 12,
                    initialValue = '',
                    order = 1
                }
            },
            {
                usePhoenixColors = {
                    type = 'checkbox',
                    key = 'usePhoenixColors',
                    label = L['Use_Phoenix_Colors'] or 'Use Phoenix UI Colors',
                    tooltip = L['Use_Phoenix_Colors_Description'] or 'Use Phoenix UI color scheme for Details! windows',
                    initialValue = true,
                    column = 6,
                    order = 1,
                    onChange = function(widget, value)
                        if not Phoenix_UI.db.profile.detailskin then
                            Phoenix_UI.db.profile.detailskin = {}
                        end
                        Phoenix_UI.db.profile.detailskin.usePhoenixColors = value
                    end
                },
                modernStyle = {
                    type = 'checkbox',
                    key = 'modernStyle',
                    label = L['Modern_Style'] or 'Modern Style',
                    tooltip = L['Modern_Style_Description'] or 'Use a modern, clean look for Details! windows',
                    initialValue = true,
                    column = 6,
                    order = 2,
                    onChange = function(widget, value)
                        if not Phoenix_UI.db.profile.detailskin then
                            Phoenix_UI.db.profile.detailskin = {}
                        end
                        Phoenix_UI.db.profile.detailskin.modernStyle = value
                    end
                }
            },
            {
                shadowBorders = {
                    type = 'checkbox',
                    key = 'shadowBorders',
                    label = L['Shadow_Borders'] or 'Shadow Borders',
                    tooltip = L['Shadow_Borders_Description'] or 'Add shadow effect to window borders',
                    initialValue = true,
                    column = 6,
                    order = 1,
                    onChange = function(widget, value)
                        if not Phoenix_UI.db.profile.detailskin then
                            Phoenix_UI.db.profile.detailskin = {}
                        end
                        Phoenix_UI.db.profile.detailskin.shadowBorders = value
                    end
                },
                transparentBackground = {
                    type = 'checkbox',
                    key = 'transparentBackground',
                    label = L['Transparent_Background'] or 'Transparent Background',
                    tooltip = L['Transparent_Background_Description'] or 'Use semi-transparent backgrounds for Details! windows',
                    initialValue = true,
                    column = 6,
                    order = 2,
                    onChange = function(widget, value)
                        if not Phoenix_UI.db.profile.detailskin then
                            Phoenix_UI.db.profile.detailskin = {}
                        end
                        Phoenix_UI.db.profile.detailskin.transparentBackground = value
                    end
                }
            },
            {
                separator2 = {
                    type = 'spacer',
                    height = 20,
                    column = 12,
                    order = 1
                }
            },
            {
                colorsHeader = {
                    type = 'header',
                    label = L['Colors'] or 'Colors',
                    template = 'PhoenixSubHeaderTmpl',
                    column = 12,
                    initialValue = '',
                    order = 1
                }
            },
            {
                backgroundColor = {
                    key = 'backgroundColor',
                    label = L['Background_Color'] or 'Background Color',
                    type = 'color',
                    hasAlpha = true,
                    initialValue = {r = 0.1, g = 0.1, b = 0.1, a = 0.8},
                    column = 4,
                    order = 1,
                    onChange = function(widget, r, g, b, a)
                        if not Phoenix_UI.db.profile.detailskin then
                            Phoenix_UI.db.profile.detailskin = {}
                        end
                        if not Phoenix_UI.db.profile.detailskin.colors then
                            Phoenix_UI.db.profile.detailskin.colors = {}
                        end
                        Phoenix_UI.db.profile.detailskin.colors.background = {r = r, g = g, b = b, a = a}
                    end
                },
                borderColor = {
                    key = 'borderColor',
                    label = L['Border_Color'] or 'Border Color',
                    type = 'color',
                    hasAlpha = true,
                    initialValue = {r = 0.8, g = 0.3, b = 0, a = 0.9},
                    column = 4,
                    order = 2,
                    onChange = function(widget, r, g, b, a)
                        if not Phoenix_UI.db.profile.detailskin then
                            Phoenix_UI.db.profile.detailskin = {}
                        end
                        if not Phoenix_UI.db.profile.detailskin.colors then
                            Phoenix_UI.db.profile.detailskin.colors = {}
                        end
                        Phoenix_UI.db.profile.detailskin.colors.border = {r = r, g = g, b = b, a = a}
                    end
                },
                textColor = {
                    key = 'textColor',
                    label = L['Text_Color'] or 'Text Color',
                    type = 'color',
                    hasAlpha = true,
                    initialValue = {r = 1, g = 1, b = 1, a = 1},
                    column = 4,
                    order = 3,
                    onChange = function(widget, r, g, b, a)
                        if not Phoenix_UI.db.profile.detailskin then
                            Phoenix_UI.db.profile.detailskin = {}
                        end
                        if not Phoenix_UI.db.profile.detailskin.colors then
                            Phoenix_UI.db.profile.detailskin.colors = {}
                        end
                        Phoenix_UI.db.profile.detailskin.colors.text = {r = r, g = g, b = b, a = a}
                    end
                }
            },
            {
                barColor = {
                    key = 'barColor',
                    label = L['Bar_Color'] or 'Default Bar Color',
                    type = 'color',
                    hasAlpha = true,
                    initialValue = {r = 0.8, g = 0.3, b = 0, a = 0.9},
                    column = 4,
                    order = 1,
                    onChange = function(widget, r, g, b, a)
                        if not Phoenix_UI.db.profile.detailskin then
                            Phoenix_UI.db.profile.detailskin = {}
                        end
                        if not Phoenix_UI.db.profile.detailskin.colors then
                            Phoenix_UI.db.profile.detailskin.colors = {}
                        end
                        Phoenix_UI.db.profile.detailskin.colors.bar = {r = r, g = g, b = b, a = a}
                    end
                }
            },
            {
                separator3 = {
                    type = 'spacer',
                    height = 20,
                    column = 12,
                    order = 1
                }
            },
            {
                infoHeader = {
                    type = 'header',
                    label = L['Information'] or 'Information',
                    template = 'PhoenixSubHeaderTmpl',
                    column = 12,
                    initialValue = '',
                    order = 1
                }
            },
            {
                infoText = {
                    type = 'text',
                    label = L['Details_Info'] or [[|cffff9900DETAILS! ADDON REQUIRED|r

This skin requires the Details! damage meter addon to be installed. Without Details!, this tab will appear empty.

Install Details! from your addon manager, then reload your UI to access these settings. Changes to these settings will apply the next time Details! loads its windows.]],
                    fontSize = 'medium',
                    fontStyle = 'normal',
                    column = 12,
                    order = 1
                }
            },
            {
                aboutText = {
                    type = 'text',
                    label = L['Details_About'] or 'The Phoenix UI skin for Details! provides a seamless look and feel that matches the rest of your Phoenix UI elements.',
                    fontSize = 'medium',
                    fontStyle = 'normal',
                    column = 12,
                    order = 2
                }
            },
            -- Add padding at the bottom to ensure all options are visible when scrolling
            {
                bottomPadding = {
                    type = 'spacer',
                    height = 150,
                    column = 12,
                    order = 1
                }
            }
        }
    }
    
    return layout
end
