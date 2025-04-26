-- Phoenix_UI: Mythic+ Config Connector
-- This file ensures proper registration of Mythic+ features in the Phoenix UI config
local addonName, Phoenix = ...

-- Wait for PLAYER_LOGIN to ensure both config systems are loaded
local frame = CreateFrame("Frame")
frame:RegisterEvent("PLAYER_LOGIN")
frame:SetScript("OnEvent", function(self, event)
    -- Get both module references
    local MythicPlus = Phoenix_UI:GetModule("MythicPlus", true)
    local ConfigMythicPlus = Phoenix_UI:GetModule("Config.Layout.MythicPlus", true)
    
    -- Don't proceed if either module is missing
    if not MythicPlus or not ConfigMythicPlus then
        if Phoenix_UI.debug then
            print("Phoenix UI: |cffff9900Mythic+ module or config missing.|r")
        end
        return
    end
    
    -- Ensure the config module has the latest settings
    if MythicPlus.db and MythicPlus.db.profile then
        -- Synchronize settings to config module
        if Phoenix_UI.db and Phoenix_UI.db.profile and not Phoenix_UI.db.profile.mythicplus then
            Phoenix_UI.db.profile.mythicplus = CopyTable(MythicPlus.db.profile)
        end
    end
    
    -- If ConfigSystem exists, register the layout there as well
    if Phoenix_UI.ConfigSystem and Phoenix_UI.ConfigSystem.RegisterLayout then
        -- Get the layout from the module's config
        local Config = MythicPlus:GetModule("Config", true)
        if Config and Config.CreateConfigLayout then
            -- Create the layout and register it
            Config:CreateConfigLayout()
        end
    end
    
    -- Force refresh of the config panel if it's open
    if Phoenix_UIConfig and Phoenix_UIConfig.RefreshPanel then
        Phoenix_UIConfig:RefreshPanel("MythicPlus")
    end
end) 