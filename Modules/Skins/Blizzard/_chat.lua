local Module = Phoenix_UI:NewModule("Skins.Chat");

function Module:OnEnable()
    if (Phoenix_UI:Color()) then
        Phoenix_UI:Skin(ChatFrame1EditBox, true)
        Phoenix_UI:Skin(ChatFrame2EditBox, true)
        Phoenix_UI:Skin(ChatFrame3EditBox, true)
        Phoenix_UI:Skin(ChatFrame4EditBox, true)
        Phoenix_UI:Skin(ChatFrame5EditBox, true)
        Phoenix_UI:Skin(ChatFrame6EditBox, true)
        Phoenix_UI:Skin(ChatFrame7EditBox, true)
        Phoenix_UI:Skin(ChannelFrame, true)
        Phoenix_UI:Skin(ChannelFrame.NineSlice, true)
        Phoenix_UI:Skin(ChannelFrame.LeftInset.NineSlice, true)
        Phoenix_UI:Skin(ChannelFrame.RightInset.NineSlice, true)
        Phoenix_UI:Skin(ChannelFrameInset.NineSlice, true)
        Phoenix_UI:Skin(ChatConfigFrame, true)
        Phoenix_UI:Skin(ChatConfigFrame.Header, true)
        Phoenix_UI:Skin(ChatConfigFrame.Border, true)
        Phoenix_UI:Skin(ChatConfigBackgroundFrame, true)
        Phoenix_UI:Skin(ChatConfigBackgroundFrame.NineSlice, true)
        Phoenix_UI:Skin(ChatConfigCategoryFrame, true)
        Phoenix_UI:Skin(ChatConfigCategoryFrame.NineSlice, true)
    end
end



