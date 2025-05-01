local Layout = Phoenix_UI:NewModule('Config.Layout.Msbt')

-- Register the module to ensure it's loaded early
function Layout:OnInitialize()
    -- Immediately ensure database settings exist
    local db = Phoenix_UI.db
    if not db.profile.msbt then
        db.profile.msbt = {
            enabled = false,
            showIcons = true,
            normalFontSize = 18,
            critFontSize = 22,
            scrollHeight = 250,
            enableCooldowns = true,
            enableTriggers = true,
            showAllHeals = true,
            abbreviateNumbers = true,
            enableSounds = true,
            showSwingDamage = true,
            __initialized = true,  -- Flag to ensure settings are recognized
        }
        
        -- Save immediately on init
        if Phoenix_UI.ForceSaveDB then
            Phoenix_UI:ForceSaveDB()
        elseif Phoenix_UI.SaveDB then
            Phoenix_UI:SaveDB()
        end
    else
        -- Make sure the initialization flag is set
        db.profile.msbt.__initialized = true
        
        -- Ensure all settings exist (for users upgrading)
        db.profile.msbt.showIcons = db.profile.msbt.showIcons ~= false
        db.profile.msbt.normalFontSize = db.profile.msbt.normalFontSize or 18
        db.profile.msbt.critFontSize = db.profile.msbt.critFontSize or 22
        db.profile.msbt.scrollHeight = db.profile.msbt.scrollHeight or 250
        db.profile.msbt.enableCooldowns = db.profile.msbt.enableCooldowns ~= false
        db.profile.msbt.enableTriggers = db.profile.msbt.enableTriggers ~= false
        db.profile.msbt.showAllHeals = db.profile.msbt.showAllHeals ~= false
        db.profile.msbt.abbreviateNumbers = db.profile.msbt.abbreviateNumbers ~= false
        db.profile.msbt.enableSounds = db.profile.msbt.enableSounds ~= false
        db.profile.msbt.showSwingDamage = db.profile.msbt.showSwingDamage ~= false
    end
    
    -- Register the module to receive profile changes
    db.RegisterCallback(self, "OnProfileChanged", "RefreshSettings")
    db.RegisterCallback(self, "OnProfileCopied", "RefreshSettings")
    db.RegisterCallback(self, "OnProfileReset", "RefreshSettings")
end

-- Function to handle profile changes
function Layout:RefreshSettings()
    local db = Phoenix_UI.db
    
    -- Ensure MSBT settings exist after profile changes
    if not db.profile.msbt then
        db.profile.msbt = {
            enabled = false,
            showIcons = true,
            normalFontSize = 18,
            critFontSize = 22,
            scrollHeight = 250,
            enableCooldowns = true,
            enableTriggers = true,
            showAllHeals = true,
            abbreviateNumbers = true,
            enableSounds = true,
            showSwingDamage = true,
            __initialized = true,
        }
        
        -- Save immediately
        if Phoenix_UI.ForceSaveDB then
            Phoenix_UI:ForceSaveDB()
        elseif Phoenix_UI.SaveDB then
            Phoenix_UI:SaveDB()
        end
    end
    
    -- Force MSBT update
    local msbtManager = Phoenix_UI:GetModule('MSBT.Manager', true)
    if msbtManager and msbtManager.UpdateSettings then
        C_Timer.After(0.5, function()
            msbtManager:UpdateSettings()
        end)
    end
end

-- Helper function to apply MSBT settings
local function ApplyMSBTSettings()
    local db = Phoenix_UI.db
    local msbtManager = Phoenix_UI:GetModule('MSBT.Manager', true)
    
    if msbtManager and msbtManager.UpdateSettings then
        C_Timer.After(0.2, function()
            msbtManager:UpdateSettings()
        end)
    end
    
    -- Force saving
    if Phoenix_UI.ForceSaveDB then
        Phoenix_UI:ForceSaveDB()
    elseif Phoenix_UI.SaveDB then
        Phoenix_UI:SaveDB()
    end
end

function Layout:OnEnable()
    -- Database
    local db = Phoenix_UI.db

    -- Ensure msbt settings exist
    if not db.profile.msbt then
        db.profile.msbt = {
            enabled = false,
            showIcons = true,
            normalFontSize = 18,
            critFontSize = 22,
            scrollHeight = 250,
            enableCooldowns = true,
            enableTriggers = true,
            showAllHeals = true,
            abbreviateNumbers = true,
            enableSounds = true,
            showSwingDamage = true,
            __initialized = true,
        }
    else
        -- Make sure the initialization flag is set
        db.profile.msbt.__initialized = true
    end

    -- Layout
    Layout.layout = {
        layoutConfig = { padding = { top = 15 } },
        database = db.profile.msbt,
        rows = {
            {
                header = {
                    type = 'header',
                    label = 'MSBT - Scrolling Combat Text'
                }
            },
            {
                description = {
                    type = 'description',
                    text = "MikScrollingBattleText (MSBT) provides highly configurable scrolling combat text, showing damage, healing, buffs, debuffs, and more.",
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
                    label = 'Enable MSBT',
                    tooltip = 'Enable or disable the MSBT scrolling combat text feature',
                    get = function() return db.profile.msbt.enabled end,
                    set = function(value)
                        db.profile.msbt.enabled = value
                        
                        -- Update MSBT settings through the manager
                        local msbtManager = Phoenix_UI:GetModule('MSBT.Manager')
                        if msbtManager then
                            msbtManager:UpdateSettings()
                            
                            -- Provide user feedback
                            if value then
                                print("|cffFF7D0APhoenix|r|cffFF0000_|r|cffFFD100UI|r: MSBT enabled. You can configure it using the options below.")
                            else
                                print("|cffFF7D0APhoenix|r|cffFF0000_|r|cffFFD100UI|r: MSBT disabled.")
                            end
                            
                            -- Force save immediately after changing the setting
                            if Phoenix_UI.ForceSaveDB then
                                Phoenix_UI:ForceSaveDB()
                                
                                -- Ensure value is correct in database
                                if db.profile.msbt.enabled ~= value then
                                    print("|cffFF7D0APhoenix|r|cffFF0000_|r|cffFFD100UI|r: Warning - Settings may not be saving correctly. Attempting to fix...")
                                    -- Last resort, try to flush settings
                                    if FlushSettingsDB then FlushSettingsDB() end
                                    if FlushSavedVariables then FlushSavedVariables() end
                                end
                            end
                        else
                            print("|cffFF7D0APhoenix|r|cffFF0000_|r|cffFFD100UI|r: MSBT Manager module not found. Please report this issue.")
                        end
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
                    label = 'General Settings',
                    column = 12,
                    order = 5
                }
            },
            {
                showIcons = {
                    type = 'checkbox',
                    label = 'Show Icons',
                    tooltip = 'Show spell and ability icons with combat text',
                    get = function() return db.profile.msbt.showIcons end,
                    set = function(value)
                        db.profile.msbt.showIcons = value
                        ApplyMSBTSettings()
                    end,
                    disabled = function() return not db.profile.msbt.enabled end,
                    column = 4,
                    order = 6
                },
                abbreviateNumbers = {
                    type = 'checkbox',
                    label = 'Abbreviate Numbers',
                    tooltip = 'Shorten numbers like 1000 to 1k, 1000000 to 1M',
                    get = function() return db.profile.msbt.abbreviateNumbers end,
                    set = function(value)
                        db.profile.msbt.abbreviateNumbers = value
                        ApplyMSBTSettings()
                    end,
                    disabled = function() return not db.profile.msbt.enabled end,
                    column = 4,
                    order = 7
                },
                enableSounds = {
                    type = 'checkbox',
                    label = 'Enable Sounds',
                    tooltip = 'Play sound effects for certain events',
                    get = function() return db.profile.msbt.enableSounds end,
                    set = function(value)
                        db.profile.msbt.enableSounds = value
                        ApplyMSBTSettings()
                    end,
                    disabled = function() return not db.profile.msbt.enabled end,
                    column = 4,
                    order = 8
                }
            },
            {
                normalFontSize = {
                    type = 'slider',
                    label = 'Normal Font Size',
                    tooltip = 'Size of the font for regular hits',
                    min = 10,
                    max = 30,
                    step = 1,
                    get = function() return db.profile.msbt.normalFontSize end,
                    set = function(value)
                        db.profile.msbt.normalFontSize = value
                        ApplyMSBTSettings()
                    end,
                    disabled = function() return not db.profile.msbt.enabled end,
                    column = 6,
                    order = 9
                },
                critFontSize = {
                    type = 'slider',
                    label = 'Critical Font Size',
                    tooltip = 'Size of the font for critical hits',
                    min = 10,
                    max = 36,
                    step = 1,
                    get = function() return db.profile.msbt.critFontSize end,
                    set = function(value)
                        db.profile.msbt.critFontSize = value
                        ApplyMSBTSettings()
                    end,
                    disabled = function() return not db.profile.msbt.enabled end,
                    column = 6,
                    order = 10
                }
            },
            {
                scrollHeight = {
                    type = 'slider',
                    label = 'Scroll Area Height',
                    tooltip = 'Height of the scrolling text areas',
                    min = 150,
                    max = 600,
                    step = 10,
                    get = function() return db.profile.msbt.scrollHeight end,
                    set = function(value)
                        db.profile.msbt.scrollHeight = value
                        ApplyMSBTSettings()
                    end,
                    disabled = function() return not db.profile.msbt.enabled end,
                    column = 12,
                    order = 11
                }
            },
            {
                divider3 = {
                    type = 'divider',
                    column = 12,
                    order = 12
                }
            },
            {
                header3 = {
                    type = 'header',
                    label = 'Combat Text Settings',
                    column = 12,
                    order = 13
                }
            },
            {
                enableCooldowns = {
                    type = 'checkbox',
                    label = 'Show Cooldowns',
                    tooltip = 'Show cooldown notifications for abilities',
                    get = function() return db.profile.msbt.enableCooldowns end,
                    set = function(value)
                        db.profile.msbt.enableCooldowns = value
                        ApplyMSBTSettings()
                    end,
                    disabled = function() return not db.profile.msbt.enabled end,
                    column = 4,
                    order = 14
                },
                enableTriggers = {
                    type = 'checkbox',
                    label = 'Enable Triggers',
                    tooltip = 'Enable combat event triggers',
                    get = function() return db.profile.msbt.enableTriggers end,
                    set = function(value)
                        db.profile.msbt.enableTriggers = value
                        ApplyMSBTSettings()
                    end,
                    disabled = function() return not db.profile.msbt.enabled end,
                    column = 4,
                    order = 15
                },
                showSwingDamage = {
                    type = 'checkbox',
                    label = 'Show Auto Attacks',
                    tooltip = 'Show auto-attack damage',
                    get = function() return db.profile.msbt.showSwingDamage end,
                    set = function(value)
                        db.profile.msbt.showSwingDamage = value
                        ApplyMSBTSettings()
                    end,
                    disabled = function() return not db.profile.msbt.enabled end,
                    column = 4,
                    order = 16
                }
            },
            {
                showAllHeals = {
                    type = 'checkbox',
                    label = 'Show All Heals',
                    tooltip = 'Show healing done to all players, not just yourself',
                    get = function() return db.profile.msbt.showAllHeals end,
                    set = function(value)
                        db.profile.msbt.showAllHeals = value
                        ApplyMSBTSettings()
                    end,
                    disabled = function() return not db.profile.msbt.enabled end,
                    column = 12,
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
                    label = 'Advanced Configuration',
                    column = 12,
                    order = 19
                }
            },
            {
                msbtconfig = {
                    type = 'button',
                    text = 'Open MSBT Configuration',
                    tooltip = 'Open the full MSBT configuration panel for advanced settings',
                    onClick = function()
                        -- Initialize MikSBT helpers if they exist
                        if _G.Phoenix_UI_InitMSBTHelpers then
                            _G.Phoenix_UI_InitMSBTHelpers()
                        end
                        
                        -- Some addons load on-demand, try to ensure MSBT is loaded
                        if MikSBT and MikSBT.IsModDisabled and not MikSBT:IsModDisabled() then
                            -- Direct access to MSBTOptions options
                            if MSBTOptions and MSBTOptions.Main and MSBTOptions.Main.ShowMainFrame then
                                MSBTOptions.Main.ShowMainFrame()
                                return
                            end
                            
                            -- If that fails, check if we can load MSBTOptions
                            if not IsAddOnLoaded("MSBTOptions") then
                                print("|cffFF7D0APhoenix|r|cffFF0000_|r|cffFFD100UI|r: Loading MSBT Options addon...")
                                LoadAddOn("MSBTOptions")
                                C_Timer.After(0.5, function()
                                    -- Now that MSBT is available, try to open options
                                    local msbtManager = Phoenix_UI:GetModule('MSBT.Manager')
                                    if msbtManager then
                                        msbtManager:OpenMSBTOptions()
                                    end
                                end)
                                return
                            end
                        end
                        
                        local msbtManager = Phoenix_UI:GetModule('MSBT.Manager')
                        if msbtManager then
                            local success = msbtManager:OpenMSBTOptions()
                            if not success then
                                print("|cffFF7D0APhoenix|r|cffFF0000_|r|cffFFD100UI|r: Failed to open MSBT options. You can try manually typing /msbt in chat.")
                            end
                        else
                            print("|cffFF7D0APhoenix|r|cffFF0000_|r|cffFFD100UI|r: MSBT Manager module not found. Please report this issue.")
                        end
                    end,
                    column = 12,
                    order = 20
                }
            },
            {
                divider5 = {
                    type = 'divider',
                    column = 12,
                    order = 21
                }
            },
            {
                header5 = {
                    type = 'header',
                    label = 'Troubleshooting',
                    column = 12,
                    order = 22
                }
            },
            {
                troubleshooting = {
                    type = 'button',
                    text = 'Fix MSBT Issues',
                    tooltip = 'Try to fix common MSBT issues by reinitializing the addon',
                    onClick = function()
                        -- Try to initialize MSBT helpers
                        if _G.Phoenix_UI_InitMSBTHelpers then
                            local success = _G.Phoenix_UI_InitMSBTHelpers()
                            if success then
                                print("|cffFF7D0APhoenix|r|cffFF0000_|r|cffFFD100UI|r: Successfully reinitialized MSBT helpers.")
                            else
                                print("|cffFF7D0APhoenix|r|cffFF0000_|r|cffFFD100UI|r: MSBT helper initialization pending. Try again in a few seconds.")
                            end
                        end
                        
                        -- Try to update MSBT settings
                        local msbtManager = Phoenix_UI:GetModule('MSBT.Manager')
                        if msbtManager then
                            msbtManager:InitMSBT()
                            print("|cffFF7D0APhoenix|r|cffFF0000_|r|cffFFD100UI|r: MSBT initialization triggered. Please check if issues are resolved.")
                        else
                            print("|cffFF7D0APhoenix|r|cffFF0000_|r|cffFFD100UI|r: MSBT Manager module not found. Please report this issue.")
                        end
                    end,
                    column = 6,
                    order = 23
                },
                reload = {
                    type = 'button',
                    text = 'Reload UI',
                    tooltip = 'Reload the user interface to apply all changes',
                    onClick = function()
                        ReloadUI()
                    end,
                    column = 6,
                    order = 24
                }
            }
        },
    }
    
    -- Register the layout
    Phoenix_UI.layouts.MSBT = Layout.layout
    
    -- Get the MSBT module
    local MSBTModule = Phoenix_UI:GetModule("MSBT.Manager", true)
    
    -- Connect the layout to the module
    if MSBTModule then
        MSBTModule.layout = Layout.layout
        if MSBTModule.OnLayoutRegistered then
            MSBTModule:OnLayoutRegistered(Layout.layout)
        end
    end
end