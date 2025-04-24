local Module = Phoenix_UI:NewModule("Skins.Azerit");

function Module:OnEnable()
    if (Phoenix_UI:Color()) then
        local f = CreateFrame("Frame")
        f:RegisterEvent("ADDON_LOADED")
        f:SetScript("OnEvent", function(self, event, name)
            if name == "Blizzard_AzeriteUI" then
                Phoenix_UI:Skin(AzeriteEmpoweredItemUI.BorderFrame, true)
                Phoenix_UI:Skin(AzeriteEmpoweredItemUI.BorderFrame.NineSlice, true)
            end

            if name == "Blizzard_AzeriteRespecUI" then
                Phoenix_UI:Skin(AzeriteRespecFrame, true)
                Phoenix_UI:Skin(AzeriteRespecFrame.NineSlice, true)
            end

            if name == "Blizzard_AzeriteEssenceUI" then
                Phoenix_UI:Skin(AzeriteEssenceUI, true)
                Phoenix_UI:Skin(AzeriteEssenceUI.NineSlice, true)
                Phoenix_UI:Skin(AzeriteEssenceUI.LeftInset.NineSlice, true)
                Phoenix_UI:Skin(AzeriteEssenceUI.RightInset.NineSlice, true)
                Phoenix_UI:Skin(AzeriteEssenceUI.EssenceList.ScrollBar, true)
            end
        end)
    end
end



