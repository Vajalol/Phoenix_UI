function Phoenix_UI:SaveDB(force)
    -- If no database, just return
    if not self.db then return end
    
    -- Debug info
    local debug = self.debug or false
    if debug then
        print("Phoenix_UI: SaveDB called")
    end
    
    -- Check if we need to perform a save operation by checking if anything has changed
    local hasChanges = force or false
    
    -- Check if any modules have been modified
    if not hasChanges and _G["Phoenix_UIDB"] and _G["Phoenix_UIDB"].__modifiedModules then
        for _, _ in pairs(_G["Phoenix_UIDB"].__modifiedModules) do
            hasChanges = true
            break
        end
    end
    
    -- Check if settings change indicator is set
    if not hasChanges and self.settingsChanged then
        hasChanges = true
        if debug then
            print("Phoenix_UI: Save triggered by settingsChanged flag")
        end
    end
    
    -- Skip save if nothing changed and not forced
    if not hasChanges and not force then
        if debug then
            print("Phoenix_UI: Skipping save - no changes detected")
        end
        return true
    end
    
    -- Check for combat lockdown - if in combat, queue the save for later
    if InCombatLockdown() and not force then
        if not self.pendingSaves then 
            self.pendingSaves = {}
            -- Create the event handler if it doesn't exist
            if not self.ProcessPendingSaves then
                self.ProcessPendingSaves = function(self)
                    if InCombatLockdown() then return end
                    if debug then
                        print("Phoenix_UI: Processing " .. #self.pendingSaves .. " pending saves after combat")
                    end
                    -- Process all pending saves
                    for _, saveData in ipairs(self.pendingSaves) do
                        self:SaveDB(true)
                    end
                    -- Clear the queue
                    wipe(self.pendingSaves)
                    -- Unregister the event
                    self:UnregisterEvent("PLAYER_REGEN_ENABLED")
                end
            end
            -- Register the event handler
            self:RegisterEvent("PLAYER_REGEN_ENABLED", "ProcessPendingSaves")
        end
        -- Add to pending saves
        table.insert(self.pendingSaves, {time = GetTime()})
        if debug then
            print("Phoenix_UI: Save queued due to combat lockdown")
        end
        return false
    end
    
    -- First, commit any pending changes from widgets
    self:CommitPendingChanges()
    
    -- Validate settings before saving
    self:ValidateSettings()
    
    -- Ensure any pending changes are written to the database
    if self.db.profile then
        -- Get current profile
        local currentProfile = self.db.keys and self.db.keys.profile or "Default"
        
        -- ENHANCED: Ensure profile structure in both local and global db
        if not _G["Phoenix_UIDB"] then
            _G["Phoenix_UIDB"] = {}
        end
        
        if not _G["Phoenix_UIDB"].__modifiedModules then
            _G["Phoenix_UIDB"].__modifiedModules = {}
        end
        
        if not _G["Phoenix_UIDB"].profiles then
            _G["Phoenix_UIDB"].profiles = {}
        end
        
        if not _G["Phoenix_UIDB"].profiles[currentProfile] then
            _G["Phoenix_UIDB"].profiles[currentProfile] = {}
        end
        
        -- ENHANCED: Also ensure Default profile exists as fallback
        if not _G["Phoenix_UIDB"].profiles.Default then
            _G["Phoenix_UIDB"].profiles.Default = {}
        end
        
        -- Add debug info marker to help track save issues
        if debug then
            print("Phoenix_UI: SaveDB saving to profile " .. currentProfile)
        end
        _G["Phoenix_UIDB"].__lastSaveMethod = "SaveDB_Enhanced"
        _G["Phoenix_UIDB"].__lastSaveTime = GetTime()
        
        -- Add metadata
        _G["Phoenix_UIDB"].__lastAccess = GetTime()
        _G["Phoenix_UIDB"].__addon_version = self.version or "unknown"
        
        -- Support for ModuleIntegration - ensure module connections are saved
        -- Use regular GetModule since we know the module name
        local moduleIntegration = self:GetModule("ModuleIntegration", true)
        if moduleIntegration then
            if debug then
                print("Phoenix_UI: Processing ModuleIntegration module")
            end
            
            -- Ensure moduleIntegration exists in profile
            if not self.db.profile.moduleIntegration then
                self.db.profile.moduleIntegration = {}
            end
            
            -- Don't try to call methods that may not exist
            -- Instead, just ensure the module data gets saved
            _G["Phoenix_UIDB"].__modifiedModules["moduleIntegration"] = GetTime()
                
            -- Save to global profile - use CopyTable for safety
            if self.db.profile.moduleIntegration then
                _G["Phoenix_UIDB"].profiles[currentProfile].moduleIntegration = 
                    CopyTable(self.db.profile.moduleIntegration)
            end
        end
        
        -- ENHANCED: Comprehensive module list to ensure ALL modules are saved
        local allModules = {
            -- Critical UI modules
            "general", "unitframes", "nameplates", "actionbars", "castbars", 
            "buffs", "tooltip", "map", "chat", "misc", "uiscaling", "fonts",
            -- Additional feature modules
            "msbt", "idtip", "buffoverlay", "cooldowntracker", "weakauras", 
            "mythicplus", "raidframes", "profiles",
            -- Legacy module names for compatibility
            "actionbar", "castbar", "buff"
        }
        
        -- ENHANCED: Process all modules in an optimized way
        for _, moduleName in ipairs(allModules) do
            if self.db.profile[moduleName] and type(self.db.profile[moduleName]) == "table" then
                if debug then
                    print("Phoenix_UI: Saving module " .. moduleName)
                end
                
                -- Track this module as modified
                _G["Phoenix_UIDB"].__modifiedModules[moduleName] = GetTime()
                
                -- Get current settings
                local currentSettings = self.db.profile[moduleName]
                
                -- Add timestamp to track when these settings were last modified
                currentSettings.__updated = GetTime()
                currentSettings.__saved_from = "SaveDB_Enhanced"
                
                -- Update in DB
                self.db.profile[moduleName] = currentSettings
                
                -- ENHANCED: Always use deep copy to ensure proper persistence
                -- Ensure profile exists
                if not _G["Phoenix_UIDB"].profiles[currentProfile][moduleName] then
                    _G["Phoenix_UIDB"].profiles[currentProfile][moduleName] = {}
                end
                
                -- Update the module settings in the global variable using deep copy
                _G["Phoenix_UIDB"].profiles[currentProfile][moduleName] = CopyTable(currentSettings)
                
                -- ENHANCED: Also save to Default profile as a fallback
                if moduleName ~= "profiles" then -- Skip profiles to avoid cross-contamination
                    _G["Phoenix_UIDB"].profiles.Default[moduleName] = CopyTable(currentSettings)
                end
                
                if debug then
                    print("Phoenix_UI: Updated global variable for " .. moduleName)
                end
            end
        end
        
        -- ENHANCED: Ensure character-to-profile mapping is correct
        local playerKey = UnitName("player") .. " - " .. GetRealmName()
        if not _G["Phoenix_UIDB"].profileKeys then
            _G["Phoenix_UIDB"].profileKeys = {}
        end
        _G["Phoenix_UIDB"].profileKeys[playerKey] = currentProfile
        
        -- Also check for specialized module namespaces
        local specializedModules = {
            "MSBT", "idTip", "BuffOverlay", "PremadeGroupsFilter", "CooldownTracker", 
            "actionbars", "castbars", "buffs", "map", "chat", "misc", "tooltip"
        }
        
        for _, moduleName in ipairs(specializedModules) do
            if self.moduleDB and self.moduleDB[moduleName] and self.moduleDB[moduleName].profile then
                if debug then
                    print("Phoenix_UI: Processing specialized module " .. moduleName)
                end
                
                -- Track this module as modified
                _G["Phoenix_UIDB"].__modifiedModules[moduleName] = GetTime()
                
                -- Force update of the moduleDB profile
                local currentSettings = self.moduleDB[moduleName].profile
                
                -- Add timestamp 
                currentSettings.__updated = GetTime()
                currentSettings.__saved_from = "SaveDB_specialized"
                
                -- Update in moduleDB
                self.moduleDB[moduleName].profile = CopyTable(currentSettings)
                
                -- Update the module settings in the main profile as well for redundancy
                local lowerName = moduleName:lower()
                if not self.db.profile[lowerName] then
                    self.db.profile[lowerName] = {}
                end
                
                -- Sync basic settings like enabled state
                if currentSettings.enabled ~= nil then
                    self.db.profile[lowerName].enabled = currentSettings.enabled
                    self.db.profile[lowerName].__updated = GetTime()
                end
            end
        end
        
        -- Update last save timestamp
        _G["Phoenix_UIDB"].__lastSaved = GetTime()
        _G["Phoenix_UIDB"].__currentProfile = currentProfile
        
        -- ENHANCED: Multiple flush attempts with error handling
        for i = 1, 3 do
            pcall(function()
                if FlushSettingsDB then
                    FlushSettingsDB() 
                elseif FlushSavedVariables then
                    FlushSavedVariables()
                end
            end)
            
            -- Attempt additional flushes with delays
            if i < 3 then
                C_Timer.After(0.2 * i, function()
                    pcall(function()
                        if FlushSettingsDB then
                            FlushSettingsDB() 
                        elseif FlushSavedVariables then
                            FlushSavedVariables()
                        end
                    end)
                end)
            end
        end
    end
    
    if debug then
        print("|cffFF7D0APhoenix|r|cffFF0000_|r|cffFFD100UI|r: Settings saved")
    else
        self:Print("Saving Phoenix UI settings...")
    end
    
    -- ENHANCED: Final verification to ensure critical modules are saved
    if _G["Phoenix_UIDB"] and self.db and self.db.profile then
        -- Mark this as a complete save cycle
        _G["Phoenix_UIDB"].__saveComplete = GetTime()
        
        -- Create backup data for emergency recovery
        if not _G["Phoenix_UI_EmergencyBackup"] then
            _G["Phoenix_UI_EmergencyBackup"] = {}
        end
        
        -- Store backup of current profile 
        local backupProfile = self.db.keys and self.db.keys.profile or "Default"
        _G["Phoenix_UI_EmergencyBackup"].lastProfile = backupProfile
        _G["Phoenix_UI_EmergencyBackup"].timestamp = GetTime()
        
        -- Create differential backup - only store recently modified modules for efficiency
        if not _G["Phoenix_UI_EmergencyBackup"].modules then
            _G["Phoenix_UI_EmergencyBackup"].modules = {}
        end
        
        -- Only save modules that have been recently modified
        for moduleName, modifiedTime in pairs(_G["Phoenix_UIDB"].__modifiedModules or {}) do
            if GetTime() - modifiedTime < 300 then -- Backup modules modified in the last 5 minutes
                _G["Phoenix_UI_EmergencyBackup"].modules[moduleName] = CopyTable(self.db.profile[moduleName] or {})
            end
        end
        
        -- Include character-specific data if available
        if Phoenix_UIPerCharDB then
            _G["Phoenix_UI_EmergencyBackup"].perChar = CopyTable(Phoenix_UIPerCharDB)
        end
        
        -- Reset the modified modules tracker after a successful save
        if not debug then
            wipe(_G["Phoenix_UIDB"].__modifiedModules)
        end
        
        -- Clear the settings changed flag
        self.settingsChanged = false
    end
    
    return true
end

-- ... rest of the code remains the same ...