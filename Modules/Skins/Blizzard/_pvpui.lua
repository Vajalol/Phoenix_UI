local Module = Phoenix_UI:NewModule("Skins.PvPUI");

function Module:OnEnable()
    if (Phoenix_UI:Color()) then
        local f = CreateFrame("Frame")
        f:RegisterEvent("ADDON_LOADED")
        f:SetScript("OnEvent", function(self, event, name)
            if name == "Blizzard_PVPUI" then
                Phoenix_UI:Skin(HonorFrame, true)
                Phoenix_UI:Skin(HonorFrame.ConquestFrame, true)
                Phoenix_UI:Skin(HonorFrame.Inset, true)
                Phoenix_UI:Skin(HonorFrame.Inset.NineSlice, true)
                Phoenix_UI:Skin(HonorFrame.BonusFrame, true)
                Phoenix_UI:Skin(ConquestFrame, true)
                Phoenix_UI:Skin(ConquestFrame.ConquestBar, true)
                Phoenix_UI:Skin(ConquestFrame.Inset, true)
                Phoenix_UI:Skin(ConquestFrame.Inset.NineSlice, true)
                Phoenix_UI:Skin(PVPQueueFrame, true)
                Phoenix_UI:Skin(PVPQueueFrame.HonorInset, true)
                Phoenix_UI:Skin(PVPQueueFrame.HonorInset.NineSlice, true)
                PVPQueueFrame.HonorInset:Hide();
            end
        end)
    end
end



