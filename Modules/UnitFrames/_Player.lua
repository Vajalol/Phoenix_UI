local Module = Phoenix_UI:NewModule("UnitFrames.Player");

function Module:OnEnable()
    local db = {
        unitframes = Phoenix_UI.db.profile.unitframes,
        texture = Phoenix_UI.db.profile.general.texture,
        classbar = Phoenix_UI.db.profile.unitframes.classbar
    }
    
    -- COMPLETELY NEW MANA COLOR SYSTEM
    -- Direct intervention to ensure mana is blue
    
    -- Override the global PowerBarColor for mana
    if PowerBarColor and PowerBarColor["MANA"] then
        local manaColor = PowerBarColor["MANA"]
        manaColor.r = 0
        manaColor.g = 0.5
        manaColor.b = 1
    end
    
    -- Function to find and color any mana bars
    local function colorManaBars()
        -- Only proceed if player uses mana
        if UnitPowerType("player") == 0 then
            -- Try coloring PlayerFrame manabar if it exists
            if PlayerFrame and PlayerFrame.manabar then
                PlayerFrame.manabar:SetStatusBarColor(0, 0.5, 1)
            end
            
            -- Force color the global PowerBar colors
            if PowerBarColor and PowerBarColor["MANA"] then
                local manaColor = PowerBarColor["MANA"]
                manaColor.r = 0
                manaColor.g = 0.5
                manaColor.b = 1
            end
        end
    end
    
    -- Hook key Blizzard functions
    hooksecurefunc("UnitFrameManaBar_Update", function(statusbar)
        if statusbar and statusbar.powerType == 0 then -- Mana
            statusbar:SetStatusBarColor(0, 0.5, 1)
        end
    end)
    
    -- Create a frame for handling events
    local eventFrame = CreateFrame("Frame")
    eventFrame:RegisterEvent("PLAYER_ENTERING_WORLD")
    eventFrame:RegisterEvent("UNIT_DISPLAYPOWER")
    eventFrame:RegisterEvent("PLAYER_SPECIALIZATION_CHANGED")
    eventFrame:RegisterEvent("ACTIVE_TALENT_GROUP_CHANGED")
    eventFrame:SetScript("OnEvent", function()
        colorManaBars()
        -- Make multiple attempts
        C_Timer.After(0.5, colorManaBars)
        C_Timer.After(1, colorManaBars)
        C_Timer.After(2, colorManaBars)
    end)
    
    -- Create a continuous timer to enforce this
    C_Timer.NewTicker(1, colorManaBars)

    if not db.unitframes.totemicons then
        hooksecurefunc(TotemFrame, "Update", function()
            TotemFrame:Hide()
        end)
    end

    if db.texture ~= [[Interface\Default]] then
        local function healthTexture(self, event)
            if event == "PLAYER_ENTERING_WORLD" then
                self.healthbar:SetStatusBarTexture(db.texture)
                self.healthbar:GetStatusBarTexture():SetDrawLayer("BORDER")
                self.healthbar.AnimatedLossBar:SetStatusBarTexture(db.texture)
                self.healthbar.AnimatedLossBar:GetStatusBarTexture():SetDrawLayer("BORDER")
            end
        end

        local function manaTexture(self)
            if self and self.manabar then
                -- Get Power Color
                local powerColor = PowerBarColor[self.manabar.powerType]

                -- Set Texture
                self.manabar.texture:SetTexture(db.texture)

                -- Set Power Color
                if self.manabar.powerType == 0 then
                    self.manabar:SetStatusBarColor(0, 0.5, 1)
                else
                    self.manabar:SetStatusBarColor(powerColor.r, powerColor.g, powerColor.b)
                end
            end
        end

        PlayerFrame:HookScript("OnEvent", function(self, event)
            healthTexture(self, event)
            manaTexture(self, event)

            if not db.unitframes.cornericon then
                if PlayerFrame.PlayerFrameContent and PlayerFrame.PlayerFrameContent.PlayerFrameContentContextual then
                    PlayerFrame.PlayerFrameContent.PlayerFrameContentContextual.PlayerPortraitCornerIcon:Hide()
                end
            end
        end)

        -- ALWAYS add extra hooks for mana color
        PlayerFrame:HookScript("OnShow", function() 
            C_Timer.After(0.5, colorManaBars)
        end)

        PetFrame:HookScript("OnEvent", function(self, event)
            if event == "PLAYER_ENTERING_WORLD" then
                self.healthbar:SetStatusBarTexture(db.texture)
                self.healthbar:GetStatusBarTexture():SetDrawLayer("BORDER")
            end
        end)
    end

    if not db.classbar then
        self.classBarHooks = self.classBarHooks or {}
        
        if RogueComboPointBarFrame then
            RogueComboPointBarFrame:HookScript("OnEvent", function()
                RogueComboPointBarFrame:Hide()
                Phoenix_UI:HookFunction(RogueComboPointBarFrame, "Show", function() end)
            end)
            self.classBarHooks["Rogue"] = RogueComboPointBarFrame
        end

        if MageArcaneChargesFrame then
            MageArcaneChargesFrame:HookScript("OnEvent", function()
                MageArcaneChargesFrame:Hide()
                Phoenix_UI:HookFunction(MageArcaneChargesFrame, "Show", function() end)
            end)
            self.classBarHooks["Mage"] = MageArcaneChargesFrame
        end

        if WarlockPowerFrame then
            WarlockPowerFrame:HookScript("OnEvent", function()
                WarlockPowerFrame:Hide()
                Phoenix_UI:HookFunction(WarlockPowerFrame, "Show", function() end)
            end)
            self.classBarHooks["Warlock"] = WarlockPowerFrame
        end

        if DruidComboPointBarFrame then
            DruidComboPointBarFrame:HookScript("OnEvent", function()
                DruidComboPointBarFrame:Hide()
                Phoenix_UI:HookFunction(DruidComboPointBarFrame, "Show", function() end)
            end)
            self.classBarHooks["Druid"] = DruidComboPointBarFrame
        end

        if MonkHarmonyBarFrame then
            MonkHarmonyBarFrame:HookScript("OnEvent", function()
                MonkHarmonyBarFrame:Hide()
                Phoenix_UI:HookFunction(MonkHarmonyBarFrame, "Show", function() end)
            end)
            self.classBarHooks["Monk"] = MonkHarmonyBarFrame
        end

        if EssencePlayerFrame then
            EssencePlayerFrame:HookScript("OnEvent", function()
                EssencePlayerFrame:Hide()
                Phoenix_UI:HookFunction(EssencePlayerFrame, "Show", function() end)
            end)
            self.classBarHooks["Evoker"] = EssencePlayerFrame
        end

        if RuneFrame then
            RuneFrame:HookScript("OnEvent", function()
                RuneFrame:Hide()
                Phoenix_UI:HookFunction(RuneFrame, "Show", function() end)
            end)
            self.classBarHooks["DeathKnight"] = RuneFrame
        end

        if PaladinPowerBarFrame then
            PaladinPowerBarFrame:HookScript("OnEvent", function()
                PaladinPowerBarFrame:Hide()
                Phoenix_UI:HookFunction(PaladinPowerBarFrame, "Show", function() end)
            end)
            self.classBarHooks["Paladin"] = PaladinPowerBarFrame
        end
    elseif self.classBarHooks then
        -- Restore class bars if the setting is enabled
        for _, frame in pairs(self.classBarHooks) do
            Phoenix_UI:UnhookFunction(frame, "Show")
            frame:Show()
        end
        self.classBarHooks = {}
    end

    local statusTexture = PlayerFrame.PlayerFrameContent.PlayerFrameContentMain.StatusTexture;
    local statusAnimation = PlayerFrame.PlayerFrameContent.PlayerFrameContentContextual.PlayerRestLoop

    hooksecurefunc("PlayerFrame_UpdateStatus", function(self)
        if (IsResting()) then
            statusTexture:Hide()
            statusAnimation:Hide()
        end
    end)
end



