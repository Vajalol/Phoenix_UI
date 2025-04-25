function Phoenix_UI:SaveDB(force)
    -- If forced or no database, just return
    if force or not self.db then return end
    
    -- Debug info
    local debug = self.debug or false
    if debug then
        print("Phoenix_UI: SaveDB called")
    end
    
    -- First, commit any pending changes from widgets
    self:CommitPendingChanges()
    
    -- Validate settings before saving
    self:ValidateSettings()
    
    -- Ensure any pending changes are written to the database
    if self.db.profile then
        -- Re-register defaults to ensure any new settings are properly initialized
        self.db:RegisterDefaults(self.defaults)
        
        -- Get all module names from the tabs layout
        local allModules = {}
        
        -- First add the critical modules specifically (for backward compatibility)
        local criticalModules = {
            "nameplates", "actionbars", "castbars", "buffs", "msbt", "idtip",
            "general", "unitframes", "tooltip", "map", "chat", "misc",
            "uiscaling", "profiles", "cooldownTracker"
        }
        
        for _, moduleName in ipairs(criticalModules) do
            allModules[moduleName] = true
        end
        
        -- Get all other module names from the db.profile
        for moduleName, _ in pairs(self.db.profile) do
            if type(self.db.profile[moduleName]) == "table" then
                allModules[moduleName] = true
            end
        end
        
        -- Initialize __modifiedModules if it doesn't exist
        if not _G["Phoenix_UIDB"] then
            _G["Phoenix_UIDB"] = {}
        end
        
        if not _G["Phoenix_UIDB"].__modifiedModules then
            _G["Phoenix_UIDB"].__modifiedModules = {}
        end
        
        -- Get current profile
        local currentProfile = self.db.keys and self.db.keys.profile or "Default"
        
        -- Ensure profiles exists in global DB
        if not _G["Phoenix_UIDB"].profiles then
            _G["Phoenix_UIDB"].profiles = {}
        end
        
        -- Ensure current profile exists
        if not _G["Phoenix_UIDB"].profiles[currentProfile] then
            _G["Phoenix_UIDB"].profiles[currentProfile] = {}
        end
        
        -- Add metadata
        _G["Phoenix_UIDB"].__lastAccess = GetTime()
        _G["Phoenix_UIDB"].__addon_version = self.version or "unknown"
        
        -- Process all modules that need to be saved
        for moduleName, _ in pairs(allModules) do
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
                currentSettings.__saved_from = "SaveDB"
                
                -- Update in DB
                self.db.profile[moduleName] = currentSettings
                
                -- Directly update the AceDB saved variables to ensure persistence
                if type(_G["Phoenix_UIDB"]) == "table" then
                    -- Ensure profile exists
                    if not _G["Phoenix_UIDB"].profiles[currentProfile][moduleName] then
                        _G["Phoenix_UIDB"].profiles[currentProfile][moduleName] = {}
                    end
                    
                    -- Update the module settings in the global variable using deep copy
                    _G["Phoenix_UIDB"].profiles[currentProfile][moduleName] = CopyTable(currentSettings)
                    
                    if debug then
                        print("Phoenix_UI: Updated global variable for " .. moduleName)
                    end
                end
                
                -- Special handling for chat module to ensure emoji settings are preserved
                if moduleName == "chat" and currentSettings.emoji then
                    -- Double-check emoji settings are saved properly
                    if not _G["Phoenix_UIDB"].profiles[currentProfile].chat then
                        _G["Phoenix_UIDB"].profiles[currentProfile].chat = {}
                    end
                    
                    if not _G["Phoenix_UIDB"].profiles[currentProfile].chat.emoji then
                        _G["Phoenix_UIDB"].profiles[currentProfile].chat.emoji = {}
                    end
                    
                    -- Ensure emoji settings are properly copied
                    _G["Phoenix_UIDB"].profiles[currentProfile].chat.emoji = CopyTable(currentSettings.emoji)
                end
            end
        end
        
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
        
        -- Attempt to flush the saved variables to disk
        pcall(function()
            if FlushSettingsDB then
                FlushSettingsDB() 
            elseif FlushSavedVariables then
                FlushSavedVariables()
            end
        end)
    end
    
    if debug then
        print("|cffFF7D0APhoenix|r|cffFF0000_|r|cffFFD100UI|r: Settings saved")
    else
        self:Print("Saving Phoenix UI settings...")
    end
    
    -- Directly update the global savedvariables to ensure persistence
    if _G["Phoenix_UIDB"] and self.db and self.db.profile then
        -- Make sure we have a profiles table
        _G["Phoenix_UIDB"].profiles = _G["Phoenix_UIDB"].profiles or {}
        _G["Phoenix_UIDB"].profiles[currentProfile] = _G["Phoenix_UIDB"].profiles[currentProfile] or {}
        
        -- Safety copy all critical settings
        pcall(function()
            -- Copy the general settings first (priority)
            if self.db.profile.general then
                _G["Phoenix_UIDB"].profiles[currentProfile].general = CopyTable(self.db.profile.general)
                
                -- Also save in Default profile for safety
                _G["Phoenix_UIDB"].profiles.Default = _G["Phoenix_UIDB"].profiles.Default or {}
                _G["Phoenix_UIDB"].profiles.Default.general = CopyTable(self.db.profile.general)
            end
            
            -- DEBUG: Print some information about what's being saved
            if self.debug then
                print("Phoenix_UI: Saving all modules to global DB")
                -- Check critical tabs that we know have issues
                local tabsToCheck = {"actionbars", "tooltip", "map", "chat", "misc", "buffs", "castbars"}
                for _, tabName in ipairs(tabsToCheck) do
                    if self.db.profile[tabName] then
                        print("Phoenix_UI: " .. tabName .. " exists in profile, enabled = " .. tostring(self.db.profile[tabName].enabled))
                    else
                        print("Phoenix_UI: " .. tabName .. " does NOT exist in profile!")
                    end
                end
            end
            
            -- Copy all other settings
            for moduleName, moduleData in pairs(self.db.profile) do
                if type(moduleData) == "table" and moduleName ~= "general" then
                    _G["Phoenix_UIDB"].profiles[currentProfile][moduleName] = CopyTable(moduleData)
                end
            end
        end)
    end
    
    -- Attempt one more flush to disk with metadata to verify save
    pcall(function()
        if _G["Phoenix_UIDB"] then
            _G["Phoenix_UIDB"].__saveComplete = GetTime()
            
            if FlushSettingsDB then
                FlushSettingsDB() 
            elseif FlushSavedVariables then
                FlushSavedVariables()
            end
        end
    end)
    
    return true
end

-- Commit any pending changes from UI widgets to ensure complete data is saved
function Phoenix_UI:CommitPendingChanges()
    -- Debug output
    local debug = self.debug or false
    
    if debug then
        print("Phoenix_UI: CommitPendingChanges called")
    end
    
    -- First, check if Phoenix_UIConfig is loaded
    local config = _G.Phoenix_UIConfig
    if config then
        -- Try to commit any pending changes in the config UI
        if config.CommitPendingChanges then
            pcall(function() config:CommitPendingChanges() end)
        end
    end
    
    -- Check if our UI module is loaded
    if self.UI then
        -- Try to commit any pending changes in our UI
        if self.UI.CommitPendingChanges then
            pcall(function() self.UI:CommitPendingChanges() end)
        end
        
        -- Ensure all dropdowns and other widgets have their values saved
        if self.UI.elements then
            for _, element in pairs(self.UI.elements) do
                if element and element.Commit and type(element.Commit) == "function" then
                    pcall(function() element:Commit() end)
                end
            end
        end
    end
    
    -- Ensure profile database is properly synced
    if self.db and self.db.profile then
        -- Ensure critical settings tables exist
        local criticalModules = {
            "general", "actionbars", "unitframes", "nameplates", "chat", 
            "tooltip", "map", "fonts", "uiscaling", "buffs", "castbars",
            "msbt", "idtip", "buffoverlay", "misc"
        }
        
        local timestamp = GetTime()
        
        for _, moduleName in ipairs(criticalModules) do
            if not self.db.profile[moduleName] then
                self.db.profile[moduleName] = {}
                
                -- Try to recover from global savedvariables if available
                if _G["Phoenix_UIDB"] and _G["Phoenix_UIDB"].profiles then
                    local currentProfile = self.db.keys and self.db.keys.profile or "Default"
                    
                    if _G["Phoenix_UIDB"].profiles[currentProfile] and 
                       _G["Phoenix_UIDB"].profiles[currentProfile][moduleName] then
                        -- Copy settings from global savedvariables
                        pcall(function()
                            self.db.profile[moduleName] = CopyTable(_G["Phoenix_UIDB"].profiles[currentProfile][moduleName])
                        end)
                        
                        if debug then
                            print("Phoenix_UI: Recovered settings for " .. moduleName .. " from global savedvariables")
                        end
                    end
                end
            end
            
            -- Mark the module as updated
            if self.db.profile[moduleName] then
                self.db.profile[moduleName].__updated = timestamp
                self.db.profile[moduleName].__committed = timestamp
            end
        end
        
        -- Ensure theme settings
        if self.db.profile.general and self.db.profile.general.theme then
            -- Validate the theme exists
            local Themes = self:GetModule("Data.Themes", true)
            if Themes and Themes.data then
                local currentTheme = self.db.profile.general.theme
                
                -- Ensure the current theme exists in the themes data
                local themeExists = false
                for _, themeData in ipairs(Themes.data) do
                    if themeData.value == currentTheme then
                        themeExists = true
                        break
                    end
                end
                
                -- If theme doesn't exist, use "PhoenixFlame" or "Default" as fallback
                if not themeExists then
                    -- Try PhoenixFlame first, then fall back to Default if needed
                    local fallbackTheme = "PhoenixFlame"
                    local fallbackExists = false
                    
                    for _, themeData in ipairs(Themes.data) do
                        if themeData.value == fallbackTheme then
                            fallbackExists = true
                            break
                        end
                    end
                    
                    if fallbackExists then
                        self.db.profile.general.theme = fallbackTheme
                    else
                        self.db.profile.general.theme = "Default"
                    end
                    
                    if debug then
                        print("Phoenix_UI: Theme fixed to: " .. self.db.profile.general.theme)
                    end
                end
            end
        end
        
        -- Ensure font settings
        if self.db.profile.general and self.db.profile.general.font then
            -- Ensure it's also stored in fonts table
            self.db.profile.fonts = self.db.profile.fonts or {}
            self.db.profile.fonts.gameFont = self.db.profile.fonts.gameFont or {}
            self.db.profile.fonts.gameFont.family = self.db.profile.general.font
        elseif self.db.profile.fonts and self.db.profile.fonts.gameFont and self.db.profile.fonts.gameFont.family then
            -- Sync from fonts table to general
            self.db.profile.general = self.db.profile.general or {}
            self.db.profile.general.font = self.db.profile.fonts.gameFont.family
        end
    end
    
    -- Also apply font settings if available
    if self.ApplyFontSettings then
        pcall(function() self:ApplyFontSettings() end)
    end
    
    -- Return success
    return true
end

-- Queue a save operation with a delay to avoid excessive saving during rapid settings changes
function Phoenix_UI:QueueSave(delay)
    delay = delay or 0.3 -- Default delay of 0.3 seconds
    
    -- Cancel any existing save timer
    if self.saveTimer then
        self.saveTimer:Cancel()
        self.saveTimer = nil
    end
    
    -- Create a new save timer
    self.saveTimer = C_Timer.NewTimer(delay, function()
        self.saveTimer = nil
        self:SaveDB()
    end)
end

-- Force a save immediately
function Phoenix_UI:ForceSaveDB()
    -- Make sure we have a valid database
    if not self.db or not self.db.profile then
        return false
    end
    
    -- First, commit any pending changes
    self:CommitPendingChanges()
    
    -- Validate settings first
    self:ValidateSettings()
    
    -- Get all modules
    local allModules = {}
    
    -- Include all critical modules
    local criticalModules = {
        "nameplates", "actionbars", "castbars", "buffs", "msbt", "idtip",
        "general", "unitframes", "tooltip", "map", "chat", "misc",
        "uiscaling", "profiles", "cooldownTracker"
    }
    
    for _, moduleName in ipairs(criticalModules) do
        allModules[moduleName] = true
    end
    
    -- Get all modules from profile
    for moduleName, _ in pairs(self.db.profile) do
        if type(self.db.profile[moduleName]) == "table" then
            allModules[moduleName] = true
        end
    end
    
    -- Get current profile
    local currentProfile = self.db.keys.profile or "Default"
    
    -- Ensure the global Phoenix_UIDB exists and has proper structure
    if _G["Phoenix_UIDB"] == nil then
        _G["Phoenix_UIDB"] = {}
    end
    
    if _G["Phoenix_UIDB"].profiles == nil then
        _G["Phoenix_UIDB"].profiles = {}
    end
    
    if _G["Phoenix_UIDB"].profiles[currentProfile] == nil then
        _G["Phoenix_UIDB"].profiles[currentProfile] = {}
    end
    
    -- Initialize modified modules tracking if it doesn't exist
    if not _G["Phoenix_UIDB"].__modifiedModules then
        _G["Phoenix_UIDB"].__modifiedModules = {}
    end
    
    -- Process all modules
    for moduleName, _ in pairs(allModules) do
        if self.db.profile[moduleName] then
            -- Create deep copy of settings
            local settings = CopyTable(self.db.profile[moduleName])
            
            -- Add timestamp for tracking
            settings.__updated = GetTime()
            settings.__saved_method = "force_save"
            
            -- Track this module as modified
            _G["Phoenix_UIDB"].__modifiedModules[moduleName] = GetTime()
            
            -- Update in both the AceDB profile and global Phoenix_UIDB
            self.db.profile[moduleName] = settings
            
            -- Ensure the module exists in global variable
            if not _G["Phoenix_UIDB"].profiles[currentProfile][moduleName] then
                _G["Phoenix_UIDB"].profiles[currentProfile][moduleName] = {}
            end
            
            -- Deep copy to ensure all changes are preserved
            _G["Phoenix_UIDB"].profiles[currentProfile][moduleName] = CopyTable(settings)
            
            -- Also save to Default profile as a fallback
            if currentProfile ~= "Default" then
                if not _G["Phoenix_UIDB"].profiles["Default"] then
                    _G["Phoenix_UIDB"].profiles["Default"] = {}
                end
                
                if not _G["Phoenix_UIDB"].profiles["Default"][moduleName] then
                    _G["Phoenix_UIDB"].profiles["Default"][moduleName] = {}
                end
                
                -- Only copy critical settings to Default profile
                for _, criticalModule in ipairs(criticalModules) do
                    if moduleName == criticalModule then
                        _G["Phoenix_UIDB"].profiles["Default"][moduleName] = CopyTable(settings)
                        break
                    end
                end
            end
        end
    end
    
    -- Process specialized modules if available
    if self.moduleDB then
        local specializedModules = {
            "MSBT", "idTip", "BuffOverlay", "PremadeGroupsFilter", "CooldownTracker",
            "actionbars", "castbars", "buffs", "map", "chat", "misc", "tooltip"
        }
        
        for _, moduleName in ipairs(specializedModules) do
            if self.moduleDB[moduleName] and self.moduleDB[moduleName].profile then
                -- Track this module as modified
                _G["Phoenix_UIDB"].__modifiedModules[moduleName] = GetTime()
                
                -- Add timestamps for tracking
                self.moduleDB[moduleName].profile.__updated = GetTime()
                self.moduleDB[moduleName].profile.__saved_method = "force_save_specialized"
                
                -- Sync with main DB
                local lowerName = moduleName:lower()
                if self.db.profile[lowerName] then
                    self.db.profile[lowerName].enabled = self.moduleDB[moduleName].profile.enabled
                    self.db.profile[lowerName].__updated = GetTime()
                end
            end
        end
    end
    
    -- Update global timestamps
    _G["Phoenix_UIDB"].__lastSaved = GetTime()
    _G["Phoenix_UIDB"].__currentProfile = currentProfile
    _G["Phoenix_UIDB"].__forceSave = true
    
    -- Force flush to disk
    pcall(function()
        if FlushSettingsDB then
            FlushSettingsDB()
        elseif FlushSavedVariables then
            FlushSavedVariables()
        end
    end)
    
    -- Return success
    return true
end

-- Validates module settings to ensure they are properly structured
function Phoenix_UI:ValidateSettings()
    if not self.db or not self.db.profile then return end
    
    -- Critical modules to validate
    local criticalModules = {
        "nameplates", "actionbars", "castbars", "buffs", "msbt", "idtip",
        "tooltip", "map", "chat", "misc", "uiscaling"
    }
    
    -- Loop through critical modules
    for _, moduleName in ipairs(criticalModules) do
        -- Ensure the module settings exist
        if not self.db.profile[moduleName] then
            self.db.profile[moduleName] = {}
        end
        
        -- For each module, ensure key settings exist
        if moduleName == "nameplates" then
            -- Ensure nameplates settings have required fields
            local np = self.db.profile.nameplates
            np.decimals = np.decimals or "1"
            np.style = np.style or "Default"
            np.npccolors = np.npccolors or {}
        elseif moduleName == "actionbars" then
            -- Ensure actionbars settings have required fields
            local ab = self.db.profile.actionbars
            ab.mouseover = ab.mouseover or false
            ab.enable = ab.enable or false
        elseif moduleName == "castbars" then
            -- Ensure castbars settings have required fields
            local cb = self.db.profile.castbars
            cb.enabled = cb.enabled or false
        elseif moduleName == "buffs" then
            -- Ensure buffs settings have required fields
            local buff = self.db.profile.buffs
            buff.enabled = buff.enabled or false
        elseif moduleName == "msbt" then
            -- Ensure msbt settings have required fields
            local msbt = self.db.profile.msbt
            msbt.enabled = msbt.enabled or false
        elseif moduleName == "idtip" then
            -- Ensure idtip settings have required fields
            local idtip = self.db.profile.idtip
            idtip.enabled = idtip.enabled or true
        elseif moduleName == "tooltip" then
            -- Ensure tooltip settings have required fields
            local tooltip = self.db.profile.tooltip
            tooltip.enabled = tooltip.enabled or true
        elseif moduleName == "map" then
            -- Ensure map settings have required fields
            local map = self.db.profile.map
            map.enabled = map.enabled or true
        elseif moduleName == "chat" then
            -- Ensure chat settings have required fields
            local chat = self.db.profile.chat
            chat.enabled = chat.enabled or true
            
            -- Ensure emoji settings exist and are properly initialized
            if not chat.emoji then
                chat.emoji = {
                    enabled = true,
                    size = 16
                }
            end
        elseif moduleName == "misc" then
            -- Ensure misc settings have required fields
            local misc = self.db.profile.misc
            misc.enabled = misc.enabled or true
        end
    end
    
    -- Also check module DB 
    if self.moduleDB then
        if self.moduleDB.MSBT and not self.moduleDB.MSBT.profile then
            self.moduleDB.MSBT.profile = { enabled = self.db.profile.msbt.enabled }
        end
        
        if self.moduleDB.idTip and not self.moduleDB.idTip.profile then
            self.moduleDB.idTip.profile = { enabled = self.db.profile.idtip.enabled }
        end
    end
    
    return true
end

-- Add a function to verify saved variables integrity
function Phoenix_UI:VerifySavedVariables()
    -- Check if global saved variables exist
    if not _G["Phoenix_UIDB"] then
        _G["Phoenix_UIDB"] = {}
    end
    
    -- Check if profiles exist
    if not _G["Phoenix_UIDB"].profiles then
        _G["Phoenix_UIDB"].profiles = {}
    end
    
    -- Get current profile
    local currentProfile = "Default"
    if self.db and self.db.keys and self.db.keys.profile then
        currentProfile = self.db.keys.profile
    end
    
    -- Check if current profile exists
    if not _G["Phoenix_UIDB"].profiles[currentProfile] then
        _G["Phoenix_UIDB"].profiles[currentProfile] = {}
    end
    
    -- Force save on startup to ensure changes persist
    C_Timer.After(5, function()
        if self.ForceSaveDB then
            self.silentSave = true
            self:ForceSaveDB()
            self.silentSave = false
        end
    end)
    
    -- Register for login event to save again after all addons load
    local frame = CreateFrame("Frame")
    frame:RegisterEvent("PLAYER_ENTERING_WORLD")
    frame:SetScript("OnEvent", function()
        C_Timer.After(10, function()
            if self.ForceSaveDB then
                self.silentSave = true
                self:ForceSaveDB()
                self.silentSave = false
                
                -- Perform repair if enabled
                if self.DiagnoseAndRepairSettings then
                    self:DiagnoseAndRepairSettings()
                end
            end
        end)
    end)
end

-- Comprehensive function to save ALL settings across all modules
function Phoenix_UI:SaveAllSettings()
    -- Mark all settings as updated with a timestamp
    local timestamp = GetTime()
    
    -- Debug output
    local debug = self.debug or false
    if debug then
        print("Phoenix_UI: SaveAllSettings called")
    end
    
    -- First, commit any pending changes from widgets
    self:CommitPendingChanges()
    
    -- Ensure theme settings are properly synchronized before saving
    if self.db and self.db.profile then
        -- Synchronize theme settings to ensure they're consistently applied
        if self.db.profile.general and self.db.profile.general.theme then
            local currentTheme = self.db.profile.general.theme
            
            -- Ensure the current theme exists in the themes data
            local Themes = self:GetModule("Data.Themes", true)
            if Themes and Themes.data then
                local themeExists = false
                for _, themeData in ipairs(Themes.data) do
                    if themeData.value == currentTheme then
                        themeExists = true
                        break
                    end
                end
                
                -- If theme doesn't exist, default to "PhoenixFlame" or "Default"
                if not themeExists then
                    -- Try PhoenixFlame first, then fall back to Default if needed
                    local fallbackTheme = "PhoenixFlame"
                    local fallbackExists = false
                    
                    for _, themeData in ipairs(Themes.data) do
                        if themeData.value == fallbackTheme then
                            fallbackExists = true
                            break
                        end
                    end
                    
                    if fallbackExists then
                        self.db.profile.general.theme = fallbackTheme
                    else
                        self.db.profile.general.theme = "Default"
                    end
                    
                    if debug then
                        print("Phoenix_UI: Theme '" .. currentTheme .. "' not found, using fallback: " .. self.db.profile.general.theme)
                    end
                end
            end
        end
    end
    
    -- Mark all module settings with an update timestamp
    for moduleName, settings in pairs(self.db.profile) do
        if type(settings) == "table" then
            settings.__updated = timestamp
            settings.__saved_method = "save_all_settings"
        end
    end
    
    -- Safely save to the global table for each module
    if _G["Phoenix_UIDB"] and type(_G["Phoenix_UIDB"]) == "table" then
        -- Ensure profiles table exists
        if not _G["Phoenix_UIDB"].profiles or type(_G["Phoenix_UIDB"].profiles) ~= "table" then
            _G["Phoenix_UIDB"].profiles = {}
        end
        
        local currentProfile = self.db.keys and self.db.keys.profile or "Default"
        
        -- Ensure the profile exists
        if not _G["Phoenix_UIDB"].profiles[currentProfile] then
            _G["Phoenix_UIDB"].profiles[currentProfile] = {}
        end
        
        -- Copy ALL profile settings (deep copy)
        local success, errorMsg = pcall(function()
            _G["Phoenix_UIDB"].profiles[currentProfile] = CopyTable(self.db.profile)
        end)
        
        if not success and debug then
            print("Phoenix_UI: Error copying profile settings: " .. tostring(errorMsg))
            -- Try individual sections to avoid complete failure
            for moduleName, moduleData in pairs(self.db.profile) do
                if type(moduleData) == "table" then
                    pcall(function()
                        _G["Phoenix_UIDB"].profiles[currentProfile][moduleName] = CopyTable(moduleData)
                    end)
                end
            end
        end
        
        -- Always ensure critical modules are saved
        local criticalModules = {"general", "actionbars", "unitframes", "nameplates", "chat", "tooltip"}
        for _, moduleName in ipairs(criticalModules) do
            if self.db.profile[moduleName] and type(self.db.profile[moduleName]) == "table" then
                pcall(function()
                    _G["Phoenix_UIDB"].profiles[currentProfile][moduleName] = CopyTable(self.db.profile[moduleName])
                    _G["Phoenix_UIDB"].profiles[currentProfile][moduleName].__updated = timestamp
                    _G["Phoenix_UIDB"].profiles[currentProfile][moduleName].__saved_method = "critical_module_save"
                end)
            end
        end
        
        if debug then
            print("Phoenix_UI: Updated all settings in global Phoenix_UIDB")
        end
    end
    
    -- Trigger the normal save to ensure everything is properly processed
    self:SaveDB()
    
    -- Force flush to disk with added protection
    pcall(function()
        if FlushSettingsDB then
            FlushSettingsDB()
        elseif FlushSavedVariables then
            FlushSavedVariables()
        end
    end)
    
    -- Verify that theme settings were properly saved
    if self.db and self.db.profile and self.db.profile.general and self.db.profile.general.theme then
        local currentTheme = self.db.profile.general.theme
        if _G["Phoenix_UIDB"] and _G["Phoenix_UIDB"].profiles then
            local currentProfile = self.db.keys and self.db.keys.profile or "Default"
            if _G["Phoenix_UIDB"].profiles[currentProfile] and _G["Phoenix_UIDB"].profiles[currentProfile].general then
                local savedTheme = _G["Phoenix_UIDB"].profiles[currentProfile].general.theme
                
                -- If there's a mismatch, fix it
                if savedTheme ~= currentTheme then
                    _G["Phoenix_UIDB"].profiles[currentProfile].general.theme = currentTheme
                    
                    -- Flush changes again
                    pcall(function()
                        if FlushSettingsDB then
                            FlushSettingsDB()
                        elseif FlushSavedVariables then
                            FlushSavedVariables()
                        end
                    end)
                    
                    if debug then
                        print("Phoenix_UI: Fixed theme mismatch. Current: " .. currentTheme .. ", Saved: " .. tostring(savedTheme))
                    end
                end
            end
        end
    end
    
    -- Print confirmation
    if not debug then
        self:Print("All settings saved successfully.")
    end
    
    return true
end

-- Helper function to ensure Phoenix_UIConfig is available
function Phoenix_UI:EnsurePhoenixUIConfig()
    if not _G.Phoenix_UIConfig and LibStub then
        -- Try to load Phoenix_UIConfig through LibStub
        local config = LibStub("Phoenix_UIConfig", true)
        if config then
            -- Assign to global for other modules
            _G.Phoenix_UIConfig = config
            return true
        end
        return false
    end
    
    return _G.Phoenix_UIConfig ~= nil
end

-- Function to diagnose and repair settings issues
function Phoenix_UI:DiagnoseAndRepairSettings()
    -- Check if we have global DB
    if not _G["Phoenix_UIDB"] then
        _G["Phoenix_UIDB"] = {}
    end
    
    -- Initialize diagnostics tracking
    _G["Phoenix_UIDB"].__diagnostics = _G["Phoenix_UIDB"].__diagnostics or {}
    _G["Phoenix_UIDB"].__diagnostics.lastRun = GetTime()
    _G["Phoenix_UIDB"].__diagnostics.repairCount = (_G["Phoenix_UIDB"].__diagnostics.repairCount or 0) + 1
    
    -- Ensure required structures exist
    if not _G["Phoenix_UIDB"].profiles then
        _G["Phoenix_UIDB"].profiles = {}
        _G["Phoenix_UIDB"].__diagnostics.repairs = _G["Phoenix_UIDB"].__diagnostics.repairs or {}
        _G["Phoenix_UIDB"].__diagnostics.repairs[#_G["Phoenix_UIDB"].__diagnostics.repairs + 1] = {
            time = GetTime(),
            issue = "Created missing profiles table"
        }
    end
    
    -- Get current profile
    local currentProfile = "Default"
    if self.db and self.db.keys and self.db.keys.profile then
        currentProfile = self.db.keys.profile
    end
    
    -- Ensure current profile exists
    if not _G["Phoenix_UIDB"].profiles[currentProfile] then
        _G["Phoenix_UIDB"].profiles[currentProfile] = {}
        _G["Phoenix_UIDB"].__diagnostics.repairs = _G["Phoenix_UIDB"].__diagnostics.repairs or {}
        _G["Phoenix_UIDB"].__diagnostics.repairs[#_G["Phoenix_UIDB"].__diagnostics.repairs + 1] = {
            time = GetTime(),
            issue = "Created missing profile: " .. currentProfile
        }
    end
    
    -- Ensure __modifiedModules exists
    if not _G["Phoenix_UIDB"].__modifiedModules then
        _G["Phoenix_UIDB"].__modifiedModules = {}
        _G["Phoenix_UIDB"].__diagnostics.repairs = _G["Phoenix_UIDB"].__diagnostics.repairs or {}
        _G["Phoenix_UIDB"].__diagnostics.repairs[#_G["Phoenix_UIDB"].__diagnostics.repairs + 1] = {
            time = GetTime(),
            issue = "Created missing __modifiedModules tracking table"
        }
    end
    
    -- Compare and repair profile settings if we have AceDB settings
    if self.db and self.db.profile then
        -- Critical modules to check
        local criticalModules = {
            "nameplates", "actionbars", "castbars", "buffs", "msbt", "idtip",
            "general", "unitframes", "tooltip", "map", "chat", "misc",
            "uiscaling", "profiles", "cooldownTracker"
        }
        
        -- Check each critical module exists in both local and global
        for _, moduleName in ipairs(criticalModules) do
            -- Track if this module needs saving
            local needsSave = false
            
            -- Check if module exists in local DB but not global
            if self.db.profile[moduleName] and type(self.db.profile[moduleName]) == "table" then
                if not _G["Phoenix_UIDB"].profiles[currentProfile][moduleName] or 
                   type(_G["Phoenix_UIDB"].profiles[currentProfile][moduleName]) ~= "table" then
                    -- Create the module in the global database
                    _G["Phoenix_UIDB"].profiles[currentProfile][moduleName] = CopyTable(self.db.profile[moduleName])
                    _G["Phoenix_UIDB"].__diagnostics.repairs = _G["Phoenix_UIDB"].__diagnostics.repairs or {}
                    _G["Phoenix_UIDB"].__diagnostics.repairs[#_G["Phoenix_UIDB"].__diagnostics.repairs + 1] = {
                        time = GetTime(),
                        issue = "Created missing module in global: " .. moduleName
                    }
                    needsSave = true
                end
                
                -- Mark this module as modified
                _G["Phoenix_UIDB"].__modifiedModules[moduleName] = GetTime()
            end
            
            -- Check if module exists in global DB but not local
            if _G["Phoenix_UIDB"].profiles[currentProfile][moduleName] and 
               type(_G["Phoenix_UIDB"].profiles[currentProfile][moduleName]) == "table" then
                if not self.db.profile[moduleName] or type(self.db.profile[moduleName]) ~= "table" then
                    -- Create the module in the local database
                    self.db.profile[moduleName] = CopyTable(_G["Phoenix_UIDB"].profiles[currentProfile][moduleName])
                    _G["Phoenix_UIDB"].__diagnostics.repairs = _G["Phoenix_UIDB"].__diagnostics.repairs or {}
                    _G["Phoenix_UIDB"].__diagnostics.repairs[#_G["Phoenix_UIDB"].__diagnostics.repairs + 1] = {
                        time = GetTime(),
                        issue = "Created missing module in local: " .. moduleName
                    }
                    needsSave = true
                end
            end
            
            -- Force save if needed
            if needsSave then
                if self.ForceSaveDB then
                    self:ForceSaveDB()
                elseif self.SaveDB then
                    self:SaveDB()
                end
            end
        end
    end
    
    -- Also check specialized modules
    if self.moduleDB then
        local specializedModules = {
            "MSBT", "idTip", "BuffOverlay", "PremadeGroupsFilter", "CooldownTracker",
            "actionbars", "castbars", "buffs", "map", "chat", "misc", "tooltip"
        }
        
        for _, moduleName in ipairs(specializedModules) do
            if self.moduleDB[moduleName] and self.moduleDB[moduleName].profile then
                -- Mark as updated
                self.moduleDB[moduleName].profile.__updated = GetTime()
                self.moduleDB[moduleName].profile.__repair_check = GetTime()
                
                -- Mark in the tracking table
                _G["Phoenix_UIDB"].__modifiedModules[moduleName] = GetTime()
            end
        end
    end
    
    -- Record diagnostics completion
    _G["Phoenix_UIDB"].__diagnostics.lastCompleted = GetTime()
    
    -- Force a save after repair
    self:ForceSaveDB()
    
    return true
end

-- Add a function to verify installation status
function Phoenix_UI:IsInstalled()
    -- Make sure to clearly debug this critical function
    local debug = self.debug
    
    -- Log function entry
    if debug then
        print("Phoenix_UI: IsInstalled - Function called")
    end
    
    -- Check if the database exists
    if not self.db then
        if debug then
            print("Phoenix_UI: IsInstalled - DB not available")
        end
        return false
    end
    
    if not self.db.profile then
        if debug then
            print("Phoenix_UI: IsInstalled - Profile not available")
        end
        return false
    end
    
    -- Get current profile
    local currentProfile = self.db.keys and self.db.keys.profile or "Default"
    
    -- Add debug output if enabled
    if debug then
        print("Phoenix_UI: IsInstalled - Checking install status for profile: " .. currentProfile)
    end
    
    -- Print values to debug logs
    if debug then
        if self.db.profile then
            print("Phoenix_UI: IsInstalled - Local db.profile.install = " .. tostring(self.db.profile.install))
        end
        
        if _G["Phoenix_UIDB"] and _G["Phoenix_UIDB"].profiles then
            if _G["Phoenix_UIDB"].profiles[currentProfile] then
                print("Phoenix_UI: IsInstalled - Global UIDB current profile install = " .. 
                      tostring(_G["Phoenix_UIDB"].profiles[currentProfile].install))
            end
            
            if _G["Phoenix_UIDB"].profiles["Default"] then
                print("Phoenix_UI: IsInstalled - Global UIDB Default profile install = " .. 
                      tostring(_G["Phoenix_UIDB"].profiles["Default"].install))
            end
        end
    end
    
    -- First check the local AceDB value since it's most reliable
    if self.db.profile.install == true then
        if debug then
            print("Phoenix_UI: IsInstalled - Found install flag in AceDB profile - returning TRUE")
        end
        return true
    end
    
    -- Then check if the global variable has the install flag set
    if _G["Phoenix_UIDB"] and _G["Phoenix_UIDB"].profiles then
        -- Current profile check
        if _G["Phoenix_UIDB"].profiles[currentProfile] and 
           _G["Phoenix_UIDB"].profiles[currentProfile].install == true then
            if debug then
                print("Phoenix_UI: IsInstalled - Found install flag in Phoenix_UIDB for current profile - returning TRUE")
            end
            
            -- Copy to local for next time
            self.db.profile.install = true
            
            return true
        end
        
        -- Default profile check as fallback
        if _G["Phoenix_UIDB"].profiles["Default"] and 
           _G["Phoenix_UIDB"].profiles["Default"].install == true then
            if debug then
                print("Phoenix_UI: IsInstalled - Found install flag in Phoenix_UIDB for Default profile - returning TRUE")
            end
            
            -- Copy to local for next time
            self.db.profile.install = true
            
            return true
        end
    elseif debug then
        print("Phoenix_UI: IsInstalled - Phoenix_UIDB or profiles not found")
    end
    
    -- Not installed, add debug output
    if debug then
        print("Phoenix_UI: IsInstalled - No install flag found, returning FALSE")
    end
    
    -- Always return a boolean value
    return false
end

-- Set installation status to true and save more robustly
function Phoenix_UI:SetInstalled()
    -- Make sure to clearly debug this critical function
    local debug = self.debug
    
    -- Log function entry
    if debug then
        print("Phoenix_UI: SetInstalled - Function called")
    end
    
    -- Ensure database exists
    if not self.db or not self.db.profile then
        if debug then
            print("Phoenix_UI: SetInstalled - DB or profile not available")
        end
        return false
    end
    
    -- Get current profile
    local currentProfile = self.db.keys and self.db.keys.profile or "Default"
    
    -- Set installation flag in AceDB
    self.db.profile.install = true
    self.db.profile.reset = true  -- Also set reset flag to ensure full initialization
    
    -- Add debug output if enabled
    if debug then
        print("Phoenix_UI: SetInstalled - Setting install flag for profile: " .. currentProfile)
    end
    
    -- Also update the global variable for direct persistence
    if _G["Phoenix_UIDB"] then
        -- Ensure profiles table exists
        if not _G["Phoenix_UIDB"].profiles then
            _G["Phoenix_UIDB"].profiles = {}
        end
        
        -- Ensure current profile exists
        if not _G["Phoenix_UIDB"].profiles[currentProfile] then
            _G["Phoenix_UIDB"].profiles[currentProfile] = {}
        end
        
        -- Set installation flag
        _G["Phoenix_UIDB"].profiles[currentProfile].install = true
        _G["Phoenix_UIDB"].profiles[currentProfile].reset = true
        
        -- Also set in Default profile for safety
        if not _G["Phoenix_UIDB"].profiles["Default"] then
            _G["Phoenix_UIDB"].profiles["Default"] = {}
        end
        _G["Phoenix_UIDB"].profiles["Default"].install = true
        _G["Phoenix_UIDB"].profiles["Default"].reset = true
        
        -- Directly set timestamp to help with debugging
        _G["Phoenix_UIDB"].__installTime = GetTime()
        
        if debug then
            print("Phoenix_UI: SetInstalled - Updated global variables")
        end
    elseif debug then
        print("Phoenix_UI: SetInstalled - Warning: Global Phoenix_UIDB not available")
    end
    
    -- Save all tab settings to ensure everything is properly saved
    if self.SaveAllTabSettings then
        self:SaveAllTabSettings()
        if debug then
            print("Phoenix_UI: SetInstalled - SaveAllTabSettings completed")
        end
    end
    
    -- Force save to ensure persistence
    if self.ForceSaveDB then
        self:ForceSaveDB()
        if debug then
            print("Phoenix_UI: SetInstalled - ForceSaveDB completed")
        end
    elseif self.SaveDB then
        self:SaveDB(true)
        if debug then
            print("Phoenix_UI: SetInstalled - SaveDB completed")
        end
    end
    
    -- Directly flush saved variables to disk
    pcall(function()
        if FlushSettingsDB then
            FlushSettingsDB()
            if debug then
                print("Phoenix_UI: SetInstalled - FlushSettingsDB completed")
            end
        elseif FlushSavedVariables then
            FlushSavedVariables()
            if debug then
                print("Phoenix_UI: SetInstalled - FlushSavedVariables completed")
            end
        end
    end)
    
    -- Verify installation was successful
    local installSuccessful = self:IsInstalled()
    
    -- Add debug output if enabled
    if debug then
        print("Phoenix_UI: SetInstalled - Installation " .. (installSuccessful and "successful" or "FAILED"))
    end
    
    return installSuccessful
end

-- Synchronize module settings between local and global databases
-- This is crucial for ensuring data integrity across the addon
function Phoenix_UI:SyncModuleSettings(forceSave)
    -- Debug output
    local debug = self.debug or false
    
    if debug then
        print("Phoenix_UI: SyncModuleSettings called, forceSave = " .. tostring(forceSave or false))
    end
    
    -- Only sync if we have both required tables
    if not self.db or not self.db.profile then
        if debug then
            print("Phoenix_UI: SyncModuleSettings - Local DB not available")
        end
        return false
    end
    
    if not _G["Phoenix_UIDB"] or not _G["Phoenix_UIDB"].profiles then
        if debug then
            print("Phoenix_UI: SyncModuleSettings - Global DB not available")
        end
        return false
    end
    
    -- Use pcall for the entire function to prevent any errors from breaking the addon
    local syncSuccess, syncError = pcall(function()
        -- Get current profile
        local currentProfile = self.db.keys and self.db.keys.profile or "Default"
        
        -- Ensure current profile exists in global DB
        if not _G["Phoenix_UIDB"].profiles[currentProfile] then
            _G["Phoenix_UIDB"].profiles[currentProfile] = {}
        end
        
        -- Track sync information
        local syncInfo = {
            timestamp = GetTime(),
            synced = {},
            errors = {},
            conflicts = {}
        }
        
        -- Helper to check if a module was recently modified
        local function wasRecentlyModified(module, timeThreshold)
            timeThreshold = timeThreshold or 300 -- 5 minutes by default
            
            -- Check local DB first
            if self.db.profile[module] and self.db.profile[module].__updated then
                local lastUpdate = self.db.profile[module].__updated
                if (GetTime() - lastUpdate) < timeThreshold then
                    return true, "local", lastUpdate
                end
            end
            
            -- Then check global DB
            if _G["Phoenix_UIDB"].profiles[currentProfile][module] and 
               _G["Phoenix_UIDB"].profiles[currentProfile][module].__updated then
                local lastUpdate = _G["Phoenix_UIDB"].profiles[currentProfile][module].__updated
                if (GetTime() - lastUpdate) < timeThreshold then
                    return true, "global", lastUpdate
                end
            end
            
            return false
        end
        
        -- Helper to determine which version is newer (local or global)
        local function getNewerVersion(module)
            local localTime = self.db.profile[module] and self.db.profile[module].__updated
            local globalTime = _G["Phoenix_UIDB"].profiles[currentProfile][module] and 
                               _G["Phoenix_UIDB"].profiles[currentProfile][module].__updated
            
            if not localTime and not globalTime then
                return "unknown"
            elseif not localTime then
                return "local"
            elseif not globalTime then
                return "global"
            else
                -- Both have timestamps, compare them
                return (localTime > globalTime) and "local" or "global"
            end
        end
        
        -- Critical modules that must be synced
        local criticalModules = {
            "general", "actionbars", "unitframes", "nameplates", "chat", 
            "tooltip", "map", "fonts", "uiscaling", "buffs", "castbars",
            "msbt", "idtip", "buffoverlay", "misc"
        }
        
        -- First sync critical modules
        for i, moduleName in ipairs(criticalModules) do
            -- Skip if module doesn't exist in either database
            if self.db.profile[moduleName] or _G["Phoenix_UIDB"].profiles[currentProfile][moduleName] then
                -- Determine which version to use
                local newerVersion = getNewerVersion(moduleName)
                local wasModified, modifiedSource = wasRecentlyModified(moduleName)
                
                -- Create module in local DB if it doesn't exist
                if not self.db.profile[moduleName] then
                    self.db.profile[moduleName] = {}
                end
                
                -- Create module in global DB if it doesn't exist
                if not _G["Phoenix_UIDB"].profiles[currentProfile][moduleName] then
                    _G["Phoenix_UIDB"].profiles[currentProfile][moduleName] = {}
                end
                
                -- Sync based on which is newer
                local success = true
                local errorMsg = nil
                
                if forceSave or (newerVersion == "local") then
                    -- Local is newer, update global
                    success, errorMsg = pcall(function()
                        _G["Phoenix_UIDB"].profiles[currentProfile][moduleName] = CopyTable(self.db.profile[moduleName])
                        _G["Phoenix_UIDB"].profiles[currentProfile][moduleName].__updated = GetTime()
                        _G["Phoenix_UIDB"].profiles[currentProfile][moduleName].__sync_direction = "local_to_global"
                    end)
                    
                    if success then
                        syncInfo.synced[moduleName] = "local_to_global"
                    else
                        syncInfo.errors[moduleName] = errorMsg
                    end
                elseif newerVersion == "global" then
                    -- Global is newer, update local
                    success, errorMsg = pcall(function()
                        self.db.profile[moduleName] = CopyTable(_G["Phoenix_UIDB"].profiles[currentProfile][moduleName])
                        self.db.profile[moduleName].__updated = GetTime()
                        self.db.profile[moduleName].__sync_direction = "global_to_local"
                    end)
                    
                    if success then
                        syncInfo.synced[moduleName] = "global_to_local"
                    else
                        syncInfo.errors[moduleName] = errorMsg
                    end
                else
                    -- Same version or unknown, just mark as synced
                    syncInfo.synced[moduleName] = "already_in_sync"
                end
            end
        end
        
        -- Now sync all other modules
        for moduleName, moduleData in pairs(self.db.profile) do
            -- Skip modules we've already processed
            local shouldSkip = false
            
            -- Check if it's a critical module we already processed
            for _, criticalModule in ipairs(criticalModules) do
                if moduleName == criticalModule then
                    shouldSkip = true
                    break
                end
            end
            
            -- Also skip if it's not a table
            if type(moduleData) ~= "table" then
                shouldSkip = true
            end
            
            -- Process this module if we shouldn't skip it
            if not shouldSkip then
                -- Determine which version to use
                local newerVersion = getNewerVersion(moduleName)
                local wasModified, modifiedSource = wasRecentlyModified(moduleName)
                
                -- Create module in global DB if it doesn't exist
                if not _G["Phoenix_UIDB"].profiles[currentProfile][moduleName] then
                    _G["Phoenix_UIDB"].profiles[currentProfile][moduleName] = {}
                end
                
                -- Sync based on which is newer
                local success = true
                local errorMsg = nil
                
                if forceSave or (newerVersion == "local" or newerVersion == "unknown") then
                    -- Local is newer or unknown, update global
                    success, errorMsg = pcall(function()
                        _G["Phoenix_UIDB"].profiles[currentProfile][moduleName] = CopyTable(self.db.profile[moduleName])
                        _G["Phoenix_UIDB"].profiles[currentProfile][moduleName].__updated = GetTime()
                        _G["Phoenix_UIDB"].profiles[currentProfile][moduleName].__sync_direction = "local_to_global"
                    end)
                    
                    if success then
                        syncInfo.synced[moduleName] = "local_to_global"
                    else
                        syncInfo.errors[moduleName] = errorMsg
                    end
                elseif newerVersion == "global" then
                    -- Global is newer, update local
                    success, errorMsg = pcall(function()
                        self.db.profile[moduleName] = CopyTable(_G["Phoenix_UIDB"].profiles[currentProfile][moduleName])
                        self.db.profile[moduleName].__updated = GetTime()
                        self.db.profile[moduleName].__sync_direction = "global_to_local"
                    end)
                    
                    if success then
                        syncInfo.synced[moduleName] = "global_to_local"
                    else
                        syncInfo.errors[moduleName] = errorMsg
                    end
                end
            end
        end
        
        -- Finally, check for modules that exist in global but not local
        for moduleName, moduleData in pairs(_G["Phoenix_UIDB"].profiles[currentProfile]) do
            if not self.db.profile[moduleName] and type(moduleData) == "table" then
                -- Module exists in global but not local, copy to local
                local success, errorMsg = pcall(function()
                    self.db.profile[moduleName] = CopyTable(moduleData)
                    self.db.profile[moduleName].__updated = GetTime()
                    self.db.profile[moduleName].__sync_direction = "global_to_local"
                end)
                
                if success then
                    syncInfo.synced[moduleName] = "global_to_local_new"
                else
                    syncInfo.errors[moduleName] = errorMsg
                end
            end
        end
        
        -- Record synchronization information
        self.lastSyncInfo = syncInfo
        
        -- If there were errors, write to debug log
        if debug then
            local errorCount = 0
            for _, _ in pairs(syncInfo.errors) do
                errorCount = errorCount + 1
            end
            
            if errorCount > 0 then
                print("Phoenix_UI: SyncModuleSettings - " .. errorCount .. " errors encountered")
            else
                print("Phoenix_UI: SyncModuleSettings - Successfully synced all modules")
            end
        end
        
        -- Force flush to disk with added protection
        if forceSave then
            pcall(function()
                if FlushSettingsDB then
                    FlushSettingsDB()
                elseif FlushSavedVariables then
                    FlushSavedVariables()
                end
            end)
        end
    end)
    
    -- Handle any errors that occurred during synchronization
    if not syncSuccess and debug then
        print("Phoenix_UI: Error in SyncModuleSettings: " .. tostring(syncError))
    end
    
    return syncSuccess
end

-- Add a function to explicitly save all tab settings
function Phoenix_UI:SaveAllTabSettings()
    -- Get current profile
    local currentProfile = self.db.keys and self.db.keys.profile or "Default"
    
    -- Ensure we have the required variables
    if not self.db or not self.db.profile or not _G["Phoenix_UIDB"] then
        return false
    end
    
    -- Make sure profiles table exists in global DB
    if not _G["Phoenix_UIDB"].profiles then
        _G["Phoenix_UIDB"].profiles = {}
    end
    
    -- Ensure current profile exists
    if not _G["Phoenix_UIDB"].profiles[currentProfile] then
        _G["Phoenix_UIDB"].profiles[currentProfile] = {}
    end
    
    -- Define all tab modules to save
    local allTabs = {
        "general", "unitframes", "nameplates", 
        "actionbar", "actionbars",
        "castbar", "castbars",
        "buff", "buffs",
        "tooltip", "map", "chat", "misc", "uiscaling", 
        "msbt", "idtip", "buffoverlay", "cooldownTracker"
    }
    
    -- Track which tabs were saved
    local savedTabs = {}
    
    -- Force save each tab
    for _, tabName in ipairs(allTabs) do
        if self.db.profile[tabName] then
            -- Copy to global DB
            _G["Phoenix_UIDB"].profiles[currentProfile][tabName] = CopyTable(self.db.profile[tabName])
            savedTabs[tabName] = true
            
            -- Add timestamp
            _G["Phoenix_UIDB"].profiles[currentProfile][tabName].__saved = GetTime()
        end
    end
    
    -- Update timestamps
    _G["Phoenix_UIDB"].__lastSaved = GetTime()
    _G["Phoenix_UIDB"].__currentProfile = currentProfile
    
    -- Force write to disk
    pcall(function()
        if FlushSettingsDB then
            FlushSettingsDB()
        elseif FlushSavedVariables then
            FlushSavedVariables()
        end
    end)
    
    -- Register for login event to ensure settings are loaded next time
    local frame = CreateFrame("Frame")
    frame:RegisterEvent("PLAYER_ENTERING_WORLD")
    frame:SetScript("OnEvent", function()
        C_Timer.After(2, function()
            if self.ForceSaveDB then
                self:ForceSaveDB()
            end
        end)
    end)
    
    return savedTabs
end

-- Improved instant save function that can be called from any widget or control
function Phoenix_UI:InstantSave(moduleName, key, value)
    -- Skip if database isn't available
    if not self.db or not self.db.profile then return false end
    
    -- Debug info
    local debug = self.debug or false
    if debug then
        print("Phoenix_UI: InstantSave called for " .. (moduleName or "unknown") .. 
              " key:" .. (key or "unknown"))
    end

    -- Get current profile
    local currentProfile = self.db.keys and self.db.keys.profile or "Default"
    
    -- First check if we are updating a specific value
    if moduleName and key and value ~= nil then
        -- Update the value in the database
        if not self.db.profile[moduleName] then
            self.db.profile[moduleName] = {}
        end
        
        -- Set the value in the database
        self.db.profile[moduleName][key] = value
        
        -- Mark as updated
        self.db.profile[moduleName].__updated = GetTime()
        self.db.profile[moduleName].__saved_from = "InstantSave"
        
        -- If we're able to, update the global savedvariables directly for redundancy
        if type(_G["Phoenix_UIDB"]) == "table" then
            -- Ensure we have the profile structure
            _G["Phoenix_UIDB"].profiles = _G["Phoenix_UIDB"].profiles or {}
            _G["Phoenix_UIDB"].profiles[currentProfile] = _G["Phoenix_UIDB"].profiles[currentProfile] or {}
            _G["Phoenix_UIDB"].profiles[currentProfile][moduleName] = _G["Phoenix_UIDB"].profiles[currentProfile][moduleName] or {}
            
            -- Update the value directly in the global table
            _G["Phoenix_UIDB"].profiles[currentProfile][moduleName][key] = value
            _G["Phoenix_UIDB"].profiles[currentProfile][moduleName].__updated = GetTime()
            _G["Phoenix_UIDB"].__lastSaved = GetTime()
            _G["Phoenix_UIDB"].__currentProfile = currentProfile
        end
    elseif moduleName then
        -- If only module name provided, save that entire module
        if self.db.profile[moduleName] then
            -- Mark as updated
            self.db.profile[moduleName].__updated = GetTime()
            
            -- Update in global table if possible
            if type(_G["Phoenix_UIDB"]) == "table" then
                _G["Phoenix_UIDB"].profiles = _G["Phoenix_UIDB"].profiles or {}
                _G["Phoenix_UIDB"].profiles[currentProfile] = _G["Phoenix_UIDB"].profiles[currentProfile] or {}
                
                -- Deep copy the entire module
                _G["Phoenix_UIDB"].profiles[currentProfile][moduleName] = CopyTable(self.db.profile[moduleName])
                _G["Phoenix_UIDB"].__lastSaved = GetTime()
                _G["Phoenix_UIDB"].__currentProfile = currentProfile
            end
        end
    end
    
    -- Force write to disk
    pcall(function()
        if FlushSettingsDB then
            FlushSettingsDB()
        elseif FlushSavedVariables then
            FlushSavedVariables()
        end
    end)
    
    return true
end

-- SaveGuard - Ensures settings are properly saved, even when reload or crashes occur
function Phoenix_UI:InitSaveGuard()
    -- Create a frame to handle auto-save events
    local frame = CreateFrame("Frame")
    self.saveGuardFrame = frame
    
    -- Flag to track if a save is needed
    frame.saveNeeded = false
    frame.lastSave = GetTime()
    
    -- Attach handlers for various events that should trigger saving
    frame:RegisterEvent("PLAYER_LOGOUT")
    frame:RegisterEvent("PLAYER_CAMPING")
    frame:RegisterEvent("PLAYER_QUITING")
    
    -- Handle events to ensure saving during login/logout or reload
    frame:SetScript("OnEvent", function(self, event)
        if event == "PLAYER_LOGOUT" or 
           event == "PLAYER_CAMPING" or 
           event == "PLAYER_QUITING" then
            -- Force an immediate save before shutdown
            if Phoenix_UI.ForceSaveDB then
                Phoenix_UI:ForceSaveDB()
            elseif Phoenix_UI.SaveDB then
                Phoenix_UI:SaveDB(true)
            end
            
            -- Mark the final save timestamp
            if _G["Phoenix_UIDB"] then
                _G["Phoenix_UIDB"].__finalSave = GetTime()
                _G["Phoenix_UIDB"].__shutdownEvent = event
                
                -- Force setting to disk
                pcall(function()
                    if FlushSettingsDB then
                        FlushSettingsDB()
                    elseif FlushSavedVariables then
                        FlushSavedVariables()
                    end
                end)
            end
        end
    end)
    
    -- Create a ticker to periodically check and save if needed
    frame.autoSaveTicker = C_Timer.NewTicker(5, function()
        -- Check if any changes have been made recently
        if frame.saveNeeded or (GetTime() - frame.lastSave > 30) then
            -- Attempt a save
            if Phoenix_UI.SaveDB then
                Phoenix_UI:SaveDB()
                
                -- Record successful save
                frame.lastSave = GetTime()
                frame.saveNeeded = false
                
                -- Set timestamp for diagnostics
                if _G["Phoenix_UIDB"] then
                    _G["Phoenix_UIDB"].__autoSave = frame.lastSave
                end
            end
        end
    end)
    
    -- Hook various addon functions to ensure they trigger auto-save
    hooksecurefunc(self, "SaveDB", function()
        frame.lastSave = GetTime()
        frame.saveNeeded = false
    end)
    
    -- Create a method to flag that save is needed
    self.MarkSaveNeeded = function()
        frame.saveNeeded = true
    end
    
    -- Return the frame for reference
    return frame
end

-- Hook OnInitialize to add SaveGuard startup
local originalOnInitialize = Phoenix_UI.OnInitialize
Phoenix_UI.OnInitialize = function(self)
    -- Call original function first
    if originalOnInitialize then
        originalOnInitialize(self)
    end
    
    -- Initialize the SaveGuard after addon settings are loaded
    C_Timer.After(2, function()
        self:InitSaveGuard()
    end)
end

-- Add a reset function that can be called via /pui reset
function Phoenix_UI:ResetInstallation()
    local debug = true -- Always show debug for this critical operation
    
    print("|cffFF7D0APhoenix|r|cffFF0000_|r|cffFFD100UI|r: Resetting installation status...")
    
    -- Check database exists
    if not self.db or not self.db.profile then
        print("|cffFF7D0APhoenix|r|cffFF0000_|r|cffFFD100UI|r: Error - Database not available!")
        return false
    end
    
    -- Get current profile
    local currentProfile = self.db.keys and self.db.keys.profile or "Default"
    print("|cffFF7D0APhoenix|r|cffFF0000_|r|cffFFD100UI|r: Resetting profile: " .. currentProfile)
    
    -- Reset local flags
    self.db.profile.install = nil
    self.db.profile.reset = nil
    
    -- Reset global flags
    if _G["Phoenix_UIDB"] and _G["Phoenix_UIDB"].profiles then
        if _G["Phoenix_UIDB"].profiles[currentProfile] then
            _G["Phoenix_UIDB"].profiles[currentProfile].install = nil
            _G["Phoenix_UIDB"].profiles[currentProfile].reset = nil
            print("|cffFF7D0APhoenix|r|cffFF0000_|r|cffFFD100UI|r: Reset flags in current profile")
        end
        
        if _G["Phoenix_UIDB"].profiles["Default"] then
            _G["Phoenix_UIDB"].profiles["Default"].install = nil
            _G["Phoenix_UIDB"].profiles["Default"].reset = nil
            print("|cffFF7D0APhoenix|r|cffFF0000_|r|cffFFD100UI|r: Reset flags in Default profile")
        end
        
        -- Clear install timestamp
        _G["Phoenix_UIDB"].__installTime = nil
    else
        print("|cffFF7D0APhoenix|r|cffFF0000_|r|cffFFD100UI|r: Warning - Global Phoenix_UIDB not available!")
    end
    
    -- Force save
    if self.ForceSaveDB then
        self:ForceSaveDB()
    elseif self.SaveDB then
        self:SaveDB(true)
    end
    
    -- Flush to disk
    pcall(function()
        if FlushSettingsDB then
            FlushSettingsDB()
        elseif FlushSavedVariables then
            FlushSavedVariables()
        end
    end)
    
    -- Verify reset
    local isInstalled = self:IsInstalled()
    if isInstalled then
        print("|cffFF7D0APhoenix|r|cffFF0000_|r|cffFFD100UI|r: ERROR - Failed to reset installation status!")
        return false
    else
        print("|cffFF7D0APhoenix|r|cffFF0000_|r|cffFFD100UI|r: Installation reset successful. Please reload your UI.")
        print("|cffFF7D0APhoenix|r|cffFF0000_|r|cffFFD100UI|r: Type /reload to apply changes.")
        return true
    end
end

-- Add handling for "reset" in the slash command function
function Phoenix_UI:SlashCommand(input)
    -- Check if we have input
    input = input and input:trim() or ""
    
    if input == "reset" then
        -- Handle reset command
        self:ResetInstallation()
        return
    end
    
    -- Handle other existing commands...
    if self.Config then
        self:Config()
    end
end 