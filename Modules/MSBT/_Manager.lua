local MSBTManager = Phoenix_UI:NewModule('MSBT.Manager', "AceEvent-3.0")

function MSBTManager:OnInitialize()
    -- Database
    self.db = Phoenix_UI.db
    
    -- Ensure MSBT settings exist
    if not self.db.profile.msbt then
        self.db.profile.msbt = {
            enabled = false,
            __initialized = true  -- Initialization flag
        }
        
        -- Immediately save
        if Phoenix_UI.ForceSaveDB then
            Phoenix_UI:ForceSaveDB()
        elseif Phoenix_UI.SaveDB then
            Phoenix_UI:SaveDB()
        end
    else
        -- Ensure the initialization flag is set
        self.db.profile.msbt.__initialized = true
    end
    
    -- Register callbacks for whenever the MSBT settings change
    self.db.RegisterCallback(self, "OnProfileChanged", "UpdateSettings")
    self.db.RegisterCallback(self, "OnProfileCopied", "UpdateSettings")
    self.db.RegisterCallback(self, "OnProfileReset", "UpdateSettings")
    
    -- Register an event to make sure MSBT is initialized 
    self:RegisterEvent("PLAYER_ENTERING_WORLD", "InitMSBT")
end

function MSBTManager:OnEnable()
    -- Initial settings check
    self:UpdateSettings()
    
    -- Connect to the Phoenix_UI layout system
    if Phoenix_UI and Phoenix_UI.layouts and Phoenix_UI.layouts.Msbt then
        self.layout = Phoenix_UI.layouts.Msbt
        if self.OnLayoutRegistered then
            self:OnLayoutRegistered(self.layout)
        end
    end
    
    -- Create initial backup
    C_Timer.After(5, function()
        self:BackupSettings()
    end)
end

function MSBTManager:InitMSBT()
    -- Make sure MikSBT is initialized (since it's embedded)
    C_Timer.After(1, function()
        -- Run diagnostics after a short delay to check for issues
        C_Timer.After(2, function()
            self:DiagnoseSettings()
        end)
        
        -- Check if MikSBT is available
        if not MikSBT then
            print("|cffFF7D0APhoenix|r|cffFF0000_|r|cffFFD100UI|r: MikSBT is not properly initialized. Attempting to initialize the embedded version...")
            
            -- Try to initialize the helper functions first
            if _G.Phoenix_UI_InitMSBTHelpers and _G.Phoenix_UI_InitMSBTHelpers() then
                print("|cffFF7D0APhoenix|r|cffFF0000_|r|cffFFD100UI|r: MikSBT helpers initialized.")
            end
            
            -- Try again after another delay
            C_Timer.After(1, function()
                if not MikSBT then
                    print("|cffFF7D0APhoenix|r|cffFF0000_|r|cffFFD100UI|r: Failed to initialize MikSBT. Please restart your game client.")
                    return
                end
                
                self:UpdateSettings()
            end)
            return
        end
        
        -- Initialize the helper functions
        if _G.Phoenix_UI_InitMSBTHelpers then
            local success = _G.Phoenix_UI_InitMSBTHelpers()
            if Phoenix and Phoenix.debug and success then
                print("|cffFF7D0APhoenix|r|cffFF0000_|r|cffFFD100UI|r: MikSBT helpers successfully initialized.")
            end
        end
        
        -- Apply the settings
        self:UpdateSettings()
    end)
end

function MSBTManager:BackupSettings()
    -- Skip if no settings exist
    if not self.db or not self.db.profile or not self.db.profile.msbt then return end
    
    -- Create backup in Phoenix_UIPerCharDB if it doesn't exist
    if not Phoenix_UIPerCharDB then Phoenix_UIPerCharDB = {} end
    
    -- Create a backup of MSBT settings
    Phoenix_UIPerCharDB.MSBTBackup = {
        enabled = self.db.profile.msbt.enabled,
        __timestamp = time(),
        __characterName = UnitName("player"),
        __realmName = GetRealmName()
    }
    
    -- Force save of per-character database
    if FlushSettingsDB then FlushSettingsDB() end
    if FlushSavedVariables then FlushSavedVariables() end
    
    if Phoenix and Phoenix.debug then
        print("|cffFF7D0APhoenix|r|cffFF0000_|r|cffFFD100UI|r: MSBT settings backed up")
    end
    
    return true
end

function MSBTManager:RestoreSettingsIfNeeded()
    -- Check if we have a valid backup
    if not Phoenix_UIPerCharDB or not Phoenix_UIPerCharDB.MSBTBackup then return false end
    
    -- Check if current settings are missing or corrupted
    if not self.db or not self.db.profile or not self.db.profile.msbt or not self.db.profile.msbt.__initialized then
        -- We need to restore from backup
        print("|cffFF7D0APhoenix|r|cffFF0000_|r|cffFFD100UI|r: MSBT settings corrupted, restoring from backup...")
        
        -- Create settings if needed
        if not self.db.profile.msbt then
            self.db.profile.msbt = {}
        end
        
        -- Restore settings
        self.db.profile.msbt.enabled = Phoenix_UIPerCharDB.MSBTBackup.enabled
        self.db.profile.msbt.__initialized = true
        self.db.profile.msbt.__restoredAt = time()
        self.db.profile.msbt.__restoredFrom = Phoenix_UIPerCharDB.MSBTBackup.__timestamp or 0
        
        -- Save immediately
        if Phoenix_UI.ForceSaveDB then
            Phoenix_UI:ForceSaveDB()
        elseif Phoenix_UI.SaveDB then
            Phoenix_UI:SaveDB()
        end
        
        -- Force flush again
        if FlushSettingsDB then FlushSettingsDB() end
        if FlushSavedVariables then FlushSavedVariables() end
        
        print("|cffFF7D0APhoenix|r|cffFF0000_|r|cffFFD100UI|r: MSBT settings restored successfully")
        return true
    end
    
    return false
end

function MSBTManager:UpdateSettings()
    -- First try to restore settings if needed
    self:RestoreSettingsIfNeeded()
    
    -- Ensure MSBT database settings exist
    if not self.db.profile.msbt then
        self.db.profile.msbt = {
            enabled = false,
            __initialized = true
        }
    end
    
    -- Skip if MikSBT is not available yet
    if not MikSBT then
        return
    end
    
    -- Initialize the helper functions again if they're not already initialized
    if _G.Phoenix_UI_InitMSBTHelpers then
        _G.Phoenix_UI_InitMSBTHelpers()
    end
    
    -- Handle the enabling/disabling of MSBT based on the profile setting
    local msbtEnabled = self.db.profile.msbt.enabled
    
    -- Check if the user has MSBT enabled in settings
    if msbtEnabled then
        -- If MikSBT exists (embedded version), enable it
        if MikSBT.IsEnabled and not MikSBT:IsEnabled() and MikSBT.EnableAddon then
            MikSBT:EnableAddon()
            
            -- Initialize MSBT Main if it exists and needs to be initialized
            if MikSBT.Main and MikSBT.Main.Initialize and not MikSBT.Main.initialized then
                MikSBT.Main:Initialize()
            end
            
            if Phoenix and Phoenix.debug then
                print("|cffFF7D0APhoenix|r|cffFF0000_|r|cffFFD100UI|r: MSBT activated")
            end
        end
    else
        -- When disabled, disable the embedded version if possible
        if MikSBT.IsEnabled and MikSBT:IsEnabled() and MikSBT.DisableAddon then
            MikSBT:DisableAddon()
            if Phoenix and Phoenix.debug then
                print("|cffFF7D0APhoenix|r|cffFF0000_|r|cffFFD100UI|r: MSBT deactivated")
            end
        end
    end
    
    -- Use Phoenix_UI's ForceSaveDB function which ensures immediate saving
    if Phoenix_UI and Phoenix_UI.ForceSaveDB then
        Phoenix_UI:ForceSaveDB()
    -- Fallback to regular SaveDB if ForceSaveDB isn't available
    elseif Phoenix_UI and Phoenix_UI.SaveDB then
        Phoenix_UI:SaveDB()
        
        -- Attempt to immediately flush saved variables to disk
        if FlushSettingsDB then
            FlushSettingsDB() 
        elseif FlushSavedVariables then
            FlushSavedVariables()
        end
    end
    
    -- Double-check that the data was saved to profile
    if self.db.profile.msbt.enabled ~= msbtEnabled then
        print("|cffFF7D0APhoenix|r|cffFF0000_|r|cffFFD100UI|r: Warning - MSBT settings may not be saving properly.")
        -- Force the setting again
        self.db.profile.msbt.enabled = msbtEnabled
        
        -- Try another save approach
        if Phoenix_UI and Phoenix_UI.db and Phoenix_UI.db.sv then
            -- Mark as requiring flush
            Phoenix_UI.db.sv.__needsFlush = true
            -- Force immediate write again
            if FlushSettingsDB then FlushSettingsDB() end
            if FlushSavedVariables then FlushSavedVariables() end
        end
    end
    
    -- Backup the settings after any changes
    self:BackupSettings()
end

-- Function to open MSBT options window
function MSBTManager:OpenMSBTOptions()
    -- Make sure MSBT is available
    if not MikSBT then
        print("|cffFF7D0APhoenix|r|cffFF0000_|r|cffFFD100UI|r: MikSBT is not available. Trying to initialize it...")
        
        -- Try to initialize the helper functions
        if _G.Phoenix_UI_InitMSBTHelpers then
            local success = _G.Phoenix_UI_InitMSBTHelpers()
            if success then
                print("|cffFF7D0APhoenix|r|cffFF0000_|r|cffFFD100UI|r: Successfully initialized MikSBT helpers.")
            end
        end
        
        -- Try again after a short delay
        C_Timer.After(0.5, function()
            if not MikSBT then
                print("|cffFF7D0APhoenix|r|cffFF0000_|r|cffFFD100UI|r: MikSBT is still not available. Please restart your game client.")
                return false
            end
            
            -- Recursively call ourselves now that MikSBT might be available
            self:OpenMSBTOptions()
        end)
        return false
    end
    
    -- Make sure MSBT is enabled first - if not, we'll enable it temporarily for the options
    local wasDisabled = false
    if not self.db.profile.msbt.enabled then
        print("|cffFF7D0APhoenix|r|cffFF0000_|r|cffFFD100UI|r: Temporarily enabling MSBT to access options.")
        wasDisabled = true
    end
    
    -- Enable MSBT if it's not already enabled
    if MikSBT.IsEnabled and not MikSBT:IsEnabled() and MikSBT.EnableAddon then
        MikSBT:EnableAddon()
        
        -- Initialize MSBT Main if it exists and needs to be initialized
        if MikSBT.Main and MikSBT.Main.Initialize and not MikSBT.Main.initialized then
            MikSBT.Main:Initialize()
        end
        
        if Phoenix and Phoenix.debug then
            print("|cffFF7D0APhoenix|r|cffFF0000_|r|cffFFD100UI|r: MSBT activated")
        end
    end
    
    -- MSBTOptions is loaded directly in modules/load.xml, not as a separate addon
    -- Check if the MSBTOptions is available
    if not MSBTOptions then
        print("|cffFF7D0APhoenix|r|cffFF0000_|r|cffFFD100UI|r: MSBTOptions module is not available. Trying to initialize it...")
        
        -- Try again after a short delay to see if it becomes available
        C_Timer.After(1, function()
            if not MSBTOptions then
                print("|cffFF7D0APhoenix|r|cffFF0000_|r|cffFFD100UI|r: MSBTOptions still not available. Please report this issue.")
                
                -- If it was disabled before and still not available, disable it again
                if wasDisabled and MikSBT.IsEnabled and MikSBT:IsEnabled() and MikSBT.DisableAddon then
                    MikSBT:DisableAddon()
                end
                
                return false
            end
            
            -- Recursively call ourselves now that MSBTOptions might be available
            self:OpenMSBTOptions()
        end)
        return false
    end
    
    -- Now try to open the options window using various methods
    local success = false
    
    -- Method 1: Try using the MSBTOptions.Main.ShowMainFrame method (most common)
    if MSBTOptions.Main and MSBTOptions.Main.ShowMainFrame then
        MSBTOptions.Main.ShowMainFrame()
        success = true
    -- Method 2: Try using MikSBT.Profiles.ShowOptions method (fallback)
    elseif MikSBT.Profiles and MikSBT.Profiles.ShowOptions then
        MikSBT.Profiles.ShowOptions()
        success = true
    -- Method 3: Last resort, use the slash command handler
    elseif MikSBT.COMMAND and SlashCmdList["MSBT"] then
        SlashCmdList["MSBT"]("")
        success = true
    else
        print("|cffFF7D0APhoenix|r|cffFF0000_|r|cffFFD100UI|r: Unable to open MSBT options. Try typing /msbt in chat.")
        success = false
    end
    
    -- If it was disabled before and we're just showing options, disable it again
    if wasDisabled and MikSBT.IsEnabled and MikSBT:IsEnabled() and MikSBT.DisableAddon then
        -- Set a timer to disable it after the options window is done
        C_Timer.After(0.5, function()
            if self.db.profile.msbt.enabled then
                -- User enabled it in options, so we should keep it enabled
                return
            end
            
            -- Otherwise, disable it again
            MikSBT:DisableAddon()
            if Phoenix and Phoenix.debug then
                print("|cffFF7D0APhoenix|r|cffFF0000_|r|cffFFD100UI|r: MSBT deactivated (returning to previous state)")
            end
        end)
    end
    
    return success
end

-- Add after InitMSBT function
function MSBTManager:DiagnoseSettings()
    -- Only run on first player login
    if self.diagnosisRun then return end
    self.diagnosisRun = true
    
    -- Check for Phoenix_UIDB existence
    if not Phoenix_UIDB then
        return false
    end
    
    -- Check for profiles in Phoenix_UIDB
    if not Phoenix_UIDB.profiles then
        return false
    end
    
    -- Find active profile
    local activeProfile = Phoenix_UIDB.profileKeys and Phoenix_UIDB.profileKeys[UnitName("player").." - "..GetRealmName()]
    if not activeProfile then
        return false
    end
    
    -- Check if active profile data exists
    if not Phoenix_UIDB.profiles[activeProfile] then
        return false
    end
    
    -- Check if MSBT settings exist in active profile
    if not Phoenix_UIDB.profiles[activeProfile].msbt then
        return false
    end
    
    return true
end 