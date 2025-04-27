-- Phoenix_UI: Detail Skin Config Connector
-- This file ensures proper registration of Detail Skin features in the Phoenix UI config
local addonName, Phoenix = ...

-- Wait for PLAYER_LOGIN to ensure all systems are loaded
local frame = CreateFrame("Frame")
frame:RegisterEvent("PLAYER_LOGIN")
frame:RegisterEvent("ADDON_LOADED")
frame:SetScript("OnEvent", function(self, event, addon)
    if event == "ADDON_LOADED" and addon == "Details" then
        -- Details! has been loaded, notify our module
        local DetailsSkin = Phoenix_UI:GetModule("DetailsSkin", true)
        if DetailsSkin then
            DetailsSkin:OnDetailsLoaded()
            
            -- Apply compatibility patches for Details components
            C_Timer.After(2, function()
                -- Create a safer version of the ApplySkin method for Details instances
                if DetailsSkin and DetailsSkin.ApplySkin then
                    local originalApplySkin = DetailsSkin.ApplySkin
                    DetailsSkin.ApplySkin = function(self)
                        -- Call original function
                        local result = originalApplySkin(self)
                        
                        -- Additional compatibility patches after main skin applied
                        C_Timer.After(0.5, function()
                            -- Apply our patch to any Details window that might exist
                            if _G._detalhes then
                                -- For all registered Details instances 
                                if _G._detalhes.tabela_instancias then
                                    for _, instance in ipairs(_G._detalhes.tabela_instancias) do
                                        if instance and instance.baseframe then
                                            -- Add safety wrapper for SetWindowColor if needed
                                            if type(instance.SetWindowColor) == "function" and 
                                               not instance.__phoenix_safe_set_window_color then
                                                instance.__phoenix_safe_set_window_color = true
                                                local originalSetWindowColor = instance.SetWindowColor
                                                instance.SetWindowColor = function(self, ...)
                                                    -- Try original function, but catch errors
                                                    local success, err = pcall(originalSetWindowColor, self, ...)
                                                    if not success then
                                                        -- Fallback color setting if original fails
                                                        if self.baseframe and self.baseframe.SetBackdropColor then
                                                            self.baseframe:SetBackdropColor(...)
                                                        end
                                                    end
                                                end
                                            end
                                        end
                                    end
                                end
                                
                                -- Try to patch the playerbreakdown window specifically
                                -- Handle window breakdown which has a different object path
                                if _G._detalhes and _G._detalhes.playerDetailWindow then
                                    local playerDetailWindow = _G._detalhes.playerDetailWindow
                                    if playerDetailWindow and not playerDetailWindow.SetColor then
                                        playerDetailWindow.SetColor = function(self, r, g, b, a)
                                            -- Fallback implementation that won't cause errors
                                            if self.bg and type(self.bg.SetColorTexture) == "function" then
                                                self.bg:SetColorTexture(r or 0.1, g or 0.1, b or 0.1, a or 0.9)
                                            end
                                        end
                                    end
                                    
                                    -- Also patch main frame if it exists
                                    if playerDetailWindow.container and not playerDetailWindow.container.SetColor then
                                        playerDetailWindow.container.SetColor = function(self, r, g, b, a)
                                            if self.SetBackdropColor then
                                                self:SetBackdropColor(r or 0.1, g or 0.1, b or 0.1, a or 0.9)
                                            end
                                        end
                                    end
                                end
                            end
                        end)
                        
                        return result
                    end
                end
                
                -- Try to fix any already created Details windows
                if _G._detalhes then
                    -- Patch window_playerbreakdown objects that are causing issues
                    local addSetColorMethod = function(obj)
                        if obj and not obj.SetColor then
                            obj.SetColor = function(self, r, g, b, a)
                                -- Do nothing, just prevent errors
                            end
                        end
                    end
                    
                    -- Add to main objects
                    if _G._detalhes.breakdown_window then
                        addSetColorMethod(_G._detalhes.breakdown_window)
                        if _G._detalhes.breakdown_window.frame then
                            addSetColorMethod(_G._detalhes.breakdown_window.frame)
                        end
                    end
                    
                    -- Details has different object hierarchies in different versions
                    -- Try to cover all possible object paths mentioned in errors
                    if _G._detalhes.janela_info then 
                        addSetColorMethod(_G._detalhes.janela_info)
                    end
                    if _G._detalhes.playerDetailWindow then
                        addSetColorMethod(_G._detalhes.playerDetailWindow)
                    end
                end
            end)
        end
    end
    
    if event == "PLAYER_LOGIN" then
        -- Get module references
        local DetailsSkin = Phoenix_UI:GetModule("DetailsSkin", true)
        local ConfigDetailSkin = Phoenix_UI:GetModule("Config.Layout.DetailSkin", true)
        
        -- Don't proceed if the module is missing
        if not DetailsSkin then
            if Phoenix_UI.debug then
                print("Phoenix UI: |cffff9900Detail Skin module not found.|r")
            end
            return
        end
        
        -- Ensure the database exists
        if not Phoenix_UI.db.profile.detailskin then
            Phoenix_UI.db.profile.detailskin = {
                enabled = true,
                shadowBorders = true,
                transparentBackground = true,
                colors = {
                    background = {r = 0.1, g = 0.1, b = 0.1, a = 0.8},
                    border = {r = 0.8, g = 0.3, b = 0, a = 0.9},
                    text = {r = 1, g = 1, b = 1, a = 1},
                    bar = {r = 0.8, g = 0.3, b = 0, a = 0.9}
                }
            }
        end
        
        -- Add method to check if Details is loaded directly on the module
        DetailsSkin.IsDetailsAvailable = function()
            return _G._detalhes ~= nil
        end
        
        -- Create a detail scan function
        DetailsSkin.ScanDetails = function(self)
            if not self:IsDetailsAvailable() then return end
            
            -- Log available profiles
            if Phoenix_UI.debug then
                local profiles = {}
                for name, _ in pairs(_G._detalhes_global.profiles) do
                    table.insert(profiles, name)
                end
                print("Phoenix UI: |cffff9900Details! profiles found:|r", table.concat(profiles, ", "))
            end
            
            -- Apply skin if auto-apply is enabled
            if Phoenix_UI.db.profile.detailskin.enabled then
                DetailsSkin:ApplySkin()
            end
        end
        
        -- Set up details watcher
        C_Timer.After(2, function() 
            DetailsSkin:ScanDetails()
        end)
        
        -- Force refresh of the config panel if it's open
        if Phoenix_UIConfig and Phoenix_UIConfig.RefreshPanel then
            Phoenix_UIConfig:RefreshPanel("DetailSkin")
        end
    end
end) 