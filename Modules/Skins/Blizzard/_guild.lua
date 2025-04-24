local Module = Phoenix_UI:NewModule("Skins.Guild");

function Module:OnEnable()
    if (Phoenix_UI:Color()) then
        Phoenix_UI:Skin(GuildRegistrarFrame, true)
        Phoenix_UI:Skin(GuildRegistrarFrame.NineSlice, true)
        Phoenix_UI:Skin(TabardFrame, true)
        Phoenix_UI:Skin(TabardFrame.NineSlice, true)

        local f = CreateFrame("Frame")
        f:RegisterEvent("ADDON_LOADED")
        f:SetScript("OnEvent", function(self, event, name)
            if name == "Blizzard_GuildBankUI" then
                Phoenix_UI:Skin(GuildBankFrameTab1, true)
                Phoenix_UI:Skin(GuildBankFrameTab2, true)
                Phoenix_UI:Skin(GuildBankFrameTab3, true)
                Phoenix_UI:Skin(GuildBankFrameTab4, true)
                Phoenix_UI:Skin(GuildBankFrame, true)
                Phoenix_UI:Skin({
                    GuildBankFrameLeft,
                    GuildBankFrameMiddle,
                    GuildBankFrameRight
                }, true, true)
                Phoenix_UI:Skin(GuildBankFrame.MoneyFrameBG, true)
                Phoenix_UI:Skin(GuildBankFrame.Column1, true)
                Phoenix_UI:Skin(GuildBankFrame.Column2, true)
                Phoenix_UI:Skin(GuildBankFrame.Column3, true)
                Phoenix_UI:Skin(GuildBankFrame.Column4, true)
                Phoenix_UI:Skin(GuildBankFrame.Column5, true)
                Phoenix_UI:Skin(GuildBankFrame.Column6, true)
                Phoenix_UI:Skin(GuildBankFrame.Column7, true)
            end
        end)
    end
end



