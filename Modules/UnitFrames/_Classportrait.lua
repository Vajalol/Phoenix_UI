local Module = Phoenix_UI:NewModule("Misc.Classportrait");

function Module:OnEnable()
    local db = Phoenix_UI.db.profile.unitframes.portrait
    if (db == 'ClassIcon') then
        local TEXTURE_NAME = "Interface\\Phoenix_UI\\Media\\Textures\\ClassPortraits\\%s.tga"
        hooksecurefunc("UnitFramePortrait_Update", function(self)
            if self.portrait then
                if UnitIsPlayer(self.unit) then
                    local _, class = UnitClass(self.unit)
                    if class then
                        self.portrait:SetTexture(TEXTURE_NAME:format(class))
                    end
                end
            end
        end)
    end
end



