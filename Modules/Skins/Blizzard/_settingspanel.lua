local Module = Phoenix_UI:NewModule("Skins.Settingspanel");

function Module:OnEnable()
    if (Phoenix_UI:Color()) then
        local f = CreateFrame("Frame")
        f:RegisterEvent("ADDON_LOADED")
        f:SetScript("OnEvent", function(self, event, name)
            Phoenix_UI:Skin(SettingsPanel, true)
            Phoenix_UI:Skin(SettingsPanel.Bg, true)
            Phoenix_UI:Skin(SettingsPanel.NineSlice, true)
        end)
    end
end



