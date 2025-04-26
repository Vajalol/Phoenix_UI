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