local Module = Phoenix_UI:NewModule("UnitFrames.Target");

function Module:OnEnable()

    local db = {
        unitframes = Phoenix_UI.db.profile.unitframes,
        texture = Phoenix_UI.db.profile.general.texture,
        theme = Phoenix_UI.db.profile.general.theme
    }
    
    -- Ensure unitframes.debuffs exists with default values
    if not db.unitframes.debuffs then
        db.unitframes.debuffs = {
            size = 34,
            padding = 2,
            icons = 10
        }
        -- Also make sure it persists by updating the actual database
        Phoenix_UI.db.profile.unitframes.debuffs = db.unitframes.debuffs
    end
    
    -- Ensure unitframes.buffs exists with default values
    if not db.unitframes.buffs then
        db.unitframes.buffs = {
            size = 32,
            padding = 2,
            icons = 10
        }
        -- Also make sure it persists by updating the actual database
        Phoenix_UI.db.profile.unitframes.buffs = db.unitframes.buffs
    end

    -- Set Target/Focus Textures
    local function healthTexture(self)
        if self:IsForbidden() then return end
        
        -- Set Textures
        self.healthbar:SetStatusBarTexture(db.texture)
        self.healthbar:GetStatusBarTexture():SetDrawLayer("BORDER")
        if self.myHealPrediction then
            self.myHealPredictionBar:SetTexture(db.texture)
        end
    end

    local hooked = {}
    local function UpdateFrameAuras(aura)
        if db.theme ~= 'Blizzard' then
            if not hooked[aura] then
                hooked[aura] = true

                local icon = aura.Icon
                icon:SetTexCoord(0.1, 0.9, 0.1, 0.9)
                icon:SetDrawLayer("BACKGROUND", -8)

                if not aura.border then
                    local border = aura.border or
                        aura:CreateTexture(aura.border, "BACKGROUND", nil, -7)

                    border:SetTexture("Interface\\Phoenix_UI\\Media\\Textures\\Core\\gloss")
                    border:SetTexCoord(0, 1, 0, 1)
                    border:SetDrawLayer("BACKGROUND", -7)
                    border:ClearAllPoints()
                    border:SetPoint("TOPLEFT", aura, "TOPLEFT", -1, 1)
                    border:SetPoint("BOTTOMRIGHT", aura, "BOTTOMRIGHT", 1, -1)
                    aura.border = border

                    local backdrop = {
                        bgFile = nil,
                        edgeFile = "Interface\\Phoenix_UI\\Media\\Textures\\Core\\outer_shadow",
                        tile = false,
                        tileSize = 32,
                        edgeSize = 4,
                        insets = {
                            left = 4,
                            right = 4,
                            top = 4,
                            bottom = 4,
                        },
                    }
                    local back = CreateFrame("Frame", nil, aura, "BackdropTemplate")
                    back:SetPoint("TOPLEFT", aura, "TOPLEFT", -4, 4)
                    back:SetPoint("BOTTOMRIGHT", aura, "BOTTOMRIGHT", 4, -4)
                    back:SetFrameLevel(aura:GetFrameLevel() - 1)
                    back:SetBackdrop(backdrop)
                    back:SetBackdropBorderColor(unpack(Phoenix_UI:Color(0.25, 0.9)))
                    aura.bg = back
                end
            end
        end
    end

    local function Phoenix_UIColorRepBar(self)
        local reputationBar = self.TargetFrameContent.TargetFrameContentMain.ReputationColor
        reputationBar:SetVertexColor(unpack(Phoenix_UI:Color(0.15)))
    end

    -- Hooks

    hooksecurefunc(TargetFrame, "OnEvent", function(self)
        -- Set Health Texture
        if db.texture ~= [[Interface\Default]] then
            healthTexture(self)
        end

        -- Recolor Reputation Bar
        if (Phoenix_UI:Color()) then
            Phoenix_UIColorRepBar(self)
        end

        -- Style Buffs & Debuffs
        for aura, _ in self.auraPools:EnumerateActive() do
            UpdateFrameAuras(aura)
        end
    end)

    hooksecurefunc(FocusFrame, "OnEvent", function(self)
        -- Set Health Texture
        if db.texture ~= [[Interface\Default]] then
            healthTexture(self)
        end

        -- Recolor Reputation Bar
        if (Phoenix_UI:Color()) then
            Phoenix_UIColorRepBar(self)
        end

        -- Style Buffs & Debuffs
        for aura, _ in self.auraPools:EnumerateActive() do
            UpdateFrameAuras(aura)
        end
    end)

    hooksecurefunc(TargetFrameToT, "Update", function(self)
        -- Set Health Texture
        if db.texture ~= [[Interface\Default]] then
            healthTexture(self)
        end
    end)

    hooksecurefunc(FocusFrameToT, "Update", function(self)
        -- Set Health Texture
        if db.texture ~= [[Interface\Default]] then
            healthTexture(self)
        end
    end)

    -- Set TargetFrame Buff/Debuff SetSize
    hooksecurefunc("TargetFrame_UpdateBuffAnchor", function(_, buff)
        -- Check if the unitframes buffs table exists before accessing it
        if not buff or not db.unitframes.buffs then return end
        
        buff:SetSize(db.unitframes.buffs.size, db.unitframes.buffs.size)

        if buff.Count then
            local fontSize = db.unitframes.buffs.size / 2.75
            buff.Count:SetFont(STANDARD_TEXT_FONT, 10, "OUTLINE")
            buff.Count:ClearAllPoints()
            buff.Count:SetPoint("BOTTOMRIGHT", buff, "BOTTOMRIGHT", 2, 0)
        end
    end)

    hooksecurefunc("TargetFrame_UpdateDebuffAnchor", function(_, debuff)
        -- Check if the unitframes debuffs table exists before accessing it
        if not debuff or not db.unitframes.debuffs then return end
        
        debuff:SetSize(db.unitframes.debuffs.size, db.unitframes.debuffs.size)

        if debuff.Count then
            local fontSize = db.unitframes.debuffs.size / 2.75
            debuff.Count:SetFont(STANDARD_TEXT_FONT, 10, "OUTLINE")
            debuff.Count:ClearAllPoints()
            debuff.Count:SetPoint("BOTTOMRIGHT", debuff, "BOTTOMRIGHT", 2, 0)
        end
    end)
end



