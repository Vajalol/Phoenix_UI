local Module = Phoenix_UI:NewModule("Skins.Garrison");

function Module:OnEnable()
    if (Phoenix_UI:Color()) then
        local f = CreateFrame("Frame")
        f:RegisterEvent("ADDON_LOADED")
        f:SetScript("OnEvent", function(self, event, name)
            if name == "Blizzard_GarrisonUI" then
                Phoenix_UI:Skin(GarrisonCapacitiveDisplayFrame, true)
                Phoenix_UI:Skin(GarrisonCapacitiveDisplayFrame.NineSlice, true)
                Phoenix_UI:Skin(GarrisonCapacitiveDisplayFrameInset, true)
                Phoenix_UI:Skin(GarrisonCapacitiveDisplayFrameInset.NineSlice, true)
            end
        end)
    end
end



