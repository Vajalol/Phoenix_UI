local Skins = Phoenix_UI:NewModule("Config.Layout.Skins")

-- Helper function to get skin configuration
local function GetSkinConfig()
    local db = Phoenix_UI.db.profile
    if not db.skins then
        db.skins = {
            enabled = true,
            blizzardFrames = true,
            actionBars = true,
            bags = true,
            chat = true,
            minimap = true,
            unitFrames = true,
            raidFrames = true,
            customSkinColors = false,
            skinColor = {r = 0.1, g = 0.1, b = 0.1, a = 0.8},
            borderColor = {r = 0.3, g = 0.3, b = 0.3, a = 1},
            customElements = {},
        }
    end
    return db.skins
end

-- Helper function to apply skin changes
local function ApplySkinChanges()
    -- Call the Skins module's refresh function if available
    local SkinsModule = Phoenix_UI:GetModule("Skins", true)
                 or Phoenix_UI:GetModule("SkinModule", true)
                 or Phoenix_UI:GetModule("SkinsModule", true)
                 or Phoenix_UI:GetModule("PhoenixSkins", true)
    if SkinsModule and SkinsModule.RefreshSkins then
        C_Timer.After(0.2, function()
            SkinsModule:RefreshSkins()
        end)
    end
    
    -- Force UI reload message if needed
    if not SkinsModule or not SkinsModule.RefreshSkins then
        print("|cffFF7D0APhoenix|r|cffFF0000_|r|cffFFD100UI|r: Some skin changes may require a UI reload to take full effect.")
    end
end

function Skins:OnEnable()
    if not Phoenix_UI.layouts then
        Phoenix_UI.layouts = {}
    end
    
    local db = Phoenix_UI.db.profile
    local skinConfig = GetSkinConfig()
    
    -- Create the layout
    local layout = {
        layoutConfig = { padding = { top = 15 } },
        rows = {
            {
                header = {
                    type = 'header',
                    label = 'UI Skins'
                }
            },
            {
                description = {
                    type = 'description',
                    text = "Configure the appearance of various interface elements with Phoenix UI skins.",
                    column = 12,
                    order = 1
                }
            },
            {
                divider1 = {
                    type = 'divider',
                    column = 12,
                    order = 2
                }
            },
            {
                enabled = {
                    type = 'checkbox',
                    label = 'Enable Skins',
                    tooltip = 'Enable or disable all Phoenix UI skins',
                    get = function() return skinConfig.enabled end,
                    set = function(value)
                        skinConfig.enabled = value
                        ApplySkinChanges()
                    end,
                    column = 12,
                    order = 3
                }
            },
            {
                divider2 = {
                    type = 'divider',
                    column = 12,
                    order = 4
                }
            },
            {
                header2 = {
                    type = 'header',
                    label = 'Skin Categories',
                    column = 12,
                    order = 5
                }
            },
            {
                blizzardFrames = {
                    type = 'checkbox',
                    label = 'Blizzard Frames',
                    tooltip = 'Apply skins to standard Blizzard UI frames (character, spellbook, bags, etc.)',
                    get = function() return skinConfig.blizzardFrames end,
                    set = function(value)
                        skinConfig.blizzardFrames = value
                        ApplySkinChanges()
                    end,
                    disabled = function() return not skinConfig.enabled end,
                    column = 4,
                    order = 6
                },
                actionBars = {
                    type = 'checkbox',
                    label = 'Action Bars',
                    tooltip = 'Apply skins to action bars and buttons',
                    get = function() return skinConfig.actionBars end,
                    set = function(value)
                        skinConfig.actionBars = value
                        ApplySkinChanges()
                    end,
                    disabled = function() return not skinConfig.enabled end,
                    column = 4,
                    order = 7
                },
                bags = {
                    type = 'checkbox',
                    label = 'Bags & Bank',
                    tooltip = 'Apply skins to inventory, bags, and bank frames',
                    get = function() return skinConfig.bags end,
                    set = function(value)
                        skinConfig.bags = value
                        ApplySkinChanges()
                    end,
                    disabled = function() return not skinConfig.enabled end,
                    column = 4,
                    order = 8
                }
            },
            {
                chat = {
                    type = 'checkbox',
                    label = 'Chat Frames',
                    tooltip = 'Apply skins to chat windows and related UI elements',
                    get = function() return skinConfig.chat end,
                    set = function(value)
                        skinConfig.chat = value
                        ApplySkinChanges()
                    end,
                    disabled = function() return not skinConfig.enabled end,
                    column = 4,
                    order = 9
                },
                minimap = {
                    type = 'checkbox',
                    label = 'Minimap',
                    tooltip = 'Apply skins to the minimap and related elements',
                    get = function() return skinConfig.minimap end,
                    set = function(value)
                        skinConfig.minimap = value
                        ApplySkinChanges()
                    end,
                    disabled = function() return not skinConfig.enabled end,
                    column = 4,
                    order = 10
                },
                unitFrames = {
                    type = 'checkbox',
                    label = 'Unit Frames',
                    tooltip = 'Apply skins to player, target, and focus frames',
                    get = function() return skinConfig.unitFrames end,
                    set = function(value)
                        skinConfig.unitFrames = value
                        ApplySkinChanges()
                    end,
                    disabled = function() return not skinConfig.enabled end,
                    column = 4,
                    order = 11
                }
            },
            {
                raidFrames = {
                    type = 'checkbox',
                    label = 'Raid & Party Frames',
                    tooltip = 'Apply skins to raid and party frames',
                    get = function() return skinConfig.raidFrames end,
                    set = function(value)
                        skinConfig.raidFrames = value 
                        ApplySkinChanges()
                    end,
                    disabled = function() return not skinConfig.enabled end,
                    column = 12,
                    order = 12
                }
            },
            {
                divider3 = {
                    type = 'divider',
                    column = 12,
                    order = 13
                }
            },
            {
                header3 = {
                    type = 'header',
                    label = 'Skin Appearance',
                    column = 12,
                    order = 14
                }
            },
            {
                customSkinColors = {
                    type = 'checkbox',
                    label = 'Use Custom Colors',
                    tooltip = 'Enable to customize the skin colors below',
                    get = function() return skinConfig.customSkinColors end,
                    set = function(value)
                        skinConfig.customSkinColors = value
                        ApplySkinChanges()
                    end,
                    disabled = function() return not skinConfig.enabled end,
                    column = 12,
                    order = 15
                }
            },
            {
                skinColor = {
                    type = 'color',
                    label = 'Background Color',
                    tooltip = 'Choose the background color for skinned frames',
                    hasAlpha = true,
                    get = function() 
                        local color = skinConfig.skinColor
                        return color.r, color.g, color.b, color.a
                    end,
                    set = function(r, g, b, a)
                        skinConfig.skinColor.r = r
                        skinConfig.skinColor.g = g
                        skinConfig.skinColor.b = b
                        skinConfig.skinColor.a = a
                        ApplySkinChanges()
                    end,
                    disabled = function() return not skinConfig.enabled or not skinConfig.customSkinColors end,
                    column = 6,
                    order = 16
                },
                borderColor = {
                    type = 'color',
                    label = 'Border Color',
                    tooltip = 'Choose the border color for skinned frames',
                    hasAlpha = true,
                    get = function() 
                        local color = skinConfig.borderColor
                        return color.r, color.g, color.b, color.a
                    end,
                    set = function(r, g, b, a)
                        skinConfig.borderColor.r = r
                        skinConfig.borderColor.g = g
                        skinConfig.borderColor.b = b
                        skinConfig.borderColor.a = a
                        ApplySkinChanges()
                    end,
                    disabled = function() return not skinConfig.enabled or not skinConfig.customSkinColors end,
                    column = 6,
                    order = 17
                }
            },
            {
                divider4 = {
                    type = 'divider',
                    column = 12,
                    order = 18
                }
            },
            {
                header4 = {
                    type = 'header',
                    label = 'Advanced Options',
                    column = 12,
                    order = 19
                }
            },
            {
                openConfig = {
                    type = 'button',
                    text = 'Open Full Skin Configuration',
                    tooltip = 'Opens the detailed skinning configuration panel with advanced options',
                    onClick = function()
                        -- Call the Skins module's configuration if available
                        local SkinsModule = Phoenix_UI:GetModule("Skins", true)
                                     or Phoenix_UI:GetModule("SkinModule", true)
                                     or Phoenix_UI:GetModule("SkinsModule", true)
                                     or Phoenix_UI:GetModule("PhoenixSkins", true)
                        if SkinsModule and SkinsModule.OpenConfig then
                            SkinsModule:OpenConfig()
                        else
                            print("|cffFF7D0APhoenix|r|cffFF0000_|r|cffFFD100UI|r: Advanced skin configuration is not available in this version.")
                        end
                    end,
                    column = 12,
                    order = 20
                }
            },
            {
                spacer = {
                    type = 'spacer',
                    height = 10,
                    column = 12,
                    order = 21
                }
            },
            {
                reloadUI = {
                    type = 'button',
                    text = 'Reload UI',
                    tooltip = 'Reload the user interface to apply all skin changes',
                    onClick = function()
                        ReloadUI()
                    end,
                    column = 12,
                    order = 22
                }
            }
        }
    }
    
    -- Register the layout
    Phoenix_UI.layouts.Skins = layout
    
    -- Get the Skins module
    local SkinsModule = Phoenix_UI:GetModule("Skins", true)
    
    -- Connect the layout to the module
    if SkinsModule then
        SkinsModule.layout = layout
        if SkinsModule.OnLayoutRegistered then
            SkinsModule:OnLayoutRegistered(layout)
        end
    end
end
