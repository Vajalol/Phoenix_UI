local Module = Phoenix_UI:NewModule("Skins.FlightMap");

function Module:OnEnable()
    if (Phoenix_UI:Color()) then
        local f = CreateFrame("Frame")
        f:RegisterEvent("ADDON_LOADED")
        f:SetScript("OnEvent", function(self, event, name)
            if name == "Blizzard_FlightMap" then
                Phoenix_UI:Skin(FlightMapFrame, true)
                Phoenix_UI:Skin(FlightMapFrame.BorderFrame, true)
                Phoenix_UI:Skin(FlightMapFrame.BorderFrame.NineSlice, true)
            end
        end)
    end
end



