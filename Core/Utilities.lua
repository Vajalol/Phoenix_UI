-- Utility functions for Phoenix UI

-- Force save all settings to disk before reload
function Phoenix_UI:ForceSettingsSave()
    -- Debug output if debug mode is enabled
    local debug = self.debug or false
    if debug then
        print("Phoenix_UI: ForceSettingsSave called")
    end
    
    -- Status reporting variables
    local success = true
    local steps_completed = 0
    
    -- First commit any pending changes
    if self.CommitPendingChanges then
        local status = pcall(function() self:CommitPendingChanges() end)
        success = success and status
        if status then steps_completed = steps_completed + 1 end
        if debug then print("Phoenix_UI: CommitPendingChanges: " .. (status and "Success" or "Failed")) end
    end
    
    -- Then save all settings
    if self.SaveAllSettings then
        local status = pcall(function() self:SaveAllSettings() end)
        success = success and status
        if status then steps_completed = steps_completed + 1 end
        if debug then print("Phoenix_UI: SaveAllSettings: " .. (status and "Success" or "Failed")) end
    end
    
    -- Also save tab settings specifically
    if self.SaveAllTabSettings then
        local status = pcall(function() self:SaveAllTabSettings() end)
        success = success and status
        if status then steps_completed = steps_completed + 1 end
        if debug then print("Phoenix_UI: SaveAllTabSettings: " .. (status and "Success" or "Failed")) end
    end
    
    -- Ensure we synchronize between databases
    if self.SyncModuleSettings then
        local status = pcall(function() self:SyncModuleSettings(true) end)
        success = success and status
        if status then steps_completed = steps_completed + 1 end
        if debug then print("Phoenix_UI: SyncModuleSettings: " .. (status and "Success" or "Failed")) end
    end
    
    -- Direct update of global savedvariables
    local directSaveStatus = pcall(function()
        if self.db and self.db.profile then
            local currentProfile = self.db.keys and self.db.keys.profile or "Default"
            
            -- Ensure _G["Phoenix_UIDB"] exists
            if not _G["Phoenix_UIDB"] then
                _G["Phoenix_UIDB"] = {}
            end
            
            -- Ensure profiles table exists
            _G["Phoenix_UIDB"].profiles = _G["Phoenix_UIDB"].profiles or {}
            _G["Phoenix_UIDB"].profiles[currentProfile] = _G["Phoenix_UIDB"].profiles[currentProfile] or {}
            
            -- Copy each module's settings
            for moduleName, moduleData in pairs(self.db.profile) do
                if type(moduleData) == "table" then
                    _G["Phoenix_UIDB"].profiles[currentProfile][moduleName] = CopyTable(moduleData)
                end
            end
        end
    end)
    success = success and directSaveStatus
    if directSaveStatus then steps_completed = steps_completed + 1 end
    if debug then print("Phoenix_UI: Direct SaveVar Update: " .. (directSaveStatus and "Success" or "Failed")) end
    
    -- Force flush to disk using multiple methods for redundancy
    local flushStatus = pcall(function()
        if FlushSettingsDB then
            FlushSettingsDB()
        end
        if FlushSavedVariables then
            FlushSavedVariables()
        end
        -- Attempt to force the game client to save
        if SaveVariables then
            SaveVariables("Phoenix_UIDB")
        end
    end)
    success = success and flushStatus
    if flushStatus then steps_completed = steps_completed + 1 end
    if debug then print("Phoenix_UI: Flush to Disk: " .. (flushStatus and "Success" or "Failed")) end
    
    -- Final status message
    if debug then
        print("Phoenix_UI: ForceSettingsSave completed with " .. steps_completed .. " steps successful")
    end
    
    -- Fire saved event for any listeners
    self:SendMessage("PHOENIX_UI_SETTINGS_SAVED")
    
    return success
end 

-- Function to diagnose profile issues
function Phoenix_UI:DiagnoseProfileIssues()
    -- Always show output for this diagnostic function
    print("|cffFF7D0APhoenix|r|cffFF0000_|r|cffFFD100UI|r: Profile Diagnostics")
    
    -- Get player and realm info
    local playerName = UnitName("player")
    local realmName = GetRealmName()
    local playerKey = playerName .. " - " .. realmName
    
    -- Report current AceDB profile info
    print("Current character: " .. playerKey)
    
    -- Check AceDB profile info
    if self.db then
        print("AceDB available: Yes")
        if self.db.keys then
            print("Current profile (AceDB): " .. (self.db.keys.profile or "nil"))
        else
            print("AceDB keys not found")
        end
        
        -- Check profile keys
        if self.db.sv and self.db.sv.profileKeys then
            local profileName = self.db.sv.profileKeys[playerKey]
            print("ProfileKeys entry: " .. (profileName or "nil"))
        else
            print("AceDB profileKeys not found")
        end
    else
        print("AceDB not available")
    end
    
    -- Check global variable structure
    if _G["Phoenix_UIDB"] then
        print("Global Phoenix_UIDB: Available")
        
        -- Check profiles
        if _G["Phoenix_UIDB"].profiles then
            print("Global profiles table: Available")
            local profileCount = 0
            for name, _ in pairs(_G["Phoenix_UIDB"].profiles) do
                profileCount = profileCount + 1
            end
            print("Number of profiles: " .. profileCount)
            
            -- Check Default profile
            if _G["Phoenix_UIDB"].profiles["Default"] then
                print("Default profile: Exists")
            else
                print("Default profile: Missing")
            end
        else
            print("Global profiles table: Missing")
        end
        
        -- Check profileKeys
        if _G["Phoenix_UIDB"].profileKeys then
            print("Global profileKeys table: Available")
            local globalProfileName = _G["Phoenix_UIDB"].profileKeys[playerKey]
            print("Global profileKeys entry: " .. (globalProfileName or "nil"))
        else
            print("Global profileKeys table: Missing")
        end
        
        -- Check metadata
        if _G["Phoenix_UIDB"].__currentProfile then
            print("Current profile marker: " .. _G["Phoenix_UIDB"].__currentProfile)
        end
        
        if _G["Phoenix_UIDB"].__lastSaved then
            local timeSince = GetTime() - _G["Phoenix_UIDB"].__lastSaved
            print("Last saved: " .. math.floor(timeSince) .. " seconds ago")
        end
    else
        print("Global Phoenix_UIDB: Missing")
    end
    
    -- Report if there's a mismatch
    if self.db and self.db.keys and _G["Phoenix_UIDB"] and _G["Phoenix_UIDB"].profileKeys then
        local aceProfile = self.db.keys.profile
        local globalProfile = _G["Phoenix_UIDB"].profileKeys[playerKey]
        
        if aceProfile ~= globalProfile then
            print("|cffFF0000CRITICAL ISSUE:|r Profile mismatch between AceDB and global table")
            print("AceDB profile: " .. (aceProfile or "nil"))
            print("Global profile key: " .. (globalProfile or "nil"))
        end
    end
    
    return true
end

-- Command to repair profile issues
function Phoenix_UI:RepairProfileAssignment()
    print("|cffFF7D0APhoenix|r|cffFF0000_|r|cffFFD100UI|r: Repairing profile assignment...")
    
    -- Get player key
    local playerName = UnitName("player")
    local realmName = GetRealmName()
    local playerKey = playerName .. " - " .. realmName
    
    -- Get current profile from AceDB
    local currentProfile = "Default"
    if self.db and self.db.keys and self.db.keys.profile then
        currentProfile = self.db.keys.profile
    end
    
    -- Fix global profileKeys table
    if _G["Phoenix_UIDB"] then
        -- Create profileKeys if missing
        if not _G["Phoenix_UIDB"].profileKeys then
            _G["Phoenix_UIDB"].profileKeys = {}
            print("Created missing profileKeys table")
        end
        
        -- Set player's profile
        _G["Phoenix_UIDB"].profileKeys[playerKey] = currentProfile
        print("Set profile for " .. playerKey .. " to " .. currentProfile)
        
        -- Set metadata
        _G["Phoenix_UIDB"].__currentProfile = currentProfile
        _G["Phoenix_UIDB"].__lastSaved = GetTime()
        
        -- Ensure the profile exists
        if not _G["Phoenix_UIDB"].profiles then
            _G["Phoenix_UIDB"].profiles = {}
        end
        
        if not _G["Phoenix_UIDB"].profiles[currentProfile] then
            _G["Phoenix_UIDB"].profiles[currentProfile] = {}
            
            -- Copy from current memory profile if available
            if self.db and self.db.profile then
                _G["Phoenix_UIDB"].profiles[currentProfile] = CopyTable(self.db.profile)
            end
        end
    else
        print("Cannot repair: Global Phoenix_UIDB missing")
        return false
    end
    
    -- Force save
    self:ForceSettingsSave()
    
    print("Profile repair complete. Try reloading your UI with /reload")
    return true
end 