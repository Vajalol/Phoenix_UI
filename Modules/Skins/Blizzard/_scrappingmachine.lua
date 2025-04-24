local Module = Phoenix_UI:NewModule("Skins.ScrappingMachine");

function Module:OnEnable()
    if (Phoenix_UI:Color()) then
        local f = CreateFrame("Frame")
        f:RegisterEvent("ADDON_LOADED")
        f:SetScript("OnEvent", function(self, event, name)
            if name == "Blizzard_ScrappingMachineUI" then
                Phoenix_UI:Skin(ScrappingMachineFrame, true)
                Phoenix_UI:Skin(ScrappingMachineFrame.NineSlice, true)
            end
        end)
    end
end



