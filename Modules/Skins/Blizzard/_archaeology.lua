local Module = Phoenix_UI:NewModule("Skins.Archaeology");

function Module:OnEnable()
    if (Phoenix_UI:Color()) then
        local f = CreateFrame("Frame")
        f:RegisterEvent("ADDON_LOADED")
        f:SetScript("OnEvent", function(self, event, name)
            if name == "Blizzard_ArchaeologyUI" then
                Phoenix_UI:Skin(ArchaeologyFrame.NineSlice, true)
            end
        end)
    end
end



