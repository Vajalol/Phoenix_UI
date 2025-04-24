local Module = Phoenix_UI:NewModule("Skins.Alliedraces");

function Module:OnEnable()
    if (Phoenix_UI:Color()) then
        local f = CreateFrame("Frame")
        f:RegisterEvent("ADDON_LOADED")
        f:SetScript("OnEvent", function(self, event, name)
            if name == "Blizzard_AlliedRacesUI" then
                Phoenix_UI:Skin(AlliedRacesFrame, true)
                Phoenix_UI:Skin(AlliedRacesFrame.NineSlice, true)
                Phoenix_UI:Skin(AlliedRacesFrameInset.NineSlice, true)
            end
        end)
    end
end



