local Module = Phoenix_UI:NewModule("Config.Install");

function Module:OnEnable()
    -- Wait a short delay to ensure database initialization is complete
    C_Timer.After(0.5, function()
        -- First check if Phoenix_UI.db exists at all
        if not Phoenix_UI.db then 
            -- Database isn't ready yet, try again shortly
            C_Timer.After(1, function() self:OnEnable() end)
            return
        end
        
        -- DIRECT APPROACH: Check directly like SUI does, without relying on a separate function
        local isInstalled = false
        
        -- Check if already installed (direct profile check like SUI)
        if Phoenix_UI.db.profile and Phoenix_UI.db.profile.install then
            isInstalled = true
        end
        
        -- Use the IsInstalled function as a backup if it exists
        if not isInstalled and Phoenix_UI.IsInstalled and type(Phoenix_UI.IsInstalled) == "function" then
            isInstalled = Phoenix_UI:IsInstalled()
        end
        
        if not isInstalled then
            -- Tell the Core/Init.lua welcome panel not to show
            Phoenix_UI.useAlternateWelcomePanel = true
            
            local Install = CreateFrame("Frame", nil, UIParent)
            Install:SetWidth(GetScreenWidth())
            Install:SetHeight(GetScreenHeight())
            Install:SetPoint("CENTER", 0, 0)
            Install:EnableMouse(true)
            Install:SetFrameStrata("HIGH")
            Install.text = Install:CreateFontString(nil, "ARTWORK", "GameFontHighlight")
            Install.text:SetScale(3) -- Slightly reduced from 4 to prevent visual issues
            Install.text:SetPoint("CENTER", 0, 100) -- Moved up to prevent overlap with other elements
            Install.text:SetText("|cffFF7D0AWelcome to Phoenix|r|cffFF0000_|r|cffFFD100UI|r")

            local Texture = Install:CreateTexture(nil, "BACKGROUND")
            Texture:SetTexture("Interface\\DialogFrame\\UI-DialogBox-Background")
            Texture:SetAllPoints(Install)
            Install.texture = Texture

            local Subtitle = CreateFrame("Frame", "Subtitle", Install)
            Subtitle:SetSize(250, 50)
            Subtitle:SetPoint("CENTER", Install, 0, 30) -- Moved down to prevent overlap with title
            Subtitle.text = Subtitle:CreateFontString(nil, "ARTWORK", "QuestMapRewardsFont")
            Subtitle.text:SetPoint("CENTER", 0, 0)
            Subtitle.text:SetText("|cffFF7D0AThe Fire Side|r |cffFFD100of World of Warcraft|r")
            Subtitle.text:SetScale(1.4)

            -- Add our custom tagline
            local Tagline = CreateFrame("Frame", "Tagline", Install)
            Tagline:SetSize(500, 50)
            Tagline:SetPoint("CENTER", Subtitle, 0, -30)
            Tagline.text = Tagline:CreateFontString(nil, "ARTWORK", "QuestMapRewardsFont")
            Tagline.text:SetPoint("CENTER", 0, 0)
            Tagline.text:SetText("|cffFF3300T|r|cffFF4400y|r|cffFF5500p|r|cffFF6600e|r |cffFF7700/|r|cffFF8800p|r|cffFF9900u|r|cffFFAA00i|r |cffFFBB00t|r|cffFFCC00o|r |cffFFDD00o|r|cffFFEE00p|r|cffFFFF00e|r|cffFFEE00n|r |cffFFDD00C|r|cffFFCC00o|r|cffFFBB00n|r|cffFFAA00f|r|cffFF9900i|r|cffFF8800g|r |cffFF7700P|r|cffFF6600a|r|cffFF5500n|r|cffFF4400e|r|cffFF3300l|r |cffFF4400-|r |cffFF5500F|r|cffFF6600r|r|cffFF7700o|r|cffFF8800m|r |cffFF9900a|r|cffFFAA00s|r|cffFFBB00h|r|cffFFCC00e|r|cffFFDD00s|r |cffFFEE00t|r|cffFFFF00o|r |cffFFEE00a|r|cffFFDD00s|r|cffFFCC00h|r|cffFFBB00e|r|cffFFAA00s|r |cffFF9900W|r|cffFF8800e|r|cffFF7700l|r|cffFF6600c|r|cffFF5500o|r|cffFF4400m|r|cffFF3300e|r |cffFF4400t|r|cffFF5500o|r |cffFF6600f|r|cffFF7700i|r|cffFF8800r|r|cffFF9900e|r |cffFFAA00G|r|cffFFBB00a|r|cffFFCC00m|r|cffFFDD00e|r|cffFFEE00r|r")
            Tagline.text:SetScale(0.7)

            local Author = CreateFrame("Frame", "Author", Install)
            Author:SetSize(250, 50)
            Author:SetPoint("CENTER", Tagline, 0, -40) -- Further spacing
            Author.text = Author:CreateFontString(nil, "ARTWORK", "QuestMapRewardsFont")
            Author.text:SetPoint("CENTER", 0, 0)
            Author.text:SetText("|cffFF7D0AReworked By|r |cffFF0000VortexQ8|r")
            Author.text:SetScale(0.9)

            local Button = CreateFrame("Button", "Start", Install, "UIPanelButtonTemplate")
            Button:SetPoint("CENTER", 0, -60) -- Moved down for better spacing
            Button:SetSize(180, 40)
            Button:SetText("Begin Your Journey")
            Button:SetNormalTexture("Interface\\Common\\bluemenu-main")
            Button:GetNormalTexture():SetTexCoord(0.00390625, 0.87890625, 0.75195313, 0.83007813)
            Button:GetNormalTexture():SetVertexColor(0.265, 0.320, 0.410, 1)
            Button:SetHighlightTexture("Interface\\Common\\bluemenu-main")
            Button:GetHighlightTexture():SetTexCoord(0.00390625, 0.87890625, 0.75195313, 0.83007813)
            Button:GetHighlightTexture():SetVertexColor(0.265, 0.320, 0.410, 1)
            Button:SetScript("OnClick", function()
                -- SIMPLIFIED APPROACH: Set flag directly in both local and global databases like SUI does
                
                -- Set in local database
                if Phoenix_UI.db and Phoenix_UI.db.profile then
                    Phoenix_UI.db.profile.install = true
                    Phoenix_UI.db.profile.reset = true
                end
                
                -- Set in global database for persistence
                if _G["Phoenix_UIDB"] then
                    -- Make sure profiles table exists
                    if not _G["Phoenix_UIDB"].profiles then
                        _G["Phoenix_UIDB"].profiles = {}
                    end
                    
                    -- Get current profile
                    local currentProfile = Phoenix_UI.db and Phoenix_UI.db.keys and Phoenix_UI.db.keys.profile or "Default"
                    
                    -- Make sure current profile exists
                    if not _G["Phoenix_UIDB"].profiles[currentProfile] then
                        _G["Phoenix_UIDB"].profiles[currentProfile] = {}
                    end
                    
                    -- Set install flag directly in the global variable
                    _G["Phoenix_UIDB"].profiles[currentProfile].install = true
                    _G["Phoenix_UIDB"].profiles[currentProfile].reset = true
                    
                    -- Also set in Default profile for safety
                    if not _G["Phoenix_UIDB"].profiles["Default"] then
                        _G["Phoenix_UIDB"].profiles["Default"] = {}
                    end
                    _G["Phoenix_UIDB"].profiles["Default"].install = true
                    _G["Phoenix_UIDB"].profiles["Default"].reset = true
                end
                
                -- Try to also use the SetInstalled function if available, but don't rely on it
                if Phoenix_UI.SetInstalled and type(Phoenix_UI.SetInstalled) == "function" then
                    pcall(function() Phoenix_UI:SetInstalled() end)
                end
                
                -- Force save if available
                if Phoenix_UI.ForceSaveDB and type(Phoenix_UI.ForceSaveDB) == "function" then
                    pcall(function() Phoenix_UI:ForceSaveDB() end)
                elseif Phoenix_UI.SaveDB and type(Phoenix_UI.SaveDB) == "function" then
                    pcall(function() Phoenix_UI:SaveDB(true) end)
                end
                
                -- Try to flush settings to disk
                pcall(function()
                    if FlushSettingsDB then
                        FlushSettingsDB()
                    elseif FlushSavedVariables then
                        FlushSavedVariables()
                    end
                end)
                
                local fadeInfo = {};
                fadeInfo.mode = "OUT";
                fadeInfo.timeToFade = 0.4;
                fadeInfo.finishedFunc = function()
                    Install:Hide()
                    -- Only call Config if it exists
                    if Phoenix_UI.Config then
                        Phoenix_UI:Config()
                    end
                end
                UIFrameFade(Install, fadeInfo);
            end)
            
            -- Store the panel in the addon for later access
            Phoenix_UI.InstallPanel = Install
        end
    end)
end




