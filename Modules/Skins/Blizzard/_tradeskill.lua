local Module = Phoenix_UI:NewModule("Skins.TradeSkill");

function Module:OnEnable()
    if (Phoenix_UI:Color()) then
        local f = CreateFrame("Frame")
        f:RegisterEvent("ADDON_LOADED")
        f:SetScript("OnEvent", function(self, event, name)
            if name == "Blizzard_TradeSkillUI" then
                Phoenix_UI:Skin(TradeSkillFrame, true)
                Phoenix_UI:Skin(TradeSkillFrame.NineSlice, true)
            end
        end)
    end
end



