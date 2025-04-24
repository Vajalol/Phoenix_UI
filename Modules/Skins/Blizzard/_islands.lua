local Module = Phoenix_UI:NewModule("Skins.Islands");

function Module:OnEnable()
    if (Phoenix_UI:Color()) then
        local f = CreateFrame("Frame")
        f:RegisterEvent("ADDON_LOADED")
        f:SetScript("OnEvent", function(self, event, name)
            if name == "Blizzard_IslandsQueueUI" then
                Phoenix_UI:Skin(IslandsQueueFrame, true)
                Phoenix_UI:Skin(IslandsQueueFrame.NineSlice, true)
                Phoenix_UI:Skin(IslandsQueueFrame.ArtOverlayFrame, true)
            end
        end)
    end
end



