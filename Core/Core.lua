function Phoenix_UI:SaveDB(force)
    -- If no database, just return
    if not self.db then return end
    
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
    end
    
    return true
end

-- Commit any pending changes from UI widgets to ensure complete data is saved
function Phoenix_UI:CommitPendingChanges()
    -- Debug output
    local debug = self.debug or false
    
    if debug then
        print("Phoenix_UI: CommitPendingChanges called")
    end
    
    -- Track which modules were modified for optimized saving
    local modifiedModules = {}
    
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
        
        -- ENHANCED: Track which tab is currently active
        local activeTab = nil
        if self.UI.tabs and self.UI.tabs.selectedTab and self.UI.tabs.selectedTab.name then
            activeTab = self.UI.tabs.selectedTab.name:lower()
            modifiedModules[activeTab] = true
            
            if debug then
                print("Phoenix_UI: Active tab is " .. activeTab)
            end
        end
        
        -- Ensure all dropdowns and other widgets have their values saved
        if self.UI.elements then
            for elementID, element in pairs(self.UI.elements) do
                if element and element.Commit and type(element.Commit) == "function" then
                    pcall(function() element:Commit() end)
                end
                
                -- ENHANCED: Track which module this element belongs to
                if element and element.dataKey then
                    local moduleName = element.dataKey:match("^([^%.]+)")
                    if moduleName then
                        modifiedModules[moduleName] = true
                        
                        if debug then
                            print("Phoenix_UI: Tracked element change in module " .. moduleName)
                        end
                    end
                end
            end
        end
        
        -- Mark modules as needing a save in the UI
        self.UI.settingsChanged = true
        self.UI.lastModifiedModules = modifiedModules
    end
    
    -- Ensure profile database is properly synced
    if self.db and self.db.profile then
        -- Ensure critical settings tables exist
        local criticalModules = {
            "general", "actionbars", "unitframes", "nameplates", "chat", 
            "tooltip", "map", "fonts", "uiscaling", "buffs", "castbars",
            "msbt", "idtip", "buffoverlay", "misc"
        }
        
        -- Current time for tracking
        local timestamp = GetTime()
        
        -- Check if any critical modules were modified
        local criticalModified = false
        for _, moduleName in ipairs(criticalModules) do
            if modifiedModules[moduleName] then
                criticalModified = true
                break
            end
        end
        
        -- Mark that settings have changed
        self.settingsChanged = true
        
        -- ENHANCED: Force immediate save for critical module changes
        if criticalModified then
            -- Use a short delay to batch rapid changes
            if not self._criticalSaveTimer then
                self._criticalSaveTimer = C_Timer.After(0.3, function()
                    self._criticalSaveTimer = nil
                    
                    -- Force save
                    if self.SaveDB then
                        self:SaveDB()
                    end
                    
                    -- Ensure we flush to disk
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
    
    -- Return success flag
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
    
    -- Debug info
    local debug = self.debug or false
    if debug then
        print("Phoenix_UI: ForceSaveDB called")
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
    
    -- Add debug info
    if debug then
        print("Phoenix_UI: ForceSaveDB saving to profile " .. currentProfile)
    end
    _G["Phoenix_UIDB"].__lastForceMethod = "ForceSaveDB"
    _G["Phoenix_UIDB"].__lastForceTime = GetTime()
    
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
    
    -- Ensure profileKeys exists and is set correctly
    if not _G["Phoenix_UIDB"].profileKeys then
        _G["Phoenix_UIDB"].profileKeys = {}
    end
    
    -- Make sure this character is assigned to the correct profile
    local playerName = UnitName("player")
    local realmName = GetRealmName()
    local playerKey = playerName .. " - " .. realmName
    
    if _G["Phoenix_UIDB"].profileKeys[playerKey] ~= currentProfile then
        _G["Phoenix_UIDB"].profileKeys[playerKey] = currentProfile
        if debug then
            print("Phoenix_UI: Fixed profile key for " .. playerKey .. " to " .. currentProfile)
        end
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
            
            if debug then
                print("Phoenix_UI: ForceSaveDB saved module " .. moduleName)
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
    
    -- ENHANCED: More comprehensive module list
    local criticalModules = {
        "general", "nameplates", "actionbars", "castbars", "buffs", "msbt", "idtip",
        "tooltip", "map", "chat", "misc", "uiscaling", "fonts", "unitframes",
        "cooldowntracker", "weakauras", "mythicplus", "raidframes"
    }
    
    -- Get current profile for recovery
    local currentProfile = self.db.keys and self.db.keys.profile or "Default"
    
    -- Loop through critical modules
    for _, moduleName in ipairs(criticalModules) do
        -- Ensure the module settings exist
        if not self.db.profile[moduleName] then
            self.db.profile[moduleName] = {}
            
            -- Try to recover from global savedvariables if available
            if _G["Phoenix_UIDB"] and _G["Phoenix_UIDB"].profiles then
                -- First try current profile
                if _G["Phoenix_UIDB"].profiles[currentProfile] and 
                   _G["Phoenix_UIDB"].profiles[currentProfile][moduleName] then
                    -- Copy settings from current profile
                    self.db.profile[moduleName] = CopyTable(_G["Phoenix_UIDB"].profiles[currentProfile][moduleName])
                
                -- Then try Default profile if current profile doesn't have settings
                elseif _G["Phoenix_UIDB"].profiles.Default and 
                       _G["Phoenix_UIDB"].profiles.Default[moduleName] then
                    -- Copy settings from Default profile
                    self.db.profile[moduleName] = CopyTable(_G["Phoenix_UIDB"].profiles.Default[moduleName])
                end
            end
        end
        
        -- Module-specific validation
        if moduleName == "nameplates" then
            -- Ensure nameplates settings have required fields
            local np = self.db.profile.nameplates
            np.decimals = np.decimals or "1"
            np.style = np.style or "Default"
            np.npccolors = np.npccolors or {}
            np.enabled = np.enabled ~= false -- default to true
            np.stackingmode = np.stackingmode ~= nil and np.stackingmode or false
            np.height = np.height or 1.0
            np.width = np.width or 1.0
            np.texture = np.texture or "Blizzard"
            
        elseif moduleName == "actionbars" then
            -- Ensure actionbars settings have required fields
            local ab = self.db.profile.actionbars
            ab.mouseover = ab.mouseover or false
            ab.enable = ab.enable or false
            ab.enabled = ab.enabled ~= false -- default to true
            ab.numrows = ab.numrows or 1
            ab.buttonsize = ab.buttonsize or 32
            ab.buttonspacing = ab.buttonspacing or 4
            
        elseif moduleName == "castbars" then
            -- Ensure castbars settings have required fields
            local cb = self.db.profile.castbars
            cb.enabled = cb.enabled ~= false -- default to true
            cb.texture = cb.texture or "Blizzard"
            cb.enableplayer = cb.enableplayer ~= false -- default to true
            cb.enabletarget = cb.enabletarget ~= false -- default to true
            cb.enablefocus = cb.enablefocus ~= false -- default to true
            
        elseif moduleName == "buffs" then
            -- Ensure buffs settings have required fields
            local buff = self.db.profile.buffs
            buff.enabled = buff.enabled ~= false -- default to true
            buff.size = buff.size or 30
            buff.spacing = buff.spacing or 2
            buff.growthx = buff.growthx or "RIGHT"
            buff.growthy = buff.growthy or "UP"
            
        elseif moduleName == "tooltip" then
            -- Ensure tooltip settings have required fields
            local tooltip = self.db.profile.tooltip
            tooltip.enabled = tooltip.enabled ~= false -- default to true
            tooltip.scale = tooltip.scale or 1.0
            tooltip.combathide = tooltip.combathide ~= nil and tooltip.combathide or false
            tooltip.cursor = tooltip.cursor ~= nil and tooltip.cursor or false
            
        elseif moduleName == "map" then
            -- Ensure map settings have required fields
            local map = self.db.profile.map
            map.enabled = map.enabled ~= false -- default to true
            map.scale = map.scale or 1.0
            map.position = map.position or "BOTTOMRIGHT"
            map.miniblips = map.miniblips ~= nil and map.miniblips or true
            
        elseif moduleName == "chat" then
            -- Ensure chat settings have required fields
            local chat = self.db.profile.chat
            chat.enabled = chat.enabled ~= false -- default to true
            chat.fontsize = chat.fontsize or 12
            chat.sticky = chat.sticky ~= nil and chat.sticky or true
            chat.emojis = chat.emojis ~= nil and chat.emojis or true
            chat.timestamps = chat.timestamps ~= nil and chat.timestamps or true
            
        elseif moduleName == "msbt" then
            -- Ensure msbt settings have required fields
            local msbt = self.db.profile.msbt
            msbt.enabled = msbt.enabled or false
            
        elseif moduleName == "idtip" then
            -- Ensure idtip settings have required fields
            local idtip = self.db.profile.idtip
            idtip.enabled = idtip.enabled ~= false -- default to true
            
        elseif moduleName == "fonts" then
            -- Ensure font settings have required fields
            local fonts = self.db.profile.fonts
            fonts.gameFont = fonts.gameFont or {}
            fonts.gameFont.family = fonts.gameFont.family or "Friz Quadrata TT"
            
        elseif moduleName == "uiscaling" then
            -- Ensure UI scaling settings have required fields
            local ui = self.db.profile.uiscaling
            ui.scale = ui.scale or 1.0
            ui.enabled = ui.enabled ~= false -- default to true
            
        elseif moduleName == "general" then
            -- Ensure general settings have required fields
            local general = self.db.profile.general
            general.font = general.font or "Friz Quadrata TT"
            general.theme = general.theme or "Dark"
            general.color = general.color or {r = 1, g = 0.5, b = 0, a = 1} -- Phoenix Orange
            
            -- Sync font settings for consistency
            if general.font then
                self.db.profile.fonts = self.db.profile.fonts or {}
                self.db.profile.fonts.gameFont = self.db.profile.fonts.gameFont or {}
                self.db.profile.fonts.gameFont.family = general.font
            end
        end
    end
    
    -- Ensure fonts are synced between general and fonts table
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
    
    -- Ensure character-to-profile mapping is correct
    if _G["Phoenix_UIDB"] then
        local playerKey = UnitName("player") .. " - " .. GetRealmName()
        _G["Phoenix_UIDB"].profileKeys = _G["Phoenix_UIDB"].profileKeys or {}
        _G["Phoenix_UIDB"].profileKeys[playerKey] = currentProfile
    end
    
    -- Also apply font settings if available
    if self.ApplyFontSettings then
        pcall(function() self:ApplyFontSettings() end)
    end
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

-- Implementation of the missing InitFromDB function
function Phoenix_UI:InitFromDB()
    local debug = self.debug or false
    
    if debug then
        print("Phoenix_UI: InitFromDB called")
    end
    
    -- Skip if already initialized
    if self.dataInitialized then
        return
    end
    
    -- Verify database is available
    if not self.db or not self.db.profile then
        if debug then
            print("Phoenix_UI: InitFromDB - Database not available")
        end
        return
    end
    
    -- Get current profile
    local currentProfile = self.db.keys and self.db.keys.profile or "Default"
    
    -- Check for global settings in Phoenix_UIDB
    if _G["Phoenix_UIDB"] and _G["Phoenix_UIDB"].profiles then
        -- Ensure current profile exists in global DB
        if not _G["Phoenix_UIDB"].profiles[currentProfile] then
            _G["Phoenix_UIDB"].profiles[currentProfile] = CopyTable(self.db.profile)
        end
        
        -- Ensure critical settings tables exist in both local and global DB
        local criticalModules = {
            "general", "actionbars", "unitframes", "nameplates", "chat", 
            "tooltip", "map", "fonts", "uiscaling", "buffs", "castbars",
            "msbt", "idtip", "buffoverlay", "misc"
        }
        
        -- Initialize missing settings tables in local DB
        for _, moduleName in ipairs(criticalModules) do
            if not self.db.profile[moduleName] then
                self.db.profile[moduleName] = {}
                
                -- Try to recover from global savedvariables
                if _G["Phoenix_UIDB"].profiles[currentProfile] and 
                   _G["Phoenix_UIDB"].profiles[currentProfile][moduleName] then
                    self.db.profile[moduleName] = CopyTable(_G["Phoenix_UIDB"].profiles[currentProfile][moduleName])
                    
                    if debug then
                        print("Phoenix_UI: Recovered " .. moduleName .. " settings from global DB")
                    end
                end
            end
        end
        
        -- Synchronize between global and local DB
        if self.SyncModuleSettings then
            self:SyncModuleSettings()
        end
    end
    
    -- Mark as initialized to prevent re-initialization
    self.dataInitialized = true
    
    if debug then
        print("Phoenix_UI: InitFromDB complete")
    end
    
    return true
end

-- Implementation of the missing OnPlayerEnteringWorld function
function Phoenix_UI:OnPlayerEnteringWorld()
    local debug = self.debug or false
    
    if debug then
        print("Phoenix_UI: OnPlayerEnteringWorld called")
    end
    
    -- Initialize from database if not already done
    if not self.dataInitialized then
        self:InitFromDB()
    end
    
    -- Get current profile and playerKey
    local currentProfile = self.db and self.db.keys and self.db.keys.profile or "Default"
    local playerName = UnitName("player")
    local realmName = GetRealmName()
    local playerKey = playerName .. " - " .. realmName
    
    -- ENHANCED: PROFILE CONSISTENCY CHECK - This is critical for fixing Default profile issues
    if _G["Phoenix_UIDB"] then
        -- Ensure profileKeys exists
        if not _G["Phoenix_UIDB"].profileKeys then
            _G["Phoenix_UIDB"].profileKeys = {}
            
            if debug then
                print("Phoenix_UI: Created missing profileKeys table")
            end
        end
        
        -- Check if there's a mismatch between AceDB and global profileKeys
        local globalProfile = _G["Phoenix_UIDB"].profileKeys[playerKey]
        
        -- ENHANCED: Handle profile synchronization
        if globalProfile and globalProfile ~= currentProfile then
            -- There's a mismatch - decide what to do
            if debug then
                print("Phoenix_UI: Profile mismatch detected. AceDB=" .. currentProfile .. ", Global=" .. globalProfile)
            end
            
            -- Try to determine which is more recent
            local aceProfileUpdated = false
            local globalProfileUpdated = false
            
            -- Check if we have the profiles in AceDB
            if self.db and self.db.profiles and self.db.profiles[globalProfile] then
                -- AceDB has the global profile - might be safe to switch
                aceProfileUpdated = true
            end
            
            -- Check if global DB has the current profile
            if _G["Phoenix_UIDB"].profiles and _G["Phoenix_UIDB"].profiles[currentProfile] then
                globalProfileUpdated = true
            end
            
            -- ENHANCED: Decide which profile to use based on most recent changes
            local useAceProfile = true -- Default to keeping current AceDB profile
            
            -- If both profiles exist, check which one was updated more recently
            if aceProfileUpdated and globalProfileUpdated then
                -- Get last update timestamps if available
                local aceTimestamp = 0
                local globalTimestamp = 0
                
                if _G["Phoenix_UIDB"].profiles[currentProfile] and _G["Phoenix_UIDB"].profiles[currentProfile].__updated then
                    aceTimestamp = _G["Phoenix_UIDB"].profiles[currentProfile].__updated
                end
                
                if _G["Phoenix_UIDB"].profiles[globalProfile] and _G["Phoenix_UIDB"].profiles[globalProfile].__updated then
                    globalTimestamp = _G["Phoenix_UIDB"].profiles[globalProfile].__updated
                end
                
                -- Use the more recently updated profile
                if globalTimestamp > aceTimestamp then
                    useAceProfile = false
                end
            elseif globalProfileUpdated and not aceProfileUpdated then
                -- Only global profile exists
                useAceProfile = false
            end
            
            -- Apply the decision
            if useAceProfile then
                -- Update global profileKeys to match AceDB
                _G["Phoenix_UIDB"].profileKeys[playerKey] = currentProfile
                
                if debug then
                    print("Phoenix_UI: Updated global profileKeys to " .. currentProfile)
                end
            else
                -- Switch AceDB to match global profileKeys
                if self.db and self.db.SetProfile then
                    -- Use AceDB method to switch profiles
                    pcall(function() self.db:SetProfile(globalProfile) end)
                    
                    -- Update current profile reference
                    currentProfile = globalProfile
                    
                    if debug then
                        print("Phoenix_UI: Switched AceDB profile to " .. globalProfile)
                    end
                else
                    -- Fallback - update global to match AceDB
                    _G["Phoenix_UIDB"].profileKeys[playerKey] = currentProfile
                    
                    if debug then
                        print("Phoenix_UI: Updated global profileKeys to match AceDB (fallback)")
                    end
                end
            end
        else
            -- Profiles match or global profile doesn't exist - update global to be sure
            _G["Phoenix_UIDB"].profileKeys[playerKey] = currentProfile
        end
        
        -- ENHANCED: Ensure we have profiles table in global DB
        if not _G["Phoenix_UIDB"].profiles then
            _G["Phoenix_UIDB"].profiles = {}
        end
        
        -- ENHANCED: Ensure current profile exists in global DB
        if not _G["Phoenix_UIDB"].profiles[currentProfile] then
            _G["Phoenix_UIDB"].profiles[currentProfile] = {}
            
            if debug then
                print("Phoenix_UI: Created missing profile in global DB: " .. currentProfile)
            end
        end
        
        -- ENHANCED: Sync settings from AceDB to global DB if we have any
        if self.db and self.db.profile and next(self.db.profile) ~= nil then
            -- Critical modules to synchronize
            local criticalModules = {
                "general", "nameplates", "actionbars", "castbars", "buffs", "msbt", "idtip",
                "tooltip", "map", "chat", "misc", "uiscaling", "fonts", "unitframes"
            }
            
            for _, moduleName in ipairs(criticalModules) do
                if self.db.profile[moduleName] and type(self.db.profile[moduleName]) == "table" then
                    -- Update global DB with current settings
                    _G["Phoenix_UIDB"].profiles[currentProfile][moduleName] = CopyTable(self.db.profile[moduleName])
                    
                    if debug then
                        print("Phoenix_UI: Synced " .. moduleName .. " to global DB")
                    end
                end
            end
            
            -- Update timestamp
            _G["Phoenix_UIDB"].profiles[currentProfile].__updated = GetTime()
            _G["Phoenix_UIDB"].profiles[currentProfile].__synced = true
        end
    end
    
    -- ENHANCED: Apply theme settings if needed
    if self.db and self.db.profile and self.db.profile.general and self.db.profile.general.theme then
        -- Call ApplyTheme function if it exists
        if self.ApplyTheme then
            pcall(function() self:ApplyTheme(self.db.profile.general.theme) end)
        end
    end
    
    -- ENHANCED: Apply font settings if needed
    if self.db and self.db.profile and self.db.profile.fonts then
        -- Call ApplyFontSettings function if it exists
        if self.ApplyFontSettings then
            pcall(function() self:ApplyFontSettings() end)
        end
    end
    
    -- ENHANCED: Validate all settings to ensure they exist
    self:ValidateSettings()
    
    -- Set up periodic autosave if not already running
    if not self.autoSaveTimer then
        self.autoSaveTimer = C_Timer.NewTicker(120, function() -- Save every 2 minutes
            -- Only save if settings have changed
            if self.settingsChanged then
                self:SaveAllSettings()
                self.settingsChanged = false
            end
        end)
    end
    
    -- Mark initialization as complete
    self.dataInitialized = true
end