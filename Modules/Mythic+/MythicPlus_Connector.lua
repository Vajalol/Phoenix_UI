-- Phoenix_UI: Mythic+ Config Connector
-- This file ensures proper registration of Mythic+ features in the Phoenix UI config
local addonName, Phoenix = ...

-- Wait for PLAYER_LOGIN to ensure both config systems are loaded
local frame = CreateFrame("Frame")
frame:RegisterEvent("PLAYER_LOGIN")
frame:SetScript("OnEvent", function(self, event)
    -- Debug helper function
    local function DebugMessage(msg)
        if Phoenix_UI and Phoenix_UI.debug then
            print("|cff00ffffPhoenix UI Mythic+:|r " .. msg)
        end
    end
    
    DebugMessage("MythicPlus_Connector initializing...")
    
    -- Get module reference
    local MythicPlus = Phoenix.Modules.MythicPlus

    -- Don't proceed if module is missing
    if not MythicPlus then
        DebugMessage("ERROR: MythicPlus module is missing!")
        if Phoenix_UI.debug then
            print("Phoenix UI: |cffff9900Mythic+ module missing.|r")
        end
        return
    end
    
    -- Ensure the module has a valid database
    if not MythicPlus.db then
        DebugMessage("WARNING: MythicPlus.db is missing, creating default")
        MythicPlus.db = {
            profile = {
                enabled = true,
                showTimer = true,
                showObjectives = true,
                deathPenalty = true,
                enhanceKeystones = true,
                integrateWithPhoenix = true,
                progressFormat = "PERCENTAGE_AND_VALUE",
                timerFormat = "REMAINING",
                showEnemyTooltip = true,
                showChestTimers = true,
            }
        }
    elseif not MythicPlus.db.profile then
        DebugMessage("WARNING: MythicPlus.db.profile is missing, creating default")
        MythicPlus.db.profile = {
            enabled = true,
            showTimer = true,
            showObjectives = true,
            deathPenalty = true,
            enhanceKeystones = true,
            integrateWithPhoenix = true,
            progressFormat = "PERCENTAGE_AND_VALUE",
            timerFormat = "REMAINING",
            showEnemyTooltip = true,
            showChestTimers = true,
        }
    end
    
    -- Ensure the config module has the latest settings
    if MythicPlus.db and MythicPlus.db.profile then
        -- Synchronize settings to config module
        if Phoenix_UI.db and Phoenix_UI.db.profile then
            if not Phoenix_UI.db.profile.mythicplus then
                DebugMessage("Copying MythicPlus settings to Phoenix_UI.db.profile.mythicplus")
                Phoenix_UI.db.profile.mythicplus = CopyTable(MythicPlus.db.profile)
            else
                DebugMessage("Phoenix_UI.db.profile.mythicplus already exists")
            end
        else
            DebugMessage("ERROR: Phoenix_UI.db or Phoenix_UI.db.profile is missing!")
        end
    else
        DebugMessage("ERROR: MythicPlus.db or MythicPlus.db.profile is still missing after attempted repair!")
    end
    
    -- If ConfigSystem exists, register the layout there as well
    if Phoenix_UI.ConfigSystem and Phoenix_UI.ConfigSystem.RegisterLayout then
        -- Get the layout from the module's config
        local Config = MythicPlus:GetModule("Config", true)
        if Config and Config.CreateConfigLayout then
            -- Create the layout and register it
            DebugMessage("Registering MythicPlus layout with Phoenix_UI.ConfigSystem")
            pcall(function() Config:CreateConfigLayout() end)
        else
            DebugMessage("ERROR: Config module or CreateConfigLayout method not found!")
        end
    else
        DebugMessage("Phoenix_UI.ConfigSystem not available, skipping layout registration")
    end
    
    -- Force refresh of the config panel if it's open
    if Phoenix_UIConfig and Phoenix_UIConfig.RefreshPanel then
        DebugMessage("Refreshing MythicPlus panel")
        pcall(function() Phoenix_UIConfig:RefreshPanel("MythicPlus") end)
    else
        DebugMessage("Phoenix_UIConfig not available, skipping panel refresh")
    end
    
    DebugMessage("MythicPlus_Connector initialization complete")
end) 