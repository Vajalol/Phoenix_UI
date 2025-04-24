local Module = Phoenix_UI:NewModule("Skins.Mail");

function Module:OnEnable()
    if (Phoenix_UI:Color()) then
        Phoenix_UI:Skin(MailFrame, true)
        Phoenix_UI:Skin(MailFrame.NineSlice, true)
        Phoenix_UI:Skin(OpenMailFrame, true)
        Phoenix_UI:Skin(OpenMailFrame.NineSlice, true)
        Phoenix_UI:Skin(MailFrameInset, true)
        Phoenix_UI:Skin(MailFrameInset.NineSlice, true)
        Phoenix_UI:Skin(OpenMailFrameInset, true)
        Phoenix_UI:Skin(OpenMailFrameInset.NineSlice, true)
        Phoenix_UI:Skin(SendMailMoneyInset, true)
        Phoenix_UI:Skin(SendMailMoneyInset.NineSlice, true)
        Phoenix_UI:Skin(SendMailMoneyBg, true)
        Phoenix_UI:Skin(SendMailFrame, true)

        -- Tabs
        Phoenix_UI:Skin(MailFrameTab1, true)
        Phoenix_UI:Skin(MailFrameTab2, true)
    end
end



