local Module = Phoenix_UI:NewModule("Skins.Trade");

function Module:OnEnable()
    if (Phoenix_UI:Color()) then
        Phoenix_UI:Skin(TradeFrame, true)
        Phoenix_UI:Skin(TradeFrame.NineSlice, true)
        Phoenix_UI:Skin(TradeFrame.RecipientOverlay, true)
        Phoenix_UI:Skin(TradeFrameInset.NineSlice, true)
        Phoenix_UI:Skin(TradePlayerEnchantInset, true)
        Phoenix_UI:Skin(TradePlayerEnchantInset.NineSlice, true)
        Phoenix_UI:Skin(TradePlayerItemsInset.NineSlice, true)
        Phoenix_UI:Skin(TradeRecipientItemsInset.NineSlice, true)
        Phoenix_UI:Skin(TradeRecipientMoneyBg, true)
        Phoenix_UI:Skin(TradeRecipientMoneyInset.NineSlice, true)
        Phoenix_UI:Skin(TradeRecipientEnchantInset, true)
        Phoenix_UI:Skin(TradeRecipientEnchantInset.NineSlice, true)
    end
end



