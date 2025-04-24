local Layout = Phoenix_UI:NewModule('Config.Layout.Msbt')

-- Register the module to ensure it's loaded early
function Layout:OnInitialize()
    -- Immediately ensure database settings exist
    local db = Phoenix_UI.db
    if not db.profile.msbt then
        db.profile.msbt = {
            enabled = false,
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

function Layout:OnEnable()
    -- Database
    local db = Phoenix_UI.db

    -- Ensure msbt settings exist
    if not db.profile.msbt then
        db.profile.msbt = {
            enabled = false,
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
                enabled = {
                    type = 'checkbox',
                    label = 'Enable MSBT',
                    desc = 'Enable or disable the MSBT scrolling combat text feature',
                    get = function() return db.profile.msbt.enabled end,
                    set = function(value)
                        db.profile.msbt.enabled = value
                        
                        -- Update MSBT settings through the manager
                        local msbtManager = Phoenix_UI:GetModule('MSBT.Manager')
                        if msbtManager then
                            msbtManager:UpdateSettings()
                            
                            -- Provide user feedback
                            if value then
                                print("|cffFF7D0APhoenix|r|cffFF0000_|r|cffFFD100UI|r: MSBT enabled. You can configure it using the button below.")
                            else
                                print("|cffFF7D0APhoenix|r|cffFF0000_|r|cffFFD100UI|r: MSBT disabled.")
                            end
                            
                            -- Force save immediately after changing the setting
                            if Phoenix_UI.ForceSaveDB then
                                Phoenix_UI:ForceSaveDB()
                                
                                -- Ensure value is correct in database
                                if db.profile.msbt.enabled ~= value then
                                    print("|cffFF7D0APhoenix|r|cffFF0000_|r|cffFFD100UI|r: Warning - Settings may not be saving correctly. Attempting to fix...")
                                    -- Force it again
                                    db.profile.msbt.enabled = value
                                    Phoenix_UI:ForceSaveDB()
                                    
                                    -- Force flush
                                    if FlushSettingsDB then FlushSettingsDB() end
                                    if FlushSavedVariables then FlushSavedVariables() end
                                end
                            end
                        else
                            print("|cffFF7D0APhoenix|r|cffFF0000_|r|cffFFD100UI|r: MSBT Manager module not found. Please report this issue.")
                        end
                    end,
                    column = 3,
                    order = 1
                }
            },
            {
                msbtconfig = {
                    type = 'button',
                    text = 'Open MSBT Configuration',
                    onClick = function()
                        -- Initialize MikSBT helpers if they exist
                        if _G.Phoenix_UI_InitMSBTHelpers then
                            _G.Phoenix_UI_InitMSBTHelpers()
                        end
                        
                        -- First check if MSBT is properly loaded
                        if not MikSBT then
                            print("|cffFF7D0APhoenix|r|cffFF0000_|r|cffFFD100UI|r: MSBT is not properly loaded. Trying to initialize...")
                            
                            -- Try again after a short delay
                            C_Timer.After(1, function()
                                if not MikSBT then
                                    print("|cffFF7D0APhoenix|r|cffFF0000_|r|cffFFD100UI|r: MSBT could not be initialized. Please enable MSBT and reload your UI.")
                                    return
                                end
                                
                                -- Now that MSBT is available, try to open options
                                local msbtManager = Phoenix_UI:GetModule('MSBT.Manager')
                                if msbtManager then
                                    msbtManager:OpenMSBTOptions()
                                end
                            end)
                            return
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
                    column = 3,
                    order = 2
                }
            },
            {
                info = {
                    type = 'label',
                    label = "MSBT provides highly configurable scrolling combat text. Enable the feature using the checkbox above, then use the button to open MSBT's configuration panel.",
                    fontSize = 12,
                    fontObject = "GameFontNormalSmall",
                    color = {r = 1, g = 0.82, b = 0},
                    column = 3,
                    order = 3
                }
            },
            {
                spacer = {
                    type = 'spacer',
                    column = 3,
                    order = 4,
                    height = 20
                }
            },
            {
                troubleshooting = {
                    type = 'button',
                    text = 'Fix MSBT Issues',
                    desc = 'Try to fix common MSBT issues by reinitializing the addon',
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
                    column = 3,
                    order = 5
                }
            },
            {
                reload = {
                    type = 'button',
                    text = 'Reload UI',
                    desc = 'Reload the user interface to apply changes',
                    onClick = function()
                        ReloadUI()
                    end,
                    column = 3,
                    order = 6
                }
            }
        },
    }
end 